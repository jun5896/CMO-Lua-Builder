#!/usr/bin/env node
import fs from 'node:fs/promises';
import { constants as fsConstants } from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { isSameOrInside } from './sidecar-paths.mjs';
import { findCmoRoot } from './cmo-install-locator.mjs';

const DEFAULT_CMO_ROOT = findCmoRoot();
const EXCEPTION_LOG_PATTERN = /^ExceptionLog_.*\.txt$/i;
const LUA_HISTORY_PATTERN = /^LuaHistory_.*\.txt$/i;

function cleanPath(value = '') {
  return String(value || '').trim().replace(/^"|"$/g, '');
}

function resolvePath(value) {
  return path.resolve(cleanPath(value));
}

function usage() {
  return [
    'Usage:',
    '  node tools/probe-cmo-integration.mjs [--cmo-root <path>] [--scenarios-root <path>] [--logs-root <path>] [--scenario-folder <path>] [--json] [--strict]',
    '',
    'Environment fallbacks:',
    '  CMO_ROOT',
    '  CMO_SCENARIOS_ROOT',
    '  CMO_LOGS_ROOT',
    '',
    'This probe is dry-run only. It does not write files or mutate CMO state.',
  ].join('\n');
}

export function parseProbeArgs(argv = [], env = process.env) {
  const options = {
    cmoRoot: cleanPath(env.CMO_ROOT) || DEFAULT_CMO_ROOT,
    scenariosRoot: cleanPath(env.CMO_SCENARIOS_ROOT),
    logsRoot: cleanPath(env.CMO_LOGS_ROOT),
    scenarioFolder: '',
    json: false,
    strict: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--help' || value === '-h') {
      options.help = true;
    } else if (value === '--json') {
      options.json = true;
    } else if (value === '--strict') {
      options.strict = true;
    } else if (value === '--cmo-root') {
      options.cmoRoot = argv[index + 1] || '';
      index += 1;
    } else if (value === '--scenarios-root') {
      options.scenariosRoot = argv[index + 1] || '';
      index += 1;
    } else if (value === '--logs-root') {
      options.logsRoot = argv[index + 1] || '';
      index += 1;
    } else if (value === '--scenario-folder') {
      options.scenarioFolder = argv[index + 1] || '';
      index += 1;
    } else {
      throw new Error(`Unknown argument: ${value}\n\n${usage()}`);
    }
  }

  const cmoRoot = resolvePath(options.cmoRoot || DEFAULT_CMO_ROOT);
  return {
    ...options,
    cmoRoot,
    scenariosRoot: resolvePath(options.scenariosRoot || path.join(cmoRoot, 'Scenarios')),
    logsRoot: resolvePath(options.logsRoot || path.join(cmoRoot, 'Logs')),
    scenarioFolder: options.scenarioFolder ? resolvePath(options.scenarioFolder) : '',
  };
}

async function statPath(target) {
  try {
    return await fs.stat(target);
  } catch {
    return null;
  }
}

async function canAccess(target, mode) {
  try {
    await fs.access(target, mode);
    return true;
  } catch {
    return false;
  }
}

async function findFiles(root, pattern) {
  const stat = await statPath(root);
  if (!stat?.isDirectory()) return [];

  const entries = await fs.readdir(root, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    if (!entry.isFile() || !pattern.test(entry.name)) continue;
    const filePath = path.join(root, entry.name);
    const fileStat = await statPath(filePath);
    files.push({
      name: entry.name,
      path: filePath,
      sizeBytes: fileStat?.size || 0,
      lastWriteTime: fileStat?.mtime?.toISOString?.() || '',
    });
  }

  return files.sort((a, b) => b.lastWriteTime.localeCompare(a.lastWriteTime) || a.name.localeCompare(b.name));
}

function capability(status, title, detail, extra = {}) {
  return { status, title, detail, ...extra };
}

