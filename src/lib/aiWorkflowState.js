export const AI_WORKFLOW_STATES = Object.freeze({
  idle: 'idle',
  calling: 'calling',
  ready: 'ready',
  askBack: 'askBack',
  blocked: 'blocked',
  error: 'error',
});

const STATE_COPY = Object.freeze({
  idle: {
    tone: 'idle',
    label: '대기',
    title: 'AI response 대기',
    body: '요청문을 검토한 뒤 AI 호출을 실행하거나 Prompt 복사 fallback으로 외부 AI에 직접 질문할 수 있습니다.',
    nextActions: [
      '요청문과 선택된 템플릿 컨텍스트를 확인하세요.',
      'AI 호출을 실행하거나 Prompt 복사 fallback을 사용할 수 있습니다.',
      '응답이 돌아오면 동일한 parser와 apply gate가 적용됩니다.',
    ],
  },
  calling: {
    tone: 'calling',
    label: '호출 중',
    title: 'AI 호출 중',
    body: 'AI 응답을 기다리는 중입니다. 중복 호출과 Lua 적용은 잠시 막아둡니다.',
    nextActions: [
      '현재 호출이 끝날 때까지 기다리세요.',
      '응답이 돌아오면 ready, ask back, blocked 중 하나로 다시 분류됩니다.',
      '호출이 실패하면 설정 또는 Context Pack을 확인하세요.',
    ],
  },
  ready: {
    tone: 'ready',
    label: '초안 준비',
    title: 'Lua 초안 적용 가능, CMO 검증 필요',
    body: 'Parser가 paste-ready Lua를 찾았고 blocker가 없습니다. Working Draft에 적용할 수 있지만 반드시 CMO 엔진에서 실행 검증이 필요합니다.',
    nextActions: [
      'Assumptions와 Validation checklist를 먼저 확인하세요.',
      '문제가 없으면 Lua 초안을 Working Draft에 적용하세요.',
      'CMO Lua Console 또는 Event Editor에서 직접 실행 검증하세요.',
    ],
  },
  askBack: {
    tone: 'askBack',
    label: '추가 확인 필요',
    title: 'CMO 값 확인 후 재질문',
    body: 'AI가 안전한 Lua를 만들기 전에 Side, Mission, Unit GUID, DBID, RP, Zone 같은 실제 CMO 값을 확인해 달라고 요청했습니다.',
    nextActions: [
      'CMO UI에서 요청된 실제 이름, GUID, DBID, Loadout ID, 좌표, posture 값을 확인하세요.',
      '확인한 값을 follow-up 지시에 붙여 넣으세요.',
      '사용자가 직접 승인한 뒤 다시 AI 호출을 실행하세요.',
    ],
  },
  blocked: {
    tone: 'blocked',
    label: '적용 차단',
    title: 'Lua 적용 전 차단 사유 확인',
    body: 'Parser, placeholder, unsafe Lua, 누락 section, pruning audit 중 하나가 적용을 막았습니다.',
    nextActions: [
      '차단 사유와 warning을 먼저 확인하세요.',
      '필요하면 재질문 초안을 만들고 부족한 값을 보강하세요.',
      'Apply 버튼이 다시 활성화될 때까지 CMO에 붙여 넣지 마세요.',
    ],
  },
  error: {
    tone: 'error',
    label: '호출 오류',
    title: 'AI 호출 또는 설정 오류',
    body: 'Adapter, provider, Context Pack, pruning audit, 모델 선택 중 하나가 실패했습니다. Prompt 복사 fallback은 계속 사용할 수 있습니다.',
    nextActions: [
      'Settings의 provider, model, adapter 상태를 확인하세요.',
      'Context Pack 또는 pruning hard block 메시지를 확인하세요.',
      '필요하면 Prompt 복사 fallback으로 외부 AI에 수동 질문하세요.',
    ],
  },
});

function hasText(value) {
  return Boolean(String(value || '').trim());
}

function hasItems(items) {
  return Array.isArray(items) && items.length > 0;
}

function firstItem(items) {
  return hasItems(items) ? String(items[0]) : '';
}

function countTextLines(value) {
  const text = String(value || '').trim();
  if (!text) return 0;
  return (text.match(/\n/g)?.length || 0) + 1;
}

function hasPruningFailures(pruningAudit) {
  return Boolean(pruningAudit?.hardBlock || hasItems(pruningAudit?.failures));
}

function buildState(id, overrides = {}) {
  const base = STATE_COPY[id] || STATE_COPY.idle;
  const nextActions = [...(overrides.nextActions || base.nextActions || [])];
  return {
    id,
    ...base,
    canApplyLua: false,
    applyBlockedReason: '',
    luaLineCount: 0,
    detail: '',
    ...overrides,
    nextActions,
  };
}

export function deriveAiWorkflowState({
  aiResponse = '',
  isAiCalling = false,
  aiCallStatus = null,
  parsedResponse = null,
  applyBlockedReason = '',
  pruningAudit = null,
} = {}) {
  if (isAiCalling) {
    return buildState(AI_WORKFLOW_STATES.calling, {
      detail: aiCallStatus?.message || '',
    });
  }

  const hasResponse = hasText(aiResponse);
  const blocker = applyBlockedReason || firstItem(parsedResponse?.blockers);

  if (hasPruningFailures(pruningAudit)) {
    const message =
      pruningAudit?.hardBlock ||
      firstItem(pruningAudit?.failures) ||
      STATE_COPY.error.body;
    return buildState(AI_WORKFLOW_STATES.error, {
      applyBlockedReason: message,
      detail: message,
      body: message,
    });
  }

  if (hasResponse && parsedResponse?.isPasteReady === true) {
    const luaLineCount = countTextLines(parsedResponse.lua);
    return buildState(AI_WORKFLOW_STATES.ready, {
      canApplyLua: true,
      luaLineCount,
      detail: `${luaLineCount} Lua lines`,
    });
  }

  if (hasResponse && hasItems(parsedResponse?.followUpQuestions) && !hasText(parsedResponse?.lua)) {
    const question = firstItem(parsedResponse.followUpQuestions);
    return buildState(AI_WORKFLOW_STATES.askBack, {
      applyBlockedReason: blocker,
      detail: question,
      body: question ? `${STATE_COPY.askBack.body} 첫 질문: ${question}` : STATE_COPY.askBack.body,
    });
  }

  if (hasResponse) {
    return buildState(AI_WORKFLOW_STATES.blocked, {
      applyBlockedReason: blocker,
      luaLineCount: countTextLines(parsedResponse?.lua),
      detail: blocker,
      body: blocker || STATE_COPY.blocked.body,
    });
  }

  if (aiCallStatus?.state === 'error') {
    const message = aiCallStatus?.message || STATE_COPY.error.body;
    return buildState(AI_WORKFLOW_STATES.error, {
      applyBlockedReason: message,
      detail: message,
      body: message,
    });
  }

  return buildState(AI_WORKFLOW_STATES.idle, {
    detail: aiCallStatus?.message || '',
  });
}
