# B4 User-Triggered State Export Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a user-triggered CMO state snapshot import path that parses pasted `Tool_DumpEvents()` / `ScenEdit_GetEvent(...)` output and turns it into a safe, timestamped UI snapshot.

**Architecture:** Add a pure snapshot-import helper first, expose it through a bounded adapter endpoint second, then add a UI import panel that creates text-only follow-up drafts and optional Confirmed Context promotions. The path is manual and user-reviewed end to end.

**Tech Stack:** Node ESM, existing CMO event export parser, local adapter server, React/Vite UI, existing smoke-contract scripts.

---

## Scope Guard

This plan intentionally does not add automatic CMO export, polling, watchers, live read-back, automatic CMO execution, or automatic AI send.

## File Map

- Create `server/cmo-state-snapshot-importer.mjs`: pure helper that imports `parse()` from `tools/parse-cmo-event-export.mjs`, validates text bounds, strips raw fields, redacts text, and returns a bounded snapshot object.
- Create `tools/verify-cmo-state-snapshot-contract.mjs`: helper smoke covering parser reuse, bounds, raw stripping, redaction, and no filesystem/process mutation APIs.
- Modify `package.json`: add `smoke:cmo-state-snapshot`.
- Modify `server/ai-provider-adapter.mjs`: add `POST /api/cmo/state-snapshot/import`.
- Create `tools/verify-cmo-state-snapshot-endpoint.mjs`: endpoint smoke covering no browser root, no response raw body, redaction, bounds, and no AI/CMO execution.
- Modify `src/lib/aiAdapterClient.js`: add `importCmoStateSnapshot({ text, sourceHint })`.
- Modify `src/components/LuaAssistant.jsx`: add the user-triggered state snapshot import UI.
- Create `tools/verify-ai-adapter-client-state-snapshot-contract.mjs`: client smoke covering request shape and no automatic AI send.

## Task 1: Snapshot Import Helper

**Files:**

- Create: `server/cmo-state-snapshot-importer.mjs`
- Create: `tools/verify-cmo-state-snapshot-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Write the smoke contract first**

Create `tools/verify-cmo-state-snapshot-contract.mjs` with checks for:

```js
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { buildCmoStateSnapshot } from '../server/cmo-state-snapshot-importer.mjs';

const sample = `
<EventTriggers>
  <EventTrigger_RegularTime><ID>T1</ID><Description>Every minute</Description></EventTrigger_RegularTime>
</EventTriggers>
<EventActions>
  <EventAction_LuaScript><ID>A1</ID><Description>AI Action</Description><ScriptText>print("hello")</ScriptText></EventAction_LuaScript>
</EventActions>
<SimEvents>
  <SimEvent><ID>E1</ID><Description>AI Event</Description><Triggers><Trigger>T1</Trigger></Triggers><Actions><Action>A1</Action></Actions></SimEvent>
</SimEvents>
`;

const result = buildCmoStateSnapshot(sample, { now: '2026-05-11T00:00:00.000Z' });

assert.equal(result.source.live, false);
assert.equal(result.summary.eventCount, 1);
assert.equal(result.events[0].name, 'AI Event');
assert.equal('raw' in result.events[0], false);
assert.equal(result.events[0].luaScripts?.length ?? 0, 0);
assert.ok(result.events[0].luaScriptPreviews.length >= 1);
assert.ok(result.snapshotId.startsWith('cmo-state-'));

const redacted = buildCmoStateSnapshot('C:/Users/demo/secret sk-proj-demo Bearer demo', {
  now: '2026-05-11T00:00:00.000Z',
});
assert.ok(redacted.redaction.count >= 2);
assert.equal(JSON.stringify(redacted).includes('sk-proj-demo'), false);
assert.equal(JSON.stringify(redacted).includes('Bearer demo'), false);

assert.throws(
  () => buildCmoStateSnapshot('x'.repeat(256 * 1024 + 1)),
  /too large/i,
);

const helperSource = readFileSync(new URL('../server/cmo-state-snapshot-importer.mjs', import.meta.url), 'utf8');
assert.equal(/\bwriteFile\b|\bappendFile\b|\brm\b|\bunlink\b|\bspawn\b|\bexec\b|\bwatch\b/.test(helperSource), false);