function summarizeCapabilities(capabilities) {
  const values = Object.values(capabilities);
  return {
    total: values.length,
    passed: values.filter((item) => item.status === 'pass').length,
    warned: values.filter((item) => item.status === 'warn').length,
    failed: values.filter((item) => item.status === 'fail').length,
    manual: values.filter((item) => item.status === 'manual').length,
    unknown: values.filter((item) => item.status === 'unknown').length,
  };
}

function uniquePaths(paths) {
  const seen = new Set();
  const result = [];
  for (const value of paths.filter(Boolean).map(resolvePath)) {
    const key = value.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    result.push(value);
  }
  return result;
}

function pathPrefixStatus(cmoRoot, scenariosRoot, logsRoot) {
  const scenarioInside = isSameOrInside(scenariosRoot, cmoRoot);
  const logsInside = isSameOrInside(logsRoot, cmoRoot);
  if (scenarioInside && logsInside) {
    return capability(
      'pass',
      'Future adapter path prefixes',
      'Scenario and log roots are inside the configured CMO root.',
    );
  }

  return capability(
    'warn',
    'Future adapter path prefixes',
    'One or more configured roots are outside the CMO root. Future endpoints must whitelist each prefix explicitly.',
  );
}

export async function runCmoIntegrationProbe(inputOptions = {}) {
  const options = parseProbeArgs([], {
    CMO_ROOT: inputOptions.cmoRoot || process.env.CMO_ROOT || DEFAULT_CMO_ROOT,
    CMO_SCENARIOS_ROOT: inputOptions.scenariosRoot || process.env.CMO_SCENARIOS_ROOT || '',
    CMO_LOGS_ROOT: inputOptions.logsRoot || process.env.CMO_LOGS_ROOT || '',
  });
  const scenarioFolder = inputOptions.scenarioFolder ? resolvePath(inputOptions.scenarioFolder) : options.scenarioFolder;

  const cmoRootStat = await statPath(options.cmoRoot);
  const scenariosRootStat = await statPath(options.scenariosRoot);
  const logsRootStat = await statPath(options.logsRoot);
  const scenarioFolderStat = scenarioFolder ? await statPath(scenarioFolder) : null;
  const exceptionLogs = await findFiles(options.logsRoot, EXCEPTION_LOG_PATTERN);
  const luaHistoryLogs = await findFiles(options.logsRoot, LUA_HISTORY_PATTERN);

  const capabilities = {
    cmoRoot: cmoRootStat?.isDirectory()
      ? capability('pass', 'CMO root', `Found CMO root: ${options.cmoRoot}`)
      : capability('fail', 'CMO root', `CMO root not found: ${options.cmoRoot}`),
    scenariosRoot: scenariosRootStat?.isDirectory()
      ? capability('pass', 'Scenarios root', `Found scenarios root: ${options.scenariosRoot}`)
      : capability('fail', 'Scenarios root', `Scenarios root not found: ${options.scenariosRoot}`),
    logsRoot: logsRootStat?.isDirectory()
      ? capability('pass', 'Logs root', `Found logs root: ${options.logsRoot}`)
      : capability('fail', 'Logs root', `Logs root not found: ${options.logsRoot}`),
    scenarioWriteAccess: scenariosRootStat?.isDirectory()
      ? (await canAccess(options.scenariosRoot, fsConstants.W_OK)
        ? capability('pass', 'Scenario folder write access', 'Write permission is available by access check only; no file was written.')
        : capability('warn', 'Scenario folder write access', 'Write permission was not available. Track B2 must use a manual or relocated workflow.'))
      : capability('unknown', 'Scenario folder write access', 'Scenarios root is missing, so write permission was not checked.'),
    exceptionLogPattern: logsRootStat?.isDirectory()
      ? (exceptionLogs.length > 0
        ? capability('pass', 'ExceptionLog_*.txt', `Found ${exceptionLogs.length} ExceptionLog_*.txt file(s).`, { count: exceptionLogs.length, files: exceptionLogs.slice(0, 5) })
        : capability('warn', 'ExceptionLog_*.txt', 'No ExceptionLog_*.txt files found yet. This can be normal before CMO logs an exception.', { count: 0, files: [] }))
      : capability('unknown', 'ExceptionLog_*.txt', 'Logs root is missing, so ExceptionLog files were not checked.', { count: 0, files: [] }),
    luaHistoryPattern: logsRootStat?.isDirectory()
      ? (luaHistoryLogs.length > 0
        ? capability('pass', 'LuaHistory_*.txt', `Found ${luaHistoryLogs.length} LuaHistory_*.txt file(s).`, { count: luaHistoryLogs.length, files: luaHistoryLogs.slice(0, 5) })
        : capability('warn', 'LuaHistory_*.txt', 'No LuaHistory_*.txt files found yet. This can be normal before Lua runs in CMO.', { count: 0, files: [] }))
      : capability('unknown', 'LuaHistory_*.txt', 'Logs root is missing, so LuaHistory files were not checked.', { count: 0, files: [] }),
    luaAutoLoad: capability(
      'manual',
      'Scenario .lua auto-load',
      scenarioFolderStat?.isDirectory()
        ? `Manual check required for scenario folder: ${scenarioFolder}`
        : 'Manual check required. Provide --scenario-folder with a disposable scenario folder for a more specific next step.',
      {
        scenarioFolder,
        recommendation: 'Do not assume automatic loading. Build Track B2 around explicit ScenEdit_RunScript(...) from the CMO Lua root; Build 1868 reports dofile(...) as nil in the console sandbox.',
      },
    ),
    safePathPrefixes: pathPrefixStatus(options.cmoRoot, options.scenariosRoot, options.logsRoot),
  };

  const safePathPrefixes = uniquePaths([options.cmoRoot, options.scenariosRoot, options.logsRoot]);

  return {
    generatedAt: new Date().toISOString(),
    dryRunOnly: true,
    roots: {
      cmoRoot: options.cmoRoot,
      scenariosRoot: options.scenariosRoot,
      logsRoot: options.logsRoot,
      scenarioFolder,
    },
    safePathPrefixes,
    capabilities,
    summary: summarizeCapabilities(capabilities),
    nextStep: 'Track B2 should use explicit ScenEdit_RunScript(...) from the CMO Lua root unless a separate auto-load behavior is later proven.',
  };
}

