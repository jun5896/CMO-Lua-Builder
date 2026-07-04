const CONTEXT_PACK_HEADING = '## Context Pack / Pruning Audit';
const SECRET_PATTERN = /\bBearer\s+[A-Za-z0-9._-]+|\bsk-[A-Za-z0-9_-]{8,}/;
const GUID_PATTERN = /\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b/gi;
const DBID_LINE_PATTERN = /^- (?:DB\/Loadout IDs in Lua|Combined DB\/Loadout IDs): ([^\n]*)$/gm;
const TOKEN_WARN_LIMIT = 12000;
const TOKEN_HARD_LIMIT = 30000;

function lines(value) {
  return String(value || '').split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
}

function detectIntent({ source, intent = {}, engineFeedback = '' }) {
  const actionType = intent.actionType || '';
  const hint = `${intent.summary || ''} ${intent.actionDetail || ''}`.toLowerCase();

  if (String(engineFeedback || '').trim()) return 'validationDebug';
  if (actionType === 'mission_assign' || actionType === 'mission_toggle') return 'missionAssignment';
  if (actionType === 'loadout_scramble') return 'dbidLoadout';
  if (actionType === 'zone_toggle') return 'referencePointZone';
  if (/spawn|addunit|unit spawn/.test(hint)) return 'unitSpawnOrEdit';
  if (/doctrine|emcon/.test(hint)) return 'doctrineEmcon';
  return String(source || '').trim() ? 'luaRepair' : 'generalAskBack';
}

function plannedOmissions(intentName) {
  return {
    luaRepair: 'u,mis,db',
    missionAssignment: 'rp,tpl,sides',
    dbidLoadout: 'mis,lua,rp',
    validationDebug: 'tpl,obj',
    referencePointZone: 'db,lua',
    unitSpawnOrEdit: 'mis,events',
    doctrineEmcon: 'rp,db',
  }[intentName] || 'obj,lua';
}

function estimateTokens(value) {
  return Math.ceil(String(value || '').length / 4);
}

function uniqueValues(values) {
  return [...new Set((values || []).map((value) => String(value || '').trim()).filter(Boolean))];
}

function uniquePush(target, value) {
  if (value && !target.includes(value)) target.push(value);
}

function replaceSection(prompt, heading, replacement) {
  const text = String(prompt || '');
  const start = text.indexOf(heading);
  if (start < 0) return [text, false];

  const next = text.indexOf('\n## ', start + 1);
  const end = next < 0 ? text.length : next;
  return [`${text.slice(0, start)}${replacement}${text.slice(end)}`, true];
}

function buildLuaBundleSummary(context) {
  const luaFiles = Array.isArray(context.luaFiles) ? context.luaFiles : [];
  if (luaFiles.length <= 1) return null;

  const totalLines = luaFiles.reduce((sum, file) => sum + (file?.analysis?.lineCount || 0), 0);
  const totalChars = luaFiles.reduce((sum, file) => sum + (file?.analysis?.charCount || 0), 0);
  const topApis = uniqueValues(luaFiles.flatMap((file) => file?.analysis?.apis || [])).slice(0, 12);
  const fileRows = luaFiles.slice(0, 18).map((file) => {
    const apis = (file?.analysis?.apis || []).slice(0, 5).join(', ') || 'none';
    return `- ${file?.path || 'Lua'}: L${file?.analysis?.lineCount || 0}, C${file?.analysis?.charCount || 0}, APIs ${apis}`;
  });
  const omittedCount = Math.max(0, luaFiles.length - fileRows.length);

  return [
    '## Lua File Bundle Context',
    '- pruned: non-active.',
    `- Files: ${luaFiles.length}`,
    `- Lines: ${totalLines}`,
    `- Chars: ${totalChars}`,
    `- APIs: ${topApis.join(', ') || 'none'}`,
    '',
    '### Files',
    ...fileRows,
    omittedCount ? `- ... ${omittedCount} more omitted.` : '',
  ].filter(Boolean).join('\n');
}

