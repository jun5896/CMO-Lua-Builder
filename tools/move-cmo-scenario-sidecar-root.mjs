#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import {
  DEFAULT_EXTERNAL_SIDECAR_ROOT,
  getConfiguredSidecarRoot,
  isSafeSidecarRoot,
  isSameOrInside,
  LEGACY_INTERNAL_SIDECAR_ROOT,
} from './sidecar-paths.mjs';

const DEFAULT_FROM = LEGACY_INTERNAL_SIDECAR_ROOT;
const DEFAULT_TO = getConfiguredSidecarRoot() || DEFAULT_EXTERNAL_SIDECAR_ROOT;

function usage() {
  return [
    'Usage:',
    '  node tools/move-cmo-scenario-sidecar-root.mjs [--from <dir>] [--to <dir>] [--copy|--move] [--yes]',
    '',
    'Default mode is dry-run. The default target is:',
    `  ${DEFAULT_TO}`,
    '',
    'Examples:',
    '  npm run move:scenario-sidecars',
    '  npm run move:scenario-sidecars -- --copy --yes',
    '  npm run move:scenario-sidecars -- --move --yes',
  ].join('\n');
}

function parseArgs(argv) {
  const options = {
    from: DEFAULT_FROM,
    to: DEFAULT_TO,
    copy: false,
    move: false,
    yes: false,
    top: 10,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--from') {
      options.from = argv[index + 1] || DEFAULT_FROM;
      index += 1;
    } else if (value === '--to') {
      options.to = argv[index + 1] || DEFAULT_TO;
      index += 1;
    } else if (value === '--copy') {
      options.copy = true;
    } else if (value === '--move') {
      options.move = true;
    } else if (value === '--yes') {
      options.yes = true;
    } else if (value === '--top') {
      options.top = Math.max(0, Number(argv[index + 1] || 0));
      index += 1;
    } else if (value === '--help' || value === '-h') {
      console.log(usage());
      process.exit(0);
    }
  }

  if (options.copy && options.move) {
    throw new Error('Use only one of --copy or --move.');
  }

  return options;
}

async function statSafe(filePath) {
  try {
    return await fs.stat(filePath);
  } catch {
    return null;
  }
}

async function listFiles(root) {
  const entries = await fs.readdir(root, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...await listFiles(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }

  return files;
}

function formatBytes(bytes) {
  return {
    bytes,
    mb: Number((bytes / 1024 / 1024).toFixed(1)),
    gb: Number((bytes / 1024 / 1024 / 1024).toFixed(3)),
  };
}

function makeRecord(fromRoot, toRoot, sourcePath, sourceStat, targetStat) {
  const relative = path.relative(fromRoot, sourcePath);
  const targetPath = path.join(toRoot, relative);
  const exists = Boolean(targetStat?.isFile());
  const sameSize = exists && targetStat.size === sourceStat.size;
  const conflict = exists && !sameSize;

  return {
    sourcePath,
    targetPath,
    relativePath: relative.replace(/\\/g, '/'),
    size: sourceStat.size,
    exists,
    sameSize,
    conflict,
    needsCopy: !exists,
  };
}

async function buildPlan(fromRoot, toRoot) {
  const sourceFiles = await listFiles(fromRoot);
  const records = [];

  for (const sourcePath of sourceFiles) {
    const sourceStat = await statSafe(sourcePath);
    if (!sourceStat?.isFile()) continue;

    const relative = path.relative(fromRoot, sourcePath);
    const targetPath = path.join(toRoot, relative);
    const targetStat = await statSafe(targetPath);
    records.push(makeRecord(fromRoot, toRoot, sourcePath, sourceStat, targetStat));
  }

  return records;
}

async function copyRecord(record) {
  if (!record.needsCopy) return;
  await fs.mkdir(path.dirname(record.targetPath), { recursive: true });
  await fs.copyFile(record.sourcePath, record.targetPath);
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const fromRoot = path.resolve(options.from);
  const toRoot = path.resolve(options.to);

  if (!isSafeSidecarRoot(fromRoot)) {
    throw new Error(`Refusing to migrate from an unsafe sidecar root: ${fromRoot}`);
  }
  if (!isSafeSidecarRoot(toRoot)) {
    throw new Error(`Refusing to migrate to an unsafe sidecar root: ${toRoot}`);
  }
  if (isSameOrInside(toRoot, fromRoot) || isSameOrInside(fromRoot, toRoot)) {
    throw new Error(`Refusing nested migration roots: from=${fromRoot}, to=${toRoot}`);
  }

  const fromStat = await statSafe(fromRoot);
  if (!fromStat?.isDirectory()) {
    throw new Error(`Source sidecar root not found: ${fromRoot}`);
  }

  const records = await buildPlan(fromRoot, toRoot);
  const conflicts = records.filter((record) => record.conflict);
  const existingSame = records.filter((record) => record.sameSize);
  const toCopy = records.filter((record) => record.needsCopy);
  const totalBytes = records.reduce((sum, record) => sum + record.size, 0);
  const copyBytes = toCopy.reduce((sum, record) => sum + record.size, 0);
  const mode = options.yes && (options.copy || options.move)
    ? options.move ? 'move' : 'copy'
    : 'dry-run';

  const summary = {
    from: fromRoot,
    to: toRoot,
    mode,
    files: records.length,
    total: formatBytes(totalBytes),
    alreadyPresentSameSize: existingSame.length,
    toCopy: {
      files: toCopy.length,
      ...formatBytes(copyBytes),
    },
    conflicts: {
      files: conflicts.length,
      top: conflicts.slice(0, options.top).map((record) => ({
        file: record.relativePath,
        sourceBytes: record.size,
      })),
    },
    note: 'Dry-run is default. Use --copy --yes to duplicate to the external cache, or --move --yes to copy then remove the source root.',
  };

  console.log(JSON.stringify(summary, null, 2));

  if (conflicts.length > 0) {
    throw new Error('Destination has conflicting files. Resolve or choose another --to root before copying.');
  }

  if (mode === 'dry-run') {
    console.log('\nDry-run only. No files were copied or deleted.');
    return;
  }

  for (const record of toCopy) {
    await copyRecord(record);
  }

  if (mode === 'move') {
    // Only remove after every missing file has been copied and conflicts were rejected.
    await fs.rm(fromRoot, { recursive: true, force: true });
  }

  console.log(`\n${mode === 'move' ? 'Moved' : 'Copied'} ${toCopy.length} files to ${toRoot}.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