console.log('PASS - CMO state snapshot helper contract holds.');
```

- [ ] **Step 2: Run the smoke and verify RED**

Run:

```powershell
npm run smoke:cmo-state-snapshot
```

Expected before implementation:

```text
Missing script: "smoke:cmo-state-snapshot"
```

or module-not-found for `server/cmo-state-snapshot-importer.mjs`.

- [ ] **Step 3: Add the package script**

Add to `package.json` scripts:

```json
"smoke:cmo-state-snapshot": "node tools/verify-cmo-state-snapshot-contract.mjs"
```

- [ ] **Step 4: Implement the helper**

Create `server/cmo-state-snapshot-importer.mjs` with these exports:

```js
export const MAX_CMO_STATE_IMPORT_BYTES = 256 * 1024;
export const MAX_STATE_EVENTS = 50;
export const MAX_STATE_SPECIAL_ACTIONS = 50;
export const MAX_STATE_WARNINGS = 20;
export const MAX_LUA_PREVIEW_CHARS = 600;

export function redactCmoStateText(text) {}
export function buildCmoStateSnapshot(text, options = {}) {}
```

Implementation requirements:

- Import `parse` from `../tools/parse-cmo-event-export.mjs`.
- Reject empty text with a user-readable error.
- Reject text above `MAX_CMO_STATE_IMPORT_BYTES`.
- Call `parse(redactedText, { type: sourceHint })` only when `sourceHint` is one of the parser-supported source types.
- Strip all parser `raw` fields.
- Convert `luaScripts` into `luaScriptPreviews`.
- Set `source.live = false`.
- Return `redaction.count`.

- [ ] **Step 5: Run the helper smoke**

Run:

```powershell
npm run smoke:cmo-state-snapshot
```

Expected:

```text
PASS - CMO state snapshot helper contract holds.
```

- [ ] **Step 6: Run baseline checks**

Run:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Expected:

```text
PASS
```

Build must keep Main JS < `400 kB`, Main CSS < `60 kB`, and `aiContextPruning` < `9 kB`.

- [ ] **Step 7: Commit B4.1**

Run:

```powershell
git add package.json server/cmo-state-snapshot-importer.mjs tools/verify-cmo-state-snapshot-contract.mjs
git commit -m "Add B4 CMO state snapshot helper"
```

## Task 2: Adapter Endpoint

**Files:**

- Modify: `server/ai-provider-adapter.mjs`
- Create: `tools/verify-cmo-state-snapshot-endpoint.mjs`
- Modify: `package.json`

- [ ] **Step 1: Write the endpoint smoke first**

Create `tools/verify-cmo-state-snapshot-endpoint.mjs` that starts the adapter on a test port and sends:

```http
POST /api/cmo/state-snapshot/import
Content-Type: application/json

{
  "text": "<EventTriggers></EventTriggers><SimEvents></SimEvents>",
  "sourceHint": "toolDumpEvents",
  "logsRoot": "C:/Users/demo/should-be-ignored",
  "cmoRoot": "C:/Users/demo/should-be-ignored"
}
```

Assert:

- HTTP `200`.
- Response contains `source.live === false`.
- Response does not echo `logsRoot` or `cmoRoot`.
- Response does not include parser `raw` fields.
- Response does not include raw `Bearer`, `Authorization`, or `sk-` secrets.
- Adapter source has no call to `sendCmoAiPrompt` from the endpoint.

- [ ] **Step 2: Run endpoint smoke and verify RED**

Run:

```powershell
npm run smoke:cmo-state-snapshot-endpoint
```

Expected before endpoint wiring:

```text
404
```

or missing script.

- [ ] **Step 3: Add the package script**

Add:

```json
"smoke:cmo-state-snapshot-endpoint": "node tools/verify-cmo-state-snapshot-endpoint.mjs"
```

- [ ] **Step 4: Wire the endpoint**

In `server/ai-provider-adapter.mjs`, add:

```js
if (req.method === 'POST' && pathname === '/api/cmo/state-snapshot/import') {
  const body = await readJsonOrEmpty(req);
  const snapshot = buildCmoStateSnapshot(String(body.text || ''), {
    sourceHint: body.sourceHint,
  });
  return sendJson(res, 200, deepScrubSecrets(snapshot));
}
```

Do not read root fields from the browser body.

- [ ] **Step 5: Run endpoint and release smokes**

Run:

```powershell
npm run smoke:cmo-state-snapshot
npm run smoke:cmo-state-snapshot-endpoint
npm run verify:release
```

Expected:

```text
PASS
```

- [ ] **Step 6: Commit B4.2**

Run:

```powershell
git add package.json server/ai-provider-adapter.mjs tools/verify-cmo-state-snapshot-endpoint.mjs
git commit -m "Add B4 CMO state snapshot endpoint"
```

## Task 3: UI State Snapshot Import

**Files:**

- Modify: `src/lib/aiAdapterClient.js`
- Modify: `src/components/LuaAssistant.jsx`
- Create: `tools/verify-ai-adapter-client-state-snapshot-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Write client smoke first**

