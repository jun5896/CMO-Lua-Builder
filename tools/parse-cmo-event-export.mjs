#!/usr/bin/env node
/**
 * parse-cmo-event-export.mjs
 *
 * Claude Task 1 (codex-assigned 2026-05-02).
 * Spec: handoff/to-codex/Task-1/backend-event-import-contract.md (this repo)
 *       and ~/.codex/cmo-lua-ui/handoff/to-claude/2026-05-02-task-1-event-export-parser.md (codex side)
 *
 * Parses CMO engine-exported event/Lua text into the JSON contract codex defined.
 * Tolerant of imperfect input; preserves unknowns under `raw`; never decodes
 * `.scen` Scenario_Compressed payloads.
 *
 * Inputs handled:
 *   - Tool_DumpEvents() XML/text output
 *   - Pasted Lua-Console text from ScenEdit_GetEvent(...) / similar
 *   - Mixed pasted text (best-effort)
 *
 * Usage:
 *   node parse-cmo-event-export.mjs "input.txt" --out "out.json"
 *   node parse-cmo-event-export.mjs --stdin --type toolDumpEvents > out.json
 *   Get-Content input.txt | node parse-cmo-event-export.mjs --stdin
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { argv, exit, stdin } from 'node:process';
import { basename } from 'node:path';

// -----------------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------------

const API_PATTERN = /\b(?:ScenEdit|VP|Tool|World|Command|SE)_[A-Za-z][A-Za-z0-9_]*/g;

const TRIGGER_TYPES = [
  'UnitDestroyed', 'UnitDamaged', 'UnitDetected', 'UnitEntersArea',
  'UnitRemainsInArea', 'RegularTime', 'Time', 'ScenLoaded',
  'ScenHasStarted', 'Points', 'Random', 'LuaScript',
];
const ACTION_TYPES = [
  'LuaScript', 'Message', 'Points', 'EndScenario', 'TeleportInArea',
  'ChangeMissionStatus', 'ChangeSidePosture',
];

const VALID_SOURCE_TYPES = new Set([
  'toolDumpEvents', 'scenEditGetEvent', 'pastedLuaConsole', 'mixed', 'unknown',
]);

// -----------------------------------------------------------------------------
// Type detection
// -----------------------------------------------------------------------------

