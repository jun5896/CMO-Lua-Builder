# Task 3 — Integration Readiness Note (AI Provider Adapter)

**From:** Claude (`~/.claude/cmo-lua-scripts/`)
**Trigger:** Codex signal `Task 3 pull open` (`from-codex-ui/handoff/to-claude/2026-05-03-task-3-pull-open-ai-adapter.md`)
**Deliverable:** This document — the "concise integration readiness note" Codex's directive asked for.
**Adapter implementation:** `tools/server/{ai-provider-adapter.mjs, providers.mjs, .env.example}`
**Re-verified:** 2026-05-03 — 7/7 baseline smoke tests pass + 2 extra CORS tests + log-leak audit (clean).

---

## 1. Files Codex should copy

Source paths under `~/.claude/cmo-lua-scripts/` → suggested destinations under `~/.codex/cmo-lua-ui/`:

| Source | Destination | Notes |
|---|---|---|
| `tools/server/ai-provider-adapter.mjs` | `server/ai-provider-adapter.mjs` | HTTP server, ~333 lines |
| `tools/server/providers.mjs` | `server/providers.mjs` | Provider call/test logic, ~190 lines |
| `tools/server/.env.example` | `server/.env.example` | Config template, NO real values |
| `handoff/to-codex/Task-3-AI-Adapter/ai-provider-backend-contract.md` | `docs/ai-provider-backend-contract.md` | Formal API contract |
| `handoff/to-codex/Task-3-AI-Adapter/integration-readiness-note.md` | `docs/ai-provider-integration-notes.md` (optional) | This document |
| `handoff/to-codex/Task-3-AI-Adapter/samples/*` | `docs/samples/ai-provider/*` (optional) | 5 example request/response JSONs |

**Total adapter footprint: ~530 lines of JS + 1 env template.** No build step, no transpile, no lock-file changes required.

**`.gitignore` additions (Kimi territory — let Kimi own this edit):**
```
server/.env
server/.cmo-ai-settings.json
```
(The second line is a forward-looking safeguard for the future disk-persistence task. Adding it now is harmless even if persistence never lands.)

---

## 2. Recommended npm scripts

Add to `~/.codex/cmo-lua-ui/package.json` `"scripts"` section:

```json
{
  "scripts": {
    "start:ai-adapter":   "node server/ai-provider-adapter.mjs",
    "smoke:ai-adapter":   "node server/ai-provider-adapter.mjs & sleep 1 && curl -sf http://127.0.0.1:8765/api/health && kill %1"
  }
}
```

Optional combined dev convenience:
```json
{
  "scripts": {
    "dev:with-adapter":   "concurrently \"npm:dev\" \"npm:start:ai-adapter\""
  }
}
```
This last one would require adding `concurrently` as a dev dep — **defer that decision to Codex** since `package.json` is shared and adding deps invites Kimi-owned `package-lock.json` updates.

PowerShell launcher recommendation (separate window keeps the UI hot-reload independent):
```powershell
# in start-cmo-lua-ui.ps1, add:
Start-Process -NoNewWindow:$false -FilePath "node" `
  -ArgumentList "server/ai-provider-adapter.mjs" `
  -WorkingDirectory $PSScriptRoot
```

---

## 3. Node stdlib-only?

✅ **Yes.** Verified imports in both files use only `node:*` modules:

```
ai-provider-adapter.mjs:
  node:http, node:fs, node:url, node:path, ./providers.mjs

providers.mjs:
  (no imports — uses global fetch + AbortController, both Node 18+)
```

**Runtime requirement:** Node 18+ (for native `fetch` and `AbortController`).
**Verified locally on:** Node v24.14.1.
**No external deps.** No `package.json` change in `~/.codex/cmo-lua-ui/` is required for the adapter itself — the optional npm script additions above are config only.

---

## 4. Smoke test commands and expected pass/fail

Re-verified 2026-05-03 against the adapter on this workstation. All commands assume the adapter is running on default `127.0.0.1:8765`.

### Baseline contract (7 tests — match Rev 1 results)

