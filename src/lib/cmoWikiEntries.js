export const MAX_DRAFT_LUA_CHARS = 2000;

export const BADGE_DEFINITIONS = [
  { id: 'engineTest', label: 'CMO 엔진 테스트 필요', tone: 'warning' },
  { id: 'needsSide', label: 'Side 확인', tone: 'info' },
  { id: 'needsMission', label: 'Mission 확인', tone: 'info' },
  { id: 'needsUnitGuid', label: 'Unit GUID 확인', tone: 'info' },
  { id: 'needsDbid', label: 'DBID 확인', tone: 'info' },
  { id: 'needsLoadout', label: 'Loadout ID 확인', tone: 'info' },
  { id: 'needsRpZone', label: 'RP / Zone 확인', tone: 'info' },
  { id: 'affectsSideWide', label: 'Side 전체 영향', tone: 'caution' },
];

export function annotationTextParts(annotation) {
  if (!annotation) return [];
  return [
    annotation.title,
    annotation.summary,
    ...(annotation.beginnerNotes || []),
    ...(annotation.prerequisites || []),
    annotation.safePattern,
    annotation.aiHint,
    ...(annotation.checks || []),
  ].filter(Boolean);
}

export function normalizeSearchText(values) {
  return values.filter(Boolean).join(' ').toLowerCase();
}

export function annotationText(annotation, field = 'all') {
  if (!annotation) return '';
  if (field === 'prerequisites') return normalizeSearchText(annotation.prerequisites || []);
  if (field === 'checks') return normalizeSearchText(annotation.checks || []);
  return normalizeSearchText(annotationTextParts(annotation));
}

export function includesAny(text, needles) {
  return needles.some((needle) => text.includes(needle));
}

export function resourceSearchText(resource, annotation = resource?.annotation) {
  return normalizeSearchText([
    resource?.file,
    resource?.sourceFile,
    resource?.relativePath,
    resource?.scenario,
    resource?.category,
    resource?.type,
    resource?.title,
    resource?.summary,
    ...(resource?.features || []),
    ...(resource?.apis || []),
    ...annotationTextParts(annotation),
  ]);
}

export function matchesQuickFilter(resource, annotation = resource?.annotation, filterId) {
  if (resource?.type === 'preset') return false;

  const category = String(resource?.category || '').toLowerCase();
  const allText = annotationText(annotation);

  if (filterId === 'event') return category === 'event';
  if (filterId === 'mission') return category === 'mission';
  if (filterId === 'unit') return category === 'unit' || includesAny(allText, ['unit spawn', 'unit edit', 'unit lifecycle', '유닛']);
  if (filterId === 'dbidLoadout') return category === 'loadout' || includesAny(allText, ['dbid', 'loadout', 'database viewer']);
  if (filterId === 'rpZone') return ['reference', 'zone'].includes(category) || includesAny(allText, [' rp ', 'reference point', 'zone', '좌표']);
  if (filterId === 'doctrineEmcon') return category === 'doctrine' || includesAny(allText, ['doctrine', 'emcon', 'posture', '교전 규칙']);
  if (filterId === 'keyvalue') return category === 'kvstore' || includesAny(allText, ['keyvalue', 'kvstore', ' key value ', 'setkeyvalue']);

  return false;
}

export function buildResourceBadges(resource, annotation = resource?.annotation) {
  const category = String(resource?.category || '').toLowerCase();
  const prerequisiteText = annotationText(annotation, 'prerequisites');
  const checkText = annotationText(annotation, 'checks');
  const allText = annotationText(annotation);
  const badges = [];

  const addBadge = (id) => {
    const badge = BADGE_DEFINITIONS.find((item) => item.id === id);
    if (badge && !badges.some((item) => item.id === id)) badges.push(badge);
  };

  if (includesAny(allText, ['engine test', 'engine verification', 'lua console', 'event editor', 'cmo engine', '엔진 테스트', '엔진 검증'])) addBadge('engineTest');
  if (includesAny(prerequisiteText, ['side name', 'actual side', 'source side', 'target side', 'side 이름', 'side를'])) addBadge('needsSide');
  if (includesAny(prerequisiteText, ['mission name', 'actual mission', 'mission 이름'])) addBadge('needsMission');
  if (includesAny(prerequisiteText, ['unit guid', 'unit id', 'guid first', 'copy unit id', 'guid를', 'guid가'])) addBadge('needsUnitGuid');
  if (includesAny(prerequisiteText, ['dbid', 'database viewer'])) addBadge('needsDbid');
  if (includesAny(prerequisiteText, ['loadout id', 'loadout'])) addBadge('needsLoadout');
  if (includesAny(prerequisiteText, ['rp name', 'reference point', 'zone name', 'rp 이름', 'zone 이름', '좌표'])) addBadge('needsRpZone');
  if (category === 'doctrine' || includesAny(allText, ['side-wide', 'side level', 'side 전체', 'posture', 'doctrine', 'emcon'])) addBadge('affectsSideWide');

  if (!badges.some((badge) => badge.id === 'engineTest') && includesAny(checkText, ['test', 'verify', 'verification', 'check', '테스트', '검증', '확인'])) {
    addBadge('engineTest');
  }

  return badges;
}

function templateBySource(templates = []) {
  return new Map((templates || []).map((template) => [template.sourceFile, template]));
}

function resourcesByFile(...resourceLists) {
  const map = new Map();
  resourceLists.flat().filter(Boolean).forEach((resource) => {
    if (resource.file && !map.has(resource.file)) map.set(resource.file, resource);
  });
  return map;
}

