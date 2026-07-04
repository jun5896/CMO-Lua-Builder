# Local Confirmed Context Workspace Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Track A3 so the local AI editor can store source-labeled CMO-confirmed values, reuse them in prompts and follow-up drafts, and keep all persistence inside the existing temp session flow.

**Architecture:** Add one pure helper with a focused Node smoke test, then wire confirmed context into `LuaAssistant.jsx` state, prompt construction, temp session restore, and the existing Context tab. Finally pass confirmed context into `AiResponseReviewPanel` so follow-up drafts can include already-confirmed facts without auto-sending.

**Tech Stack:** React 19, Vite, plain JavaScript ES modules, existing Node smoke scripts, no new dependencies, no new backend endpoint, no new test framework.

---

## File Structure

- Create `src/lib/aiConfirmedContext.js`: pure normalization, source labels, display grouping, and prompt/follow-up formatting.
- Create `tools/verify-ai-confirmed-context-contract.mjs`: focused smoke for normalization, duplicate collapse, prompt formatting, mutation safety, empty state, and secret redaction.
- Modify `package.json`: add `smoke:ai-confirmed-context`.
- Modify `src/components/LuaAssistant.jsx`: add `confirmedContext` state, prompt integration, temp session integration, Context tab UI, and pruning context pass-through.
- Modify `src/components/AiResponseReviewPanel.jsx`: accept confirmed context and include it in user-triggered follow-up drafts.
- Create `handoff/to-kimi/2026-05-09-local-confirmed-context-workspace-qa.md`: focused QA directive after the product commit.
- Modify `handoff/to-kimi/CURRENT_TASK.md`, `handoff/to-claude/CURRENT_TASK.md`, and `handoff/to-gemini/CURRENT_TASK.md`: record active QA state and current A3 baseline.

## Invariants

- Do not modify `src/index.css`; Main CSS is at `59.14 kB` with limited headroom.
- Do not add a backend endpoint.
- Do not read or write CMO scenario folders, logs, or live game state.
- Do not add a new dependency or modify `package-lock.json`.
- Do not add a new durable storage channel for confirmed context.
- Existing temp session/autosave may continue using its current storage path.
- Do not persist provider credentials, raw API keys, Bearer tokens, Authorization headers, or `sk-` values.
- Do not weaken `parseAiInterpreterResponse()`, `deriveAiWorkflowState()`, or `aiContextPruning` hard blocks.
- `aiParsedResponse.isPasteReady` remains the only Lua apply gate.
- Follow-up drafts remain text-only and user-triggered.

---

### Task 1: Add Confirmed Context Helper And Smoke Contract

**Files:**
- Create: `src/lib/aiConfirmedContext.js`
- Create: `tools/verify-ai-confirmed-context-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Add the package script**

In `package.json`, add this script near the existing AI smoke scripts:

```json
"smoke:ai-confirmed-context": "node tools/verify-ai-confirmed-context-contract.mjs",
```

Do not modify `package-lock.json`.

- [ ] **Step 2: Create the failing smoke script**

Create `tools/verify-ai-confirmed-context-contract.mjs` before creating the helper:

```javascript
#!/usr/bin/env node
import assert from 'node:assert/strict';
import {
  CONFIRMED_CONTEXT_SOURCES,
  CONFIRMED_CONTEXT_TYPES,
  formatConfirmedContextForFollowUp,
  formatConfirmedContextForPrompt,
  getConfirmedContextDisplayGroups,
  hasConfirmedContextEntries,
  makeConfirmedContextEntry,
  normalizeConfirmedContextEntries,
} from '../src/lib/aiConfirmedContext.js';

const entries = normalizeConfirmedContextEntries([
  {
    type: 'side',
    value: 'Blue',
    source: 'manual-cmo-ui',
    sourceDetail: 'CMO side list',
  },
  {
    type: 'side',
    value: 'Blue',
    source: 'manual-cmo-ui',
    sourceDetail: 'Duplicate from CMO side list',
  },
  {
    type: 'unitGuid',
    label: 'AEW #1',
    value: '2f25a7d1-aaaa-bbbb-cccc-0123456789ab',
    source: 'copy-unit-guid',
  },
  {
    type: 'dbid',
    value: '2990',
    source: 'database-viewer',
  },
  {
    type: 'loadout',
    value: '1404',
    source: 'database-viewer',
  },
  {
    type: 'rpZone',
    value: 'CAP Box North',
    source: 'scenario-sidecar-summary',
  },
  {
    type: 'note',
    value: 'Authorization: Bearer sk-secret-value',
    source: 'manual-cmo-ui',
  },
]);

