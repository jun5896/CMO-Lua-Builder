#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import {
  getPreferredSidecarRoot,
  getSidecarIndexPath,
  isSafeSidecarRoot,
  normalizeSidecarReference,
} from './sidecar-paths.mjs';

const DEFAULT_ROOT = getPreferredSidecarRoot();
const DEFAULT_INDEX = getSidecarIndexPath(DEFAULT_ROOT);

function usage() {
  return [
    'Usage:',
    '  node tools/prune-cmo-scenario-sidecar-cache.mjs [--root <dir>] [--index <file>] [--prune-orphans] [--yes] [--top <n>]',
    '',
    'Default mode is audit-only. With --prune-orphans, the tool still dry-runs unless --yes is also supplied.',
    'Referenced sidecars from scenario-openability-index.json are always protected.',
  ].join('\n');
}

function parseArgs(argv) {
  const options = {
    root: DEFAULT_ROOT,
    index: '',
    pruneOrphans: false,
    yes: false,
    top: 12,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--root') {
      options.root = argv[index + 1] || DEFAULT_ROOT;
      index += 1;
    } else if (value === '--index') {
      options.index = argv[index + 1] || DEFAULT_INDEX;
      index += 1;
    } else if (value === '--prune-orphans') {
      options.pruneOrphans = true;
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

  return options;
}

function isSameOrInside(target, root) {
  const resolvedTarget = path.resolve(target);
  const resolvedRoot = path.resolve(root);
  const relative = path.relative(resolvedRoot, resolvedTarget);
  return !relative || (!relative.startsWith('..') && !path.isAbsolute(relative));
}

function isSafeRoot(root) {
  return isSafeSidecarRoot(root);
}

async function statSafe(filePath) {
  try {
    return await fs.stat(filePath);
  } catch {
    return null;
  }
}

async function readJsonSafe(filePath) {
  try {
    return JSON.parse((await fs.readFile(filePath, 'utf8')).replace(/^\uFEFF/, ''));
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

function normalizeRelative(value = '') {
  return String(value || '').replace(/\\/g, '/').replace(/^\/+/, '');
}

function sidecarPathFromIndexFile(root, fileName = '') {
  const normalized = normalizeSidecarReference(fileName);
  if (!normalized) return '';

  return path.join(root, normalized);
}

function addProtected(protectedPaths, root, fileName) {
  const target = sidecarPathFromIndexFile(root, fileName);
  if (!target) return;
  if (!isSameOrInside(target, root)) return;
  protectedPaths.add(path.resolve(target).toLowerCase());
}

function collectProtectedPaths(root, indexPath, indexData) {
  const protectedPaths = new Set([path.resolve(indexPath).toLowerCase()]);
  const scenarios = Array.isArray(indexData?.scenarios) ? indexData.scenarios : [];

  for (const scenario of scenarios) {
    for (const sidecar of scenario?.sidecars || []) {
      addProtected(protectedPaths, root, sidecar.file);
    }

    addProtected(protectedPaths, root, scenario?.lastAttempt?.diagnosticFile);
  }

  return protectedPaths;
}

function classifyFile(root, protectedPaths, filePath, size) {
  const lowerPath = path.resolve(filePath).toLowerCase();
  const ext = path.extname(filePath).toLowerCase() || '(none)';
  const relativePath = normalizeRelative(path.relative(root, filePath));
  const protectedByIndex = protectedPaths.has(lowerPath);

  let kind = 'other';
  if (/scenario-openability-index\.json$/i.test(relativePath)) kind = 'index';
  else if (/\.summary\.json$/i.test(relativePath)) kind = 'summary';
  else if (/\.scenario\.xml\.error\.json$/i.test(relativePath)) kind = 'diagnosticError';
  else if (/\.json$/i.test(relativePath)) kind = 'scan';
  else if (/\.scenario\.xml$/i.test(relativePath)) kind = 'xml';

  return {
    filePath,
    relativePath,
    size,
    ext,
    kind,
    protectedByIndex,
    orphan: !protectedByIndex && kind !== 'index',
  };
}

function addSize(bucket, key, bytes) {
  bucket[key] = bucket[key] || { files: 0, bytes: 0 };
  bucket[key].files += 1;
  bucket[key].bytes += bytes;
}

function formatBytes(bytes) {
  return {
    bytes,
    mb: Number((bytes / 1024 / 1024).toFixed(1)),
    gb: Number((bytes / 1024 / 1024 / 1024).toFixed(3)),
  };
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const root = path.resolve(options.root);
  const indexPath = path.resolve(options.index || getSidecarIndexPath(root));

  if (!isSafeRoot(root)) {
    throw new Error(`Refusing to inspect outside project-owned sidecar roots: ${root}`);
  }

  if (!isSameOrInside(indexPath, root)) {
    throw new Error(`Refusing to use an index outside the sidecar root: ${indexPath}`);
  }

  const rootStat = await statSafe(root);
  if (!rootStat?.isDirectory()) {
    throw new Error(`Sidecar root not found: ${root}`);
  }

  const indexData = await readJsonSafe(indexPath);
  if (!indexData) {
    throw new Error(`Could not read sidecar index: ${indexPath}`);
  }

  const protectedPaths = collectProtectedPaths(root, indexPath, indexData);
  const files = await listFiles(root);
  const items = [];

  for (const filePath of files) {
    const stat = await statSafe(filePath);
    if (!stat?.isFile()) continue;
    items.push(classifyFile(root, protectedPaths, filePath, stat.size));
  }

  const byKind = {};
  const byExt = {};
  let totalBytes = 0;
  let protectedBytes = 0;
  let orphanBytes = 0;
  const orphans = [];

  for (const item of items) {
    totalBytes += item.size;
    addSize(byKind, item.kind, item.size);
    addSize(byExt, item.ext, item.size);

    if (item.protectedByIndex) protectedBytes += item.size;
    if (item.orphan) {
      orphanBytes += item.size;
      orphans.push(item);
    }
  }

  orphans.sort((a, b) => b.size - a.size);
  const topOrphans = orphans.slice(0, options.top).map((item) => ({
    file: item.relativePath,
    kind: item.kind,
    ...formatBytes(item.size),
  }));

  const summary = {
    root,
    index: indexPath,
    mode: options.pruneOrphans && options.yes ? 'delete-orphans' : 'dry-run',
    scenariosInIndex: Array.isArray(indexData?.scenarios) ? indexData.scenarios.length : 0,
    files: items.length,
    total: formatBytes(totalBytes),
    protectedByIndex: {
      files: items.filter((item) => item.protectedByIndex).length,
      ...formatBytes(protectedBytes),
    },
    orphans: {
      files: orphans.length,
      ...formatBytes(orphanBytes),
      top: topOrphans,
    },
    byKind,
    byExt,
    note: 'Only orphan files not referenced by scenario-openability-index.json are eligible for deletion.',
  };

  console.log(JSON.stringify(summary, null, 2));

  if (!options.pruneOrphans) {
    console.log('\nAudit only. Re-run with --prune-orphans to mark orphan sidecars as delete candidates.');
    return;
  }

  if (!options.yes) {
    console.log('\nDry-run only. Re-run with --prune-orphans --yes to delete orphan sidecars.');
    return;
  }

  for (const item of orphans) {
    await fs.rm(item.filePath, { force: true });
  }

  console.log(`\nDeleted ${orphans.length} orphan sidecars. Reclaimed about ${summary.orphans.gb} GB.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
