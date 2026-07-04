const MAX_EVIDENCE_PER_CATEGORY = 4;

export const FOLLOW_UP_NEED_CATEGORIES = Object.freeze([
  {
    id: 'side',
    label: 'Side',
    promptLabel: 'Side name',
    severity: 'confirm',
    reason: 'CMO UI에 있는 실제 Side 이름을 확인하세요.',
    patterns: [/\bside\b/i, /side name/i, /DetectorSideID/i, /target_side/i],
  },
  {
    id: 'mission',
    label: 'Mission',
    promptLabel: 'Mission name',
    severity: 'confirm',
    reason: '이미 만든 Mission 이름을 CMO Mission Editor에서 확인하세요.',
    patterns: [/\bmission\b/i, /mission name/i, /AssignUnitToMission/i],
  },
  {
    id: 'unitGuid',
    label: 'Unit GUID',
    promptLabel: 'Unit GUID',
    severity: 'confirm',
    reason: '배치된 유닛은 CMO의 Copy unit ID to clipboard GUID를 우선 사용하세요.',
    patterns: [/\bguid\b/i, /unit guid/i, /unit id/i, /copy unit id/i, /UNIT_GUID/i],
  },
  {
    id: 'dbid',
    label: 'DBID',
    promptLabel: 'DBID',
    severity: 'confirm',
    reason: '현재 시나리오 DB 기준 Database Viewer에서 DBID를 확인하세요.',
    patterns: [/\bdbid\b/i, /database viewer/i, /weapon dbid/i, /aircraft dbid/i, /platform dbid/i],
  },
  {
    id: 'loadout',
    label: 'Loadout',
    promptLabel: 'Loadout ID',
    severity: 'confirm',
    reason: '현재 DB와 항공기 기준 Loadout ID를 확인하세요.',
    patterns: [/loadout/i, /loadoutId/i, /loadout id/i],
  },
  {
    id: 'rpZone',
    label: 'RP / Zone',
    promptLabel: 'RP or Zone',
    severity: 'confirm',
    reason: 'CMO에 존재하는 Reference Point 또는 Zone 이름을 사용하세요.',
    patterns: [/\brp\b/i, /reference point/i, /\bzone\b/i, /No-Nav/i, /Exclusion/i],
  },
  {
    id: 'postureDoctrine',
    label: 'Posture / Doctrine / EMCON',
    promptLabel: 'Posture, Doctrine, or EMCON',
    severity: 'confirm',
    reason: '관계, 교전규칙, EMCON 값은 추측하지 말고 CMO에서 확인하세요.',
    patterns: [/posture/i, /doctrine/i, /EMCON/i, /\bWRA\b/i],
  },
  {
    id: 'coordinates',
    label: 'Coordinates',
    promptLabel: 'Coordinates',
    severity: 'confirm',
    reason: '좌표는 CMO 지도에서 확인한 값만 사용하세요.',
    patterns: [/coordinate/i, /latitude/i, /longitude/i, /\blat\b/i, /\blon\b/i, /map/i, /좌표/],
  },
  {
    id: 'weather',
    label: 'Weather',
    promptLabel: 'Weather range',
    severity: 'confirm',
    reason: '날씨 범위와 baseline 값은 명시적으로 확인하세요.',
    patterns: [/weather/i, /rain/i, /cloud/i, /sea state/i, /temperature/i, /날씨/],
  },
  {
    id: 'format',
    label: 'Response Format',
    promptLabel: 'Required response sections',
    severity: 'format',
    reason: 'Paste-ready Lua와 필수 응답 heading을 다시 맞추세요.',
    patterns: [/missing section/i, /required section/i, /paste-ready lua/i, /No Lua code block/i],
  },
  {
    id: 'unsafeLua',
    label: 'Unsafe Lua',
    promptLabel: 'Unsafe Lua surface',
    severity: 'safety',
    reason: 'os.*, io.*, require 같은 unsafe Lua 표면을 제거하세요.',
    patterns: [/unsafe lua/i, /\bos\./i, /\bio\./i, /\brequire\s*\(?/i, /dofile/i, /loadfile/i],
  },
]);

function collectSourceLines(parsedResponse = {}, applyBlockedReason = '') {
  const sourceGroups = [
    parsedResponse.blockers,
    parsedResponse.warnings,
    parsedResponse.followUpQuestions,
    parsedResponse.prerequisites,
    parsedResponse.missingRequiredSections,
    applyBlockedReason ? [applyBlockedReason] : [],
  ];
  return sourceGroups
    .flatMap((items) => (Array.isArray(items) ? items : []))
    .map((item) => String(item || '').trim())
    .filter(Boolean);
}

function cloneCategory(category, evidence) {
  return {
    id: category.id,
    label: category.label,
    promptLabel: category.promptLabel,
    severity: category.severity,
    reason: category.reason,
    evidence: evidence.slice(0, MAX_EVIDENCE_PER_CATEGORY),
  };
}

export function deriveAiFollowUpNeeds(parsedResponse = {}, applyBlockedReason = '') {
  const lines = collectSourceLines(parsedResponse, applyBlockedReason);
  const categories = [];

  for (const category of FOLLOW_UP_NEED_CATEGORIES) {
    const evidence = lines.filter((line) => category.patterns.some((pattern) => pattern.test(line)));
    if (evidence.length) {
      categories.push(cloneCategory(category, evidence));
    }
  }

  return {
    categories,
    summary: categories.length
      ? `${categories.length}개 확인 필요값`
      : '확인 필요값 없음',
    hasNeeds: categories.length > 0,
  };
}

export function formatFollowUpNeedsForPrompt(needs = {}) {
  const categories = Array.isArray(needs.categories) ? needs.categories : [];
  if (!categories.length) return '';

  return [
    '확인 필요값:',
    ...categories.map((category) => `- ${category.label}: ${category.reason}`),
    '',
    '규칙:',
    '- 위 값들은 추측하지 말 것.',
    '- 값이 부족하면 추가 질문을 먼저 작성할 것.',
    '- 안전한 경우에만 ## Paste-ready Lua 섹션을 다시 작성할 것.',
  ].join('\n');
}
