#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import {
  formatSidecarRootHelp,
  getSidecarIndexPath,
  LEGACY_PUBLIC_SIDECAR_ROOT,
  PROJECT_ROOT,
  resolveSidecarReference,
} from './sidecar-paths.mjs';

const DEFAULT_INDEX = getSidecarIndexPath();
const LEGACY_INDEX = path.join(LEGACY_PUBLIC_SIDECAR_ROOT, 'scenario-openability-index.json');
const VALID_STATUSES = new Set([
  'readyWithInternalSidecar',
  'metadataOnlyNeedsDecoder',
  'decoderFailed',
  'plainXmlReadable',
  'readError',
]);

function parseArgs(argv) {
  const options = { index: DEFAULT_INDEX, json: false };
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--index') {
      options.index = argv[index + 1] || DEFAULT_INDEX;
      index += 1;
    } else if (value === '--json') {
      options.json = true;
    }
  }
  return options;
}

function slug(value = '') {
  return String(value || 'scenario')
    .replace(/\.[^.]+$/, '')
    .normalize('NFKD')
    .replace(/[^A-Za-z0-9_. -]+/g, '')
    .trim()
    .replace(/[\s_]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase()
    || 'scenario';
}

async function readJson(filePath) {
  try {
    return JSON.parse(await fs.readFile(filePath, 'utf8'));
  } catch (error) {
    if (error?.code === 'ENOENT') {
      throw new Error(`Could not read sidecar index: ${filePath}${formatSidecarRootHelp()}`);
    }
    throw error;
  }
}

async function resolveDefaultIndex(indexPath) {
  if (indexPath !== DEFAULT_INDEX) return indexPath;

  try {
    await fs.access(DEFAULT_INDEX);
    return DEFAULT_INDEX;
  } catch {
    try {
      await fs.access(LEGACY_INDEX);
      return LEGACY_INDEX;
    } catch {
      throw new Error(`Could not find scenario sidecar index at ${DEFAULT_INDEX} or ${LEGACY_INDEX}${formatSidecarRootHelp()}`);
    }
  }
}

async function fileExists(relativePath) {
  const fullPath = resolveSidecarReference(relativePath);
  try {
    const stat = await fs.stat(fullPath);
    return stat.isFile() ? stat.size : 0;
  } catch {
    return 0;
  }
}

function sidecarBasename(sidecar = {}) {
  return path.basename(String(sidecar.file || '')).replace(/\.(summary\.json|scenario\.xml|json)$/i, '');
}

function commandLooksSafe(command = '') {
  const text = String(command || '');
  return text.startsWith('npm run prepare:scenario -- "')
    && !text.includes('C:\\Users\\dlwls\\.codex\\cmo-lua-ui\\public\\scenario-scan-samples');
}

async function verifyReadyScenario(scenario, issues) {
  const fileSlug = slug(scenario.fileName);
  const expectedSlug = scenario.slug ? String(scenario.slug) : fileSlug;
  const sidecars = Array.isArray(scenario.sidecars) ? scenario.sidecars : [];
  const hasInternalSidecar = sidecars.some((sidecar) => sidecar.kind === 'summary' || sidecar.kind === 'xml');

  if (!hasInternalSidecar) {
    issues.push({ level: 'error', fileName: scenario.fileName, message: 'readyWithInternalSidecar has no summary/xml sidecar' });
  }

  for (const sidecar of sidecars) {
    const size = await fileExists(sidecar.file);
    if (!size) {
      issues.push({ level: 'error', fileName: scenario.fileName, message: `missing sidecar file: ${sidecar.file}` });
      continue;
    }

    const base = sidecarBasename(sidecar);
    if (base && base !== expectedSlug && base.toLowerCase() !== expectedSlug.toLowerCase()) {
      // Old exact XML names can differ only in case/punctuation; title-based collisions should not be attached.
      const normalizedBase = slug(base);
      if (normalizedBase !== fileSlug && normalizedBase !== expectedSlug) {
        issues.push({
          level: 'warning',
          fileName: scenario.fileName,
          message: `sidecar basename differs from file slug: ${sidecar.file}`,
        });
      }
    }
  }
}

async function verifyDecoderFailedScenario(scenario, issues) {
  const attempt = scenario.lastAttempt || {};
  if (!attempt.code || !attempt.diagnosticFile) {
    issues.push({ level: 'error', fileName: scenario.fileName, message: 'decoderFailed is missing lastAttempt code or diagnosticFile' });
    return;
  }

  const size = await fileExists(attempt.diagnosticFile);
  if (!size) {
    issues.push({ level: 'error', fileName: scenario.fileName, message: `missing decoder diagnostic file: ${attempt.diagnosticFile}` });
  }
}

async function verifyIndex(indexPath) {
  indexPath = await resolveDefaultIndex(indexPath);
  const index = await readJson(indexPath);
  const scenarios = Array.isArray(index.scenarios) ? index.scenarios : [];
  const issues = [];
  const counts = scenarios.reduce((acc, scenario) => {
    acc[scenario.status] = (acc[scenario.status] || 0) + 1;
    return acc;
  }, {});

  if (index.totalScenarios !== scenarios.length) {
    issues.push({
      level: 'error',
      message: `totalScenarios mismatch: index=${index.totalScenarios}, actual=${scenarios.length}`,
    });
  }

  for (const scenario of scenarios) {
    if (!VALID_STATUSES.has(scenario.status)) {
      issues.push({ level: 'error', fileName: scenario.fileName, message: `unknown status: ${scenario.status}` });
    }

    if (!scenario.fileName || !scenario.scenarioPath) {
      issues.push({ level: 'error', fileName: scenario.fileName, message: 'missing fileName or scenarioPath' });
    }

    if (!commandLooksSafe(scenario.commands?.prepare)) {
      issues.push({ level: 'error', fileName: scenario.fileName, message: 'missing or unsafe prepare command' });
    }

    if (scenario.status === 'readyWithInternalSidecar') {
      await verifyReadyScenario(scenario, issues);
    }

    if (scenario.status === 'decoderFailed') {
      await verifyDecoderFailedScenario(scenario, issues);
    }
  }

  const readErrors = scenarios.filter((scenario) => scenario.status === 'readError');
  const ready = scenarios.filter((scenario) => scenario.status === 'readyWithInternalSidecar');
  const metadataOnly = scenarios.filter((scenario) => scenario.status === 'metadataOnlyNeedsDecoder');
  const decoderFailed = scenarios.filter((scenario) => scenario.status === 'decoderFailed');

  return {
    ok: !issues.some((issue) => issue.level === 'error'),
    generatedAt: index.generatedAt,
    totalScenarios: scenarios.length,
    counts,
    readyCount: ready.length,
    metadataOnlyCount: metadataOnly.length,
    decoderFailedCount: decoderFailed.length,
    readErrorCount: readErrors.length,
    webOpenabilityVerdict: readErrors.length
      ? 'Some scenario wrappers could not be read.'
      : 'All scenario wrappers are classifiable by the web loader. Internal compressed data opens after prepare:scenario sidecar generation.',
    issues,
    readySamples: ready.slice(0, 20).map((scenario) => ({
      title: scenario.title,
      fileName: scenario.fileName,
      sidecars: scenario.sidecars?.map((sidecar) => sidecar.file) || [],
    })),
  };
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const result = await verifyIndex(path.resolve(options.index));

  if (options.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log('Scenario loader verification');
    console.log(`GeneratedAt : ${result.generatedAt}`);
    console.log(`Total       : ${result.totalScenarios}`);
    console.log(`Counts      : ${JSON.stringify(result.counts)}`);
    console.log(`Verdict     : ${result.webOpenabilityVerdict}`);
    console.log(`Issues      : ${result.issues.length}`);
    for (const issue of result.issues.slice(0, 50)) {
      console.log(`- [${issue.level}] ${issue.fileName || '(index)'}: ${issue.message}`);
    }
  }

  if (!result.ok) process.exitCode = 1;
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