Create `tools/verify-ai-adapter-client-state-snapshot-contract.mjs` asserting:

- `fetch` is called with `/api/cmo/state-snapshot/import`.
- Method is `POST`.
- Body includes `text` and optional `sourceHint`.
- Body does not include `logsRoot`, `cmoRoot`, `scenarioRoot`, or `luaRoot`.
- Client helper does not call AI send helpers.

- [ ] **Step 2: Run client smoke and verify RED**

Run:

```powershell
npm run smoke:ai-adapter-client-state-snapshot
```

Expected before implementation:

```text
Missing script
```

or missing client export.

- [ ] **Step 3: Add the client helper**

In `src/lib/aiAdapterClient.js`, export:

```js
export async function importCmoStateSnapshot({ text, sourceHint } = {}) {
  return requestJson('/api/cmo/state-snapshot/import', {
    method: 'POST',
    body: JSON.stringify({ text, sourceHint }),
  });
}
```

Use the file's existing request helper pattern.

- [ ] **Step 4: Add the UI panel**

In `src/components/LuaAssistant.jsx`, add a compact panel near the B3 log feedback controls:

- Label: `CMO 상태 스냅샷 가져오기`
- Helper text: `CMO에서 직접 복사한 Tool_DumpEvents 또는 ScenEdit_GetEvent 출력만 가져옵니다. 실시간 연결이 아닙니다.`
- Button: `스냅샷 가져오기`
- Result heading: `가져온 CMO 스냅샷`
- Follow-up button: `후속 질문 초안 만들기`

The follow-up button must only write text into the AI chat instruction field.

- [ ] **Step 5: Run client and full verification**

Run:

```powershell
npm run smoke:ai-adapter-client-state-snapshot
npm run lint
npm run build
npm run verify:release
```

Expected:

```text
PASS
```

Main CSS must remain below `60 kB`. Prefer existing CSS classes before adding new styles.

- [ ] **Step 6: Commit B4.3**

Run:

```powershell
git add package.json src/lib/aiAdapterClient.js src/components/LuaAssistant.jsx tools/verify-ai-adapter-client-state-snapshot-contract.mjs
git commit -m "Add B4 CMO state snapshot UI"
```

## Task 4: Closeout and Release

**Files:**

- Create: `docs/agent-ops/b4-user-triggered-state-export-closeout-2026-05-11.md`
- Modify: `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`
- Later modify: `README.md`

- [ ] **Step 1: Open Kimi QA after each implementation slice**

For each slice, create a focused Kimi directive and archive the report after approval.

- [ ] **Step 2: Write B4 closeout docs**

After B4.1 to B4.3 pass QA, document:

- Slice commits.
- QA archives.
- Verification baseline.
- Preserved boundaries.
- User-facing labels.
- Explicit statement that this is imported snapshot state, not live read-back.

- [ ] **Step 3: Add release marker**

Update README only after closeout QA passes. Proposed release tag:

```text
release-2026-05-11-cmo-lua-builder-state-snapshot-import
```

- [ ] **Step 4: Tag and release after Kimi release-marker QA**

Create the tag and GitHub Release only after the marker QA is approved.

## Kimi QA Expectations

Kimi should verify:

- B4 helper rejects oversize text.
- B4 helper strips parser `raw` fields.
- B4 helper bounds Lua previews.
- B4 endpoint ignores browser-provided roots.
- B4 endpoint does not call AI.
- B4 endpoint does not execute CMO Lua.
- B4 UI does not call AI automatically.
- B4 UI says imported snapshot, not live state.
- B4 follow-up remains text-only.
- B4 can promote user-selected snapshot facts only through existing Confirmed Context paths.
- Main JS < `400 kB`.
- Main CSS < `60 kB`.
- `aiContextPruning` < `9 kB`.
- AI adapter smoke has no raw auth leakage.

## Self-Review

- Spec coverage: every B4 design requirement maps to a task.
- Scope: one feature, split into helper, endpoint, UI, closeout.
- No live read-back claim: all task wording uses "snapshot" or "import".
- No automatic action: no task calls AI or CMO automatically.
