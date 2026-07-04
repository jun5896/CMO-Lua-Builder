#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import fs from 'node:fs/promises';
import path from 'node:path';
import {
  getPreferredSidecarRoot,
  getSidecarIndexPath,
  LEGACY_PUBLIC_SIDECAR_ROOT,
  PROJECT_ROOT,
} from './sidecar-paths.mjs';
import { findCmoRoot } from './cmo-install-locator.mjs';

const DEFAULT_OUT_ROOT = getPreferredSidecarRoot();
const DEFAULT_INDEX = getSidecarIndexPath(DEFAULT_OUT_ROOT);
const LEGACY_INDEX = path.join(LEGACY_PUBLIC_SIDECAR_ROOT, 'scenario-openability-index.json');
const DEFAULT_CMO_ROOT = findCmoRoot();

function usage() {
  return [
    'Usage:',
    '  node tools/prepare-cmo-scenario-sidecar.mjs <scenario.scen|scenario-folder> [--slug <slug>] [--out-root <dir>] [--keep-xml] [--no-audit]',
    '',
    'Example:',
    '  npm run prepare:scenario -- "C:\\...\\Operation Epic Fury - The First 24 Hours.scen"',
  ].join('\n');
}

function parseArgs(argv) {
  const options = {
    input: '',
    slug: '',
    outRoot: DEFAULT_OUT_ROOT,
    cmoRoot: process.env.CMO_ROOT || DEFAULT_CMO_ROOT,
    audit: true,
    keepXml: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--slug') {
      options.slug = argv[index + 1] || '';
      index += 1;
    } else if (value === '--out-root') {
      options.outRoot = argv[index + 1] || DEFAULT_OUT_ROOT;
      index += 1;
    } else if (value === '--cmo-root') {
      options.cmoRoot = argv[index + 1] || options.cmoRoot;
      index += 1;
    } else if (value === '--no-audit') {
      options.audit = false;
    } else if (value === '--keep-xml') {
      options.keepXml = true;
    } else if (!options.input) {
      options.input = value;
    }
  }

  if (!options.input) {
    throw new Error(usage());
  }

  return options;
}

async function statSafe(target) {
  try {
    return await fs.stat(target);
  } catch {
    return null;
  }
}

async function resolveScenarioInput(input) {
  const inputPath = path.resolve(input);
  const stat = await statSafe(inputPath);
  if (!stat) throw new Error(`Scenario input not found: ${inputPath}`);

  if (stat.isFile()) {
    if (path.extname(inputPath).toLowerCase() !== '.scen') {
      throw new Error(`Expected a .scen file: ${inputPath}`);
    }
    return inputPath;
  }

  if (!stat.isDirectory()) throw new Error(`Input is neither file nor directory: ${inputPath}`);

  const entries = await fs.readdir(inputPath);
  const scenFiles = entries
    .filter((entry) => path.extname(entry).toLowerCase() === '.scen')
    .sort((a, b) => a.localeCompare(b));

  if (!scenFiles.length) throw new Error(`No .scen file found in folder: ${inputPath}`);
  return path.join(inputPath, scenFiles[0]);
}

function slug(value = '', options = {}) {
  const stripExtension = options.stripExtension !== false;
  const rawValue = stripExtension
    ? String(value || 'scenario').replace(/\.[^.]+$/, '')
    : String(value || 'scenario');
  return rawValue
    .normalize('NFKD')
    .replace(/[^A-Za-z0-9_. -]+/g, '')
    .trim()
    .replace(/[\s_]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase()
    || 'scenario';
}

async function deriveSlug(scenarioPath, explicitSlug) {
  if (explicitSlug) return slug(explicitSlug, { stripExtension: false });
  for (const indexPath of [DEFAULT_INDEX, LEGACY_INDEX]) {
    try {
      const index = JSON.parse(await fs.readFile(indexPath, 'utf8'));
      const matched = Array.isArray(index.scenarios)
        ? index.scenarios.find((scenario) => path.normalize(scenario.scenarioPath || '').toLowerCase() === path.normalize(scenarioPath).toLowerCase())
        : null;
      if (matched?.slug) {
        return slug(matched.slug, { stripExtension: false });
      }
    } catch {
      // The index may not exist on first run. Try the next index, then fall back to the file name.
    }
  }
  // Use the file name by default. Titles can collide across v1/v1.3/workshop
  // copies, but the file name usually carries the disambiguating suffix.
  return slug(path.basename(scenarioPath));
}

function run(command, args, options = {}) {
  console.log(`\n> ${command} ${args.map((arg) => (/\s/.test(arg) ? `"${arg}"` : arg)).join(' ')}`);
  const result = spawnSync(command, args, {
    cwd: PROJECT_ROOT,
    stdio: 'inherit',
    shell: false,
    ...options,
  });

  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(`Command failed with exit code ${result.status}: ${command}`);
  }
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const scenarioPath = await resolveScenarioInput(options.input);
  const outRoot = path.resolve(options.outRoot);
  const outputSlug = await deriveSlug(scenarioPath, options.slug);
  const scanOut = path.join(outRoot, `${outputSlug}.json`);
  const xmlOut = path.join(outRoot, `${outputSlug}.scenario.xml`);
  const summaryOut = path.join(outRoot, `${outputSlug}.summary.json`);

  await fs.mkdir(outRoot, { recursive: true });

  run(process.execPath, [
    path.join('tools', 'scan-cmo-scenario-folder.mjs'),
    scenarioPath,
    '--out',
    scanOut,
  ]);

  run('powershell', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    path.join('tools', 'extract-cmo-scenario-xml.ps1'),
    scenarioPath,
    '--OutXml',
    xmlOut,
    '-CmoRoot',
    options.cmoRoot,
  ]);

  run(process.execPath, [
    path.join('tools', 'summarize-cmo-scenario-xml.mjs'),
    xmlOut,
    '--out',
    summaryOut,
  ]);

  if (!options.keepXml) {
    await fs.rm(xmlOut, { force: true });
  }

  if (options.audit) {
    run(process.execPath, [path.join('tools', 'audit-cmo-scenario-openability.mjs')]);
  }

  console.log('\nScenario sidecar preparation complete.');
  console.log(`Scenario: ${scenarioPath}`);
  console.log(`Slug    : ${outputSlug}`);
  console.log(`Scan    : ${path.relative(PROJECT_ROOT, scanOut)}`);
  console.log(`XML     : ${options.keepXml ? path.relative(PROJECT_ROOT, xmlOut) : 'pruned after summary generation (--keep-xml to retain)'}`);
  console.log(`Summary : ${path.relative(PROJECT_ROOT, summaryOut)}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
