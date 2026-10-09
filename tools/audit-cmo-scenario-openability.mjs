#!/usr/bin/env node
import { buildScenarioCommands } from '../src/lib/scenarioCommands.js';
import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';
import {
  getPreferredSidecarRoot,
  getSidecarIndexPath,
  getSidecarReadRoots,
  PROJECT_ROOT,
  resolveSidecarReference,
  toSidecarReference,
} from './sidecar-paths.mjs';
import { findCmoScenariosRoot, findCmoWorkshopRoots } from './cmo-install-locator.mjs';

const SIDECAR_ROOT = getPreferredSidecarRoot();
const SIDECAR_ROOTS = getSidecarReadRoots();
const DEFAULT_OUT = getSidecarIndexPath(SIDECAR_ROOT);
const CMO_SCENARIOS_ROOT = findCmoScenariosRoot();
const DEFAULT_ROOTS = [
  CMO_SCENARIOS_ROOT,
  ...findCmoWorkshopRoots(),
];
// User workspace folders kept out of the default audit set (personal drafts).
const USER_WORKSPACE_FOLDER_NAMES = ['새 폴더', '새 폴더 1', '새 폴더 2', '새 폴더 backup', '시뮬레이션'];
const DEFAULT_EXCLUDED_ROOTS = USER_WORKSPACE_FOLDER_NAMES.map((name) => path.join(CMO_SCENARIOS_ROOT, name));
function parseArgs(argv) {
  const options = { roots: [], out: DEFAULT_OUT, limit: 0, excludeRoots: [], includeUserWorkspaces: false };
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--root' || value === '--roots') {
      options.roots.push(argv[index + 1]);
      index += 1;
    } else if (value === '--exclude-root') {
      options.excludeRoots.push(argv[index + 1]);
      index += 1;
    } else if (value === '--include-user-workspaces') {
      options.includeUserWorkspaces = true;
    } else if (value === '--out') {
      options.out = argv[index + 1] || DEFAULT_OUT;
      index += 1;
    } else if (value === '--limit') {
      options.limit = Number(argv[index + 1] || 0);
      index += 1;
    }
  }
  if (!options.roots.length) options.roots = DEFAULT_ROOTS;
  if (!options.includeUserWorkspaces) {
    options.excludeRoots.push(...DEFAULT_EXCLUDED_ROOTS);
  }
  return options;
}

