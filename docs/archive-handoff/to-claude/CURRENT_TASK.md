# CURRENT TASK - Claude

Status: sole maintainer (2026-07-04부터; 멀티에이전트 분업 종료)

> 2026-07-04 갱신: 아래 "Current manual gate"는 **CLOSED / PASS** —
> 실기 증거는 `docs/agent-ops/manual-cmo-workflow-smoke-result-2026-07-04.md` 참조
> (Build 1892에서 B2 + B3 + 신규 inbox 폴러 자동 실행 검증 완료).
> 이후 표준 작업 경로는 리포 CLAUDE.md의 AI Bridge 루프.

## Active State

- No active date-stamped Claude review directive is currently open.
- CMO Wiki / Code Assistant architecture review is complete and archived:

```text
handoff/to-claude/_archive/2026-05-13/2026-05-13-cmo-wiki-code-assistant-architecture-review.md
```

- Review memo delivered to Codex:

```text
C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-CMO-Wiki-Code-Assistant\cmo-wiki-code-assistant-architecture-review.md
```

- Result: APPROVED with refinements; implemented as helper extraction, wiki panel, editor reference helper, and text-only AI draft routing.
- Closeout doc: `docs/agent-ops/cmo-wiki-code-assistant-closeout-2026-05-13.md`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-code-assistant-qa.md`; result APPROVED, `38 / 38 PASS`.
- Release tag QA archive: `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-tag-qa.md`; result APPROVED, `35 / 35 PASS`.
- Release closeout doc: `docs/agent-ops/cmo-wiki-reference-helper-release-closeout-2026-05-13.md`.
- Current next gate: Kimi release closeout-docs QA via `handoff/to-kimi/2026-05-13-cmo-wiki-reference-helper-release-closeout-docs-qa.md`.
- Latest operating recheck: `npm run verify:release` PASS after approved rerun from sandbox `spawn EPERM`; CMO Wiki release remains current.
- Stand by until Codex opens the next review directive.
- Archived directives under `_archive/` are evidence only, not active tasks.

Current manual gate:

- Runbook: `docs/agent-ops/b4-manual-cmo-workflow-smoke-2026-05-12.md`.
- Status: READY / USER-RUN.
- Path: B2 save -> user `ScenEdit_RunScript('/AiAssist/<file>.lua')` in CMO -> B3 log feedback -> B4 state snapshot import -> text-only AI follow-up draft.
- Codex/Claude should not claim this smoke passed until user-run evidence is provided.
- If the smoke fails, keep the next response focused on the smallest failing layer: B2 save, CMO RunScript, B3 log feedback, or B4 snapshot import.

Latest B4 planning gate:

- Design: `docs/superpowers/specs/2026-05-11-b4-user-triggered-state-export-design.md`.
- Plan: `docs/superpowers/plans/2026-05-11-b4-user-triggered-state-export.md`.
- Agent-ops: `docs/agent-ops/b4-user-triggered-state-export-planning-2026-05-11.md`.
- Kimi planning QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-user-triggered-state-export-planning-qa.md`.
- Kimi QA result: APPROVED, `55 / 55 PASS`.
- Claude review directive archive: `handoff/to-claude/_archive/2026-05-11/2026-05-11-b4-user-triggered-state-export-design-review.md`.
- Claude review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B4-User-Triggered-State-Export\b4-user-triggered-state-export-review.md`.
- Claude review result: APPROVED with refinements.
- B4 locked direction: user-triggered imported CMO state snapshots from pasted `Tool_DumpEvents()` / `ScenEdit_GetEvent(...)` text, `source.live === false`, bounded/redacted parser wrapper, text-only follow-up draft, optional Confirmed Context promotion.
- B4 exclusions: no automatic AI send, automatic CMO execution, polling, watcher, live daemon claim, browser-provided filesystem root, CMO file mutation, or `.scen` mutation.
- B4.1 refinements required inside helper slice: nested raw assertions, redaction-before-parse comment, truncation signals, and UTF-16 char-unit label.
- Latest B4.1 product commit: `876903f Add B4 CMO state snapshot helper`.
- Scope: `package.json`, `server/cmo-state-snapshot-importer.mjs`, `tools/verify-cmo-state-snapshot-contract.mjs`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-helper-qa.md`.
- Kimi QA result: APPROVED, `80 / 80 PASS`.
- Codex pre-QA: `smoke:cmo-state-snapshot`, `lint`, `build`, `smoke:ai-adapter`, and `verify:release` PASS; build/adapter/verify needed approved rerun because of sandbox `spawn EPERM`.
- B4.1 remains helper-only: no adapter endpoint, UI, polling, watcher, CMO execution, live read-back claim, or AI auto-send.
- Latest B4.2 endpoint commit: `92a5ca6 Add B4 CMO state snapshot endpoint`.
- Scope: `package.json`, `server/ai-provider-adapter.mjs`, `tools/verify-cmo-state-snapshot-endpoint.mjs`.
- Endpoint: `POST /api/cmo/state-snapshot/import`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-endpoint-qa.md`.
- Kimi QA result: APPROVED, `70 / 70 PASS`.
- Codex pre-QA: endpoint smoke RED `404 !== 200`, then GREEN PASS after route wiring; helper smoke, lint, build, AI adapter smoke, and `verify:release` PASS.
- B4.2 remains UI-free: no browser-provided root, no AI auto-send, no CMO execution, no CMO file writes, no polling/watcher, and no live read-back claim.
- Latest B4.3 UI commit: `5d3b06d Add B4 CMO state snapshot UI`.
- Scope: `package.json`, `src/lib/aiAdapterClient.js`, `src/components/LuaAssistant.jsx`, `tools/verify-ai-adapter-client-state-snapshot-contract.mjs`.
- UI labels include `CMO 상태 스냅샷 가져오기`, `스냅샷 가져오기`, `가져온 CMO 스냅샷`, and `후속 질문 초안 만들기`.
- UI wording states imported snapshot and `실시간 연결이 아닙니다`.
- Codex pre-QA: client smoke RED on missing export, then GREEN after helper/UI wiring; B4 helper/endpoint, B3 client, lint, build, AI adapter smoke, and `verify:release` PASS.
- Build baseline after B4.3: Main JS `391.65 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-ui-qa.md`.
- Kimi QA result: APPROVED, `74 / 74 PASS`.
- B4 closeout doc: `docs/agent-ops/b4-user-triggered-state-export-closeout-2026-05-11.md`.
- B4 closeout docs commit: `69040d3 Document B4 user-triggered state export closeout`.
- Kimi closeout-docs QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-user-triggered-state-export-closeout-docs-qa.md`.
- Kimi closeout-docs QA result: APPROVED, `60 / 60 PASS`.
- Latest B4 release marker commit: `b1fac3d Mark B4 state snapshot import release in README`.
- Scope: `README.md`, `package.json`.
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
- Review directive archive: `handoff/to-claude/_archive/2026-05-10/2026-05-10-b3-log-feedback-loop-design-review.md`.
- Review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B3-Log-Feedback-Loop\b3-log-feedback-loop-review.md`.
- Review verdict: `APPROVED with refinements`.
- Kimi planning QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b3-log-feedback-loop-planning-qa.md`.
- Kimi QA result: APPROVED, `36 / 36 PASS`.
- B3 locked direction: read-only CMO log feedback from `ExceptionLog_*.txt` / `LuaHistory_*.txt`, server-side logs root only, redacted bounded snippets, text-only follow-up draft, no automatic AI send, no automatic CMO execution, no polling/watcher/live read-back.
- B3.1 refinements required before helper QA: positioned tail reads, implemented `since`, expanded path redaction, and no-write/no-exec/no-full-read smoke guards.

