#!/usr/bin/env node
import { spawn } from 'node:child_process';
import fs from 'node:fs/promises';
import path from 'node:path';
import {
  getSidecarIndexPath,
  LEGACY_PUBLIC_SIDECAR_ROOT,
  PROJECT_ROOT,
} from './sidecar-paths.mjs';

const DEFAULT_INDEX = getSidecarIndexPath();
const LEGACY_INDEX = path.join(LEGACY_PUBLIC_SIDECAR_ROOT, 'scenario-openability-index.json');

function usage() {
  return [
    'Usage:',
    '  node tools/prepare-cmo-scenario-batch.mjs --match <text> [--limit <n>] [--concurrency <n>] [--dry-run]',
    '  node tools/prepare-cmo-scenario-batch.mjs --all --limit <n> [--concurrency <n>] [--dry-run]',
    '',
    'Safety:',
    '  A selector is required. Use --match, --path-contains, --limit, or explicit --all.',
    '  Default status is metadataOnlyNeedsDecoder, so ready sidecars are not rebuilt unless --status all is used.',
    '  decoderFailed entries are skipped unless --retry-failed is provided.',
    '',
    'Examples:',
    '  npm run prepare:scenario-batch -- --match "Trident Boreal" --concurrency 2',
    '  npm run prepare:scenario-batch -- --all --limit 10 --concurrency 2 --dry-run',
  ].join('\n');
}

function parseArgs(argv) {
  const options = {
    index: DEFAULT_INDEX,
    match: '',
    pathContains: '',
    status: 'metadataOnlyNeedsDecoder',
    limit: 0,
    concurrency: 2,
    dryRun: false,
    all: false,
    finalAudit: true,
    retryFailed: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--index') {
      options.index = argv[index + 1] || DEFAULT_INDEX;
      index += 1;
    } else if (value === '--match') {
      options.match = argv[index + 1] || '';
      index += 1;
    } else if (value === '--path-contains') {
      options.pathContains = argv[index + 1] || '';
      index += 1;
    } else if (value === '--status') {
      options.status = argv[index + 1] || options.status;
      index += 1;
    } else if (value === '--limit') {
      options.limit = Number(argv[index + 1] || 0);
      index += 1;
    } else if (value === '--concurrency') {
      options.concurrency = Number(argv[index + 1] || 2);
      index += 1;
    } else if (value === '--dry-run') {
      options.dryRun = true;
    } else if (value === '--all') {
      options.all = true;
    } else if (value === '--retry-failed') {
      options.retryFailed = true;
    } else if (value === '--no-final-audit') {
      options.finalAudit = false;
    } else if (value === '--help' || value === '-h') {
      options.help = true;
    }
  }

  options.concurrency = Math.min(4, Math.max(1, Math.floor(options.concurrency || 2)));
  options.limit = Math.max(0, Math.floor(options.limit || 0));
  return options;
}

async function readJson(filePath) {
  return JSON.parse(await fs.readFile(filePath, 'utf8'));
}

async function resolveDefaultIndex(indexPath) {
  if (indexPath !== DEFAULT_INDEX) return indexPath;

  try {
    await fs.access(DEFAULT_INDEX);
    return DEFAULT_INDEX;
  } catch {
    return LEGACY_INDEX;
  }
}

function includesIgnoreCase(value, needle) {
  return String(value || '').toLowerCase().includes(String(needle || '').toLowerCase());
}

function selectScenarios(index, options) {
  let scenarios = Array.isArray(index.scenarios) ? index.scenarios : [];

  if (options.status !== 'all') {
    scenarios = scenarios.filter((scenario) => scenario.status === options.status);
  }

  if (!options.retryFailed) {
    scenarios = scenarios.filter((scenario) => scenario.status !== 'decoderFailed');
  }

  if (options.match) {
    scenarios = scenarios.filter((scenario) => [
      scenario.title,
      scenario.fileName,
      scenario.scenarioPath,
      scenario.slug,
    ].some((value) => includesIgnoreCase(value, options.match)));
  }

  if (options.pathContains) {
    scenarios = scenarios.filter((scenario) => includesIgnoreCase(scenario.scenarioPath, options.pathContains));
  }

  scenarios = scenarios.filter((scenario) => scenario.scenarioPath);
  scenarios.sort((a, b) => String(a.scenarioPath).localeCompare(String(b.scenarioPath)));

  if (options.limit > 0) {
    scenarios = scenarios.slice(0, options.limit);
  }

  return scenarios;
}

