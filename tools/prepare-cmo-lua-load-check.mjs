#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const DEFAULT_FILE_NAME = 'AiAssist_B0LoadCheck.lua';
const DEFAULT_MARKER_PREFIX = 'AiAssist_B0LoadCheck';
const DEFAULT_SCRIPT_FOLDER = 'AiAssist_B0';
const SAFE_FILE_NAME_PATTERN = /^AiAssist_B0[A-Za-z0-9_-]*\.lua$/;
const SAFE_SCRIPT_FOLDER_PATTERN = /^AiAssist_B0[A-Za-z0-9_-]*$/;

function cleanValue(value = '') {
  return String(value || '').trim().replace(/^"|"$/g, '');
}

function usage() {
  return [
    'Usage:',
    '  node tools/prepare-cmo-lua-load-check.mjs [--cmo-lua-root <path>] [--script-folder <name>] [--file-name <name>] [--marker <text>] [--write] [--yes] [--overwrite] [--json]',
    '',
    'Default mode is dry-run. The tool writes only when --cmo-lua-root, --write, and --yes are all provided.',
    'The generated loader snippet uses CMO ScenEdit_RunScript(...), not dofile(...).',
    '',
    'Example dry-run:',
    '  npm run probe:cmo-lua-load-check -- --cmo-lua-root "C:\\...\\Command - Modern Operations\\Lua"',
    '',
    'Example explicit write:',
    '  npm run probe:cmo-lua-load-check -- --cmo-lua-root "C:\\...\\Command - Modern Operations\\Lua" --write --yes',
  ].join('\n');
}