function detectSourceType(text) {
  if (!text || !text.trim()) return 'unknown';
  const head = text.slice(0, 2000);

  // XML-like Tool_DumpEvents output (real CMO format observed 2026-05-02)
  if (/<\s*(EventTriggers|EventConditions|EventActions|SimEvents|SpecialActions)\b/i.test(head)
      || /<\s*Event(Trigger|Condition|Action)_[A-Za-z]+/i.test(head)
      || /<\s*Event\b|<\s*Trigger\b|<\s*Action\b|<\s*Condition\b/i.test(head)) {
    return 'toolDumpEvents';
  }

  // Strip Lua line comments to look at "real" content
  const stripped = text.replace(/^\s*--[^\n]*$/gm, '').trim();
  const sHead = stripped.slice(0, 2000);

  // Strong signal: ScenEdit_SetEvent calls (canonical event-setup output)
  if (/\bScenEdit_Set(Event|Trigger|Action|Condition|EventTrigger|EventAction|EventCondition)\s*\(/.test(sHead)) {
    return 'pastedLuaConsole';
  }

  // Lua-table dump from ScenEdit_GetEvent: top-level `{` with triggers/actions keys
  if (/^\s*\{[\s\S]*\bname\s*=/.test(sHead)
      && /\b(triggers|actions|conditions)\s*=\s*\{/.test(sHead)) {
    return 'scenEditGetEvent';
  }

  // Some lua source / console echo
  if (/\bScenEdit_|\bVP_|\bTool_/.test(sHead)) {
    return 'pastedLuaConsole';
  }

  return 'unknown';
}

// -----------------------------------------------------------------------------
// Helper: collect APIs / object hints / lua bodies
// -----------------------------------------------------------------------------

function collectApis(text) {
  return [...new Set((text.match(API_PATTERN) || []))].sort();
}

function collectStringsByKey(text, keyRe) {
  // Extract values after `key = "..."` or `key='...'`. Returns deduped list.
  const out = new Set();
  const re = new RegExp(`\\b(?:${keyRe})\\s*=\\s*['"]([^'"]+)['"]`, 'g');
  let m;
  while ((m = re.exec(text)) !== null) out.add(m[1]);
  return [...out];
}

function collectObjectContext(text) {
  return {
    sides:           collectStringsByKey(text, 'side|Side|playerside'),
    missions:        collectStringsByKey(text, 'mission|Mission|MissionName'),
    units:           collectStringsByKey(text, 'unit|UnitName|unitname'),
    referencePoints: collectStringsByKey(text, 'rp|RP|ReferencePoint|refpoint'),
    zones:           collectStringsByKey(text, 'zone|Zone|ZoneName'),
    specialActions:  collectStringsByKey(text, 'specialAction|SpecialAction'),
    luaFiles:        collectStringsByKey(text, 'scriptfile|file|lua_file|luaFile')
                       .filter(s => /\.lua\b/i.test(s)),
  };
}

function extractLuaBodies(text) {
  // Pull out long-bracket Lua blocks (...[==[ ... ]==]...) and quoted scripts
  const out = [];

  // long bracket: [=[...]=]  /  [==[...]==]  /  [[...]]
  const longBracket = /\[(=*)\[([\s\S]*?)\]\1\]/g;
  let m;
  while ((m = longBracket.exec(text)) !== null) {
    const body = m[2].trim();
    if (body && /[\n\r]/.test(body) && body.length > 8) out.push(body);
  }

  // scripttext = "...."  (double-quoted, may have escaped newlines)
  const quoted = /\bscripttext\s*=\s*"((?:[^"\\]|\\.)*)"/g;
  while ((m = quoted.exec(text)) !== null) {
    let body = m[1].replace(/\\n/g, '\n').replace(/\\"/g, '"').trim();
    if (body && body.length > 4) out.push(body);
  }

  // <ScriptText>...</ScriptText>  (XML form from Tool_DumpEvents)
  const xmlScript = /<ScriptText\s*>([\s\S]*?)<\/ScriptText\s*>/gi;
  while ((m = xmlScript.exec(text)) !== null) {
    const body = m[1].trim();
    if (body && body.length > 4) out.push(body);
  }

  return [...new Set(out)];
}

// -----------------------------------------------------------------------------
// Tool_DumpEvents XML parser (real CMO format, calibrated 2026-05-02)
//
// Model:
//   <EventTriggers>    pool of <EventTrigger_<TYPE>> elements, ID-keyed
//   <EventConditions>  pool of <EventCondition_<TYPE>> elements, ID-keyed
//   <EventActions>     pool of <EventAction_<TYPE>> elements, ID-keyed
//   <SimEvents>        list of <SimEvent>; each holds <Description> (event name)
//                       and <Triggers>/<Conditions>/<Actions> with <Trigger>ID</>
//                       text references that resolve into the pools.
//   <SpecialActions>   independent top-level — not bound to SimEvents.
//
// Each pool entry: { id, name (=Description), type (=tag suffix), raw, luaScript? }
// -----------------------------------------------------------------------------

function tagText(block, name) {
  const m = block.match(new RegExp(`<${name}\\s*>([\\s\\S]*?)</${name}\\s*>`, 'i'));
  return m ? m[1].trim() : undefined;
}

function decodeXmlEntities(s) {
  if (!s) return s;
  return String(s)
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&amp;/g, '&'); // last (avoids double-decoding)
}

