import fs from 'node:fs/promises';
import path from 'node:path';

const DEFAULT_CMO_LUA_ROOT = 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Command - Modern Operations\\Lua';
const CMO_LUA_ROOT = process.env.CMO_LUA_ROOT || DEFAULT_CMO_LUA_ROOT;
const PROJECT_ROOT = path.resolve(new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1'));
const OUT_ROOT = path.join(PROJECT_ROOT, 'public', 'cmo-installed-lua');
const EXAMPLES_ROOT = path.join(OUT_ROOT, 'examples');

const API_PATTERN = /\b(?:ScenEdit|VP|Tool|World|Hs|Lua|Unit|UI|Command)_[A-Za-z0-9_]+/g;

const FEATURE_RULES = [
  {
    name: 'Event Automation',
    description: 'Creates or wires CMO events, triggers, conditions, and Lua actions.',
    pattern: /\bScenEdit_(?:SetEvent|SetTrigger|SetCondition|SetAction|SetEventTrigger|SetEventCondition|SetEventAction)\b/,
  },
  {
    name: 'Mission Control',
    description: 'Creates missions or assigns units/targets to missions.',
    pattern: /\bScenEdit_(?:AddMission|SetMission|AssignUnitToMission|AssignUnitAsTarget|DeleteMission)\b/,
  },
  {
    name: 'Unit Spawn / Edit',
    description: 'Adds, moves, teleports, damages, or edits units.',
    pattern: /\bScenEdit_(?:AddUnit|SetUnit|GetUnit|DeleteUnit|TeleportTo|SetLoadout)\b/,
  },
  {
    name: 'Contacts / Detection',
    description: 'Reads contacts or contact wrappers for detection-driven logic.',
    pattern: /\b(?:ScenEdit_GetContacts|VP_GetSide|contactsBy|ScenEdit_UnitC)\b/,
  },
  {
    name: 'Doctrine / EMCON',
    description: 'Changes doctrine or emissions control state.',
    pattern: /\bScenEdit_(?:SetEMCON|GetDoctrine|SetDoctrine|SetDoctrineWRA)\b/,
  },
  {
    name: 'Weather',
    description: 'Reads or changes scenario weather.',
    pattern: /\bScenEdit_SetWeather\b|\bweather\b/i,
  },
  {
    name: 'Scoring / Victory',
    description: 'Reads score, changes score, or ends the scenario.',
    pattern: /\bScenEdit_(?:GetScore|SetScore|EndScenario)\b/,
  },
  {
    name: 'Messaging / Briefing',
    description: 'Shows special messages or writes player-facing text.',
    pattern: /\bScenEdit_(?:SpecialMessage|SetSideOptions)\b|\bmessage\b/i,
  },
  {
    name: 'Reference Points / Zones',
    description: 'Creates or uses reference points and patrol/trigger areas.',
    pattern: /\bScenEdit_(?:AddReferencePoint|SetReferencePoint|GetReferencePoint|DeleteReferencePoint)\b|\bReferencePoint\b|\barea\b/i,
  },
  {
    name: 'Cargo / Logistics',
    description: 'Moves cargo, magazines, weapons, or supply state.',
    pattern: /\bScenEdit_(?:UnloadCargo|ClearAllMagazines|DistributeWeaponAtAirbase|AddWeaponToUnitMagazine)\b|\bcargo\b|\blogistics\b/i,
  },
  {
    name: 'Geometry / Map',
    description: 'Uses range, circles, coordinates, elevation, or map geometry.',
    pattern: /\b(?:Tool_Range|World_GetCircleFromPoint|World_GetElevation|latitude|longitude)\b/i,
  },
  {
    name: 'KeyValue State',
    description: 'Stores state with scenario key/value helpers.',
    pattern: /\bScenEdit_(?:GetKeyValue|SetKeyValue)\b/,
  },
];

function toPosix(relativePath) {
  return relativePath.split(path.sep).join('/');
}

function toPublicPath(relativePath) {
  return `/cmo-installed-lua/examples/${toPosix(relativePath)
    .split('/')
    .map((part) => encodeURIComponent(part))
    .join('/')}`;
}

async function pathExists(target) {
  try {
    await fs.access(target);
    return true;
  } catch {
    return false;
  }
}

async function collectLuaFiles(root, current = root) {
  const entries = await fs.readdir(current, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(current, entry.name);
    if (entry.isDirectory()) {
      files.push(...await collectLuaFiles(root, fullPath));
    } else if (entry.isFile() && entry.name.toLowerCase().endsWith('.lua')) {
      files.push(fullPath);
    }
  }

  return files;
}

function getApis(source) {
  const matches = source.match(API_PATTERN) || [];
  return [...new Set(matches)].sort((a, b) => a.localeCompare(b));
}

function getFeatures(source, relativePath) {
  const searchable = `${relativePath}\n${source}`;
  return FEATURE_RULES
    .filter((rule) => rule.pattern.test(searchable))
    .map((rule) => rule.name);
}

function addIndexEntry(index, key, example) {
  if (!index.has(key)) {
    index.set(key, { name: key, count: 0, examples: [] });
  }
  const item = index.get(key);
  item.count += 1;
  if (item.examples.length < 8) {
    item.examples.push(example);
  }
}

async function main() {
  if (!await pathExists(CMO_LUA_ROOT)) {
    throw new Error(`CMO Lua root not found: ${CMO_LUA_ROOT}`);
  }

  await fs.rm(OUT_ROOT, { recursive: true, force: true });
  await fs.mkdir(EXAMPLES_ROOT, { recursive: true });

  const luaFiles = (await collectLuaFiles(CMO_LUA_ROOT)).sort((a, b) => a.localeCompare(b));
  const apiIndex = new Map();
  const featureIndex = new Map();
  let totalBytes = 0;

  const examples = [];
  for (const fullPath of luaFiles) {
    const relativePath = path.relative(CMO_LUA_ROOT, fullPath);
    const destination = path.join(EXAMPLES_ROOT, relativePath);
    const stat = await fs.stat(fullPath);
    const source = await fs.readFile(fullPath, 'utf8');
    const apis = getApis(source);
    const features = getFeatures(source, relativePath);
    const scenario = relativePath.split(path.sep)[0] || '(root)';
    const lineCount = source.split(/\r\n|\r|\n/).length;
    const publicPath = toPublicPath(relativePath);
    const exampleSummary = {
      file: path.basename(fullPath),
      relativePath: toPosix(relativePath),
      path: publicPath,
    };

    await fs.mkdir(path.dirname(destination), { recursive: true });
    await fs.copyFile(fullPath, destination);

    totalBytes += stat.size;
    apis.forEach((api) => addIndexEntry(apiIndex, api, exampleSummary));
    features.forEach((feature) => addIndexEntry(featureIndex, feature, exampleSummary));

    examples.push({
      type: 'installed-example',
      scenario,
      file: path.basename(fullPath),
      relativePath: toPosix(relativePath),
      path: publicPath,
      size: stat.size,
      lines: lineCount,
      lastWriteTime: stat.mtime.toISOString(),
      apis,
      features,
    });
  }

  const featureDescriptions = Object.fromEntries(FEATURE_RULES.map((rule) => [rule.name, rule.description]));
  const manifest = {
    generatedAt: new Date().toISOString(),
    sourceRoot: CMO_LUA_ROOT,
    fileCount: examples.length,
    totalBytes,
    examples,
    apiIndex: [...apiIndex.values()].sort((a, b) => b.count - a.count || a.name.localeCompare(b.name)),
    featureIndex: [...featureIndex.values()]
      .map((item) => ({ ...item, description: featureDescriptions[item.name] || '' }))
      .sort((a, b) => b.count - a.count || a.name.localeCompare(b.name)),
  };

  await fs.writeFile(path.join(OUT_ROOT, 'manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');

  console.log(`Synced ${examples.length} CMO Lua examples`);
  console.log(`Source: ${CMO_LUA_ROOT}`);
  console.log(`Output: ${OUT_ROOT}`);
  console.log(`APIs indexed: ${manifest.apiIndex.length}`);
  console.log(`Features indexed: ${manifest.featureIndex.length}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
