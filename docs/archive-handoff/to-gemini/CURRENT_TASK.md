# CURRENT TASK - Gemini

Status: Korean UX wording / beginner guidance / prompt behavior reviewer

## Active State

- No active Gemini UX / IA directive is currently open.
- CMO Wiki / Code Assistant UX review is complete and archived:

```text
handoff/to-gemini/_archive/2026-05-13/2026-05-13-cmo-wiki-code-assistant-ux-review.md
```

- Result: APPROVED WITH CHANGES; Codex incorporated beginner-facing wiki wording, deterministic helper naming, text-only AI draft labels, and template creation de-emphasis.
- Closeout doc: `docs/agent-ops/cmo-wiki-code-assistant-closeout-2026-05-13.md`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-code-assistant-qa.md`; result APPROVED, `38 / 38 PASS`.
- Release tag QA archive: `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-tag-qa.md`; result APPROVED, `35 / 35 PASS`.
- Release closeout doc: `docs/agent-ops/cmo-wiki-reference-helper-release-closeout-2026-05-13.md`.
- Current next gate: Kimi release closeout-docs QA via `handoff/to-kimi/2026-05-13-cmo-wiki-reference-helper-release-closeout-docs-qa.md`.
- Latest operating recheck: `npm run verify:release` PASS after approved rerun from sandbox `spawn EPERM`; CMO Wiki release remains current.
- Stand by until Codex opens the next UX review directive.
- Archived directives under `_archive/` are evidence only, not active tasks.

Latest planning gate:

- Design: `docs/superpowers/specs/2026-05-13-cmo-ai-advisory-workspace-design.md`.
- Plan: `docs/superpowers/plans/2026-05-13-cmo-ai-advisory-workspace.md`.
- Agent-ops: `docs/agent-ops/cmo-ai-advisory-workspace-planning-2026-05-13.md`.
- Local scenario size check: `1058` `.scen` files, `149` over `1.25 MB`, largest observed `17.49 MB`.
- Direction: AI Chat primary, Lua Scratchpad secondary, Wiki / Presets integrated, B2/B3/B4 explicit manual support actions.

Current manual gate:

- Runbook: `docs/agent-ops/b4-manual-cmo-workflow-smoke-2026-05-12.md`.
- Status: READY / USER-RUN.
- User-facing path: `CMO 파일 준비` -> `CMO Lua 폴더 저장` -> user-run `ScenEdit_RunScript('/AiAssist/<file>.lua')` -> `CMO 로그 확인` -> `CMO 상태 스냅샷 가져오기` -> `후속 질문 초안 만들기`.
- Wording must continue to avoid live-state claims; use imported snapshot / 가져온 스냅샷 and text-only draft language.
- No Gemini review is needed unless the manual smoke exposes confusing UI wording.

Latest B4 planning gate:

- Design: `docs/superpowers/specs/2026-05-11-b4-user-triggered-state-export-design.md`.
- Plan: `docs/superpowers/plans/2026-05-11-b4-user-triggered-state-export.md`.
- Agent-ops: `docs/agent-ops/b4-user-triggered-state-export-planning-2026-05-11.md`.
- Kimi planning QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-user-triggered-state-export-planning-qa.md`.
- Kimi QA result: APPROVED, `55 / 55 PASS`.
- Claude design review archive: `handoff/to-claude/_archive/2026-05-11/2026-05-11-b4-user-triggered-state-export-design-review.md`.
- Claude review result: APPROVED with refinements.
- B4 user-facing wording must say imported snapshot / 가져온 스냅샷, not live state / 실시간 상태.
- Expected future B4 UI labels: `CMO 상태 스냅샷 가져오기`, `스냅샷 가져오기`, `가져온 CMO 스냅샷`, `후속 질문 초안 만들기`.
- Latest B4.1 product commit: `876903f Add B4 CMO state snapshot helper`.
- Scope is helper-only: no user-facing UI wording yet.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-helper-qa.md`.
- Kimi QA result: APPROVED, `80 / 80 PASS`.
- Current next gate: B4.2 adapter endpoint; still no user-facing UI wording expected.
- Latest B4.2 endpoint commit: `92a5ca6 Add B4 CMO state snapshot endpoint`.
- Scope is adapter endpoint + smoke only: no user-facing UI wording yet.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-endpoint-qa.md`.
- Kimi QA result: APPROVED, `70 / 70 PASS`.
- Latest B4.3 UI commit: `5d3b06d Add B4 CMO state snapshot UI`.
- New UI labels: `CMO 상태 스냅샷 가져오기`, `스냅샷 가져오기`, `가져온 CMO 스냅샷`, `후속 질문 초안 만들기`.
- Wording states that the pasted CMO export becomes an imported snapshot and that `실시간 연결이 아닙니다`.
- Follow-up remains a user-reviewed draft and AI is not called automatically.
- Snapshot hints can be promoted into Confirmed Context only by user-selected per-value clicks.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-ui-qa.md`.
- Kimi QA result: APPROVED, `74 / 74 PASS`.
- B4 closeout doc: `docs/agent-ops/b4-user-triggered-state-export-closeout-2026-05-11.md`.
- B4 closeout docs commit: `69040d3 Document B4 user-triggered state export closeout`.
- Kimi closeout-docs QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-user-triggered-state-export-closeout-docs-qa.md`.
- Kimi closeout-docs QA result: APPROVED, `60 / 60 PASS`.
- Latest B4 release marker commit: `b1fac3d Mark B4 state snapshot import release in README`.
- README current public release line now references `release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- `verify:release` now includes B4 helper/endpoint/client smokes.
- Kimi release-marker QA directive: `handoff/to-kimi/2026-05-11-b4-state-snapshot-import-release-marker-qa.md`.
- Kimi release-marker QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-state-snapshot-import-release-marker-qa.md`.
- Kimi release-marker QA result: APPROVED, `48 / 48 PASS`.
- B4 release tag: `release-2026-05-11-cmo-lua-builder-state-snapshot-import` -> `b1fac3d`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- Kimi release-tag QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-state-snapshot-import-release-tag-qa.md`.
- Kimi release-tag QA result: APPROVED, `48 / 48 PASS`.
- B4 release closeout doc: `docs/agent-ops/b4-state-snapshot-import-release-closeout-2026-05-11.md`.
- B4 release closeout status: APPROVED / RELEASED.
- Kimi B4 release closeout-docs QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-state-snapshot-import-release-closeout-docs-qa.md`.
- Kimi B4 release closeout-docs QA result: APPROVED, `54 / 54 PASS`.
- B4 is fully released and closed.
- Latest B4 post-release operating recheck: `npm run verify:release` PASS after approved rerun from sandbox `spawn EPERM`.
- B4 operating baseline remains Main JS `391.65 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Manual CMO end-to-end smoke is not run by Codex and remains the next user-run gate.
- Kimi B4 post-release operating recheck QA archive: `handoff/to-kimi/_archive/2026-05-12-b4-post-release-operating-recheck-qa.md`.
- Kimi B4 post-release operating recheck QA result: APPROVED, `39 / 39 PASS`.
- Current next gate: user-run end-to-end CMO workflow smoke.

Latest B3 planning gate:

- Design: `docs/superpowers/specs/2026-05-10-b3-log-feedback-loop-design.md`.
- Plan: `docs/superpowers/plans/2026-05-10-b3-log-feedback-loop.md`.
- Agent-ops: `docs/agent-ops/b3-log-feedback-loop-planning-2026-05-10.md`.
- Kimi planning QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b3-log-feedback-loop-planning-qa.md`.
- Kimi QA result: APPROVED, `36 / 36 PASS`.
- Claude review result: `APPROVED with refinements`; B3.1 must keep log reads bounded, redaction expanded, and AI follow-up user-reviewed.
- Gemini remains standby until B3 UI wording exists.
- Future B3 wording must say: logs are read-only, paths/secrets are redacted, follow-up is a draft, AI is not called automatically, and the user must review before sending.

