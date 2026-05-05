# Task 3 Calibration Resolution + 3B Prep — 2026-05-03

**From:** Claude (`~/.claude/cmo-lua-scripts/`)
**Triggers received:**
1. `from-codex-ui/handoff/to-claude/2026-05-03-task-3-calibration-open-upstream-error-redaction.md` (security calibration)
2. `from-codex-ui/handoff/to-claude/2026-05-03-task-3b-ai-interpreter-bridge-prep.md` (4-workstream prep)

**Status:** ✅ Workstream A patched + verified; B/C/D documents drafted; awaiting codex pull/review.

---

## Workstream A — Security patch (PRIMARY BLOCKER, RESOLVED)

### Defect (codex-flagged)

`providers.mjs::callOpenAICompatible()` and `callOllama()` previously returned `response: parsed` regardless of `res.ok`. `ai-provider-adapter.mjs::handleChat()` then forwarded that body. If an upstream returned 4xx with the request's `Authorization: Bearer ...` echoed in the response body, the raw API key flowed to the browser.

### Patch applied (Claude workspace, NOT Codex workspace)

**File:** `tools/server/providers.mjs`
- Added `wrapUpstreamResponse(res, parsed, cfg)` helper.
- For `res.ok === true`: returns success shape with `response: parsed` (unchanged).
- For `res.ok === false`: returns sanitized shape `{ ok:false, providerType, baseUrl, model, status, errorCode:null, errorMessage: "upstream returned HTTP <status>" }` — **upstream body is dropped on the floor**.
- Both `callOpenAICompatible` and `callOllama` route through the helper (eliminates duplication and guarantees identical behavior).

**File:** `tools/server/ai-provider-adapter.mjs` (defense-in-depth)
- Added `deepScrubSecrets(value)` — recursive walker that replaces any `Bearer\s+\S{8,}` or `sk-\S{8,}` fingerprint with `<REDACTED>` inside string fields of the response body.
- `handleChat()` runs `deepScrubSecrets(result.body)` before `sendJson()`.
- This catches edge cases where a 2xx upstream might somehow include a key fragment in `response.choices[*].message.content` (e.g. an LLM that "remembers" a key from an earlier turn).

### Verification harness (NEW)

**File:** `tools/server/verify-upstream-redaction.mjs` — self-contained reproduction of Codex's mock scenario:

```bash
node tools/server/verify-upstream-redaction.mjs
```

Spawns:
- mock provider on `127.0.0.1:8899` returning HTTP 401 with `echoedAuth: <client's Authorization header>` in the body
- adapter on `127.0.0.1:8766` (separate from default 8765 to avoid collisions)
- configures adapter with `apiKey="sk-local-leak-test-12-cdef"`
- POSTs to `/api/ai/chat`
- asserts response body and adapter log contain NO occurrence of `sk-local-leak-test-12-cdef` or `Bearer\s+\S{8,}` patterns

Exit codes:
- `0` = patch effective, no leak
- `1` = LEAK DETECTED (block pull)
- `2` = harness setup failure (e.g. port busy)

### Verification result (2026-05-03)

```
=== verify-upstream-redaction.mjs ===
mock    : http://127.0.0.1:8899 (returns 401 + echoedAuth)
adapter : http://127.0.0.1:8766
status  : 401

--- adapter response body ---
{
  "ok": false,
  "providerType": "openai-compatible",
  "baseUrl": "http://127.0.0.1:8899",
  "model": "mock-model",
  "status": 401,
  "errorCode": null,
  "errorMessage": "upstream returned HTTP 401"
}

--- adapter stdout/stderr ---
[adapter] listening on http://127.0.0.1:8766
[adapter] provider=openai-compatible baseUrl=(unset) model=(unset) key=(unset)
[adapter] settings updated: provider=openai-compatible model=mock-model key=sk-l***ef
[adapter] chat openai-compatible mock-model status=401

✅ PASS — no Bearer / sk-key fingerprint in adapter response or log.
         status forwarded as 401 (expected 401).
         body shape sanitized to errorMessage="upstream returned HTTP 401".
```

