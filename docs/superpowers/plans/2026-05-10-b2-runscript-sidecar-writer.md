# B2 RunScript Sidecar Writer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Track B2 so a paste-ready AI Lua draft can be saved as a namespaced file under the CMO `Lua` root and manually executed by the user with `ScenEdit_RunScript('/AiAssist/<file>.lua')`.

**Architecture:** Implement the writer in three slices: a pure server-side writer helper with a smoke contract, a local adapter endpoint that exposes dry-run and confirmed write modes, and a small UI path gated by `aiParsedResponse.isPasteReady`. The browser never supplies arbitrary filesystem roots; the adapter resolves the CMO Lua root from `CMO_LUA_ROOT` or the known local default and only writes under `<root>\AiAssist`.

**Tech Stack:** Node ESM, existing local adapter (`server/ai-provider-adapter.mjs`), React 19, Vite, existing smoke-script pattern, no new dependencies, no new test framework.

---

## File Structure

- Create `server/cmo-lua-sidecar-writer.mjs`: pure writer helper for filename normalization, unsafe Lua checks, dry-run reports, and confirmed writes under `<CMO Lua root>\AiAssist`.
- Create `tools/verify-cmo-lua-sidecar-writer-contract.mjs`: smoke contract for helper behavior.
- Modify `server/ai-provider-adapter.mjs`: add `POST /api/cmo/lua-sidecar` route that calls the helper.
- Create `tools/verify-cmo-lua-sidecar-endpoint.mjs`: smoke contract for endpoint behavior.
- Modify `src/lib/aiAdapterClient.js`: add `saveCmoLuaSidecar()` client function.
- Modify `src/components/LuaAssistant.jsx`: add dry-run prepare and confirmed save UI near AI Lua output; reuse existing button/status classes instead of adding main CSS.
- Modify `package.json`: add `smoke:cmo-lua-sidecar-writer` and `smoke:cmo-lua-sidecar-endpoint`.
- Create `handoff/to-kimi/2026-05-10-b2-runscript-sidecar-writer-qa.md`: focused QA directive after implementation.
- Update `handoff/to-kimi/CURRENT_TASK.md`, `handoff/to-claude/CURRENT_TASK.md`, and `handoff/to-gemini/CURRENT_TASK.md` after implementation.

## Invariants

- Do not modify `.scen` files.
- Do not write to scenario folders.
- Do not create generated files under `public/`, `dist/`, or project-local sidecar directories.
- Do not automatically execute CMO Lua.
- Do not add log tailing, polling, live read-back, or AI auto-send.
- Do not add dependencies or modify `package-lock.json`.
- Keep adapter bind host as `127.0.0.1`.
- Keep manual prompt-copy fallback visible.
- Keep `aiParsedResponse.isPasteReady === true` as the only save/apply gate.
- Reject unsafe Lua surfaces before writing.
- Main CSS is close to the `60 kB` watch line; reuse existing styles.

---

### Task 1: Writer Helper Contract

