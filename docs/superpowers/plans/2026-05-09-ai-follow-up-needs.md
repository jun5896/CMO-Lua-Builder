# AI Follow-Up Needs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build A2-2 so blocked and ask-back AI responses show grouped CMO confirmation needs and produce safer follow-up drafts.

**Architecture:** Add a pure `aiFollowUpNeeds` helper plus a focused Node smoke, then wire the helper into the lazy AI Response Review panel only. Keep the main workflow state, parser, apply gate, adapter, pruning, and Track B boundaries unchanged.

**Tech Stack:** React 19, Vite, plain JavaScript ES modules, existing Node smoke scripts, existing lazy component CSS, no new dependencies, no new test framework.

---

## File Structure

- Create `src/lib/aiFollowUpNeeds.js`: pure category detection and prompt-formatting helper.
- Create `tools/verify-ai-follow-up-needs-contract.mjs`: focused smoke for category detection, formatting, duplicate handling, empty state, and mutation safety.
- Modify `package.json`: add `smoke:ai-follow-up-needs`.
- Modify `src/components/AiResponseReviewPanel.jsx`: import the helper, render a compact CMO confirmation-needs card, and include grouped needs in the follow-up draft.
- Modify `src/components/AiResponseReviewPanel.css`: style the new lazy-panel needs card only.
- Create `handoff/to-kimi/2026-05-09-ai-follow-up-needs-qa.md`: focused QA directive after product commit.
- Modify `handoff/to-kimi/CURRENT_TASK.md`, `handoff/to-claude/CURRENT_TASK.md`, and `handoff/to-gemini/CURRENT_TASK.md`: record active QA state.

## Invariants

- No changes to `parseAiInterpreterResponse()`.
- No changes to `src/lib/aiContextPruning.js`.
- No changes to `src/index.css`; Main CSS is already close to the `60 kB` soft line.
- No CMO filesystem writes, log tailing, live read-back, or backend endpoint.
- No auto-send: follow-up is drafted into the chat input only.
- `canApplyLua` and `aiParsedResponse.isPasteReady` gate behavior remains unchanged.
- No new dependency, package-lock drift, localStorage/sessionStorage usage, or credential strings.

---

### Task 1: Add Follow-Up Needs Smoke

**Files:**
- Create: `tools/verify-ai-follow-up-needs-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Add the package script**

In `package.json`, add this script near the other smoke scripts:

```json
"smoke:ai-follow-up-needs": "node tools/verify-ai-follow-up-needs-contract.mjs",
```

Do not modify `package-lock.json`.

- [ ] **Step 2: Create the failing smoke script**

Create `tools/verify-ai-follow-up-needs-contract.mjs`:

```javascript
#!/usr/bin/env node
import assert from 'node:assert/strict';
import {
  deriveAiFollowUpNeeds,
  FOLLOW_UP_NEED_CATEGORIES,
  formatFollowUpNeedsForPrompt,
} from '../src/lib/aiFollowUpNeeds.js';

function ids(needs) {
  return needs.categories.map((category) => category.id);
}

function assertHas(idsToCheck, expectedId) {
  assert.equal(idsToCheck.includes(expectedId), true, `expected ${expectedId}`);
}

const mixedParsedResponse = {
  blockers: [
    'No Lua code block found.',
    'Placeholder tokens detected in Lua: <UNIT_GUID>',
  ],
  warnings: [
    'Missing section: paste-ready lua',
    'Confirm DBID and Loadout ID from Database Viewer.',
  ],
  followUpQuestions: [
    'What is the Blue Side name and Mission name?',
    'Confirm RP / Zone names and coordinates from the CMO map.',
    'Confirm posture, doctrine, and EMCON settings.',
  ],
  prerequisites: [
    'Use Copy unit ID to clipboard GUID for the selected unit.',
    'Weather range must be explicit.',
  ],
  missingRequiredSections: ['paste-ready lua'],
};

