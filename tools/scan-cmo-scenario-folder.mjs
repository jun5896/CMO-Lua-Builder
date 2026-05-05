import { Buffer } from 'node:buffer';
import fs from 'node:fs/promises';
import path from 'node:path';
import { getPreferredSidecarRoot } from './sidecar-paths.mjs';

const DEFAULT_OUT_ROOT = getPreferredSidecarRoot();

const API_PATTERN = /\b(?:ScenEdit|VP|Tool|World|Hs|Lua|Unit|UI|Command)_[A-Za-z0-9_]+/g;
const GUID_PATTERN = /\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b/gi;
const CMO_UNIT_ID_PATTERN = /\b[A-Z0-9]{6}-[A-Z0-9]{13}\b/g;
const DBID_PATTERN = /\b(?:dbid|loadoutid|weapon\s*dbid|sensor\s*dbid|mount\s*dbid)\s*[=:]\s*(\d+)\b/gi;
const HTML_KEYWORDS = [
  'Situation',
  'Enemy Forces',
  'Friendly Forces',
  'Air Bases',
  'Gameplay Notes',
  'Designer Note',
  'Special Actions',
];

function usage() {
  return [
    'Usage:',
    '  node tools/scan-cmo-scenario-folder.mjs <scenario.scen|scenario-folder> [--out <output.json>]',
    '',
    'Example:',
    '  node tools/scan-cmo-scenario-folder.mjs "C:\\...\\Iran Strike, 2020-2030.scen" --out scenario-sidecars\\iran-strike-2020-2030.json',
  ].join('\n');
}

function parseArgs(argv) {
  const options = { input: '', out: '' };

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--out') {
      options.out = argv[index + 1] || '';
      index += 1;
    } else if (!options.input) {
      options.input = value;
    }
  }

  if (!options.input) {
    throw new Error(usage());
  }

  return options;
}

async function pathStat(target) {
  try {
    return await fs.stat(target);
  } catch {
    return null;
  }
}

async function resolveScenarioInput(input) {
  const inputPath = path.resolve(input);
  const stat = await pathStat(inputPath);
  if (!stat) {
    throw new Error(`Scenario input not found: ${inputPath}`);
  }

  if (stat.isFile()) {
    if (path.extname(inputPath).toLowerCase() !== '.scen') {
      throw new Error(`Expected a .scen file or scenario folder: ${inputPath}`);
    }
    return {
      scenarioPath: inputPath,
      scenarioFolder: path.dirname(inputPath),
    };
  }

  if (!stat.isDirectory()) {
    throw new Error(`Input is neither file nor folder: ${inputPath}`);
  }

  const files = await fs.readdir(inputPath);
  const scenFiles = files.filter((file) => path.extname(file).toLowerCase() === '.scen').sort((a, b) => a.localeCompare(b));
  if (scenFiles.length === 0) {
    throw new Error(`No .scen file found in folder: ${inputPath}`);
  }

  return {
    scenarioPath: path.join(inputPath, scenFiles[0]),
    scenarioFolder: inputPath,
  };
}