function selectorProvided(options) {
  return Boolean(options.all || options.match || options.pathContains || options.limit > 0);
}

function runPrepare(scenarioPath, index, total, outputSlug = '') {
  return new Promise((resolve) => {
    const label = `[${index + 1}/${total}]`;
    console.log(`${label} preparing ${scenarioPath}`);
    const args = [
      path.join('tools', 'prepare-cmo-scenario-sidecar.mjs'),
      scenarioPath,
      '--no-audit',
    ];
    if (outputSlug) {
      args.push('--slug', outputSlug);
    }
    const child = spawn(process.execPath, args, {
      cwd: PROJECT_ROOT,
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: false,
    });

    child.stdout.on('data', (chunk) => process.stdout.write(`${label} ${chunk}`));
    child.stderr.on('data', (chunk) => process.stderr.write(`${label} ${chunk}`));
    child.on('error', (error) => resolve({ scenarioPath, ok: false, error: error.message }));
    child.on('close', (code) => resolve({ scenarioPath, ok: code === 0, code }));
  });
}

async function runQueue(scenarios, concurrency) {
  const results = [];
  let cursor = 0;

  async function worker() {
    while (cursor < scenarios.length) {
      const index = cursor;
      cursor += 1;
      results[index] = await runPrepare(scenarios[index].scenarioPath, index, scenarios.length, scenarios[index].slug);
    }
  }

  await Promise.all(Array.from({ length: Math.min(concurrency, scenarios.length) }, () => worker()));
  return results;
}

function runNodeScript(scriptPath) {
  return new Promise((resolve) => {
    const child = spawn(process.execPath, [scriptPath], {
      cwd: PROJECT_ROOT,
      stdio: 'inherit',
      shell: false,
    });
    child.on('error', (error) => resolve({ ok: false, error: error.message }));
    child.on('close', (code) => resolve({ ok: code === 0, code }));
  });
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    return;
  }

  if (!selectorProvided(options)) {
    throw new Error(usage());
  }

  options.index = await resolveDefaultIndex(options.index);
  const index = await readJson(path.resolve(options.index));
  const scenarios = selectScenarios(index, options);

  console.log(`Scenario batch prepare`);
  console.log(`Index       : ${path.resolve(options.index)}`);
  console.log(`Selected    : ${scenarios.length}`);
  console.log(`Status      : ${options.status}`);
  console.log(`Concurrency : ${options.concurrency}`);
  console.log(`Dry run     : ${options.dryRun ? 'yes' : 'no'}`);
  console.log(`Retry failed: ${options.retryFailed ? 'yes' : 'no'}`);

  for (const scenario of scenarios.slice(0, 50)) {
    console.log(`- ${scenario.title || scenario.fileName} :: ${scenario.scenarioPath}`);
  }
  if (scenarios.length > 50) console.log(`... ${scenarios.length - 50} more`);

  if (!scenarios.length || options.dryRun) return;

  const results = await runQueue(scenarios, options.concurrency);
  const failed = results.filter((result) => !result.ok);

  if (options.finalAudit) {
    console.log('\nRunning final openability audit...');
    const audit = await runNodeScript(path.join('tools', 'audit-cmo-scenario-openability.mjs'));
    if (!audit.ok) {
      failed.push({ scenarioPath: 'final audit', ok: false, code: audit.code, error: audit.error });
    }
  }

  console.log('\nBatch complete.');
  console.log(`Succeeded: ${results.length - failed.length}/${results.length}`);
  if (failed.length) {
    console.log('Failed scenarios:');
    for (const failure of failed) {
      console.log(`- ${failure.scenarioPath} (${failure.error || `exit ${failure.code}`})`);
    }
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