Latest B3.1 helper implementation:

- Product commit: `407e822 Add B3 CMO log feedback helper`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-helper-qa.md`.
- Kimi QA result: APPROVED, `47 / 47 PASS`.
- Scope is helper-only: no user-facing UI wording yet.
- No Gemini wording directive is open; remain standby until B3.3 UI wording exists.

Latest B3.2 endpoint implementation:

- Product commit: `7f8943c Add B3 CMO log feedback endpoint`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-endpoint-qa.md`.
- Kimi QA result: APPROVED, `45 / 45 PASS`.
- Scope is adapter endpoint only: still no user-facing UI wording.
- Future B3.3 wording should keep the output as read-only/redacted log feedback and a draft, not an automatic AI send.

Latest B3.3 UI log feedback implementation:

- Product commit: `3800fdf Add B3 CMO log feedback UI`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-ui-qa.md`.
- Kimi QA result: APPROVED, `45 / 45 PASS`.
- Scope: client helper + LuaAssistant UI + client smoke contract.
- New Korean UI labels: `CMO 로그 확인`, `CMO 로그 스냅샷`, `후속 질문 초안`, `AI 채팅에 넣기`, `초안 복사`.
- Wording states that AI is not called automatically and the draft must be reviewed by the user before calling AI.
- B3 implementation slices are now all Kimi-approved: helper -> endpoint -> UI.
- No Gemini wording directive is open; remain standby unless Codex requests focused B3 release/closeout wording review.

Latest B3 closeout draft:

- Closeout reference: `docs/agent-ops/b3-log-feedback-loop-closeout-2026-05-11.md`.
- Status: `APPROVED / CLOSED`.
- Kimi closeout-docs QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-closeout-docs-qa.md`.
- Kimi closeout-docs QA result: APPROVED, `40 / 40 PASS`.
- User-facing B3 wording should remain: logs are read-only snapshots, paths/secrets are redacted, follow-up is a draft, AI is not called automatically, and the user reviews before sending.
- Recommended next gate: B3 release marker / README update.