function decodeXml(value = '') {
  return value
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&apos;/g, "'")
    .replace(/&amp;/g, '&')
    .replace(/&#(\d+);/g, (_, code) => String.fromCodePoint(Number(code)))
    .replace(/&#x([0-9a-f]+);/gi, (_, code) => String.fromCodePoint(Number.parseInt(code, 16)));
}

function normalizeText(value = '') {
  return decodeXml(value)
    .replace(/\r\n|\r/g, '\n')
    .replace(/[ \t]+/g, ' ')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

function getTag(xml, tagName) {
  const textMatch = new RegExp(`<${tagName}(?:\\s[^>]*)?>([\\s\\S]*?)<\\/${tagName}>`, 'i').exec(xml);
  if (textMatch) {
    return normalizeText(textMatch[1]);
  }
  const selfClosingMatch = new RegExp(`<${tagName}(?:\\s[^>]*)?\\/>`, 'i').exec(xml);
  return selfClosingMatch ? '' : null;
}

function getRawTag(xml, tagName) {
  const match = new RegExp(`<${tagName}(?:\\s[^>]*)?>([\\s\\S]*?)<\\/${tagName}>`, 'i').exec(xml);
  return match ? match[1].trim() : '';
}

function getLoadDocs(description) {
  return [...description.matchAll(/\[LOADDOC\]([^\[]+?)\[\/LOADDOC\]/gi)]
    .map((match) => match[1].trim())
    .filter(Boolean);
}

function summarizeCompressedBlock(rawCompressed) {
  if (!rawCompressed) {
    return {
      present: false,
      status: 'notPresent',
      note: 'Scenario_Compressed block was not found.',
    };
  }

  const compact = rawCompressed.replace(/\s+/g, '');
  let decoded = Buffer.alloc(0);
  let decodeError = '';
  try {
    decoded = Buffer.from(compact, 'base64');
  } catch (error) {
    decodeError = error instanceof Error ? error.message : String(error);
  }

  const firstBytesHex = decoded.length > 0
    ? [...decoded.subarray(0, 24)].map((byte) => byte.toString(16).padStart(2, '0')).join(' ')
    : '';

  return {
    present: true,
    status: 'metadataOnly',
    encoding: 'base64-container',
    base64Chars: compact.length,
    decodedBytes: decoded.length,
    firstBytesHex,
    decodeError,
    note: 'CMO stores the main scenario body in an internal compressed container. This scanner does not attempt unsafe/proprietary decoding; export events/Lua from the CMO engine for authoritative internals.',
  };
}

function getUniqueMatches(source, pattern, limit = 100) {
  const items = new Set();
  for (const match of source.matchAll(pattern)) {
    const value = match[1] || match[0];
    if (value) {
      items.add(value);
    }
    if (items.size >= limit) {
      break;
    }
  }
  return [...items];
}

function getApis(source) {
  return getUniqueMatches(source, API_PATTERN, 300).sort((a, b) => a.localeCompare(b));
}

function stripHtml(source) {
  return normalizeText(source
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<\/(?:p|li|h[1-6]|ul|ol|div|tr)>/gi, '\n')
    .replace(/<[^>]+>/g, ' '));
}

function extractHtmlHeadings(source) {
  return [...source.matchAll(/<h([1-6])[^>]*>([\s\S]*?)<\/h\1>/gi)]
    .map((match) => ({
      level: Number(match[1]),
      text: stripHtml(match[2]).replace(/\s+/g, ' ').trim(),
    }))
    .filter((heading) => heading.text)
    .slice(0, 24);
}

function getKeywordSnippets(text) {
  const snippets = [];
  for (const keyword of HTML_KEYWORDS) {
    const index = text.toLowerCase().indexOf(keyword.toLowerCase());
    if (index === -1) {
      continue;
    }
    snippets.push({
      keyword,
      text: text.slice(index, index + 520).replace(/\s+/g, ' ').trim(),
    });
  }
  return snippets.slice(0, 8);
}

function inferSidesFromFileName(fileName) {
  const withoutExt = path.basename(fileName, path.extname(fileName));
  const sidePart = withoutExt
    .replace(/^IranStrike_?/i, '')
    .replace(/_(?:Briefing|Gameplay_Notes)$/i, '');

  if (!sidePart || sidePart.toLowerCase() === 'description') {
    return [];
  }

  return sidePart
    .split(/[-_+]/)
    .map((part) => part.trim())
    .filter(Boolean);
}

async function scanHtmlFile(filePath, scenarioFolder) {
  const source = await fs.readFile(filePath, 'utf8');
  const text = stripHtml(source);
  const relativePath = path.relative(scenarioFolder, filePath);
  return {
    type: 'html',
    file: path.basename(filePath),
    relativePath,
    bytes: Buffer.byteLength(source, 'utf8'),
    inferredSides: inferSidesFromFileName(filePath),
    headings: extractHtmlHeadings(source),
    snippets: getKeywordSnippets(text),
    textPreview: text.slice(0, 700),
  };
}

function summarizeIniUnits(source) {
  const unitMatches = [...source.matchAll(/<Unit_([^>]+)>([\s\S]*?)<\/Unit_\1>/g)];
  const mountCounts = new Map();
  const units = [];

  for (const match of unitMatches) {
    const unitInternalId = match[1];
    const body = match[2];
    const comments = [...body.matchAll(/<!--([\s\S]*?)-->/g)].map((comment) => normalizeText(comment[1]));
    const unitName = comments[0] || '';
    const mounts = [];

    for (const mountMatch of body.matchAll(/<MountAdd_(\d+)>([\s\S]*?)<\/MountAdd_\1>/g)) {
      const mountDbid = mountMatch[1];
      const mountComment = /<!--([\s\S]*?)-->/.exec(mountMatch[2])?.[1] || '';
      const mountName = normalizeText(mountComment);
      const key = `${mountDbid}::${mountName}`;
      mountCounts.set(key, (mountCounts.get(key) || 0) + 1);
      if (mounts.length < 12) {
        mounts.push({
          dbid: mountDbid,
          name: mountName,
        });
      }
    }

    if (units.length < 40) {
      units.push({
        internalId: unitInternalId,
        name: unitName,
        mountCount: [...body.matchAll(/<MountAdd_(\d+)>/g)].length,
        mounts,
      });
    }
  }

  const mountSummary = [...mountCounts.entries()]
    .map(([key, count]) => {
      const [dbid, name] = key.split('::');
      return { dbid, name, count };
    })
    .sort((a, b) => b.count - a.count || a.dbid.localeCompare(b.dbid))
    .slice(0, 40);

  return {
    unitCount: unitMatches.length,
    units,
    mountSummary,
  };
}

async function scanIniFile(filePath, scenarioFolder) {
  const source = await fs.readFile(filePath, 'utf8');
  return {
    type: 'ini-sidecar',
    file: path.basename(filePath),
    relativePath: path.relative(scenarioFolder, filePath),
    bytes: Buffer.byteLength(source, 'utf8'),
    ...summarizeIniUnits(source),
  };
}

async function scanLuaFile(filePath, scenarioFolder) {
  const source = await fs.readFile(filePath, 'utf8');
  const lines = source.split(/\r\n|\r|\n/).length;
  return {
    type: 'lua',
    file: path.basename(filePath),
    relativePath: path.relative(scenarioFolder, filePath),
    bytes: Buffer.byteLength(source, 'utf8'),
    lines,
    apis: getApis(source),
    guids: getUniqueMatches(source, GUID_PATTERN, 100),
    cmoUnitIds: getUniqueMatches(source, CMO_UNIT_ID_PATTERN, 100),
    dbids: getUniqueMatches(source, DBID_PATTERN, 100),
    preview: source.slice(0, 900),
  };
}

async function scanSidecars(scenarioFolder) {
  const entries = await fs.readdir(scenarioFolder, { withFileTypes: true });
  const sidecars = [];

  for (const entry of entries.sort((a, b) => a.name.localeCompare(b.name))) {
    if (!entry.isFile()) {
      continue;
    }

    const ext = path.extname(entry.name).toLowerCase();
    const filePath = path.join(scenarioFolder, entry.name);
    if (ext === '.html' || ext === '.htm') {
      sidecars.push(await scanHtmlFile(filePath, scenarioFolder));
    } else if (ext === '.ini') {
      sidecars.push(await scanIniFile(filePath, scenarioFolder));
    } else if (ext === '.lua') {
      sidecars.push(await scanLuaFile(filePath, scenarioFolder));
    }
  }

  return sidecars;
}

function getScenarioMetadata(scenarioXml) {
  const description = getTag(scenarioXml, 'ScenDescription') || '';
  return {
    title: getTag(scenarioXml, 'ScenTitle') || '',
    description,
    loadDocs: getLoadDocs(description),
    complexity: getTag(scenarioXml, 'Complexity') || '',
    difficulty: getTag(scenarioXml, 'Difficulty') || '',
    setting: getTag(scenarioXml, 'ScenSetting') || '',
    date: getTag(scenarioXml, 'ScenDate') || '',
    dbVersion: getTag(scenarioXml, 'DBVersion') || '',
  };
}

function parseDbVersion(dbVersion) {
  const match = /^(DB3K|CWDB)[_-]?(\d+)\.db3$/i.exec(dbVersion.trim());
  if (!match) {
    return {
      raw: dbVersion,
      family: '',
      version: '',
    };
  }
  return {
    raw: dbVersion,
    family: match[1].toUpperCase(),
    version: `v${match[2]}`,
  };
}

function buildEditContext(metadata, compressed, sidecars) {
  const htmlFiles = sidecars.filter((item) => item.type === 'html');
  const luaFiles = sidecars.filter((item) => item.type === 'lua');
  const iniFiles = sidecars.filter((item) => item.type === 'ini-sidecar');
  const candidateSides = [...new Set(htmlFiles.flatMap((item) => item.inferredSides))].sort((a, b) => a.localeCompare(b));
  const apiSet = new Set(luaFiles.flatMap((item) => item.apis));
  const iniUnitNames = iniFiles.flatMap((item) => item.units.map((unit) => unit.name).filter(Boolean));
  const supportSnippets = htmlFiles.flatMap((item) => item.snippets.map((snippet) => ({
    file: item.relativePath,
    keyword: snippet.keyword,
    text: snippet.text,
  }))).slice(0, 16);

  return {
    database: parseDbVersion(metadata.dbVersion),
    loadedDocuments: metadata.loadDocs,
    candidateSidesFromBriefingFiles: candidateSides,
    sideExtractionStatus: candidateSides.length > 0 ? 'briefingFileNamesOnly' : 'notDetected',
    looseLuaFiles: luaFiles.map((item) => ({
      file: item.relativePath,
      lines: item.lines,
      apis: item.apis.slice(0, 40),
    })),
    looseLuaApiCount: apiSet.size,
    iniUnitHints: iniUnitNames.slice(0, 30),
    supportingEvidence: [
      ...supportSnippets,
      ...iniFiles.flatMap((item) => item.units.slice(0, 12).map((unit) => ({
        file: item.relativePath,
        keyword: 'ScenarioUnits',
        text: `${unit.name || unit.internalId} / mounts: ${unit.mounts.map((mount) => `${mount.name || 'Mount'} #${mount.dbid}`).join(', ')}`,
      }))),
    ].slice(0, 24),
    limitations: [
      compressed.present
        ? 'Scenario_Compressed is present. Internal sides, events, missions, units, reference points, and embedded Lua require CMO engine export or a dedicated decoder.'
        : 'Scenario_Compressed was not present, so this file appears to expose only top-level metadata.',
      'Briefing filename sides are player/briefing hints, not guaranteed exact CMO side names.',
      'Sidecar .ini files can expose unit/mount hints, but not full runtime scenario state.',
    ],
    recommendedCmoExport: [
      'Open the scenario in CMO and use Lua Console/Event Editor export helpers for authoritative events and embedded Lua.',
      'Use Database Viewer for DBID/Loadout IDs and Scenario Editor > Copy unit ID to clipboard for placed unit GUIDs.',
      'Feed exported event/Lua text back into this assistant together with this scenario scan JSON.',
    ],
  };
}

async function scanScenario(input) {
  const { scenarioPath, scenarioFolder } = await resolveScenarioInput(input);
  const scenarioXml = await fs.readFile(scenarioPath, 'utf8');
  const metadata = getScenarioMetadata(scenarioXml);
  const compressed = summarizeCompressedBlock(getRawTag(scenarioXml, 'Scenario_Compressed'));
  const sidecars = await scanSidecars(scenarioFolder);

  return {
    generatedAt: new Date().toISOString(),
    scanner: {
      name: 'scan-cmo-scenario-folder',
      version: 1,
      mode: 'safe-metadata-and-sidecars',
    },
    input: {
      scenarioPath,
      scenarioFolder,
    },
    scenario: metadata,
    compressed,
    sidecars,
    editContext: buildEditContext(metadata, compressed, sidecars),
  };
}

function defaultOutputPath(scan) {
  const title = scan.scenario.title || path.basename(scan.input.scenarioPath, '.scen');
  const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'scenario-scan';
  return path.join(DEFAULT_OUT_ROOT, `${slug}.json`);
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const scan = await scanScenario(options.input);
  const outputPath = options.out ? path.resolve(options.out) : defaultOutputPath(scan);

  await fs.mkdir(path.dirname(outputPath), { recursive: true });
  await fs.writeFile(outputPath, `${JSON.stringify(scan, null, 2)}\n`, 'utf8');

  console.log(`Scenario scan written: ${outputPath}`);
  console.log(`Title: ${scan.scenario.title || '(unknown)'}`);
  console.log(`DB: ${scan.scenario.dbVersion || '(unknown)'}`);
  console.log(`Sidecars: ${scan.sidecars.length}`);
  console.log(`Compressed: ${scan.compressed.present ? `${scan.compressed.status}, ${scan.compressed.decodedBytes} bytes decoded` : 'not present'}`);
  console.log(`Candidate sides: ${scan.editContext.candidateSidesFromBriefingFiles.join(', ') || '(none)'}`);
  console.log(`Loose Lua files: ${scan.editContext.looseLuaFiles.length}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
