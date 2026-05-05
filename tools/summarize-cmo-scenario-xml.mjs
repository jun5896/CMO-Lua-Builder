#!/usr/bin/env node
/**
 * summarize-cmo-scenario-xml.mjs  ("보조 요약기" — Claude Task 2)
 *
 *   Initial draft  : 2026-05-02 (synthetic XML guesses)
 *   Calibrated     : 2026-05-02 (verified against real Iran Strike internal XML
 *                                supplied by codex via "Task 2 calibration open")
 *
 * Companion to codex's existing tooling:
 *   - tools/extract-cmo-scenario-xml.ps1   (codex; uses CMO DLLs to decode .scen)
 *   - tools/scan-cmo-scenario-folder.mjs   (codex; scans .scen + sidecars)
 *
 * Pipeline:
 *   .scen file
 *     → [extract-cmo-scenario-xml.ps1] decoded internal <Scenario>...</Scenario>
 *       or <ContentScenario>...</ContentScenario>
 *     → [this script] events[] / specialActions[] / sides[] / missions[]
 *                     / referencePoints[] / zones[] / activeUnits[]
 *                     / objectContext / scenario / detectedApis / warnings
 *     → [UI] feeds into Object Context Registry + AI prompts
 *
 * Real-XML calibration notes (from Iran Strike, 2020-2030 sample):
 *   - <Sides> is at scenario root.  Each <Side> contains: <ID>, <Name>,
 *     <Nature>, <Operation>, <Postures>, <ReferencePoints>, <Doctrine>,
 *     <NoNavZones>, [<ExclusionZones>], <Missions>, <SpecialActions>, ...
 *   - <Missions> children are POLYMORPHIC by element name:
 *     <Patrol>, <Strike>, <SupportMission>, ... (etc.)
 *   - <ReferencePoints>, <NoNavZones>, <ExclusionZones>, <SpecialActions>,
 *     <Missions> ALL live nested inside <Side>, NOT at scenario root.
 *   - <Postures> uses GUID-suffixed element names: <Posture_<otherSideID>>N</...>
 *     where N is an integer (0=Friendly, 1=Neutral, 2=Unfriendly, 3=Hostile).
 *   - <ActiveUnits> IS top-level and contains <Aircraft>/<Ship>/<Submarine>/
 *     <Facility>/<Group> children.  Unit blocks reference their side via a
 *     <Side>String</Side> field (display name, not GUID).
 *   - Zone display name lives in <Description>, not <Name>.  Zone polygon
 *     vertices live under <Area> as nested <RPoint> blocks (NOT navigation RPs).
 *
 * Usage:
 *   node summarize-cmo-scenario-xml.mjs <internal-xml-file> [--out <out.json>]
 *   cat scenario.xml | node summarize-cmo-scenario-xml.mjs --stdin
 *
 * Spec lives in handoff/to-codex/Task-2/backend-scenario-xml-summary-contract.md.
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { argv, exit, stdin } from 'node:process';
import { basename } from 'node:path';
import { parse as parseEventExport } from './parse-cmo-event-export.mjs';

// -----------------------------------------------------------------------------
// Sample / output limits
//   Tunable via env (CMO_SUM_MAX_*) but defaults chosen for ~10MB Iran-Strike
//   class scenarios with ~1200 units / ~1600 polygon vertices.
// -----------------------------------------------------------------------------

const LIMITS = {
  units:           Number(process.env.CMO_SUM_MAX_UNITS ?? 500),
  refPoints:       Number(process.env.CMO_SUM_MAX_REFPOINTS ?? 500),
  zones:           Number(process.env.CMO_SUM_MAX_ZONES ?? 200),
  missions:        Number(process.env.CMO_SUM_MAX_MISSIONS ?? 200),
  unitNamesInCtx:  Number(process.env.CMO_SUM_MAX_UNIT_NAMES_CTX ?? 200),
};

// -----------------------------------------------------------------------------
// Generic XML helpers (intentionally regex-based — internal CMO XML has no
// attributes, no CDATA, no namespaces; a real DOM parser would be overkill
// for a 10MB single-document use-case.)
// -----------------------------------------------------------------------------

function tagText(block, name) {
  if (!block) return undefined;
  const m = block.match(new RegExp(`<${name}\\s*>([\\s\\S]*?)</${name}\\s*>`, 'i'));
  return m ? m[1].trim() : undefined;
}

function tagTextAll(block, name) {
  if (!block) return [];
  const re = new RegExp(`<${name}\\s*>([\\s\\S]*?)</${name}\\s*>`, 'gi');
  const out = [];
  let m;
  while ((m = re.exec(block)) !== null) out.push(m[1].trim());
  return out;
}

function numText(block, name) {
  const t = tagText(block, name);
  if (t == null || t === '') return undefined;
  const n = Number(t);
  return Number.isFinite(n) ? n : undefined;
}

function boolText(block, name) {
  const t = tagText(block, name);
  if (t == null) return undefined;
  if (/^true$/i.test(t))  return true;
  if (/^false$/i.test(t)) return false;
  return undefined;
}

function decodeXmlEntities(s) {
  if (!s) return s;
  return String(s)
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&amp;/g, '&');
}

/**
 * Find the FIRST balanced <tagName>...</tagName> element (or self-closing
 * <tagName/>) starting at fromIndex. Depth-aware so it correctly skips nested
 * occurrences of the same tag.
 *
 * Returns { body, start, end } or null.
 *   - `body`  : inner text between open and close tag (or '' for self-close)
 *   - `start` : position of the opening '<'
 *   - `end`   : position right after the closing '>'
 */