const needs = deriveAiFollowUpNeeds(mixedParsedResponse, 'Unsafe Lua surface detected: require(');
const categoryIds = ids(needs);

assert.equal(needs.hasNeeds, true);
assertHas(categoryIds, 'side');
assertHas(categoryIds, 'mission');
assertHas(categoryIds, 'unitGuid');
assertHas(categoryIds, 'dbid');
assertHas(categoryIds, 'loadout');
assertHas(categoryIds, 'rpZone');
assertHas(categoryIds, 'postureDoctrine');
assertHas(categoryIds, 'coordinates');
assertHas(categoryIds, 'weather');
assertHas(categoryIds, 'format');
assertHas(categoryIds, 'unsafeLua');

assert.equal(categoryIds.filter((id) => id === 'dbid').length, 1);
assert.equal(needs.categories.find((category) => category.id === 'unitGuid').severity, 'confirm');
assert.equal(needs.categories.find((category) => category.id === 'format').severity, 'format');
assert.equal(needs.categories.find((category) => category.id === 'unsafeLua').severity, 'safety');

const emptyNeeds = deriveAiFollowUpNeeds({}, '');
assert.equal(emptyNeeds.hasNeeds, false);
assert.deepEqual(emptyNeeds.categories, []);
assert.equal(emptyNeeds.summary, '확인 필요값 없음');

const promptText = formatFollowUpNeedsForPrompt(needs);
assert.match(promptText, /확인 필요값/);
assert.match(promptText, /Side/);
assert.match(promptText, /Unit GUID/);
assert.match(promptText, /DBID/);
assert.match(promptText, /추측하지 말 것/);
assert.match(promptText, /Paste-ready Lua/);

const first = deriveAiFollowUpNeeds(mixedParsedResponse, '');
first.categories.push({ id: 'mutated' });
first.categories[0].evidence.push('mutated evidence');
const second = deriveAiFollowUpNeeds(mixedParsedResponse, '');
assert.equal(ids(second).includes('mutated'), false);
assert.equal(second.categories[0].evidence.includes('mutated evidence'), false);

assert.equal(FOLLOW_UP_NEED_CATEGORIES.length >= 11, true);