function statusLabel(status) {
  return String(status || 'unknown').toUpperCase().padEnd(7, ' ');
}

export function formatProbeReport(result) {
  const rows = Object.entries(result.capabilities).map(([, item]) => (
    `- ${statusLabel(item.status)} ${item.title}: ${item.detail}`
  ));

  return [
    'Track B0 CMO Integration Probe',
    '',
    `Generated: ${result.generatedAt}`,
    'Safety: dry-run only; this probe does not write files, delete files, tail logs, add endpoints, or mutate CMO state.',
    '',
    'Roots:',
    `- CMO root: ${result.roots.cmoRoot}`,
    `- Scenarios root: ${result.roots.scenariosRoot}`,
    `- Logs root: ${result.roots.logsRoot}`,
    `- Scenario folder: ${result.roots.scenarioFolder || '(not provided)'}`,
    '',
    'Capabilities:',
    ...rows,
    '',
    'Safe path prefixes for future adapter work:',
    ...result.safePathPrefixes.map((prefix) => `- ${prefix}`),
    '',
    'Manual check required:',
    '- Scenario-folder .lua auto-load remains unproven.',
    '- Build 1868 reports dofile(...) as nil in the CMO console sandbox.',
    '- Use explicit ScenEdit_RunScript(...) from the CMO Lua root as the safe Track B2 loader model.',
    '',
    `Summary: ${result.summary.passed} pass / ${result.summary.warned} warn / ${result.summary.failed} fail / ${result.summary.manual} manual / ${result.summary.unknown} unknown`,
  ].join('\n');
}

async function main() {
  const options = parseProbeArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    return;
  }

  const result = await runCmoIntegrationProbe(options);
  if (options.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(formatProbeReport(result));
  }

  if (options.strict && result.summary.failed > 0) {
    process.exitCode = 1;
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
}