Latest B3 release marker:

- Target commit: `c50975e Mark B3 log feedback release in README`.
- Scope: `README.md`, `package.json`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-marker-qa.md`.
- Kimi QA result: APPROVED, `30 / 30 PASS`.
- README proposed current release: `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Release wording remains compact: read-only log feedback loop, B3 smoke baseline, no automatic AI/CMO execution claims.
- Current next gate: B3 release tag / GitHub Release.

Latest B3 release tag:

- Release tag: `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Tagged commit: `c50975e Mark B3 log feedback release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Release title: `CMO Lua Builder Log Feedback Loop`.
- Release state: not draft, not prerelease.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-tag-qa.md`.
- Kimi QA result: APPROVED, `40 / 40 PASS`.
- Release wording keeps the user-facing safety model: read-only logs, redacted snippets, follow-up draft, no automatic AI call, no automatic CMO execution, and CMO engine verification required.
- Current next gate: B3 release closeout docs.

Latest B3 release closeout draft:

- Closeout reference: `docs/agent-ops/b3-log-feedback-loop-release-closeout-2026-05-11.md`.
- Status: `APPROVED / RELEASED`.
- Release tag: `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Kimi release closeout-docs QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-closeout-docs-qa.md`.
- Kimi release closeout-docs QA result: APPROVED, `45 / 45 PASS`.
- Closed user-facing model: `CMO 로그 확인` reads redacted log snapshots and `후속 질문 초안` remains a reviewed draft.
- Recommended next development gate: B4 user-triggered state export / read-back probe.

Latest B2 planning status:

- B2 RunScript Sidecar Writer planning is approved.
- Kimi planning QA: APPROVED, `34 / 34 PASS`, docs / handoff only.
- Claude design review: APPROVED with minor refinements; Codex may proceed to B2.1 writer-helper implementation.
- Design references:
  - `docs/superpowers/specs/2026-05-10-b2-runscript-sidecar-writer-design.md`
  - `docs/superpowers/plans/2026-05-10-b2-runscript-sidecar-writer.md`
  - `docs/agent-ops/b2-runscript-sidecar-writer-planning-2026-05-10.md`
- Current B2 direction: CMO `Lua` root + fixed `AiAssist` namespace + explicit `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
- Korean UI wording review is not open yet because no B2 UI copy has been implemented.
- When opened later, wording must say the saved file is an AI Lua draft, CMO engine verification remains required, and the user must run the loader snippet manually.

Latest B2.1 writer-helper implementation:

- Target commit: `b1fce05 Add B2 RunScript sidecar writer helper`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-helper-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `34 / 34` static checkpoints PASS, no regression.
- Scope is helper-only: `package.json`, `server/cmo-lua-sidecar-writer.mjs`, and `tools/verify-cmo-lua-sidecar-writer-contract.mjs`.
- No user-facing UI wording has been implemented yet.
- Current next gate: B2.2 adapter endpoint; still no user-facing UI copy expected.
- Superseded by accepted B2.3 UI save-controls QA below.
- Future wording must not imply automatic CMO execution, scenario-folder auto-load, or engine-verified Lua.

Latest B2.2 adapter endpoint implementation:

- Target commit: `203b9d7 Add B2 RunScript sidecar endpoint`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-endpoint-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `34 / 34` static checkpoints PASS, no regression.
- Scope is backend-only: `package.json`, `server/ai-provider-adapter.mjs`, and `tools/verify-cmo-lua-sidecar-endpoint.mjs`.
- Endpoint route: `POST /api/cmo/lua-sidecar`.
- No user-facing UI wording has been implemented yet.
- Superseded by accepted B2.3 UI save-controls QA below.
- Future wording should say saved files are AI Lua drafts, execution is manual via `ScenEdit_RunScript('/AiAssist/<file>.lua')`, and CMO engine verification remains required.

Latest B2.3 UI save controls implementation:

- Target commit: `2df8e57 Add B2 sidecar save controls`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-ui-save-controls-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `35 / 35` static checkpoints PASS, no regression.
- New Korean UI labels: `CMO 파일 준비`, `CMO Lua 폴더 저장`.
- New status wording says save preparation/write is complete, CMO execution is manual, and CMO engine verification remains required.
- Loader snippet display uses adapter-returned `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
- No Gemini wording directive is open yet; remain standby unless Codex requests focused wording review.
- Wording must continue to avoid implying automatic CMO execution, scenario-folder auto-load, or engine-verified Lua.

Latest B2 closeout draft:

- Closeout reference: `docs/agent-ops/b2-runscript-sidecar-writer-closeout-2026-05-10.md`.
- Closeout target commit: `fc7a291 Document B2 RunScript sidecar writer closeout`.
- Kimi closeout-docs QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-closeout-docs-qa.md`.
- Kimi closeout-docs QA: APPROVED / ARCHIVED, `35 / 35` static checkpoints PASS, no regression.
- B2 is documented as a user-triggered sidecar writer, not automatic CMO execution.
- Approved user-facing wording remains: `CMO 파일 준비`, `CMO Lua 폴더 저장`, manual `ScenEdit_RunScript('/AiAssist/<file>.lua')`, and CMO engine verification required.
- No Gemini wording directive is open yet; remain standby unless Codex requests a focused release/README wording review.

