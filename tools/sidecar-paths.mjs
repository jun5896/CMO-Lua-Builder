import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const PROJECT_ROOT = path.resolve(__dirname, '..');
export const SIDECAR_URL_PREFIX = 'scenario-sidecars';
export const LEGACY_PUBLIC_SIDECAR_URL_PREFIX = 'scenario-scan-samples';
export const LEGACY_INTERNAL_SIDECAR_ROOT = path.join(PROJECT_ROOT, SIDECAR_URL_PREFIX);
export const LEGACY_PUBLIC_SIDECAR_ROOT = path.join(PROJECT_ROOT, 'public', LEGACY_PUBLIC_SIDECAR_URL_PREFIX);
export const DEFAULT_EXTERNAL_SIDECAR_ROOT = path.join(path.dirname(PROJECT_ROOT), 'cmo-scenario-sidecars');
export const USER_CODEX_SIDECAR_ROOT = path.join(process.env.USERPROFILE || 'C:\\Users\\dlwls', '.codex', 'cmo-scenario-sidecars');

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

function unique(values) {
  const seen = new Set();
  const result = [];

  for (const value of values) {
    const resolved = path.resolve(value);
    const key = resolved.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    result.push(resolved);
  }

  return result;
}

export function getConfiguredSidecarRoot() {
  const envRoot = normalizeEnvPath(process.env.CMO_SCENARIO_SIDECAR_ROOT);
  return envRoot ? path.resolve(envRoot) : '';
}

export function getPreferredSidecarRoot() {
  const configuredRoot = getConfiguredSidecarRoot();
  if (configuredRoot) return configuredRoot;

  const externalIndex = path.join(DEFAULT_EXTERNAL_SIDECAR_ROOT, 'scenario-openability-index.json');
  if (exists(externalIndex)) return DEFAULT_EXTERNAL_SIDECAR_ROOT;

  return LEGACY_INTERNAL_SIDECAR_ROOT;
}

export function getSidecarReadRoots() {
  return unique([
    getPreferredSidecarRoot(),
    DEFAULT_EXTERNAL_SIDECAR_ROOT,
    LEGACY_INTERNAL_SIDECAR_ROOT,
    LEGACY_PUBLIC_SIDECAR_ROOT,
  ]);
}

export function getSidecarIndexPath(root = getPreferredSidecarRoot()) {
  return path.join(root, 'scenario-openability-index.json');
}

export function formatSidecarRootHelp() {
  return [
    '',
    'Set CMO_SCENARIO_SIDECAR_ROOT to your external sidecar cache, for example:',
    `  PowerShell: $env:CMO_SCENARIO_SIDECAR_ROOT="${USER_CODEX_SIDECAR_ROOT}"`,
    `Auto-detected external root for this clone: ${DEFAULT_EXTERNAL_SIDECAR_ROOT}`,
    `Project-local fallback: ${LEGACY_INTERNAL_SIDECAR_ROOT}`,
  ].join('\n');
}

export function isSameOrInside(target, root) {
  const resolvedTarget = path.resolve(target);
  const resolvedRoot = path.resolve(root);
  const relative = path.relative(resolvedRoot, resolvedTarget);
  return !relative || (!relative.startsWith('..') && !path.isAbsolute(relative));
}

export function getSidecarWriteRoots() {
  const configuredRoot = getConfiguredSidecarRoot();
  return unique([
    configuredRoot || DEFAULT_EXTERNAL_SIDECAR_ROOT,
    getPreferredSidecarRoot(),
    LEGACY_INTERNAL_SIDECAR_ROOT,
    LEGACY_PUBLIC_SIDECAR_ROOT,
  ]);
}

export function isSafeSidecarRoot(root) {
  const resolvedRoot = path.resolve(root);
  return getSidecarWriteRoots().some((safeRoot) => isSameOrInside(resolvedRoot, safeRoot));
}

export function normalizeSidecarReference(value = '') {
  const normalized = String(value || '').replace(/\\/g, '/').replace(/^\/+/, '');
  if (normalized.startsWith(`${SIDECAR_URL_PREFIX}/`)) {
    return normalized.slice(SIDECAR_URL_PREFIX.length + 1);
  }
  if (normalized.startsWith(`${LEGACY_PUBLIC_SIDECAR_URL_PREFIX}/`)) {
    return normalized.slice(LEGACY_PUBLIC_SIDECAR_URL_PREFIX.length + 1);
  }
  return normalized;
}

export function toSidecarReference(filePath, root = getPreferredSidecarRoot()) {
  const relative = path.relative(root, filePath);
  return `${SIDECAR_URL_PREFIX}/${relative.replace(/\\/g, '/')}`;
}

export function resolveSidecarReference(reference, roots = getSidecarReadRoots()) {
  const relative = normalizeSidecarReference(reference);
  if (!relative) return '';

  for (const root of roots) {
    const target = path.resolve(root, relative);
    const back = path.relative(root, target);
    if (back.startsWith('..') || path.isAbsolute(back)) continue;
    if (exists(target)) return target;
  }

  return path.resolve(roots[0] || getPreferredSidecarRoot(), relative);
}