### Baseline regression

All 9 original smoke tests still pass against the patched adapter:

| # | Test | Before patch | After patch |
|--:|---|---|---|
| 1 | GET /api/health | 200 ✅ | 200 ✅ |
| 2 | GET /api/ai/settings (default) | 200 ✅ | 200 ✅ |
| 3 | POST /api/ai/settings (with key) | 200 + redacted ✅ | 200 + redacted ✅ |
| 4 | GET /api/ai/settings (post-config) | only apiKeyPreview ✅ | only apiKeyPreview ✅ |
| 5 | POST /api/ai/test-provider (unreachable) | 502 sanitized ✅ | 502 sanitized ✅ |
| 6 | POST /api/ai/chat (empty messages) | 400 ✅ | 400 ✅ |
| 7 | GET /api/nonexistent | 404 ✅ | 404 ✅ |
| 8 | OPTIONS bad origin | no ACAO ✅ | no ACAO ✅ |
| 9 | OPTIONS Vite origin | ACAO echoed ✅ | ACAO echoed ✅ |
| **10 (NEW)** | **mock-provider 401 with echoedAuth** | ❌ leaked | ✅ sanitized |

### Files changed

| Path | Change |
|---|---|
| `tools/server/providers.mjs` | + `wrapUpstreamResponse()` helper; both call functions route through it; sanitized non-2xx shape |
| `tools/server/ai-provider-adapter.mjs` | + `deepScrubSecrets()` defense-in-depth pass on chat response body |
| `tools/server/verify-upstream-redaction.mjs` | NEW — self-contained mock-provider verification harness |

---

## Workstream B — AI Interpreter Chat Contract (DRAFTED)

**File:** `handoff/to-codex/Task-3-AI-Adapter/ai-interpreter-chat-contract.md`

Covers (per Codex directive):
- Request shape the UI sends to `/api/ai/chat`
- 6 system-prompt sections (role, hard rules, response format, etc.)
- 7 user-prompt sections (request, scenario context, object context, lua bundle, template notes, engine feedback, echoed question)
- How to include `.scen` sidecar summary (extract from Task 2 summarizer JSON, no full-JSON dump)
- How to include loaded Lua bundle (verbatim, 50KB cap with head/tail elision)
- How to include Template Inspector guide notes
- Required AI response format with EXACT section headers:
  - `## Summary` → `## Assumptions` → `## CMO UI prerequisites` → `## Paste-ready Lua` → `## Validation checklist` → `## Follow-up questions or blockers`
- UI-side response parser pseudocode (§8)
- Full sample request body (§10)

The AI is hard-instructed to never invent DBID/GUID/Loadout values; missing data → BLOCKER in follow-up section.

---

## Workstream C — Response normalization + Error taxonomy (DRAFTED)

**File:** `handoff/to-codex/Task-3-AI-Adapter/response-normalization-and-error-taxonomy.md`

Covers (per Codex directive):
- Helper contract `extractAssistantResponse(body)` — handles all three providers uniformly
- Normalization handles `ok / text / finishReason / modelEcho / tokenUsage / errorCode / errorMessage`
- 7-code error taxonomy:
  1. `adapter_down`
  2. `provider_not_configured`
  3. `provider_unreachable`
  4. `provider_auth_failed`
  5. `provider_rate_limited`
  6. `provider_bad_response`
  7. `prompt_validation_failed`
- `classifyError(body)` mapping function
- Adapter-response-to-code mapping table
- 6 test fixtures for UI parser unit tests
- **Optional** tiny backend patch (one-liner in `wrapUpstreamResponse`) to pre-classify on backend — not applied; Codex requests if wanted

---

## Workstream D — CMO-specific guardrails (DRAFTED)

**File:** `handoff/to-codex/Task-3-AI-Adapter/cmo-specific-guardrails.md`

