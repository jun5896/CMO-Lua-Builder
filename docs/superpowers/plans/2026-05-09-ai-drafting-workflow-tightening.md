# AI Drafting Workflow Tightening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build A2-1 so the local AI interpreter UI has one shared workflow-state contract for idle, calling, ready, ask-back, blocked, and error states.

**Architecture:** Add a pure frontend helper that derives the AI workflow state from the existing parser result, call status, and response text. Wire `LuaAssistant.jsx`, `AiResponseReviewPanel.jsx`, and `AiInterpreterChatPanel.jsx` to display that shared state without changing the parser, backend adapter, pruning, or `isPasteReady` apply gate.

**Tech Stack:** React 19, Vite, plain JavaScript ES modules, existing Node smoke scripts, existing CSS modules/files, no new dependencies, no new test framework.

---

## File Structure

- Create `src/lib/aiWorkflowState.js`: pure workflow-state derivation helper. It has no React imports, no fetch calls, no storage access, and no side effects.
- Create `tools/verify-ai-workflow-state-contract.mjs`: focused Node smoke that proves the six workflow states and the `isPasteReady` apply boundary.
- Modify `package.json`: add `smoke:ai-workflow-state`.
- Modify `src/components/LuaAssistant.jsx`: compute `aiWorkflowState` once and pass it to the Review and Chat lazy panels. Keep `canApplyAiLua` derived from the workflow object, which in turn is derived from `aiParsedResponse.isPasteReady`.
- Modify `src/components/AiResponseReviewPanel.jsx`: use the shared workflow state for the ready/blocked/ask-back summary card while keeping the existing follow-up draft and apply button behavior.
- Modify `src/components/AiInterpreterChatPanel.jsx`: use the shared workflow state for the mode card, next-action list, and history ready flag. Keep chat send user-triggered only.
- Modify `src/components/AiInterpreterChatPanel.css`: support `askBack`, `blocked`, `calling`, and `error` tones.
- Modify `src/components/AiResponseReviewPanel.css`: support workflow tone classes if needed by the ready card.
- Modify `src/index.css`: add a very small main-surface workflow state card only if existing classes cannot express the state clearly.
- Create `handoff/to-kimi/2026-05-09-ai-drafting-workflow-state-qa.md`: focused QA directive for Kimi after product commit.
- Optional create `handoff/to-claude/2026-05-09-ai-drafting-workflow-state-review.md`: only if state transition wording changes from this plan during implementation.
- Optional create `handoff/to-gemini/2026-05-09-ai-drafting-workflow-wording-review.md`: only if Korean labels are changed beyond the strings listed here.

## Invariants

- `canApplyLua` must be true only when `parsedResponse.isPasteReady === true`.
- `ready` must always say that CMO engine verification is still required.
- `askBack` must mean the AI is asking for confirmed CMO values before Lua can be safe.
- `blocked` must mean parser/safety/format/pruning blocks application.
- `error` must mean call/setup/context failure, not a valid AI response that needs review.
- Follow-up drafts may be generated as text, but must not be sent automatically.
- No Track B behavior: no CMO file writes, no scenario folder access, no log tailing, no live read-back, no backend endpoint.
- No credential or storage drift: no `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, or `sessionStorage` in new code outside existing allowed settings/client paths.

---

### Task 1: Add the Workflow-State Smoke Script

**Files:**
- Create: `tools/verify-ai-workflow-state-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Add the package script**

In `package.json`, add this script entry after `smoke:ai-client-parser`:

```json
"smoke:ai-workflow-state": "node tools/verify-ai-workflow-state-contract.mjs",
```

- [ ] **Step 2: Create the failing smoke script**

Create `tools/verify-ai-workflow-state-contract.mjs` with this content:

```javascript
import assert from 'node:assert/strict';
import {
  AI_WORKFLOW_STATES,
  deriveAiWorkflowState,
} from '../src/lib/aiWorkflowState.js';

function assertState(name, input, expected) {
  const actual = deriveAiWorkflowState(input);
  assert.equal(actual.id, expected.id, `${name}: state id`);
  assert.equal(actual.canApplyLua, expected.canApplyLua, `${name}: canApplyLua`);
  if (expected.titleIncludes) {
    assert.match(actual.title, expected.titleIncludes, `${name}: title`);
  }
  if (expected.bodyIncludes) {
    assert.match(actual.body, expected.bodyIncludes, `${name}: body`);
  }
}

const readyParsed = {
  lua: "ScenEdit_MsgBox('ready')",
  isPasteReady: true,
  blockers: [],
  warnings: [],
  followUpQuestions: [],
  missingRequiredSections: [],
};

const askBackParsed = {
  lua: '',
  isPasteReady: false,
  blockers: ['No Lua code block found.'],
  warnings: [],
  followUpQuestions: ['Confirm the Blue side name in CMO.'],
  missingRequiredSections: [],
};

const blockedParsed = {
  lua: "ScenEdit_SetUnit({guid='<UNIT_GUID>'})",
  isPasteReady: false,
  blockers: ['Placeholder tokens detected in Lua: <UNIT_GUID>'],
  warnings: [],
  followUpQuestions: [],
  missingRequiredSections: [],
};

assert.equal(AI_WORKFLOW_STATES.ready, 'ready');
assert.equal(AI_WORKFLOW_STATES.askBack, 'askBack');
assert.equal(AI_WORKFLOW_STATES.blocked, 'blocked');

assertState('idle', {}, {
  id: 'idle',
  canApplyLua: false,
  titleIncludes: /AI response/i,
});

assertState('calling', { isAiCalling: true, aiCallStatus: { state: 'calling', message: 'AI 호출 중' } }, {
  id: 'calling',
  canApplyLua: false,
  titleIncludes: /calling|호출/i,
});

assertState('ready', { aiResponse: '## Paste-ready Lua', parsedResponse: readyParsed }, {
  id: 'ready',
  canApplyLua: true,
  titleIncludes: /Lua/i,
  bodyIncludes: /CMO/i,
});

assertState('askBack', { aiResponse: '## Follow-up questions or blockers', parsedResponse: askBackParsed }, {
  id: 'askBack',
  canApplyLua: false,
  titleIncludes: /confirm|확인/i,
});

assertState('blocked', { aiResponse: '## Paste-ready Lua', parsedResponse: blockedParsed }, {
  id: 'blocked',
  canApplyLua: false,
  bodyIncludes: /Placeholder|UNIT_GUID/i,
});

assertState('error', {
  aiCallStatus: { state: 'error', message: 'Provider model missing' },
}, {
  id: 'error',
  canApplyLua: false,
  bodyIncludes: /Provider model missing/i,
});

console.log('PASS - AI workflow state contract holds.');
```

- [ ] **Step 3: Run the smoke to verify it fails for the right reason**

Run:

```powershell
npm run smoke:ai-workflow-state
```

Expected: FAIL with a module-not-found error for `src/lib/aiWorkflowState.js`.

---

### Task 2: Implement the Pure Workflow-State Helper

**Files:**
- Create: `src/lib/aiWorkflowState.js`
- Test: `tools/verify-ai-workflow-state-contract.mjs`

- [ ] **Step 1: Create `src/lib/aiWorkflowState.js`**

Create the file with this content:

```javascript
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
    body: '요청문을 검토하거나 Prompt 복사 fallback으로 외부 AI에 직접 질문할 수 있습니다.',
    nextActions: [
      '요청문과 선택한 템플릿/컨텍스트를 확인합니다.',
      'AI 호출을 실행하거나 Prompt 복사 fallback을 사용합니다.',
      '응답이 돌아오면 동일한 parser와 apply gate가 적용됩니다.',
    ],
  },
  calling: {
    tone: 'calling',
    label: '호출 중',
    title: 'AI 호출 중',
    body: 'AI 응답을 기다리는 중입니다. 중복 호출과 Lua 적용은 잠시 막아둡니다.',
    nextActions: [
      '현재 호출이 끝날 때까지 기다립니다.',
      '응답이 돌아오면 ready, ask-back, blocked 중 하나로 다시 분류됩니다.',
      '호출이 실패하면 설정 또는 Context Pack을 확인합니다.',
    ],
  },
  ready: {
    tone: 'ready',
    label: '초안 준비',
    title: 'Lua 초안 적용 가능 · CMO 검증 필요',
    body: 'Parser가 paste-ready Lua를 찾았고 blocker가 없습니다. Working Draft에 적용한 뒤 반드시 CMO 엔진에서 실행 검증하세요.',
    nextActions: [
      'Assumptions와 Validation checklist를 먼저 확인합니다.',
      '문제가 없으면 Lua 초안을 Working Draft에 적용합니다.',
      'CMO Lua Console 또는 Event Editor에서 직접 실행 검증합니다.',
    ],
  },
  askBack: {
    tone: 'askBack',
    label: '추가 정보 필요',
    title: 'CMO 값 확인 후 재질문',
    body: 'AI가 안전한 Lua를 만들기 전에 Side, Mission, Unit GUID, DBID, RP, Zone 같은 값을 확인해 달라고 요청했습니다.',
    nextActions: [
      'CMO UI에서 요청된 실제 이름, GUID, DBID, Loadout ID, 좌표, posture 값을 확인합니다.',
      '확인한 값을 follow-up 지시에 붙여 넣습니다.',
      '사용자가 직접 승인한 뒤 다시 AI 호출을 실행합니다.',
    ],
  },
  blocked: {
    tone: 'blocked',
    label: '적용 차단',
    title: 'Lua 적용 전 차단 사유 확인',
    body: 'Parser, placeholder, unsafe Lua, 누락 section, pruning audit 중 하나가 적용을 막았습니다.',
    nextActions: [
      '차단 사유와 warning을 먼저 확인합니다.',
      '필요하면 재질문 초안을 만들어 부족한 값을 보강합니다.',
      'Apply 버튼이 다시 활성화될 때까지 CMO에 붙여 넣지 않습니다.',
    ],
  },
  error: {
    tone: 'error',
    label: '호출 오류',
    title: 'AI 호출 또는 설정 오류',
    body: 'Adapter, provider, Context Pack, pruning audit, 모델 선택 중 하나가 실패했습니다. Prompt 복사 fallback은 계속 사용할 수 있습니다.',
    nextActions: [
      'Settings의 provider, model, adapter 상태를 확인합니다.',
      'Context Pack 또는 pruning hard block 메시지를 확인합니다.',
      '필요하면 Prompt 복사 fallback으로 외부 AI에 수동 질문합니다.',
    ],
  },
});

function hasText(value) {
  return Boolean(String(value || '').trim());
}

function countTextLines(value) {
  const text = String(value || '').trim();
  if (!text) return 0;
  return (text.match(/\n/g)?.length || 0) + 1;
}

function firstItem(items) {
  return Array.isArray(items) && items.length ? String(items[0]) : '';
}

function hasItems(items) {
  return Array.isArray(items) && items.length > 0;
}

function buildState(id, overrides = {}) {
  const base = STATE_COPY[id] || STATE_COPY.idle;
  return {
    id,
    ...base,
    canApplyLua: false,
    applyBlockedReason: '',
    luaLineCount: 0,
    detail: '',
    ...overrides,
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
  const hasPruningFailure = Boolean(pruningAudit?.hardBlock || pruningAudit?.failures?.length);

  if (hasResponse && parsedResponse?.isPasteReady) {
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
      body: question
        ? `${STATE_COPY.askBack.body} 첫 질문: ${question}`
        : STATE_COPY.askBack.body,
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

  if (aiCallStatus?.state === 'error' || hasPruningFailure) {
    const message = pruningAudit?.hardBlock || firstItem(pruningAudit?.failures) || aiCallStatus?.message || STATE_COPY.error.body;
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
```

- [ ] **Step 2: Run the workflow smoke**

Run:

```powershell
npm run smoke:ai-workflow-state
```

Expected:

```text
PASS - AI workflow state contract holds.
```

- [ ] **Step 3: Commit the green helper and smoke**

Run:

```powershell
git add package.json src/lib/aiWorkflowState.js tools/verify-ai-workflow-state-contract.mjs
git commit -m "Add AI workflow state contract smoke"
```

Expected: commit succeeds. `package-lock.json` remains unchanged.

---

### Task 3: Wire the Shared State into `LuaAssistant.jsx`

**Files:**
- Modify: `src/components/LuaAssistant.jsx`

- [ ] **Step 1: Import the helper**

At the top of `src/components/LuaAssistant.jsx`, add:

```javascript
import { deriveAiWorkflowState } from '../lib/aiWorkflowState';
```

- [ ] **Step 2: Replace direct apply-state derivation**

Replace the current block:

```javascript
const aiParsedResponse = useMemo(() => parseAiInterpreterResponse(aiResponse), [aiResponse]);
const aiExtractedLua = aiParsedResponse.lua;
const canApplyAiLua = aiParsedResponse.isPasteReady;
const aiApplyBlockedReason = aiParsedResponse.blockers[0] || '';
```

with:

```javascript
const aiParsedResponse = useMemo(() => parseAiInterpreterResponse(aiResponse), [aiResponse]);
const aiWorkflowState = useMemo(
  () => deriveAiWorkflowState({
    aiResponse,
    isAiCalling,
    aiCallStatus,
    parsedResponse: aiParsedResponse,
    applyBlockedReason: aiParsedResponse.blockers[0] || '',
    pruningAudit: aiPruningAudit,
  }),
  [aiCallStatus, aiParsedResponse, aiPruningAudit, aiResponse, isAiCalling],
);
const aiExtractedLua = aiParsedResponse.lua;
const canApplyAiLua = aiWorkflowState.canApplyLua;
const aiApplyBlockedReason = aiWorkflowState.applyBlockedReason || aiParsedResponse.blockers[0] || '';
```

- [ ] **Step 3: Add a main workflow state card**

Near the AI response toolbar in the output panel, add this card before the AI response content:

```jsx
{(aiResponse || isAiCalling || aiCallStatus.state === 'error') && (
  <div className={`ai-workflow-state-card ${aiWorkflowState.tone}`}>
    <span>{aiWorkflowState.label}</span>
    <div>
      <strong>{aiWorkflowState.title}</strong>
      <p>{aiWorkflowState.body}</p>
    </div>
  </div>
)}
```

This card must not include any button that sends an AI call.

- [ ] **Step 4: Pass the workflow state to lazy panels**

In `AiResponseReviewPanel`, add:

```jsx
workflowState={aiWorkflowState}
```

In `AiInterpreterChatPanel`, add:

```jsx
workflowState={aiWorkflowState}
```

- [ ] **Step 5: Run lint after the main wiring**

Run:

```powershell
npm run lint
```

Expected: PASS.

---

### Task 4: Align `AiResponseReviewPanel.jsx`

**Files:**
- Modify: `src/components/AiResponseReviewPanel.jsx`
- Modify: `src/components/AiResponseReviewPanel.css`

- [ ] **Step 1: Accept the workflow prop**

Change the component signature to include `workflowState`:

```javascript
export default function AiResponseReviewPanel({
  parsedResponse,
  workflowState,
  canApplyLua,
  applyBlockedReason,
  pruningAudit,
  onApplyLua,
  onDraftFollowUp,
}) {
```

- [ ] **Step 2: Add a fallback state inside the component**

After `const extractedLuaLineCount = ...`, add:

```javascript
const reviewState = workflowState || {
  tone: canApplyLua ? 'ready' : 'blocked',
  title: canApplyLua ? 'Lua 초안 적용 가능 · CMO 검증 필요' : 'AI Lua 적용 전 확인 필요',
  body: canApplyLua
    ? `${extractedLuaLineCount} lines Lua가 gate를 통과했습니다. Working Draft 적용 후 CMO 엔진에서 실행 검증하세요.`
    : applyBlockedReason || '응답 section, placeholder, unsafe Lua 여부를 먼저 확인하세요.',
};
```