function findElement(xml, tagName, fromIndex = 0) {
  const tagRe = new RegExp(`<(/?)${tagName}\\b[^>]*?(/?)>`, 'g');
  tagRe.lastIndex = fromIndex;
  let depth = 0, openStart = -1, contentStart = -1;
  let m;
  while ((m = tagRe.exec(xml)) !== null) {
    const isClose = m[1] === '/';
    const isSelfClose = m[2] === '/';
    if (!isClose) {
      if (depth === 0) { openStart = m.index; contentStart = tagRe.lastIndex; }
      if (isSelfClose && depth === 0) {
        return { body: '', start: openStart, end: tagRe.lastIndex };
      }
      if (!isSelfClose) depth++;
    } else {
      depth--;
      if (depth === 0) {
        return {
          body: xml.slice(contentStart, m.index),
          start: openStart,
          end: tagRe.lastIndex,
        };
      }
    }
  }
  return null;
}

/**
 * List every DIRECT child of `parentBody` whose tag name passes `predicate`
 * (string for single name, or function(name)->bool for polymorphic match).
 * Returns array of { name, body } records, in document order.
 */
function listDirectChildren(parentBody, predicate) {
  const predFn = typeof predicate === 'string'
    ? (n) => n === predicate
    : predicate;
  const out = [];
  const tagRe = /<(\/?)([A-Za-z_][\w]*)\b[^>]*?(\/?)>/g;
  let depth = 0;
  let cur = null;     // currently-open top-level matching child
  let curStart = -1;
  let m;
  while ((m = tagRe.exec(parentBody)) !== null) {
    const isClose = m[1] === '/';
    const name = m[2];
    const isSelfClose = m[3] === '/';
    if (!isClose) {
      if (depth === 0 && predFn(name)) {
        cur = name;
        curStart = tagRe.lastIndex;
      }
      if (isSelfClose) {
        if (depth === 0 && cur === name) {
          out.push({ name, body: '' });
          cur = null;
        }
      } else {
        depth++;
      }
    } else {
      depth--;
      if (depth === 0 && cur === name) {
        out.push({ name, body: parentBody.slice(curStart, m.index) });
        cur = null;
      }
    }
  }
  return out;
}

const MISSION_KIND_RE = /^([A-Z][A-Za-z]*Mission|Patrol|Strike|Cargo|Ferry|Mine|Support)$/;
const UNIT_KIND_RE    = /^(Aircraft|Ship|Submarine|Facility|Group|Satellite|Weapon)$/;

// -----------------------------------------------------------------------------
// Scenario-level metadata
// -----------------------------------------------------------------------------

