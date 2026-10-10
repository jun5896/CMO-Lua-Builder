import { mkdir, open } from 'node:fs/promises';
import path from 'node:path';
import { findCmoLuaRoot } from '../tools/cmo-install-locator.mjs';
import { inspectLuaSafety, LUA_SAFETY_POLICY_VERSION } from '../src/lib/luaSafety.js';

export const DEFAULT_CMO_LUA_ROOT = findCmoLuaRoot();
export const DEFAULT_SCRIPT_FOLDER = 'AiAssist';

const FILE_NAME_RE = /^AiAssist_[A-Za-z0-9_-]{1,96}\.lua$/;

function timestampForFile(date = new Date()) {
  const pad = (value) => String(value).padStart(2, '0');
  return [
    date.getFullYear(),
    pad(date.getMonth() + 1),
    pad(date.getDate()),
    '_',
    pad(date.getHours()),
    pad(date.getMinutes()),
    pad(date.getSeconds()),
  ].join('');
}

function slugify(value) {
  const slug = String(value || 'draft')
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 48);
  return slug || 'draft';
}

export function sanitizeLuaSidecarFileName({ fileName = '', slug = '', now = new Date() } = {}) {
  const candidate = fileName || `AiAssist_${timestampForFile(now)}_${slugify(slug)}.lua`;
  if (!FILE_NAME_RE.test(candidate) || candidate.includes('..') || candidate.includes('/') || candidate.includes('\\')) {
    throw new Error('Invalid AiAssist Lua filename');
  }
  return candidate;
}

export function validateLuaSidecarContent(content) {
  const result = inspectLuaSafety(content);
  if (!result.ok) {
    const error = new Error(result.issues.map((issue) => issue.message).join('; '));
    error.code = 'LUA_POLICY_REJECTED';
    error.issues = result.issues;
    throw error;
  }
  return result.normalizedLua;
}

function resolveTarget({ cmoLuaRoot, fileName }) {
  const root = path.resolve(cmoLuaRoot || process.env.CMO_LUA_ROOT || DEFAULT_CMO_LUA_ROOT);
  const folder = path.resolve(root, DEFAULT_SCRIPT_FOLDER);
  const targetFile = path.resolve(folder, fileName);
  const relative = path.relative(folder, targetFile);

  if (relative.startsWith('..') || path.isAbsolute(relative)) {
    throw new Error('Resolved target escaped AiAssist folder');
  }

  return { root, folder, targetFile };
}

function buildLuaSidecarPayload(options = {}) {
  if (options.isPasteReady !== true) {
    throw new Error('isPasteReady must be true before saving a CMO Lua sidecar');
  }

  const fileName = sanitizeLuaSidecarFileName(options);
  const lua = validateLuaSidecarContent(options.content);
  const { root, folder, targetFile } = resolveTarget({ cmoLuaRoot: options.cmoLuaRoot, fileName });
  const runScriptPath = `/${DEFAULT_SCRIPT_FOLDER}/${fileName}`;

  return {
    lua,
    report: {
      ok: true,
      luaSafetyPolicyVersion: LUA_SAFETY_POLICY_VERSION,
      mode: options.dryRun === false ? 'write' : 'dry-run',
      wroteFile: false,
      confirmedDryRun: options.dryRun !== false,
      confirmedWrite: options.confirmWrite === true,
      cmoLuaRoot: root,
      scriptFolder: DEFAULT_SCRIPT_FOLDER,
      folder,
      fileName,
      targetFile,
      runScriptPath,
      loaderSnippet: `ScenEdit_RunScript('${runScriptPath}')`,
      manualSteps: [
        'Open CMO Lua Console or the internal Lua editor.',
        'Run the loader snippet manually.',
        'Check CMO output and LuaHistory for errors.',
      ],
    },
  };
}

export function buildLuaSidecarReport(options = {}) {
  return buildLuaSidecarPayload(options).report;
}

export async function createLuaSidecar(options = {}) {
  const { lua, report } = buildLuaSidecarPayload(options);
  if (report.mode === 'dry-run') return report;

  if (options.confirmWrite !== true) {
    throw new Error('confirmWrite must be true for an actual CMO Lua sidecar write');
  }

  await mkdir(report.folder, { recursive: true });
  let handle;
  try {
    handle = await open(report.targetFile, 'wx');
    await handle.writeFile(lua, 'utf8');
  } catch (error) {
    if (error?.code === 'EEXIST') {
      throw new Error(`CMO Lua sidecar already exists: ${report.targetFile}. Prepare again with a fresh timestamp file name.`);
    }
    throw error;
  } finally {
    await handle?.close();
  }

  return { ...report, wroteFile: true };
}