console.log('PASS - AI follow-up needs contract holds.');
```

- [ ] **Step 3: Run the smoke to verify it fails for the right reason**

Run:

```powershell
npm run smoke:ai-follow-up-needs
```

Expected: FAIL with module-not-found for `src/lib/aiFollowUpNeeds.js`.

---

### Task 2: Implement `aiFollowUpNeeds` Helper

**Files:**
- Create: `src/lib/aiFollowUpNeeds.js`
- Test: `tools/verify-ai-follow-up-needs-contract.mjs`

- [ ] **Step 1: Create the helper**

Create `src/lib/aiFollowUpNeeds.js`:

```javascript
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
    reason: '좌표는 CMO 지도에서 확인한 범위와 값을 사용하세요.',
    patterns: [/latitude/i, /longitude/i, /\blat\b/i, /\blon\b/i, /coordinate/i, /좌표/],
  },
  {
    id: 'weather',
    label: 'Weather',
    promptLabel: 'Weather values',
    severity: 'confirm',
    reason: '날씨 값은 명시된 범위 안에서만 사용하세요.',
    patterns: [/weather/i, /sea state/i, /rain/i, /cloud/i, /temperature/i, /날씨/],
  },
  {
    id: 'format',
    label: 'Response Format',
    promptLabel: 'Required response format',
    severity: 'format',
    reason: '필수 heading과 fenced Lua 형식을 유지하도록 요청하세요.',
    patterns: [/missing section/i, /paste-ready lua/i, /fenced lua/i, /no lua code block/i, /required section/i],
  },
  {
    id: 'unsafeLua',
    label: 'Unsafe Lua',
    promptLabel: 'CMO-safe Lua surface',
    severity: 'safety',
    reason: 'unsafe Lua 표면을 제거하고 CMO 안전 API만 사용하도록 요청하세요.',
    patterns: [/unsafe lua/i, /\bos\s*\./i, /\bio\s*\./i, /\brequire\s*\(?/i, /\bdofile\s*\(?/i, /\bloadfile\s*\(?/i],
  },
]);

function compactLine(value) {
  return String(value || '').replace(/\s+/g, ' ').trim();
}

function collectSourceLines(parsedResponse = {}, applyBlockedReason = '') {
  const sourceGroups = [
    parsedResponse.blockers,
    parsedResponse.warnings,
    parsedResponse.followUpQuestions,
    parsedResponse.prerequisites,
    parsedResponse.missingRequiredSections,
    applyBlockedReason ? [applyBlockedReason] : [],
  ];

  return [...new Set(sourceGroups
    .flatMap((group) => (Array.isArray(group) ? group : []))
    .map(compactLine)
    .filter(Boolean))];
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
      ? `${categories.map((category) => category.label).join(', ')} 확인 필요`
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
    '- Side/Mission/GUID/DBID/Loadout/RP/Zone/posture/doctrine/EMCON/coordinates/weather 값은 추측하지 말 것.',
    '- 부족하면 BLOCKER 또는 Follow-up question으로 되물을 것.',
    '- 안전한 경우에만 ## Paste-ready Lua 섹션에 fenced Lua를 작성할 것.',
  ].join('\n');
}
```

- [ ] **Step 2: Run the helper smoke**

Run:

```powershell
npm run smoke:ai-follow-up-needs
```

Expected:

```text
PASS - AI follow-up needs contract holds.
```

- [ ] **Step 3: Run existing workflow smoke**

Run:

```powershell
npm run smoke:ai-workflow-state
```

Expected:

```text
PASS - AI workflow state contract holds.
```

- [ ] **Step 4: Commit helper and smoke**

Run:

```powershell
git add package.json src/lib/aiFollowUpNeeds.js tools/verify-ai-follow-up-needs-contract.mjs
git commit -m "Add AI follow-up needs contract"
```

Expected: commit succeeds; `package-lock.json` remains unchanged.

---

### Task 3: Wire Needs Into Review Panel

**Files:**
- Modify: `src/components/AiResponseReviewPanel.jsx`
- Modify: `src/components/AiResponseReviewPanel.css`

- [ ] **Step 1: Import helper**

At the top of `src/components/AiResponseReviewPanel.jsx`, add:

```javascript
import {
  deriveAiFollowUpNeeds,
  formatFollowUpNeedsForPrompt,
} from '../lib/aiFollowUpNeeds';
```

- [ ] **Step 2: Update follow-up instruction builder signature**

Replace:

```javascript
function buildFollowUpInstruction(parsedResponse, applyBlockedReason) {
```

with:

```javascript
function buildFollowUpInstruction(parsedResponse, applyBlockedReason, followUpNeeds) {
```

Inside the `parts` array, insert the formatted needs block after `applyBlockedReason`:

```javascript
formatFollowUpNeedsForPrompt(followUpNeeds),
```

Keep the existing blockers, warnings, follow-up questions, missing sections, and prerequisites blocks.

- [ ] **Step 3: Derive needs in component**

After `reviewState`, add:

```javascript
const followUpNeeds = deriveAiFollowUpNeeds(parsedResponse, applyBlockedReason);
const visibleNeedCategories = followUpNeeds.categories.slice(0, 6);
const showNeedsCard = followUpNeeds.hasNeeds || (!canApplyLua && (parsedResponse.blockers.length > 0 || parsedResponse.warnings.length > 0));
```

- [ ] **Step 4: Pass needs to draft button**

Replace the existing button handler:

```jsx
onClick={() => onDraftFollowUp(buildFollowUpInstruction(parsedResponse, applyBlockedReason))}
```

with:

```jsx
onClick={() => onDraftFollowUp(buildFollowUpInstruction(parsedResponse, applyBlockedReason, followUpNeeds))}
```

- [ ] **Step 5: Render the needs card**

Render this block after the ready card and before the diagnostic grid:

```jsx
{showNeedsCard && (
  <section className="ai-follow-up-needs-card">
    <div className="ai-follow-up-needs-header">
      <div>
        <strong>CMO에서 확인할 값</strong>
        <span>{followUpNeeds.summary}</span>
      </div>
      <em>{followUpNeeds.hasNeeds ? `${followUpNeeds.categories.length} categories` : '분류 없음'}</em>
    </div>
    {followUpNeeds.hasNeeds ? (
      <div className="ai-follow-up-needs-list">
        {visibleNeedCategories.map((category) => (
          <article className={`ai-follow-up-need ${category.severity}`} key={category.id}>
            <div>
              <strong>{category.label}</strong>
              <span>{category.reason}</span>
            </div>
            {category.evidence.length > 0 && (
              <details>
                <summary>근거 보기</summary>
                <ul>
                  {category.evidence.map((item) => <li key={item}>{item}</li>)}
                </ul>
              </details>
            )}
          </article>
        ))}
      </div>
    ) : (
      <p>분류된 확인값 없음. 차단 사유와 응답 형식을 먼저 확인하세요.</p>
    )}
  </section>
)}
```

- [ ] **Step 6: Add Review panel CSS**

Append to `src/components/AiResponseReviewPanel.css`:

```css
.ai-follow-up-needs-card {
  display: grid;
  gap: 0.55rem;
  padding: 0.62rem 0.72rem;
  border: 1px solid rgba(240, 184, 74, 0.26);
  border-radius: 15px;
  background: rgba(240, 184, 74, 0.065);
}

.ai-follow-up-needs-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 0.65rem;
}

.ai-follow-up-needs-header strong,
.ai-follow-up-needs-header span,
.ai-follow-up-needs-header em {
  display: block;
}

.ai-follow-up-needs-header strong {
  color: var(--text);
  font-size: 0.78rem;
}

.ai-follow-up-needs-header span,
.ai-follow-up-needs-card p {
  margin: 0.14rem 0 0;
  color: var(--muted);
  font-size: 0.7rem;
  line-height: 1.38;
}

.ai-follow-up-needs-header em {
  flex: 0 0 auto;
  padding: 0.18rem 0.46rem;
  border: 1px solid rgba(240, 184, 74, 0.28);
  border-radius: 999px;
  color: var(--muted);
  font-size: 0.6rem;
  font-style: normal;
  font-weight: 900;
}

.ai-follow-up-needs-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.45rem;
}