Latest B2 release marker:

- Target commit: `8c7a18e Mark B2 RunScript sidecar writer release in README`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-marker-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `22 / 22` static checkpoints PASS, no regression.
- README release marker references `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- README keeps the B2 wording compact: RunScript Sidecar Writer smoke baseline only, no claim of automatic CMO execution.
- No Gemini wording directive is open yet; remain standby unless Codex requests release-note wording review.
- Recommended next gate: B2 release tag / GitHub Release.

Latest B2 release tag:

- Release tag: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Tagged commit: `8c7a18e Mark B2 RunScript sidecar writer release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Release title: `CMO Lua Builder RunScript Sidecar Writer`.
- Release state: not draft, not prerelease.
- Release notes preserve the user-triggered wording: dry-run preview, confirmed write, manual `ScenEdit_RunScript('/AiAssist/<file>.lua')`, and CMO engine verification required.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-tag-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `32 / 32` static checkpoints PASS, no regression.
- Release closeout reference: `docs/agent-ops/b2-runscript-sidecar-writer-release-closeout-2026-05-10.md`.
- Release closeout docs QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-closeout-docs-qa.md`.
- Release closeout docs QA: APPROVED / ARCHIVED, `34 / 34` static checkpoints PASS, no regression.
- B2 is fully released and closed.
- No Gemini wording directive is open yet; remain standby unless Codex requests focused B3 wording or release-note review.

Latest DB517 refresh status:

- Product/reference commit: `f7a696a Refresh CMO DB517 references`.
- Closeout draft: `docs/agent-ops/cmo-build-1868-db517-refresh-closeout-2026-05-10.md`.
- Release-notes draft: `docs/agent-ops/cmo-build-1868-db517-refresh-release-notes-2026-05-10.md`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-refresh-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, 32 / 32 static checkpoints PASS, no regression.
- Local CMO baseline: `CMO v1.09 Build 1868 (Public Beta)`, `DB3K_517.db3`, `CWDB_517.db3`.
- Quick Battle wording now uses DB3K_517 example DBIDs and still warns that DBID values are DB/version-specific examples.
- Scope: local DB/reference refresh only; no in-game automation, auto-load proof, backend endpoint, polling, log tailing, sidecar writer, live read-back, or AI auto-send claim.
- Release-notes draft is not a release tag yet.
- Closeout docs QA: APPROVED / ARCHIVED, `34 / 34` static checkpoints PASS.
- Closeout docs QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-closeout-docs-qa.md`.
- Current next gate: B2 planning around the proven CMO Lua-root `ScenEdit_RunScript(...)` execution path.
- Gemini remains standby unless Codex requests focused Korean wording review.

Latest Track B0.1 load-check status:

- Reference: `docs/agent-ops/cmo-lua-load-check-b0-1-2026-05-10.md`.
- Closeout: `docs/agent-ops/cmo-lua-load-check-b0-1-closeout-2026-05-10.md`.
- Tool: `tools/prepare-cmo-lua-load-check.mjs`.
- Smoke: `tools/verify-cmo-lua-load-check-contract.mjs`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b0-1-cmo-lua-load-check-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, 40 / 40 static checkpoints PASS, no regression.
- RunScript correction QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b0-1-runscript-loader-correction-qa.md`.
- RunScript correction QA: APPROVED / ARCHIVED, 34 / 34 static checkpoints PASS, no regression.
- Scope: disposable `.lua` load-check preparation only.
- Default mode is dry-run and writes no file.
- Revised explicit write requires `--cmo-lua-root`, `--write`, and `--yes`.
- Generated Lua prints a marker only; it does not mutate scenario state.
- Korean UX must say scenario-folder auto-load remains unproven.
- Korean UX must not recommend `dofile(...)`; CMO Build 1868 reports it as nil in the console sandbox.
- User manual check proved `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')`, which printed `AiAssist_B0RunScript_20260510_0448` and returned `Yes`.
- Recommended next gate: B2 wording/design around CMO Lua-root `ScenEdit_RunScript(...)`.
- Gemini remains standby unless Codex requests focused wording review.

Latest Track B0 probe status:

- Reference: `docs/agent-ops/cmo-integration-probe-b0-2026-05-09.md`.
- Closeout: `docs/agent-ops/cmo-integration-probe-b0-closeout-2026-05-10.md`.
- Tool: `tools/probe-cmo-integration.mjs`.
- Smoke: `tools/verify-cmo-integration-probe-contract.mjs`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-b0-cmo-integration-probe-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, 34 / 34 static checkpoints PASS, no regression.
- Scope: dry-run local CMO capability probe only.
- Local probe summary: `6 pass / 1 warn / 0 fail / 1 manual / 0 unknown`.
- `.lua` scenario-folder auto-load is not proven; Korean UX should not imply automatic execution.
- `dofile(...)` is disproven for the CMO Build 1868 console sandbox.
- Recommended next slice: B2 wording around explicit `ScenEdit_RunScript(...)` from the CMO Lua root.
- Gemini remains standby unless Codex requests focused wording review.

