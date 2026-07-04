export { buildAdvisorySystemGuidance } from './aiAdvisoryGuidance.js';

const CMO_KEYWORDS = [
  'cmo',
  'command modern operations',
  'lua',
  'mission',
  '미션',
  '시나리오',
  '이벤트',
  'unit',
  'side',
  'dbid',
  'loadout',
  'emcon',
  'doctrine',
  'rp',
  'reference point',
  'scenedit',
  'tool_dumpevents',
  'scenedit_runscript',
];

export function classifyAdvisoryTopic(text = '') {
  const normalized = String(text).toLowerCase();
  const matched = CMO_KEYWORDS.filter((keyword) => normalized.includes(keyword));

  return {
    scope: matched.length > 0 ? 'cmo' : 'offTopic',
    matched,
  };
}

export function formatOffTopicRedirect(text = '') {
  const trimmed = String(text).trim();
  const prefix = trimmed
    ? `지금 질문은 "${trimmed.slice(0, 80)}" 쪽에 가까워 보여요. `
    : '';

  return `${prefix}이 도구는 CMO 미션/시나리오 Lua 작업에 맞춰져 있어요. 질문을 CMO 시나리오 설계, Lua 자동화, 이벤트/미션 구성, 또는 프롬프트 작성 쪽으로 바꿔주면 바로 도와드릴게요.`;
}
