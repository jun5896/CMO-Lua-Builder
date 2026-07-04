# Kimi QA Pipeline & Status Board

> **Owner:** Kimi  
> **Scope:** Smoke tests, security greps, build monitoring, fixture QA, task status tracking.  
> **Update trigger:** After every Codex pull, Claude patch, or Kimi deliverable completion.

---

## Smoke Test Pipeline

Run after every Codex UI edit cycle or Claude backend pull.

| # | Test | Command / Check | Owner | Status |
|---|------|-----------------|-------|--------|
| 1 | Lint | `npm run lint` | Kimi | ✅ Active |
| 2 | Build | `npm run build` | Kimi | ✅ Active |
| 3 | Mini fixture parse | `node tools/parse-cmo-event-export.mjs fixtures/cmo-scenario-mini.xml` | Kimi | ✅ Active |
| 4 | Iran fixture parse | `node tools/parse-cmo-event-export.mjs <path-to-iran-xml>` | Kimi | ✅ Active |
| 5 | Manifest load | `node -e "fs.readFileSync('public/cmo-dev-work/manifest.json')"` | Kimi | ✅ Active |
| 6 | Template catalog round-trip | Verify `src/data/templateCatalog.js` exports match `public/cmo-dev-work/templates/*.tpl.lua` | Kimi | ✅ Active |
| 7 | Scenario sidecar index valid JSON | `node -e "JSON.parse(fs.readFileSync('fixtures/scenario-sidecar-index.json'))"` | Kimi | ✅ Active |
| 8 | Event count parity | Parser events count == Task 2 summary events count (21 for Iran Strike) | Kimi | ✅ Active |
| 9 | Task 2 summarizer contract | `npm run summarize:scenario` produces JSON with `sides`, `missions`, `events`, `specialActions`, `units` | Kimi | ✅ Active |
| 10 | **Upstream redaction** | `node server/verify-upstream-redaction.mjs` → exit 0 | Claude/Kimi | ✅ **Active** |

**Smoke #10 details:**
- Requires patched `server/` files from Claude (post-2026-05-03).
- Exit codes: `0`=PASS, `1`=LEAK DETECTED (block pull), `2`=harness setup failure (retry).
- Adds ~5s to pipeline.

---

## Security Grep Baselines

Run from repo root after every Claude backend pull.

| # | Pattern | Expected | Notes |
|---|---------|----------|-------|
| 1 | `0\.0\.0\.0` | 0 hits | Bind address must stay `127.0.0.1` |
| 2 | `writeFileSync\|writeFile\|appendFile` | 0 hits | No disk writes in adapter |
| 3 | `Authorization` | 7 hits | `providers.mjs:88,166` (outbound header), `ai-provider-adapter.mjs:305` (comment), `verify-upstream-redaction.mjs:7,52,54` (test harness comment + mock read) |
| 4 | `127\.0\.0\.1` | 14 hits | `ai-provider-adapter.mjs` bind/CORS (6) + `verify-upstream-redaction.mjs` test URLs (8) |
| 5 | `apiKey` | 9 hits | `ai-provider-adapter.mjs` config/settings/log (6), `providers.mjs` outbound header (2), `verify-upstream-redaction.mjs` TEST_KEY (1). All guarded except TEST_KEY (intentional fake). |
| 6 | `Bearer\s+[A-Za-z0-9._-]{8,}\|sk-[A-Za-z0-9._-]{8,}` in `verify-upstream-redaction.mjs` | 1 hit | Intentional `TEST_KEY` constant only (`sk-local-leak-test-12-cdef` on ~L25) |

---

## Task Status Board

| Task | Description | Status | Blocker | Next Action |
|------|-------------|--------|---------|-------------|
| A | Scenario Sidecar Bridge Index | ✅ Complete | — | — |
| B | Template Inspector Guide Seed | ✅ Complete | — | Await Gemini review |
| C | AI Conversation Protocol Draft | ✅ Complete | — | Await Gemini review |
| 2 | Scenario Summarizer Integration | ✅ Complete | — | — |
| 3 | AI Adapter (backend) | ✅ **Complete** | Codex pulled `server/`; smoke #10 PASS | Monitor for regression |
| 3b | AI Adapter (UI integration) | ✅ **Complete** | Codex integrated settings/chat/test-provider flows; static contract checks PASS | Monitor for regression |
| 3B | AI Chat Protocol (dual draft) | ✅ Complete | Codex merged Claude + Kimi drafts into UI | None |

**Task 3 QA-Hold History:**
- **Opened:** 2026-05-02 — upstream non-2xx body forwarding leaked `Authorization` header.
- **Patch landed:** 2026-05-03 — Claude added `wrapUpstreamResponse()` + `deepScrubSecrets()` + harness.
- **Hold lifted:** 2026-05-03 — Codex pulled `server/` files; smoke #10 PASS; full UI integration QA PASS.
- **Status:** Closed. Monitoring only.

---

## Source Footprint Tracking

Task 3 adapter files (server-only, Node stdlib-only, **0 KB bundle delta**).

| File | Pre-patch | Post-patch | Δ |
|------|-----------|------------|---|
| `ai-provider-adapter.mjs` | 332 | ~365 | +33 (deepScrubSecrets) |
| `providers.mjs` | 187 | ~210 | +23 (wrapUpstreamResponse) |
| `.env.example` | 30 | 30 | 0 |
| `verify-upstream-redaction.mjs` | — | ~155 | +155 (NEW harness) |
| **Total** | **549** | **~760** | **+211** |

---

## Claude Artifact References (Read-Only)

Kimi may cite these without copying verbatim. Do not edit Claude workspace.

| Artifact | Path | Relevance |
|----------|------|-----------|
| Task 2 contract refinement | `~/.claude/cmo-lua-scripts/handoff/to-codex/Task-2/contract-refinement-proposal.md` | Scenario summarizer JSON shape authority |
| Task 3B interpreter contract | `~/.claude/.../handoff/to-codex/Task-3-AI-Adapter/docs/contracts/ai-interpreter-chat-contract.md` | Independent draft for Codex triangulation |
| Task 3B response normalization | `~/.claude/.../handoff/to-codex/Task-3-AI-Adapter/docs/contracts/response-normalization-and-error-taxonomy.md` | Error taxonomy reference |
| Task 3B guardrails | `~/.claude/.../handoff/to-codex/Task-3-AI-Adapter/docs/contracts/cmo-specific-guardrails.md` | CMO-specific constraints |

---

## Build/Lint Baseline Reference

Last verified: 2026-05-03

```
lint:  PASS (0 errors)
build: PASS (~509ms, JS ~371KB, CSS ~55KB)
```

**Alert threshold:**
- Lint errors > 0 → block commit
- Build time > 1500ms → investigate bundle bloat
- JS bundle > 400KB → investigate import creep
- CSS bundle > 60KB → investigate unused styles

---

## Post-Gemini Integration Check

After Gemini completes a doc integration in `docs/`:

| Step | Check | Owner | Command |
|------|-------|-------|---------|
| 1 | No accidental JSX/CSS injection into markdown | Kimi | `npm run lint` |
| 2 | Build still clean | Kimi | `npm run build` |
| 3 | Changed docs render correctly in markdown viewer | Kimi | Visual spot-check |
| 4 | glossary sweep did not touch code blocks | Kimi | `git diff -- docs/` review |

**Escalation:** If a technical discrepancy is found during the diff review, Kimi opens a handoff note at `docs/reviews/kimi-handoff-<topic>.md` and assigns back to Gemini or the original author (Claude/Codex).