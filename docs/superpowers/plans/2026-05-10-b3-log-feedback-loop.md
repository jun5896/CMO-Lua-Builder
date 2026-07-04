# B3 Log Feedback Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a read-only CMO log feedback loop that turns recent sanitized `ExceptionLog_*.txt` and `LuaHistory_*.txt` entries into a user-reviewed AI follow-up draft.

**Architecture:** Implement B3 in three slices: a pure log-reader helper, a local adapter endpoint, and a small UI/client path that fetches sanitized logs and drafts text without auto-sending it. The browser never supplies log roots; the adapter resolves `CMO_LOGS_ROOT` or the default CMO Logs folder server-side.

**Tech Stack:** Node ESM, existing local adapter (`server/ai-provider-adapter.mjs`), React 19, Vite, existing smoke-script pattern, no new dependencies, no new test framework.

---

## File Structure

- Create `server/cmo-log-feedback-reader.mjs`: pure helper for log-root resolution, file discovery, bounded reads, redaction, entry extraction, and follow-up draft formatting.
- Create `tools/verify-cmo-log-feedback-contract.mjs`: smoke contract for helper behavior.
- Modify `server/ai-provider-adapter.mjs`: add `GET /api/cmo/log-feedback` route after helper is green.
- Create `tools/verify-cmo-log-feedback-endpoint.mjs`: smoke contract for endpoint behavior.
- Modify `src/lib/aiAdapterClient.js`: add `fetchCmoLogFeedback()` client helper.
- Modify `src/components/LuaAssistant.jsx`: add user-triggered log feedback fetch and text-only follow-up draft display near B2 sidecar status.
- Modify `package.json`: add `smoke:cmo-log-feedback` and `smoke:cmo-log-feedback-endpoint`.
- Create focused Kimi QA directives after each slice.

## Invariants

- Do not modify CMO log files.
- Do not write into the CMO install folder.
- Do not read arbitrary browser-supplied roots.
- Do not add background polling or filesystem watchers.
- Do not auto-send AI follow-up requests.
- Do not automatically execute CMO Lua.
- Do not claim live read-back.
- Do not add dependencies or modify `package-lock.json`.
- Keep adapter bind host as `127.0.0.1`.
- Keep manual prompt-copy fallback visible.
- Keep Lua apply and sidecar save gated by `aiParsedResponse.isPasteReady === true`.
- Main CSS is close to the `60 kB` watch line; reuse existing classes.

## Claude Review Refinements For B3.1

Claude returned `APPROVED with refinements` for this plan. B3.1 must supersede the earlier helper snippets where needed:

- Use a positioned tail read (`fs.open` + `fd.read`) for log content. Do not `readFile()` the whole `ExceptionLog_*.txt` or `LuaHistory_*.txt` before applying `maxBytes`.
- Add a smoke fixture at least `2x maxBytes` so the contract proves the giant prefix is not returned while the final diagnostic lines are.
- Implement the `since` option in the helper contract. Timestamped lines older than the ISO marker must be filtered out.
- Expand redaction tests for `C:/Users/...`, lowercase drive paths such as `c:\...`, and UNC paths such as `\\server\share\...`.
- Add source-level smoke guards proving the helper does not use `spawn`, `exec`, `writeFile`, `appendFile`, `truncate`, `unlink`, `rename`, or full-log `readFile`.

---

### Task 1: Log Reader Helper Contract

