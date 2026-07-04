# Response Normalization + Error Taxonomy — Task 3B Workstream C

**From:** Claude (`~/.claude/cmo-lua-scripts/`)
**Trigger:** Codex signal `2026-05-03-task-3b-ai-interpreter-bridge-prep.md` Workstream C
**Purpose:**
1. Provide a helper contract for extracting assistant text uniformly across `openai-compatible` / `lm-studio` / `ollama` provider responses.
2. Define a minimal error taxonomy (7 codes) the UI can map to display strings.
**Status:** proposal — not implemented in Codex workspace. Tiny backend patch proposed inline; Codex picks whether to pull.

---

## 1. Why normalization helper?

`POST /api/ai/chat` returns the upstream provider's response verbatim under `body.response` (when 2xx). Different providers shape this differently:

| Provider | Path to assistant text |
|---|---|
| `openai-compatible` | `response.choices[0].message.content` |
| `lm-studio` | `response.choices[0].message.content` (alias of openai-compatible) |
| `ollama` | `response.message.content` |

The UI needs ONE function that returns `{ text, finishReason, modelEcho }` regardless of provider. Without this helper, every UI render path needs a `switch(providerType)`, which makes the LuaAssistant code brittle.

---

## 2. Proposed helper contract

A pure function. UI-side or backend-side — UI is fine since it's deterministic and small. Recommended: **export from a shared `src/lib/ai-response.js`** that both LuaAssistant and any future panel can import.

```js
/**
 * Extract canonical fields from the adapter's chat response body.
 *
 * @param {object} body - body returned by POST /api/ai/chat (the JSON, not the
 *                        whole http response). Either the 2xx success shape or
 *                        the post-patch sanitized error shape.
 * @returns {{
 *   ok: boolean,
 *   text: string | null,        // assistant message content, null on error
 *   finishReason: string | null,
 *   modelEcho: string | null,   // model name as the upstream reported it
 *   tokenUsage: {                // when the upstream provides it
 *     prompt: number | null,
 *     completion: number | null,
 *     total: number | null,
 *   } | null,
 *   errorCode: string | null,   // mapped to ErrorCode taxonomy below
 *   errorMessage: string | null,
 * }}
 */
export function extractAssistantResponse(body) { /* ... */ }
```

### Implementation skeleton

```js
export function extractAssistantResponse(body) {
  // Adapter-level error (sanitized shape from post-patch wrapUpstreamResponse)
  if (!body?.ok) {
    return {
      ok: false,
      text: null,
      finishReason: null,
      modelEcho: body?.model ?? null,
      tokenUsage: null,
      errorCode: classifyError(body),
      errorMessage: body?.errorMessage ?? 'Unknown adapter error',
    };
  }

  const r = body.response;
  switch (body.providerType) {
    case 'openai-compatible':
    case 'lm-studio': {
      const choice = r?.choices?.[0];
      return {
        ok: true,
        text: choice?.message?.content ?? null,
        finishReason: choice?.finish_reason ?? null,
        modelEcho: r?.model ?? null,
        tokenUsage: r?.usage ? {
          prompt:     r.usage.prompt_tokens ?? null,
          completion: r.usage.completion_tokens ?? null,
          total:      r.usage.total_tokens ?? null,
        } : null,
        errorCode: null,
        errorMessage: null,
      };
    }
    case 'ollama': {
      return {
        ok: true,
        text: r?.message?.content ?? null,
        finishReason: r?.done_reason ?? (r?.done ? 'stop' : null),
        modelEcho: r?.model ?? null,
        tokenUsage: (r?.prompt_eval_count != null || r?.eval_count != null) ? {
          prompt:     r.prompt_eval_count ?? null,
          completion: r.eval_count ?? null,
          total:      (r.prompt_eval_count ?? 0) + (r.eval_count ?? 0) || null,
        } : null,
        errorCode: null,
        errorMessage: null,
      };
    }
    default: {
      return {
        ok: false,
        text: null, finishReason: null, modelEcho: null, tokenUsage: null,
        errorCode: 'provider_bad_response',
        errorMessage: `Unknown providerType: ${body.providerType}`,
      };
    }
  }
}
```

### Defensive handling