function buildXmlPool(text, prefix, isAction = false) {
  // Find all <prefix<TYPE>>...</prefix<TYPE>> elements anywhere in the text.
  // The "type" is the suffix after `prefix`. The pool key is <ID>text</ID>.
  const pool = new Map();
  const re = new RegExp(
    `<(${prefix}[A-Za-z0-9_]+)\\b[^>]*>([\\s\\S]*?)</\\1\\s*>`,
    'g',
  );
  let m;
  while ((m = re.exec(text)) !== null) {
    const tagName = m[1];
    const inner = m[2];
    const id = tagText(inner, 'ID');
    if (!id) continue;
    const description = tagText(inner, 'Description');
    const type = tagName.slice(prefix.length);
    const entry = {
      id,
      name: description ? decodeXmlEntities(description) : '',
      type,
      raw: m[0],
    };
    if (isAction && type === 'LuaScript') {
      const body = tagText(inner, 'ScriptText');
      if (body) entry.luaScript = decodeXmlEntities(body);
    }
    if (type === 'LuaScript' && !isAction) {
      // Conditions also have ScriptText
      const body = tagText(inner, 'ScriptText');
      if (body) entry.luaScript = decodeXmlEntities(body);
    }
    pool.set(id, entry);
  }
  return pool;
}

function collectXmlRefs(simEventInner, containerTag, itemTag, pool, warnings) {
  // <Triggers><Trigger>ID</Trigger>...</Triggers>   -- normal
  // <Triggers />                                      -- empty (self-close)
  const out = [];
  // Detect self-closing form
  if (new RegExp(`<${containerTag}\\s*/>`, 'i').test(simEventInner)) {
    return out;
  }
  const containerRe = new RegExp(
    `<${containerTag}\\s*>([\\s\\S]*?)</${containerTag}\\s*>`,
    'i',
  );
  const cm = simEventInner.match(containerRe);
  if (!cm) return out;
  const itemRe = new RegExp(`<${itemTag}\\s*>([^<]+)</${itemTag}\\s*>`, 'g');
  let m;
  while ((m = itemRe.exec(cm[1])) !== null) {
    const id = m[1].trim();
    const entry = pool.get(id);
    if (entry) {
      out.push({
        name:      entry.name,
        type:      entry.type,
        raw:       entry.raw,
        ...(entry.luaScript ? { luaScript: entry.luaScript } : {}),
      });
    } else {
      out.push({ name: '', type: '', raw: `<${itemTag}>${id}</${itemTag}>`, _unresolved: true });
      warnings.push(`SimEvent referenced unknown ${itemTag} ID ${id}`);
    }
  }
  return out;
}

function parseXmlSpecialActions(text) {
  const out = [];
  const re = /<SpecialAction\b[^>]*>([\s\S]*?)<\/SpecialAction\s*>/g;
  let m;
  while ((m = re.exec(text)) !== null) {
    const inner = m[1];
    const sa = {
      id:           tagText(inner, 'ID'),
      name:         tagText(inner, 'Name') || '',
      description:  decodeXmlEntities(tagText(inner, 'Description') || ''),
      isActive:     parseBool(tagText(inner, 'IsActive'), true),
      isRepeatable: parseBool(tagText(inner, 'IsRepeatable'), false),
      luaScript:    decodeXmlEntities(tagText(inner, 'ScriptText') || ''),
    };
    out.push(sa);
  }
  return out;
}

