import fs from 'node:fs';
import path from 'node:path';

const CMO_DIR_NAME = 'Command - Modern Operations';
const CMO_STEAM_APP_ID = '1076160';

// Last-resort fallback when no live install is found. Kept as the historical
// default so path shapes in reports stay recognizable.
export const LEGACY_DEFAULT_CMO_ROOT = path.join(
  'C:\\Program Files (x86)\\Steam\\steamapps\\common',
  CMO_DIR_NAME,
);

function normalizeEnvPath(value = '') {
  return String(value || '').trim().replace(/^"|"$/g, '');
}

function exists(target) {
  try {
    return fs.existsSync(target);
  } catch {
    return false;
  }
}

function steamBaseCandidates() {
  const bases = [];
  const pf86 = process.env['ProgramFiles(x86)'] || 'C:\\Program Files (x86)';
  const pf = process.env.ProgramFiles || 'C:\\Program Files';
  bases.push(path.join(pf86, 'Steam'));
  bases.push(path.join(pf, 'Steam'));
  return bases.filter(exists);
}

function libraryRootsFromVdf(steamBase) {
  const vdfPath = path.join(steamBase, 'steamapps', 'libraryfolders.vdf');
  if (!exists(vdfPath)) return [];

  try {
    const text = fs.readFileSync(vdfPath, 'utf8');
    const roots = [];
    const pattern = /"path"\s+"([^"]+)"/g;
    let match;
    while ((match = pattern.exec(text))) {
      roots.push(match[1].replace(/\\\\/g, '\\'));
    }
    return roots;
  } catch {
    return [];
  }
}

function driveRootCandidates() {
  const candidates = [];
  for (const drive of ['C', 'D', 'E', 'F']) {
    candidates.push(`${drive}:\\SteamLibrary`);
  }
  return candidates;
}

function steamLibraryRoots() {
  const roots = [];
  for (const steamBase of steamBaseCandidates()) {
    roots.push(steamBase);
    roots.push(...libraryRootsFromVdf(steamBase));
  }
  roots.push(...driveRootCandidates());

  const seen = new Set();
  return roots.filter((root) => {
    const key = path.resolve(root).toLowerCase();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

let cachedCmoRoot = null;

export function findCmoRoot() {
  const envRoot = normalizeEnvPath(process.env.CMO_ROOT);
  if (envRoot) return path.resolve(envRoot);

  if (cachedCmoRoot) return cachedCmoRoot;

  for (const libraryRoot of steamLibraryRoots()) {
    const candidate = path.join(libraryRoot, 'steamapps', 'common', CMO_DIR_NAME);
    if (exists(path.join(candidate, 'Command.exe'))) {
      cachedCmoRoot = path.resolve(candidate);
      return cachedCmoRoot;
    }
  }

  cachedCmoRoot = LEGACY_DEFAULT_CMO_ROOT;
  return cachedCmoRoot;
}

export function findCmoLuaRoot() {
  const envRoot = normalizeEnvPath(process.env.CMO_LUA_ROOT);
  if (envRoot) return path.resolve(envRoot);
  return path.join(findCmoRoot(), 'Lua');
}

export function findCmoLogsRoot() {
  const envRoot = normalizeEnvPath(process.env.CMO_LOGS_ROOT);
  if (envRoot) return path.resolve(envRoot);
  return path.join(findCmoRoot(), 'Logs');
}

export function findCmoScenariosRoot() {
  const envRoot = normalizeEnvPath(process.env.CMO_SCENARIOS_ROOT);
  if (envRoot) return path.resolve(envRoot);
  return path.join(findCmoRoot(), 'Scenarios');
}

export function findCmoImportExportRoot() {
  const envRoot = normalizeEnvPath(process.env.CMO_IMPORTEXPORT_ROOT);
  if (envRoot) return path.resolve(envRoot);
  return path.join(findCmoRoot(), 'ImportExport');
}

export function findCmoWorkshopRoots() {
  const roots = [];
  for (const libraryRoot of steamLibraryRoots()) {
    const candidate = path.join(libraryRoot, 'steamapps', 'workshop', 'content', CMO_STEAM_APP_ID);
    if (exists(candidate)) roots.push(path.resolve(candidate));
  }
  return roots;
}

export function describeCmoInstall() {
  const cmoRoot = findCmoRoot();
  return {
    cmoRoot,
    cmoRootExists: exists(path.join(cmoRoot, 'Command.exe')),
    luaRoot: findCmoLuaRoot(),
    logsRoot: findCmoLogsRoot(),
    scenariosRoot: findCmoScenariosRoot(),
    workshopRoots: findCmoWorkshopRoots(),
    envOverrides: {
      CMO_ROOT: normalizeEnvPath(process.env.CMO_ROOT) || '',
      CMO_LUA_ROOT: normalizeEnvPath(process.env.CMO_LUA_ROOT) || '',
      CMO_LOGS_ROOT: normalizeEnvPath(process.env.CMO_LOGS_ROOT) || '',
      CMO_SCENARIOS_ROOT: normalizeEnvPath(process.env.CMO_SCENARIOS_ROOT) || '',
    },
  };
}