assert.equal(CONFIRMED_CONTEXT_TYPES.length, 10);
assert.equal(CONFIRMED_CONTEXT_SOURCES.length, 6);
assert.equal(entries.length, 6);
assert.equal(hasConfirmedContextEntries(entries), true);
assert.equal(entries.find((entry) => entry.type === 'note').value, '<REDACTED>');
assert.equal(entries.find((entry) => entry.type === 'side').label, 'Blue');

const promptSection = formatConfirmedContextForPrompt(entries);
assert.match(promptSection, /## User-confirmed CMO values/);
assert.match(promptSection, /Side: Blue/);
assert.match(promptSection, /Unit GUID: AEW #1 = 2f25a7d1-aaaa-bbbb-cccc-0123456789ab/);
assert.match(promptSection, /DBID: 2990/);
assert.match(promptSection, /Use these exact values when relevant/);
assert.match(promptSection, /ask back instead of inventing/);
assert.doesNotMatch(promptSection, /sk-secret-value/);

const followUpSection = formatConfirmedContextForFollowUp(entries);
assert.match(followUpSection, /Already confirmed CMO values/);
assert.match(followUpSection, /Loadout ID: 1404/);
assert.doesNotMatch(followUpSection, /Authorization/);

const groups = getConfirmedContextDisplayGroups(entries);
assert.equal(groups.some((group) => group.type === 'side' && group.entries.length === 1), true);
assert.equal(groups.some((group) => group.type === 'unitGuid' && group.label === 'Unit GUID'), true);

const made = makeConfirmedContextEntry({
  type: 'weather',
  value: 'Sea state 2-3',
  source: 'manual-cmo-ui',
  notes: 'Confirmed before random weather event',
});
assert.equal(made.type, 'weather');
assert.equal(made.label, 'Sea state 2-3');
assert.equal(made.sourceLabel, 'CMO UI');

const emptyEntries = normalizeConfirmedContextEntries([]);
assert.equal(hasConfirmedContextEntries(emptyEntries), false);
assert.equal(formatConfirmedContextForPrompt(emptyEntries), '');
assert.equal(formatConfirmedContextForFollowUp(emptyEntries), '');
assert.deepEqual(getConfirmedContextDisplayGroups(emptyEntries), []);

const mutationInput = [{ type: 'mission', value: 'CAP North', source: 'manual-cmo-ui' }];
const normalizedOnce = normalizeConfirmedContextEntries(mutationInput);
normalizedOnce[0].value = 'MUTATED';
const normalizedAgain = normalizeConfirmedContextEntries(mutationInput);
assert.equal(normalizedAgain[0].value, 'CAP North');

console.log('PASS - confirmed context helper contract holds.');
```

- [ ] **Step 3: Run the smoke and confirm it fails for the missing helper**

Run:

```powershell
npm run smoke:ai-confirmed-context
```

Expected: FAIL with a module-not-found error for `src/lib/aiConfirmedContext.js`.

- [ ] **Step 4: Create the helper**

Create `src/lib/aiConfirmedContext.js`:

```javascript
export const CONFIRMED_CONTEXT_TYPES = Object.freeze([
  { id: 'side', label: 'Side' },
  { id: 'mission', label: 'Mission' },
  { id: 'unitGuid', label: 'Unit GUID' },
  { id: 'dbid', label: 'DBID' },
  { id: 'loadout', label: 'Loadout ID' },
  { id: 'rpZone', label: 'RP / Zone' },
  { id: 'postureDoctrine', label: 'Posture / Doctrine / EMCON' },
  { id: 'coordinates', label: 'Coordinates' },
  { id: 'weather', label: 'Weather' },
  { id: 'note', label: 'Note' },
]);

export const CONFIRMED_CONTEXT_SOURCES = Object.freeze([
  { id: 'manual-cmo-ui', label: 'CMO UI' },
  { id: 'database-viewer', label: 'Database Viewer' },
  { id: 'copy-unit-guid', label: 'Copy unit ID' },
  { id: 'scenario-sidecar-summary', label: 'Loaded sidecar summary' },
  { id: 'template-inspector', label: 'Template Inspector' },
  { id: 'ai-ask-back-resolution', label: 'AI ask-back answer' },
]);

const DEFAULT_TYPE = 'note';
const DEFAULT_SOURCE = 'manual-cmo-ui';
const SECRET_PATTERN = /\b(?:Authorization\s*:|Bearer\s+\S+|sk-[A-Za-z0-9_-]+|apiKey\s*[:=])/i;

function optionLabel(options, id, fallback) {
  return options.find((option) => option.id === id)?.label || fallback;
}

function cleanText(value) {
  return String(value ?? '').trim();
}

function redactSecrets(value) {
  const text = cleanText(value);
  return SECRET_PATTERN.test(text) ? '<REDACTED>' : text;
}

function stableSlug(value) {
  return cleanText(value)
    .toLowerCase()
    .replace(/[^a-z0-9가-힣]+/gi, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80) || 'value';
}

function normalizeType(type) {
  const candidate = cleanText(type);
  return CONFIRMED_CONTEXT_TYPES.some((option) => option.id === candidate) ? candidate : DEFAULT_TYPE;
}

function normalizeSource(source) {
  const candidate = cleanText(source);
  return CONFIRMED_CONTEXT_SOURCES.some((option) => option.id === candidate) ? candidate : DEFAULT_SOURCE;
}

function cloneEntry(entry) {
  return { ...entry };
}

export function makeConfirmedContextEntry(entry = {}) {
  const type = normalizeType(entry.type);
  const source = normalizeSource(entry.source);
  const value = redactSecrets(entry.value ?? entry.label);

  if (!value) return null;

  const rawLabel = redactSecrets(entry.label || value);
  const label = rawLabel || value;
  const sourceDetail = redactSecrets(entry.sourceDetail);
  const notes = redactSecrets(entry.notes);
  const id = cleanText(entry.id) || `ctx_${type}_${source}_${stableSlug(value)}`;

  return {
    id,
    type,
    typeLabel: optionLabel(CONFIRMED_CONTEXT_TYPES, type, type),
    label,
    value,
    source,
    sourceLabel: optionLabel(CONFIRMED_CONTEXT_SOURCES, source, source),
    sourceDetail,
    notes,
    createdAt: cleanText(entry.createdAt),
  };
}

export function normalizeConfirmedContextEntries(entries = []) {
  const byKey = new Map();

  for (const entry of Array.isArray(entries) ? entries : []) {
    const normalized = makeConfirmedContextEntry(entry);
    if (!normalized) continue;

    const key = `${normalized.type}|${normalized.source}|${normalized.value.toLowerCase()}`;
    const existing = byKey.get(key);

    if (!existing) {
      byKey.set(key, normalized);
      continue;
    }

    byKey.set(key, {
      ...existing,
      label: existing.label || normalized.label,
      sourceDetail: existing.sourceDetail || normalized.sourceDetail,
      notes: existing.notes || normalized.notes,
      createdAt: existing.createdAt || normalized.createdAt,
    });
  }

  return Array.from(byKey.values()).map(cloneEntry);
}

export function hasConfirmedContextEntries(entries = []) {
  return normalizeConfirmedContextEntries(entries).length > 0;
}

function formatEntry(entry) {
  const valuePart = entry.label && entry.label !== entry.value
    ? `${entry.label} = ${entry.value}`
    : entry.value;
  const detail = entry.sourceDetail ? `, ${entry.sourceDetail}` : '';
  return `- ${entry.typeLabel}: ${valuePart} (source: ${entry.sourceLabel}${detail})`;
}

export function formatConfirmedContextForPrompt(entries = []) {
  const normalized = normalizeConfirmedContextEntries(entries);
  if (!normalized.length) return '';

  return [
    '## User-confirmed CMO values',
    ...normalized.map(formatEntry),
    '',
    'Use these exact values when relevant. Do not replace them with guessed alternatives. If a required value is not listed here, ask back instead of inventing it.',
  ].join('\n');
}

export function formatConfirmedContextForFollowUp(entries = []) {
  const normalized = normalizeConfirmedContextEntries(entries);
  if (!normalized.length) return '';

  return [
    'Already confirmed CMO values:',
    ...normalized.map(formatEntry),
    'Do not replace these values with guessed alternatives.',
  ].join('\n');
}

export function getConfirmedContextDisplayGroups(entries = []) {
  const normalized = normalizeConfirmedContextEntries(entries);

  return CONFIRMED_CONTEXT_TYPES
    .map((typeOption) => ({
      type: typeOption.id,
      label: typeOption.label,
      entries: normalized
        .filter((entry) => entry.type === typeOption.id)
        .map(cloneEntry),
    }))
    .filter((group) => group.entries.length > 0);
}
```

- [ ] **Step 5: Run the focused smoke**

Run:

```powershell
npm run smoke:ai-confirmed-context
```

Expected: PASS with `PASS - confirmed context helper contract holds.`

- [ ] **Step 6: Commit Task 1**

Run:

```powershell
git add package.json src/lib/aiConfirmedContext.js tools/verify-ai-confirmed-context-contract.mjs
git commit -m "Add confirmed context helper contract"
```

---

### Task 2: Wire Confirmed Context Into LuaAssistant State And Prompt

**Files:**
- Modify: `src/components/LuaAssistant.jsx`

- [ ] **Step 1: Import the helper**

Near the existing imports in `src/components/LuaAssistant.jsx`, add:

```javascript
import {
  CONFIRMED_CONTEXT_SOURCES,
  CONFIRMED_CONTEXT_TYPES,
  formatConfirmedContextForPrompt,
  getConfirmedContextDisplayGroups,
  hasConfirmedContextEntries,
  makeConfirmedContextEntry,
  normalizeConfirmedContextEntries,
} from '../lib/aiConfirmedContext';
```

- [ ] **Step 2: Make temp-session meaningful-state detection include confirmed context**

In `hasMeaningfulAssistantState()`, add this condition after the `databaseContext` diff:

```javascript
    || hasConfirmedContextEntries(state.confirmedContext)
```

- [ ] **Step 3: Add confirmed context to prompt construction**

Change the `buildAssistantPrompt()` signature to accept `confirmedContext`:

```javascript
function buildAssistantPrompt({
  source,
  objective,
  context,
  scenarioContext,
  objectContext,
  databaseContext,
  confirmedContext,
  intent,
  generatedLua,
  uiSetupText,
  engineFeedback,
  analysis,
  luaFiles,
  luaBundleAnalysis,
}) {
  const bundlePrompt = formatLuaBundlePrompt(luaFiles, luaBundleAnalysis);
  const confirmedContextPrompt = formatConfirmedContextForPrompt(confirmedContext);
```

Insert the formatted section immediately after the Database / Clipboard Context block:

```javascript
    '## Database / Clipboard Context',
    formatDatabaseContext(databaseContext),
    '',
    ...(confirmedContextPrompt ? [confirmedContextPrompt, ''] : []),
    '## User Intent',
```

- [ ] **Step 4: Add React state**

After `databaseContext` state, add:

```javascript
  const [confirmedContext, setConfirmedContext] = useState([]);
  const [confirmedContextDraft, setConfirmedContextDraft] = useState({
    type: 'side',
    value: '',
    source: 'manual-cmo-ui',
    sourceDetail: '',
    notes: '',
  });
```

- [ ] **Step 5: Add display grouping memo**

Near `activeObjectContext`, add:

```javascript
  const confirmedContextGroups = useMemo(
    () => getConfirmedContextDisplayGroups(confirmedContext),
    [confirmedContext],
  );
```

- [ ] **Step 6: Add handlers**

Near the existing context update handlers, add:

```javascript
  const updateConfirmedContextDraft = useCallback((field, value) => {
    setConfirmedContextDraft((draft) => ({ ...draft, [field]: value }));
  }, []);

  const addConfirmedContextEntry = useCallback((entry = confirmedContextDraft) => {
    const normalized = makeConfirmedContextEntry(entry);
    if (!normalized) return;

    setConfirmedContext((items) => normalizeConfirmedContextEntries([...items, normalized]));
    setConfirmedContextDraft((draft) => ({
      ...draft,
      value: '',
      sourceDetail: '',
      notes: '',
    }));
  }, [confirmedContextDraft]);

  const removeConfirmedContextEntry = useCallback((entryId) => {
    setConfirmedContext((items) => items.filter((entry) => entry.id !== entryId));
  }, []);

  const promoteDatabaseContextValue = useCallback((field, type, source, sourceDetail = '') => {
    const value = String(databaseContext[field] || '').trim();
    if (!value) return;

    addConfirmedContextEntry({
      type,
      value,
      source,
      sourceDetail,
    });
  }, [addConfirmedContextEntry, databaseContext]);
```

- [ ] **Step 7: Pass confirmed context into prompt build**

In the `prompt` `useMemo`, add `confirmedContext` to both the call and dependency list:

```javascript
      confirmedContext,
```

and:

```javascript
    [source, objective, context, scenarioContext, objectContext, databaseContext, confirmedContext, intent, generatedLua, uiSetupText, engineFeedback, analysis, luaFiles, luaBundleAnalysis],
```

- [ ] **Step 8: Store confirmed context in temp session payload**

Inside `tempSessionPayload.state`, add:

```javascript
        confirmedContext: normalizeConfirmedContextEntries(confirmedContext),
```

Add `confirmedContext` to the dependency list for that `useMemo`.

- [ ] **Step 9: Restore confirmed context from temp session**

Inside `applyAssistantState()`, after `setDatabaseContext(...)`, add:

```javascript
    setConfirmedContext(normalizeConfirmedContextEntries(state.confirmedContext || []));
```

- [ ] **Step 10: Reset confirmed context when assistant state is cleared**

In the reset state object passed to `applyAssistantState({ ... })`, add:

```javascript
      confirmedContext: [],
```

- [ ] **Step 11: Pass confirmed context to pruning context without weakening pruning**

Inside `callAiAdapter`, add `confirmedContext` to `pruningContext`:

```javascript
        confirmedContext,
```

Do not modify `src/lib/aiContextPruning.js` in this task.

- [ ] **Step 12: Run the focused smoke and lint**

Run:

```powershell
npm run smoke:ai-confirmed-context
npm run lint
```

Expected: both PASS.

- [ ] **Step 13: Commit Task 2**

Run:

```powershell
git add src/components/LuaAssistant.jsx
git commit -m "Wire confirmed context into assistant state"
```

---

### Task 3: Add Minimal Context Tab UI

**Files:**
- Modify: `src/components/LuaAssistant.jsx`

- [ ] **Step 1: Add confirmed context UI below Database / Clipboard Context**

Inside `renderContextTab()`, after the Database / Clipboard Context card and before the resize button, add this card:

```jsx
      <div className="assistant-card">
        <div className="assistant-card-title">
          <ListChecks size={16} />
          <span>Confirmed Context Workspace</span>
        </div>
        <p className="assistant-help-text">
          CMO에서 확인한 값만 보관합니다. AI는 이 값을 추측으로 대체하지 않고, 누락된 값은 다시 질문해야 합니다.
        </p>

        {confirmedContextGroups.length > 0 ? (
          <div className="object-context-summary-grid" aria-label="Confirmed CMO context values">
            {confirmedContextGroups.map((group) => (
              <section key={group.type} className="object-context-summary active">
                <span>{group.label}</span>
                <strong>{group.entries.length}</strong>
              </section>
            ))}
          </div>
        ) : (
          <p className="assistant-help-text">아직 확정 컨텍스트가 없습니다. CMO UI나 Database Viewer에서 확인한 값만 추가하세요.</p>
        )}

        {confirmedContextGroups.map((group) => (
          <div key={group.type} className="analysis-section">
            <h3>{group.label}</h3>
            <ul className="assistant-hint-list">
              {group.entries.map((entry) => (
                <li key={entry.id}>
                  <strong>{entry.label}</strong>
                  {entry.label !== entry.value ? ` = ${entry.value}` : ''}
                  <span> · {entry.sourceLabel}</span>
                  <button
                    className="btn btn-mini btn-ghost"
                    type="button"
                    onClick={() => removeConfirmedContextEntry(entry.id)}
                  >
                    제거
                  </button>
                </li>
              ))}
            </ul>
          </div>
        ))}

        <div className="database-context-grid">
          <label>
            Type
            <select value={confirmedContextDraft.type} onChange={(event) => updateConfirmedContextDraft('type', event.target.value)}>
              {CONFIRMED_CONTEXT_TYPES.map((typeOption) => (
                <option key={typeOption.id} value={typeOption.id}>{typeOption.label}</option>
              ))}
            </select>
          </label>
          <label>
            Source
            <select value={confirmedContextDraft.source} onChange={(event) => updateConfirmedContextDraft('source', event.target.value)}>
              {CONFIRMED_CONTEXT_SOURCES.map((sourceOption) => (
                <option key={sourceOption.id} value={sourceOption.id}>{sourceOption.label}</option>
              ))}
            </select>
          </label>
          <label>
            Value
            <input
              value={confirmedContextDraft.value}
              onChange={(event) => updateConfirmedContextDraft('value', event.target.value)}
              placeholder="예: Blue, CAP North, 2990, 2f25..."
            />
          </label>
          <label>
            Source detail
            <input
              value={confirmedContextDraft.sourceDetail}
              onChange={(event) => updateConfirmedContextDraft('sourceDetail', event.target.value)}
              placeholder="예: Database Viewer v516"
            />
          </label>
        </div>
        <label>Notes</label>
        <textarea
          className="database-notes-textarea"
          value={confirmedContextDraft.notes}
          onChange={(event) => updateConfirmedContextDraft('notes', event.target.value)}
          rows={3}
        />
        <button className="btn btn-secondary" type="button" onClick={() => addConfirmedContextEntry()}>
          확정 컨텍스트 추가
        </button>
      </div>
```

Use existing CSS classes only. Do not modify `src/index.css`.

- [ ] **Step 2: Add quick promote buttons under DB fields**

Below the DB/ID memo textarea in the Database / Clipboard Context card, add:

```jsx
        <div className="assistant-actions">
          <button className="btn btn-mini" type="button" onClick={() => promoteDatabaseContextValue('unitGuid', 'unitGuid', 'copy-unit-guid', 'Copied unit ID')}>
            Unit GUID 확정
          </button>
          <button className="btn btn-mini" type="button" onClick={() => promoteDatabaseContextValue('platformDbid', 'dbid', 'database-viewer', 'Platform DBID')}>
            Platform DBID 확정
          </button>
          <button className="btn btn-mini" type="button" onClick={() => promoteDatabaseContextValue('loadoutId', 'loadout', 'database-viewer', 'Loadout ID')}>
            Loadout ID 확정
          </button>
          <button className="btn btn-mini" type="button" onClick={() => promoteDatabaseContextValue('notes', 'note', 'manual-cmo-ui', 'DB/ID memo')}>
            메모 확정
          </button>
        </div>
```

- [ ] **Step 3: Run smoke, lint, and build**

Run:

```powershell
npm run smoke:ai-confirmed-context
npm run lint
npm run build
```

Expected:

- Smoke PASS.
- Lint PASS.
- Build PASS.
- Main JS below `400 kB`.
- Main CSS below `60 kB`.
- `aiContextPruning` below `9 kB`.

- [ ] **Step 4: Commit Task 3**

Run:

```powershell
git add src/components/LuaAssistant.jsx
git commit -m "Add confirmed context workspace UI"
```

---

### Task 4: Include Confirmed Context In Follow-Up Drafts

**Files:**
- Modify: `src/components/AiResponseReviewPanel.jsx`
- Modify: `src/components/LuaAssistant.jsx`

- [ ] **Step 1: Import follow-up formatter in review panel**

In `src/components/AiResponseReviewPanel.jsx`, add:

```javascript
import { formatConfirmedContextForFollowUp } from '../lib/aiConfirmedContext';
```

- [ ] **Step 2: Extend follow-up instruction builder**

Change the function signature:

```javascript
function buildFollowUpInstruction(parsedResponse, applyBlockedReason, followUpNeeds, confirmedContext = []) {
```

Then add the confirmed-context formatter after `formatFollowUpNeedsForPrompt(followUpNeeds)`:

```javascript
    formatFollowUpNeedsForPrompt(followUpNeeds),
    formatConfirmedContextForFollowUp(confirmedContext),
```

Keep the final `.filter(Boolean).join('\n\n')` behavior unchanged.

- [ ] **Step 3: Accept confirmedContext prop**

In the component props, add:

```javascript
  confirmedContext = [],
```

- [ ] **Step 4: Pass confirmed context to the draft button**

Change the follow-up draft click handler:

```jsx
              onClick={() => onDraftFollowUp(buildFollowUpInstruction(parsedResponse, applyBlockedReason, followUpNeeds, confirmedContext))}
```

- [ ] **Step 5: Pass confirmedContext from LuaAssistant**

In `LuaAssistant.jsx`, update the `AiResponseReviewPanel` usage:

```jsx
                confirmedContext={confirmedContext}
```

- [ ] **Step 6: Run focused and existing AI smokes**

Run:

```powershell
npm run smoke:ai-confirmed-context
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run smoke:ai-client-parser
```

Expected: all PASS.

- [ ] **Step 7: Run lint and build**

Run:

```powershell
npm run lint
npm run build
```

Expected:

- Lint PASS.
- Build PASS.
- Main JS below `400 kB`.
- Main CSS below `60 kB`.
- `aiContextPruning` below `9 kB`.

- [ ] **Step 8: Commit Task 4**

Run:

```powershell
git add src/components/AiResponseReviewPanel.jsx src/components/LuaAssistant.jsx
git commit -m "Use confirmed context in follow-up drafts"
```

---

### Task 5: Full Product Verification

**Files:**
- No source file edits expected.

- [ ] **Step 1: Run the A3 focused pipeline**

Run:

```powershell
npm run smoke:ai-confirmed-context
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

Expected:

- All commands PASS.
- AI adapter smoke reports no raw Bearer, Authorization, or `sk-` leakage.
- Main JS remains below `400 kB`.
- Main CSS remains below `60 kB`.
- `aiContextPruning` remains below `9 kB`.

- [ ] **Step 2: Confirm product diff boundaries**

Run:

```powershell
git diff --stat HEAD~4..HEAD
git diff --name-only HEAD~4..HEAD
```

Expected changed product files:

```text
package.json
src/components/AiResponseReviewPanel.jsx
src/components/LuaAssistant.jsx
src/lib/aiConfirmedContext.js
tools/verify-ai-confirmed-context-contract.mjs
```

Expected unchanged paths:

```text
package-lock.json
src/index.css
server/
public/
```

- [ ] **Step 3: Confirm no Track B surface appeared**

Run:

```powershell
rg -n "/api/scenario/write-sidecar|log-tail|LuaHistory|ExceptionLog|CMO_SCENARIO|writeFile|unlink|rmSync|sidecar-writer" src server tools package.json
```

Expected: no new A3-introduced match for Track B writer, log tail, or filesystem write behavior.

- [ ] **Step 4: Commit if verification needs metadata only**

If no files changed during verification, do not commit.

If a small correction is required, commit only that correction:

```powershell
git add <corrected-file>
git commit -m "Stabilize confirmed context workspace"
```

---

### Task 6: Create Kimi QA Directive

**Files:**
- Create: `handoff/to-kimi/2026-05-09-local-confirmed-context-workspace-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`

- [ ] **Step 1: Create focused Kimi directive**

Create `handoff/to-kimi/2026-05-09-local-confirmed-context-workspace-qa.md` with this structure:

```markdown
# Kimi QA Directive - Local Confirmed Context Workspace

## Target

Product commits:

Record the product commit hashes from:

```powershell
git log --oneline --reverse 5bcc2b7..HEAD -- package.json src/components/AiResponseReviewPanel.jsx src/components/LuaAssistant.jsx src/lib/aiConfirmedContext.js tools/verify-ai-confirmed-context-contract.mjs
```

The expected product commit messages are:

- Add confirmed context helper contract
- Wire confirmed context into assistant state
- Add confirmed context workspace UI
- Use confirmed context in follow-up drafts

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:ai-confirmed-context
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

## Static Checkpoints

1. `src/lib/aiConfirmedContext.js` exists and exports pure helpers.
2. `tools/verify-ai-confirmed-context-contract.mjs` exists.
3. `package.json` includes `smoke:ai-confirmed-context`.
4. `package-lock.json` is unchanged.
5. `confirmedContext` is included in `tempSessionPayload.state`.
6. `applyAssistantState()` restores `confirmedContext`.
7. `hasMeaningfulAssistantState()` accounts for `confirmedContext`.
8. `buildAssistantPrompt()` includes `## User-confirmed CMO values` only when entries exist.
9. Prompt language says not to replace confirmed values with guessed alternatives.
10. Duplicate confirmed entries collapse deterministically.
11. Confirmed entries expose source labels.
12. Context tab renders confirmed context values.
13. Removing a confirmed value does not clear `objectContext` or `databaseContext`.
14. Database quick promote buttons add Unit GUID, Platform DBID, Loadout ID, and memo entries.
15. Follow-up draft includes already-confirmed values when present.
16. Follow-up remains text-only and user-triggered.
17. `AiResponseReviewPanel` apply button remains controlled by parent `canApplyLua`.
18. `aiParsedResponse.isPasteReady` remains the only Lua apply gate.
19. `src/lib/aiContextPruning.js` hard blocks are not weakened.
20. Prompt-copy fallback remains available.
21. No new backend endpoint.
22. No CMO filesystem read/write, log tailing, or sidecar writer behavior.
23. No new `localStorage` or `sessionStorage` channel for confirmed context.
24. No raw `apiKey`, `Authorization`, `Bearer`, or `sk-` persistence.
25. `src/index.css` unchanged.
26. Main JS remains below `400 kB`.
27. Main CSS remains below `60 kB`.
28. `aiContextPruning` remains below `9 kB`.
29. AI adapter smoke reports no raw auth leakage.

## Expected Verdict

Approve only if all pipeline steps and static checkpoints pass.
```

- [ ] **Step 2: Update CURRENT_TASK handoffs**

Update the three agent current task files to say:

```text
Active QA directive: 2026-05-09-local-confirmed-context-workspace-qa.md
Track A3 target: Local Confirmed Context Workspace
Track B remains deferred.
Watch lines: Main JS < 400 kB, Main CSS < 60 kB, aiContextPruning < 9 kB.
```

For Claude and Gemini, record standby/review-only status unless a focused review is explicitly requested.

- [ ] **Step 3: Commit QA directive**

Run:

```powershell
git add handoff/to-kimi/2026-05-09-local-confirmed-context-workspace-qa.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md
git commit -m "Add confirmed context workspace QA directive"
```

---

### Task 7: Archive QA And Close Out

**Files:**
- Move: `handoff/to-kimi/2026-05-09-local-confirmed-context-workspace-qa.md` to `handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-workspace-qa.md`
- Create: `docs/agent-ops/local-confirmed-context-workspace-closeout-2026-05-09.md`
- Modify: `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`

- [ ] **Step 1: Wait for Kimi APPROVED report**

Proceed only after Kimi reports all required pipeline steps and static checkpoints as approved.

- [ ] **Step 2: Archive the directive**

Move the active directive into the dated archive:

```powershell
Move-Item -LiteralPath handoff/to-kimi/2026-05-09-local-confirmed-context-workspace-qa.md -Destination handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-workspace-qa.md
```

- [ ] **Step 3: Write closeout doc**

Create `docs/agent-ops/local-confirmed-context-workspace-closeout-2026-05-09.md` with:

```markdown
# Local Confirmed Context Workspace Closeout - 2026-05-09

## Status

APPROVED / ARCHIVED

## Product Scope

- Track A3 local editor feature.
- Confirmed context helper and smoke contract.
- Confirmed context prompt integration.
- Existing temp session persistence only.
- Context tab UI.
- Text-only follow-up draft reuse.

## Verification

- `npm run smoke:ai-confirmed-context`: PASS
- `npm run smoke:ai-follow-up-needs`: PASS
- `npm run smoke:ai-workflow-state`: PASS
- `npm run lint`: PASS
- `npm run build`: PASS
- `npm run smoke:ai-client-parser`: PASS
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage

## Bundle Baseline

- Main JS: record the exact `index-*.js` size from the approved build output.
- Main CSS: record the exact `index-*.css` size from the approved build output.
- `aiContextPruning`: record the exact lazy chunk size from the approved build output.

## Invariants Preserved

- Track B remains deferred.
- No backend endpoint added.
- No CMO filesystem read/write added.
- No log tailing added.
- No sidecar writer added.
- No new dependency.
- No `package-lock.json` drift.
- No `src/index.css` change.
- `aiParsedResponse.isPasteReady` remains the only Lua apply gate.
- Prompt-copy fallback remains available.
```

- [ ] **Step 4: Update inventory and handoffs**

Add a new section to `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md` after the A2 completion section:

```markdown
## Post-Release Local Confirmed Context Workspace Closeout - 2026-05-09

- Track A3 approved and archived.
- Confirmed context entries are local, source-labeled, and temp-session scoped.
- Track B remains deferred.
- Bundle watch lines remain satisfied.
```

Update Kimi, Claude, and Gemini `CURRENT_TASK.md` files to standby with the A3 closeout reference.

- [ ] **Step 5: Commit closeout**

Run:

```powershell
git add docs/agent-ops/local-confirmed-context-workspace-closeout-2026-05-09.md docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-workspace-qa.md
git commit -m "Document confirmed context workspace closeout"
```

---

## Final Verification Before Reporting Complete

Run:

```powershell
git status --short --branch
npm run smoke:ai-confirmed-context
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

Expected:

- `git status --short --branch` shows a clean working tree after the final commit.
- All scripts PASS.
- Main JS below `400 kB`.
- Main CSS below `60 kB`.
- `aiContextPruning` below `9 kB`.
- AI adapter smoke shows no raw auth leakage.

If Windows sandbox blocks Vite build with `spawn EPERM`, rerun the same build command with the approved elevated `npm run build` route and record that the first failure was sandbox-related.
