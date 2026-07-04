# CMO AI Advisory Workspace Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reframe the local UI from an expert AI interpreter into a chat-first CMO mission scripting advisor with a simplified Lua scratchpad and integrated wiki/preset knowledge surface.

**Architecture:** Add small contract helpers first, then reshape navigation around `AI Chat`, `Lua Scratchpad`, `Wiki / Presets`, and `CMO Bridge`. Keep B2/B3/B4 explicit and manual, move heavy guide content into lazy surfaces, and avoid adding to the main bundle where possible.

**Tech Stack:** React/Vite, existing AI adapter client, existing parser/workflow/follow-up/confirmed-context helpers, existing Template Inspector annotation data, Node ESM smoke contracts.

---

## Scope Guard

This plan does not add live CMO state, automatic CMO execution, automatic AI send, polling, filesystem watchers, new dependencies, or privileged browser-supplied root paths.

## File Map

- Create `src/lib/aiAdvisoryChatPolicy.js`: pure helper for consultation/off-topic/chat-mode prompt framing.
- Create `tools/verify-ai-advisory-chat-policy.mjs`: smoke contract for beginner ask-back, off-topic redirect, and no live-state claims.
- Modify `package.json`: add `smoke:ai-advisory-chat-policy` and later include it in `verify:release` only after product UI is stable.
- Modify `src/components/LuaAssistant.jsx`: default to the chat-first workspace, reduce legacy interpreter prominence, and route B2/B3/B4 actions into support sections.
- Modify `src/components/AiInterpreterChatPanel.jsx`: rename simple mode copy from implementation launcher to consultation chat, with one focused ask-back path.
- Modify `src/components/AiInterpreterChatPanel.css`: keep bounded response preview and minimal chat layout using existing classes where possible.
- Create `src/components/LuaScratchpadPanel.jsx`: lightweight manual Lua input/check/copy panel, extracted from the old second editor behavior.
- Create `src/components/LuaScratchpadPanel.css`: small scoped styles only if existing classes are insufficient.
- Modify or create `src/components/CmoWikiPresetPanel.jsx`: wiki-style integration of feature encyclopedia, annotations, and examples, lazy-loaded if possible.
- Create `tools/verify-ai-advisory-workspace-contract.mjs`: UI/static contract covering navigation, size-limit copy, scratchpad constraints, wiki integration, and no automatic send.

## Task 1: Advisory Chat Policy Contract

**Files:**

- Create: `src/lib/aiAdvisoryChatPolicy.js`
- Create: `tools/verify-ai-advisory-chat-policy.mjs`
- Modify: `package.json`

- [ ] **Step 1: Write the smoke contract**

Create `tools/verify-ai-advisory-chat-policy.mjs`:

```js
import assert from 'node:assert/strict';
import {
  buildAdvisorySystemGuidance,
  classifyAdvisoryTopic,
  formatOffTopicRedirect,
} from '../src/lib/aiAdvisoryChatPolicy.js';

const guidance = buildAdvisorySystemGuidance({
  confirmedContextCount: 2,
  hasScenarioSnapshot: false,
});

assert.ok(guidance.includes('CMO mission scripting advisor'));
assert.ok(guidance.includes('ask one focused follow-up question'));
assert.ok(guidance.includes('Do not claim live CMO state'));
assert.ok(guidance.includes('CMO engine verification is required'));

assert.equal(classifyAdvisoryTopic('CAP 미션 자동화 스크립트 만들어줘').scope, 'cmo');
assert.equal(classifyAdvisoryTopic('Lua 코드 문법 확인해줘').scope, 'cmo');
assert.equal(classifyAdvisoryTopic('오늘 저녁 뭐 먹지?').scope, 'offTopic');

const redirect = formatOffTopicRedirect('오늘 저녁 뭐 먹지?');
assert.ok(redirect.includes('CMO'));
assert.ok(redirect.includes('시나리오'));
assert.equal(/꺼져|불가|지원하지 않/.test(redirect), false);

console.log('PASS - AI advisory chat policy contract holds.');
```

- [ ] **Step 2: Run the smoke and confirm RED**

Run: `npm run smoke:ai-advisory-chat-policy`

Expected: FAIL because the script or helper does not exist yet.

- [ ] **Step 3: Add the helper**

Create `src/lib/aiAdvisoryChatPolicy.js`:

```js
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
  const prefix = trimmed ? `지금 질문은 "${trimmed.slice(0, 80)}" 쪽에 가까워 보여요. ` : '';
  return `${prefix}이 도구는 CMO 미션/시나리오 Lua 작업에 맞춰져 있어요. 질문을 CMO 시나리오 설계, Lua 자동화, 이벤트/미션 구성, 또는 프롬프트 작성 쪽으로 바꿔주면 바로 도와드릴게요.`;
}

export function buildAdvisorySystemGuidance({ confirmedContextCount = 0, hasScenarioSnapshot = false } = {}) {
  const contextLine = confirmedContextCount > 0
    ? `Use the ${confirmedContextCount} user-confirmed CMO values before asking for them again.`
    : 'Ask for missing CMO values before drafting Lua.';
  const snapshotLine = hasScenarioSnapshot
    ? 'You may refer to the imported CMO snapshot, but it is not live state.'
    : 'Do not claim live CMO state. Ask the user to import a snapshot if current state matters.';

  return [
    'You are a CMO mission scripting advisor, not a one-shot code generator.',
    'For broad requests, ask one focused follow-up question before producing Lua.',
    contextLine,
    snapshotLine,
    'When code is drafted, say it is an AI draft and CMO engine verification is required.',
    'If the request is off-topic, gently redirect toward CMO scenario design, Lua automation, or prompt formulation.',
  ].join('\n');
}
```

- [ ] **Step 4: Add npm script**

In `package.json`, add:

```json
"smoke:ai-advisory-chat-policy": "node tools/verify-ai-advisory-chat-policy.mjs"
```

- [ ] **Step 5: Run the smoke and commit**

Run: `npm run smoke:ai-advisory-chat-policy`

Expected: PASS.

Commit:

```powershell
git add package.json src/lib/aiAdvisoryChatPolicy.js tools/verify-ai-advisory-chat-policy.mjs
git commit -m "Add AI advisory chat policy contract"
```

## Task 2: Chat-First Workspace Navigation

**Files:**

- Modify: `src/components/LuaAssistant.jsx`
- Modify: `src/components/AiInterpreterChatPanel.jsx`
- Modify: `src/components/AiInterpreterChatPanel.css`
- Test: `tools/verify-ai-advisory-workspace-contract.mjs`

- [ ] **Step 1: Write static UI contract**

Create `tools/verify-ai-advisory-workspace-contract.mjs` with checks:

```js
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const luaAssistant = readFileSync(new URL('../src/components/LuaAssistant.jsx', import.meta.url), 'utf8');
const chatPanel = readFileSync(new URL('../src/components/AiInterpreterChatPanel.jsx', import.meta.url), 'utf8');

assert.ok(luaAssistant.includes('AI Chat'));
assert.ok(luaAssistant.includes('Lua Scratchpad'));
assert.ok(luaAssistant.includes('Wiki / Presets'));
assert.ok(luaAssistant.includes('CMO Bridge'));
assert.equal(/sendCmoAiPrompt\([^)]*logFeedback/i.test(luaAssistant), false);
assert.equal(/sendCmoAiPrompt\([^)]*snapshot/i.test(luaAssistant), false);

assert.ok(chatPanel.includes('CMO mission scripting advisor') || chatPanel.includes('CMO 미션 스크립트'));
assert.ok(chatPanel.includes('one focused follow-up') || chatPanel.includes('한 가지'));
assert.ok(chatPanel.includes('실시간') || chatPanel.includes('live'));

console.log('PASS - AI advisory workspace contract holds.');
```

- [ ] **Step 2: Run and confirm RED**

Run: `node tools/verify-ai-advisory-workspace-contract.mjs`

Expected: FAIL until UI labels and guidance are updated.

- [ ] **Step 3: Update top navigation**

In `src/components/LuaAssistant.jsx`, make the primary tab order:

```js
const WORKSPACE_TABS = [
  { id: 'chat', label: 'AI Chat' },
  { id: 'scratchpad', label: 'Lua Scratchpad' },
  { id: 'wiki', label: 'Wiki / Presets' },
  { id: 'bridge', label: 'CMO Bridge' },
  { id: 'settings', label: 'Settings' },
];
```

Keep `chat` as the initial state.

- [ ] **Step 4: Update chat empty state**

In `AiInterpreterChatPanel.jsx`, update the simple chat heading/copy:

```jsx
<h3>CMO 미션 스크립트 상담</h3>
<p>
  원하는 시나리오 동작을 편하게 말해 주세요. 바로 코드를 쓰기보다 필요한 Side, Mission,
  Unit GUID, DBID, RP 이름을 먼저 좁혀서 Lua 초안을 만듭니다.
</p>
```

Add a short scope note:

```jsx
<p className="ai-chat-scope-note">
  CMO 시나리오 설계, Lua 자동화, 이벤트/미션 구성, 프롬프트 작성에 집중합니다.
</p>
```

- [ ] **Step 5: Run contract and build**

Run:

```powershell
npm run smoke:ai-advisory-chat-policy
node tools/verify-ai-advisory-workspace-contract.mjs
npm run build
```

Expected: all PASS, Main JS remains under `400 kB`, Main CSS remains under `60 kB`.

- [ ] **Step 6: Commit**

```powershell
git add src/components/LuaAssistant.jsx src/components/AiInterpreterChatPanel.jsx src/components/AiInterpreterChatPanel.css tools/verify-ai-advisory-workspace-contract.mjs
git commit -m "Reframe AI chat as CMO advisory workspace"
```

## Task 3: Lua Scratchpad Simplification

**Files:**

- Create: `src/components/LuaScratchpadPanel.jsx`
- Create or modify: `src/components/LuaScratchpadPanel.css`
- Modify: `src/components/LuaAssistant.jsx`
- Test: `tools/verify-ai-advisory-workspace-contract.mjs`

- [ ] **Step 1: Add scratchpad component**

Create `src/components/LuaScratchpadPanel.jsx`:

```jsx
import './LuaScratchpadPanel.css';

export default function LuaScratchpadPanel({
  value,
  onChange,
  onCopyToChat,
  issues = [],
}) {
  return (
    <section className="lua-scratchpad-panel">
      <div className="panel-heading">
        <p className="eyebrow">Lua Scratchpad</p>
        <h2>수동 Lua 입력 확인</h2>
        <p>
          여기는 코드 생성기가 아니라 보조 확인 공간입니다. 붙여넣은 Lua가 의도대로 입력됐는지 보고,
          필요하면 AI Chat으로 복사해 질문하세요.
        </p>
      </div>
      <textarea
        className="lua-scratchpad-input"
        value={value}
        onChange={(event) => onChange(event.target.value)}
        placeholder="CMO Lua 코드를 여기에 붙여넣으세요."
      />
      <div className="lua-scratchpad-actions">
        <button type="button" onClick={onCopyToChat} disabled={!value.trim()}>
          AI Chat에 질문 초안 만들기
        </button>
      </div>
      <ul className="lua-scratchpad-issues">
        {issues.length === 0 ? (
          <li>기본 입력 상태는 괜찮아 보입니다. CMO 엔진 검증은 별도 필요합니다.</li>
        ) : (
          issues.map((issue) => <li key={issue.id}>{issue.message}</li>)
        )}
      </ul>
    </section>
  );
}
```

- [ ] **Step 2: Add tiny scoped CSS**

Create `src/components/LuaScratchpadPanel.css`:

```css
.lua-scratchpad-panel {
  display: grid;
  gap: 1rem;
}

.lua-scratchpad-input {
  min-height: 18rem;
  resize: vertical;
}

.lua-scratchpad-issues {
  margin: 0;
  padding-left: 1.25rem;
}
```

- [ ] **Step 3: Wire scratchpad tab**

In `LuaAssistant.jsx`, render `LuaScratchpadPanel` for the `scratchpad` tab and wire `onCopyToChat` to create a text-only chat draft:

```js
const draftScratchpadQuestion = () => {
  const code = source.trim();
  if (!code) return;
  setAiPrompt(`아래 CMO Lua 코드를 검토해 주세요. 실행 전 확인해야 할 Side/Mission/Unit/RP/DBID 값과 CMO 엔진 테스트 포인트를 알려주세요.\n\n\`\`\`lua\n${code}\n\`\`\``);
  setActiveWorkspaceTab('chat');
};
```

- [ ] **Step 4: Keep old expert behavior out of default path**

Ensure any legacy interpreter/review panels are either:

- reachable only from an explicit advanced disclosure, or
- removed from the default render path if redundant.

Do not remove parser, follow-up, confirmed context, B2, B3, or B4 helpers.

- [ ] **Step 5: Verify and commit**

Run:

```powershell
npm run smoke:ai-advisory-chat-policy
node tools/verify-ai-advisory-workspace-contract.mjs
npm run lint
npm run build
```

Commit:

```powershell
git add src/components/LuaAssistant.jsx src/components/LuaScratchpadPanel.jsx src/components/LuaScratchpadPanel.css tools/verify-ai-advisory-workspace-contract.mjs
git commit -m "Simplify Lua assistant into scratchpad"
```

## Task 4: Wiki / Presets Integration

**Files:**

- Create or modify: `src/components/CmoWikiPresetPanel.jsx`
- Modify: `src/components/LuaAssistant.jsx`
- Reuse: `public/template-annotations.json`
- Test: `tools/verify-ai-advisory-workspace-contract.mjs`

- [ ] **Step 1: Define wiki card shape**

Use existing annotation fields:

```js
const buildWikiEntry = (resource, annotation) => ({
  id: resource.id,
  title: annotation?.title ?? resource.name,
  summary: annotation?.summary ?? resource.description ?? '',
  beginnerNotes: annotation?.beginnerNotes ?? '',
  prerequisites: annotation?.prerequisites ?? '',
  safePattern: annotation?.safePattern ?? '',
  aiHint: annotation?.aiHint ?? '',
  checks: annotation?.checks ?? '',
  examples: [resource],
});
```

- [ ] **Step 2: Render encyclopedia + examples together**

The panel should show:

- concept title
- beginner explanation
- required CMO values
- related template/example file
- "Ask AI about this" button

- [ ] **Step 3: Add ask button**

Button behavior:

```js
setAiPrompt(`이 CMO Lua 기능/템플릿을 사용하고 싶습니다.\n\n주제: ${entry.title}\n설명: ${entry.summary}\n필요 확인값: ${entry.prerequisites}\n\n먼저 어떤 CMO 값이 필요한지 질문해 주세요.`);
setActiveWorkspaceTab('chat');
```

This must not call AI automatically.

- [ ] **Step 4: Lazy-load if needed**

If Main JS would exceed `400 kB`, keep the wiki/preset panel in an existing lazy chunk or add a lazy import:

```js
const CmoWikiPresetPanel = lazy(() => import('./CmoWikiPresetPanel.jsx'));
```

- [ ] **Step 5: Verify and commit**

Run:

```powershell
npm run build
npm run smoke:ai-advisory-chat-policy
node tools/verify-ai-advisory-workspace-contract.mjs
```

Commit:

```powershell
git add src/components/CmoWikiPresetPanel.jsx src/components/LuaAssistant.jsx tools/verify-ai-advisory-workspace-contract.mjs
git commit -m "Integrate presets into CMO wiki panel"
```

## Task 5: Scenario Context Honesty and Folder Scan Copy

**Files:**

- Modify: `src/components/LuaAssistant.jsx`
- Modify: `src/components/AiInterpreterChatPanel.jsx`
- Test: `tools/verify-ai-advisory-workspace-contract.mjs`

- [ ] **Step 1: Add scenario size warning copy**

In the attachment area, include:

```jsx
<p className="attachment-limit-note">
  많은 CMO .scen 파일은 브라우저 보조 첨부 한도를 넘습니다. 큰 시나리오는 경로 기반 스캔이나
  sidecar 요약으로 연결하는 방식이 필요합니다.
</p>
```

- [ ] **Step 2: Keep folder scan bounded**

Ensure folder scan copy says:

- small text/background files only
- no full scenario parsing
- max file count / total read remains bounded

- [ ] **Step 3: Verify no false live-state wording**

Add static assertions to `tools/verify-ai-advisory-workspace-contract.mjs`:

```js
assert.equal(/실시간\s*CMO\s*상태를\s*확인/.test(luaAssistant), false);
assert.ok(luaAssistant.includes('sidecar 요약') || luaAssistant.includes('경로 기반 스캔'));
```

- [ ] **Step 4: Verify and commit**

Run:

```powershell
node tools/verify-ai-advisory-workspace-contract.mjs
npm run build
```

Commit:

```powershell
git add src/components/LuaAssistant.jsx src/components/AiInterpreterChatPanel.jsx tools/verify-ai-advisory-workspace-contract.mjs
git commit -m "Clarify scenario attachment limits"
```

## Task 6: Verification, QA Directive, and Release Path

**Files:**

- Modify: `package.json`
- Create: `handoff/to-kimi/YYYY-MM-DD-cmo-ai-advisory-workspace-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`

- [ ] **Step 1: Extend verify:release only after stable**

After the new smokes are stable, add them before parser/adapter smokes:

```json
"smoke:ai-advisory-chat-policy && smoke:ai-advisory-workspace && smoke:ai-client-parser && smoke:ai-adapter"
```

- [ ] **Step 2: Full verification**

Run:

```powershell
npm run smoke:ai-advisory-chat-policy
npm run smoke:ai-advisory-workspace
npm run lint
npm run build
npm run verify:release
```

Expected:

- Main JS < `400 kB`
- Main CSS < `60 kB`
- `aiContextPruning` < `9 kB`
- no raw `Bearer`, `Authorization`, or `sk-` leakage

- [ ] **Step 3: Browser smoke**

Open `http://localhost:5173/` and verify:

- default leftmost tab is `AI Chat`
- the first visible experience is chat-like
- `Lua Scratchpad` is secondary
- wiki/presets are not the default first screen
- B2/B3/B4 controls remain explicit and manual

- [ ] **Step 4: Kimi QA directive**

Create a Kimi QA directive asking for:

- file scope check
- all smokes
- `verify:release`
- bundle watch lines
- no auto-send
- no live-state claims
- no browser-supplied privileged roots
- off-topic redirect wording
- scenario size limit copy
- scratchpad is manual-only
- wiki entries link concepts and examples

- [ ] **Step 5: Commit QA directive**

```powershell
git add handoff/to-kimi/YYYY-MM-DD-cmo-ai-advisory-workspace-qa.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md
git commit -m "Open CMO AI advisory workspace QA"
```

## Execution Notes

- Because Main JS is already near the watch line, prefer deletion/demotion/lazy loading over net-new main-bundle panels.
- Keep all user-facing Korean copy concise.
- Do not claim the AI can inspect CMO live state.
- Do not claim large `.scen` files can be fully attached through the browser helper.
- The first implementation slice should be small enough to revert safely if the UI direction feels wrong.

## Frontend Review Response

Gemini's frontend architecture review is incorporated with this sequencing:

- `LuaAssistant.jsx` split is mandatory and should happen during the advisory workspace work.
- Monaco / CodeMirror is deferred because the editor is being demoted to scratchpad and current Main JS is near the `400 kB` watch line.
- Zustand is deferred until component boundaries and hooks prove prop drilling is a real problem.
- CSS Modules are deferred; new CSS should be scoped and global CSS should shrink as old panels are removed.
- Vitest / React Testing Library is deferred until a dedicated testing/refactor task; this plan continues with existing Node smoke contracts.

The first coding slice should therefore be "policy contract + shell split", not "add another panel".

## Refactor-Safe Additional Task: Shell Extraction Before More UI

**Files:**

- Create: `src/components/AiAdvisoryWorkspace.jsx`
- Modify: `src/components/LuaAssistant.jsx`
- Test: `tools/verify-ai-advisory-workspace-contract.mjs`

- [ ] **Step 1: Create a shell component**

Create `src/components/AiAdvisoryWorkspace.jsx` with a narrow prop surface:

```jsx
export default function AiAdvisoryWorkspace({
  activeTab,
  onTabChange,
  renderChat,
  renderScratchpad,
  renderWiki,
  renderBridge,
  renderSettings,
}) {
  const tabs = [
    ['chat', 'AI Chat'],
    ['scratchpad', 'Lua Scratchpad'],
    ['wiki', 'Wiki / Presets'],
    ['bridge', 'CMO Bridge'],
    ['settings', 'Settings'],
  ];

  const renderActive = () => {
    if (activeTab === 'scratchpad') return renderScratchpad();
    if (activeTab === 'wiki') return renderWiki();
    if (activeTab === 'bridge') return renderBridge();
    if (activeTab === 'settings') return renderSettings();
    return renderChat();
  };

  return (
    <section className="ai-advisory-workspace">
      <nav className="assistant-tabbar" aria-label="CMO AI workspace">
        {tabs.map(([id, label]) => (
          <button
            key={id}
            type="button"
            className={activeTab === id ? 'is-active' : ''}
            onClick={() => onTabChange(id)}
          >
            {label}
          </button>
        ))}
      </nav>
      {renderActive()}
    </section>
  );
}
```

- [ ] **Step 2: Use the shell without moving all state yet**

In `LuaAssistant.jsx`, keep state in place for the first split but render through `AiAdvisoryWorkspace`.

This reduces risk: product behavior changes are visible, but state migration is not bundled into the same commit.

- [ ] **Step 3: Verify shell extraction did not grow the bundle unexpectedly**

Run:

```powershell
npm run build
node tools/verify-ai-advisory-workspace-contract.mjs
```

Expected:

- Main JS remains under `400 kB`.
- No B2/B3/B4 auto-send or auto-execution paths appear.

- [ ] **Step 4: Commit**

```powershell
git add src/components/AiAdvisoryWorkspace.jsx src/components/LuaAssistant.jsx tools/verify-ai-advisory-workspace-contract.mjs
git commit -m "Extract AI advisory workspace shell"
```