- [ ] **Step 3: Replace the ready card title/body**

Replace the current ready card header:

```jsx
<div className={`ai-lua-ready-card ${canApplyLua ? 'ok' : 'warning'}`}>
  <div>
    <strong>{canApplyLua ? 'Lua 초안 적용 가능 · CMO 검증 필요' : 'AI Lua 적용 전 확인 필요'}</strong>
    <span>
      {canApplyLua
        ? `${extractedLuaLineCount} lines Lua가 게이트를 통과했습니다. Working Draft 적용 후 CMO 엔진에서 실행 검증하세요.`
        : applyBlockedReason || '응답 섹션, placeholder, unsafe Lua 여부를 먼저 확인하세요.'}
    </span>
  </div>
```

with:

```jsx
<div className={`ai-lua-ready-card ${canApplyLua ? 'ok' : 'warning'} ${reviewState.tone}`}>
  <div>
    <strong>{reviewState.title}</strong>
    <span>{reviewState.body}</span>
  </div>
```

- [ ] **Step 4: Keep follow-up and apply button behavior unchanged**

Verify the buttons still have this behavior:

```jsx
{!canApplyLua && (
  <button
    className="btn btn-mini btn-ghost"
    type="button"
    onClick={() => onDraftFollowUp(buildFollowUpInstruction(parsedResponse, applyBlockedReason))}
  >
    재질문 초안 만들기
  </button>
)}
<button
  className="btn btn-mini btn-primary"
  type="button"
  onClick={onApplyLua}
  disabled={!canApplyLua}
>
  Lua 적용
</button>
```

- [ ] **Step 5: Add compact tone CSS only if needed**

If the existing card does not visually distinguish `askBack`, add this to `src/components/AiResponseReviewPanel.css`:

```css
.ai-lua-ready-card.askBack {
  border-color: rgba(217, 119, 6, 0.35);
  background: rgba(255, 251, 235, 0.92);
}

.ai-lua-ready-card.blocked,
.ai-lua-ready-card.error {
  border-color: rgba(185, 28, 28, 0.35);
  background: rgba(254, 242, 242, 0.92);
}
```

- [ ] **Step 6: Run lint**

Run:

```powershell
npm run lint
```

Expected: PASS.

---

### Task 5: Align `AiInterpreterChatPanel.jsx`

**Files:**
- Modify: `src/components/AiInterpreterChatPanel.jsx`
- Modify: `src/components/AiInterpreterChatPanel.css`

- [ ] **Step 1: Accept the workflow prop**

Add `workflowState` to the props list:

```javascript
export default function AiInterpreterChatPanel({
  basePrompt,
  instruction,
  onInstructionChange,
  aiResponse,
  aiCallStatus,
  isAiCalling,
  parsedResponse,
  workflowState,
  canApplyLua,
  applyBlockedReason,
  pruningAudit,
  copied,
  onCallAi,
  onApplyLua,
  onOpenReview,
  onCopyPrompt,
  onClearInstruction,
}) {
```

- [ ] **Step 2: Replace local response mode derivation**

Delete the local `const responseMode = (() => { ... })();` block.

Add this replacement after the count constants:

```javascript
const responseMode = workflowState || {
  tone: canApplyLua ? 'ready' : aiResponse ? 'blocked' : 'idle',
  label: canApplyLua ? '초안 준비' : aiResponse ? '적용 차단' : '대기',
  title: canApplyLua ? 'Lua 초안 적용 가능 · CMO 검증 필요' : aiResponse ? 'Lua 적용 전 확인 필요' : '아직 응답 없음',
  body: canApplyLua
    ? `${luaLineCount} lines Lua가 gate를 통과했습니다. Working Draft 적용 후 반드시 CMO 엔진에서 실행 검증하세요.`
    : applyBlockedReason || '응답 검토가 필요합니다.',
  nextActions: [],
};
```

- [ ] **Step 3: Replace next-action rendering**

Replace:

```jsx
{nextActionItems(responseMode.tone).map((item) => <li key={item}>{item}</li>)}
```

with:

```jsx
{(responseMode.nextActions?.length ? responseMode.nextActions : nextActionItems(responseMode.tone))
  .map((item) => <li key={item}>{item}</li>)}
```

- [ ] **Step 4: Update `nextActionItems` to the canonical state names**

Change the switch cases:

```javascript
case 'ask':
```

to:

```javascript
case 'askBack':
```

Change:

```javascript
case 'hold':
```

to:

```javascript
case 'blocked':
```

Add cases for `calling` and `error`:

```javascript
case 'calling':
  return [
    'AI 응답을 기다립니다.',
    '중복 호출과 Lua 적용은 현재 비활성화되어 있습니다.',
    '응답이 돌아오면 parser 결과에 따라 다음 단계가 정해집니다.',
  ];
case 'error':
  return [
    'Provider, model, adapter 상태를 먼저 확인합니다.',
    'Context Pack 또는 pruning hard block 메시지를 확인합니다.',
    '필요하면 요청문 복사 fallback으로 외부 AI에 수동 질문합니다.',
  ];
```

- [ ] **Step 5: Update history item status labels**

In `makeHistoryItem`, add:

```javascript
workflowStateId: workflowState?.id || (canApplyLua ? 'ready' : 'blocked'),
workflowLabel: workflowState?.label || (canApplyLua ? '초안 준비' : '검토 필요'),
```

Pass `workflowState` to `makeHistoryItem` in the `useEffect` call.

Render history label with:

```jsx
<strong>{item.time} · {item.workflowLabel}</strong>
```

Keep `ready: Boolean(canApplyLua)` unchanged.

- [ ] **Step 6: Update chat panel CSS tones**

Add to `src/components/AiInterpreterChatPanel.css`:

```css
.ai-chat-response-mode.askBack,
.ai-chat-next-actions.askBack {
  border-color: rgba(217, 119, 6, 0.28);
  background: rgba(255, 251, 235, 0.92);
}

.ai-chat-response-mode.blocked,
.ai-chat-next-actions.blocked,
.ai-chat-response-mode.error,
.ai-chat-next-actions.error {
  border-color: rgba(185, 28, 28, 0.28);
  background: rgba(254, 242, 242, 0.92);
}

.ai-chat-response-mode.calling,
.ai-chat-next-actions.calling {
  border-color: rgba(37, 99, 235, 0.24);
  background: rgba(239, 246, 255, 0.92);
}
```

- [ ] **Step 7: Run lint**

Run:

```powershell
npm run lint
```

Expected: PASS.

---

### Task 6: Add Main-Surface Styling

**Files:**
- Modify: `src/index.css`

- [ ] **Step 1: Add the workflow card styles**

Add this compact block near existing AI adapter/status styles:

```css
.ai-workflow-state-card {
  display: flex;
  gap: 0.8rem;
  align-items: flex-start;
  padding: 0.75rem 0.85rem;
  border: 1px solid rgba(15, 23, 42, 0.12);
  border-radius: 14px;
  background: rgba(248, 250, 252, 0.94);
}

.ai-workflow-state-card > span {
  flex: 0 0 auto;
  padding: 0.2rem 0.55rem;
  border-radius: 999px;
  background: rgba(15, 23, 42, 0.08);
  font-size: 0.72rem;
  font-weight: 800;
}

.ai-workflow-state-card strong {
  display: block;
  margin-bottom: 0.18rem;
}

.ai-workflow-state-card p {
  margin: 0;
  color: var(--muted);
  font-size: 0.85rem;
}

.ai-workflow-state-card.ready {
  border-color: rgba(22, 163, 74, 0.25);
  background: rgba(240, 253, 244, 0.94);
}

.ai-workflow-state-card.askBack,
.ai-workflow-state-card.calling {
  border-color: rgba(217, 119, 6, 0.25);
  background: rgba(255, 251, 235, 0.94);
}

.ai-workflow-state-card.blocked,
.ai-workflow-state-card.error {
  border-color: rgba(185, 28, 28, 0.28);
  background: rgba(254, 242, 242, 0.94);
}
```