.ai-follow-up-need {
  min-width: 0;
  padding: 0.54rem 0.58rem;
  border: 1px solid rgba(112, 210, 247, 0.15);
  border-radius: 13px;
  background: rgba(3, 12, 14, 0.36);
}

.ai-follow-up-need.format {
  border-color: rgba(112, 210, 247, 0.22);
}

.ai-follow-up-need.safety {
  border-color: rgba(255, 118, 118, 0.3);
}

.ai-follow-up-need strong,
.ai-follow-up-need span {
  display: block;
}

.ai-follow-up-need strong {
  color: var(--accent-2);
  font-size: 0.72rem;
}

.ai-follow-up-need span,
.ai-follow-up-need summary,
.ai-follow-up-need li {
  color: var(--muted);
  font-size: 0.66rem;
  line-height: 1.34;
}

.ai-follow-up-need span {
  margin-top: 0.12rem;
}

.ai-follow-up-need details {
  margin-top: 0.35rem;
}

.ai-follow-up-need summary {
  cursor: pointer;
}

.ai-follow-up-need ul {
  margin: 0.32rem 0 0;
  padding-left: 1rem;
}
```

- [ ] **Step 7: Run lint**

Run:

```powershell
npm run lint
```

Expected: PASS.

---

### Task 4: Product Verification and Commit

**Files:**
- No new edits unless verification finds a targeted issue.

- [ ] **Step 1: Run focused smokes**

Run:

```powershell
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