Latest B3.1 helper implementation:

- Product commit: `407e822 Add B3 CMO log feedback helper`.
- Scope: `package.json`, `server/cmo-log-feedback-reader.mjs`, `tools/verify-cmo-log-feedback-contract.mjs`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-helper-qa.md`.
- Kimi QA result: APPROVED, `47 / 47 PASS`.
- Codex pre-QA: `smoke:cmo-log-feedback`, `smoke:cmo-lua-load-check`, `lint`, `build`, `smoke:ai-adapter`, and `verify:release` PASS.
- Helper remains endpoint-free and UI-free; no CMO polling, watchers, live read-back, automatic CMO execution, or AI auto-send.
- Current next gate: B3.2 adapter endpoint and endpoint smoke.
- Claude remains standby unless Codex requests B3.2 endpoint review.

Latest B3.2 endpoint implementation:

- Product commit: `7f8943c Add B3 CMO log feedback endpoint`.
- Scope: `package.json`, `server/ai-provider-adapter.mjs`, `tools/verify-cmo-log-feedback-endpoint.mjs`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-endpoint-qa.md`.
- Kimi QA result: APPROVED, `45 / 45 PASS`.
- Codex pre-QA: endpoint smoke, helper smoke, lint, build, AI adapter smoke, and `verify:release` PASS.
- Endpoint remains UI-free; no browser-provided `logsRoot`, no CMO polling, no watchers, no live read-back, no automatic CMO execution, and no AI auto-send.
- Current next gate: B3.3 UI log feedback fetch and text-only follow-up draft.

Latest B3.3 UI log feedback implementation:

- Product commit: `3800fdf Add B3 CMO log feedback UI`.
- Scope: `package.json`, `src/lib/aiAdapterClient.js`, `src/components/LuaAssistant.jsx`, `tools/verify-ai-adapter-client-log-feedback-contract.mjs`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-ui-qa.md`.
- Kimi QA result: APPROVED, `45 / 45 PASS`.
- Codex pre-QA: TDD RED on missing `fetchCmoLogFeedback`, then client smoke GREEN; helper/endpoint/B2 client smokes PASS; lint/build/AI adapter smoke/`verify:release` PASS.
- Build baseline after B3.3: Main JS `383.67 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- UI labels: `CMO 로그 확인`, `CMO 로그 스냅샷`, `후속 질문 초안`, `AI 채팅에 넣기`.
- B3.3 remains user-reviewed and text-only: no automatic AI send, no browser-provided log root, no CMO polling, no watcher, no live read-back, and no automatic CMO execution.
- Current next gate: B3 log feedback closeout docs.
- Claude remains standby unless Codex requests a focused B3 release/closeout review.

Latest B3 closeout draft:

- Closeout reference: `docs/agent-ops/b3-log-feedback-loop-closeout-2026-05-11.md`.
- Status: `APPROVED / CLOSED`.
- Kimi closeout-docs QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-closeout-docs-qa.md`.
- Kimi closeout-docs QA result: APPROVED, `40 / 40 PASS`.
- B3 chain: planning -> helper -> endpoint -> UI.
- Preserved boundaries: read-only log snapshots, text-only follow-up draft, no automatic AI send, no automatic CMO execution, no polling/watcher/live read-back, no browser-provided root.
- Recommended next gate: B3 release marker / README update.

Latest B3 release marker:

- Target commit: `c50975e Mark B3 log feedback release in README`.
- Scope: `README.md`, `package.json`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-marker-qa.md`.
- Kimi QA result: APPROVED, `30 / 30 PASS`.
- README references proposed release tag `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- `verify:release` now includes `smoke:cmo-log-feedback`, `smoke:cmo-log-feedback-endpoint`, and `smoke:ai-adapter-client-log-feedback`.
- Codex pre-QA: B3 smokes PASS and expanded `npm run verify:release` PASS.
- Current next gate: B3 release tag / GitHub Release.

Latest B3 release tag:

- Release tag: `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Tagged commit: `c50975e Mark B3 log feedback release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Release title: `CMO Lua Builder Log Feedback Loop`.
- Release state: not draft, not prerelease.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-tag-qa.md`.
- Kimi QA result: APPROVED, `40 / 40 PASS`.
- Release notes preserve B3 boundaries: read-only log snapshots, redaction, text-only follow-up draft, no automatic AI send, no automatic CMO execution, no polling/watcher/live read-back.
- Current next gate: B3 release closeout docs.

Latest B3 release closeout draft:

- Closeout reference: `docs/agent-ops/b3-log-feedback-loop-release-closeout-2026-05-11.md`.
- Status: `APPROVED / RELEASED`.
- Release tag: `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Release-tag QA archive commit: `d12cefa Archive B3 log feedback release tag QA`.
- Kimi release closeout-docs QA archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-closeout-docs-qa.md`.
- Kimi release closeout-docs QA result: APPROVED, `45 / 45 PASS`.
- Closed chain: planning -> helper -> endpoint -> UI -> closeout -> release marker -> release tag.
- Recommended next development gate: B4 user-triggered state export / read-back probe.

Latest B2 design review:

- Review directive archive: `handoff/to-claude/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-design-review.md`.
- Review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B2-RunScript-Sidecar-Writer\b2-runscript-sidecar-writer-review.md`.
- Verdict: APPROVED with minor refinements.
- Codex may proceed to B2.1 writer-helper implementation.
- Non-blocking refinements were folded into the Codex B2 spec / plan: ignored client `cmoLuaRoot`, server-confirmed dry-run/write echo fields, no Lua body in endpoint responses, existing-file UX, `AiAssist_B0` sibling namespace note, and nested `ScenEdit_RunScript` allowlist deferral.

Latest B2.1 writer-helper implementation:

- Target commit: `b1fce05 Add B2 RunScript sidecar writer helper`.
- Scope: `package.json`, `server/cmo-lua-sidecar-writer.mjs`, `tools/verify-cmo-lua-sidecar-writer-contract.mjs`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-helper-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `34 / 34` static checkpoints PASS, no regression.
- Codex pre-QA: TDD RED with missing helper module, TDD GREEN with `npm run smoke:cmo-lua-sidecar-writer` PASS.
- Additional pre-QA: `npm run smoke:cmo-lua-load-check` PASS, `npm run verify:release` PASS, AI adapter smoke no raw auth leakage.
- B2.1 remains helper-only: no adapter endpoint, UI controls, CMO polling, log tailing, live read-back, or AI auto-send.
- Current next gate: B2.2 adapter endpoint and endpoint smoke.
- Claude remains standby unless Codex requests focused review for B2.2 endpoint design or CMO runtime assumptions.

Latest B2.2 adapter endpoint implementation:

- Target commit: `203b9d7 Add B2 RunScript sidecar endpoint`.
- Scope: `package.json`, `server/ai-provider-adapter.mjs`, `tools/verify-cmo-lua-sidecar-endpoint.mjs`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-endpoint-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `34 / 34` static checkpoints PASS, no regression.
- Codex pre-QA: endpoint smoke RED reached `404 != 200` after approved rerun, then GREEN PASS after route wiring.
- Additional pre-QA: writer smoke PASS, B0.1 load-check smoke PASS, `npm run verify:release` PASS, AI adapter smoke no raw auth leakage.
- Endpoint ignores request-body `cmoLuaRoot` and resolves the root server-side through `CMO_LUA_ROOT` / helper default.
- B2.2 remains backend-only: no UI controls, CMO polling, log tailing, live read-back, automatic CMO execution, or AI auto-send.
- Superseded by accepted B2.3 UI save-controls QA below.

Latest B2.3 UI save controls implementation:

- Target commit: `2df8e57 Add B2 sidecar save controls`.
- Scope: `package.json`, `tools/verify-ai-adapter-client-sidecar-contract.mjs`, `src/lib/aiAdapterClient.js`, `src/components/LuaAssistant.jsx`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-ui-save-controls-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `35 / 35` static checkpoints PASS, no regression.
- Codex pre-QA: client helper smoke RED failed on missing `saveCmoLuaSidecar` export, then GREEN PASS after implementation.
- Additional pre-QA: endpoint smoke PASS, writer smoke PASS, B0.1 load-check smoke PASS, `npm run verify:release` PASS, AI adapter smoke no raw auth leakage.
- Build baseline after B2.3: Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- B2.3 adds UI controls only; no CMO polling, log tailing, live read-back, automatic CMO execution, or AI auto-send.
- Claude remains standby unless Codex requests focused B2 closeout or runtime review.

Latest B2 closeout draft:

- Closeout reference: `docs/agent-ops/b2-runscript-sidecar-writer-closeout-2026-05-10.md`.
- Closeout target commit: `fc7a291 Document B2 RunScript sidecar writer closeout`.
- Kimi closeout-docs QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-closeout-docs-qa.md`.
- Kimi closeout-docs QA: APPROVED / ARCHIVED, `35 / 35` static checkpoints PASS, no regression.
- B2 is now documented as a local, user-triggered CMO Lua sidecar writer path.
- Approved path: paste-ready AI draft -> `CMO 파일 준비` dry-run -> `CMO Lua 폴더 저장` confirmed write -> user-run `ScenEdit_RunScript('/AiAssist/<file>.lua')` -> CMO engine verification.
- Preserved boundaries: no scenario-folder auto-load claim, no automatic CMO execution, no CMO polling, no log tailing, no live read-back, no AI auto-send, no browser-provided filesystem root.
- Recommended next gate: B2 release marker / README update.