| # | Command | Expected |
|--:|---|---|
| 1 | `curl -sf http://127.0.0.1:8765/api/health` | 200, JSON `{ ok:true, service:"cmo-lua-ai-adapter", version:"0.1.0", ... }` |
| 2 | `curl -s http://127.0.0.1:8765/api/ai/settings` | 200, `apiKeyConfigured:false`, `apiKeyPreview:""` |
| 3 | `curl -s -X POST http://127.0.0.1:8765/api/ai/settings -H 'Content-Type: application/json' -d '{"providerType":"openai-compatible","baseUrl":"https://api.openai.com","apiKey":"sk-test-redact-12-cdef","model":"gpt-4o-mini"}'` | 200, response shows `apiKeyPreview:"sk-t***ef"`, log line shows redacted form too |
| 4 | `curl -s http://127.0.0.1:8765/api/ai/settings` (after #3) | 200, NO `apiKey` field, only `apiKeyPreview:"sk-t***ef"` |
| 5 | `curl -i -X POST http://127.0.0.1:8765/api/ai/test-provider -H 'Content-Type: application/json' -d '{"baseUrl":"http://127.0.0.1:1","apiKey":"sk-secret-must-not-leak-12-cdef","providerType":"openai-compatible"}'` | **502** sanitized; response body MUST NOT contain `sk-secret-must-not-leak-12-cdef` |
| 6 | `curl -s -X POST http://127.0.0.1:8765/api/ai/chat -H 'Content-Type: application/json' -d '{"messages":[]}'` | 400, `{ ok:false, error:"messages[] required" }` |
| 7 | `curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8765/api/nonexistent` | 404 |

### Extended security checks (2 tests added 2026-05-03)

| # | Command | Expected |
|--:|---|---|
| 8 | `curl -i -X OPTIONS http://127.0.0.1:8765/api/ai/settings -H "Origin: http://example.com" -H "Access-Control-Request-Method: POST"` | 204, `Access-Control-Allow-Origin` header **absent** (origin not in allowlist) |
| 9 | `curl -i -X OPTIONS http://127.0.0.1:8765/api/ai/settings -H "Origin: http://127.0.0.1:5173" -H "Access-Control-Request-Method: POST"` | 204, `Access-Control-Allow-Origin: http://127.0.0.1:5173` echoed |

### Log audit (manual)

After steps 3 and 5, the adapter log MUST show only redacted forms:
```
[adapter] settings updated: provider=openai-compatible model=gpt-4o-mini key=sk-t***ef
[adapter] test-provider openai-compatible http://127.0.0.1:1 -> fail
```
Verified 2026-05-03: log contains zero occurrences of `sk-test-redact-12-cdef` or `sk-secret-must-not-leak-12-cdef`.

### Pass criteria

**All 9 tests + log audit must pass after pull. If any fails, do NOT wire to UI — file `Task 3 calibration open` (analogous to Task 2's signal pattern).**

---

## 5. API contract (5 endpoints)

### `GET /api/health`

**Purpose:** UI startup reachability probe.
**Auth:** none.
**Body:** none.
**Response 200:**
```json
{
  "ok": true,
  "service": "cmo-lua-ai-adapter",
  "version": "0.1.0",
  "providerType": "openai-compatible",
  "baseUrl": "",
  "model": ""
}
```
**UI rule:** if non-200 or unreachable → render "AI backend not running" badge; disable AI features but keep manual-prompt-copy fallback active.

### `GET /api/ai/settings`

**Purpose:** read current provider config (redacted).
**Auth:** none.
**Body:** none.
**Response 200:**
```json
{
  "ok": true,
  "settings": {
    "providerType": "openai-compatible",
    "baseUrl": "https://api.openai.com",
    "model": "gpt-4o-mini",
    "temperature": 0.7,
    "maxTokens": 1024,
    "apiKeyConfigured": true,
    "apiKeyPreview": "sk-t***ef",
    "supportedProviders": ["openai-compatible","ollama","lm-studio"]
  }
}
```
**Stable fields:**
- `apiKeyConfigured` (bool) — show "Set ✓" / "Not configured" badge
- `apiKeyPreview` (string) — masked, display next to the password input as confirmation
- `supportedProviders` (string[]) — drive the providerType dropdown
- `apiKey` field is **never** present

### `POST /api/ai/settings`

**Purpose:** update provider config in memory (no disk persist in Phase A).
**Auth:** none.
**Body** (all fields optional, but UI typically sends all):
```json
{
  "providerType": "openai-compatible",
  "baseUrl":      "https://api.openai.com",
  "apiKey":       "sk-...",
  "model":        "gpt-4o-mini",
  "temperature":  0.7,
  "maxTokens":    1024
}
```
**Response 200:** same shape as `GET /api/ai/settings` (apiKey echoed only as preview).
**Response 400:** `{ ok:false, error:"Unsupported providerType. Supported: openai-compatible, ollama, lm-studio" }` — for invalid `providerType`; or `{ ok:false, error:"Invalid JSON body" }` for malformed.
**UI rule:** the apiKey input is a password field. Send only when user clicks Save with a non-empty value; otherwise omit the key from the payload to preserve the existing one.

### `POST /api/ai/test-provider`

**Purpose:** ping configured provider before saving / after configure.
**Auth:** none.
**Body** (optional overrides, used for "test before save" UX):
```json
{
  "providerType": "openai-compatible",
  "baseUrl":      "https://api.openai.com",
  "apiKey":       "sk-...",
  "model":        "gpt-4o-mini"
}
```
- Without body: tests the saved config.
- With body: overrides for THIS call only — does not modify saved config.

**Response 200 (reachable):**
```json
{ "ok":true, "status":200, "providerType":"openai-compatible", "baseUrl":"https://api.openai.com", "reached":true }
```
**Response 502 (failure):**
```json
{ "ok":false, "providerType":"...", "baseUrl":"...", "errorCode":null, "errorMessage":"fetch failed" }
```
Model list is intentionally NOT echoed (keeps response surface small). UI displays ✅ / ⚠️ icon + the (already-known) baseUrl.

### `POST /api/ai/chat`

**Purpose:** proxy a chat-completion request to the upstream provider.
**Auth:** none.
**Body:**
```json
{
  "messages": [
    {"role":"system","content":"..."},
    {"role":"user","content":"..."}
  ],
  "temperature": 0.3,
  "maxTokens":   2048,
  "providerOverride": {
    "providerType":"openai-compatible","baseUrl":"...","apiKey":"...","model":"..."
  }
}
```
- `messages[]` is required and must be non-empty.
- `temperature`, `maxTokens` optional; falls back to saved settings.
- `providerOverride` optional; per-call override without modifying saved config.

**Success response** (status forwarded from upstream):
```json
{
  "ok": true,
  "providerType": "openai-compatible",
  "baseUrl": "https://api.openai.com",
  "model": "gpt-4o-mini",
  "response": { /* upstream JSON verbatim */ }
}
```
**UI extraction rules:**
- `openai-compatible` / `lm-studio`: `out.response.choices[0].message.content`
- `ollama`: `out.response.message.content`

**Validation 400:**
- `messages[] required`
- `baseUrl not configured`
- `model not configured`

**Upstream error 502:** sanitized `{ ok:false, providerType, baseUrl, model, errorCode, errorMessage }`. Never includes the API key, request headers, or echoed upstream headers.

---

## 6. UI integration checklist

A complete Settings + Send-to-AI flow with manual-fallback preserved:

### A. Settings panel fields

- [ ] `providerType` — `<select>` populated from `settings.supportedProviders`
- [ ] `baseUrl` — `<input type="text">`, placeholder by providerType (e.g. `https://api.openai.com`, `http://localhost:11434`, `http://localhost:1234`)
- [ ] `apiKey` — `<input type="password">`; show `settings.apiKeyPreview` as a small label next to it ("Currently: sk-t***ef" / "Not configured")
- [ ] `model` — `<input type="text">`, free-form (model lists deferred)
- [ ] `temperature` — `<input type="range" min=0 max=2 step=0.1>` or number input
- [ ] `maxTokens` — `<input type="number">`
- [ ] **Save** button → `POST /api/ai/settings` (omit `apiKey` from body if user didn't change it)
- [ ] **Status indicator** — `apiKeyConfigured` reflects via badge; turn green when set

### B. Provider test button

- [ ] **Test connection** button next to Save
- [ ] Click → `POST /api/ai/test-provider` with current form values (NOT saved values, so user can test before saving)
- [ ] On `ok:true` → green ✅ "Reached `<baseUrl>`"
- [ ] On `ok:false` → amber ⚠️ "`<errorMessage>`" (truncated to 80 chars in UI; full text on hover)
- [ ] Disable button while in flight; spinner

### C. AI request prompt send button

- [ ] **Send to AI** button in LuaAssistant (next to existing manual-copy button)
- [ ] Disabled when:
  - `/api/health` reports unreachable, OR
  - `apiKeyConfigured:false` AND `providerType` is `openai-compatible` (Ollama / LM Studio can run without key)
- [ ] On click:
  1. Build prompt via existing `buildAssistantPrompt()`
  2. Wrap as `{ messages: [{role:"user", content: prompt}] }` (or system+user split if you prefer)
  3. `POST /api/ai/chat` with default `temperature` and `maxTokens` from settings
  4. Show streaming-style typewriter UI of the response (even though the server is single-shot — animate the final text)
  5. Show output in the same panel that currently displays manual-copy text
- [ ] Cancel button visible during call (UI calls `AbortController.abort()` on the fetch)

### D. Error / status display

- [ ] Toast / inline banner area in the AI panel
- [ ] Statuses to render:
  - `health-down` — adapter unreachable
  - `not-configured` — `apiKeyConfigured:false` for a provider that needs one
  - `test-failed` — last `test-provider` call returned `ok:false`
  - `chat-failed` — last `chat` call returned `ok:false`
  - `validation-failed` — 400 from any endpoint
- [ ] Each status maps to a single human-readable line + a "Retry" button when applicable
- [ ] **Never display raw upstream JSON** — extract `errorMessage` and show only that

### E. Manual prompt copy fallback (REQUIRED — preserved)

This is non-negotiable per the Codex directive ("manual prompt copy fallback remains available"):

- [ ] The existing **Copy Prompt** button MUST remain functional regardless of adapter state
- [ ] When adapter is unreachable: hide "Send to AI" but KEEP "Copy Prompt"
- [ ] When chat call fails: still allow user to fall back to "Copy Prompt" → paste into Chatbox / browser AI
- [ ] Display a hint near the Copy button: "Or paste into your preferred AI client" — keeps manual workflow first-class

### F. (Optional but recommended) Settings persistence transparency

- [ ] On Settings page, show a small note: "Settings are kept in memory only. Restart the adapter and re-enter your key."
  - This documents the Phase A constraint explicitly so users aren't confused when settings vanish on restart.
  - Will be removed when Codex opens the secure-storage task.

---

## Compliance with Codex's required security properties (re-checked 2026-05-03)

| Codex requirement | Implementation | Verified |
|---|---|---|
| Bind only to `127.0.0.1` | `server.listen(PORT, '127.0.0.1', ...)` | ✅ never `0.0.0.0` |
| Never read Chatbox user-data / ASAR / stored keys | No filesystem reads outside `tools/server/.env` and the script's own dir | ✅ confirmed in `fixtures/chatbox-structure-notes.md` |
| Never log API keys | `redactKey()` used in every log line; `logSafe()` strips `Bearer .*` and `sk-.*` patterns | ✅ smoke-test #3 + log audit |
| Never return raw API keys in any GET response | `redactedConfig()` excludes `apiKey` field; only `apiKeyPreview` | ✅ smoke-test #4 |
| Disk persistence off in Phase A | No `writeFileSync`/`writeFile` calls anywhere; settings live in `const config` only | ✅ grep verified |
| CORS allowlist limited to local Vite dev/preview | 4 origins: `127.0.0.1:5173`, `localhost:5173`, `127.0.0.1:4173`, `localhost:4173` | ✅ smoke-tests #8 + #9 |
| Upstream errors sanitized | `sanitizeError()` returns `{ providerType, baseUrl, model, errorCode, errorMessage }`, no headers / no key | ✅ smoke-test #5 |

---

## Codex pull workflow (suggested order)

1. `git status` clean check (Kimi)
2. Copy 3 source files (adapter, providers, .env.example) into `~/.codex/cmo-lua-ui/server/`
3. Copy contract + this readiness note into `~/.codex/cmo-lua-ui/docs/`
4. Add the 2 lines to `.gitignore` (Kimi)
5. Add npm script(s) to `package.json`
6. Re-run all 9 smoke tests in the codex workspace — all must pass
7. Wire the Settings panel + Send-to-AI button per checklist §6
8. Run `npm run lint` + `npm run build` (Kimi)
9. Codex commits when all clean

---

## What I am NOT doing (per directive)

- ❌ No edits to `~/.codex/`
- ❌ No disk persistence implementation (deferred to a later "secure storage" task)
- ❌ No browser-control / extension automation (out of scope)
- ❌ No Chatbox import / key extraction (forbidden)
- ❌ No streaming responses (deferred; current is single-shot)
- ❌ No `.gitignore` / `package-lock.json` / `package.json` edits in any workspace (Kimi territory)
- ❌ No edits to `LuaAssistant.jsx`, `App.jsx`, `index.css` (Codex territory)

---

## Wait state after this note

Per directive: "After preparing the readiness note, return to monitoring."

Claude is back in monitoring mode. Future trigger signals (unchanged set):

- `Task 2 calibration open` — Codex finds field mismatch during integration
- `Task 3 calibration open` — Codex finds adapter API mismatch during integration (NEW name suggested for symmetry; Codex picks final naming)
- `Parser defect` — real CMO parse defect

If Codex needs adapter changes (e.g., add streaming, change CORS, add an endpoint) Claude can patch within the workspace and surface a new Rev under `tools/server/`.