Expected:

```text
PASS - AI follow-up needs contract holds.
PASS - AI workflow state contract holds.
PASS - AI adapter client parser contract smoke checks passed.
AI adapter smoke reports no raw Bearer / Authorization / sk-key leakage.
```

If `smoke:ai-adapter` hits sandbox `spawn EPERM`, rerun with approved escalation and record that in the QA directive.

- [ ] **Step 2: Run lint and build**

Run:

```powershell
npm run lint
npm run build
```

Expected:

```text
Main JS < 400 kB
Main CSS < 60 kB
aiContextPruning < 9 kB
```

If `npm run build` hits sandbox `spawn EPERM`, rerun with approved escalation and record that in the QA directive.

- [ ] **Step 3: Run static diff safety checks**

Run:

```powershell
git diff -G "apiKey|Authorization|Bearer|sk-|localStorage|sessionStorage" -- package.json src/lib/aiFollowUpNeeds.js tools/verify-ai-follow-up-needs-contract.mjs src/components/AiResponseReviewPanel.jsx src/components/AiResponseReviewPanel.css
git diff --name-only
```

Expected:

```text
No credential/storage additions in the diff.
Changed files remain limited to A2-2 helper, smoke, package script, Review panel, and Review panel CSS.
```

- [ ] **Step 4: Commit product implementation**

Run:

```powershell
git add package.json src/lib/aiFollowUpNeeds.js tools/verify-ai-follow-up-needs-contract.mjs src/components/AiResponseReviewPanel.jsx src/components/AiResponseReviewPanel.css
git commit -m "Add AI follow-up needs review"
```

Expected: product commit succeeds.

---

### Task 5: Open Kimi QA Directive

**Files:**
- Create: `handoff/to-kimi/2026-05-09-ai-follow-up-needs-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`

- [ ] **Step 1: Create Kimi directive**

Create `handoff/to-kimi/2026-05-09-ai-follow-up-needs-qa.md`:

```markdown
# Kimi QA Directive - AI Follow-Up Needs

## Target

Review product commit:

```text
Add AI follow-up needs review
```

## Scope

Track A2-2 local UI only:

- `package.json`
- `src/lib/aiFollowUpNeeds.js`
- `tools/verify-ai-follow-up-needs-contract.mjs`
- `src/components/AiResponseReviewPanel.jsx`
- `src/components/AiResponseReviewPanel.css`

No Track B behavior is expected.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

## Static Checkpoints

1. `src/lib/aiFollowUpNeeds.js` exists.
2. It exports `FOLLOW_UP_NEED_CATEGORIES`, `deriveAiFollowUpNeeds`, and `formatFollowUpNeedsForPrompt`.
3. Categories include Side, Mission, Unit GUID, DBID, Loadout, RP / Zone, Posture / Doctrine / EMCON, Coordinates, Weather, Response Format, and Unsafe Lua.
4. Category severities are limited to `confirm`, `format`, and `safety`.
5. Duplicate source lines do not duplicate categories.
6. Returned arrays are mutation-safe.
7. Empty parsed response returns `hasNeeds === false`.
8. `formatFollowUpNeedsForPrompt()` includes no-invention wording.
9. `package.json` includes `smoke:ai-follow-up-needs`.
10. `package-lock.json` is unchanged.
11. `AiResponseReviewPanel.jsx` derives follow-up needs.
12. Review panel renders the CMO confirmation-needs card for blocked or ask-back responses.
13. Review panel limits visible categories to 6.
14. Evidence is hidden behind `<details>`.
15. Follow-up draft includes grouped needs.
16. Follow-up draft remains text-only and is not sent automatically.
17. `AiInterpreterChatPanel.jsx` is unchanged or only receives existing draft text through props.
18. `LuaAssistant.jsx` apply gate behavior is unchanged.
19. `parseAiInterpreterResponse()` is unchanged.
20. `src/lib/aiContextPruning.js` is unchanged.
21. No `src/index.css` change.
22. No Track B behavior: no CMO folder writes, log tailing, live read-back, or backend endpoint.
23. No new dependency or devDependency.
24. No new `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, or `sessionStorage` usage.
25. Main JS remains under `400 kB`.
26. Main CSS remains under `60 kB`.
27. `aiContextPruning` remains under `9 kB`.
28. AI adapter smoke reports no raw Bearer / Authorization / sk-key leakage.