Latest B2 release marker:

- Target commit: `8c7a18e Mark B2 RunScript sidecar writer release in README`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-marker-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `22 / 22` static checkpoints PASS, no regression.
- README now references `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- `package.json` `verify:release` now includes `npm run smoke:ai-adapter-client-sidecar`.
- Codex pre-QA: `npm run smoke:ai-adapter-client-sidecar` PASS and `npm run verify:release` PASS.
- No tag or GitHub Release has been created in this target commit.
- Recommended next gate: B2 release tag / GitHub Release.

Latest B2 release tag:

- Release tag: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Tagged commit: `8c7a18e Mark B2 RunScript sidecar writer release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Release title: `CMO Lua Builder RunScript Sidecar Writer`.
- Release state: not draft, not prerelease.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-tag-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, `32 / 32` static checkpoints PASS, no regression.
- Release closeout reference: `docs/agent-ops/b2-runscript-sidecar-writer-release-closeout-2026-05-10.md`.
- B2 is now the public release baseline for user-triggered AI Lua draft save to the CMO Lua root plus manual `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
- Release closeout docs QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-closeout-docs-qa.md`.
- Release closeout docs QA: APPROVED / ARCHIVED, `34 / 34` static checkpoints PASS, no regression.
- B2 is fully released and closed.
- Claude remains standby unless Codex requests focused B3 planning or post-release review.

Latest DB517 refresh status:

- Product/reference commit: `f7a696a Refresh CMO DB517 references`.
- Closeout draft: `docs/agent-ops/cmo-build-1868-db517-refresh-closeout-2026-05-10.md`.
- Release-notes draft: `docs/agent-ops/cmo-build-1868-db517-refresh-release-notes-2026-05-10.md`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-refresh-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, 32 / 32 static checkpoints PASS, no regression.
- Local CMO baseline: `CMO v1.09 Build 1868 (Public Beta)`, `DB3K_517.db3`, `CWDB_517.db3`.
- Component index baseline: `101078` entries (`DB3K 72796`, `CWDB 28282`).
- Scope: local DB/reference refresh only; no backend endpoint, polling, log tailing, sidecar writer, live read-back, AI auto-send, or Lua apply behavior change.
- Release-notes draft is not a release tag yet.
- Closeout docs QA: APPROVED / ARCHIVED, `34 / 34` static checkpoints PASS.
- Closeout docs QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-closeout-docs-qa.md`.
- Current next gate: B2 planning around the proven CMO Lua-root `ScenEdit_RunScript(...)` execution path.
- Claude remains standby unless Codex requests focused CMO API or release-note review.

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
- User manual check on CMO Build 1868: `dofile(...)` failed as nil in the console sandbox.
- User manual check on CMO Build 1868: `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` printed `AiAssist_B0RunScript_20260510_0448` and returned `Yes`.
- `.lua` scenario-folder auto-load remains unproven.
- Recommended next gate: B2 design around CMO Lua-root `ScenEdit_RunScript(...)`.
- Claude remains standby unless Codex requests focused manual-check design or CMO API review.

Latest Track B0 probe status:

- Reference: `docs/agent-ops/cmo-integration-probe-b0-2026-05-09.md`.
- Closeout: `docs/agent-ops/cmo-integration-probe-b0-closeout-2026-05-10.md`.
- Tool: `tools/probe-cmo-integration.mjs`.
- Smoke: `tools/verify-cmo-integration-probe-contract.mjs`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-b0-cmo-integration-probe-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, 34 / 34 static checkpoints PASS, no regression.
- Scope: dry-run local CMO capability probe only.
- Local probe summary: `6 pass / 1 warn / 0 fail / 1 manual / 0 unknown`.
- `.lua` scenario-folder auto-load is not proven.
- `dofile(...)` is disproven for the CMO Build 1868 console sandbox.
- Recommended next slice: B2 design around explicit `ScenEdit_RunScript(...)` from the CMO Lua root.
- Claude remains standby unless Codex requests focused B0.1 design or CMO API review.

Latest Track A completion checklist status:

- Checklist: `docs/agent-ops/track-a-local-ai-interpreter-completion-checklist-2026-05-09.md`.
- Closeout: `docs/agent-ops/track-a-local-ai-interpreter-completion-closeout-2026-05-09.md`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-track-a-completion-checklist-qa.md`.
- Kimi QA: APPROVED / ARCHIVED, 25 / 25 static checkpoints PASS, no regression.
- Scope: docs / handoff only.
- Verdict: Track A complete as a local AI interpreter UI baseline only.
- Track B capabilities remain deferred: no CMO Lua execution claim, no live read-back claim, no scenario folder writes, no log tailing, no sidecar Lua deployment.
- Recommended next Track B step: B0 CMO Integration Probe.
- Claude remains standby unless Codex requests focused B0 review.

