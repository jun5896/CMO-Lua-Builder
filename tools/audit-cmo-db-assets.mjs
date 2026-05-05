#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';

const PROJECT_ROOT = path.resolve(new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1'));
const DEFAULT_CMO_ROOT = 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Command - Modern Operations';
const DEFAULT_OUT = path.join(PROJECT_ROOT, 'public', 'cmo-db-assets-index.json');

function parseArgs(argv) {
  const options = {
    cmoRoot: process.env.CMO_ROOT || DEFAULT_CMO_ROOT,
    out: DEFAULT_OUT,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--cmo-root') {
      options.cmoRoot = argv[index + 1] || options.cmoRoot;
      index += 1;
    } else if (value === '--out') {
      options.out = argv[index + 1] || options.out;
      index += 1;
    }
  }

  return options;
}

async function readJsonIfExists(filePath) {
  try {
    return JSON.parse(await fs.readFile(filePath, 'utf8'));
  } catch {
    return null;
  }
}

async function fileStat(filePath) {
  try {
    return await fs.stat(filePath);
  } catch {
    return null;
  }
}

async function listFiles(root, predicate = () => true, limit = 5000) {
  const files = [];

  async function visit(directory) {
    let entries = [];
    try {
      entries = await fs.readdir(directory, { withFileTypes: true });
    } catch {
      return;
    }

    for (const entry of entries) {
      const fullPath = path.join(directory, entry.name);
      if (entry.isDirectory()) {
        await visit(fullPath);
      } else if (entry.isFile() && predicate(entry.name, fullPath)) {
        const stat = await fileStat(fullPath);
        if (stat) {
          files.push({
            name: entry.name,
            path: fullPath,
            relativePath: path.relative(root, fullPath),
            sizeBytes: stat.size,
            lastWriteTime: stat.mtime.toISOString(),
          });
        }
      }

      if (files.length >= limit) return;
    }
  }

  await visit(root);
  return files;
}

function parseDbInfo(file) {
  const match = /^(DB3K|CWDB)_(\d+)([A-Za-z]*)\.db3$/i.exec(file.name);
  return {
    ...file,
    family: match?.[1]?.toUpperCase() || 'Other',
    versionNumber: match ? Number(match[2]) : 0,
    versionSuffix: match?.[3] || '',
  };
}

function newestByFamily(dbFiles) {
  const result = {};
  for (const file of dbFiles) {
    const current = result[file.family];
    if (
      !current
      || file.versionNumber > current.versionNumber
      || (file.versionNumber === current.versionNumber && file.lastWriteTime > current.lastWriteTime)
    ) {
      result[file.family] = file;
    }
  }
  return result;
}

function compactFileList(files, limit = 30) {
  return files
    .sort((a, b) => b.lastWriteTime.localeCompare(a.lastWriteTime) || a.relativePath.localeCompare(b.relativePath))
    .slice(0, limit);
}

function comparableDbFile(file) {
  return [
    file.name,
    file.family,
    file.versionNumber,
    file.versionSuffix || '',
    file.sizeBytes,
    file.lastWriteTime,
  ].join('|');
}

function summarizeDbDelta(previous, nextDbFiles) {
  const previousFiles = Array.isArray(previous?.dbFiles) ? previous.dbFiles : [];
  const previousMap = new Map(previousFiles.map((file) => [file.name.toLowerCase(), file]));
  const nextMap = new Map(nextDbFiles.map((file) => [file.name.toLowerCase(), file]));
  const added = [];
  const removed = [];
  const changed = [];

  for (const [key, nextFile] of nextMap) {
    const previousFile = previousMap.get(key);
    if (!previousFile) {
      added.push(nextFile);
    } else if (comparableDbFile(previousFile) !== comparableDbFile(nextFile)) {
      changed.push({ before: previousFile, after: nextFile });
    }
  }

  for (const [key, previousFile] of previousMap) {
    if (!nextMap.has(key)) removed.push(previousFile);
  }

  const previousLatest = previous?.latestByFamily || {};
  const latestChanged = {};
  const nextLatest = newestByFamily(nextDbFiles);
  for (const family of [...new Set([...Object.keys(previousLatest), ...Object.keys(nextLatest)])]) {
    const before = previousLatest[family];
    const after = nextLatest[family];
    if ((before?.name || '') !== (after?.name || '') || (before?.sizeBytes || 0) !== (after?.sizeBytes || 0)) {
      latestChanged[family] = { before: before || null, after: after || null };
    }
  }

  return {
    previousGeneratedAt: previous?.generatedAt || '',
    addedCount: added.length,
    removedCount: removed.length,
    changedCount: changed.length,
    latestChanged,
    added,
    removed,
    changed,
  };
}

async function scanDirectorySummary(root, name) {
  const stat = await fileStat(root);
  if (!stat?.isDirectory()) {
    return { name, path: root, exists: false, fileCount: 0, newestFiles: [] };
  }

  const files = await listFiles(root, () => true);
  return {
    name,
    path: root,
    exists: true,
    fileCount: files.length,
    newestFiles: compactFileList(files, 20),
  };
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const cmoRoot = path.resolve(options.cmoRoot);
  const dbRoot = path.join(cmoRoot, 'DB');
  const manualsRoot = path.join(cmoRoot, 'Manuals');
  const descriptionsRoot = path.join(dbRoot, 'Descriptions');
  const templatesRoot = path.join(dbRoot, 'Templates');
  const outPath = path.resolve(options.out);

  const dbFiles = (await listFiles(dbRoot, (name) => name.toLowerCase().endsWith('.db3')))
    .map(parseDbInfo)
    .sort((a, b) => a.family.localeCompare(b.family) || b.versionNumber - a.versionNumber || a.name.localeCompare(b.name));
  const previous = await readJsonIfExists(outPath);
  const latestByFamily = newestByFamily(dbFiles);

  const output = {
    generatedAt: new Date().toISOString(),
    cmoRoot,
    dbRoot,
    dbFiles,
    latestByFamily,
    supportFolders: [
      await scanDirectorySummary(descriptionsRoot, 'DB Descriptions'),
      await scanDirectorySummary(templatesRoot, 'DB Templates'),
      await scanDirectorySummary(manualsRoot, 'Manuals'),
    ],
    delta: summarizeDbDelta(previous, dbFiles),
    note: 'Run this after CMO updates. If latestByFamily changes, re-check DBID/Loadout guidance and regenerate user-facing warnings before trusting old presets.',
  };

  await fs.mkdir(path.dirname(outPath), { recursive: true });
  await fs.writeFile(outPath, `${JSON.stringify(output, null, 2)}\n`, 'utf8');
  console.log(`CMO DB assets index written: ${outPath}`);
  for (const [family, file] of Object.entries(latestByFamily)) {
    console.log(`${family}: ${file.name} (${file.sizeBytes} bytes, ${file.lastWriteTime})`);
  }
  console.log(`Delta: +${output.delta.addedCount} / ~${output.delta.changedCount} / -${output.delta.removedCount}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
