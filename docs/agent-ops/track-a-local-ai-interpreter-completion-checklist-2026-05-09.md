# Track A Local AI Interpreter Completion Checklist - 2026-05-09

## Purpose

Close Track A as a verified local AI interpreter UI baseline before starting Track B CMO in-game integration.

Track A completion does not mean CMO has executed generated Lua or that the UI can read live CMO state. It means the local web page now has a coherent, internally complete AI-assisted Lua drafting workflow:

```text
Template / context discovery
-> user intent and local context
-> AI request construction
-> response parsing
-> workflow state
-> ask-back / blocker handling
-> source-labeled confirmed context
-> text-only follow-up drafts
-> paste-ready-only Working Draft application
-> explicit CMO engine verification reminder
```

Track B remains the place for CMO installation probing, scenario folder writes, log feedback, and user-triggered read-back.

## Current Public Release

Current public release:

```text
release-2026-05-09-cmo-lua-builder-local-confirmed-context
```

Release evidence:

```text
Tagged commit: 85ccada Mark local confirmed context release in README
GitHub Release: https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-local-confirmed-context
Release title: CMO Lua Builder Local Confirmed Context Workspace
Release closeout: docs/agent-ops/local-confirmed-context-release-closeout-2026-05-09.md
```

## Included Track A Slices

### A1 - Template Inspector Search / Filter UX

Evidence:

- Product commit: `5dd1da1 Add template inspector search filter UX`.
- Public release: `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Release closeout: `docs/agent-ops/template-inspector-search-filter-release-closeout-2026-05-09.md`.
- Template annotations: `51 / 51`, `0` missing.

Result:

- User can find templates through search and seven first-slice quick filters.
- Safety badges make required CMO facts visible.
- Every detail keeps the AI draft / CMO engine verification warning.

### A2 - AI Drafting Workflow

Evidence:

- A2 completion checklist: `docs/agent-ops/ai-drafting-workflow-a2-completion-checklist-2026-05-09.md`.
- Workflow state product commit: `eb689df Align AI drafting workflow state`.
- Follow-up needs product commit: `b32c780 Add AI follow-up needs review`.
- Kimi QA: A2-1 `38 / 38` PASS; A2-2 `34 / 34` PASS; A2 completion checklist `28 / 28` PASS.

Result:

- Shared state contract covers `idle`, `calling`, `ready`, `askBack`, `blocked`, and `error`.
- `ready` is the only apply-enabled state.
- Ask-back and blocked responses show grouped CMO confirmation needs.
- Follow-up draft remains text-only and user-triggered.

### A3 - Local Confirmed Context Workspace

Evidence:

- Design: `5bcc2b7 Add local confirmed context workspace design`.
- Plan: `e15a96a Add local confirmed context workspace plan`.
- Product commits:
  - `953317a Add confirmed context helper contract`.
  - `864e36b Wire confirmed context into assistant state`.
  - `72cca75 Add confirmed context workspace UI`.
  - `3772866 Use confirmed context in follow-up drafts`.
- Workspace closeout: `docs/agent-ops/local-confirmed-context-workspace-closeout-2026-05-09.md`.
- Release closeout: `docs/agent-ops/local-confirmed-context-release-closeout-2026-05-09.md`.
- Kimi QA: workspace `29 / 29` PASS; release tag `28 / 28` PASS.

Result:

- User can store source-labeled CMO-confirmed values.
- Confirmed values appear in `## User-confirmed CMO values` prompt context.
- Confirmed values survive the existing temp session/autosave path.
- Confirmed values can be reused in text-only follow-up drafts.
- No Track B behavior was introduced.

## Track A Completion Checklist

