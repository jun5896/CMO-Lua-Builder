# Kimi Review ??Codex Task 3B Instructions (2 docs)

> **Reviewer:** Kimi  
> **Date:** 2026-05-03  
> **Scope:** `ai-interpreter-chat-contract.md` (Workstream B) + `response-normalization-and-error-taxonomy.md` (Workstream C)  
> **Authority:** Cross-checked against Kimi's own `docs/references/ai-assistant-conversation-protocol.md` and `docs/agent-ops/kimi-pipeline.md`.

---

## 1. `ai-interpreter-chat-contract.md` ??Interpreter Chat Contract

### 1.1 Overall Assessment
**Status:** ??No blocking issues. Ready for Codex triangulation.

### 1.2 Divergence from Kimi's Task C Draft

| Aspect | Kimi (Task C) | Claude (Workstream B) | Codex Decision Needed |
|--------|---------------|----------------------|----------------------|
| **Response section names** | `## Analysis Summary` | `## Summary` | Pick one; parser keys on literal string |
| **Prompt assembly format** | JSON-injected sections (1.2??.6) | Plain-text `=== HEADER ===` blocks | Either works; plain text may be more token-efficient |
| **Temperature / maxTokens** | Not specified | `temperature: 0.3`, `maxTokens: 2048` | Recommend adopting both; 0.3 improves literal compliance |
| **User question echo** | Not specified | `=== USER QUESTION (echoed for emphasis) ===` at bottom | Harmless enhancement; empirically helps model anchoring |
| **Provider override** | Not specified | `providerOverride: null` field | Optional; useful for multi-provider testing |
| **Hard rules count** | 9 rules (system prompt) | 6 rules (HARD RULES block) | Substantively equivalent; 6-rule version is more concise |
| **Response format mandate** | Present, with explicit empty-section allowance | Present, with exact empty `lua` block spec | Align perfectly on "empty Lua = BLOCKER state" |

### 1.3 Technical Validation

- **Section ordering:** `system` (fixed rules) ??`user` (request-specific) split matches prompt-caching best practices. Valid.
- **Scenario context extraction pseudocode:** Matches Task 2 summarizer JSON shape (verified against `fixtures/scenario-sidecar-index.json` and `docs/references/scenario-xml-schema-catalog.md`).
- **Lua bundle cap (50 KB):** Reasonable. Real CMO scripts rarely exceed 10 KB; 50 KB is a safe upper bound.
- **Template Inspector Notes integration:** References `template.category` and `template.name` fields that exist in `fixtures/template-inspector-guide-index.json`. Valid.
- **Engine feedback loop (§7):** Matches Kimi's §3 (Follow-Up Loop). Compatible.

### 1.4 Security / Guardrails Check

- Hard rule #1 (NEVER invent DBID/GUID/Loadout ID) ??matches Kimi guardrail #1.
- Hard rule #4 (NO file system / network / os.execute) ??matches Kimi guardrail on sandbox.
- Hard rule #5 (paste-ready Lua, no `<PLACEHOLDER>`) ??matches Kimi's "no invented names" policy.
- **No raw API key exposure in prompt assembly spec.** Verified.

### 1.5 Recommendations for Codex

1. **Adopt `temperature: 0.3` and `maxTokens: 2048`** in the adapter default payload. These were missing from Kimi's draft and improve interpreter reliability.
2. **Choose `## Summary` OR `## Analysis Summary`** ??parser must key on one literal string. `## Summary` is shorter and Claude's contract makes it the canonical header.
3. **Keep the `=== USER QUESTION ===` echo** ??low cost, high anchoring value.
4. **Merge the 6 HARD RULES** into the system prompt rather than the 9-rule version; they cover the same surface with less token burn.

---

## 2. `response-normalization-and-error-taxonomy.md` ??Normalization + Error Taxonomy

### 2.1 Overall Assessment
**Status:** ??No blocking issues. Error taxonomy aligns with patched adapter behavior.

### 2.2 `extractAssistantResponse()` Validation

| Provider | Path in upstream response | Claude's mapped field | Matches adapter patch? |
|----------|--------------------------|----------------------|------------------------|
| `openai-compatible` | `choices[0].message.content` | `text` | ??Yes |
| `lm-studio` | `choices[0].message.content` | `text` | ??Yes (alias) |
| `ollama` | `message.content` | `text` | ??Yes |
| `ollama` | `done_reason` / `done` | `finishReason` | ??Yes |
| Token usage (OpenAI) | `usage.prompt_tokens` | `tokenUsage.prompt` | ??Yes |
| Token usage (Ollama) | `prompt_eval_count` | `tokenUsage.prompt` | ??Yes |

- **Defensive handling:** Function is pure, never throws. Required for render-path safety. Valid.
- **`{ raw: "..." }` fallback:** Maps to `provider_bad_response`. Correct ??this shape only appears when upstream returns non-JSON on 2xx, which should not happen but is defensive.

### 2.3 Error Taxonomy (7 Codes) Validation

