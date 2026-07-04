# AI Drafting Workflow A2 Completion Checklist - 2026-05-09

## Purpose

Close Track A2 as a verified local AI interpreter workflow baseline and decide the next Track A step before any Track B CMO in-game integration begins.

A2 does not mean CMO has executed the Lua. It means the local web UI can guide the user from intent to reviewed AI draft, ask-back or blocker handling, text-only follow-up, parser validation, and gated Working Draft application without relying on CMO file writes or live game state.

## Current Public Release

Current public release remains:

- Release tag: `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Tagged commit: `004325d Mark template inspector search filter release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Release title: `CMO Lua Builder Template Inspector Search Filter UX`.

A2 is post-release operating work on top of that public baseline.

## Included A2 Slices

### A2-1 Workflow State

Commits:

- Design: `e8e9c9e Add AI drafting workflow tightening design`.
- Implementation plan: `81b77a9 Add AI drafting workflow implementation plan`.
- Product: `eb689df Align AI drafting workflow state`.
- QA directive: `853349b Add AI drafting workflow state QA directive`.
- QA archive: `73e080c Archive AI drafting workflow state QA`.
- QA evidence: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-drafting-workflow-state-qa.md`.

Result:

- Shared workflow states: `idle`, `calling`, `ready`, `askBack`, `blocked`, `error`.
- `ready` is the only apply-enabled state.
- `calling`, pruning hard-block/failure, and current errors defeat stale ready output.
- Main Output, Review, and Chat surfaces share the same state meaning.

### A2-2 Follow-Up Needs

Commits:

- Design: `f587645 Add AI follow-up needs design`.
- Implementation plan: `688b611 Add AI follow-up needs implementation plan`.
- Contract/helper: `64683a0 Add AI follow-up needs contract`.
- Product: `b32c780 Add AI follow-up needs review`.
- QA directive: `064fcae Add AI follow-up needs QA directive`.
- QA archive: `33aec2f Archive AI follow-up needs QA`.
- Closeout: `29318d4 Document AI follow-up needs closeout`.
- Closeout QA archive: `f98b8a5 Archive AI follow-up needs closeout QA`.
- QA evidence: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-qa.md`.
- Closeout QA evidence: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-closeout-docs-qa.md`.

Result:

- Review panel groups CMO confirmation needs under `CMO에서 확인할 값`.
- Categories cover Side, Mission, Unit GUID, DBID, Loadout, RP / Zone, Posture / Doctrine / EMCON, Coordinates, Weather, Response Format, and Unsafe Lua.
- Visible categories are capped at six and evidence is hidden behind `<details>`.
- `재질문 초안 만들기` remains text-only and includes no-invention wording.

## A2 Completion Checklist

| Requirement | Evidence | Status |
|---|---|---|
| User can start from intent / prompt text | Existing AI request flow, prompt editor, and `Prompt 복사` fallback | PASS |
| Template / preset context exists before AI call | A1 Template Inspector search/filter release and `51 / 51` annotation baseline | PASS |
| AI request can be sent through adapter | `npm run smoke:ai-adapter` and provider profile QA baseline | PASS |
| AI response is parsed into structured sections | `npm run smoke:ai-client-parser` and parser contract baseline | PASS |
| Workflow state is consistent across panels | A2-1 `aiWorkflowState` helper and Kimi 38 / 38 QA | PASS |
| Ready state is the only apply-enabled state | A2-1 state smoke and `canApplyLua` wiring | PASS |
| Ask-back values are visible and actionable | A2-2 `CMO에서 확인할 값` card and Kimi 34 / 34 QA | PASS |
| Blocked responses cannot be applied | Parser blockers, workflow state, and apply button disabled path | PASS |
| Follow-up draft is text-only | A2-1 / A2-2 QA; no auto-send behavior | PASS |
| Manual fallback remains visible | Main `Prompt 복사`, chat `요청문 복사`, AI response copy | PASS |
| Working Draft is append/apply gated | `aiParsedResponse.isPasteReady === true` / parent `canApplyLua` | PASS |
| CMO engine verification remains explicit | Ready/apply wording and AI Lua safety wording release | PASS |
| Context pruning still protects token budget | `aiContextPruning` baseline `8.56 kB`, under `9 kB` | PASS |
| No Track B behavior introduced | No CMO filesystem write, log tailing, live read-back, sidecar writer, or backend endpoint | PASS |

## Verification Baseline

Codex verification for this checklist:

- `npm run verify:release`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- Sidecar audit: `1899` scenarios in index, `3799` protected files, `24` orphans / about `5.6 MB`, dry-run only.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, sanitized HTTP 401 forwarding and no raw `Bearer`, `Authorization`, or `sk-` leakage.

Latest A2 observed bundle baseline:

- Main JS: `371.44 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- `AiInterpreterChatPanel`: `10.38 kB JS / 6.73 kB CSS`.
- `AiResponseReviewPanel`: `10.08 kB JS / 5.23 kB CSS`.

Watch line status:

- Main JS remains under `400 kB`.
- Main CSS remains under `60 kB`, but only about `0.86 kB` headroom remains.
- `aiContextPruning` remains under `9 kB`.

## A2 Verdict

Track A2 is complete as a local AI drafting workflow baseline.

The local page now has a coherent interpreter loop:

```text
intent / template context
→ AI request
→ parser state
→ ready / ask-back / blocker / error
→ grouped confirmation needs
→ text-only follow-up draft
→ paste-ready-only Working Draft application
→ CMO engine verification reminder
```

This is sufficient to proceed to the next Track A decision point.

## A3 Decision

Do not move to Track B yet.

A2 proves the AI interpreter loop is coherent, but the page still lacks a dedicated source-backed local context layer for user-confirmed values. Before B0/B1 begins, Track A should add or explicitly defer A3:

- Confirmed Side, Mission, Unit GUID, DBID, Loadout, RP, Zone, posture, doctrine, EMCON, coordinates, and weather values should have a clear local source-backed representation.
- Confirmed values should be reusable in follow-up prompts without being treated as invented defaults.
- Unconfirmed values should remain ask-back requirements.

Recommended next step:

```text
A3: Local Confirmed Context Workspace
```

Keep A3 local-only. It should not read from or write to CMO. It should prepare the UI vocabulary for later Track B live scenario context.

## Required QA For This Checklist

Kimi should verify this A2 completion checklist as docs / handoff only:

- The checklist exists.
- It references A2-1 and A2-2 commits and QA archives.
- It records the current public release remains the A1 search/filter release.
- It records the A2 bundle/watch-line baseline.
- It marks A2 complete but does not mark Track A complete.
- It recommends A3 before Track B.
- It confirms no product code, server, tool, public data, package, or lockfile change.