function decodeXml(value = '') {
  return value
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&amp;/g, '&')
    .replace(/&#(\d+);/g, (_, code) => String.fromCodePoint(Number(code)))
    .replace(/&#x([0-9a-f]+);/gi, (_, code) => String.fromCodePoint(Number.parseInt(code, 16)));
}

function getTag(xml, tagName) {
  const match = new RegExp(`<${tagName}(?:\\s[^>]*)?>([\\s\\S]*?)<\\/${tagName}>`, 'i').exec(xml);
  return match ? decodeXml(match[1].trim()) : '';
}

function getRawTag(xml, tagName) {
  const match = new RegExp(`<${tagName}(?:\\s[^>]*)?>([\\s\\S]*?)<\\/${tagName}>`, 'i').exec(xml);
  return match ? match[1].trim() : '';
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

function stablePathHash(value = '') {
  return createHash('sha1')
    .update(path.normalize(String(value || '')).toLowerCase())
    .digest('hex')
    .slice(0, 8);
}

function outputSlugForScenario(scenarioPath, fileName, baseSlugCounts) {
  const baseSlug = slug(fileName);
  if ((baseSlugCounts.get(baseSlug) || 0) <= 1) {
    return baseSlug;
  }
  return `${baseSlug}-${stablePathHash(scenarioPath)}`;
}

function xmlNameFromFileName(fileName) {
  return `${String(fileName || 'scenario.scen')
    .replace(/\.[^.]+$/, '')
    .replace(/[^A-Za-z0-9_.-]+/g, '-')
    .replace(/^-+|-+$/g, '')
    || 'scenario'}.scenario.xml`;
}

function legacyXmlCandidate(fileName, allowedSlugs) {
  const legacyName = xmlNameFromFileName(fileName);
  const legacyBase = legacyName.replace(/\.scenario\.xml$/i, '');
  return allowedSlugs.has(slug(legacyBase))
    ? { kind: 'xml', fileName: legacyName }
    : null;
}

async function exists(filePath) {
  try {
    const stat = await fs.stat(filePath);
    return stat.isFile() ? stat.size : 0;
  } catch {
    return 0;
  }
}

async function statFileIfExists(filePath) {
  try {
    const stat = await fs.stat(filePath);
    return stat.isFile() ? stat : null;
  } catch {
    return null;
  }
}

async function readJsonIfExists(filePath) {
  try {
    return JSON.parse((await fs.readFile(filePath, 'utf8')).replace(/^\uFEFF/, ''));
  } catch {
    return null;
  }
}

function scenarioKey(item) {
  return path.normalize(item?.scenarioPath || `${item?.root || ''}\\${item?.relativePath || item?.fileName || ''}`).toLowerCase();
}

function sidecarSignature(item) {
  return (item?.sidecars || [])
    .map((sidecar) => `${sidecar.kind}:${sidecar.file}:${sidecar.sizeBytes}`)
    .sort()
    .join('|');
}

function scenarioComparable(item) {
  return [
    item?.status || '',
    item?.fileName || '',
    item?.title || '',
    item?.dbVersion || '',
    item?.buildNumber || '',
    item?.sizeBytes || 0,
    item?.compressed?.base64Chars || 0,
    sidecarSignature(item),
  ].join('||');
}

function normalizePathKey(value = '') {
  return path.resolve(String(value || '')).toLowerCase();
}

function isSameOrDescendant(target, root) {
  const targetKey = normalizePathKey(target);
  const rootKey = normalizePathKey(root);
  return targetKey === rootKey || targetKey.startsWith(`${rootKey}${path.sep}`);
}

function isExcludedPath(target, excludeRoots) {
  return excludeRoots.some((root) => isSameOrDescendant(target, root));
}

function summarizeDelta(previousIndex, nextScenarios) {
  const previousScenarios = Array.isArray(previousIndex?.scenarios) ? previousIndex.scenarios : [];
  const previousMap = new Map(previousScenarios.map((item) => [scenarioKey(item), item]));
  const nextMap = new Map(nextScenarios.map((item) => [scenarioKey(item), item]));

  const added = [];
  const removed = [];
  const changed = [];

  for (const [key, nextItem] of nextMap) {
    const previousItem = previousMap.get(key);
    if (!previousItem) {
      added.push(nextItem);
    } else if (scenarioComparable(previousItem) !== scenarioComparable(nextItem)) {
      changed.push({
        before: {
          status: previousItem.status,
          title: previousItem.title,
          dbVersion: previousItem.dbVersion,
          buildNumber: previousItem.buildNumber,
          sizeBytes: previousItem.sizeBytes,
          sidecars: previousItem.sidecars,
        },
        after: {
          status: nextItem.status,
          title: nextItem.title,
          dbVersion: nextItem.dbVersion,
          buildNumber: nextItem.buildNumber,
          sizeBytes: nextItem.sizeBytes,
          sidecars: nextItem.sidecars,
        },
        scenarioPath: nextItem.scenarioPath,
      });
    }
  }

  for (const [key, previousItem] of previousMap) {
    if (!nextMap.has(key)) {
      removed.push(previousItem);
    }
  }

  return {
    previousGeneratedAt: previousIndex?.generatedAt || '',
    addedCount: added.length,
    removedCount: removed.length,
    changedCount: changed.length,
    added: added.slice(0, 50),
    removed: removed.slice(0, 50),
    changed: changed.slice(0, 50),
  };
}

async function walkScenarios(root, excludeRoots) {
  const result = [];
  async function visit(directory) {
    if (isExcludedPath(directory, excludeRoots)) {
      return;
    }
    let entries = [];
    try {
      entries = await fs.readdir(directory, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      const fullPath = path.join(directory, entry.name);
      if (entry.isDirectory()) {
        await visit(fullPath);
      } else if (entry.isFile() && path.extname(entry.name).toLowerCase() === '.scen') {
        result.push(fullPath);
      }
    }
  }
  await visit(root);
  return result;
}

// Shared with the UI: imported filenames stay literal PowerShell arguments.
const buildCommands = buildScenarioCommands;

async function sidecarStatus(fileName, title, outputSlug, strictOutputSlug = false) {
  const fileSlug = slug(fileName);
  const titleSlug = slug(title);
  const lowerFileBase = String(fileName || '').replace(/\.[^.]+$/, '').toLowerCase();
  const allowedLegacySlugs = new Set([outputSlug, fileSlug, titleSlug].filter(Boolean));
  const slugs = [...new Set([
    outputSlug,
    fileSlug,
    lowerFileBase,
    titleSlug === fileSlug ? titleSlug : '',
  ].filter(Boolean))];
  const candidates = strictOutputSlug
    ? [
      { kind: 'summary', fileName: `${outputSlug}.summary.json` },
      { kind: 'xml', fileName: `${outputSlug}.scenario.xml` },
      { kind: 'error', fileName: `${outputSlug}.scenario.xml.error.json` },
      { kind: 'scan', fileName: `${outputSlug}.json` },
    ]
    : [
      ...slugs.flatMap((item) => [
        { kind: 'summary', fileName: `${item}.summary.json` },
        { kind: 'xml', fileName: `${item}.scenario.xml` },
        { kind: 'error', fileName: `${item}.scenario.xml.error.json` },
        { kind: 'scan', fileName: `${item}.json` },
      ]),
      legacyXmlCandidate(fileName, allowedLegacySlugs),
    ].filter(Boolean);

  const present = [];
  for (const candidate of candidates) {
    for (const root of SIDECAR_ROOTS) {
      const candidatePath = path.join(root, candidate.fileName);
      const stat = await statFileIfExists(candidatePath);
      if (stat) {
        present.push({
          kind: candidate.kind,
          file: toSidecarReference(candidatePath, root),
          sizeBytes: stat.size,
          mtimeMs: stat.mtimeMs,
        });
        break;
      }
    }
  }
  return present;
}

async function freshDecoderError(sidecars, scenarioStat) {
  const errors = sidecars.filter((sidecar) => sidecar.kind === 'error');
  for (const sidecar of errors) {
    if ((sidecar.mtimeMs || 0) + 1000 < scenarioStat.mtimeMs) {
      continue;
    }
    const fullPath = resolveSidecarReference(sidecar.file);
    const payload = await readJsonIfExists(fullPath);
    if (payload?.code) {
      return { sidecar, payload };
    }
  }
  return null;
}

async function auditScenario(scenarioPath, root, outputSlug, strictOutputSlug = false) {
  const stat = await fs.stat(scenarioPath);
  const fileName = path.basename(scenarioPath);
  try {
    const text = await fs.readFile(scenarioPath, 'utf8');
    const title = getTag(text, 'ScenTitle') || getTag(text, 'Title') || path.basename(fileName, '.scen');
    const dbVersion = getTag(text, 'DBVersion');
    const buildNumber = getTag(text, 'BuildNumber') || getTag(text, 'Version');
    const compressed = getRawTag(text, 'Scenario_Compressed').replace(/\s+/g, '');
    const sidecars = await sidecarStatus(fileName, title, outputSlug, strictOutputSlug);
    const decoderError = await freshDecoderError(sidecars, stat);
    const effectiveSidecars = sidecars.filter((item) => item.kind !== 'error' || item === decoderError?.sidecar);
    const hasInternalSidecar = effectiveSidecars.some((item) => item.kind === 'summary' || item.kind === 'xml');
    const status = hasInternalSidecar
      ? 'readyWithInternalSidecar'
      : decoderError
        ? 'decoderFailed'
        : compressed
          ? 'metadataOnlyNeedsDecoder'
          : 'plainXmlReadable';

    return {
      status,
      fileName,
      title,
      dbVersion,
      buildNumber,
      scenarioPath,
      root,
      relativePath: path.relative(root, scenarioPath),
      sizeBytes: stat.size,
      compressed: {
        present: Boolean(compressed),
        base64Chars: compressed.length,
        estimatedBytes: compressed ? Math.max(0, Math.floor((compressed.length * 3) / 4) - (compressed.endsWith('==') ? 2 : compressed.endsWith('=') ? 1 : 0)) : 0,
      },
      slug: outputSlug,
      sidecars: effectiveSidecars,
      lastAttempt: decoderError ? {
        timestamp: decoderError.payload.timestamp || '',
        code: decoderError.payload.code || 'decoderFailed',
        stage: 'extractXml',
        message: decoderError.payload.message || '',
        diagnosticFile: decoderError.sidecar.file,
        actionable: decoderError.payload.detail?.actionable !== false,
      } : undefined,
      commands: buildCommands(scenarioPath, outputSlug),
    };
  } catch (error) {
    return {
      status: 'readError',
      fileName,
      title: path.basename(fileName, '.scen'),
      scenarioPath,
      root,
      relativePath: path.relative(root, scenarioPath),
      sizeBytes: stat.size,
      error: error instanceof Error ? error.message : String(error),
    };
  }
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const roots = options.roots.map((item) => path.resolve(item));
  const excludeRoots = options.excludeRoots.map((item) => path.resolve(item));
  const allScenarios = [];
  for (const root of roots) {
    const found = await walkScenarios(root, excludeRoots);
    allScenarios.push(...found.map((scenarioPath) => ({ scenarioPath, root })));
  }

  const selected = options.limit > 0 ? allScenarios.slice(0, options.limit) : allScenarios;
  const baseSlugCounts = new Map();
  for (const item of selected) {
    const baseSlug = slug(path.basename(item.scenarioPath));
    baseSlugCounts.set(baseSlug, (baseSlugCounts.get(baseSlug) || 0) + 1);
  }

  const scenarios = [];
  for (let index = 0; index < selected.length; index += 1) {
    const item = selected[index];
    const fileName = path.basename(item.scenarioPath);
    const outputSlug = outputSlugForScenario(item.scenarioPath, fileName, baseSlugCounts);
    const strictOutputSlug = (baseSlugCounts.get(slug(fileName)) || 0) > 1;
    scenarios.push(await auditScenario(item.scenarioPath, item.root, outputSlug, strictOutputSlug));
    if ((index + 1) % 100 === 0) {
      console.error(`[audit] ${index + 1}/${selected.length}`);
    }
  }

  const counts = scenarios.reduce((acc, item) => {
    acc[item.status] = (acc[item.status] || 0) + 1;
    return acc;
  }, {});

  const output = {
    generatedAt: new Date().toISOString(),
    roots,
    excludedRoots: excludeRoots,
    totalScenarios: scenarios.length,
    counts,
    note: 'readyWithInternalSidecar means the browser UI can auto-link internal XML/summary. metadataOnlyNeedsDecoder means the .scen wrapper opens but internal Event/Lua/Side data needs prepare:scenario, which runs scan + extract:scenario-xml + summarize:scenario + audit. decoderFailed means a decoder attempt already produced a diagnostic .error.json sidecar and should not be retried automatically.',
    scenarios,
  };

  const outPath = path.resolve(options.out);
  const previousIndex = await readJsonIfExists(outPath);
  output.delta = summarizeDelta(previousIndex, scenarios);

  await fs.mkdir(path.dirname(outPath), { recursive: true });
  await fs.writeFile(outPath, `${JSON.stringify(output, null, 2)}\n`, 'utf8');
  console.log(`Scenario openability index written: ${outPath}`);
  console.log(`Total: ${output.totalScenarios}`);
  console.log(JSON.stringify(counts, null, 2));
  console.log(`Delta: +${output.delta.addedCount} / ~${output.delta.changedCount} / -${output.delta.removedCount}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