Latest A3 release-tag status:

- Release tag: `release-2026-05-09-cmo-lua-builder-local-confirmed-context`.
- Tagged commit: `85ccada Mark local confirmed context release in README`.
- GitHub Release: `CMO Lua Builder Local Confirmed Context Workspace`.
- Kimi QA: APPROVED / ARCHIVED, 28 / 28 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-release-tag-qa.md`.
- Release closeout reference: `docs/agent-ops/local-confirmed-context-release-closeout-2026-05-09.md`.
- README and `verify:release` were refreshed to include Track A AI editor smokes.
- Codex pre-QA `npm run verify:release`: PASS, Main JS `377.99 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`.
- Claude remains standby; no separate release review is open unless Codex requests focused review.

Latest A3 implementation status:

- Product commits: `953317a Add confirmed context helper contract`, `864e36b Wire confirmed context into assistant state`, `72cca75 Add confirmed context workspace UI`, `3772866 Use confirmed context in follow-up drafts`.
- Kimi QA: APPROVED / ARCHIVED, 29 / 29 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-workspace-qa.md`.
- Closeout reference: `docs/agent-ops/local-confirmed-context-workspace-closeout-2026-05-09.md`.
- Scope: local Confirmed Context Workspace for source-labeled CMO values, prompt reuse, and text-only follow-up draft reuse.
- Track B remains deferred: no backend endpoint, no CMO filesystem write/read, no log tailing, no live read-back.
- Codex pre-QA passed confirmed-context smoke, follow-up-needs smoke, workflow-state smoke, lint, build, AI client parser smoke, and AI adapter smoke.
- Build observed: Main JS `377.99 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`, AiResponseReviewPanel `10.15 kB JS / 5.23 kB CSS`.
- Claude remains standby; no separate A3 review is open unless Codex requests focused review.

Latest A2-2 implementation status:

- Product commits: `64683a0 Add AI follow-up needs contract`, `b32c780 Add AI follow-up needs review`.
- Kimi QA: APPROVED / ARCHIVED, 34 / 34 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-qa.md`.
- Closeout reference: `docs/agent-ops/ai-follow-up-needs-review-closeout-2026-05-09.md`.
- Kimi closeout-docs QA: APPROVED / ARCHIVED, 28 / 28 static checkpoints PASS.
- Closeout QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-closeout-docs-qa.md`.
- Scope: grouped CMO confirmation needs and safer follow-up draft in the lazy AI Response Review panel.
- Codex pre-QA passed follow-up-needs smoke, workflow-state smoke, lint, build, AI client parser smoke, and AI adapter smoke.
- Build observed: Main JS `371.44 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`, AiResponseReviewPanel `10.08 kB JS / 5.23 kB CSS`.
- Claude remains standby; no separate review is open unless Codex requests focused review.

Latest A2 completion checklist:

- Reference: `docs/agent-ops/ai-drafting-workflow-a2-completion-checklist-2026-05-09.md`.
- Kimi QA: APPROVED / ARCHIVED, 28 / 28 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-drafting-workflow-a2-completion-qa.md`.
- A2 local AI drafting workflow baseline is documented as complete.
- Track A is not fully closed; recommended next step is A3 Local Confirmed Context Workspace before Track B.
- Claude remains standby unless Codex requests focused context-workspace review.

Latest A2 implementation status:

- Track A2-1 product commit: `eb689df Align AI drafting workflow state`.
- Kimi QA: APPROVED / ARCHIVED, 38 / 38 static checkpoints PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-drafting-workflow-state-qa.md`.
- Scope: shared local UI workflow state for `idle`, `calling`, `ready`, `askBack`, `blocked`, and `error`.
- Codex pre-QA passed workflow smoke, lint, build, AI client parser smoke, and AI adapter smoke.
- Bundle observed: Main JS `371.44 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`.
- Claude remains standby; no separate workflow-state review is open unless Codex requests one after Kimi QA.

Latest A1 implementation status:

- Product commit: `5dd1da1 Add template inspector search filter UX`.
- Kimi QA: APPROVED / ARCHIVED, 27 / 27 static checkpoints PASS.
- Closeout reference: `docs/agent-ops/template-inspector-search-filter-ux-closeout-2026-05-09.md`.
- Current public release: `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Release closeout reference: `docs/agent-ops/template-inspector-search-filter-release-closeout-2026-05-09.md`.
- No parser, pruning, adapter, decoder, or always-visible assistant review is open.

## Latest Protected Baseline

Latest local protected HEAD:

```text
80a003a Complete template inspector annotations
```

Latest Template Inspector completion status: `51 / 51` annotations, target `80a003a`, Kimi QA APPROVED / ARCHIVED, no parser/pruning/adapter/decoder review opened.

Latest Template Inspector completion closeout reference:

```text
docs/agent-ops/template-inspector-annotation-completion-closeout-2026-05-09.md
```

Template Inspector completion closeout docs QA: APPROVED / ARCHIVED; target `77e5393`, 17 / 17 static checkpoints PASS, docs/handoff-only scope confirmed, no regression.

Latest Template Inspector Batch 6 closeout reference:

```text
docs/agent-ops/template-inspector-batch-6-closeout-2026-05-09.md
```

Batch 6 QA status: APPROVED / ARCHIVED; coverage `42 / 51`, target `81d5b66`, no parser/pruning/adapter/decoder review opened.

Batch 6 closeout docs QA: APPROVED / ARCHIVED; target `4474fe9`, 16 / 16 static checkpoints PASS, docs/handoff-only scope confirmed, no regression.

Latest product release commit:

```text
59bdab9 Mark template inspector completion release in README
```

Latest published release:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-completion
```