function compactLongHintLines(prompt, decisions) {
  let nextPrompt = String(prompt || '');

  nextPrompt = nextPrompt.replace(
    /^- (Combined APIs|APIs|Combined event helpers|Event helpers|Combined trigger hints|Trigger hints): ([^\n]*)$/gm,
    (match, label, value) => {
      const items = value.split(',').map((item) => item.trim()).filter(Boolean);
      if (items.length <= 10) return match;
      decisions.summarized.push(label.includes('API') ? 'analysis.apiCalls.top10' : label.includes('event') ? 'analysis.eventCalls.top10' : 'analysis.triggerHints.top10');
      return `- ${label}: ${items.slice(0, 10).join(', ')} ... (+${items.length - 10} more)`;
    },
  );

  return nextPrompt;
}

function objectItemNeedles(item) {
  const text = String(item || '').trim();
  const short = text.split(/[[(]/)[0].trim();
  const afterColon = short.split(':').pop().trim();
  return uniqueValues([text, short, afterColon]).filter((value) => value.length >= 3);
}

function isObjectItemReferenced(item, referenceText) {
  const haystack = String(referenceText || '').toLowerCase();
  if (!haystack) return false;
  return objectItemNeedles(item).some((needle) => haystack.includes(needle.toLowerCase()));
}

function compactObjectListLines(prompt, context, decisions) {
  const intent = context.intent || {};
  const referenceText = [
    context.source,
    context.engineFeedback,
    intent.summary,
    intent.triggerDetail,
    intent.condition,
    intent.actionDetail,
    intent.eventName,
    intent.playerSide,
  ].filter(Boolean).join('\n');
  const objectRules = {
    Sides: [12, 'objects.sides.list'],
    'Units / GUIDs': [10, 'objects.units.list'],
    Missions: [10, 'objects.missions.list'],
    'Reference Points': [5, 'objects.referencePoints.list'],
    Zones: [20, 'objects.zones.list'],
    Events: [10, 'objects.events.list'],
    'Special Actions': [10, 'objects.specialActions.list'],
    'Lua files': [3, 'objects.luaFiles.list'],
  };

  return String(prompt || '').replace(
    /^- (Sides|Units \/ GUIDs|Missions|Reference Points|Zones|Events|Special Actions|Lua files): ([^\n]*)$/gm,
    (match, label, value) => {
      const rule = objectRules[label];
      const items = value.split(',').map((item) => item.trim()).filter(Boolean);
      if (!rule || items.length <= rule[0] || /^\(not provided\)$/i.test(value.trim())) return match;

      const matched = items.filter((item) => isObjectItemReferenced(item, referenceText));
      const keep = uniqueValues([...items.slice(0, rule[0]), ...matched]);
      const omittedCount = Math.max(0, items.length - keep.length);
      if (!omittedCount) return match;

      uniquePush(decisions.summarized, rule[1]);
      if (matched.length) uniquePush(decisions.preserved, `${rule[1]}.matched`);
      return `- ${label}: ${keep.join(', ')} ... (+${omittedCount} more; match)`;
    },
  );
}

function compactDetailLines(prompt, intentName, decisions) {
  let nextPrompt = String(prompt || '');
  const omit = (label, value, auditLabel) => {
    uniquePush(decisions.omitted, auditLabel);
    return `- ${label}: [${auditLabel} omitted:${value.length}]`;
  };

  if (intentName !== 'referencePointZone') {
    nextPrompt = nextPrompt.replace(
      /^- ((?:Reference point|RP) coordinates|Zone polygons|Zone polygon points): ([^\n]{220,})$/gm,
      (match, label, value) => omit(label, value, label[0] === 'Z' ? 'objects.zones.polygons' : 'objects.rp.coords'),
    );
  }
  if (intentName !== 'missionAssignment') {
    nextPrompt = nextPrompt.replace(
      /^- (Mission(?: full)? details?|Mission roster): ([^\n]{220,})$/gim,
      (match, label, value) => omit(label, value, 'objects.missions.detail'),
    );
  }
  if (!/missionAssignment|unitSpawnOrEdit|doctrineEmcon|validationDebug/.test(intentName)) {
    nextPrompt = nextPrompt.replace(
      /^- (Units?(?: full)? details?|Unit roster|Unit status|Unit loadout): ([^\n]{220,})$/gim,
      (match, label, value) => omit(label, value, 'objects.units.detail'),
    );
  }
  return nextPrompt;
}

function compactDbLines(prompt, intentName, decisions) {
  if (/unitSpawnOrEdit|dbidLoadout|validationDebug/.test(intentName)) return prompt;
  const nextPrompt = String(prompt || '').replace(/^- Notes: [^\n]+$/gm, () => (uniquePush(decisions.omitted, 'db.notes'), '- Notes: [db.notes]'));

  return nextPrompt.replace(
    /^- ((Weapon|Sensor|Mount|Platform) DBID|Loadout ID|Scenario unit GUID): \(not provided\)$/gm,
    (match, label, type) => {
      const audit = `db.${type ? type.toLowerCase() : label[0] === 'L' ? 'loadout' : 'unitGuid'}`;
      uniquePush(decisions.omitted, audit);
      return `- ${label}: [${audit}]`;
    },
  );
}

function buildAskBackHints(intentName, context, decisions, baseMissing) {
  const hints = [...(baseMissing || [])];
  const summarized = decisions?.summarized || [];
  const preserved = decisions?.preserved || [];
  const objectContext = context.objectContext || {};

  const add = (value) => uniquePush(hints, value);
  const hasSummary = (label) => summarized.includes(label);
  const hasMatched = (label) => preserved.includes(`${label}.matched`);
  const needs = (label) => hasSummary(label) && !hasMatched(label);

  if (needs('objects.units.list') && /missionAssignment|unitSpawnOrEdit|luaRepair|validationDebug/.test(intentName)) add('Unit name disambiguation');
  if (needs('objects.missions.list') && /missionAssignment|doctrineEmcon|validationDebug/.test(intentName)) add('Mission name');
  if (needs('objects.referencePoints.list') && intentName === 'referencePointZone') add('Reference point name');
  if (needs('objects.zones.list') && intentName === 'referencePointZone') add('Zone name');
  if (lines(objectContext.sides || '').length > 1 && !String(context.intent?.playerSide || '').trim() && intentName !== 'generalAskBack') add('Side name');

  if (intentName === 'unitSpawnOrEdit' && !context.databaseContext?.platformDbid) add('DBID');
  if (intentName === 'dbidLoadout' && !context.databaseContext?.loadoutId) add('Loadout ID');

  return uniqueValues(hints).slice(0, 8);
}

function omitBriefingLikeLines(prompt, decisions) {
  let nextPrompt = String(prompt || '');
  let touched = false;

  nextPrompt = nextPrompt.replace(
    /^- (Briefing|Description|Note): ([^\n]*)$/gim,
    (match, label, value) => {
      if (value.length < (label === 'Note' ? 320 : 180)) return match;
      touched = true;
      return `- ${label}: [scenario.briefing omitted:${value.length}]`;
    },
  );

  if (touched) decisions.omitted.push('scenario.briefing');
  return nextPrompt;
}

function extractPreservedIdentifiers(prompt) {
  const text = String(prompt || '');
  const dbids = [];
  for (const match of text.matchAll(DBID_LINE_PATTERN)) {
    dbids.push(...match[1].split(',').map((item) => item.trim()).filter(Boolean));
  }
  return {
    dbids: uniqueValues(dbids),
    guids: uniqueValues(text.match(GUID_PATTERN) || []),
  };
}

function identifiersStillPresent(before, after) {
  const afterText = String(after || '').toLowerCase();
  return before.dbids.every((item) => afterText.includes(item.toLowerCase()))
    && before.guids.every((item) => afterText.includes(item.toLowerCase()));
}

function requiredButMissing(intentName, context) {
  const objectContext = context.objectContext || {};
  const databaseContext = context.databaseContext || {};
  const missing = [
    ...((String(context.source || '').match(/<[^>\n]{2,48}>|TODO_|REPLACE_|INSERT_/gi) || []).slice(0, 3)),
    ...((context.previousAiBlockers || []).slice(0, 2)),
  ];

  if (intentName === 'missionAssignment') {
    if (!lines(objectContext.sides).length) missing.push('Side name');
    if (!lines(objectContext.missions).length) missing.push('Mission name');
  }

  if (intentName === 'dbidLoadout' || intentName === 'unitSpawnOrEdit') {
    if (!databaseContext.platformDbid) missing.push('Platform DBID');
    if (!databaseContext.loadoutId && intentName === 'dbidLoadout') missing.push('Loadout ID');
  }

  if (intentName === 'referencePointZone' && !lines(objectContext.referencePoints).length && !lines(objectContext.zones).length) {
    missing.push('RP or Zone name');
  }

  return [...new Set(missing)].slice(0, 6);
}

function buildAudit(prompt, context) {
  const intentName = detectIntent(context);
  const missing = uniqueValues([
    ...requiredButMissing(intentName, context),
    ...(context.askBackHints || []),
  ]).slice(0, 8);
  const planned = plannedOmissions(intentName);
  const estimatedTokens = estimateTokens(prompt);
  const decisions = context.decisions || {};
  const actualOmit = uniqueValues(decisions.omitted).join(',') || 'none';
  const summarized = uniqueValues(decisions.summarized);
  const pruningMode = actualOmit === 'none' && !summarized.length ? 'judge-only' : 'phase3';

  return [
    CONTEXT_PACK_HEADING,
    `- intent=${intentName} conf=${intentName === 'generalAskBack' ? 'low' : 'med'}`,
    `- actualOmit=${actualOmit} plannedOmit=${planned} pruning=${pruningMode}`,
    `- summaries=${summarized.join(',') || 'none'}`,
    `- missing=${missing.join(' | ') || 'none'} ask=${missing.length ? 'yes' : 'no'}`,
    `- tokens=${estimatedTokens}/${TOKEN_WARN_LIMIT} safety=system,headings,noKey,apply,copy,audit`,
  ].join('\n');
}

function replaceContextPack(prompt, audit) {
  const text = String(prompt || '');
  const start = text.indexOf(CONTEXT_PACK_HEADING);
  if (start < 0) return text;

  const next = text.indexOf('\n## ', start + CONTEXT_PACK_HEADING.length);
  if (next < 0) return `${text.slice(0, start)}${audit}`;
  return `${text.slice(0, start)}${audit}${text.slice(next)}`;
}

export function applyContextPruning(prompt, context = {}) {
  const text = String(prompt || '');
  const intentName = detectIntent(context);
  const decisions = { omitted: [], summarized: [], preserved: [] };
  const baseMissing = requiredButMissing(intentName, context);
  const preservedIdentifiers = extractPreservedIdentifiers(text);
  let nextPrompt = text;
  let hardBlock = '';

  if (!text.includes(CONTEXT_PACK_HEADING)) hardBlock = 'contextPackSectionMissing';
  if (SECRET_PATTERN.test(text)) hardBlock = 'rawSecretLikeText';
  if (
    !hardBlock
    && String(context.source || '').trim()
    && (intentName === 'luaRepair' || intentName === 'validationDebug')
    && !/## (Selected Lua File|Current Lua)\b/.test(text)
  ) {
    hardBlock = 'activeLuaRemovedForRepairIntent';
  }

  const bundleSummary = buildLuaBundleSummary(context);
  if (!hardBlock && bundleSummary && text.includes('## Lua File Bundle Context')) {
    const [bundlePrompt, replacedBundle] = replaceSection(nextPrompt, '## Lua File Bundle Context', bundleSummary);
    nextPrompt = bundlePrompt;
    if (replacedBundle) {
      decisions.omitted.push('nonActiveLuaFile.body');
      decisions.summarized.push('luaBundle.manifest');
      decisions.preserved.push('activeLuaSnippet');
    }
  }

  if (!hardBlock) {
    nextPrompt = compactLongHintLines(nextPrompt, decisions);
    nextPrompt = omitBriefingLikeLines(nextPrompt, decisions);
    nextPrompt = compactObjectListLines(nextPrompt, context, decisions);
    nextPrompt = compactDetailLines(nextPrompt, intentName, decisions);
    nextPrompt = compactDbLines(nextPrompt, intentName, decisions);
    if (!identifiersStillPresent(preservedIdentifiers, nextPrompt)) hardBlock = 'confirmedIdentifiersStripped';
  }

  const tokenEstimate = estimateTokens(nextPrompt);
  if (!hardBlock && tokenEstimate > TOKEN_HARD_LIMIT) hardBlock = 'tokenBudgetOverflow';
  const askBackHints = buildAskBackHints(intentName, context, decisions, baseMissing);

  return {
    prompt: nextPrompt,
    decisions,
    askBackHints,
    hardBlock,
    tokenEstimate,
  };
}

export function applyContextPruningAudit(prompt, context = {}) {
  const failures = [];
  const text = String(prompt || '');

  if (!text.includes(CONTEXT_PACK_HEADING)) failures.push('contextPackSectionMissing');
  if (SECRET_PATTERN.test(text)) failures.push('rawSecretLikeText');

  const audit = buildAudit(text, context);

  return {
    prompt: failures.length ? text : replaceContextPack(text, audit),
    audit,
    failures,
  };
}
