#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import {
  getPreferredSidecarRoot,
  isSafeSidecarRoot,
} from './sidecar-paths.mjs';

const DEFAULT_ROOT = getPreferredSidecarRoot();

function usage() {
  return [
    'Usage:',
    '  node tools/prune-cmo-scenario-xml-sidecars.mjs [--root <dir>] [--yes] [--allow-stale-summary]',
    '',
    'Default mode is dry-run. The tool deletes only *.scenario.xml files that have a sibling',
    '*.summary.json, because summary JSON is the UI primary sidecar and XML can be regenerated.',
  ].join('\n');
}

function parseArgs(argv) {
  const options = {
    root: DEFAULT_ROOT,
    yes: false,
    allowStaleSummary: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--root') {
      options.root = argv[index + 1] || DEFAULT_ROOT;
      index += 1;
    } else if (value === '--yes') {
      options.yes = true;
    } else if (value === '--allow-stale-summary') {
      options.allowStaleSummary = true;
    } else if (value === '--help' || value === '-h') {
      console.log(usage());
      process.exit(0);
    }
  }

  return options;
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

function summaryPathForXml(xmlPath) {
  return xmlPath.replace(/\.scenario\.xml$/i, '.summary.json');
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const root = path.resolve(options.root);

  if (!isSafeRoot(root)) {
    throw new Error(`Refusing to prune outside project-owned sidecar roots: ${root}`);
  }

  const rootStat = await statSafe(root);
  if (!rootStat?.isDirectory()) {
    throw new Error(`Sidecar root not found: ${root}`);
  }

  const files = await listFiles(root);
  const xmlFiles = files.filter((filePath) => /\.scenario\.xml$/i.test(filePath));
  const prunable = [];
  const skipped = {
    missingSummary: 0,
    staleSummary: 0,
  };

  for (const xmlPath of xmlFiles) {
    const xmlStat = await statSafe(xmlPath);
    const summaryPath = summaryPathForXml(xmlPath);
    const summaryStat = await statSafe(summaryPath);

    if (!summaryStat?.isFile()) {
      skipped.missingSummary += 1;
      continue;
    }

    if (!options.allowStaleSummary && summaryStat.mtimeMs + 2000 < xmlStat.mtimeMs) {
      skipped.staleSummary += 1;
      continue;
    }

    prunable.push({ xmlPath, size: xmlStat.size });
  }

  const bytes = prunable.reduce((sum, item) => sum + item.size, 0);
  const summary = {
    root,
    mode: options.yes ? 'delete' : 'dry-run',
    xmlFiles: xmlFiles.length,
    prunable: prunable.length,
    skipped,
    reclaimBytes: bytes,
    reclaimMB: Number((bytes / 1024 / 1024).toFixed(1)),
    reclaimGB: Number((bytes / 1024 / 1024 / 1024).toFixed(3)),
  };

  console.log(JSON.stringify(summary, null, 2));

  if (!options.yes) {
    console.log('\nDry-run only. Re-run with --yes to delete prunable XML sidecars.');
    return;
  }

  for (const item of prunable) {
    await fs.unlink(item.xmlPath);
  }

  console.log(`\nDeleted ${prunable.length} XML sidecars. Reclaimed about ${summary.reclaimGB} GB.`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