function harvestScenarioMetadata(xml) {
  // Scenario-root metadata fields use names (Description, Name, ID) that are
  // also reused deep inside Side / unit / zone blocks. To pick only the root
  // occurrences, walk the direct children of <Scenario>/<ContentScenario>
  // with depth tracking. Some CMO content/campaign scenarios decode to
  // <ContentScenario> even though they still contain the same useful internals.
  const scenEl = findElement(xml, 'Scenario') || findElement(xml, 'ContentScenario');
  const root = scenEl ? scenEl.body : xml;
  const directChildText = new Map();   // tagName -> first non-empty inner text
  const tagRe = /<(\/?)([A-Za-z_][\w]*)\b[^>]*?(\/?)>/g;
  let depth = 0, curName = null, curStart = -1;
  let m;
  while ((m = tagRe.exec(root)) !== null) {
    const isClose = m[1] === '/';
    const name = m[2];
    const isSelfClose = m[3] === '/';
    if (!isClose) {
      if (depth === 0 && !isSelfClose) {
        curName = name;
        curStart = tagRe.lastIndex;
      }
      if (!isSelfClose) depth++;
    } else {
      depth--;
      if (depth === 0 && curName === name && curStart >= 0) {
        const txt = root.slice(curStart, m.index).trim();
        if (txt && !directChildText.has(name)) directChildText.set(name, txt);
        curName = null;
      }
    }
  }
  const t = (n) => directChildText.get(n);
  const out = {
    title:        t('Title'),
    description:  t('Description'),
    setting:      t('Meta_ScenSetting') || t('Setting'),
    fileName:     t('FileName'),
    fileNamePath: t('FileNamePath'),
    startTime:    t('StartTime'),
    zeroHour:     t('ZeroHour'),
    duration:     t('Duration'),
    currentSide:  t('CurrentSide'),
    complexity:   t('Meta_Complexity') || t('Complexity'),
    difficulty:   t('Meta_Difficulty') || t('Difficulty'),
    dbVersion:    t('DBVersion') || t('DBUsed'),
    gameVersion:  t('GameVersion'),
    weatherModel: t('WeatherModel'),
    timeCompression: t('TimeCompression'),
    campaignId:   t('CampaignID'),
  };
  for (const [k, v] of Object.entries(out)) {
    if (v == null || v === '') delete out[k];
    else out[k] = decodeXmlEntities(v);
  }
  return out;
}

// -----------------------------------------------------------------------------
// Sides (with embedded postures, operation, and per-side counts)
// -----------------------------------------------------------------------------