function parseXmlEvents(text, warnings) {
  // Build the three pools
  const triggerPool   = buildXmlPool(text, 'EventTrigger_');
  const conditionPool = buildXmlPool(text, 'EventCondition_');
  const actionPool    = buildXmlPool(text, 'EventAction_', /*isAction*/ true);

  // Walk SimEvents and resolve references
  const events = [];
  const reSim = /<SimEvent\b[^>]*>([\s\S]*?)<\/SimEvent\s*>/g;
  let m;
  while ((m = reSim.exec(text)) !== null) {
    const inner = m[1];
    const triggers   = collectXmlRefs(inner, 'Triggers',   'Trigger',   triggerPool,   warnings);
    const conditions = collectXmlRefs(inner, 'Conditions', 'Condition', conditionPool, warnings);
    const actions    = collectXmlRefs(inner, 'Actions',    'Action',    actionPool,    warnings);

    const luaScripts = [];
    for (const a of actions) {
      if (a.luaScript) luaScripts.push(a.luaScript);
    }

    events.push({
      name:         tagText(inner, 'Description') || 'unnamed',
      isActive:     parseBool(tagText(inner, 'IsActive'), true),
      isRepeatable: parseBool(tagText(inner, 'IsRepeatable'), false),
      probability:  parseInt(tagText(inner, 'Probability') || '100', 10),
      triggers,
      conditions,
      actions,
      luaScripts: [...new Set(luaScripts)],
    });
  }

  // Backward-compat: if real-format containers were absent but legacy <Event>
  // blocks exist, fall through to a simple legacy parse.
  if (events.length === 0
      && /<EventTriggers\b|<EventActions\b|<EventConditions\b|<SimEvents\b/.test(text) === false
      && /<Event\b/.test(text)) {
    return parseXmlEventsLegacy(text, warnings);
  }

  if (events.length === 0) {
    warnings.push('toolDumpEvents: no <SimEvent> blocks found');
  }
  return events;
}

// Legacy hypothetical-shape parser, kept for backward compatibility with
// fixture-01-tool-dump-events-HYPOTHETICAL.xml.
function parseXmlEventsLegacy(text, warnings) {
  const events = [];
  const eventBlocks = text.match(/<Event\b[\s\S]*?<\/Event\s*>/gi) || [];
  for (const block of eventBlocks) {
    events.push({
      name:         attrLegacy(block, 'Name') || tagText(block, 'Name') || 'unnamed',
      description:  attrLegacy(block, 'Description') || tagText(block, 'Description') || undefined,
      isActive:     parseBool(attrLegacy(block, 'IsActive') || tagText(block, 'IsActive'), true),
      isRepeatable: parseBool(attrLegacy(block, 'IsRepeatable') || tagText(block, 'IsRepeatable'), false),
      probability:  parseInt(attrLegacy(block, 'Probability') || tagText(block, 'Probability') || '100', 10),
      triggers:     extractChildrenLegacy(block, 'Trigger'),
      conditions:   extractChildrenLegacy(block, 'Condition'),
      actions:      extractChildrenLegacy(block, 'Action'),
      luaScripts:   extractLuaBodies(block),
    });
  }
  return events;
}

function attrLegacy(block, name) {
  const m = block.match(new RegExp(`\\b${name}\\s*=\\s*"([^"]*)"`, 'i'));
  return m ? m[1] : undefined;
}

function extractChildrenLegacy(block, kind) {
  const re = new RegExp(`<${kind}\\b[\\s\\S]*?</${kind}\\s*>`, 'gi');
  const out = [];
  const matches = block.match(re) || [];
  for (const m of matches) {
    out.push({
      name: attrLegacy(m, 'Name') || tagText(m, 'Name') || '',
      type: attrLegacy(m, 'Type') || tagText(m, 'Type') || '',
      raw:  m.trim(),
    });
  }
  return out;
}

function parseBool(s, fallback) {
  if (s == null) return fallback;
  const t = String(s).trim().toLowerCase();
  if (t === 'true' || t === '1' || t === 'yes') return true;
  if (t === 'false' || t === '0' || t === 'no') return false;
  return fallback;
}

// -----------------------------------------------------------------------------
// ScenEdit_GetEvent table-dump parser (best-effort)
// -----------------------------------------------------------------------------
//
// Format example (one event as a Lua table):
//   { name = "MyEvent", isActive = true, isRepeatable = false, probability = 100,
//     triggers = { { name = "trg1", type = "UnitDestroyed", ... }, ... },
//     conditions = { ... },
//     actions = { { name = "act1", type = "LuaScript", scripttext = [==[...]==] }, ... },
//   }
// This is a fuzzy parser, not a full Lua parser.