- If `r` is `{ raw: "..." }` (the adapter's fallback when upstream returned non-JSON), `text` is `null` and `errorCode` is `provider_bad_response`.
- If `r.choices` is missing or empty, `text` is `null` (not throw); `errorCode` is `provider_bad_response`.
- The function MUST NOT throw on any input — UI uses it inside render paths.

---

## 3. Error taxonomy (7 codes)

These are the canonical UI display states. Codex's settings panel + LuaAssistant should switch on these strings only — never on raw HTTP status codes or provider error strings.

| Code | When it fires | Suggested UI message |
|---|---|---|
| `adapter_down` | `GET /api/health` fails / unreachable | "AI backend not running. Start with `npm run start:ai-adapter` or use Copy Prompt." |
| `provider_not_configured` | `POST /api/ai/chat` returns 400 with `error: "baseUrl not configured"` or `"model not configured"` | "Configure your AI provider in Settings before sending." |
| `provider_unreachable` | adapter returns 502 with `errorCode: null, errorMessage: "fetch failed"` (or similar timeout/abort/network) | "Could not reach `<baseUrl>`. Check the URL and that the provider is online." |
| `provider_auth_failed` | adapter returns sanitized 401 (`errorMessage: "upstream returned HTTP 401"` or 403) | "Provider rejected the API key. Re-enter or check Settings." |
| `provider_rate_limited` | adapter returns sanitized 429 (`errorMessage: "upstream returned HTTP 429"`) | "Provider rate-limited the request. Wait a moment and retry, or reduce maxTokens." |
| `provider_bad_response` | upstream 2xx but missing `choices[0]` / `message.content`; OR `r` is `{ raw: ... }`; OR JSON-parse failed | "Provider returned an unexpected response. Try again or switch model." |
| `prompt_validation_failed` | adapter returns 400 with `error: "messages[] required"` or `"Invalid JSON body"` | "The UI built an invalid prompt. (Bug — please report.)" |

### `classifyError()` mapping helper

```js
function classifyError(body) {
  if (!body) return 'adapter_down';
  const msg = body.errorMessage ?? '';
  const status = body.status ?? null;

  if (status === 401 || status === 403) return 'provider_auth_failed';
  if (status === 429)                    return 'provider_rate_limited';
  if (/upstream returned HTTP 5\d{2}/.test(msg)) return 'provider_bad_response';
  if (/fetch failed|aborted|timeout|ENOTFOUND|ECONNREFUSED/i.test(msg)) {
    return 'provider_unreachable';
  }
  if (/baseUrl not configured|model not configured/.test(msg)) {
    return 'provider_not_configured';
  }
  if (/messages\[\] required|Invalid JSON body/.test(msg)) {
    return 'prompt_validation_failed';
  }
  return 'provider_bad_response';
}
```

### Status-code mapping table (reference for Codex)

| Adapter response | Body fingerprint | Maps to |
|---|---|---|
| 200 + `ok:true` + valid `response` | normal success | (no error code) |
| 200 + `ok:true` + `response: { raw: ... }` | upstream returned non-JSON | `provider_bad_response` |
| 400 + `error: "messages[] required"` | UI bug | `prompt_validation_failed` |
| 400 + `error: "baseUrl not configured"` | settings missing | `provider_not_configured` |
| 401/403 + sanitized `errorMessage: "upstream returned HTTP 401/403"` | bad key | `provider_auth_failed` |
| 429 + sanitized | rate limit | `provider_rate_limited` |
| 5xx + sanitized `errorMessage: "upstream returned HTTP 5XX"` | upstream down | `provider_bad_response` |
| 502 + `errorMessage: "fetch failed"` | network | `provider_unreachable` |
| (network failure to adapter itself) | health check fails | `adapter_down` |

---

## 4. Tiny backend patch — proposal (NOT applied)

The current adapter response for upstream non-2xx is:

```jsonc
{
  "ok": false,
  "providerType": "...",
  "baseUrl": "...",
  "model": "...",
  "status": 401,                                   // present
  "errorCode": null,                               // currently always null
  "errorMessage": "upstream returned HTTP 401"
}
```

`errorCode` is always `null` after the security patch. The UI's `classifyError()` works fine via `errorMessage` regex, so no change is strictly needed.

**Optional refinement (one-line change in `providers.mjs::wrapUpstreamResponse`):**

```js
errorCode: res.status === 401 ? 'unauthorized'
        : res.status === 403 ? 'forbidden'
        : res.status === 429 ? 'rate_limited'
        : res.status >= 500   ? 'upstream_5xx'
        : 'upstream_4xx',
```

This pre-classifies on the backend so the UI can switch on `errorCode` directly without regex on `errorMessage`. **My recommendation: do this only if Codex specifically wants it.** The regex-on-errorMessage approach is fine and keeps the backend simpler.

If Codex wants it, I can patch this in 2 minutes — say so in next signal.

---

## 5. Test fixture (for the UI parser unit tests Codex may want to write)

```js
// adapter response shapes the parser must handle
const FIXTURES = {
  openaiSuccess: {
    ok: true, providerType: 'openai-compatible',
    baseUrl: 'https://api.openai.com', model: 'gpt-4o-mini',
    response: {
      id: 'chatcmpl-...', model: 'gpt-4o-mini-2024-07-18',
      choices: [{
        message: { role: 'assistant', content: 'Hello.' },
        finish_reason: 'stop',
      }],
      usage: { prompt_tokens: 10, completion_tokens: 5, total_tokens: 15 },
    },
  },
  ollamaSuccess: {
    ok: true, providerType: 'ollama',
    baseUrl: 'http://localhost:11434', model: 'llama3',
    response: {
      model: 'llama3', message: { role: 'assistant', content: 'Hello.' },
      done: true, done_reason: 'stop',
      prompt_eval_count: 12, eval_count: 8,
    },
  },
  upstream401: {
    ok: false, providerType: 'openai-compatible',
    baseUrl: 'https://api.openai.com', model: 'gpt-4o-mini',
    status: 401, errorCode: null,
    errorMessage: 'upstream returned HTTP 401',
  },
  fetchFailed: {
    ok: false, providerType: 'openai-compatible',
    baseUrl: 'http://nope.invalid', model: 'gpt-4o-mini',
    errorCode: null, errorMessage: 'fetch failed',
  },
  badJson: {
    ok: true, providerType: 'openai-compatible',
    baseUrl: '...', model: '...',
    response: { raw: 'data: [DONE]\n\n' },   // streaming response leaked
  },
  validationFail: {
    ok: false, error: 'messages[] required',
  },
};
```

For each fixture, `extractAssistantResponse(body).errorCode` should equal:
- `openaiSuccess` → `null`
- `ollamaSuccess` → `null`
- `upstream401` → `provider_auth_failed`
- `fetchFailed` → `provider_unreachable`
- `badJson` → `provider_bad_response`
- `validationFail` → `prompt_validation_failed`

---

## 6. Boundaries observed

- ❌ No edits to `~/.codex/`
- ❌ No edits to `src/`
- ❌ No `package.json` / `.gitignore` changes
- ✅ Helper is pure UI-side code Codex copies at their pace
- ✅ Backend tiny-patch proposal is **opt-in** (Codex requests if wanted)