function harvestSidesAndChildren(xml, warnings) {
  const sidesEl = findElement(xml, 'Sides');
  if (!sidesEl) {
    warnings.push('No <Sides> container found at scenario root');
    return { sides: [], missions: [], referencePoints: [], zones: [], specialActions: [] };
  }

  const sideBlocks = listDirectChildren(sidesEl.body, 'Side');
  const sides = [];
  const missions = [];
  const referencePoints = [];
  const zones = [];
  const specialActions = [];

  let truncated = { missions: false, refs: false, zones: false };

  for (const { body: sideBody } of sideBlocks) {
    const sideId   = tagText(sideBody, 'ID');
    const sideName = decodeXmlEntities(tagText(sideBody, 'Name') || '');
    const nature   = boolText(sideBody, 'Nature');

    // Operation
    const opEl = findElement(sideBody, 'Operation');
    const operation = opEl ? {
      id:                       tagText(opEl.body, 'ID'),
      hHourMissionTime:         numText(opEl.body, 'HHourMissionTime'),
      lHourMissionTime:         numText(opEl.body, 'LHourMissionTime'),
      hHourEffectiveStartTime:  numText(opEl.body, 'HHourEffectiveStartTime'),
      lHourEffectiveStartTime:  numText(opEl.body, 'LHourEffectiveStartTime'),
      hLHourAreRelative:        boolText(opEl.body, 'H_LHourAreRelative'),
    } : null;

    // Postures (GUID-suffixed element names)
    const postEl = findElement(sideBody, 'Postures');
    const postures = {};
    if (postEl) {
      const postRe = /<Posture_([A-Za-z0-9_-]+)>([^<]*)<\/Posture_\1\s*>/g;
      let pm;
      while ((pm = postRe.exec(postEl.body)) !== null) {
        const otherGuid = pm[1];
        const value = parseInt(pm[2], 10);
        if (Number.isFinite(value)) postures[otherGuid] = value;
      }
    }

    // Per-side mission harvest (polymorphic <Patrol|Strike|*Mission|...>)
    const missionsEl = findElement(sideBody, 'Missions');
    let sideMissionCount = 0;
    if (missionsEl) {
      const missionBlocks = listDirectChildren(
        missionsEl.body,
        (n) => MISSION_KIND_RE.test(n),
      );
      sideMissionCount = missionBlocks.length;
      for (const { name: kind, body: mBody } of missionBlocks) {
        if (missions.length >= LIMITS.missions) {
          truncated.missions = true;
          break;
        }
        const mName = tagText(mBody, 'Name');
        if (!mName) continue;
        missions.push({
          id:        tagText(mBody, 'ID'),
          name:      decodeXmlEntities(mName),
          kind,                                   // Patrol | Strike | SupportMission | ...
          category:  tagText(mBody, 'Category'),
          type:      tagText(mBody, 'Type'),
          phase:     tagText(mBody, '_Phase'),
          completion:tagText(mBody, 'Completion'),
          operationName: tagText(mBody, 'OperationName') || null,
          priorityWeight:numText(mBody, 'PriorityWeight'),
          estimatedExecutionTime: tagText(mBody, 'EstimatedExecutionTime'),
          startTriggerEnabled:    boolText(mBody, 'MissionStartTrigger_Time_Enabled'),
          completedTriggerEnabled:boolText(mBody, 'MissionCompletedTrigger_ElapsedTime_Enabled'),
          sideId,
          sideName,
        });
      }
    }

    // Per-side navigation reference points
    const refPointsEl = findElement(sideBody, 'ReferencePoints');
    let sideRPCount = 0;
    if (refPointsEl) {
      const rpBlocks = listDirectChildren(refPointsEl.body, 'RPoint');
      sideRPCount = rpBlocks.length;
      for (const { body: rpBody } of rpBlocks) {
        if (referencePoints.length >= LIMITS.refPoints) {
          truncated.refs = true;
          break;
        }
        const name = tagText(rpBody, 'Name');
        if (!name) continue;
        referencePoints.push({
          id:        tagText(rpBody, 'ID'),
          name:      decodeXmlEntities(name),
          lat:       numText(rpBody, 'Lat'),
          lon:       numText(rpBody, 'Lon'),
          isVisible: boolText(rpBody, 'Vis') ?? boolText(rpBody, 'IH'),
          isLocked:  boolText(rpBody, 'IsLocked'),
          color: {
            r: numText(rpBody, 'ColorR'),
            g: numText(rpBody, 'ColorG'),
            b: numText(rpBody, 'ColorB'),
          },
          rgroup:    numText(rpBody, 'RGroup'),
          sideId,
          sideName,
        });
      }
    }

    // Per-side zones (NoNavZones + ExclusionZones, both nested in Side)
    let sideZoneCount = 0;
    for (const containerTag of ['NoNavZones', 'ExclusionZones']) {
      const zEl = findElement(sideBody, containerTag);
      if (!zEl) continue;
      const childTag = containerTag.slice(0, -1); // NoNavZone / ExclusionZone
      const zBlocks = listDirectChildren(zEl.body, childTag);
      sideZoneCount += zBlocks.length;
      for (const { body: zBody } of zBlocks) {
        if (zones.length >= LIMITS.zones) {
          truncated.zones = true;
          break;
        }
        const desc = tagText(zBody, 'Description') || tagText(zBody, 'Name');
        if (!desc) continue;
        // Count vertices in <Area><RPoint>... — informational only
        const areaEl = findElement(zBody, 'Area');
        const vertexCount = areaEl
          ? listDirectChildren(areaEl.body, 'RPoint').length
          : 0;
        zones.push({
          kind:        childTag,
          id:          tagText(zBody, 'ID'),
          name:        decodeXmlEntities(desc),
          isActive:    boolText(zBody, 'IsActive'),
          vertexCount,
          sideId,
          sideName,
        });
      }
    }

    // Per-side special actions (Task 1 parser also picks these up but we
    // surface a name-list here for the per-side counters).
    const saEl = findElement(sideBody, 'SpecialActions');
    let sideSACount = 0;
    if (saEl) {
      const saBlocks = listDirectChildren(saEl.body, 'SpecialAction');
      sideSACount = saBlocks.length;
      for (const { body: saBody } of saBlocks) {
        const name = tagText(saBody, 'Name');
        if (!name) continue;
        specialActions.push({
          id:           tagText(saBody, 'ID'),
          name:         decodeXmlEntities(name),
          isActive:     boolText(saBody, 'IsActive'),
          isRepeatable: boolText(saBody, 'IsRepeatable'),
          sideId,
          sideName,
        });
      }
    }

    sides.push({
      id: sideId,
      name: sideName,
      nature,
      operation,
      postures,
      counts: {
        missions: sideMissionCount,
        referencePoints: sideRPCount,
        zones: sideZoneCount,
        specialActions: sideSACount,
      },
    });
  }

  if (truncated.missions) warnings.push(`missions list truncated at ${LIMITS.missions} (CMO_SUM_MAX_MISSIONS)`);
  if (truncated.refs)     warnings.push(`referencePoints list truncated at ${LIMITS.refPoints} (CMO_SUM_MAX_REFPOINTS)`);
  if (truncated.zones)    warnings.push(`zones list truncated at ${LIMITS.zones} (CMO_SUM_MAX_ZONES)`);

  return { sides, missions, referencePoints, zones, specialActions };
}