function parseLuaTableEvents(text, warnings) {
  const events = [];

  // Find each top-level event-like table by sniffing for `name = "..."` adjacent to
  // `triggers = {` or `actions = {`.
  const candidates = sliceByEventStart(text);
  for (const slice of candidates) {
    const evt = {
      name:         luaScalar(slice, 'name') || 'unnamed',
      description:  luaScalar(slice, 'description'),
      isActive:     parseBool(luaScalar(slice, 'isActive'), true),
      isRepeatable: parseBool(luaScalar(slice, 'isRepeatable'), false),
      probability:  parseInt(luaScalar(slice, 'probability') || '100', 10),
      triggers:     parseLuaSubtableArray(slice, 'triggers', 'UnitDestroyed'),
      conditions:   parseLuaSubtableArray(slice, 'conditions', 'LuaScript'),
      actions:      parseLuaSubtableArray(slice, 'actions', 'LuaScript'),
      luaScripts:   extractLuaBodies(slice),
    };
    events.push(evt);
  }

  if (candidates.length === 0) {
    warnings.push('scenEditGetEvent: no event tables identified — input may be malformed');
  }
  return events;
}

function sliceByEventStart(text) {
  // Find top-level event tables.
  // Strategy: find each `name = "..."` that is followed within ~4000 chars by
  // `triggers = {` etc., slice from prior `{` to its matching `}`. Then drop
  // any slice that is fully contained inside another (those are sub-tables).
  const candidates = [];
  const seen = new Set();
  const re = /name\s*=\s*['"][^'"]+['"]/g;
  let m;
  while ((m = re.exec(text)) !== null) {
    const lookahead = text.slice(m.index, m.index + 4000);
    if (!/\b(triggers|actions|conditions)\s*=\s*\{/.test(lookahead)) continue;
    const start = findOpenBrace(text, m.index);
    if (start < 0) continue;
    const end = findMatchingBrace(text, start);
    if (end < 0) continue;
    if (seen.has(start)) continue;
    seen.add(start);
    candidates.push({ start, end, slice: text.slice(start, end + 1) });
  }

  // Drop slices whose [start, end] range is strictly inside another slice's range.
  const top = candidates.filter(c =>
    !candidates.some(other =>
      other !== c && other.start < c.start && other.end > c.end
    )
  );
  return top.map(c => c.slice);
}

function findOpenBrace(text, fromPos) {
  for (let i = fromPos; i >= 0 && i > fromPos - 1500; i--) {
    if (text[i] === '{') return i;
  }
  return -1;
}

function findMatchingBrace(text, openIdx) {
  let depth = 0;
  for (let i = openIdx; i < text.length; i++) {
    const c = text[i];
    if (c === '{') depth++;
    else if (c === '}') {
      depth--;
      if (depth === 0) return i;
    }
  }
  return -1;
}

function luaScalar(text, key) {
  // Match `key = "..."` or `key = '..'` or `key = true|false|number`
  const reStr = new RegExp(`\\b${key}\\s*=\\s*['"]([^'"]+)['"]`);
  const reBool = new RegExp(`\\b${key}\\s*=\\s*(true|false)\\b`, 'i');
  const reNum = new RegExp(`\\b${key}\\s*=\\s*(-?\\d+(?:\\.\\d+)?)`);
  let m = text.match(reStr);
  if (m) return m[1];
  m = text.match(reBool);
  if (m) return m[1].toLowerCase();
  m = text.match(reNum);
  if (m) return m[1];
  return undefined;
}

function parseLuaSubtableArray(text, key, typeFallback) {
  // Find `<key> = { ... }` and collect each inner `{ ... }` as a child entry.
  const re = new RegExp(`\\b${key}\\s*=\\s*\\{`);
  const m = text.match(re);
  if (!m) return [];
  const start = text.indexOf('{', m.index + m[0].length - 1);
  const end = findMatchingBrace(text, start);
  if (end < 0) return [];
  const block = text.slice(start + 1, end);

  const out = [];
  let i = 0;
  while (i < block.length) {
    while (i < block.length && block[i] !== '{') i++;
    if (i >= block.length) break;
    const subEnd = findMatchingBrace(block, i);
    if (subEnd < 0) break;
    const child = block.slice(i, subEnd + 1);
    out.push({
      name: luaScalar(child, 'name') || '',
      type: luaScalar(child, 'type') || typeFallback,
      raw:  child.trim(),
      luaScript: extractLuaBodies(child)[0] || undefined,
    });
    i = subEnd + 1;
  }
  return out;
}

// -----------------------------------------------------------------------------
// Lua-Console fallback: scan ScenEdit_SetEvent + SetTrigger + SetAction calls
// -----------------------------------------------------------------------------

function parseLuaConsoleEvents(text, warnings) {
  const events = new Map(); // name -> event obj

  // ScenEdit_SetEvent("name", { ... })  — use balanced-brace match
  const setEventRe = /ScenEdit_SetEvent\s*\(\s*['"]([^'"]+)['"]\s*,\s*\{/g;
  let m;
  while ((m = setEventRe.exec(text)) !== null) {
    const name = m[1];
    const startBrace = m.index + m[0].length - 1;
    const endBrace = findMatchingBrace(text, startBrace);
    if (endBrace < 0) continue;
    const body = text.slice(startBrace, endBrace + 1);
    if (!events.has(name)) events.set(name, {
      name,
      description:  luaScalar(body, 'description'),
      isActive:     parseBool(luaScalar(body, 'isactive') || luaScalar(body, 'isActive'), true),
      isRepeatable: parseBool(luaScalar(body, 'isrepeatable') || luaScalar(body, 'isRepeatable'), false),
      probability:  parseInt(luaScalar(body, 'probability') || '100', 10),
      triggers:     [],
      conditions:   [],
      actions:      [],
      luaScripts:   [],
    });
  }

  // First, harvest item definitions (trigger/cond/action) into name-keyed pools.
  const triggerPool   = harvestSetCallPool(text, 'SetTrigger',   'UnitDestroyed');
  const conditionPool = harvestSetCallPool(text, 'SetCondition', 'LuaScript');
  const actionPool    = harvestSetCallPool(text, 'SetAction',    'LuaScript', /*isAction*/true);

  // Then resolve event ↔ item linkage via SetEventTrigger / SetEventCondition /
  // SetEventAction calls. These are the AUTHORITATIVE link in CMO Lua.
  linkPoolToEvents(text, 'SetEventTrigger',   triggerPool,   events, 'triggers');
  linkPoolToEvents(text, 'SetEventCondition', conditionPool, events, 'conditions');
  linkPoolToEvents(text, 'SetEventAction',    actionPool,    events, 'actions');

  // Any items that never got linked: park them in an `unattached` event so they
  // aren't silently dropped (with a warning).
  const unattached = {
    name: '_unattached_', isActive: true, isRepeatable: false, probability: 100,
    triggers: [], conditions: [], actions: [], luaScripts: [],
    _synthetic: true,
  };
  for (const [name, item] of triggerPool)   if (!item._linked) unattached.triggers.push(item);
  for (const [name, item] of conditionPool) if (!item._linked) unattached.conditions.push(item);
  for (const [name, item] of actionPool)    if (!item._linked) unattached.actions.push(item);
  if (unattached.triggers.length || unattached.conditions.length || unattached.actions.length) {
    events.set('_unattached_', unattached);
    warnings.push(`pastedLuaConsole: ${unattached.triggers.length}T/${unattached.conditions.length}C/${unattached.actions.length}A items had no SetEvent<X> link — parked in _unattached_`);
  }

  // Pull luaScripts from each event's actions
  for (const evt of events.values()) {
    const bodies = [];
    for (const act of evt.actions) {
      if (act.luaScript) bodies.push(act.luaScript);
    }
    evt.luaScripts = bodies;
  }

  if (events.size === 0) {
    warnings.push('pastedLuaConsole: no ScenEdit_SetEvent calls detected');
  }
  // Strip the marker before returning
  return [...events.values()].map(({ _synthetic, ...e }) => e);
}

function harvestSetCallPool(text, fnName, typeFallback, isAction = false) {
  const pool = new Map();  // name -> item
  // Balanced-brace match to handle nested tables / [==[...]==] Lua blocks
  const re = new RegExp(`ScenEdit_${fnName}\\s*\\(\\s*\\{`, 'g');
  let m;
  while ((m = re.exec(text)) !== null) {
    const startBrace = m.index + m[0].length - 1;
    const endBrace = findMatchingBrace(text, startBrace);
    if (endBrace < 0) continue;
    const body = text.slice(startBrace, endBrace + 1);
    const name = luaScalar(body, 'name') || '';
    if (!name) continue;
    const item = {
      name,
      type: luaScalar(body, 'type') || typeFallback,
      raw:  body.trim(),
      _linked: false,
    };
    if (isAction && item.type === 'LuaScript') {
      item.luaScript = luaScalar(body, 'scripttext') || extractLuaBodies(body)[0];
    }
    pool.set(name, item);
  }
  return pool;
}

function linkPoolToEvents(text, fnName, pool, events, bucket) {
  // ScenEdit_SetEventTrigger("evt", { mode='add', name='trg' })  — balanced brace
  const re = new RegExp(
    `ScenEdit_${fnName}\\s*\\(\\s*['"]([^'"]+)['"]\\s*,\\s*\\{`,
    'g',
  );
  let m;
  while ((m = re.exec(text)) !== null) {
    const evtName = m[1];
    const startBrace = m.index + m[0].length - 1;
    const endBrace = findMatchingBrace(text, startBrace);
    if (endBrace < 0) continue;
    const body = text.slice(startBrace, endBrace + 1);
    const itemName = luaScalar(body, 'name');
    if (!itemName) continue;
    if (!events.has(evtName)) {
      // Event referenced but not yet declared via SetEvent — auto-create stub
      events.set(evtName, {
        name: evtName, isActive: true, isRepeatable: false, probability: 100,
        triggers: [], conditions: [], actions: [], luaScripts: [],
      });
    }
    const item = pool.get(itemName);
    if (item) {
      item._linked = true;
      // Strip internal marker before pushing
      const { _linked, ...clean } = item;
      events.get(evtName)[bucket].push(clean);
    }
  }
}

// -----------------------------------------------------------------------------
// Top-level parse
// -----------------------------------------------------------------------------

export function parse(text, opts = {}) {
  const warnings = [];
  const explicitType = opts.type && VALID_SOURCE_TYPES.has(opts.type) ? opts.type : null;
  const type = explicitType || detectSourceType(text);

  let events = [];
  if (type === 'toolDumpEvents') {
    events = parseXmlEvents(text, warnings);
  } else if (type === 'scenEditGetEvent') {
    events = parseLuaTableEvents(text, warnings);
  } else if (type === 'pastedLuaConsole') {
    events = parseLuaConsoleEvents(text, warnings);
  } else {
    // 'mixed' or 'unknown': try all, dedupe by name
    const combined = [
      ...parseXmlEvents(text, []),
      ...parseLuaTableEvents(text, []),
      ...parseLuaConsoleEvents(text, []),
    ];
    const byName = new Map();
    for (const e of combined) {
      if (!byName.has(e.name)) byName.set(e.name, e);
    }
    events = [...byName.values()];
    if (events.length === 0) {
      warnings.push('Input type unrecognized; no events extracted');
    } else {
      warnings.push(`Mixed-mode parse: combined output from multiple parsers (${combined.length} → ${events.length} after dedupe)`);
    }
  }

  // Best-effort scenario hints from text
  const scenario = {
    title:     scanFirst(text, /\bScenarioTitle\b\s*[=:]\s*["']([^"']+)["']/i),
    dbVersion: scanFirst(text, /\bDB(?:Version)?\b\s*[=:]\s*["']?([A-Z0-9_.]+)/i),
    build:     scanFirst(text, /\b[Bb]uild\b\s*[=:]\s*["']?(\d+(?:\.\d+)?)/),
  };
  if (!scenario.title) delete scenario.title;
  if (!scenario.dbVersion) delete scenario.dbVersion;
  if (!scenario.build) delete scenario.build;

  // SpecialActions are extracted separately (real CMO XML keeps them outside
  // events; legacy/lua-table sources don't have them).
  let specialActions = [];
  if (type === 'toolDumpEvents'
      || /<SpecialAction\b/.test(text.slice(0, 4000)) || /<SpecialActions\b/.test(text)) {
    specialActions = parseXmlSpecialActions(text);
  }

  // Merge SpecialAction names into objectContext.specialActions for codex
  // contract compatibility.
  const objectContext = collectObjectContext(text);
  if (specialActions.length) {
    const names = new Set(objectContext.specialActions);
    for (const sa of specialActions) {
      if (sa.name) names.add(sa.name);
    }
    objectContext.specialActions = [...names];
  }

  return {
    source: {
      type,
      fileName: opts.fileName,
      parsedAt: new Date().toISOString(),
    },
    scenario,
    events,
    specialActions,           // contract extension: full SpecialAction objects
    objectContext,
    detectedApis:  collectApis(text),
    warnings,
  };
}

function scanFirst(text, re) {
  const m = text.match(re);
  return m ? m[1] : undefined;
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
  const opts = { stdin: false, type: null, out: null, input: null };
  let i = 0;
  while (i < args.length) {
    const a = args[i];
    if (a === '--stdin') { opts.stdin = true; i++; }
    else if (a === '--type') { opts.type = args[++i]; i++; }
    else if (a === '--out')  { opts.out  = args[++i]; i++; }
    else if (a === '-h' || a === '--help') { opts.help = true; i++; }
    else if (!a.startsWith('--')) { opts.input = a; i++; }
    else { i++; }
  }
  return opts;
}

function printHelp() {
  console.log(`parse-cmo-event-export.mjs

Usage:
  node parse-cmo-event-export.mjs <input.txt> [--out <out.json>] [--type <t>]
  node parse-cmo-event-export.mjs --stdin [--type <t>]
  cat input.txt | node parse-cmo-event-export.mjs --stdin

Types: toolDumpEvents | scenEditGetEvent | pastedLuaConsole | mixed
       (auto-detect if omitted)

Output: JSON object on stdout, or written to --out path.
`);
}

async function main() {
  const opts = parseCliArgs(argv.slice(2));
  if (opts.help) { printHelp(); exit(0); }

  let text, fileName;
  if (opts.stdin) {
    text = await readStdin();
    fileName = '<stdin>';
  } else if (opts.input) {
    text = readFileSync(opts.input, 'utf-8');
    fileName = basename(opts.input);
  } else {
    printHelp();
    exit(2);
  }

  const result = parse(text, { type: opts.type, fileName });
  const json = JSON.stringify(result, null, 2);
  if (opts.out) {
    writeFileSync(opts.out, json);
    console.error(`[parser] wrote ${opts.out}  events=${result.events.length}  warnings=${result.warnings.length}`);
  } else {
    console.log(json);
  }
}

// Run only when invoked directly (not when imported)
if (import.meta.url === `file://${process.argv[1].replace(/\\/g, '/')}`
    || import.meta.url.endsWith(process.argv[1].replace(/\\/g, '/').split('/').pop())) {
  main().catch((err) => {
    console.error('[parser] error:', err.message);
    exit(1);
  });
}
