# AI Provider Backend Contract

**Task:** Claude Task 3 — AI Provider Backend Adapter
**Source spec:** Codex's relayed direction 2026-05-02 ("Chatbox식 OpenAI-compatible API 호출 구조를 참고한 로컬 AI 백엔드 어댑터")
**Implementation:** `tools/server/{ai-provider-adapter.mjs, providers.mjs, .env.example}`
**Status:** prototype delivered, smoke-tested (7/7), awaiting codex review

---

## Purpose

Local-only Node HTTP server that gives the CMO Lua UI a uniform way to call external LLM providers (OpenAI / OpenRouter / CrofAI / LM Studio / Ollama / etc.). Models the Chatbox UX of "register an OpenAI-compatible provider" without reading any Chatbox files or keys.

```
CMO Lua UI (browser, Vite)  ───HTTP───▶  ai-provider-adapter (127.0.0.1:8765, Node)
                                                   │
                                                   └─fetch(/v1/chat/completions)─▶  External provider
```

---

## Endpoints

### `GET /api/health`
Reachability check for the UI.

**Response (200):**
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

### `GET /api/ai/settings`
Returns the current provider config with API key REDACTED. See `samples/sample-settings-redacted.json`.

### `POST /api/ai/settings`
Updates provider config in memory. Body matches the redacted shape (without the `apiKeyConfigured` / `apiKeyPreview` fields — UI sends `apiKey` plaintext).

**Body:**
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

**Response (200):** redacted settings (see GET).

**Response (400):** `{ ok:false, error: "..." }` for unsupported providerType / malformed body.

**Persistence:** in-memory only in this prototype. Codex confirms the persistence story before we add disk write.

### `POST /api/ai/test-provider`
Pings the configured provider. Sends:
- `openai-compatible` / `lm-studio` → `GET /v1/models`
- `ollama` → `GET /api/tags`

Optionally accepts overrides in body so the UI can test new settings before saving.

**Body (optional):** any subset of provider config — overrides current settings for THIS call only.

**Success (200):** see `samples/sample-test-provider-success.json` — `{ ok:true, status:200, providerType, baseUrl, reached:true }`. Model list is NOT echoed back.

**Failure (502):** see `samples/sample-test-provider-failure.json` — `{ ok:false, providerType, baseUrl, errorCode, errorMessage }`. Never includes API key or upstream headers.

### `POST /api/ai/chat`
Proxies a chat-completion request.

**Body:**
```json
{
  "messages": [{"role":"user","content":"..."}],
  "temperature": 0.7,
  "maxTokens": 1024,
  "providerOverride": { "providerType":"...", "baseUrl":"...", "apiKey":"...", "model":"..." }
}
```

`providerOverride` is optional. When present, it overrides the saved settings for this single call without modifying them.

**Success:** the upstream provider response is forwarded under `response`, with context fields wrapping it (see `samples/sample-chat-response.json`). Status code reflects the upstream status.

**Validation errors (400):**
- `messages[] required`
- `baseUrl not configured`
- `model not configured`

**Upstream errors (502):** sanitized — provider type, base URL, model, error code, truncated error message. NEVER includes the API key, request headers, or full upstream body if the upstream tried to echo headers.

---

## Provider types

| Type | Path | Auth |
|---|---|---|
| `openai-compatible` | POST `/v1/chat/completions` | `Authorization: Bearer <apiKey>` |
| `lm-studio` | POST `/v1/chat/completions` (alias) | optional Bearer |
| `ollama` | POST `/api/chat` | none |

**Body shape:**

OpenAI-compatible / LM Studio:
```json
{ "model": "...", "messages": [...], "temperature": 0.7, "max_tokens": 1024 }
```

Ollama:
```json
{ "model": "...", "messages": [...], "stream": false, "options": { "temperature": 0.7, "num_predict": 1024 } }
```

---

## Security

| Rule | Implementation |
|---|---|
| Bind localhost only | `server.listen(8765, '127.0.0.1', ...)` |
| CORS allowlist | `http://127.0.0.1:5173`, `http://localhost:5173`, `:4173` (Vite preview) |
| API key never logged | `redactKey()` in log; `Bearer ...` patterns scrubbed in `logSafe()` |
| API key never returned to GET | `apiKeyPreview` is masked, full value never echoed |
| Upstream errors sanitized | `sanitizeError()` — no headers, no key, no full body |
| `.env` loaded once, not echoed | `loadEnvIfPresent()` reads at startup; vars used directly |
| No persistence in prototype | Settings are in-memory; codex reviews persistence before disk write |
| Body size cap | 1 MB (rejects with 413-equivalent error) |
| Timeout | 60 s for chat, 15 s for test-provider |
| No streaming yet | All responses non-streaming for prototype simplicity |

---

## Configuration