Template Inspector completion release-tag QA: APPROVED / ARCHIVED; tag points at `59bdab9`, GitHub Release title is `CMO Lua Builder Template Inspector Completion`, `npm run verify:release` PASS, Template Inspector coverage `51 / 51`, no parser/pruning/adapter/decoder review opened.

Latest Template Inspector completion release closeout reference:

```text
docs/agent-ops/template-inspector-completion-release-closeout-2026-05-09.md
```

Completion release closeout docs QA: APPROVED / ARCHIVED; target `9437c3d`, 23 / 23 static checkpoints PASS, docs/handoff-only scope confirmed, no parser/pruning/adapter/decoder review opened.

Latest Template Inspector completion post-closeout operating recheck: Kimi QA APPROVED / ARCHIVED; target `dd0e211`, 23 / 23 static checkpoints PASS; `npm run verify:release` PASS; bundle `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`; scenario baseline `1899 / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`; AI adapter smoke had no raw auth leakage; no parser/pruning/adapter/decoder review opened.

Accepted bundle baseline:

- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `PresetGuide`: `30.05 kB JS / 5.86 kB CSS`
- `AiAdapterSettings`: `10.44 kB JS / 2.43 kB CSS`
- `AiInterpreterChatPanel`: `10.19 kB JS / 6.19 kB CSS`
- `AiResponseReviewPanel`: `5.19 kB JS / 3.50 kB CSS`
- `aiContextPruning`: `8.56 kB`

Latest post-release verification (`d215245`, fresh clone from `release-2026-05-06-cmo-lua-builder-sidecar-onboarding`):

- `audit:scenario-sidecars`: PASS (`1899` index entries, `3799` protected sidecars, `24` orphans / `5.6 MB`)
- `verify:scenario-loader`: PASS (`1857` ready / `42` decoderFailed, issues `0`)
- `npm ci`: PASS (`0` vulnerabilities)
- `lint`: PASS
- `build`: PASS (`366.01 kB JS / 58.27 kB CSS`)
- `smoke:ai-adapter`: PASS; no raw `Bearer` / `sk-` leakage

Latest operating recheck (`146861a`):

- `audit:scenario-sidecars`: PASS (`1899` index entries, `3799` protected sidecars, `24` orphans / `5.6 MB`)
- `verify:scenario-loader`: PASS (`1857` ready / `42` decoderFailed, issues `0`)
- `smoke:scenario-transient`: PASS after approved spawn permissions; in-memory summary returned and `.scenario-extract-cache/` left empty

Latest parser contract smoke (`607196f`):

- `smoke:ai-client-parser`: PASS
- `lint`: PASS
- `build`: PASS (`366.29 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`)
- `smoke:ai-adapter`: PASS; no raw `Bearer` / `sk-` leakage
- Coverage confirmed: OpenAI/Ollama/error text extraction, paste-ready response, missing heading blocker, placeholder blocker, unsafe Lua blocker, and `BLOCKER` response.

Latest release verification workflow (`d7afc39`):

- `verify:release`: PASS
- Pipeline covers sidecar audit, scenario loader verification, lint, build, AI client parser smoke, and AI adapter smoke.
- Build remained `366.29 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- No product source, dependency, or `package-lock.json` change beyond the package script and README shortcut.

Latest QA workflow release (`e5cd403`):

- Tag: `release-2026-05-06-cmo-lua-builder-qa-workflow`
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-06-cmo-lua-builder-qa-workflow`
- Release title: `CMO Lua Builder QA Workflow Release`
- Kimi QA: APPROVED, no regression
- `verify:release`: PASS; bundle/scenario/security baselines unchanged

Latest AI Lua safety wording release (`a8e9b66`):

- Tag: `release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`
- Release title: `CMO Lua Builder AI Lua Safety Wording Update`
- Kimi QA: APPROVED, no regression
- `verify:release`: PASS
- Build output: `366.47 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Safety wording now frames AI-generated Lua as a gated draft requiring CMO engine verification, while `isPasteReady` apply gating remains unchanged.
- Handoff closeout: `eb93f50 Archive AI Lua safety wording release QA`

Latest transient scenario sidecar UX (`8f9641e`):

- Commit: `8f9641e Clarify transient scenario sidecar UX`
- Kimi QA: APPROVED, no regression
- `verify:release`: PASS
- `smoke:scenario-transient`: PASS, returned an in-memory summary and left `.scenario-extract-cache/` empty
- Build output: `366.60 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Scope was user-facing status wording in `LuaAssistant.jsx`; sidecar loading, transient in-memory summary, `adapter://scenario/transient-open`, and `isPasteReady` gating remained unchanged.
- Handoff closeout: `a0a52f9 Archive transient scenario sidecar UX QA`

Latest transient sidecar UX release (`ffbd86e`):

- Tag: `release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`
- Release title: `CMO Lua Builder Transient Sidecar UX Update`
- Kimi release-tag QA: APPROVED, no regression
- `verify:release`: PASS
- `smoke:scenario-transient`: PASS, in-memory summary returned and `.scenario-extract-cache` remained empty
- Build output: `366.60 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`