**Files:**
- Create: `server/cmo-lua-sidecar-writer.mjs`
- Create: `tools/verify-cmo-lua-sidecar-writer-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Add the smoke script entry**

In `package.json`, add:

```json
"smoke:cmo-lua-sidecar-writer": "node tools/verify-cmo-lua-sidecar-writer-contract.mjs"
```

Do not change `package-lock.json`.

- [ ] **Step 2: Create the failing smoke**

Create `tools/verify-cmo-lua-sidecar-writer-contract.mjs`:

```javascript
#!/usr/bin/env node
import assert from 'node:assert/strict';
import { mkdir, mkdtemp, readFile, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {
  DEFAULT_CMO_LUA_ROOT,
  DEFAULT_SCRIPT_FOLDER,
  buildLuaSidecarReport,
  createLuaSidecar,
  sanitizeLuaSidecarFileName,
  validateLuaSidecarContent,
} from '../server/cmo-lua-sidecar-writer.mjs';

const tmp = await mkdtemp(path.join(os.tmpdir(), 'cmo-lua-sidecar-writer-'));

try {
  assert.match(DEFAULT_CMO_LUA_ROOT, /Command - Modern Operations[\\/]Lua$/);
  assert.equal(DEFAULT_SCRIPT_FOLDER, 'AiAssist');

  assert.equal(
    sanitizeLuaSidecarFileName({ slug: 'Strike Alpha' }).startsWith('AiAssist_'),
    true,
  );
  assert.equal(sanitizeLuaSidecarFileName({ fileName: 'AiAssist_safe-name_01.lua' }), 'AiAssist_safe-name_01.lua');
  assert.throws(() => sanitizeLuaSidecarFileName({ fileName: '../AiAssist_bad.lua' }), /Invalid AiAssist Lua filename/);
  assert.throws(() => sanitizeLuaSidecarFileName({ fileName: 'LuaInit.lua' }), /Invalid AiAssist Lua filename/);

  validateLuaSidecarContent('print("hello")\nScenEdit_SpecialMessage("Blue", "Ready")');
  assert.throws(() => validateLuaSidecarContent('os.execute("calc")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('io.open("x")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('require("x")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('dofile("x")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('loadfile("x")'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('package.path = "x"'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('debug.getinfo(1)'), /Unsafe Lua surface/);
  assert.throws(() => validateLuaSidecarContent('ScenEdit_RunScript("/x.lua")'), /Unsafe Lua surface/);

  const dryRun = await createLuaSidecar({
    cmoLuaRoot: tmp,
    content: 'print("AI draft")',
    slug: 'Strike Alpha',
    isPasteReady: true,
  });
  assert.equal(dryRun.mode, 'dry-run');
  assert.equal(dryRun.wroteFile, false);
  assert.equal(dryRun.confirmedDryRun, true);
  assert.equal(dryRun.confirmedWrite, false);
  assert.equal(dryRun.scriptFolder, 'AiAssist');
  assert.match(dryRun.fileName, /^AiAssist_\d{8}_\d{6}_strike-alpha\.lua$/);
  assert.match(dryRun.loaderSnippet, /^ScenEdit_RunScript\('\/AiAssist\/AiAssist_/);

  assert.throws(
    () => buildLuaSidecarReport({ cmoLuaRoot: tmp, content: 'print(1)', isPasteReady: false }),
    /isPasteReady must be true/,
  );

  await assert.rejects(
    () => createLuaSidecar({
      cmoLuaRoot: tmp,
      content: 'print("blocked")',
      slug: 'Blocked',
      isPasteReady: true,
      dryRun: false,
      confirmWrite: false,
    }),
    /confirmWrite must be true/,
  );

  const writeResult = await createLuaSidecar({
    cmoLuaRoot: tmp,
    content: 'print("write ok")',
    fileName: 'AiAssist_20260510_052500_write-ok.lua',
    isPasteReady: true,
    dryRun: false,
    confirmWrite: true,
  });
  assert.equal(writeResult.mode, 'write');
  assert.equal(writeResult.wroteFile, true);
  assert.equal(writeResult.runScriptPath, '/AiAssist/AiAssist_20260510_052500_write-ok.lua');
  assert.equal(writeResult.loaderSnippet, "ScenEdit_RunScript('/AiAssist/AiAssist_20260510_052500_write-ok.lua')");

  const written = await readFile(path.join(tmp, 'AiAssist', 'AiAssist_20260510_052500_write-ok.lua'), 'utf8');
  assert.equal(written, 'print("write ok")\n');

  await assert.rejects(
    () => createLuaSidecar({
      cmoLuaRoot: tmp,
      content: 'print("no overwrite")',
      fileName: 'AiAssist_20260510_052500_write-ok.lua',
      isPasteReady: true,
      dryRun: false,
      confirmWrite: true,
    }),
    /already exists/,
  );

  await mkdir(path.join(tmp, 'outside'), { recursive: true });
  await assert.rejects(
    () => createLuaSidecar({
      cmoLuaRoot: tmp,
      content: 'print("unsafe")',
      fileName: 'AiAssist_20260510_052500_.._unsafe.lua',
      isPasteReady: true,
      dryRun: false,
      confirmWrite: true,
    }),
    /Invalid AiAssist Lua filename/,
  );

  console.log('PASS - CMO Lua sidecar writer contract holds.');
} finally {
  await rm(tmp, { recursive: true, force: true });
}
```

- [ ] **Step 3: Run RED**

Run:

```powershell
npm run smoke:cmo-lua-sidecar-writer
```

Expected: FAIL with `ERR_MODULE_NOT_FOUND` for `server/cmo-lua-sidecar-writer.mjs`.

- [ ] **Step 4: Create the writer helper**

Create `server/cmo-lua-sidecar-writer.mjs`:

```javascript
import { mkdir, open, writeFile } from 'node:fs/promises';
import path from 'node:path';

export const DEFAULT_CMO_LUA_ROOT = 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Command - Modern Operations\\Lua';
export const DEFAULT_SCRIPT_FOLDER = 'AiAssist';

const FILE_NAME_RE = /^AiAssist_[A-Za-z0-9_-]{1,96}\.lua$/;
const UNSAFE_LUA_PATTERNS = [
  /\bos\s*\./i,
  /\bio\s*\./i,
  /\brequire\s*\(?/i,
  /\bdofile\s*\(?/i,
  /\bloadfile\s*\(?/i,
  /\bpackage\s*\./i,
  /\bdebug\s*\./i,
  /\bScenEdit_RunScript\s*\(?/i,
];

function timestampForFile(date = new Date()) {
  const pad = (value) => String(value).padStart(2, '0');
  return [
    date.getFullYear(),
    pad(date.getMonth() + 1),
    pad(date.getDate()),
    '_',
    pad(date.getHours()),
    pad(date.getMinutes()),
    pad(date.getSeconds()),
  ].join('');
}

function slugify(value) {
  const slug = String(value || 'draft')
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 48);
  return slug || 'draft';
}

export function sanitizeLuaSidecarFileName({ fileName = '', slug = '', now = new Date() } = {}) {
  const candidate = fileName || `AiAssist_${timestampForFile(now)}_${slugify(slug)}.lua`;
  if (!FILE_NAME_RE.test(candidate) || candidate.includes('..') || candidate.includes('/') || candidate.includes('\\')) {
    throw new Error('Invalid AiAssist Lua filename');
  }
  return candidate;
}

export function validateLuaSidecarContent(content) {
  const text = String(content || '').trimEnd();
  if (!text.trim()) throw new Error('Lua content is required');
  for (const pattern of UNSAFE_LUA_PATTERNS) {
    if (pattern.test(text)) throw new Error(`Unsafe Lua surface rejected: ${pattern}`);
  }
  return `${text}\n`;
}

function resolveTarget({ cmoLuaRoot, fileName }) {
  const root = path.resolve(cmoLuaRoot || process.env.CMO_LUA_ROOT || DEFAULT_CMO_LUA_ROOT);
  const folder = path.resolve(root, DEFAULT_SCRIPT_FOLDER);
  const targetFile = path.resolve(folder, fileName);
  const relative = path.relative(folder, targetFile);
  if (relative.startsWith('..') || path.isAbsolute(relative)) {
    throw new Error('Resolved target escaped AiAssist folder');
  }
  return { root, folder, targetFile };
}

export function buildLuaSidecarReport(options = {}) {
  if (options.isPasteReady !== true) throw new Error('isPasteReady must be true before saving a CMO Lua sidecar');
  const fileName = sanitizeLuaSidecarFileName(options);
  const lua = validateLuaSidecarContent(options.content);
  const { root, folder, targetFile } = resolveTarget({ cmoLuaRoot: options.cmoLuaRoot, fileName });
  const runScriptPath = `/${DEFAULT_SCRIPT_FOLDER}/${fileName}`;
  return {
    ok: true,
    mode: options.dryRun === false ? 'write' : 'dry-run',
    wroteFile: false,
    confirmedDryRun: options.dryRun !== false,
    confirmedWrite: options.confirmWrite === true,
    cmoLuaRoot: root,
    scriptFolder: DEFAULT_SCRIPT_FOLDER,
    folder,
    fileName,
    targetFile,
    runScriptPath,
    loaderSnippet: `ScenEdit_RunScript('${runScriptPath}')`,
    manualSteps: [
      'Open CMO Lua Console or the internal Lua editor.',
      'Run the loader snippet manually.',
      'Check CMO output and LuaHistory for errors.',
    ],
    lua,
  };
}

export async function createLuaSidecar(options = {}) {
  const report = buildLuaSidecarReport(options);
  if (report.mode === 'dry-run') return report;
  if (options.confirmWrite !== true) throw new Error('confirmWrite must be true for an actual CMO Lua sidecar write');
  await mkdir(report.folder, { recursive: true });
  const handle = await open(report.targetFile, 'wx');
  try {
    await writeFile(handle, report.lua, 'utf8');
  } catch (err) {
    await handle.close().catch(() => {});
    throw err;
  }
  await handle.close();
  return { ...report, wroteFile: true };
}
```

- [ ] **Step 5: Run GREEN**

Run:

```powershell
npm run smoke:cmo-lua-sidecar-writer
```

Expected: PASS with `PASS - CMO Lua sidecar writer contract holds.`

### Task 2: Adapter Endpoint Contract

**Files:**
- Modify: `server/ai-provider-adapter.mjs`
- Create: `tools/verify-cmo-lua-sidecar-endpoint.mjs`
- Modify: `package.json`

- [ ] **Step 1: Add endpoint smoke script**

In `package.json`, add:

```json
"smoke:cmo-lua-sidecar-endpoint": "node tools/verify-cmo-lua-sidecar-endpoint.mjs"
```

- [ ] **Step 2: Create failing endpoint smoke**

Create `tools/verify-cmo-lua-sidecar-endpoint.mjs`:

```javascript
#!/usr/bin/env node
import assert from 'node:assert/strict';
import { once } from 'node:events';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import os from 'node:os';
import path from 'node:path';

const ADAPTER_PORT = 8767;
const tmp = await mkdtemp(path.join(os.tmpdir(), 'cmo-lua-sidecar-endpoint-'));

function startAdapter() {
  const proc = spawn(process.execPath, ['server/ai-provider-adapter.mjs'], {
    cwd: path.resolve('.'),
    env: {
      ...process.env,
      PORT: String(ADAPTER_PORT),
      CMO_LUA_ROOT: tmp,
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

async function postSidecar(body) {
  const response = await fetch(`http://127.0.0.1:${ADAPTER_PORT}/api/cmo/lua-sidecar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const json = await response.json();
  return { status: response.status, json };
}

let adapter;
try {
  adapter = startAdapter();
  await waitForAdapter();

  const dryRun = await postSidecar({
    content: 'print("dry run")',
    fileName: 'AiAssist_20260510_060000_dry-run.lua',
    isPasteReady: true,
    cmoLuaRoot: path.join(tmp, 'malicious-root-ignored'),
  });
  assert.equal(dryRun.status, 200);
  assert.equal(dryRun.json.mode, 'dry-run');
  assert.equal(dryRun.json.wroteFile, false);
  assert.equal(dryRun.json.confirmedDryRun, true);
  assert.equal(dryRun.json.confirmedWrite, false);
  assert.equal(Object.hasOwn(dryRun.json, 'lua'), false);
  assert.equal(dryRun.json.targetFile.startsWith(path.join(tmp, 'AiAssist')), true);
  assert.equal(dryRun.json.targetFile.includes('malicious-root-ignored'), false);
  assert.equal(dryRun.json.loaderSnippet, "ScenEdit_RunScript('/AiAssist/AiAssist_20260510_060000_dry-run.lua')");

  const blocked = await postSidecar({
    content: 'print("blocked")',
    fileName: 'AiAssist_20260510_060001_blocked.lua',
    isPasteReady: true,
    dryRun: false,
  });
  assert.equal(blocked.status, 400);
  assert.match(blocked.json.errorMessage, /confirmWrite must be true/);

  const write = await postSidecar({
    content: 'print("write")',
    fileName: 'AiAssist_20260510_060002_write.lua',
    isPasteReady: true,
    dryRun: false,
    confirmWrite: true,
  });
  assert.equal(write.status, 200);
  assert.equal(write.json.wroteFile, true);
  assert.equal(Object.hasOwn(write.json, 'lua'), false);
  const written = await readFile(path.join(tmp, 'AiAssist', 'AiAssist_20260510_060002_write.lua'), 'utf8');
  assert.equal(written, 'print("write")\n');

  const unsafe = await postSidecar({
    content: 'os.execute("calc")',
    fileName: 'AiAssist_20260510_060003_unsafe.lua',
    isPasteReady: true,
  });
  assert.equal(unsafe.status, 400);
  assert.match(unsafe.json.errorMessage, /Unsafe Lua surface/);

  const notReady = await postSidecar({
    content: 'print("not ready")',
    fileName: 'AiAssist_20260510_060004_not-ready.lua',
    isPasteReady: false,
  });
  assert.equal(notReady.status, 400);
  assert.match(notReady.json.errorMessage, /isPasteReady must be true/);

  const logs = adapter.getLogs();
  assert.doesNotMatch(logs, /sk-[A-Za-z0-9]/);
  assert.doesNotMatch(JSON.stringify([dryRun.json, write.json, unsafe.json, notReady.json]), /Bearer\s+|sk-/);

  console.log('PASS - CMO Lua sidecar endpoint contract holds.');
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
npm run smoke:cmo-lua-sidecar-endpoint
```

Expected: FAIL with `404` because `/api/cmo/lua-sidecar` is not routed yet.

- [ ] **Step 4: Wire the route**

In `server/ai-provider-adapter.mjs`, add this import near the other imports:

```javascript
import { createLuaSidecar } from './cmo-lua-sidecar-writer.mjs';
```

Add this handler before the server routing block:

```javascript
async function handleCmoLuaSidecar(req, res) {
  try {
    const body = await readJsonOrEmpty(req);
    const result = await createLuaSidecar({
      content: body.content,
      slug: body.slug,
      fileName: body.fileName,
      isPasteReady: body.isPasteReady,
      dryRun: body.dryRun !== false,
      confirmWrite: body.confirmWrite === true,
    });
    logSafe(`cmo lua sidecar ${result.mode} ${result.fileName} -> ok`);
    return sendJson(res, 200, deepScrubSecrets({ ...result, lua: undefined }));
  } catch (err) {
    logSafe(`cmo lua sidecar -> fail ${err?.message || err}`);
    return sendJson(res, 400, deepScrubSecrets({
      ok: false,
      error: 'cmo lua sidecar write failed',
      errorMessage: trimForResponse(err?.message || err),
    }));
  }
}
```

Add this route near the existing route list:

```javascript
if (method === 'POST' && path === '/api/cmo/lua-sidecar') return handleCmoLuaSidecar(req, res);
```

- [ ] **Step 5: Run endpoint GREEN**

Run:

```powershell
npm run smoke:cmo-lua-sidecar-endpoint
```

Expected: PASS with `PASS - CMO Lua sidecar endpoint contract holds.`

### Task 3: UI Client And Save Controls

**Files:**
- Modify: `src/lib/aiAdapterClient.js`
- Modify: `src/components/LuaAssistant.jsx`

- [ ] **Step 1: Add the client helper**

In `src/lib/aiAdapterClient.js`, add:

```javascript
export async function saveCmoLuaSidecar(payload) {
  const response = await fetch(`${AI_ADAPTER_BASE_URL}/api/cmo/lua-sidecar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload || {}),
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok || body?.ok === false) {
    const error = new Error(body?.errorMessage || body?.error || `CMO Lua sidecar save failed (${response.status})`);
    error.status = response.status;
    error.body = body;
    throw error;
  }
  return body;
}
```

- [ ] **Step 2: Import the helper in LuaAssistant**

Change the import in `src/components/LuaAssistant.jsx` from:

```javascript
  sendCmoAiPrompt,
```

to:

```javascript
  saveCmoLuaSidecar,
  sendCmoAiPrompt,
```

- [ ] **Step 3: Add state for sidecar save status**

Near the AI call status state, add:

```javascript
const [luaSidecarSave, setLuaSidecarSave] = useState({
  state: 'idle',
  message: '',
  loaderSnippet: '',
  fileName: '',
});
```

- [ ] **Step 4: Add the save handler**

Inside `LuaAssistant`, near `applyAiLuaBlock`, add:

```javascript
const saveAiLuaSidecar = async ({ dryRun = true } = {}) => {
  if (!canApplyAiLua || !aiParsedResponse.luaBlock.trim()) {
    setLuaSidecarSave({
      state: 'error',
      message: 'paste-ready Lua 초안만 CMO Lua 파일로 저장할 수 있습니다.',
      loaderSnippet: '',
      fileName: '',
    });
    return;
  }
  setLuaSidecarSave((previous) => ({
    ...previous,
    state: 'loading',
    message: dryRun ? 'CMO Lua 파일 저장 위치를 확인하는 중입니다...' : 'CMO Lua 폴더에 파일을 저장하는 중입니다...',
  }));
  try {
    const result = await saveCmoLuaSidecar({
      content: aiParsedResponse.luaBlock,
      slug: activeIntent?.actionType || selectedTemplate?.id || 'ai-draft',
      isPasteReady: aiParsedResponse.isPasteReady,
      dryRun,
      confirmWrite: dryRun ? false : true,
    });
    setLuaSidecarSave({
      state: 'ok',
      message: dryRun
        ? `저장 준비 완료: ${result.fileName}. CMO 실행은 수동으로 확인하세요.`
        : `CMO Lua 폴더에 저장됨: ${result.fileName}. CMO에서 loader snippet을 직접 실행하세요.`,
      loaderSnippet: result.loaderSnippet || '',
      fileName: result.fileName || '',
    });
  } catch (error) {
    const alreadyExists = /already exists|EEXIST/i.test(error?.message || '');
    setLuaSidecarSave({
      state: 'error',
      message: alreadyExists
        ? '같은 이름의 AiAssist Lua 파일이 이미 있습니다. CMO 파일 준비를 다시 눌러 새 timestamp 파일명으로 재시도하세요.'
        : (error?.message || 'CMO Lua 파일 저장에 실패했습니다.'),
      loaderSnippet: '',
      fileName: '',
    });
  }
};
```

The `intent` object is already available in this component scope; use it for the slug. Do not use `selectedTemplate`, because that value is not part of this component.

- [ ] **Step 5: Add buttons near the existing AI Lua apply controls**

Near the existing AI Lua apply button group, add:

```jsx
<button
  className="btn btn-secondary"
  type="button"
  onClick={() => saveAiLuaSidecar({ dryRun: true })}
  disabled={!canApplyAiLua || luaSidecarSave.state === 'loading'}
  title="CMO Lua root 아래 AiAssist 파일 저장 위치와 RunScript 명령을 먼저 확인합니다."
>
  CMO 파일 준비
</button>
<button
  className="btn btn-secondary"
  type="button"
  onClick={() => saveAiLuaSidecar({ dryRun: false })}
  disabled={!canApplyAiLua || luaSidecarSave.state === 'loading'}
  title="paste-ready Lua 초안을 CMO Lua root의 AiAssist 폴더에 저장합니다. 실행은 CMO에서 직접 해야 합니다."
>
  CMO Lua 폴더에 저장
</button>
```

- [ ] **Step 6: Render the loader snippet**

Near the same control group, render status using existing classes:

```jsx
{luaSidecarSave.message ? (
  <div className={`ai-adapter-status inline ${luaSidecarSave.state === 'ok' ? 'ok' : luaSidecarSave.state === 'error' ? 'error' : 'loading'}`}>
    {luaSidecarSave.message}
  </div>
) : null}
{luaSidecarSave.loaderSnippet ? (
  <pre className="working-draft-preview">{luaSidecarSave.loaderSnippet}</pre>
) : null}
```

Use existing CSS classes only.

- [ ] **Step 7: Run UI build checks**

Run:

```powershell
npm run lint
npm run build
```

Expected: PASS. Main CSS must remain under `60 kB`.

### Task 4: Verification And QA Handoff

**Files:**
- Create: `handoff/to-kimi/2026-05-10-b2-runscript-sidecar-writer-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`
- Modify: `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`

- [ ] **Step 1: Run full B2 verification**

Run:

```powershell
npm run smoke:cmo-lua-sidecar-writer
npm run smoke:cmo-lua-sidecar-endpoint
npm run smoke:ai-workflow-state
npm run smoke:ai-client-parser
npm run lint
npm run build
npm run smoke:ai-adapter
```

Expected: all PASS. If build or adapter smoke hits Windows sandbox `spawn EPERM`, rerun with approved permissions and record that in the QA directive.

- [ ] **Step 2: Create Kimi QA directive**

Create `handoff/to-kimi/2026-05-10-b2-runscript-sidecar-writer-qa.md` with this structure:

- Title: `Kimi QA Directive - B2 RunScript Sidecar Writer`
- Status: `ACTIVE`
- Date: `2026-05-10`
- Target: verify Track B2 RunScript sidecar writer implementation.
- Required pipeline:
  - `git status --short --branch`
  - `npm run smoke:cmo-lua-sidecar-writer`
  - `npm run smoke:cmo-lua-sidecar-endpoint`
  - `npm run smoke:ai-workflow-state`
  - `npm run smoke:ai-client-parser`
  - `npm run lint`
  - `npm run build`
  - `npm run smoke:ai-adapter`
- Static checkpoints:
  - Writer target is CMO Lua root plus fixed `AiAssist` folder.
  - Browser/client cannot provide arbitrary filesystem root.
  - A malicious `cmoLuaRoot` field in the request body is ignored and cannot redirect the target path.
  - Actual write requires `isPasteReady: true`, `dryRun: false`, and `confirmWrite: true`.
  - Dry-run writes no file.
  - Response echoes server-confirmed `confirmedDryRun` and `confirmedWrite`.
  - Response does not include the Lua body.
  - File names are restricted to `AiAssist_*.lua`.
  - Path traversal is rejected.
  - Existing files are not overwritten.
  - Existing-file errors are surfaced as a user-recoverable "prepare again with a fresh timestamp" path.
  - Unsafe Lua surfaces are rejected.
  - Loader snippet uses `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
  - Loader snippet does not use `dofile`.
  - UI save buttons are disabled unless `canApplyAiLua` is true.
  - UI text says CMO execution is manual and CMO engine verification is still required.
  - Prompt-copy fallback remains visible.
  - `aiParsedResponse.isPasteReady` remains the save/apply gate.
  - No scenario-folder writes.
  - No `.scen` mutation.
  - No generated data under `public/` or `dist/`.
  - No log tailing, polling, live read-back, or AI auto-send.
  - No dependency or lockfile drift.
  - Main JS remains under `400 kB`.
  - Main CSS remains under `60 kB`.
  - `aiContextPruning` remains under `9 kB`.
  - AI adapter smoke shows no raw Bearer / Authorization / sk-key leakage.
- Expected verdict: report pipeline, bundle sizes, checkpoint pass count, drift, and regression.

- [ ] **Step 3: Update handoff current state**

Update Kimi, Claude, and Gemini current task files:

- Kimi: active QA directive and B2 pre-QA evidence.
- Claude: standby unless asked to review path safety or CMO assumptions.
- Gemini: standby unless asked to review Korean save/run wording.

- [ ] **Step 4: Commit implementation**

After Kimi approves:

```powershell
git add -A
git commit -m "Add B2 RunScript sidecar writer"
git push
```

If push to `origin/main` is blocked by policy, request explicit user approval before retrying.

## Self-Review

- Spec coverage: the plan covers helper, endpoint, UI gate, QA, and handoff.
- No-open-items scan: the plan avoids `TBD` markers and open-ended implementation instructions.
- Type consistency: request/response names match across helper, endpoint, client, and UI.
- Risk posture: first implementation writes only under CMO Lua root `AiAssist` namespace and never auto-executes.