// -----------------------------------------------------------------------------
// ActiveUnits (top-level container; mixed unit-kind children)
// -----------------------------------------------------------------------------

function harvestActiveUnits(xml, warnings) {
  const auEl = findElement(xml, 'ActiveUnits');
  if (!auEl) {
    return { activeUnits: [], unitCounts: { total: 0 } };
  }
  const blocks = listDirectChildren(auEl.body, (n) => UNIT_KIND_RE.test(n));
  const activeUnits = [];
  const unitCounts = {};
  let truncated = false;

  for (const { name: kind, body: uBody } of blocks) {
    unitCounts[kind] = (unitCounts[kind] || 0) + 1;
    if (activeUnits.length >= LIMITS.units) {
      truncated = true;
      continue;          // keep counting but stop pushing detail rows
    }
    const name = tagText(uBody, 'Name');
    if (!name) continue;
    activeUnits.push({
      id:    tagText(uBody, 'ID'),
      kind,                                              // Aircraft | Ship | ...
      name:  decodeXmlEntities(name),
      side:  decodeXmlEntities(tagText(uBody, 'Side') || ''),  // STRING name
      dbid:  tagText(uBody, 'DBID'),
      lat:   numText(uBody, 'Lat'),
      lon:   numText(uBody, 'Lon'),
      heading: numText(uBody, 'CH'),
      speed:   numText(uBody, 'CS'),
      altitude:numText(uBody, 'CA'),
      flightRole: tagText(uBody, 'FlightRole'),
    });
  }
  if (truncated) {
    warnings.push(
      `activeUnits sample truncated at ${LIMITS.units} entries ` +
      `(unitCounts still reflects full totals; raise CMO_SUM_MAX_UNITS to widen)`,
    );
  }
  unitCounts.total = blocks.length;
  return { activeUnits, unitCounts };
}

// -----------------------------------------------------------------------------
// Top-level summarize()
// -----------------------------------------------------------------------------

export function summarize(xml, opts = {}) {
  const warnings = [];

  // 1. Reuse Task 1 XML parser for events + specialActions detail
  //    (specialActions detail comes from Task 1 ScriptText handling; the
  //    name-list we built per-side above is just for object-context.)
  const eventsResult = parseEventExport(xml, { type: 'toolDumpEvents' });

  // 2. Scenario metadata
  const scenario = harvestScenarioMetadata(xml);

  // 3. Sides + per-side rollups (missions, RPs, zones, specialActions)
  const sideHarvest = harvestSidesAndChildren(xml, warnings);

  // 4. Top-level active units
  const { activeUnits, unitCounts } = harvestActiveUnits(xml, warnings);

  // 4b. Cross-reference per-side <SpecialAction> sideId/sideName onto Task 1's
  //     detailed specialActions[] (Task 1 doesn't track sides — it parses the
  //     scripted block only). Match by ID.
  const sideBySaId = new Map();
  for (const sa of sideHarvest.specialActions) {
    if (sa.id) sideBySaId.set(sa.id, { sideId: sa.sideId, sideName: sa.sideName });
  }
  const enrichedSpecialActions = eventsResult.specialActions.map((sa) => {
    const sideRef = sa.id ? sideBySaId.get(sa.id) : null;
    return sideRef ? { ...sa, sideId: sideRef.sideId, sideName: sideRef.sideName } : sa;
  });
  const unmatched = enrichedSpecialActions.filter(sa => !sa.sideName).length;
  if (unmatched > 0 && eventsResult.specialActions.length > 0) {
    warnings.push(
      `${unmatched}/${eventsResult.specialActions.length} specialActions could not be ` +
      `attributed to a side (ID mismatch between Task 1 and per-side harvest)`,
    );
  }

  // 5. Build objectContext for UI Object Context Registry. Names only,
  //    capped per LIMITS.unitNamesInCtx so the prompt doesn't blow context.
  const unitNamesCtx = activeUnits
    .slice(0, LIMITS.unitNamesInCtx)
    .map(u => u.name);
  const objectContext = {
    sides:           sideHarvest.sides.map(s => s.name).filter(Boolean),
    missions:        sideHarvest.missions.map(m => m.name),
    units:           unitNamesCtx,
    referencePoints: sideHarvest.referencePoints.map(r => r.name),
    zones:           sideHarvest.zones.map(z => z.name),
    specialActions:  sideHarvest.specialActions.map(sa => sa.name)
                       .concat(eventsResult.specialActions.map(sa => sa.name).filter(Boolean))
                       .filter((v, i, a) => v && a.indexOf(v) === i),
    luaFiles:        eventsResult.objectContext.luaFiles,
  };

  if ((unitCounts.total || 0) > LIMITS.unitNamesInCtx) {
    warnings.push(
      `objectContext.units capped at ${LIMITS.unitNamesInCtx} of ${unitCounts.total} ` +
      `(use activeUnits[] or unitCounts for full picture)`,
    );
  }

  // 6. Sanity warnings
  if (eventsResult.events.length === 0
      && Object.keys(scenario).length === 0
      && sideHarvest.sides.length === 0) {
    warnings.push('Input has no Scenario/ContentScenario/Sides/Events — likely not decoded internal XML');
  }
  warnings.push(...eventsResult.warnings);

  return {
    source: {
      type:      'extractedScenarioXml',
      fileName:  opts.fileName,
      parsedAt:  new Date().toISOString(),
      xmlLength: xml.length,
      calibratedAgainst: 'Iran Strike, 2020-2030 (verified 2026-05-02)',
    },
    scenario,
    sides:           sideHarvest.sides,
    missions:        sideHarvest.missions,
    referencePoints: sideHarvest.referencePoints,
    zones:           sideHarvest.zones,
    activeUnits,
    unitCounts,
    events:          eventsResult.events,
    specialActions:  enrichedSpecialActions,
    objectContext,
    detectedApis:    eventsResult.detectedApis,
    warnings,
  };
}