Latest Track A completion checklist status:

- Checklist: `docs/agent-ops/track-a-local-ai-interpreter-completion-checklist-2026-05-09.md`.
- Closeout: `docs/agent-ops/track-a-local-ai-interpreter-completion-closeout-2026-05-09.md`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-track-a-completion-checklist-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, 25 / 25 static checkpoints PASS, no regression.
- Scope: docs / handoff only.
- Verdict: Track A complete as a local AI interpreter UI baseline only.
- Track B capabilities remain deferred: no CMO Lua execution claim, no live read-back claim, no scenario folder writes, no log tailing, no sidecar Lua deployment.
- Recommended next Track B step: B0 CMO Integration Probe.
- Gemini remains standby unless Codex requests focused wording review.

Latest A3 release-tag status:

- Release tag: `release-2026-05-09-cmo-lua-builder-local-confirmed-context`.
- Tagged commit: `85ccada Mark local confirmed context release in README`.
- GitHub Release: `CMO Lua Builder Local Confirmed Context Workspace`.
- Kimi QA: APPROVED / ARCHIVED, 28 / 28 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-release-tag-qa.md`.
- Release closeout reference: `docs/agent-ops/local-confirmed-context-release-closeout-2026-05-09.md`.
- README and `verify:release` were refreshed to include Track A AI editor smokes.
- Codex pre-QA `npm run verify:release`: PASS, Main JS `377.99 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`.
- Gemini remains standby; no separate Korean wording directive is open unless Codex requests focused copy review.

Latest A3 implementation status:

- Product commits: `953317a Add confirmed context helper contract`, `864e36b Wire confirmed context into assistant state`, `72cca75 Add confirmed context workspace UI`, `3772866 Use confirmed context in follow-up drafts`.
- Kimi QA: APPROVED / ARCHIVED, 29 / 29 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-workspace-qa.md`.
- Closeout reference: `docs/agent-ops/local-confirmed-context-workspace-closeout-2026-05-09.md`.
- Scope: local Confirmed Context Workspace in the Context tab, with source-labeled values reused in AI prompts and text-only follow-up drafts.
- Track B remains deferred: no backend endpoint, no CMO filesystem write/read, no log tailing, no live read-back.
- Codex pre-QA passed confirmed-context smoke, follow-up-needs smoke, workflow-state smoke, lint, build, AI client parser smoke, and AI adapter smoke.
- Build observed: Main JS `377.99 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`, AiResponseReviewPanel `10.15 kB JS / 5.23 kB CSS`.
- Gemini remains standby; no separate Korean wording directive is open unless Codex requests focused copy review after Kimi QA.

Latest A2-2 implementation status:

- Product commits: `64683a0 Add AI follow-up needs contract`, `b32c780 Add AI follow-up needs review`.
- Kimi QA: APPROVED / ARCHIVED, 34 / 34 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-qa.md`.
- Closeout reference: `docs/agent-ops/ai-follow-up-needs-review-closeout-2026-05-09.md`.
- Kimi closeout-docs QA: APPROVED / ARCHIVED, 28 / 28 static checkpoints PASS.
- Closeout QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-closeout-docs-qa.md`.
- Scope: Review panel now groups CMO confirmation needs under `CMO에서 확인할 값` and strengthens `재질문 초안 만들기` with no-invention wording.
- Codex pre-QA passed follow-up-needs smoke, workflow-state smoke, lint, build, AI client parser smoke, and AI adapter smoke.
- Build observed: Main JS `371.44 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`, AiResponseReviewPanel `10.08 kB JS / 5.23 kB CSS`.
- Gemini remains standby; no separate Korean wording directive is open unless Codex requests focused copy review.

Latest A2 completion checklist:

- Reference: `docs/agent-ops/ai-drafting-workflow-a2-completion-checklist-2026-05-09.md`.
- Kimi QA: APPROVED / ARCHIVED, 28 / 28 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-drafting-workflow-a2-completion-qa.md`.
- A2 local AI drafting workflow baseline is documented as complete.
- Track A is not fully closed; recommended next step is A3 Local Confirmed Context Workspace before Track B.
- Gemini remains standby unless Codex requests focused context-workspace wording review.

Latest A2 implementation status:

- Track A2-1 product commit: `eb689df Align AI drafting workflow state`.
- Kimi QA: APPROVED / ARCHIVED, 38 / 38 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-drafting-workflow-state-qa.md`.
- Scope: local AI interpreter workflow states and UI wording alignment.
- States: `idle`, `calling`, `ready`, `askBack`, `blocked`, `error`.
- Codex pre-QA passed workflow smoke, lint, build, AI client parser smoke, and AI adapter smoke.
- Bundle observed: Main JS `371.44 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`.
- Gemini remains standby; no separate Korean wording directive is open unless Codex requests focused copy review after Kimi QA.