Latest full operating recheck (`bb86df5`):

- First sandbox run reached build and stopped on known Vite `spawn EPERM`.
- Approved rerun of `npm run verify:release`: PASS.
- Chain PASS: sidecar audit, scenario loader, lint, build, AI client parser smoke, AI adapter smoke.
- Build output: `366.60 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `24` orphans / about `5.6 MB`.
- AI adapter smoke: PASS, no raw `Bearer` / `sk-` leakage.

Latest sidecar cache settings wording polish (`2ba77a8`):

- Scope: `src/App.jsx` only.
- Kimi QA: APPROVED, no regression.
- UI change: Settings > Storage > Scenario Sidecar Cache now uses compact Korean status/count labels instead of leftover English labels.
- `lint`: PASS.
- `build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- Safety invariants unchanged: sidecar root hint, `CMO_SCENARIO_SIDECAR_ROOT`, `.scen` not modified wording, command rows, prompt-copy fallback, and `isPasteReady` apply gate.

Latest sidecar cache wording release (`f3539f5`):

- Tag: `release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`
- Release title: `CMO Lua Builder Sidecar Cache Wording Update`
- Kimi release-tag QA: APPROVED, no regression
- `verify:release`: PASS
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage

Release closeout reference:

```text
docs/agent-ops/sidecar-cache-wording-release-closeout-2026-05-08.md
```

Use the closeout as the concise operating reference for release verification, watch lines, GitHub Release checks, and next work candidates.

Latest closeout docs QA:

- `9822cd3 Archive sidecar cache wording closeout docs QA`
- Kimi QA: APPROVED / ARCHIVED
- Target closeout commit: `af84723 Document sidecar cache wording release closeout`
- Static checkpoints: 16 / 16 PASS
- Regression: none

Latest post-closeout release verification (`fb33753`):

- Initial sandbox run hit Vite `spawn EPERM`; approved rerun was used.
- `verify:release`: PASS.
- Chain PASS: sidecar audit, scenario loader, lint, build, AI client parser smoke, AI adapter smoke.
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`.
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.

Latest Template Inspector annotation coverage (`05fd836`, QA archived at `350a515`):

- Scope: `public/template-annotations.json` only.
- Kimi QA: APPROVED / ARCHIVED, no regression.
- Added beginner / AI guide annotations for `doctrine_emcon.tpl.lua`, `mission_strike.tpl.lua`, `reference_point_add.tpl.lua`, and `unit_spawn.tpl.lua`.
- JSON coverage: `12 / 51` annotated resources, `39` missing.
- `lint`: PASS.
- `build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- Parser, adapter, and pruning contracts unchanged.

Latest Template Inspector annotation Batch 2 (`246c175`, QA archived at `6d553b7`):

- Scope: `public/template-annotations.json` only.
- Kimi QA: APPROVED / ARCHIVED, no regression.
- Added beginner / AI guide annotations for `event_simple.tpl.lua`, `event_regular_time.tpl.lua`, `event_unit_detected.tpl.lua`, `event_unit_enters_area.tpl.lua`, `loadout_set.tpl.lua`, and `zone_add.tpl.lua`.
- JSON coverage: `18 / 51` annotated resources, `33` missing.
- `lint`: PASS.
- `build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- Parser, adapter, and pruning contracts unchanged.

Latest Template Inspector annotation Batch 3 (`4d7208a`, QA archived under `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-3-qa.md`):

- Scope: `public/template-annotations.json` plus Superpowers planning docs only.
- Kimi QA: APPROVED / ARCHIVED, no regression.
- Added beginner / AI guide annotations for `side_posture.tpl.lua`, `event_contact_emcon.tpl.lua`, `unit_spawn_random.tpl.lua`, `event_teleport.tpl.lua`, `event_dbid_score.tpl.lua`, and `event_cargo_drop.tpl.lua`.
- JSON coverage: `24 / 51` annotated resources, `27` missing.
- `lint`: PASS.
- `build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- Parser, adapter, pruning, scenario-loader, prompt-copy, and Lua apply contracts unchanged.
- Closeout reference: `docs/agent-ops/template-inspector-batch-3-closeout-2026-05-09.md`.

Latest Template Inspector annotation Batch 4 (`ac8949f`, QA archived under `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-4-qa.md`):

- Scope: `public/template-annotations.json` plus Superpowers planning docs only.
- Kimi QA: APPROVED / ARCHIVED, no regression.
- Added beginner / AI guide annotations for `mission_support.tpl.lua`, `mission_cargo.tpl.lua`, `mission_ferry.tpl.lua`, `mission_mine.tpl.lua`, `kvstore_set.tpl.lua`, and `event_kv_flag.tpl.lua`.
- JSON coverage: `30 / 51` annotated resources, `21` missing.
- `lint`: PASS.
- `build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- Parser, adapter, pruning, scenario-loader, prompt-copy, and Lua apply contracts unchanged.
- Closeout reference: `docs/agent-ops/template-inspector-batch-4-closeout-2026-05-09.md`.
- Closeout docs QA: APPROVED / ARCHIVED; target `3f8911b`, 15 / 15 static checkpoints PASS, docs/handoff-only scope confirmed, no regression.

Latest Template Inspector annotation Batch 5 (`a80b9ea`, QA archived under `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-5-qa.md`):

- Scope: `public/template-annotations.json` plus Superpowers planning docs only.
- Kimi QA: APPROVED / ARCHIVED, no regression.
- Added beginner / AI guide annotations for `event_unit_destroyed.tpl.lua`, `event_unit_damaged.tpl.lua`, `event_missions_toggle.tpl.lua`, `event_escalation.tpl.lua`, `weather_random.tpl.lua`, and `event_dynamic_weather.tpl.lua`.
- JSON coverage: `36 / 51` annotated resources, `15` missing.
- `lint`: PASS.
- `build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- Parser, adapter, pruning, scenario-loader, prompt-copy, and Lua apply contracts unchanged.
- Closeout reference: `docs/agent-ops/template-inspector-batch-5-closeout-2026-05-09.md`.
- Closeout docs QA: APPROVED / ARCHIVED; target `11367cd`, 15 / 15 static checkpoints PASS, docs/handoff-only scope confirmed, no regression.