export function parseLoadCheckArgs(argv = []) {
  const options = {
    cmoLuaRoot: '',
    scriptFolder: DEFAULT_SCRIPT_FOLDER,
    fileName: DEFAULT_FILE_NAME,
    marker: '',
    write: false,
    yes: false,
    overwrite: false,
    json: false,
    help: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--help' || value === '-h') {
      options.help = true;
    } else if (value === '--cmo-lua-root') {
      options.cmoLuaRoot = argv[index + 1] || '';
      index += 1;
    } else if (value === '--scenario-folder') {
      throw new Error('--scenario-folder is no longer supported for B0.1 writes. Use --cmo-lua-root and ScenEdit_RunScript instead.');
    } else if (value === '--script-folder') {
      options.scriptFolder = argv[index + 1] || '';
      index += 1;
    } else if (value === '--file-name') {
      options.fileName = argv[index + 1] || '';
      index += 1;
    } else if (value === '--marker') {
      options.marker = argv[index + 1] || '';
      index += 1;
    } else if (value === '--write') {
      options.write = true;
    } else if (value === '--yes') {
      options.yes = true;
    } else if (value === '--overwrite') {
      options.overwrite = true;
    } else if (value === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown argument: ${value}\n\n${usage()}`);
    }
  }

  return {
    ...options,
    cmoLuaRoot: options.cmoLuaRoot ? path.resolve(cleanValue(options.cmoLuaRoot)) : '',
    scriptFolder: cleanValue(options.scriptFolder || DEFAULT_SCRIPT_FOLDER),
    fileName: cleanValue(options.fileName || DEFAULT_FILE_NAME),
    marker: cleanValue(options.marker),
  };
}

function makeMarker(value = '') {
  const cleaned = cleanValue(value);
  if (cleaned) return cleaned;

  const stamp = new Date().toISOString().replace(/[-:.TZ]/g, '').slice(0, 14);
  return `${DEFAULT_MARKER_PREFIX}_${stamp}`;
}

function escapeLuaSingleQuoted(value = '') {
  return String(value)
    .replace(/\\/g, '\\\\')
    .replace(/'/g, "\\'")
    .replace(/\r?\n/g, ' ');
}

function assertSafeFileName(fileName) {
  if (!SAFE_FILE_NAME_PATTERN.test(fileName)) {
    throw new Error(`Unsafe load-check file name: ${fileName}. Use AiAssist_B0*.lua.`);
  }
}

function assertSafeScriptFolder(scriptFolder) {
  if (!SAFE_SCRIPT_FOLDER_PATTERN.test(scriptFolder)) {
    throw new Error(`Unsafe load-check script folder: ${scriptFolder}. Use AiAssist_B0*.`);
  }
}

function targetPathFor(cmoLuaRoot, scriptFolder, fileName) {
  if (!cmoLuaRoot) return path.join('<cmo-lua-root>', scriptFolder, fileName);
  return path.join(path.resolve(cmoLuaRoot), scriptFolder, fileName);
}

function runScriptPathFor(scriptFolder, fileName) {
  return `/${scriptFolder}/${fileName}`.replace(/\\/g, '/');
}

function buildLua(marker) {
  return [
    '-- AiAssist B0.1 disposable Lua load check.',
    '-- Harmless by design: prints a marker only; no scenario state is modified.',
    `local marker = '${escapeLuaSingleQuoted(marker)}'`,
    'print(marker)',
    '',
  ].join('\n');
}

function buildManualSteps(targetFile, marker, loaderSnippet) {
  return [
    'Use a disposable/test scenario only.',
    'Place the generated Lua file under the CMO Lua root, not the scenario folder.',
    'Open the CMO Lua Console or internal Lua editor.',
    `Run this CMO loader snippet: ${loaderSnippet}`,
    `Look for this marker in the Lua console or LuaHistory logs: ${marker}`,
    'Do not use dofile(...); CMO Build 1868 reports dofile as nil in the console sandbox.',
    'Do not treat scenario-folder auto-load as proven; this check only proves explicit ScenEdit_RunScript loading.',
    `Target file: ${targetFile}`,
  ];
}

export function buildLuaLoadCheck(options = {}) {
  const fileName = cleanValue(options.fileName || DEFAULT_FILE_NAME);
  const scriptFolder = cleanValue(options.scriptFolder || DEFAULT_SCRIPT_FOLDER);
  assertSafeFileName(fileName);
  assertSafeScriptFolder(scriptFolder);

  const cmoLuaRoot = options.cmoLuaRoot ? path.resolve(cleanValue(options.cmoLuaRoot)) : '';
  const marker = makeMarker(options.marker);
  const targetFile = targetPathFor(cmoLuaRoot, scriptFolder, fileName);
  const runScriptPath = runScriptPathFor(scriptFolder, fileName);
  const loaderSnippet = `ScenEdit_RunScript('${runScriptPath}')`;
  const lua = buildLua(marker);

  return {
    fileName,
    cmoLuaRoot,
    scriptFolder,
    targetFile,
    runScriptPath,
    marker,
    lua,
    loaderSnippet,
    manualSteps: buildManualSteps(targetFile, marker, loaderSnippet),
  };
}

async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

async function writeLoadCheckFile(targetFile, lua, overwrite = false) {
  const flag = overwrite ? 'w' : 'wx';
  let handle;
  try {
    handle = await fs.open(targetFile, flag);
    await handle.write(lua);
  } catch (error) {
    if (error?.code === 'EEXIST') {
      throw new Error(`Load-check file already exists: ${targetFile}. Re-run with --overwrite only for a disposable scenario.`);
    }
    throw error;
  } finally {
    await handle?.close();
  }
}

export async function runLuaLoadCheck(options = {}) {
  const parsed = {
    cmoLuaRoot: options.cmoLuaRoot || '',
    scriptFolder: options.scriptFolder || DEFAULT_SCRIPT_FOLDER,
    fileName: options.fileName || DEFAULT_FILE_NAME,
    marker: options.marker || '',
    write: Boolean(options.write),
    yes: Boolean(options.yes),
    overwrite: Boolean(options.overwrite),
  };
  const built = buildLuaLoadCheck(parsed);

  let mode = 'dry-run';
  let wroteFile = false;
  let writeBlockedReason = '';

  if (parsed.write && parsed.yes) {
    if (!built.cmoLuaRoot) {
      throw new Error('Writing requires --cmo-lua-root.');
    }

    const stat = await fs.stat(built.cmoLuaRoot).catch(() => null);
    if (!stat?.isDirectory()) {
      throw new Error(`CMO Lua root not found: ${built.cmoLuaRoot}`);
    }

    await fs.mkdir(path.dirname(built.targetFile), { recursive: true });
    await writeLoadCheckFile(built.targetFile, built.lua, parsed.overwrite);
    mode = 'write';
    wroteFile = true;
  } else if (parsed.write || parsed.yes) {
    writeBlockedReason = 'Writing requires --write and --yes.';
  }

  return {
    ...built,
    mode,
    wroteFile,
    writeBlockedReason,
    targetExists: built.cmoLuaRoot ? await fileExists(built.targetFile) : false,
    safety: {
      dryRunDefault: true,
      requiresWriteAndYes: true,
      fixedNamespace: 'AiAssist_B0*.lua',
      mutatesScenarioState: false,
      luaAutoLoadProven: false,
      usesScenEditRunScript: true,
      usesDofile: false,
    },
  };
}

export function formatLoadCheckReport(result) {
  return [
    'Track B0.1 CMO Lua Load Check',
    '',
    `Mode: ${result.mode}`,
    `Target file: ${result.targetFile}`,
    `Marker: ${result.marker}`,
    `Wrote file: ${result.wroteFile ? 'yes' : 'no'}`,
    result.writeBlockedReason ? `Write blocked: ${result.writeBlockedReason}` : '',
    '',
    'Lua preview:',
    '```lua',
    result.lua.trimEnd(),
    '```',
    '',
    'Manual steps:',
    ...result.manualSteps.map((step) => `- ${step}`),
    '',
    'Important: scenario-folder .lua auto-load is not proven until the marker appears without running the loader snippet.',
  ].filter((line) => line !== '').join('\n');
}

async function main() {
  const options = parseLoadCheckArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    return;
  }

  const result = await runLuaLoadCheck(options);
  if (options.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(formatLoadCheckReport(result));
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
}