| Code | Trigger condition | Maps to adapter body? | Kimi Pipeline Smoke Test Coverage |
|------|-------------------|----------------------|-----------------------------------|
| `adapter_down` | Health check fails | Implicit (network failure to adapter) | Smoke #1 (GET /api/health) |
| `provider_not_configured` | `baseUrl not configured` | 400 body with `error` field | Smoke #3 (settings default) |
| `provider_unreachable` | `fetch failed` / timeout | 502 or network error | Smoke #5 (test-provider unreachable) |
| `provider_auth_failed` | `upstream returned HTTP 401/403` | Sanitized 401/403 body | **Smoke #10** (mock-provider 401) |
| `provider_rate_limited` | `upstream returned HTTP 429` | Sanitized 429 body | Add to post-pull smoke suite |
| `provider_bad_response` | Missing `choices[0]` / `{raw:...}` | 2xx malformed or 5xx sanitized | Implicit in smoke #6 (empty messages) |
| `prompt_validation_failed` | `messages[] required` / invalid JSON | 400 body with `error` field | Smoke #6 (empty messages) |

**All 7 codes map cleanly to the patched adapter's possible outputs.**

### 2.4 `classifyError()` Regex Validation

- `/upstream returned HTTP 5\d{2}/` ??`provider_bad_response` ??Correct (5xx sanitized)
- `/fetch failed|aborted|timeout|ENOTFOUND|ECONNREFUSED/i` ??`provider_unreachable` ??Correct
- `/baseUrl not configured|model not configured/` ??`provider_not_configured` ??Correct
- `/messages\[\] required|Invalid JSON body/` ??`prompt_validation_failed` ??Correct
- **Fallback:** `provider_bad_response` ??safe default.

### 2.5 Tiny Backend Patch Proposal (§4) ??Kimi Assessment

Claude proposes adding `errorCode` pre-classification in `providers.mjs::wrapUpstreamResponse`:

```js
errorCode: res.status === 401 ? 'unauthorized'
        : res.status === 403 ? 'forbidden'
        : res.status === 429 ? 'rate_limited'
        : res.status >= 500   ? 'upstream_5xx'
        : 'upstream_4xx',
```

**Kimi recommendation: ??DO NOT apply this patch yet.**

Rationale:
1. **Backend simplicity:** Current regex-on-`errorMessage` approach in `classifyError()` works and keeps the backend stateless.
2. **Taxonomy mismatch:** The proposed backend codes (`unauthorized`, `forbidden`, `rate_limited`, `upstream_5xx`) do NOT match the UI taxonomy (`provider_auth_failed`, `provider_rate_limited`, `provider_bad_response`). The UI would still need a mapping layer, defeating the purpose.
3. **Smoke test stability:** Adding `errorCode` strings to the backend response changes the JSON shape. Kimi's smoke #10 asserts on `errorCode: null`; a patch would require updating the harness and the pipeline.
4. **Future-proofing:** If Codex later wants backend pre-classification, the mapping should use the **same 7-code taxonomy** as the UI, not a parallel set.

**Action:** If Codex wants backend pre-classification, open a follow-up task to align backend `errorCode` values 1:1 with the UI taxonomy, then update smoke #10 accordingly.

### 2.6 Test Fixtures Validation

The 6 fixtures provided are structurally sound and cover:
- Success (OpenAI + Ollama)
- Sanitized upstream 401
- Network failure
- Malformed JSON (`{raw:...}`)
- Validation failure

**Recommendation:** Codex can drop these directly into `src/lib/ai-response.test.js` (or equivalent) as soon as the UI parser is implemented.

---

## 3. Cross-Cutting Observations

### 3.1 Kimi Pipeline Updates Required

| Item | Update |
|------|--------|
| Smoke #10 | Already covers `provider_auth_failed`. Add `provider_rate_limited` to **post-pull extended smoke suite** (optional, not blocking). |
| Grep baselines | Unchanged. No new `sk-` / `Bearer` / `0.0.0.0` / `writeFileSync` patterns introduced. |
| Source footprint | `response-normalization-and-error-taxonomy.md` is a **docs-only** artifact (UI-side helper pseudocode). Zero backend LOC delta. |

### 3.2 Gemini Integration Impact

- `ai-interpreter-chat-contract.md` is **English-only, developer-facing**. No Korean translation needed.
- `response-normalization-and-error-taxonomy.md` is **English-only, developer-facing**. No Korean translation needed.
- Both documents should be added to `docs/agent-ops/gemini-review-queue.md` as **excluded from language review** (backend/contract artifacts, already covered by Gemini integration guide §2 rule).

### 3.3 Codex Pull Readiness

| Step | Status | Owner |
|------|--------|-------|
| Pull patched `providers.mjs` | ??Verified by Claude harness | Codex |
| Pull patched `ai-provider-adapter.mjs` | ??Verified by Claude harness | Codex |
| Pull `verify-upstream-redaction.mjs` | ??Harness described and tested | Codex |
| Run smoke #10 | ??Awaiting Codex pull | Kimi |
| Pull B/C/D contract docs into `docs/` | ??Awaiting Codex decision | Codex |
| Wire UI parser per §8 | ??Awaiting Codex implementation | Codex |
| Adopt `temperature: 0.3`, `maxTokens: 2048` | ??Recommend in next Codex cycle | Kimi |

---

## 4. Boundaries Observed

- ??No edits to Claude workspace files.
- ??No edits to `src/`, `tools/`, `server/`.
- ??Review is read-only analysis + recommendation only.