Latest Template Inspector annotations release-tag QA (`f46385b`, QA archived at `d85ea78`):

- Release tag: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- GitHub Release title: `CMO Lua Builder Template Inspector Annotation Update`.
- Kimi QA: APPROVED / ARCHIVED, no regression.
- `npm run verify:release`: PASS.
- Release notes cover `8 / 51` to `18 / 51` annotation coverage, the 10 newly annotated templates, sandbox `spawn EPERM` approved rerun context, bundle baseline, sidecar/loader baseline, and AI adapter smoke auth safety.
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Parser, adapter, pruning, and scenario-loader contracts unchanged.

Template Inspector annotations closeout reference:

```text
docs/agent-ops/template-inspector-annotations-release-closeout-2026-05-09.md
```

Use the closeout as the concise operating reference for annotation coverage, release verification, watch lines, and next work candidates.

Template Inspector annotations closeout docs QA:

- Kimi QA archived at `e6b0c97 Archive template inspector annotations closeout docs QA`.
- Target commit: `3ff471e Document template inspector annotations release closeout`.
- Static checkpoints: 21 / 21 PASS.
- Scope confirmed: docs and handoff only; no product source, package, parser, adapter, pruning, or scenario-loader drift.
- Regression: none.

Latest Template Inspector post-closeout operating recheck:

- `npm run verify:release`: PASS.
- Chain PASS: sidecar audit, scenario loader, lint, build, AI client parser smoke, AI adapter smoke.
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.
- AI adapter smoke: PASS, sanitized HTTP 401 forwarding and no raw `Bearer` / `Authorization` / `sk-` leakage.
- Parser, adapter, pruning, scenario-loader, and Lua apply contracts unchanged.
- Kimi recheck QA archived at `f2d7ceb Archive template inspector post-closeout recheck QA`; 20 / 20 static checkpoints PASS, no regression.

Scenario baseline:

- `1899` total scenarios
- `1857 readyWithInternalSidecar`
- `0 metadataOnlyNeedsDecoder`
- `42 decoderFailed`
- `verify:scenario-loader`: PASS, issues `0`

## Review Triggers

Review only when Codex opens a focused signal in one of these areas:

- AI response parser contract
- context pruning safety or token-bloat contract
- AI adapter backend/provider secret handling
- new non-CMANO decoder failure class
- always-visible Event/Lua Assistant surfaces
- parser status UI
- prompt-copy fallback
- Lua apply controls
- lazy split touching required global UI styles

Do not reopen scenario decoder work for existing `decoderLegacyCmano` entries.

## Core Contracts

AI response/parser:

- Required headings must remain stable.
- Placeholder Lua such as `<UNIT_GUID>` must block paste-ready state.
- `BLOCKER` responses must block paste-ready state.
- Unsafe Lua surfaces such as `os.*`, `io.*`, `require`, `dofile`, `loadfile`, `package.*`, and `debug.*` must block.
- Lua apply must remain parent-owned and gated by `aiParsedResponse.isPasteReady === true`.
- `npm run smoke:ai-client-parser` is the lightweight no-dependency guard for this contract.

AI adapter/provider:

- Adapter binds locally and must not expose raw secrets.
- Logs/responses must scrub `Authorization`, `Bearer`, and `sk-` values.
- Saved provider profiles must not store raw API keys.
- Provider override objects must not carry raw API keys.

Context pruning:

- Safety rules, required response headings, current user instruction, active Lua, DB family/version, and confirmed identifiers are mandatory context.
- DBID/GUID hints must not be stripped.
- Hard blocks must stop before `sendCmoAiPrompt`.
- `aiContextPruning` should remain under the `9 kB` watch line unless Codex explicitly opens expansion work.

Lazy/UI split:

- Preset Guide and Settings styles may stay lazy.
- Always-visible assistant status/readiness/apply/prompt-copy UI must not depend on route-only CSS chunks.
- Future large guide data should prefer `public` JSON or lazy assets over React source inflation.

## Useful Verification Commands

Kimi normally runs broad QA. Claude should only request these when they support a focused review:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
npm run verify:release
npm run verify:scenario-loader
```

If a decoder issue is reopened, require:

- exact scenario path
- failure class
- relevant command output
- whether failure is new non-CMANO behavior or existing legacy CMANO limitation

## Boundaries

- Do not modify `src/**`, `server/**`, `tools/**`, `package.json`, or handoff files unless explicitly assigned.
- Do not mass-decode scenarios.
- Do not write into CMO install or Steam workshop folders.
- Do not log/store API keys.
- Do not turn uncertain CMO API behavior into confirmed claims.