Three layers, lowest precedence first:
1. `.env` file in `tools/server/` (loaded at startup)
2. `process.env` (already set when the user launches Node with vars)
3. `POST /api/ai/settings` (overrides above, in memory)

Recognized env vars (also `.env.example`):
- `AI_PROVIDER_TYPE` — `openai-compatible` | `ollama` | `lm-studio`
- `AI_PROVIDER_BASE_URL`
- `AI_PROVIDER_API_KEY`
- `AI_PROVIDER_MODEL`
- `AI_PROVIDER_TEMPERATURE` — float, default 0.7
- `AI_PROVIDER_MAX_TOKENS` — int, default 1024
- `PORT` — default 8765

---

## Run

```bash
cd ~/.claude/cmo-lua-scripts
node tools/server/ai-provider-adapter.mjs
# listening on http://127.0.0.1:8765
```

Configure (one of):
```bash
# (a) .env file
cp tools/server/.env.example tools/server/.env
# edit .env

# (b) inline env vars
PORT=8765 AI_PROVIDER_BASE_URL=https://api.openai.com AI_PROVIDER_API_KEY=sk-... \
AI_PROVIDER_MODEL=gpt-4o-mini node tools/server/ai-provider-adapter.mjs

# (c) UI calls POST /api/ai/settings
curl -X POST http://127.0.0.1:8765/api/ai/settings \
  -H 'Content-Type: application/json' \
  -d '{"providerType":"openai-compatible","baseUrl":"...","apiKey":"...","model":"..."}'
```

---

## Smoke-test results (2026-05-02)

```
1. GET  /api/health                         -> 200 ok
2. GET  /api/ai/settings (default)          -> 200, key redacted
3. POST /api/ai/settings (configure)        -> 200, log shows sk-t***ef
4. GET  /api/ai/settings (after config)     -> 200, apiKey not in response
5. POST /api/ai/test-provider (unreachable) -> 502 sanitized error
6. POST /api/ai/chat (empty messages)       -> 400 validation error
7. GET  /api/nonexistent                    -> 404
```

All 7 pass. Server is responsive in <100 ms for all non-network endpoints.

---

## Field list for codex's UI integration

When wiring into LuaAssistant or a settings panel, the UI should:

1. **On startup:** `GET /api/health`. If non-OK or unreachable, show "AI backend not running" instead of attempting calls.

2. **Settings tab:** read via `GET /api/ai/settings`, write via `POST /api/ai/settings`.
   - Form fields: `providerType` (dropdown of `supportedProviders`), `baseUrl`, `apiKey` (password input), `model`, `temperature` (slider), `maxTokens` (number).
   - Show `apiKeyPreview` next to the input as a confirmation, but require re-entry to change.

3. **Test button:** `POST /api/ai/test-provider`. Show ✅ or sanitized error.

4. **Chat:** `POST /api/ai/chat` with the existing prompt body the UI already builds in `LuaAssistant.jsx::buildAssistantPrompt`. Display `response.choices[0].message.content` (OpenAI-compat) or the equivalent path for ollama.

---

## Out of scope (explicit non-goals)

- ❌ Reading Chatbox's stored keys / config — see `fixtures/chatbox-structure-notes.md`
- ❌ Streaming responses (deferred; prototype is single-shot)
- ❌ Disk persistence of settings (deferred; codex reviews approach first)
- ❌ Authentication on the local server (single-user localhost only)
- ❌ Provider auto-discovery / model list caching
- ❌ Multi-user / multi-tenancy
- ❌ Embedding API (`/v1/embeddings`)
- ❌ File upload / vision endpoints

---

## Codex review path

When ready:
1. Pull `tools/server/{ai-provider-adapter.mjs, providers.mjs, .env.example}` into `cmo-lua-ui/server/` or `cmo-lua-ui/tools/server/`.
2. Pull this contract to `cmo-lua-ui/docs/ai-provider-backend-contract.md`.
3. Update `start-cmo-lua-ui.ps1` to optionally start the adapter (codex's call).
4. Add a "Settings → AI Provider" tab in the UI that calls these endpoints.

---

## Open questions

1. Persistence: where should settings live when codex approves disk-write? Options: `tools/server/.cmo-ai-settings.json` (gitignored), OS keyring, encrypted file. Codex picks.
2. Streaming: do we need it for the AI Request flow's UX, or is single-shot OK?
3. Auth: do we ever expose this beyond localhost? If yes, codex picks the auth model (token / mTLS / Tailscale).
4. Multi-provider concurrent settings: should the UI keep a "library" of providers and switch via dropdown, or always one-at-a-time?

---

## Revision marker

| Rev | Date | Change |
|---|---|---|
| 1 | 2026-05-02 | Initial draft. 7/7 smoke tests pass. Awaiting codex review. |