export function buildCmoWikiEntries({
  annotationsPayload,
  templates = [],
  builderManifest = {},
  installedManifest = {},
} = {}) {
  const annotations = annotationsPayload?.templates || {};
  const catalog = templateBySource(templates);
  const resources = resourcesByFile(
    builderManifest.templates || [],
    builderManifest.presets || [],
    installedManifest.examples || [],
  );

  return Object.entries(annotations).map(([sourceFile, annotation]) => {
    const template = catalog.get(sourceFile) || null;
    const resource = resources.get(sourceFile) || {};
    const entry = {
      id: sourceFile,
      file: sourceFile,
      sourceFile,
      title: annotation.title || template?.title || sourceFile,
      summary: annotation.summary || template?.summary || '',
      useCase: annotation.beginnerNotes?.[0] || annotation.summary || template?.summary || '',
      beginnerNotes: annotation.beginnerNotes || [],
      requiredValues: annotation.prerequisites || [],
      safePattern: annotation.safePattern || '',
      aiHint: annotation.aiHint || '',
      engineChecks: annotation.checks || [],
      category: resource.category || template?.featureGroup || template?.presetSection || '',
      type: resource.type || 'template',
      path: resource.path || '',
      lines: resource.lines || 0,
      features: resource.features || [],
      apis: resource.apis || [],
      template,
      annotation,
    };
    return {
      ...entry,
      badges: buildResourceBadges(entry, annotation),
      searchText: resourceSearchText(entry, annotation),
    };
  }).sort((a, b) => a.title.localeCompare(b.title));
}

const API_HINTS = [
  ['ScenEdit_SetKeyValue', ['keyvalue', 'kvstore', 'state']],
  ['ScenEdit_GetKeyValue', ['keyvalue', 'kvstore', 'state']],
  ['ScenEdit_SetDoctrine', ['doctrine', 'emcon', 'posture']],
  ['ScenEdit_SetEMCON', ['doctrine', 'emcon']],
  ['ScenEdit_AssignUnitToMission', ['mission']],
  ['ScenEdit_AddReferencePoint', ['reference point', 'rp ', 'zone']],
  ['ScenEdit_SetWeather', ['weather']],
  ['ScenEdit_AddUnit', ['unit spawn', 'dbid']],
  ['ScenEdit_SetLoadout', ['loadout']],
];

export function matchCmoWikiEntriesForLua(luaText = '', entries = [], { limit = 5 } = {}) {
  const text = String(luaText).toLowerCase();
  if (!text.trim()) return [];

  const scored = entries.map((entry) => {
    let score = 0;
    const haystack = entry.searchText || resourceSearchText(entry);

    if (text.includes(entry.sourceFile.toLowerCase())) score += 8;
    for (const api of entry.apis || []) {
      if (text.includes(String(api).toLowerCase())) score += 6;
    }
    for (const [apiName, keywords] of API_HINTS) {
      if (text.includes(apiName.toLowerCase()) && keywords.some((keyword) => haystack.includes(keyword))) {
        score += 5;
      }
    }
    for (const token of [entry.category, entry.title, ...(entry.features || [])]) {
      const normalized = String(token || '').toLowerCase();
      if (normalized && text.includes(normalized)) score += 2;
    }

    return { entry, score };
  });

  return scored
    .filter((item) => item.score > 0)
    .sort((a, b) => b.score - a.score || a.entry.title.localeCompare(b.entry.title))
    .slice(0, limit)
    .map((item) => item.entry);
}

export function redactWikiDraftText(text = '') {
  return String(text)
    .replace(/\bBearer\s+[A-Za-z0-9._~+/=-]+/gi, 'Bearer [redacted]')
    .replace(/\bsk-proj-[A-Za-z0-9_-]{6,}/gi, 'sk-proj-[redacted]')
    .replace(/\bsk-[A-Za-z0-9_-]{6,}/gi, 'sk-[redacted]')
    .replace(/\b[A-Za-z]:[\\/][^\s`'"]+/g, '[local-path-redacted]')
    .replace(/\\\\[A-Za-z0-9_.-]+\\[^\s`'"]+/g, '[unc-path-redacted]');
}

export function formatWikiQuestionDraft(entry, { luaText = '' } = {}) {
  const safeLua = redactWikiDraftText(String(luaText).slice(0, MAX_DRAFT_LUA_CHARS));
  const truncated = String(luaText).length > MAX_DRAFT_LUA_CHARS
    ? `\n\nLua 일부만 포함했습니다. (${MAX_DRAFT_LUA_CHARS}자 제한)`
    : '';
  const requiredValues = entry.requiredValues?.length
    ? entry.requiredValues.map((item) => `- ${item}`).join('\n')
    : '- CMO에서 실제 Side/Mission/Unit/RP/DBID 값을 확인해야 합니다.';

  return [
    '이 CMO Lua 기능을 사용하고 싶습니다. 이 문장은 AI 채팅 입력창에만 들어가며 자동 전송되지 않습니다.',
    '',
    `주제: ${entry.title}`,
    `관련 예문: ${entry.sourceFile}`,
    '',
    'CMO에서 직접 확인할 값:',
    requiredValues,
    '',
    '안전 패턴:',
    entry.safePattern || 'AI 초안은 CMO 엔진에서 직접 검증해야 합니다.',
    '',
    '요청:',
    '먼저 부족한 CMO 값을 한 가지씩 질문해 주세요. 충분하면 CMO 엔진 검증이 필요한 Lua 초안을 작성해 주세요.',
    safeLua ? `\n참고 Lua:\n\`\`\`lua\n${safeLua}\n\`\`\`${truncated}` : '',
  ].filter(Boolean).join('\n');
}