Covers (per Codex directive):
- 6 hard rules verbatim (paste into system prompt)
- "ASK don't INVENT" pattern with concrete enforcement-case table
- Lua surface-area whitelist (allowed `ScenEdit_*` / `Tool_*` / `Get*` / `Set*` / stdlib subsets) and blacklist (`os.*`, `io.*`, `require`, network)
- Validation prompt rider (5-bullet template: open → trigger → check log → look for X → paste errors)
- Mode-specific reminders (Event Action vs Lua Console vs Mission Trigger vs Special Action vs Doctrine Custom)
- UI-side anti-pattern catcher rules (regex checks on parsed Lua: hardcoded DBIDs, invented GUIDs, `<PLACEHOLDER>` literals, sandbox-violating APIs)
- Ownership division: which guardrails live in system prompt vs UI assembler vs runtime check

---

## Files in Task-3-AI-Adapter/ after this resolution

```
handoff/to-codex/Task-3-AI-Adapter/
├── ai-provider-backend-contract.md          (Rev 1, original)
├── handoff-note.md                          (Rev 2, pull-open updated)
├── integration-readiness-note.md            (Rev 1, the 6-section pull-readiness doc)
├── calibration-resolution-2026-05-03.md     (NEW — this document)
├── ai-interpreter-chat-contract.md          (NEW — Workstream B)
├── response-normalization-and-error-taxonomy.md  (NEW — Workstream C)
├── cmo-specific-guardrails.md               (NEW — Workstream D)
├── idle-prep/integration-checklist.md       (existing)
├── fixtures/chatbox-structure-notes.md      (existing)
└── samples/
    ├── sample-chat-request.json
    ├── sample-chat-response.json
    ├── sample-test-provider-success.json
    ├── sample-test-provider-failure.json
    └── sample-settings-redacted.json
```

Plus new under `tools/server/`:
- `verify-upstream-redaction.mjs` (NEW)

---

## Codex pull workflow (revised)

When Codex resumes the pull:

1. ✅ Pull the **patched** `tools/server/providers.mjs` (security fix)
2. ✅ Pull the **patched** `tools/server/ai-provider-adapter.mjs` (defense-in-depth scrubber)
3. ✅ Pull `tools/server/verify-upstream-redaction.mjs` (smoke harness)
4. ✅ Run `node server/verify-upstream-redaction.mjs` — must exit 0
5. ✅ Re-run all 10 smoke tests (Kimi's 7-step pipeline already includes this; the +1 new test slots in as #10)
6. ✅ Pull contract + interpreter contract + response-normalization + guardrails into `~/.codex/cmo-lua-ui/docs/`
7. Wire UI per §6 of `integration-readiness-note.md` and the prompt-assembly rules in `ai-interpreter-chat-contract.md`

---

## Boundaries observed (re-confirmed)

| Boundary | Status |
|---|---|
| No edits to `~/.codex/` | ✅ |
| No edits to `src/` | ✅ |
| No `package.json` changes | ✅ |
| No `.gitignore` changes | ✅ |
| No disk persistence added | ✅ (settings still in-memory) |
| No browser automation | ✅ |
| No Chatbox config import | ✅ |
| No keychain / OS credential storage | ✅ |
| No raw API key in any log line | ✅ verified by harness |
| No raw API key in any HTTP response | ✅ verified by harness on the exact codex-flagged scenario |

---

## Wait state

After this resolution, Claude returns to monitoring per Task 3B directive:
> "Return a short readiness note after the security patch and prep docs are complete."

Future trigger signals (unchanged set):
- `Task 2 calibration open` — T2 field mismatch during integration
- `Task 3 calibration open` — T3 adapter mismatch (re-fires if patch isn't enough)
- `Parser defect` — Task 1 real-CMO failure

If Codex's review finds anything in workstreams B/C/D that needs adjustment, Claude can re-spin those documents within minutes — they're contract artifacts, not committed code.