// -----------------------------------------------------------------------------
// CLI
// -----------------------------------------------------------------------------

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    stdin.setEncoding('utf-8');
    stdin.on('data', (chunk) => { data += chunk; });
    stdin.on('end', () => resolve(data));
  });
}

function parseCliArgs(args) {
  const opts = { stdin: false, out: null, input: null };
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '--stdin') opts.stdin = true;
    else if (a === '--out') opts.out = args[++i];
    else if (a === '-h' || a === '--help') opts.help = true;
    else if (!a.startsWith('--') && !opts.input) opts.input = a;
  }
  return opts;
}

function printHelp() {
  console.log(`summarize-cmo-scenario-xml.mjs (calibrated 2026-05-02)

Usage:
  node summarize-cmo-scenario-xml.mjs <internal-xml-file> [--out <out.json>]
  node summarize-cmo-scenario-xml.mjs --stdin
  cat scenario.xml | node summarize-cmo-scenario-xml.mjs --stdin

Input is the DECODED internal XML produced by codex's
tools/extract-cmo-scenario-xml.ps1 (which uses CMO's own DLLs).

Output JSON shape: see backend-scenario-xml-summary-contract.md.
`);
}

async function main() {
  const opts = parseCliArgs(argv.slice(2));
  if (opts.help) { printHelp(); exit(0); }

  let xml, fileName;
  if (opts.stdin) {
    xml = await readStdin();
    fileName = '<stdin>';
  } else if (opts.input) {
    xml = readFileSync(opts.input, 'utf-8');
    fileName = basename(opts.input);
  } else {
    printHelp();
    exit(2);
  }

  const result = summarize(xml, { fileName });
  const json = JSON.stringify(result, null, 2);
  if (opts.out) {
    writeFileSync(opts.out, json);
    console.error(
      `[summarize] wrote ${opts.out}  ` +
      `events=${result.events.length}  specAct=${result.specialActions.length}  ` +
      `sides=${result.sides.length}  missions=${result.missions.length}  ` +
      `rps=${result.referencePoints.length}  zones=${result.zones.length}  ` +
      `units=${result.activeUnits.length}/${result.unitCounts.total}  ` +
      `warns=${result.warnings.length}`,
    );
  } else {
    console.log(json);
  }
}

const isCli = import.meta.url === `file://${process.argv[1].replace(/\\/g, '/')}`
           || import.meta.url.endsWith(process.argv[1].replace(/\\/g, '/').split('/').pop());
if (isCli) {
  main().catch((err) => {
    console.error('[summarize] error:', err.message);
    exit(1);
  });
}