- [ ] **Step 2: Run build to measure CSS budget**

Run:

```powershell
npm run build
```

Expected:

```text
index-*.css under 60 kB
index-*.js under 400 kB
aiContextPruning-*.js under 9 kB
```

If main CSS exceeds 60 kB, reduce this block by removing tone-specific backgrounds before touching lazy component CSS.

---

### Task 7: Run the Product Verification Set

**Files:**
- No file edits.

- [ ] **Step 1: Run focused smokes**

Run:

```powershell
npm run smoke:ai-workflow-state
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

Expected:

```text
PASS - AI workflow state contract holds.
```

The adapter smoke must report no raw `Bearer`, `Authorization`, or `sk-` leakage.

- [ ] **Step 2: Run lint and build**

Run:

```powershell
npm run lint
npm run build
```

Expected: both PASS.

- [ ] **Step 3: Run static safety scans**

Run:

```powershell
Select-String -Path src\lib\aiWorkflowState.js,src\components\AiInterpreterChatPanel.jsx,src\components\AiResponseReviewPanel.jsx -Pattern "apiKey|Authorization|Bearer|sk-|localStorage|sessionStorage"
Select-String -Path src\components\LuaAssistant.jsx -Pattern "canApplyAiLua = aiWorkflowState.canApplyLua|disabled={!canApplyAiLua}|isPasteReady"
```

Expected:

```text
No credential/storage hits in the new workflow helper and panel changes.
LuaAssistant.jsx still shows canApplyAiLua flowing to disabled={!canApplyAiLua}.
```

- [ ] **Step 4: Commit the product implementation**

Run:

```powershell
git add package.json src/lib/aiWorkflowState.js tools/verify-ai-workflow-state-contract.mjs src/components/LuaAssistant.jsx src/components/AiResponseReviewPanel.jsx src/components/AiResponseReviewPanel.css src/components/AiInterpreterChatPanel.jsx src/components/AiInterpreterChatPanel.css src/index.css
git commit -m "Align AI drafting workflow state"
```

Expected: product commit succeeds and `package-lock.json` remains unchanged.

---

### Task 8: Open Kimi QA Directive

**Files:**
- Create: `handoff/to-kimi/2026-05-09-ai-drafting-workflow-state-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`

- [ ] **Step 1: Create Kimi QA directive**

Create `handoff/to-kimi/2026-05-09-ai-drafting-workflow-state-qa.md` with this content:

```markdown
# Kimi QA Directive - AI Drafting Workflow State

## Target

Review the product commit `Align AI drafting workflow state`.

## Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

## Static Checkpoints

1. `src/lib/aiWorkflowState.js` exists and exports `AI_WORKFLOW_STATES` plus `deriveAiWorkflowState`.
2. `tools/verify-ai-workflow-state-contract.mjs` covers `idle`, `calling`, `ready`, `askBack`, `blocked`, and `error`.
3. `ready` returns `canApplyLua === true` only when `parsedResponse.isPasteReady === true`.
4. `calling`, `askBack`, `blocked`, `error`, and `idle` return `canApplyLua === false`.
5. `LuaAssistant.jsx` derives `canApplyAiLua` from `aiWorkflowState.canApplyLua`.
6. Apply buttons still use `disabled={!canApplyAiLua}`.
7. Apply blocked message still reports the parser blocker when present.
8. `AiResponseReviewPanel.jsx` uses `workflowState` for the summary card.
9. `AiInterpreterChatPanel.jsx` uses `workflowState` for the mode card and next actions.
10. Follow-up draft creation remains a text draft only and is not automatically sent.
11. Main `Prompt 복사` fallback remains visible.
12. Chat `요청문 복사` fallback remains visible.
13. `parseAiInterpreterResponse()` contract is unchanged.
14. `aiContextPruning` code is unchanged.
15. No Track B behavior is introduced: no scenario folder writes, no log tail, no live read-back, no backend endpoint.
16. No new dependency or package-lock drift.
17. No new `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, or `sessionStorage` usage in the workflow-state changes.
18. Main JS remains under `400 kB`.
19. Main CSS remains under `60 kB`.
20. `aiContextPruning` remains under `9 kB`.
21. AI adapter smoke reports no raw Bearer/Authorization/sk- leakage.

## Expected Verdict

Approve only if all pipeline steps pass and every state except `ready` keeps Lua apply disabled.
```
```

- [ ] **Step 2: Update agent current tasks**

Update the three `CURRENT_TASK.md` files with a short A2-1 active-state note:

```markdown
## Active A2-1 - AI Drafting Workflow State