Latest A1 implementation status:

- Product commit: `5dd1da1 Add template inspector search filter UX`.
- Kimi QA: APPROVED / ARCHIVED, 27 / 27 static checkpoints PASS.
- Closeout reference: `docs/agent-ops/template-inspector-search-filter-ux-closeout-2026-05-09.md`.
- Current public release: `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Release closeout reference: `docs/agent-ops/template-inspector-search-filter-release-closeout-2026-05-09.md`.
- No separate wording review is open; Gemini remains standby unless Codex asks for focused Korean UX copy review.

## Latest Protected Baseline

Latest local protected HEAD:

```text
80a003a Complete template inspector annotations
```

Latest Template Inspector completion status: `51 / 51` annotations, target `80a003a`, Kimi QA APPROVED / ARCHIVED, no wording regression.

Latest Template Inspector completion closeout reference:

```text
docs/agent-ops/template-inspector-annotation-completion-closeout-2026-05-09.md
```

Template Inspector completion closeout docs QA: APPROVED / ARCHIVED; target `77e5393`, 17 / 17 static checkpoints PASS, docs/handoff-only scope confirmed, no wording regression.

Latest Template Inspector Batch 6 closeout reference:

```text
docs/agent-ops/template-inspector-batch-6-closeout-2026-05-09.md
```

Batch 6 QA status: APPROVED / ARCHIVED; coverage `42 / 51`, no wording regression.

Batch 6 closeout docs QA: APPROVED / ARCHIVED; target `4474fe9`, 16 / 16 static checkpoints PASS, docs/handoff-only scope confirmed, no wording regression.

Latest product release commit:

```text
59bdab9 Mark template inspector completion release in README
```

Latest published release:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-completion
```

Template Inspector completion release-tag QA: APPROVED / ARCHIVED; tag points at `59bdab9`, GitHub Release title is `CMO Lua Builder Template Inspector Completion`, `npm run verify:release` PASS, Template Inspector coverage `51 / 51`, no wording regression.

Latest Template Inspector completion release closeout reference:

```text
docs/agent-ops/template-inspector-completion-release-closeout-2026-05-09.md
```

Completion release closeout docs QA: APPROVED / ARCHIVED; target `9437c3d`, 23 / 23 static checkpoints PASS, docs/handoff-only scope confirmed, no wording regression.

Latest Template Inspector completion post-closeout operating recheck: Kimi QA APPROVED / ARCHIVED; target `dd0e211`, 23 / 23 static checkpoints PASS; `npm run verify:release` PASS; bundle `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`; scenario baseline `1899 / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`; AI adapter smoke had no raw auth leakage; no wording regression.

Current user-facing product model:

- `.scen` files open metadata first.
- Compressed scenario internals require local sidecar generation.
- Prepared sidecars are local/generated/regenerable files.
- Sidecars are not permanent edits to `.scen`.
- The web UI auto-links sidecars when present.

Current bundle baseline:

- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`

Keep wording compact because the UI has watch lines for bundle size.

Latest wording / onboarding status:

- Gemini compact UX wording directive was archived after Codex incorporated the safe subset.
- AI assistant wording now reinforces no-invention ask-back and CMO engine validation.
- Sidecar/cache wording now distinguishes local sidecar cache from temporary extraction cache and states that `.scen` files are not modified.
- Sidecar CLI onboarding now gives explicit `CMO_SCENARIO_SIDECAR_ROOT` guidance when a fresh clone cannot find the external sidecar cache.
- Fresh-clone QA on `d215245`: npm ci/lint/build/audit/loader/smoke PASS, no auth leak.
- Operating recheck on `146861a`: sidecar audit/loader/transient-open smoke PASS; `.scenario-extract-cache/` left empty.
- README sidecar root guidance QA on `e6f2057`: PASS; public release tag, `%USERPROFILE%\.codex\cmo-scenario-sidecars`, `CMO_SCENARIO_SIDECAR_ROOT`, and `.scen` not modified wording are consistent.
- AI client parser contract smoke on `607196f`: PASS; no wording change needed, but ask-back / paste-ready / blocker safety remains protected by `npm run smoke:ai-client-parser`.
- Release verification workflow on `d7afc39`: PASS; README now documents `npm run verify:release` plus the manual split pipeline, with no product wording regression.
- QA workflow release on `e5cd403`: published as `release-2026-05-06-cmo-lua-builder-qa-workflow`; GitHub Release title is `CMO Lua Builder QA Workflow Release`, with Kimi QA approved and no wording regression.
- QA workflow release closeout on `1b7e603`: `docs/agent-ops/qa-workflow-release-closeout-2026-05-07.md` is the concise operating reference for release verification and next work candidates.
- AI Lua safety wording on `1260e33`: PASS; UI now labels AI-generated Lua as `초안` and reinforces `CMO 검증 필요` without changing `isPasteReady` gating.
- AI Lua safety wording release on `a8e9b66`: published as `release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`; GitHub Release title is `CMO Lua Builder AI Lua Safety Wording Update`, with Kimi release-tag QA approved and no wording regression.
- AI Lua safety wording closeout: `docs/agent-ops/ai-lua-safety-wording-release-closeout-2026-05-07.md` is the concise operating reference for current release wording and watch lines.
- Transient scenario sidecar UX on `8f9641e`: PASS; missing-sidecar and transient in-memory open messages now explain AI adapter temporary summary behavior in Korean without implying `.scen` modification.
- Transient sidecar UX release on `ffbd86e`: published as `release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`; GitHub Release title is `CMO Lua Builder Transient Sidecar UX Update`, with Kimi release-tag QA approved and no wording regression.
- Transient sidecar UX closeout: `docs/agent-ops/transient-sidecar-ux-release-closeout-2026-05-07.md` is the concise operating reference for sidecar transient-open wording and watch lines.
- Full operating recheck on `bb86df5`: `npm run verify:release` PASS after approved rerun for sandbox `spawn EPERM`; bundle stayed `366.60 kB JS / 58.27 kB CSS`, sidecar/loader baselines stayed `1899 / 1857 ready / 42 decoderFailed`, and AI adapter smoke had no raw auth leakage.
- Sidecar Cache Settings wording on `2ba77a8`: PASS; Settings > Storage now uses Korean index/status/count labels (`인덱스 확인 중`, `내부 컨텍스트 준비`, `메타데이터만`, `디코더 실패`) while preserving sidecar root, `.scen` not modified guidance, command rows, prompt-copy fallback, and `isPasteReady` gate.
- Sidecar Cache Wording release on `f3539f5`: published as `release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`; GitHub Release title is `CMO Lua Builder Sidecar Cache Wording Update`, with Kimi release-tag QA approved and no wording regression.
- Sidecar Cache Wording closeout: `docs/agent-ops/sidecar-cache-wording-release-closeout-2026-05-08.md` is the concise operating reference for Settings sidecar cache wording and watch lines.
- Sidecar Cache Wording closeout docs QA on `9822cd3`: Kimi approved / archived the closeout consistency check, 16 / 16 static checkpoints PASS, no wording regression.
- Post-closeout operating recheck on `fb33753`: `npm run verify:release` PASS after approved rerun for sandbox `spawn EPERM`; bundle stayed `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`, sidecar/loader baselines stayed `1899 / 1857 ready / 42 decoderFailed`, and AI adapter smoke had no raw auth leakage.
- Template Inspector annotation coverage on `05fd836`: PASS; `doctrine_emcon`, `mission_strike`, `reference_point_add`, and `unit_spawn` now have beginner notes, prerequisites, safe patterns, AI instruction hints, and CMO verification checks. Kimi QA archived at `350a515`, no wording regression.
- Template Inspector annotation Batch 2 on `246c175`: PASS; `event_simple`, `event_regular_time`, `event_unit_detected`, `event_unit_enters_area`, `loadout_set`, and `zone_add` now reinforce trigger/action separation, repeated-action guards, TargetFilter uncertainty, RP-name requirements, Loadout ID source checks, and No-Nav vs Exclusion wording. Kimi QA archived at `6d553b7`, no wording regression.
- Template Inspector annotations release on `f46385b`: published as `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`; GitHub Release title is `CMO Lua Builder Template Inspector Annotation Update`, with Kimi release-tag QA archived at `d85ea78`, `npm run verify:release` PASS, and no wording regression.
- Template Inspector annotations closeout: `docs/agent-ops/template-inspector-annotations-release-closeout-2026-05-09.md` is the concise operating reference for annotation coverage, release verification, watch lines, and next wording candidates.
- Template Inspector annotations closeout docs QA on `e6b0c97`: PASS; target `3ff471e`, 21 / 21 static checkpoints PASS, docs/handoff-only scope confirmed, no wording regression.
- Template Inspector post-closeout operating recheck: `npm run verify:release` PASS; bundle stayed `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`, sidecar/loader baselines stayed `1899 / 1857 ready / 42 decoderFailed`, and AI adapter smoke had no raw auth leakage.
- Template Inspector post-closeout recheck QA on `f2d7ceb`: PASS; target `adddf64`, 20 / 20 static checkpoints PASS, no wording regression.
- Template Inspector annotation Batch 3 on `4d7208a`: PASS; `side_posture`, `event_contact_emcon`, `unit_spawn_random`, `event_teleport`, `event_dbid_score`, and `event_cargo_drop` now reinforce real Side/posture values, no invented contact/EMCON values, map-confirmed coordinate bounds, GUID-first unit lookup, Database Viewer DBIDs, and RP-name requirements. Kimi QA archived under `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-3-qa.md`, closeout reference is `docs/agent-ops/template-inspector-batch-3-closeout-2026-05-09.md`, no wording regression.
- Template Inspector annotation Batch 4 on `ac8949f`: PASS; `mission_support`, `mission_cargo`, `mission_ferry`, `mission_mine`, `kvstore_set`, and `event_kv_flag` now reinforce real Side/RP/Mission/cargo values, KeyValue key naming, one-shot guard behavior, repeatable event risk, and no invented mission/RP/cargo/trigger values. Kimi QA archived under `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-4-qa.md`, no wording regression.
- Template Inspector Batch 4 closeout: `docs/agent-ops/template-inspector-batch-4-closeout-2026-05-09.md` is the concise operating reference for Batch 4 annotation coverage, safety wording, watch lines, and next wording candidates.
- Template Inspector Batch 4 closeout docs QA: PASS; target `3f8911b`, 15 / 15 static checkpoints PASS, docs/handoff-only scope confirmed, no wording regression.
- Template Inspector annotation Batch 5 on `a80b9ea`: PASS; `event_unit_destroyed`, `event_unit_damaged`, `event_missions_toggle`, `event_escalation`, `weather_random`, and `event_dynamic_weather` now reinforce real TargetFilter/DBID/type IDs, damage thresholds, Mission/Side names, trigger options, posture/doctrine values, bounded weather ranges, and no invented event/weather values. Kimi QA archived under `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-5-qa.md`, no wording regression.
- Template Inspector Batch 5 closeout: `docs/agent-ops/template-inspector-batch-5-closeout-2026-05-09.md` is the concise operating reference for Batch 5 annotation coverage, event/weather safety wording, watch lines, and next wording candidates.
- Template Inspector Batch 5 closeout docs QA: PASS; target `11367cd`, 15 / 15 static checkpoints PASS, docs/handoff-only scope confirmed, no wording regression.
- Template Inspector annotation Batch 6 on `81d5b66`: PASS; `event_complex`, `event_split_merge`, `event_ambient_traffic`, `event_scen_loaded`, `event_unit_x`, and `inst_import` now reinforce real Event Editor options, GUID-first split/merge caution, Civilian ship DBIDs, coordinate bounds, ScenLoaded idempotence, UnitX payload validation, trusted `.inst` filenames, Side names, and DB compatibility checks. Kimi QA archived under `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-6-qa.md`, no wording regression.
- Template Inspector annotation Batch 7 on `80a003a`: PASS; coverage reached `51 / 51`, with final guidance for startup weather, loadout scramble, generic mission fallback, advanced ops, airbase scramble, CAP patrol, multi-file output, quickbattle, and strike alpha presets. Kimi QA archived under `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-7-qa.md`, no wording regression.

## Wording Review Triggers

Review only when Codex asks for wording around:

- `템플릿 / 프리셋 삽입`
- `폼 추가 / Builder Forms`
- `사용자 지정 프리셋 > 수정`
- `현재 표시된 프리셋 폼만 저장합니다`
- AI interpreter chat / follow-up guidance
- sidecar/cache explanation
- Template Inspector beginner notes
- ask-back guidance for ambiguous CMO goals

## Preferred Language Rules

Scenario / sidecar wording:

- Prefer `sidecar 준비 필요`, `로컬 분석 파일`, `임시 추출 캐시`.
- Avoid saying `.scen` was modified.
- Avoid saying deletion is always safe unless the UI also says sidecars must be regenerated.
- Avoid calling metadata-only state a failure.
- Existing `ContentScenario` support is a success path, not a failure.
- Existing `decoderLegacyCmano` items are legacy limitations unless Codex says a new class appeared.

AI assistant wording:

- Explain that AI can draft Lua, but CMO engine testing is still required.
- Reinforce ask-back when Side, Mission, Unit GUID, DBID, Loadout ID, RP, or Zone is missing.
- Keep warnings short and actionable.
- Do not imply AI output is safe to paste unless paste-ready validation passes.

Template / preset wording:

- `템플릿 / 프리셋 삽입`: templates/presets append below existing Lua and preserve current text.
- `폼 추가 / Builder Forms`: belongs to Preset Guide and creates editable preset forms.
- `수정`: replaces the current builder form/settings with the saved preset.
- `현재 표시된 프리셋 폼만 저장합니다`: saves one displayed form, avoiding accidental bundle presets.

Template Inspector notes:

- Keep exact CMO API names such as `ScenEdit_*`, `Tool_*`, `VP_*`.
- Mark uncertain API behavior, DBID, Loadout ID, GUID, Side, Mission, RP, or Zone claims as `Codex 확인 필요`.
- Do not claim engine-tested behavior unless Codex/user verified it.

## Output Shape

Prefer concise Korean:

- label candidates
- one-line tooltip text
- short empty-state text
- compact warning text
- beginner checklist
- small ambiguity/ask-back table

Avoid long tutorial prose unless Codex explicitly asks.

## Boundaries

- Do not edit code.
- Do not write into CMO install/workshop folders.
- Do not modify `.scen` files.
- Do not batch prepare scenarios.
- Do not paste long copyrighted manual/forum text.