## Expected Verdict

Approve only if the Review panel makes ask-back/blocked responses more actionable without changing send/apply safety boundaries.
```
```

- [ ] **Step 2: Update current task files**

Add a short active A2-2 note to the three `CURRENT_TASK.md` files:

```markdown
## Active A2-2 - AI Follow-Up Needs

Codex opened A2-2 after A2-1 workflow-state QA approval. Kimi owns focused QA for grouped CMO confirmation needs and follow-up draft safety. Claude and Gemini remain standby unless Codex requests focused review.
```

- [ ] **Step 3: Commit and push directive**

Run:

```powershell
git add handoff/to-kimi/2026-05-09-ai-follow-up-needs-qa.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md
git commit -m "Add AI follow-up needs QA directive"
git push
```

Expected: push succeeds and Kimi has an active top-level directive.

---

### Task 6: After Kimi Approval

**Files:**
- Move: `handoff/to-kimi/2026-05-09-ai-follow-up-needs-qa.md` to `handoff/to-kimi/_archive/2026-05-09/`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`
- Modify: `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`

- [ ] **Step 1: Archive QA directive**

Run:

```powershell
Move-Item -LiteralPath handoff\to-kimi\2026-05-09-ai-follow-up-needs-qa.md -Destination handoff\to-kimi\_archive\2026-05-09\2026-05-09-ai-follow-up-needs-qa.md
```

- [ ] **Step 2: Record closeout in inventory**

Add a section:

```markdown
## Post-Release AI Follow-Up Needs - 2026-05-09

- Scope: Track A2-2 grouped CMO confirmation needs and follow-up draft polish.
- Product commit: record the one-line result of `git log --oneline --grep "Add AI follow-up needs review" -1`.
- Kimi QA: APPROVED / ARCHIVED.
- Pipeline: `smoke:ai-follow-up-needs`, `smoke:ai-workflow-state`, lint, build, AI client parser smoke, and AI adapter smoke PASS.
- Bundle baseline: record exact main JS, main CSS, aiContextPruning, and AiResponseReviewPanel lazy sizes from Kimi.
- Safety: follow-up drafts remain text-only; no automatic send; Lua apply gate unchanged; Track B remains deferred.
```

- [ ] **Step 3: Commit closeout**

Run:

```powershell
git add docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-qa.md
git commit -m "Archive AI follow-up needs QA"
git push
```

Expected: clean working tree after push.

---

## Verification Summary

Minimum product verification before Kimi:

```powershell
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

Expected no-change areas:

```text
src/lib/aiAdapterClient.js
src/lib/aiContextPruning.js
src/components/LuaAssistant.jsx
src/components/AiInterpreterChatPanel.jsx
src/index.css
server/**
package-lock.json
```

## Self-Review

- Spec coverage: The helper covers all required categories, prompt formatting, duplicate handling, empty state, and mutation safety. The Review panel renders grouped needs and drafts stronger follow-up text. QA covers no auto-send, apply gate preservation, bundle watch lines, and no Track B behavior.
- Placeholder scan: The plan uses concrete paths, commands, code, and expected output. No unresolved implementation placeholders remain.
- Type consistency: `FOLLOW_UP_NEED_CATEGORIES`, `deriveAiFollowUpNeeds`, `formatFollowUpNeedsForPrompt`, `followUpNeeds`, `visibleNeedCategories`, and `showNeedsCard` are used consistently across helper, smoke, and Review panel wiring.