Codex opened A2-1 after the Template Inspector Search / Filter release. Kimi owns focused QA for the shared AI workflow state contract. Claude and Gemini remain standby unless Codex requests wording or state-transition review.
```

- [ ] **Step 3: Commit the handoff**

Run:

```powershell
git add handoff/to-kimi/2026-05-09-ai-drafting-workflow-state-qa.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md
git commit -m "Add AI drafting workflow state QA directive"
```

Expected: handoff commit succeeds.

- [ ] **Step 4: Push**

Run:

```powershell
git push
```

Expected: `origin/main` receives the product commit and QA directive commit.

---

### Task 9: After Kimi Approval

**Files:**
- Move: `handoff/to-kimi/2026-05-09-ai-drafting-workflow-state-qa.md` to `handoff/to-kimi/_archive/2026-05-09/`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`
- Modify: `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`

- [ ] **Step 1: Archive the QA directive**

Run:

```powershell
New-Item -ItemType Directory -Force handoff\to-kimi\_archive\2026-05-09
Move-Item handoff\to-kimi\2026-05-09-ai-drafting-workflow-state-qa.md handoff\to-kimi\_archive\2026-05-09\
```

Expected: Kimi top-level inbox returns to `_archive/` plus `CURRENT_TASK.md`.

- [ ] **Step 2: Record the A2-1 closeout**

Add a section to `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`:

```markdown
## Post-Release AI Drafting Workflow State - 2026-05-09

- Scope: Track A2-1 local AI interpreter workflow state alignment.
- Product commit: record the one-line result of `git log --oneline --grep "Align AI drafting workflow state" -1`.
- QA: Kimi approved `smoke:ai-workflow-state`, lint, build, AI client parser smoke, and AI adapter smoke.
- Bundle baseline: record the exact main JS, main CSS, and aiContextPruning sizes from Kimi's QA report.
- Safety: `ready` is the only apply-enabled state and remains tied to `aiParsedResponse.isPasteReady`.
- Track B: still deferred.
```

Use the actual product commit hash and observed bundle values from Kimi's report.

- [ ] **Step 3: Commit the closeout**

Run:

```powershell
git add docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-drafting-workflow-state-qa.md
git commit -m "Archive AI drafting workflow state QA"
git push
```

Expected: clean working tree after push.

---

## Verification Summary

Minimum verification before asking Kimi:

```powershell
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

Expected watch lines:

```text
Main JS < 400 kB
Main CSS < 60 kB
aiContextPruning < 9 kB
PresetGuide lazy growth irrelevant to A2 unless touched
```

Expected no-change areas:

```text
server/**
public/template-annotations.json
src/lib/aiContextPruning.js
package-lock.json
scenario sidecar tooling
```

## Self-Review

- Spec coverage: The helper and smoke cover all six workflow states from the A2 design. The UI wiring tasks align the main, review, and chat surfaces. Kimi directive covers bundle, smoke, prompt-copy, no Track B behavior, no storage drift, and the apply gate.
- Placeholder scan: This plan contains concrete file paths, commands, code snippets, expected outputs, and no unresolved implementation markers.
- Type consistency: `AI_WORKFLOW_STATES`, `deriveAiWorkflowState`, `workflowState`, `canApplyLua`, `applyBlockedReason`, `tone`, `label`, `title`, `body`, and `nextActions` are named consistently across helper, smoke, and component wiring.