| Requirement | Evidence | Status |
|---|---|---|
| Template / preset discovery exists before AI call | A1 search/filter UX, `51 / 51` annotations | PASS |
| User can express intent and edit prompt context | Existing Event / Lua Assistant intent, context, prompt editor | PASS |
| User can bring local CMO context into the request | Object Context Registry, Database / Clipboard Context, Confirmed Context Workspace | PASS |
| Confirmed values are source-labeled | A3 `aiConfirmedContext` helper and Context tab UI | PASS |
| Confirmed values are not treated as AI-invented defaults | Prompt says not to replace confirmed values with guessed alternatives | PASS |
| Missing values remain ask-back requirements | A2 follow-up needs categories and A3 confirmed context do not suppress blockers | PASS |
| AI request can be sent through adapter | `npm run smoke:ai-adapter` PASS, no auth leakage | PASS |
| AI response parser contract is covered | `npm run smoke:ai-client-parser` PASS | PASS |
| Workflow state is shared across panels | A2 `aiWorkflowState`, `smoke:ai-workflow-state` PASS | PASS |
| Ready state is the only apply-enabled state | `canApplyLua` / `aiParsedResponse.isPasteReady` gate | PASS |
| Blocked or ask-back responses cannot be applied | Parser blockers, workflow state, disabled apply controls | PASS |
| Follow-up draft is text-only and user-triggered | A2/A3 review panel behavior; no auto-send | PASS |
| Manual prompt-copy fallback remains | Main prompt copy, chat prompt copy, AI response copy | PASS |
| Working Draft application remains gated | Parent `canApplyAiLua` controls apply buttons | PASS |
| CMO engine verification remains explicit | AI Lua safety wording and A1/A2/A3 UI language | PASS |
| Context pruning remains active and bounded | `aiContextPruning` `8.56 kB`, under `9 kB` | PASS |
| Provider secrets remain protected | Adapter smoke no raw Bearer / Authorization / `sk-` leakage | PASS |
| Scenario sidecar storage remains external | Sidecar audit baseline and no public/dist sidecar regression | PASS |
| No Track B behavior was introduced | No CMO filesystem write, log tailing, sidecar writer, live read-back, or new backend endpoint | PASS |
| Current release baseline is published | `release-2026-05-09-cmo-lua-builder-local-confirmed-context` | PASS |

## Verification Baseline

Codex ran the current full release chain:

```powershell
npm run verify:release
```

Result:

```text
PASS
```

Expanded chain:

```text
audit:scenario-sidecars: PASS
verify:scenario-loader: PASS
lint: PASS
build: PASS
smoke:ai-workflow-state: PASS
smoke:ai-follow-up-needs: PASS
smoke:ai-confirmed-context: PASS
smoke:ai-client-parser: PASS
smoke:ai-adapter: PASS, no auth leakage
```

Scenario / sidecar baseline:

```text
Scenario index: 1899
Ready with internal sidecar: 1857
Decoder failed: 42
Loader issues: 0
Sidecar protected by index: 3799
Sidecar orphans: 24 / 5.6 MB
```

Bundle baseline:

```text
Main JS: 377.99 kB (< 400 kB)
Main CSS: 59.14 kB (< 60 kB, 0.86 kB headroom)
aiContextPruning: 8.56 kB (< 9 kB)
PresetGuide: 33.99 kB JS / 7.49 kB CSS
AiInterpreterChatPanel: 10.38 kB JS / 6.73 kB CSS
AiResponseReviewPanel: 10.15 kB JS / 5.23 kB CSS
```

## Track A Verdict

Track A is complete as a local AI interpreter UI baseline.

This is a local-editor completion verdict only. It does not claim:

- Lua was executed in CMO.
- CMO live state is readable.
- CMO scenario folders are writable.
- CMO logs are tailed.
- Sidecar Lua deployment exists.

Those are Track B capabilities.

## Next Recommended Track

Proceed to Track B0 CMO Integration Probe before any in-game write/read integration.

Track B0 should verify the user's local CMO environment, folder permissions, log paths, LuaHistory availability, and explicit loader assumptions before B1/B2/B3/B4 implementation begins.

## Required QA For This Checklist

Kimi should verify this checklist as docs / handoff only:

- The checklist exists.
- It references the current public release `release-2026-05-09-cmo-lua-builder-local-confirmed-context`.
- It records A1, A2, and A3 evidence.
- It marks Track A complete as a local UI baseline only.
- It explicitly does not claim CMO execution, live read-back, scenario writes, or log tailing.
- It recommends B0 CMO Integration Probe as the next Track B step.
- It records `npm run verify:release` PASS and the expanded 9-step chain.
- It records bundle and scenario baselines.
- It confirms the target commit changes docs / handoff only.