**Files:**
- Create: `server/cmo-log-feedback-reader.mjs`
- Create: `tools/verify-cmo-log-feedback-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Add the smoke script entry**

In `package.json`, add:

```json
"smoke:cmo-log-feedback": "node tools/verify-cmo-log-feedback-contract.mjs"
```

Do not change `package-lock.json`.

- [ ] **Step 2: Create the failing smoke**

Create `tools/verify-cmo-log-feedback-contract.mjs`:

```javascript
#!/usr/bin/env node
import assert from 'node:assert/strict';
import { mkdir, mkdtemp, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {
  DEFAULT_CMO_LOGS_ROOT,
  buildCmoLogFeedback,
  redactCmoLogText,
  resolveCmoLogsRoot,
} from '../server/cmo-log-feedback-reader.mjs';

const tmp = await mkdtemp(path.join(os.tmpdir(), 'cmo-log-feedback-'));

try {
  assert.match(DEFAULT_CMO_LOGS_ROOT, /Command - Modern Operations[\\/]Logs$/);
  assert.equal(resolveCmoLogsRoot({ logsRoot: tmp }), path.resolve(tmp));

  const secretText = 'C:\\Users\\dlwls\\secret\\file.lua Authorization: Bearer abcdefgh sk-testsecret';
  const redacted = redactCmoLogText(secretText, { cmoRoot: 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Command - Modern Operations' });
  assert.doesNotMatch(redacted.text, /dlwls/);
  assert.doesNotMatch(redacted.text, /Bearer abcdefgh/);
  assert.doesNotMatch(redacted.text, /sk-testsecret/);
  assert.equal(redacted.redactionsApplied >= 2, true);

  await mkdir(tmp, { recursive: true });
  await writeFile(
    path.join(tmp, 'ExceptionLog_2026_05_10.txt'),
    [
      '2026-05-10 05:20:00 Lua execution failed at C:\\Users\\dlwls\\AiAssist\\bad.lua',
      'stack traceback: ScenEdit_SetUnit({guid="<UNIT_GUID>"})',
      '',
    ].join('\n'),
    'utf8',
  );
  await writeFile(
    path.join(tmp, 'LuaHistory_2026_05_10_052000.txt'),
    [
      'ScenEdit_RunScript("/AiAssist/AiAssist_20260510_test.lua")',
      'ERROR: unit GUID not found',
      '',
    ].join('\n'),
    'utf8',
  );

  const result = await buildCmoLogFeedback({
    logsRoot: tmp,
    kind: 'all',
    limit: 5,
    maxBytes: 12000,
  });

  assert.equal(result.ok, true);
  assert.equal(result.logsRootConfigured, true);
  assert.equal(result.files.length, 2);
  assert.equal(result.summary.filesScanned, 2);
  assert.equal(result.summary.entriesReturned >= 2, true);
  assert.match(result.followUpDraft, /Do not invent missing Side, Mission, Unit GUID, DBID, Loadout ID, RP, Zone, or coordinates/);
  assert.doesNotMatch(JSON.stringify(result), /C:\\\\Users\\\\dlwls/);
  assert.doesNotMatch(JSON.stringify(result), /sk-testsecret|Bearer abcdefgh/);
  assert.equal(result.files.every((file) => !file.path), true);
  assert.equal(result.files.every((file) => file.fileName.endsWith('.txt')), true);

  const exceptionOnly = await buildCmoLogFeedback({
    logsRoot: tmp,
    kind: 'exception',
    limit: 5,
  });
  assert.equal(exceptionOnly.files.every((file) => file.kind === 'exception'), true);

  const historyOnly = await buildCmoLogFeedback({
    logsRoot: tmp,
    kind: 'lua-history',
    limit: 5,
  });
  assert.equal(historyOnly.files.every((file) => file.kind === 'lua-history'), true);

  console.log('PASS - CMO log feedback helper contract holds.');
} finally {
  await rm(tmp, { recursive: true, force: true });
}
```

- [ ] **Step 3: Run RED**

Run:

```powershell
npm run smoke:cmo-log-feedback
```

Expected: FAIL with `ERR_MODULE_NOT_FOUND` for `server/cmo-log-feedback-reader.mjs`.

- [ ] **Step 4: Create the log reader helper**

Create `server/cmo-log-feedback-reader.mjs`:

```javascript
import { readdir, readFile, stat } from 'node:fs/promises';
import path from 'node:path';

export const DEFAULT_CMO_ROOT = 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Command - Modern Operations';
export const DEFAULT_CMO_LOGS_ROOT = path.join(DEFAULT_CMO_ROOT, 'Logs');

const LOG_PATTERNS = {
  exception: /^ExceptionLog_.*\.txt$/i,
  'lua-history': /^LuaHistory_.*\.txt$/i,
};

function clampInt(value, fallback, min, max) {
  const number = Number.parseInt(value, 10);
  if (!Number.isFinite(number)) return fallback;
  return Math.min(max, Math.max(min, number));
}

export function resolveCmoLogsRoot({ logsRoot = '' } = {}) {
  return path.resolve(logsRoot || process.env.CMO_LOGS_ROOT || DEFAULT_CMO_LOGS_ROOT);
}

function logKindForFileName(fileName) {
  if (LOG_PATTERNS.exception.test(fileName)) return 'exception';
  if (LOG_PATTERNS['lua-history'].test(fileName)) return 'lua-history';
  return '';
}

export function redactCmoLogText(value, options = {}) {
  let text = String(value || '');
  let redactionsApplied = 0;
  const apply = (pattern, replacement) => {
    text = text.replace(pattern, () => {
      redactionsApplied += 1;
      return replacement;
    });
  };

  const cmoRoot = String(options.cmoRoot || DEFAULT_CMO_ROOT).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  apply(new RegExp(`${cmoRoot}[^\\r\\n\\t ]*`, 'gi'), '<REDACTED_CMO_PATH>');
  apply(/C:\\Users\\[^\\\r\n\t ]+(?:\\[^\r\n\t ]*)?/gi, '<REDACTED_USER_PATH>');
  apply(/[A-Z]:\\[^\r\n\t ]+/g, '<REDACTED_PATH>');
  apply(/Bearer\s+[A-Za-z0-9._-]{8,}/g, '<REDACTED_SECRET>');
  apply(/Authorization:\s*[^\r\n]+/gi, 'Authorization: <REDACTED_SECRET>');
  apply(/sk-[A-Za-z0-9._-]{8,}/g, '<REDACTED_SECRET>');

  return { text, redactionsApplied };
}

async function listLogFiles(logsRoot, kind) {
  const entries = await readdir(logsRoot, { withFileTypes: true }).catch(() => []);
  const files = [];
  for (const entry of entries) {
    if (!entry.isFile()) continue;
    const fileKind = logKindForFileName(entry.name);
    if (!fileKind) continue;
    if (kind !== 'all' && kind !== fileKind) continue;
    const filePath = path.join(logsRoot, entry.name);
    const info = await stat(filePath).catch(() => null);
    files.push({
      kind: fileKind,
      fileName: entry.name,
      filePath,
      lastWriteTime: info?.mtime?.toISOString?.() || '',
      sizeBytes: info?.size || 0,
    });
  }
  return files.sort((a, b) => b.lastWriteTime.localeCompare(a.lastWriteTime) || a.fileName.localeCompare(b.fileName));
}

function tailLines(text, limit) {
  return String(text || '')
    .split(/\r?\n/)
    .map((line, index) => ({ lineNumber: index + 1, text: line.trim() }))
    .filter((line) => line.text)
    .slice(-limit);
}

function buildFollowUpDraft(files) {
  const snippets = files.flatMap((file) => file.entries.map((entry) => `- ${file.fileName}:${entry.lineNumber} ${entry.text}`));
  return [
    'Review these CMO log lines and explain the likely Lua failure.',
    'Do not invent missing Side, Mission, Unit GUID, DBID, Loadout ID, RP, Zone, or coordinates.',
    'If more CMO context is required, ask for the exact value instead of guessing.',
    '',
    ...snippets.slice(0, 12),
  ].join('\n').trim();
}

export async function buildCmoLogFeedback(options = {}) {
  const logsRoot = resolveCmoLogsRoot(options);
  const kind = ['exception', 'lua-history', 'all'].includes(options.kind) ? options.kind : 'all';
  const limit = clampInt(options.limit, 20, 1, 50);
  const maxBytes = clampInt(options.maxBytes, 24000, 4096, 65536);
  const candidates = await listLogFiles(logsRoot, kind);
  const files = [];
  let redactionsApplied = 0;
  let remaining = limit;

  for (const candidate of candidates.slice(0, 4)) {
    if (remaining <= 0) break;
    const raw = await readFile(candidate.filePath, 'utf8').catch(() => '');
    const bounded = raw.slice(-maxBytes);
    const entries = tailLines(bounded, remaining).map((entry) => {
      const redacted = redactCmoLogText(entry.text);
      redactionsApplied += redacted.redactionsApplied;
      return { ...entry, text: redacted.text };
    });
    remaining -= entries.length;
    files.push({
      kind: candidate.kind,
      fileName: candidate.fileName,
      lastWriteTime: candidate.lastWriteTime,
      sizeBytes: candidate.sizeBytes,
      entries,
    });
  }

  const entriesReturned = files.reduce((sum, file) => sum + file.entries.length, 0);

  return {
    ok: true,
    logsRootConfigured: true,
    kind,
    files,
    summary: {
      filesScanned: files.length,
      entriesReturned,
      redactionsApplied,
    },
    followUpDraft: buildFollowUpDraft(files),
  };
}
```

- [ ] **Step 5: Run GREEN**

Run:

```powershell
npm run smoke:cmo-log-feedback
```

Expected: PASS with `PASS - CMO log feedback helper contract holds.`

- [ ] **Step 6: Commit B3.1**

```powershell
git add package.json server/cmo-log-feedback-reader.mjs tools/verify-cmo-log-feedback-contract.mjs
git commit -m "Add B3 CMO log feedback helper"
```

---

### Task 2: Adapter Endpoint

**Files:**
- Modify: `server/ai-provider-adapter.mjs`
- Create: `tools/verify-cmo-log-feedback-endpoint.mjs`
- Modify: `package.json`

- [ ] **Step 1: Add endpoint smoke script**

In `package.json`, add:

```json
"smoke:cmo-log-feedback-endpoint": "node tools/verify-cmo-log-feedback-endpoint.mjs"
```

- [ ] **Step 2: Create failing endpoint smoke**

Create `tools/verify-cmo-log-feedback-endpoint.mjs`:

```javascript
#!/usr/bin/env node
import assert from 'node:assert/strict';
import { once } from 'node:events';
import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import os from 'node:os';
import path from 'node:path';

const ADAPTER_PORT = 8768;
const tmp = await mkdtemp(path.join(os.tmpdir(), 'cmo-log-feedback-endpoint-'));

function startAdapter() {
  const proc = spawn(process.execPath, ['server/ai-provider-adapter.mjs'], {
    cwd: path.resolve('.'),
    env: {
      ...process.env,
      PORT: String(ADAPTER_PORT),
      CMO_LOGS_ROOT: tmp,
    },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  let logs = '';
  proc.stdout.on('data', (chunk) => { logs += chunk.toString(); });
  proc.stderr.on('data', (chunk) => { logs += chunk.toString(); });
  return { proc, getLogs: () => logs };
}

async function waitForAdapter() {
  const started = Date.now();
  while (Date.now() - started < 5000) {
    try {
      const response = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/health`);
      if (response.ok) return;
    } catch {
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
  }
  throw new Error('adapter did not start');
}

let adapter;
try {
  await writeFile(path.join(tmp, 'ExceptionLog_2026_05_10.txt'), 'ERROR C:\\Users\\dlwls\\bad.lua sk-testsecret\n', 'utf8');
  await writeFile(path.join(tmp, 'LuaHistory_2026_05_10_052000.txt'), 'ScenEdit_RunScript("/AiAssist/test.lua")\n', 'utf8');

  adapter = startAdapter();
  await waitForAdapter();

  const response = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/cmo/log-feedback?kind=all&limit=10&logsRoot=C:\\malicious`);
  assert.equal(response.status, 200);
  const body = await response.json();
  assert.equal(body.ok, true);
  assert.equal(body.files.length, 2);
  assert.doesNotMatch(JSON.stringify(body), /dlwls|sk-testsecret|C:\\\\malicious/);
  assert.match(body.followUpDraft, /Do not invent missing Side/);

  const exceptionOnly = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/cmo/log-feedback?kind=exception`);
  const exceptionBody = await exceptionOnly.json();
  assert.equal(exceptionBody.files.every((file) => file.kind === 'exception'), true);

  assert.doesNotMatch(adapter.getLogs(), /sk-testsecret|Bearer\s+/);
  console.log('PASS - CMO log feedback endpoint contract holds.');
} finally {
  if (adapter?.proc && !adapter.proc.killed) {
    adapter.proc.kill('SIGTERM');
    await Promise.race([once(adapter.proc, 'exit'), new Promise((resolve) => setTimeout(resolve, 1000))]).catch(() => {});
  }
  await rm(tmp, { recursive: true, force: true });
}
```

- [ ] **Step 3: Run RED**

Run:

```powershell
npm run smoke:cmo-log-feedback-endpoint
```

Expected: FAIL with `404` because `/api/cmo/log-feedback` is not routed yet.

- [ ] **Step 4: Wire the endpoint**

In `server/ai-provider-adapter.mjs`, add:

```javascript
import { buildCmoLogFeedback } from './cmo-log-feedback-reader.mjs';
```

Add handler:

```javascript
async function handleCmoLogFeedback(req, res, url) {
  try {
    const result = await buildCmoLogFeedback({
      kind: url.searchParams.get('kind') || 'all',
      since: url.searchParams.get('since') || '',
      limit: url.searchParams.get('limit') || '',
      maxBytes: url.searchParams.get('maxBytes') || '',
    });
    logSafe(`cmo log feedback ${result.kind} -> ${result.summary.entriesReturned} entries`);
    return sendJson(res, 200, deepScrubSecrets(result));
  } catch (err) {
    logSafe(`cmo log feedback -> fail ${err?.message || err}`);
    return sendJson(res, 400, deepScrubSecrets({
      ok: false,
      error: 'cmo log feedback failed',
      errorMessage: trimForResponse(err?.message || err),
    }));
  }
}
```

Add route:

```javascript
if (method === 'GET' && path === '/api/cmo/log-feedback') return handleCmoLogFeedback(req, res, url);
```

- [ ] **Step 5: Run endpoint GREEN**

Run:

```powershell
npm run smoke:cmo-log-feedback-endpoint
```

Expected: PASS with `PASS - CMO log feedback endpoint contract holds.`

- [ ] **Step 6: Commit B3.2**

```powershell
git add package.json server/ai-provider-adapter.mjs tools/verify-cmo-log-feedback-endpoint.mjs
git commit -m "Add B3 CMO log feedback endpoint"
```

---

### Task 3: Client And UI Draft

**Files:**
- Modify: `src/lib/aiAdapterClient.js`
- Modify: `src/components/LuaAssistant.jsx`
- Create: `tools/verify-ai-adapter-client-log-feedback-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Add client smoke script**

In `package.json`, add:

```json
"smoke:ai-adapter-client-log-feedback": "node tools/verify-ai-adapter-client-log-feedback-contract.mjs"
```

- [ ] **Step 2: Add client helper contract**

Create `tools/verify-ai-adapter-client-log-feedback-contract.mjs`:

```javascript
#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const source = await readFile('src/lib/aiAdapterClient.js', 'utf8');
assert.match(source, /export async function fetchCmoLogFeedback/);
assert.match(source, /\/api\/cmo\/log-feedback/);
assert.doesNotMatch(source, /logsRoot/);

const ui = await readFile('src/components/LuaAssistant.jsx', 'utf8');
assert.match(ui, /fetchCmoLogFeedback/);
assert.match(ui, /CMO 로그 확인/);
assert.match(ui, /후속 질문 초안/);
assert.doesNotMatch(ui, /sendCmoAiPrompt\([^)]*logFeedback/i);

console.log('PASS - AI adapter client log feedback contract holds.');
```

- [ ] **Step 3: Run RED**

Run:

```powershell
npm run smoke:ai-adapter-client-log-feedback
```

Expected: FAIL because `fetchCmoLogFeedback` is not exported yet.

- [ ] **Step 4: Add the client helper**

In `src/lib/aiAdapterClient.js`, add:

```javascript
export async function fetchCmoLogFeedback({ kind = 'all', limit = 20 } = {}) {
  const params = new URLSearchParams();
  params.set('kind', kind);
  params.set('limit', String(limit));
  const response = await fetch(`${AI_ADAPTER_BASE_URL}/api/cmo/log-feedback?${params.toString()}`);
  return readJsonResponse(response);
}
```

Do not include a `logsRoot` field or parameter.

- [ ] **Step 5: Add UI state and button**

In `src/components/LuaAssistant.jsx`, import `fetchCmoLogFeedback` and add a local state:

```javascript
const [logFeedback, setLogFeedback] = useState({
  state: 'idle',
  message: '',
  entries: [],
  followUpDraft: '',
});
```

Add handler:

```javascript
const refreshCmoLogFeedback = async () => {
  setLogFeedback((previous) => ({
    ...previous,
    state: 'loading',
    message: 'CMO 로그를 읽어 최근 Lua 실행 결과를 확인하는 중입니다...',
  }));
  try {
    const result = await fetchCmoLogFeedback({ kind: 'all', limit: 12 });
    const entries = (result.files || []).flatMap((file) => (
      (file.entries || []).map((entry) => ({
        fileName: file.fileName,
        lineNumber: entry.lineNumber,
        text: entry.text,
      }))
    ));
    setLogFeedback({
      state: 'ok',
      message: entries.length
        ? '최근 CMO 로그를 찾았습니다. 아래 초안을 검토한 뒤 필요할 때만 AI에 보내세요.'
        : '최근 CMO Lua 오류 로그를 찾지 못했습니다.',
      entries,
      followUpDraft: result.followUpDraft || '',
    });
  } catch (error) {
    setLogFeedback({
      state: 'error',
      message: error?.message || 'CMO 로그 확인에 실패했습니다.',
      entries: [],
      followUpDraft: '',
    });
  }
};
```

Render a button and draft block near the B2 sidecar status:

```jsx
<button
  className="btn btn-secondary"
  type="button"
  onClick={refreshCmoLogFeedback}
  disabled={logFeedback.state === 'loading'}
  title="CMO Logs 폴더의 ExceptionLog/LuaHistory를 읽고 민감 경로를 제거한 후 후속 질문 초안을 만듭니다. AI에는 자동 전송하지 않습니다."
>
  CMO 로그 확인
</button>
{logFeedback.message ? (
  <div className={`ai-adapter-status inline ${logFeedback.state === 'ok' ? 'ok' : logFeedback.state === 'error' ? 'error' : 'loading'}`}>
    {logFeedback.message}
  </div>
) : null}
{logFeedback.followUpDraft ? (
  <div className="working-draft-preview">
    <strong>후속 질문 초안</strong>
    <pre>{logFeedback.followUpDraft}</pre>
  </div>
) : null}
```

Do not call `sendCmoAiPrompt` from this handler.

- [ ] **Step 6: Run client GREEN**

Run:

```powershell
npm run smoke:ai-adapter-client-log-feedback
npm run lint
npm run build
```

Expected: all PASS. Main CSS remains under `60 kB`.

- [ ] **Step 7: Commit B3.3**

```powershell
git add package.json tools/verify-ai-adapter-client-log-feedback-contract.mjs src/lib/aiAdapterClient.js src/components/LuaAssistant.jsx
git commit -m "Add B3 log feedback UI draft"
```

---

### Task 4: Verification And QA Handoff

**Files:**
- Create: `handoff/to-kimi/2026-05-10-b3-log-feedback-loop-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`
- Modify: `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- Modify: `README.md` only if B3 changes the documented verification baseline.

- [ ] **Step 1: Run full verification**

Run:

```powershell
npm run smoke:cmo-log-feedback
npm run smoke:cmo-log-feedback-endpoint
npm run smoke:ai-adapter-client-log-feedback
npm run smoke:ai-workflow-state
npm run smoke:ai-follow-up-needs
npm run smoke:ai-confirmed-context
npm run smoke:ai-adapter-client-sidecar
npm run smoke:ai-client-parser
npm run lint
npm run build
npm run smoke:ai-adapter
```

Expected: all PASS. If a Windows sandbox `spawn EPERM` appears, rerun with approved permissions and record that in the QA directive.

- [ ] **Step 2: Create Kimi QA directive**

Create `handoff/to-kimi/2026-05-10-b3-log-feedback-loop-qa.md` with these required checkpoints:

- Helper reads only `ExceptionLog_*.txt` and `LuaHistory_*.txt`.
- Helper does not write, delete, truncate, watch, or mutate files.
- Endpoint is `GET /api/cmo/log-feedback`.
- Browser cannot provide `logsRoot`.
- Query `logsRoot=C:\malicious` is ignored.
- Response contains file names only, not absolute paths.
- Response redacts user paths, CMO paths, absolute drive paths, `Bearer`, `Authorization`, and `sk-` patterns.
- Response is bounded by `limit` and `maxBytes`.
- Follow-up draft says not to invent Side, Mission, Unit GUID, DBID, Loadout ID, RP, Zone, or coordinates.
- UI does not auto-send AI requests.
- UI labels the output as a follow-up draft.
- UI says logs are read-only / redacted.
- No CMO polling, log watcher, live read-back, automatic CMO execution, or AI auto-send is introduced.
- B2 sidecar writer and `isPasteReady` gates remain unchanged.
- Manual prompt-copy fallback remains visible.
- No dependency or lockfile drift.
- Main JS remains under `400 kB`.
- Main CSS remains under `60 kB`.
- `aiContextPruning` remains under `9 kB`.
- AI adapter smoke has no raw auth leakage.

- [ ] **Step 3: Update handoffs and commit**

Update current task files and inventory, then commit:

```powershell
git add -A
git commit -m "Open B3 log feedback loop QA"
```

After Kimi approval, archive the directive and prepare B3 closeout docs.

## Self-Review

- Spec coverage: helper, endpoint, client/UI, redaction, no-auto-send, and QA gates are covered.
- Placeholder scan: no unresolved markers or open-ended implementation steps remain.
- Type consistency: helper, endpoint, client, and UI use `kind`, `limit`, `maxBytes`, `files`, `entries`, `summary`, and `followUpDraft` consistently.
- Risk posture: B3 starts read-only and user-reviewed; it does not claim live read-back or autonomous action.
