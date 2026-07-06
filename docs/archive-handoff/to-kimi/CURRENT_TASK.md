# CURRENT TASK - Kimi

Status: QA / regression monitor / commit-hygiene watcher

## Active State

- No active QA directive.
- Stand by for next directive from Codex.
- Treat archived files under `_archive/` as evidence only, not active instructions.
- Do not modify files, create commits, create tags, edit releases, install dependencies, prune sidecars, or move sidecars.

## Latest Operating Recheck - CMO Wiki / Lua Reference Helper

Current public release:

```text
release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper
```

Verification:

```text
npm run verify:release
```

Result:

- Initial sandbox run reproduced Vite build `spawn EPERM`.
- Approved rerun: PASS, 17-step chain.
- Main JS `253.81 kB`, Main CSS `59.45 kB`, `aiContextPruning` `8.56 kB`.
- CmoWikiPanel `7.59 kB JS / 3.61 kB CSS`.
- LuaEditorReferenceHelper `2.12 kB JS / 0.84 kB CSS`.
- LuaAssistant `136.86 kB JS`.
- Scenario loader `1899 / 1857 / 42 / 0`.
- Sidecar audit `3799` protected, `24` orphans / about `5.6 MB`.
- AI adapter smoke: no raw `Bearer` / `Authorization` / `sk-` leakage.

Invariant status:

- CMO Wiki release remains current.
- B2/B3/B4/CMO Wiki smokes remain in `verify:release`.
- No automatic AI send, automatic CMO execution, polling, watcher, live-state claim, browser root, or CMO mutation introduced.
- Next manual gate remains end-to-end advisory workflow smoke.

## Latest Accepted QA - CMO Wiki / Lua Reference Helper Operating Recheck

QA archive:

```text
handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-operating-recheck-qa.md
```

Target:

```text
d686a6a Record CMO wiki reference helper operating recheck
```

Expected scope:

```text
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
handoff/to-kimi/CURRENT_TASK.md
handoff/to-kimi/2026-05-13-cmo-wiki-reference-helper-operating-recheck-qa.md
```

QA focus:

- Post-release operating recheck is recorded in inventory.
- All baselines (bundle, scenario, sidecar, AI adapter) are accurately captured.
- No product source, package, parser, adapter, pruning, or scenario-loader behavior changes.
- Invariants hold: no automatic AI send, no automatic CMO execution, no polling/watcher/live-state/browser root/CMO mutation.
- `aiParsedResponse.isPasteReady` gate unchanged.
- Next manual gate: end-to-end advisory workflow smoke.

Verdict: **APPROVED** — 34 / 34 static checkpoints PASS, `git diff --check` clean, no regression.

## Latest Accepted QA - CMO Wiki / Lua Reference Helper Release Closeout Docs

QA archive:

```text
handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-closeout-docs-qa.md
```

Target:

```text
e3ab8bb Document CMO wiki reference helper release closeout
```

Expected scope:

```text
docs/agent-ops/cmo-wiki-reference-helper-release-closeout-2026-05-13.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
handoff/to-kimi/CURRENT_TASK.md
handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-tag-qa.md
handoff/to-kimi/2026-05-13-cmo-wiki-reference-helper-release-tag-qa.md
```

QA focus:

- Release closeout doc exists and records tag, tagged commit, GitHub Release, release state.
- Release closeout records full implementation chain from design through release tag QA activation.
- Release closeout records Claude architecture review and Gemini UX review.
- Release closeout records Kimi QA evidence (product QA 38/38, marker QA 25/25, tag QA 35/35).
- Release closeout records release notes coverage, bundle baseline, verification chain.
- Release closeout records preserved boundaries and next recommended gate.
- Inventory contains CMO Wiki / Lua Reference Helper release closeout entry.
- Kimi/Claude/Gemini CURRENT_TASK.md reference the release closeout.
- Target commit changes docs/handoff only.
- Release tag QA directive is archived under `_archive/`.

Kimi QA result:

- Verdict: APPROVED - CMO Wiki / Lua Reference Helper release closeout docs hold.
- Static checkpoints: `47 / 47 PASS`.
- Scope: docs/handoff only (7 files).
- No product source, server, tool, public, package, or lockfile drift.
- Regression: none.
- CMO Wiki / Lua Reference Helper is now fully released and closed.

## Latest Accepted QA - CMO Wiki / Lua Reference Helper Release Tag

QA archive:

```text
handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-tag-qa.md
```

Release tag:

```text
release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper
```

Tagged commit:

```text
d09b0d7 Mark CMO wiki reference helper release in README
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper
```

QA focus:

- Tag exists and points to `d09b0d7`.
- GitHub Release title is `CMO Lua Builder CMO Wiki Reference Helper`.
- Release is not draft, not prerelease.
- Release notes cover all highlights, safety boundaries, verification, bundle, and QA evidence.
- `npm run verify:release` PASS with 17-step chain.
- No commits created during QA.

Kimi QA result:

- Verdict: APPROVED - CMO Wiki / Lua Reference Helper release tag holds.
- Static checkpoints: `35 / 35 PASS`.
- Pipeline: `verify:release` 17-step chain PASS.
- Bundle: Main JS `253.81 kB`, Main CSS `59.45 kB`, `aiContextPruning` `8.56 kB`.
- Tag mapping: `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper -> d09b0d7`.
- GitHub Release: title `CMO Lua Builder CMO Wiki Reference Helper`, draft=false, prerelease=false.
- Release notes coverage: all 29 content checkpoints verified.
- Current next gate: CMO Wiki / Lua Reference Helper release closeout docs.

## Latest Accepted QA - CMO Wiki / Lua Reference Helper Release Marker

QA archive:

```text
handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-marker-qa.md
```

Target:

```text
d09b0d7 Mark CMO wiki reference helper release in README
```

Expected scope:

```text
README.md
```

QA focus:

- README public release line references `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`.
- README manual QA pipeline includes `smoke:cmo-wiki-code-assistant`.
- README records Main JS `253.81 kB`, Main CSS `59.45 kB`, and `aiContextPruning` `8.56 kB`.
- README records CmoWikiPanel `7.59 kB JS / 3.61 kB CSS`, LuaEditorReferenceHelper `2.12 kB JS / 0.84 kB CSS`, and LuaAssistant `136.86 kB JS`.
- `npm run verify:release` passes the 17-step chain.
- Target commit remains README-only with no source, server, tool, public, docs, handoff, package, or lockfile drift.
- No release tag / GitHub Release exists yet.

Kimi QA result:

- Verdict: APPROVED.
- Static checkpoints: `25 / 25 PASS`.
- Pipeline: `verify:release` 17-step chain PASS.
- Bundle: Main JS `253.81 kB`, Main CSS `59.45 kB`, `aiContextPruning` `8.56 kB`.
- Tag/GitHub Release: not created yet (confirmed).
- Scope: `README.md` only.
- Current next gate: CMO Wiki / Lua Reference Helper release tag / GitHub Release creation.

## Latest Accepted QA - CMO Wiki / Lua Reference Helper

QA archive:

```text
handoff/to-kimi/_archive/2026-05-13-cmo-wiki-code-assistant-qa.md
```

Closeout doc:

```text
docs/agent-ops/cmo-wiki-code-assistant-closeout-2026-05-13.md
```

Target commits:

```text
4f70332 Add CMO wiki entry helper
30801bc Share CMO wiki utility helpers
32250e5 Add CMO Lua encyclopedia panel
11d6bcf Add Lua editor reference helper
```

Expected scope:

```text
package.json
src/App.jsx
src/components/AiInterpreterChatPanel.jsx
src/components/CmoWikiPanel.css
src/components/CmoWikiPanel.jsx
src/components/LuaAssistant.jsx
src/components/LuaEditorReferenceHelper.css
src/components/LuaEditorReferenceHelper.jsx
src/components/TemplateLibrary.jsx
src/lib/cmoWikiDataClient.js
src/lib/cmoWikiEntries.js
tools/verify-ai-chat-entrypoint-contract.mjs
tools/verify-cmo-wiki-code-assistant-contract.mjs
```

QA focus:

- Wiki entries built deterministically from 51 template annotations.
- Wiki panel has search, quick filters, and text-only AI chat draft button.
- Lua editor reference helper matches known patterns without calling AI directly.
- Both helpers lazy-loaded.
- Drafts route to AI chat as text-only input without auto-submit.
- No backend, CMO file write, polling, watcher, or live read-back introduced.
- B2/B3/B4 smokes remain PASS.

Kimi QA result:

- Verdict: APPROVED - CMO Wiki / Lua Reference Helper holds.
- Static checkpoints: `38 / 38 PASS`.
- Pipeline: `smoke:cmo-wiki-code-assistant` PASS, `smoke:ai-chat-entrypoint` PASS, `verify:release` 17-step chain PASS.
- Bundle: Main JS `253.81 kB`, Main CSS `59.45 kB`, `aiContextPruning` `8.56 kB`, CmoWikiPanel lazy `7.59 kB JS + 3.61 kB CSS`, LuaEditorReferenceHelper lazy `2.12 kB JS + 0.84 kB CSS`.
- Scope: expected 13 files.
- Regression: none.

## Latest Accepted QA - Advisory Workspace Menu

QA archive:

```text
handoff/to-kimi/_archive/2026-05-13-advisory-workspace-menu-qa.md
```

Target:

```text
292bdef Rework advisory workspace menu
```

Expected scope:

```text
src/App.jsx
src/index.css
tools/verify-ai-chat-entrypoint-contract.mjs
```

QA focus:

- Top-level menu simplified from 4 tabs to 3 main areas.
- Leftmost tab is `Lua 편집 에이전트` with 2 sub modes (AI chat / Lua editor).
- New workspaces default to agent + chat mode.
- Legacy tab states migrate correctly (ai-chat→agent, assistant/output→agent editor, guide/builder/reference→encyclopedia).
- Lua editor mode keeps full manual workflow.
- Encyclopedia keeps guide/checklist context.
- Settings remains available.
- No backend, package, or lockfile drift.

Kimi QA result:

- Verdict: APPROVED - Advisory workspace menu hold.
- Static checkpoints: `30 / 30 PASS`.
- Pipeline: `smoke:ai-chat-entrypoint` PASS, `verify:release` 16-step chain PASS.
- Bundle: Main JS `254.00 kB`, Main CSS `59.45 kB`, `aiContextPruning` `8.56 kB`, LuaAssistant lazy `135.22 kB`.
- Scope: expected 3 files only.
- Regression: none.

## Latest Accepted QA - AI Advisory Policy + Lazy Workspace

QA archive:

```text
handoff/to-kimi/_archive/2026-05-13-ai-advisory-policy-lazy-workspace-qa.md
```

Target commits:

```text
bc922a6 Add AI advisory chat policy contract
8d99a71 Wire advisory policy into AI prompt
7ab75f3 Split advisory guidance helper
53ef0f4 Lazy load Lua assistant workspace
```

Expected scope:

```text
package.json
src/App.jsx
src/components/LuaAssistant.jsx
src/lib/aiAdvisoryChatPolicy.js
src/lib/aiAdvisoryGuidance.js
tools/verify-ai-advisory-chat-policy.mjs
tools/verify-ai-chat-entrypoint-contract.mjs
```

QA focus:

- Advisory policy defines CMO mission scripting advisor role.
- Advisory policy says ask one focused follow-up before Lua for broad requests.
- Advisory policy says do not claim live CMO state.
- Advisory policy says CMO engine verification is required.
- Off-topic redirect is gentle and uses CMO/scenario wording.
- LuaAssistant is lazy-loaded, reducing main bundle size.
- App.jsx no longer statically imports LuaAssistant.
- Existing isPasteReady / canApplyAiLua gate is not weakened.
- Existing prompt-copy fallback remains available.
- No new backend, polling, watcher, or live read-back introduced.

Kimi QA result:

- Verdict: APPROVED - AI advisory policy + lazy workspace hold.
- Static checkpoints: `30 / 30 PASS`.
- Pipeline: `smoke:ai-advisory-chat-policy` PASS, `smoke:ai-chat-entrypoint` PASS, `lint` PASS, `build` PASS, `verify:release` 16-step chain PASS.
- Bundle: Main JS `253.55 kB` (down from 398.55 kB), LuaAssistant lazy chunk `135.22 kB`, Main CSS `59.32 kB`, `aiContextPruning` `8.56 kB`.
- Scope: expected 7 files only.
- Regression: none.
- Note: Main JS dropped significantly thanks to LuaAssistant lazy-loading, creating healthy headroom below the 400 kB watch line.

## Latest Accepted QA - AI Chat Entrypoint Attachments

QA archive:

```text
handoff/to-kimi/_archive/2026-05-13-ai-chat-entrypoint-attachments-qa.md
```

Target:

```text
ab8b94a Simplify AI chat entrypoint
```

Expected scope:

```text
package.json
src/App.jsx
src/components/AiInterpreterChatPanel.css
src/components/AiInterpreterChatPanel.jsx
src/components/LuaAssistant.jsx
src/index.css
tools/verify-ai-chat-entrypoint-contract.mjs
```

QA focus:

- AI Chat is the leftmost top-level workspace tab.
- New workspaces default to `activeTab: 'ai-chat'`.
- AI Chat and Event/Lua Assistant share one LuaAssistant instance.
- AI Chat renders a dedicated simple chat pane, hiding expert controls.
- Event/Lua Assistant tab still exposes the full manual editor workflow.
- Simple chat pane includes scenario, Lua/document, and folder scan attachments.
- Attachment files are prompt context only and do not overwrite editors.
- AiInterpreterChatPanel supports simpleMode with reduced UI.
- Idle chat state shows response pending, not Lua missing.
- No backend, polling, watcher, or live read-back introduced.

Kimi QA result:

- Verdict: APPROVED - AI chat entrypoint attachments hold.
- Static checkpoints: `30 / 30 PASS`.
- Pipeline: `smoke:ai-chat-entrypoint` PASS, `smoke:ai-interpreter-ui` PASS, `lint` PASS, `build` PASS, `verify:release` 16-step chain PASS.
- Bundle: Main JS `398.55 kB` (close to 400 kB watch line), Main CSS `59.32 kB`, `aiContextPruning` `8.56 kB`.
- Scope: expected 7 files only.
- Regression: none.
- Note: Main JS is at 398.55 kB, only 1.45 kB below the 400 kB soft line. Future features should be size-conscious.

## Current Manual Gate - B4 End-to-End CMO Workflow Smoke

Runbook:

```text
docs/agent-ops/b4-manual-cmo-workflow-smoke-2026-05-12.md
```

Status:

- READY / USER-RUN.
- No Kimi QA directive is open yet.
- Codex cannot run the in-game CMO steps directly; user evidence is required before a result closeout or QA directive can be opened.

Manual smoke path:

```text
B2 save -> user ScenEdit_RunScript('/AiAssist/<file>.lua') in CMO -> B3 log feedback -> B4 state snapshot import -> text-only AI follow-up draft
```

Expected evidence:

- B2 saved AiAssist file and loader snippet.
- CMO `ScenEdit_RunScript(...)` console output / return value.
- B3 `CMO 로그 확인` result and confirmation that follow-up draft remains text-only.
- B4 `CMO 상태 스냅샷 가져오기` result with imported snapshot / `source.live === false` behavior.
- Any failure output needed to open a focused fix slice.

## Latest Accepted QA - B4 Post-Release Operating Recheck

QA archive:

```text
handoff/to-kimi/_archive/2026-05-12-b4-post-release-operating-recheck-qa.md
```

Target:

```text
eca6c13 Record B4 post-release operating recheck
```

Expected scope:

```text
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
handoff/to-kimi/CURRENT_TASK.md
```

QA focus:

- Inventory contains `B4 Post-Release Operating Recheck - 2026-05-12`.
- Current public release remains `release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- `npm run verify:release` is recorded as PASS after approved rerun from sandbox `spawn EPERM`.
- 16-step verification chain is recorded.
- Bundle baseline remains Main JS `391.65 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scenario and sidecar baselines remain `1899 / 1857 / 42 / 0`, `3799 protected`, `24 orphans / about 5.6 MB`.
- B2/B3/B4 smokes remain part of the release chain.
- Preserved boundaries remain explicit.
- Manual CMO smoke is clearly marked not run by Codex and left as the next user-run gate.

Kimi QA result:

- Verdict: APPROVED - B4 post-release operating recheck holds.
- Static checkpoints: `39 / 39 PASS`.
- Scope: docs/handoff only (4 files).
- No product source, server, tool, public, package, or lockfile drift.
- Regression: none.
- B4 operating baseline is confirmed stable after release closeout.
- Current next gate: user-run end-to-end CMO workflow smoke.

## Latest Accepted QA - B4 State Snapshot Import Release Closeout Docs

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b4-state-snapshot-import-release-closeout-docs-qa.md
```

Target:

```text
43e1923 Document B4 state snapshot import release closeout
```

Expected scope:

```text
docs/agent-ops/b4-state-snapshot-import-release-closeout-2026-05-11.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
handoff/to-kimi/CURRENT_TASK.md
```

QA focus:

- Release closeout doc exists and records tag, tagged commit, GitHub Release, release state.
- Release closeout records full B4 chain from planning through release tag QA archive.
- Release closeout records Kimi QA evidence, Claude review, bundle baseline, verification chain.
- Release closeout records preserved boundaries and next recommended gate.
- Inventory contains B4 release closeout entry.
- Kimi/Claude/Gemini CURRENT_TASK.md reference the B4 release closeout.
- Target commit changes docs/handoff only.

Kimi QA result:

- Verdict: APPROVED - B4 state snapshot import release closeout docs hold.
- Static checkpoints: `54 / 54 PASS`.
- Scope: docs/handoff only (5 files).
- No product source, server, tool, public, package, or lockfile drift.
- Regression: none.
- B4 is now fully released and closed.

## Latest Accepted QA - B4 State Snapshot Import Release Tag

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b4-state-snapshot-import-release-tag-qa.md
```

Release tag:

```text
release-2026-05-11-cmo-lua-builder-state-snapshot-import
```

Tagged commit:

```text
b1fac3d Mark B4 state snapshot import release in README
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-11-cmo-lua-builder-state-snapshot-import
```

QA focus:

- Tag exists and points to `b1fac3d`.
- GitHub Release title is `CMO Lua Builder State Snapshot Import`.
- Release is not draft, not prerelease.
- Release notes cover all 10 safety boundaries.
- Release notes mention all B4 highlights, QA evidence, bundle baseline, and verification chain.
- `npm run verify:release` PASS with 16-step chain.
- No commits created during QA.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `48 / 48 PASS`.
- Pipeline: `npm run verify:release` 16-step chain PASS.
- Bundle: Main JS `391.65 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Tag mapping: `release-2026-05-11-cmo-lua-builder-state-snapshot-import -> b1fac3d`.
- GitHub Release: title `CMO Lua Builder State Snapshot Import`, draft=false, prerelease=false.
- Release notes coverage: highlights, safety boundaries, verification, bundle, QA evidence all present.
- B4 release closeout doc: `docs/agent-ops/b4-state-snapshot-import-release-closeout-2026-05-11.md`.
- Current next gate: B4 post-release operating recheck / end-to-end manual CMO workflow smoke.

## Latest Accepted QA - B4 State Snapshot Import Release Marker

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b4-state-snapshot-import-release-marker-qa.md
```

Target:

```text
b1fac3d Mark B4 state snapshot import release in README
```

Expected scope:

```text
README.md
package.json
```

QA focus:

- README current public release line references `release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- `package.json` `verify:release` includes B4 smokes:
  - `smoke:cmo-state-snapshot`
  - `smoke:cmo-state-snapshot-endpoint`
  - `smoke:ai-adapter-client-state-snapshot`
- README manual QA pipeline and baseline include the same B4 smokes.
- `npm run verify:release` PASS with the expanded 16-step chain.
- No release tag or GitHub Release should exist yet.
- Target commit must not change product source, server, tools, public data, docs, handoff, dependencies, or lockfile.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `48 / 48 PASS`.
- Pipeline: `npm run verify:release` 16-step chain PASS.
- Bundle: Main JS `391.65 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Tag/GitHub Release: not created yet (confirmed at marker QA time).
- Scope: `README.md` + `package.json` only.
- Current next gate: B4 release tag / GitHub Release creation (now complete).

## Latest Accepted QA - B4 User-Triggered State Export Closeout Docs

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b4-user-triggered-state-export-closeout-docs-qa.md
```

Target:

```text
69040d3 Document B4 user-triggered state export closeout
```

Expected scope:

```text
docs/agent-ops/b4-user-triggered-state-export-closeout-2026-05-11.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
handoff/to-kimi/CURRENT_TASK.md
handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-ui-qa.md
```

QA focus:

- Closeout doc records B4 as user-triggered imported snapshots, not live read-back.
- Closeout doc records planning, helper, endpoint, UI, QA archives, Claude review, baselines, and preserved boundaries.
- B4.3 UI QA report is archived and the top-level B4.3 directive is removed.
- No product source, server, tool, public, package, lockfile, or README drift.
- Static checkpoints: `60 / 60 PASS`.
- Verdict: APPROVED.
- Next gate is B4 release marker / README update.

## Latest Accepted QA - B4.3 CMO State Snapshot UI

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-ui-qa.md
```

Target:

```text
5d3b06d Add B4 CMO state snapshot UI
```

Expected scope:

```text
package.json
src/lib/aiAdapterClient.js
src/components/LuaAssistant.jsx
tools/verify-ai-adapter-client-state-snapshot-contract.mjs
```

QA focus:

- `importCmoStateSnapshot()` posts only `text` and `sourceHint` to `/api/cmo/state-snapshot/import`.
- UI label is `CMO 상태 스냅샷 가져오기`.
- UI says imported snapshot / 가져온 스냅샷 and explicitly says it is not a live connection.
- User pastes CMO export text manually and clicks `스냅샷 가져오기`.
- Follow-up remains text-only and user-reviewed via `후속 질문 초안 만들기`.
- Snapshot follow-up must not call AI automatically.
- User-selected snapshot hints can be promoted into Confirmed Context one value at a time.
- No polling, watcher, CMO execution, file write/delete, `.scen` mutation, or browser-provided filesystem root is introduced.
- Pipeline: `npm run smoke:ai-adapter-client-state-snapshot`, `npm run smoke:cmo-state-snapshot-endpoint`, `npm run smoke:cmo-state-snapshot`, `npm run smoke:ai-adapter-client-log-feedback`, `npm run lint`, `npm run build`, `npm run smoke:ai-adapter`, and `npm run verify:release` PASS.
- Static checkpoints: `74 / 74 PASS`.
- Verdict: APPROVED.
- Current next gate: B4 closeout docs QA.

## Latest Accepted QA - B4.2 CMO State Snapshot Endpoint

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-endpoint-qa.md
```

Target:

```text
92a5ca6 Add B4 CMO state snapshot endpoint
```

Expected scope:

```text
package.json
server/ai-provider-adapter.mjs
tools/verify-cmo-state-snapshot-endpoint.mjs
```

QA focus:

- Endpoint is `POST /api/cmo/state-snapshot/import`.
- Endpoint passes only `text` and `sourceHint` to the B4.1 helper.
- Browser-provided `cmoRoot`, `logsRoot`, `scenarioRoot`, `luaRoot`, `filePath`, and `scriptPath` are ignored.
- Response is `deepScrubSecrets`-wrapped and preserves helper redaction.
- Endpoint does not call AI, execute CMO Lua, write files, poll, watch, or claim live read-back.
- Endpoint smoke verifies successful import, empty/oversize error handling, malicious-root rejection by omission, and log redaction.
- Pipeline: `npm run smoke:cmo-state-snapshot-endpoint`, `npm run smoke:cmo-state-snapshot`, `npm run lint`, `npm run build`, `npm run smoke:ai-adapter`, and `npm run verify:release` PASS.
- Static checkpoints: `70 / 70 PASS`.
- Verdict: APPROVED.
- Current next gate: B4.3 UI state snapshot import panel.

## Latest Accepted QA - B4.1 CMO State Snapshot Helper

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-helper-qa.md
```

Target:

```text
876903f Add B4 CMO state snapshot helper
```

Expected scope:

```text
package.json
server/cmo-state-snapshot-importer.mjs
tools/verify-cmo-state-snapshot-contract.mjs
```

QA focus:

- Helper wraps `tools/parse-cmo-event-export.mjs` into a bounded snapshot contract.
- `source.live === false` is hardcoded for B4 snapshots.
- Input bound is `256 KiB`.
- Event and special action lists are capped at `50`.
- Warnings are capped at `20`.
- Lua previews are capped at `600` UTF-16 code units.
- Parser `raw`, full `luaScript`, and full `luaScripts` are stripped from nested output.
- Redaction runs before parse and uses parser-safe replacement tokens.
- No adapter endpoint, UI, polling, watcher, CMO execution, AI auto-send, or browser root usage is introduced.
- Static checkpoints: `80 / 80 PASS`.
- Verdict: APPROVED.
- `verify:release` does not include the B4 smoke yet; extension is expected after B4.2 endpoint.
- Current next gate: B4.2 adapter endpoint.

## Latest Accepted QA - B4 User-Triggered State Export Planning

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b4-user-triggered-state-export-planning-qa.md
```

Target:

```text
2639944 Plan B4 user-triggered state export
```

QA focus / result:

- B4 is framed as user-triggered imported state snapshots, not silent live read-back.
- First implementation path is manual pasted CMO export text from `Tool_DumpEvents()` / `ScenEdit_GetEvent(...)`.
- Existing parser contract is reused through a bounded wrapper plan.
- Browser-provided filesystem roots remain rejected.
- No automatic AI send, automatic CMO execution, polling, watcher, `.scen` mutation, or live daemon claim is introduced.
- This planning gate is docs / handoff only; no `src/**`, `server/**`, `tools/**`, `public/**`, `README.md`, `package.json`, or lockfile drift is expected.
- Static checkpoints: `55 / 55 PASS`.
- Verdict: APPROVED.

Claude design review:

- Review directive archive: `handoff/to-claude/_archive/2026-05-11/2026-05-11-b4-user-triggered-state-export-design-review.md`.
- Review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B4-User-Triggered-State-Export\b4-user-triggered-state-export-review.md`.
- Verdict: APPROVED with refinements.
- B4.1 in-slice refinements: nested raw assertions, redaction-before-parse comment, truncation signals, and UTF-16 char-unit label.
- Current next gate: B4.1 CMO state snapshot helper.

## Latest Accepted QA - B3 Log Feedback Loop Release Closeout Docs

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-closeout-docs-qa.md
```

Target:

```text
a199b43 Document B3 log feedback release closeout
```

Expected scope:

```text
docs/agent-ops/b3-log-feedback-loop-release-closeout-2026-05-11.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
handoff/to-kimi/CURRENT_TASK.md
```

QA focus:

- B3 release closeout doc records tag, GitHub Release, release notes coverage, all B3 slice commits, all QA archives, verification baseline, and preserved boundaries.
- Target is docs/handoff only.
- Next recommended development gate is B4 user-triggered state export / read-back probe.
- Static checkpoints: `45 / 45 PASS`.
- Verdict: APPROVED.

## Latest Accepted QA - B3 Log Feedback Loop Release Tag

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-tag-qa.md
```

Release tag:

```text
release-2026-05-11-cmo-lua-builder-log-feedback-loop
```

Tagged commit:

```text
c50975e Mark B3 log feedback release in README
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-11-cmo-lua-builder-log-feedback-loop
```

Codex verification:

- `git rev-list -n 1 release-2026-05-11-cmo-lua-builder-log-feedback-loop`: `c50975e0276950c5d18a24d45f6e2c353a6ed9ca`.
- GitHub Release title: `CMO Lua Builder Log Feedback Loop`.
- Release state: not draft, not prerelease.
- Release notes mention B3 read-only log feedback, B2 RunScript context, manual `ScenEdit_RunScript`, redacted bounded logs, text-only follow-up draft, no auto AI send, no auto CMO execution, and no live read-back claim.
- `npm run verify:release`: PASS before tag creation with the 13-step expanded chain.
- Kimi QA result: APPROVED, `40 / 40 PASS`.
- Current next gate: B3 release closeout docs.

## Pending Closeout - B3 Log Feedback Loop Release

Release closeout reference:

```text
docs/agent-ops/b3-log-feedback-loop-release-closeout-2026-05-11.md
```

Release:

```text
release-2026-05-11-cmo-lua-builder-log-feedback-loop
```

Status:

```text
APPROVED / RELEASED
```

Scope:

- B3 public release tag and GitHub Release are complete.
- QA evidence covers planning, helper, endpoint, UI, closeout docs, release marker, and release tag.
- Current next recommended development gate after release closeout QA: B4 user-triggered state export / read-back probe.

## Latest Accepted QA - B3 Log Feedback Loop Release Marker

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-marker-qa.md
```

Target:

```text
c50975e Mark B3 log feedback release in README
```

Expected scope:

```text
README.md
package.json
```

QA focus:

- README current release line references `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- `verify:release` includes B3 helper, endpoint, and client log-feedback smokes.
- `npm run verify:release` PASS with expanded chain.
- No tag or GitHub Release exists yet for the B3 release name.
- No product source, server, tool, public data, dependency, or lockfile drift.
- Static checkpoints: `30 / 30 PASS`.
- Verdict: APPROVED.
- Current next gate: B3 release tag / GitHub Release.

## Latest Accepted QA - B3 Log Feedback Loop Closeout Docs

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-closeout-docs-qa.md
```

Target:

```text
dffc296 Document B3 log feedback loop closeout
```

Expected scope:

```text
docs/agent-ops/b3-log-feedback-loop-closeout-2026-05-11.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
handoff/to-kimi/CURRENT_TASK.md
```

QA focus:

- B3 closeout doc exists and records the helper -> endpoint -> UI chain.
- Kimi QA evidence is complete: planning `36 / 36`, helper `47 / 47`, endpoint `45 / 45`, UI `45 / 45`.
- Boundaries remain explicit: no auto AI send, no CMO auto-execution, no polling/watcher/live read-back, no browser root, no log mutation.
- Static checkpoints: `40 / 40 PASS`.
- Verdict: APPROVED.
- Next gate is B3 release marker / README update.

## Latest Accepted QA - B3.3 CMO Log Feedback UI

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-ui-qa.md
```

Target:

```text
3800fdf Add B3 CMO log feedback UI
```

Expected scope:

```text
package.json
src/components/LuaAssistant.jsx
src/lib/aiAdapterClient.js
tools/verify-ai-adapter-client-log-feedback-contract.mjs
```

Codex pre-QA:

- TDD RED: `npm run smoke:ai-adapter-client-log-feedback` failed on missing `fetchCmoLogFeedback` export.
- TDD GREEN: `npm run smoke:ai-adapter-client-log-feedback` PASS after implementation.
- `npm run smoke:cmo-log-feedback-endpoint`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:cmo-log-feedback`: PASS.
- `npm run smoke:ai-adapter-client-sidecar`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS, Main JS `383.67 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- `npm run smoke:ai-adapter`: PASS after approved rerun for Windows sandbox `spawn EPERM`; no raw auth leakage.
- `npm run verify:release`: PASS.

QA focus:

- `fetchCmoLogFeedback()` client helper uses `GET /api/cmo/log-feedback`.
- Browser/UI does not supply a log root.
- `CMO 로그 확인` fetches sanitized log snippets through the adapter only.
- `후속 질문 초안` is text-only and user-reviewed.
- No `sendCmoAiPrompt` auto-send, no CMO auto-execution, no polling, no watcher, no live read-back claim.
- Existing B2 sidecar controls, prompt-copy fallback, and `isPasteReady` gates remain intact.
- Static checkpoints: `45 / 45 PASS`.
- Verdict: APPROVED.
- Current next gate: B3 log feedback closeout docs QA.

## Pending Closeout - B3 Log Feedback Loop

Closeout reference:

```text
docs/agent-ops/b3-log-feedback-loop-closeout-2026-05-11.md
```

Status:

```text
APPROVED / CLOSED
```

Scope:

- B3 planning, helper, endpoint, and UI slices.
- Kimi QA approvals: planning `36 / 36`, helper `47 / 47`, endpoint `45 / 45`, UI `45 / 45`.
- Current release remains B2 until Codex opens the B3 release marker.
- Recommended next gate after closeout QA: B3 release marker / README update.

## Latest Accepted QA - B3.2 CMO Log Feedback Endpoint

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-endpoint-qa.md
```

Target:

```text
7f8943c Add B3 CMO log feedback endpoint
```

Expected scope:

```text
package.json
server/ai-provider-adapter.mjs
tools/verify-cmo-log-feedback-endpoint.mjs
```

Pre-QA pipeline already run by Codex:

- `npm run smoke:cmo-log-feedback-endpoint`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:cmo-log-feedback`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS, Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage.
- `npm run verify:release`: PASS.
- Static checkpoints: `45 / 45 PASS`.
- Verdict: APPROVED.

QA focus:

- Adapter-only B3.2, no UI yet.
- `GET /api/cmo/log-feedback` reads sanitized logs via B3.1 helper.
- Browser-supplied `logsRoot` is ignored.
- Endpoint does not call AI, execute CMO, poll, watch files, or claim live read-back.
- Response/logs remain redacted and bounded.
- Current next gate: B3.3 UI log feedback fetch and text-only follow-up draft.

## Latest Accepted QA - B3.1 CMO Log Feedback Helper

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-helper-qa.md
```

Target:

```text
407e822 Add B3 CMO log feedback helper
```

Expected scope:

```text
package.json
server/cmo-log-feedback-reader.mjs
tools/verify-cmo-log-feedback-contract.mjs
```

Pre-QA pipeline already run by Codex:

- `npm run smoke:cmo-log-feedback`: PASS.
- `npm run smoke:cmo-lua-load-check`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS, Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- `npm run smoke:ai-adapter`: PASS after approved rerun for Windows sandbox `spawn EPERM`; no raw auth leakage.
- `npm run verify:release`: PASS.
- Static checkpoints: `47 / 47 PASS`.
- Verdict: APPROVED.

QA focus:

- Helper-only B3.1, no endpoint or UI yet.
- Server-side logs root only.
- Positioned tail reads, no full-log `readFile`.
- `since` filter implemented.
- Expanded path and secret redaction.
- No file mutation, process execution, polling, watcher, live read-back, automatic CMO execution, or AI auto-send.
- Current next gate: B3.2 adapter endpoint and endpoint smoke.

## Latest Accepted QA - B3 Log Feedback Loop Planning

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b3-log-feedback-loop-planning-qa.md
```

Planning references:

```text
docs/superpowers/specs/2026-05-10-b3-log-feedback-loop-design.md
docs/superpowers/plans/2026-05-10-b3-log-feedback-loop.md
docs/agent-ops/b3-log-feedback-loop-planning-2026-05-10.md
```

Expected scope:

- docs / handoff only.
- No `src/**`, `server/**`, `tools/**`, `public/**`, package, lockfile, dependency, sidecar, CMO, tag, or release change.

QA focus:

- B3 is planning-only and read-only.
- Log feedback supports `ExceptionLog_*.txt` and `LuaHistory_*.txt`.
- Browser cannot provide `logsRoot`.
- Redaction and response bounds are specified.
- Follow-up remains text-only and user-reviewed.
- No automatic AI send, automatic CMO execution, polling, watcher, or live read-back claim is introduced.

Kimi QA result:

- Verdict: APPROVED.
- Static checkpoints: `36 / 36 PASS`.
- Scope: docs / handoff only.
- Regression: none.

Claude design review:

- Archive: `handoff/to-claude/_archive/2026-05-10/2026-05-10-b3-log-feedback-loop-design-review.md`.
- Memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B3-Log-Feedback-Loop\b3-log-feedback-loop-review.md`.
- Verdict: `APPROVED with refinements`.
- B3.1 must use positioned tail reads, implement `since`, expand path redaction, and add source-level no-write/no-exec/no-full-read smoke guards.

## Latest Accepted QA - B2 RunScript Sidecar Writer Release Closeout Docs

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-closeout-docs-qa.md
```

Target:

```text
3766c25 Document B2 RunScript sidecar writer release closeout
```

Expected scope:

- docs / handoff only.
- Release closeout doc.
- Final stabilization inventory.
- Kimi / Claude / Gemini `CURRENT_TASK.md`.
- Release-tag QA archive.
- Removal of the previous top-level release-tag QA directive.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Scope: docs / handoff only.
- Confirmed: release closeout doc records the release tag, tagged commit, GitHub Release metadata, B0.1 prior facts, six B2 slice commits, seven QA archive paths, verification baseline, preserved boundaries, and B3 recommendation.
- Confirmed: release-tag QA directive is archived, handoff inboxes are clean, and Kimi / Claude / Gemini `CURRENT_TASK.md` files are consistent.

## Current B2 Release State

- B2 RunScript Sidecar Writer is fully released and closed.
- Current public release: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Closeout reference: `docs/agent-ops/b2-runscript-sidecar-writer-release-closeout-2026-05-10.md`.
- Approved execution model: user manually runs `ScenEdit_RunScript('/AiAssist/<file>.lua')` in CMO after saving a paste-ready AI Lua draft.
- `dofile(...)` remains disproven for the CMO Build 1868 console sandbox.
- No automatic CMO execution, polling, log tailing, live read-back, or AI auto-send is implemented.
- Recommended next gate: B3 log feedback loop planning.

## Latest Accepted QA - B2 RunScript Sidecar Writer Release Tag

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-tag-qa.md
```

Release tag:

```text
release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer
```

Tagged commit:

```text
8c7a18e Mark B2 RunScript sidecar writer release in README
```

Expected release metadata:

- GitHub Release URL: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Release title: `CMO Lua Builder RunScript Sidecar Writer`.
- Draft: `false`.
- Prerelease: `false`.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `32 / 32 PASS`.
- Tag mapping: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer -> 8c7a18e`.
- GitHub Release title: `CMO Lua Builder RunScript Sidecar Writer`.
- Release state: not draft, not prerelease.
- `npm run verify:release`: PASS.
- Bundle: Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Confirmed release notes cover B2 safety boundaries, RunScript manual execution, smoke baselines, scenario/sidecar baseline, and no raw auth leakage.

## Latest Closeout Draft - B2 RunScript Sidecar Writer Release

Closeout reference:

```text
docs/agent-ops/b2-runscript-sidecar-writer-release-closeout-2026-05-10.md
```

Status:

- B2 release tag and GitHub Release are approved.
- Release closeout doc records the tag, GitHub Release, QA archive, verification baseline, preserved boundaries, and next recommended B3 planning gate.
- B2 is now the public release baseline for user-triggered AI Lua draft save to the CMO Lua root plus manual `ScenEdit_RunScript('/AiAssist/<file>.lua')`.

## Latest Accepted QA - B2 RunScript Sidecar Writer Release Marker

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-marker-qa.md
```

Target:

```text
8c7a18e Mark B2 RunScript sidecar writer release in README
```

Expected target scope:

- `README.md`
- `package.json`

Codex pre-QA evidence:

- `npm run smoke:ai-adapter-client-sidecar`: PASS.
- `npm run verify:release`: PASS after approved sandbox-spawn rerun.
- Build baseline: Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scenario baseline: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected files, `24` orphans / `5.6 MB`, dry-run only.
- AI adapter smoke: PASS, no raw auth leakage.

QA focus:

- README current release line references `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- README manual QA pipeline includes `npm run smoke:ai-adapter-client-sidecar`.
- `package.json` `verify:release` includes the new sidecar client smoke before parser/adapter smoke.
- Target remains README/package only; no source/server/tool/public/doc/handoff release-tag side effects.
- No tag or GitHub Release is created in this target commit; that is a later gate after marker QA / push approval.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `22 / 22 PASS`.
- Pipeline: `npm run smoke:ai-adapter-client-sidecar` PASS and extended `npm run verify:release` PASS.
- Bundle: Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scope: `README.md` + `package.json` only.
- Confirmed: release marker updated, `verify:release` includes sidecar client smoke, and no tag/GitHub Release was created in the marker commit.

## Latest Closeout Draft - B2 RunScript Sidecar Writer

Closeout reference:

```text
docs/agent-ops/b2-runscript-sidecar-writer-closeout-2026-05-10.md
```

Closeout target:

```text
fc7a291 Document B2 RunScript sidecar writer closeout
```

Closeout-docs QA:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-closeout-docs-qa.md
```

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `35 / 35 PASS`.
- Scope: docs / handoff only.
- Confirmed: B0.1 prior facts, four B2 slice commits, four QA archives, Claude review result, operating path, UI labels, preserved boundaries, bundle/scenario baselines, and next-gate recommendation are all recorded.

Included approved slices:

- Planning: `3931a95 Plan B2 RunScript sidecar writer`.
- B2.1 writer helper: `b1fce05 Add B2 RunScript sidecar writer helper`.
- B2.2 adapter endpoint: `203b9d7 Add B2 RunScript sidecar endpoint`.
- B2.3 UI controls: `2df8e57 Add B2 sidecar save controls`.

Approved B2 operating path:

- AI paste-ready draft only.
- `CMO 파일 준비` dry-run preview first.
- `CMO Lua 폴더 저장` confirmed write second.
- User manually runs `ScenEdit_RunScript('/AiAssist/<file>.lua')` in CMO.
- User performs CMO engine verification.

Protected boundaries:

- No scenario-folder auto-load claim.
- No automatic CMO execution.
- No CMO polling, log tailing, live read-back, or AI auto-send.
- No browser-provided filesystem root.
- No dependency or lockfile drift.
- No `src/index.css` growth.

Current B2 baseline:

- Main JS: `380.45 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.

## Latest Accepted QA - B2 RunScript Sidecar UI Save Controls

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-ui-save-controls-qa.md
```

Target:

```text
2df8e57 Add B2 sidecar save controls
```

Expected target scope:

- `package.json`
- `tools/verify-ai-adapter-client-sidecar-contract.mjs`
- `src/lib/aiAdapterClient.js`
- `src/components/LuaAssistant.jsx`

Codex pre-QA evidence:

- TDD RED: `npm run smoke:ai-adapter-client-sidecar` failed because `saveCmoLuaSidecar` was not exported.
- TDD GREEN: `npm run smoke:ai-adapter-client-sidecar` PASS.
- `npm run smoke:cmo-lua-sidecar-endpoint`: PASS after approved sandbox-spawn rerun.
- `npm run smoke:cmo-lua-sidecar-writer`: PASS.
- `npm run smoke:cmo-lua-load-check`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved sandbox-spawn rerun.
- `npm run smoke:ai-adapter`: PASS after approved sandbox-spawn rerun, no raw auth leakage.
- `npm run verify:release`: PASS.

Observed build baseline:

- Main JS: `380.45 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.

QA focus:

- `saveCmoLuaSidecar` client helper posts to `/api/cmo/lua-sidecar`.
- UI exposes `CMO 파일 준비` dry-run and `CMO Lua 폴더 저장` confirmed-write controls.
- UI displays returned `ScenEdit_RunScript('/AiAssist/<file>.lua')` loader snippet.
- Browser does not supply `cmoLuaRoot`; server-side B2.2 root boundary remains authoritative.
- Controls are gated by `canApplyAiLua`, which remains derived from `aiParsedResponse.isPasteReady`.
- Wording must not imply automatic CMO execution, scenario-folder auto-load, or engine-verified Lua.
- No polling, log tailing, live read-back, AI auto-send, dependency, lockfile, or CSS expansion is expected.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `35 / 35 PASS`.
- Pipeline: client smoke, endpoint/helper/B0.1 smokes, lint, build, adapter smoke, and `verify:release` PASS.
- Bundle: Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scope: expected four files only.
- Security: `canApplyAiLua` / `isPasteReady` gate maintained, `cmoLuaRoot` not sent from browser, prompt-copy fallback preserved, and existing CSS classes reused.

## Latest Accepted QA - B2 RunScript Sidecar Endpoint

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-endpoint-qa.md
```

Target:

```text
203b9d7 Add B2 RunScript sidecar endpoint
```

Expected target scope:

- `package.json`
- `server/ai-provider-adapter.mjs`
- `tools/verify-cmo-lua-sidecar-endpoint.mjs`

Codex pre-QA evidence:

- TDD RED: endpoint smoke initially hit sandbox `spawn EPERM`; approved rerun failed with `404 != 200` because `/api/cmo/lua-sidecar` was not routed yet.
- TDD GREEN: `npm run smoke:cmo-lua-sidecar-endpoint` PASS.
- `npm run smoke:cmo-lua-sidecar-writer`: PASS.
- `npm run smoke:cmo-lua-load-check`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:ai-adapter`: PASS after approved rerun, no raw auth leakage.
- `npm run verify:release`: PASS.

QA focus:

- Endpoint route exists: `POST /api/cmo/lua-sidecar`.
- Endpoint ignores request-body `cmoLuaRoot`; root comes from server environment/default helper only.
- Endpoint supports dry-run and confirmed write through the B2.1 writer helper.
- Endpoint returns no Lua body.
- Endpoint preserves `isPasteReady`, `dryRun`, and `confirmWrite` gates.
- Endpoint does not add UI controls, polling, log tailing, live read-back, automatic CMO execution, or AI auto-send.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Pipeline: `smoke:cmo-lua-sidecar-endpoint`, B2.1/B0.1 smokes, and `verify:release` PASS.
- Bundle: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scope: endpoint-only; no UI or public data drift.
- Security: request-body `cmoLuaRoot` ignored, no Lua body in response, `deepScrubSecrets` applied, and no auth leakage in logs/responses.

Current next step:

- Superseded by accepted B2.3 UI save-controls QA above.

## Latest Accepted QA - B2 RunScript Sidecar Writer Helper

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-helper-qa.md
```

Target:

```text
b1fce05 Add B2 RunScript sidecar writer helper
```

Expected target scope:

- `package.json`
- `server/cmo-lua-sidecar-writer.mjs`
- `tools/verify-cmo-lua-sidecar-writer-contract.mjs`

Codex pre-QA evidence:

- TDD RED: `npm run smoke:cmo-lua-sidecar-writer` failed with `ERR_MODULE_NOT_FOUND` for missing `server/cmo-lua-sidecar-writer.mjs`.
- TDD GREEN: `npm run smoke:cmo-lua-sidecar-writer` PASS.
- `npm run smoke:cmo-lua-load-check`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:ai-adapter`: PASS after approved rerun, no raw auth leakage.
- `npm run verify:release`: PASS.

QA focus:

- Pure helper only; no adapter endpoint and no UI controls.
- Default dry-run writes no file.
- Actual write requires `isPasteReady: true`, `dryRun: false`, and `confirmWrite: true`.
- Writes stay under `<CMO Lua root>\AiAssist\`.
- Responses include server-confirmed dry-run/write flags and do not include the Lua body.
- Unsafe Lua surfaces remain blocked, including nested `ScenEdit_RunScript`.
- Existing files are not overwritten.
- `ScenEdit_RunScript('/AiAssist/<file>.lua')` remains the loader model; `dofile(...)` remains disproven.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Pipeline: `smoke:cmo-lua-sidecar-writer`, `smoke:cmo-lua-load-check`, and `verify:release` PASS.
- Bundle: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scope: helper-only; no adapter route, UI, or public data drift.
- Security: unsafe Lua surfaces blocked, `open('wx')` prevents overwrite, dry-run default, and response/report does not include Lua body.

Current next step:

- Stand by until Codex opens B2.2 adapter endpoint implementation QA.

## Latest Accepted QA - B2 RunScript Sidecar Writer Planning

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-plan-qa.md
```

Scope:

- Docs / handoff only.
- Verified B2 design, implementation plan, agent-ops planning doc, Claude review directive, and agent CURRENT_TASK consistency.
- Confirmed no `src/**`, `server/**`, `tools/**`, `public/**`, package, endpoint, UI, or runtime behavior change was included in the planning gate.

B2 locked direction:

- CMO `Lua` root plus fixed `AiAssist` namespace.
- Explicit `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
- Browser/client cannot provide arbitrary filesystem roots.
- Actual write requires `isPasteReady: true`, `dryRun: false`, and `confirmWrite: true`.
- Scenario-folder auto-load remains unproven.
- `dofile(...)` remains disproven for CMO Build 1868 console sandbox.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Scope: docs / handoff only.
- Drift: no source, server, tools, public, package, or lockfile drift.

Claude review result:

- Review archive: `handoff/to-claude/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-design-review.md`.
- Review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B2-RunScript-Sidecar-Writer\b2-runscript-sidecar-writer-review.md`.
- Verdict: APPROVED with minor refinements; Codex may proceed to B2.1 writer-helper implementation.

Current next step:

- Stand by until Codex opens B2.1 writer-helper implementation QA.

## Latest Accepted QA - B0.1 RunScript Loader Correction

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b0-1-runscript-loader-correction-qa.md
```

Scope:

- Tools / docs / handoff only.
- Verifies `tools/prepare-cmo-lua-load-check.mjs` now uses CMO Lua root plus `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')`.
- Verifies `--scenario-folder` is rejected for B0.1 writes.
- Records the user-run CMO result: `dofile(...)` is unavailable in the CMO Build 1868 console sandbox.
- Records the user-run CMO result: `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` printed `AiAssist_B0RunScript_20260510_0448` and returned `Yes`.
- Confirms scenario-folder `.lua` auto-load remains unproven.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Source / package / public drift: none.
- Backend endpoint / polling / log tailing / sidecar writer / read-back: none.

Pipeline:

```powershell
git status --short --branch
npm run smoke:cmo-lua-load-check
npm run smoke:cmo-integration-probe
npm run lint
npm run build
npm run smoke:ai-adapter
```

Observed bundle:

- Main JS: `377.99 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.

Current next step:

- Stand by until Codex opens B2 planning around the proven CMO Lua-root `ScenEdit_RunScript(...)` execution path.

## Latest Accepted QA - CMO Build 1868 / DB517 Closeout Docs

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-closeout-docs-qa.md
```

Scope:

- Docs / handoff only.
- Verifies DB517 closeout doc, release-notes draft, final stabilization inventory entry, and Kimi / Claude / Gemini CURRENT_TASK consistency.
- Confirms the release-notes draft remains a draft only and does not claim a tag exists.
- Confirms the next Track B gate originally returned to B0.1 disposable CMO scenario manual load check.
- Confirms no `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json` drift.

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Product pipeline re-run was not required because this was docs / handoff only.
- `git diff --check`: docs / handoff only, no source drift.

Closeout outputs:

- Closeout doc: `docs/agent-ops/cmo-build-1868-db517-refresh-closeout-2026-05-10.md`.
- Release-notes draft: `docs/agent-ops/cmo-build-1868-db517-refresh-release-notes-2026-05-10.md`.
- Target product commit: `f7a696a Refresh CMO DB517 references`.
- DB baseline: `DB3K_517.db3`, `CWDB_517.db3`, component entries `101078`.
- Bundle baseline: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Template Inspector coverage remained `51 / 51`, `0 missing`.

Current next step:

- B0.1 manual follow-up is now complete: `dofile(...)` failed, while CMO Lua-root `ScenEdit_RunScript(...)` succeeded.
- Stand by until Codex opens a focused B0.1 result QA / B2 planning directive.

## Latest Accepted QA - CMO Build 1868 / DB517 Refresh

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-refresh-qa.md
```

Target:

```text
CMO Build 1868 / DB517 local reference refresh
```

Scope:

- Verify that Codex reflected the urgent CMO Build 1868 public beta DB update locally.
- Official source: `https://forums.matrixgames.com/viewtopic.php?t=417070`.
- Expected local DB files: `DB3K_517.db3`, `CWDB_517.db3`.
- Expected UI DB summary: `DB3K_517.db3`, `CWDB_517.db3`, component entries `101078`.
- Expected component index split: `DB3K 72796`, `CWDB 28282`.
- Expected scanner result: `CMO v1.09 Build 1868 (Public Beta)`.

Required pipeline:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-adapter
```

Kimi result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `32 / 32 PASS`.
- Bundle: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Template Inspector coverage remained `51 / 51`, `0 missing`.
- Generated local DB artifact confirmed `DB3K_517.db3` / `CWDB_517.db3` and delta `+2 / ~0 / -0`.

Regression watch:

- Do not allow current DB summaries to remain on v516.
- Template Inspector annotations must remain `51 / 51`, `0 missing`.
- Quick Battle Korean comments must remain valid UTF-8.
- No `src/**`, `server/**`, backend endpoint, CMO polling, log tailing, sidecar writer, live read-back, dependency, or lockfile drift.
- Manual prompt-copy fallback and `aiParsedResponse.isPasteReady` Lua apply gate remain unchanged.
- Main JS < 400 kB, Main CSS < 60 kB, `aiContextPruning` < 9 kB.

## Latest Accepted QA - Track B0.1 CMO Lua Load Check

Target files:

```text
package.json
tools/prepare-cmo-lua-load-check.mjs
tools/verify-cmo-lua-load-check-contract.mjs
docs/agent-ops/cmo-lua-load-check-b0-1-2026-05-10.md
docs/superpowers/plans/2026-05-10-cmo-lua-load-check.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
```

Closeout reference:

```text
docs/agent-ops/cmo-lua-load-check-b0-1-closeout-2026-05-10.md
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b0-1-cmo-lua-load-check-qa.md
```

Scope:

- B0.1 prepares a disposable-scenario `.lua` load check.
- Adds `npm run probe:cmo-lua-load-check`.
- Adds `npm run smoke:cmo-lua-load-check`.
- Default mode is dry-run and writes no files.
- Revised write mode requires `--cmo-lua-root`, `--write`, and `--yes`.
- Does not add backend endpoints, CMO polling, log tailing, AI auto-send, live read-back, or automatic execution.

Codex pre-QA evidence:

- TDD RED: `npm run smoke:cmo-lua-load-check` failed with missing `tools/prepare-cmo-lua-load-check.mjs`.
- TDD GREEN: `npm run smoke:cmo-lua-load-check` PASS.
- Dry-run: `npm run probe:cmo-lua-load-check -- --json` PASS.
- Dry-run result: `mode: dry-run`, `wroteFile: false`, `fileName: AiAssist_B0LoadCheck.lua`.
- Original loader snippet shape was `dofile([[<scenario-folder>\AiAssist_B0LoadCheck.lua]])`; user manual check disproved this path.
- Revised loader snippet shape is `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')`.
- Generated Lua prints a marker only and does not mutate scenario state.
- `.lua` scenario-folder auto-load remains unproven.
- CMO Build 1868 console reports `dofile(...)` as nil.
- CMO Build 1868 successfully ran `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')`, printed `AiAssist_B0RunScript_20260510_0448`, and returned `Yes`.
- `npm run lint`: PASS.
- `npm run build`: PASS, Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage.

Kimi result:

- Target commit: `67043ca Add B0.1 CMO Lua load check`.
- Verdict: APPROVED, no regression.
- Static checkpoints: `40 / 40 PASS`.

Current next step:

- Stand by until Codex opens a focused QA directive for the B0.1 manual result and revised `ScenEdit_RunScript(...)` loader contract, or proceeds to B2 planning.

## Latest Accepted QA - Track B0 CMO Integration Probe

Target files:

```text
tools/probe-cmo-integration.mjs
tools/verify-cmo-integration-probe-contract.mjs
docs/agent-ops/cmo-integration-probe-b0-2026-05-09.md
docs/superpowers/plans/2026-05-09-cmo-integration-probe.md
package.json
```

Closeout reference:

```text
docs/agent-ops/cmo-integration-probe-b0-closeout-2026-05-10.md
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-b0-cmo-integration-probe-qa.md
```

Scope:

- Track B0 dry-run local CMO environment probe.
- Adds `npm run probe:cmo-integration`.
- Adds `npm run smoke:cmo-integration-probe`.
- Does not add backend endpoints, scenario writes, `.scen` mutation, log tailing, live read-back, CMO polling, AI auto-send, or sidecar Lua deployment.

Codex pre-QA evidence:

- TDD RED: `npm run smoke:cmo-integration-probe` failed with missing `tools/probe-cmo-integration.mjs`.
- TDD GREEN: `npm run smoke:cmo-integration-probe` PASS.
- Local dry-run probe: `npm run probe:cmo-integration -- --json` PASS.
- Local capability summary: `6 pass / 1 warn / 0 fail / 1 manual / 0 unknown`.
- CMO root, Scenarios root, Logs root, scenario write-access check, ExceptionLog pattern, and safe path prefixes passed.
- `LuaHistory_*.txt` was WARN because no matching files were observed yet.
- Scenario-folder `.lua` auto-load remains MANUAL and must not be treated as proven.
- Follow-up manual check disproved `dofile(...)` and proved explicit CMO Lua-root `ScenEdit_RunScript(...)`.
- `npm run lint`: PASS.
- `npm run build`: PASS, Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage.

Kimi result:

- Target commit: `c950ecd Add B0 CMO integration probe`.
- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.

Current next step:

- Stand by until Codex opens B2 planning around explicit `ScenEdit_RunScript(...)` or another focused QA directive.

## Latest Accepted QA - Track A Completion Checklist

Target document:

```text
docs/agent-ops/track-a-local-ai-interpreter-completion-checklist-2026-05-09.md
```

Closeout reference:

```text
docs/agent-ops/track-a-local-ai-interpreter-completion-closeout-2026-05-09.md
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-track-a-completion-checklist-qa.md
```

Scope:

- Docs / handoff only.
- Verifies that A1 Template Inspector, A2 AI Drafting Workflow, and A3 Local Confirmed Context Workspace are enough to close Track A as a local AI interpreter UI baseline.
- Does not claim CMO Lua execution, live CMO read-back, CMO scenario folder writes, log tailing, or sidecar Lua deployment.
- Recommends B0 CMO Integration Probe as the next Track B step.

Kimi result:

- Target commit: `0266f33 Document Track A local interpreter completion`.
- Verdict: APPROVED, no regression.
- Static checkpoints: `25 / 25 PASS`.
- `npm run verify:release`: PASS.
- Expanded 9-step chain passed.
- Build: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scenario baseline: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected / `24` orphans / `5.6 MB`.
- AI adapter smoke: no raw auth leakage.

Current next step:

- Stand by until Codex opens Track B0 CMO Integration Probe or another focused QA directive.

## Latest Accepted QA - Local Confirmed Context Release Tag

Target release:

```text
release-2026-05-09-cmo-lua-builder-local-confirmed-context
```

Tagged commit:

```text
85ccada Mark local confirmed context release in README
```

Scope:

- Release marker and verification baseline refresh.
- README now points to the local confirmed context public release.
- `package.json` `verify:release` now includes `smoke:ai-workflow-state`, `smoke:ai-follow-up-needs`, and `smoke:ai-confirmed-context`.
- No product source, server, public data, dependency, or lockfile change expected.

Required verification:

- Tag points to `85ccada`.
- GitHub Release title, URL, not-draft, not-prerelease, and notes verified.
- `npm run verify:release`: PASS.
- Bundle watch lines passed: Main JS `< 400 kB`, Main CSS `< 60 kB`, `aiContextPruning < 9 kB`.
- AI adapter smoke has no raw Bearer / Authorization / sk-key leakage.

Kimi QA result:

- APPROVED / ARCHIVED.
- Static checkpoints: `28 / 28` PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-release-tag-qa.md`.
- Closeout reference: `docs/agent-ops/local-confirmed-context-release-closeout-2026-05-09.md`.
- `npm run verify:release`: PASS with expanded 9-step chain.
- Build: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Sidecar audit: `1899` scenarios in index, `3799` protected files, `24` orphans / `5.6 MB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- AI adapter smoke: no raw auth leakage.

## Latest Accepted QA - Local Confirmed Context Workspace

Target product commits:

```text
953317a Add confirmed context helper contract
864e36b Wire confirmed context into assistant state
72cca75 Add confirmed context workspace UI
3772866 Use confirmed context in follow-up drafts
```

Scope:

- Track A3 local AI editor feature.
- Adds source-labeled confirmed CMO values to the local Context tab.
- Reuses confirmed values in prompt construction and text-only follow-up drafts.
- Uses existing temp session/autosave persistence only.
- Track B remains deferred: no backend endpoint, no CMO filesystem write/read, no log tailing, no live read-back.

Required pipeline:

- `git status --short --branch`: clean.
- `npm run smoke:ai-confirmed-context`: PASS.
- `npm run smoke:ai-follow-up-needs`: PASS.
- `npm run smoke:ai-workflow-state`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, no auth leakage.

Kimi QA result:

- APPROVED / ARCHIVED.
- Static checkpoints: `29 / 29` PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-workspace-qa.md`.
- Closeout reference: `docs/agent-ops/local-confirmed-context-workspace-closeout-2026-05-09.md`.
- Observed bundle: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- CSS watch-line: Main CSS remains below `60 kB` with `0.86 kB` headroom.

## Latest Accepted QA - AI Drafting Workflow A2 Completion Checklist

Target commit:

```text
b7dd3b6 Document AI drafting workflow A2 completion
```

Scope:

- Docs / handoff only.
- Verifies the A2 completion checklist, final stabilization inventory entry, and Kimi / Claude / Gemini CURRENT_TASK consistency.
- No product code, server, tool, public data, package, lockfile, or release-tag change expected.

QA focus:

- Confirm A2-1 and A2-2 commits / QA archives are recorded correctly.
- Confirm checklist marks A2 complete but does not mark Track A fully complete.
- Confirm A3 Local Confirmed Context Workspace is recommended before Track B.
- Confirm `npm run verify:release` evidence and bundle/watch-line baselines are recorded.
- Confirm target commit changes docs / handoff only.

Kimi QA result:

- APPROVED / ARCHIVED.
- Pipeline: `git status`, `git show --stat`, `git show --name-only`, and `git diff --check` all PASS.
- Static checkpoints: `28 / 28` PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-drafting-workflow-a2-completion-qa.md`.
- Target commit is docs / handoff only; no product code, server, tool, public data, package, or lockfile drift.

## Latest A2 Completion Checklist

Target document:

```text
docs/agent-ops/ai-drafting-workflow-a2-completion-checklist-2026-05-09.md
```

Scope:

- Docs / handoff only.
- Records A2-1 workflow-state and A2-2 follow-up-needs as a complete local AI drafting workflow baseline.
- Does not mark Track A fully complete.
- Recommends A3 Local Confirmed Context Workspace before Track B.

Status:

- Created by Codex.
- Codex ran `npm run verify:release`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- Verification preserved sidecar audit `1899` index / `3799` protected / `24` orphans, loader `1857 ready / 42 decoderFailed / 0 issues`, build `371.44 kB JS / 59.14 kB CSS / 8.56 kB aiContextPruning`, and AI adapter no-auth-leak smoke.
- Next useful task: focused docs/handoff-only QA when Codex opens a directive.

## Latest Accepted QA - AI Follow-Up Needs Closeout Docs

Target commit:

```text
29318d4 Document AI follow-up needs closeout
```

Scope:

- Docs / handoff only.
- Verifies A2-2 closeout doc, final stabilization inventory entry, and Kimi / Claude / Gemini CURRENT_TASK consistency.
- No product code, server, tool, public data, package, lockfile, or release-tag change expected.

QA focus:

- Confirm the closeout doc records A2-2 design, plan, contract/helper, product, QA directive, and QA archive commits.
- Confirm the closeout doc records Kimi QA approval, `34 / 34` checkpoints, bundle baseline, `CMO에서 확인할 값`, and Track B deferral.
- Confirm inventory and agent handoff files reference the A2-2 closeout consistently.
- Confirm target commit changes docs / handoff only.

Kimi QA result:

- APPROVED / ARCHIVED.
- Pipeline: `git status`, `git show --stat`, `git show --name-only`, and `git diff --check` all PASS.
- Static checkpoints: `28 / 28` PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-closeout-docs-qa.md`.
- Target commit is docs / handoff only; no product code, server, tool, public data, package, or lockfile drift.

## Latest Accepted QA - AI Follow-Up Needs Review

Target commits:

```text
64683a0 Add AI follow-up needs contract
b32c780 Add AI follow-up needs review
```

Scope:

- Track A2-2 local AI interpreter/editor UI improvement.
- Adds `src/lib/aiFollowUpNeeds.js` and `npm run smoke:ai-follow-up-needs`.
- Adds grouped `CMO에서 확인할 값` review-panel guidance for blocked / ask-back responses.
- Strengthens the `재질문 초안 만들기` draft with grouped confirmation needs and no-invention wording.
- Does not open Track B behavior: no CMO filesystem write, sidecar writer, log tailing, live read-back, or backend endpoint.

Codex pre-QA:

- `npm run smoke:ai-follow-up-needs`: PASS.
- `npm run smoke:ai-workflow-state`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:ai-adapter`: PASS after approved rerun for Windows sandbox `spawn EPERM`; no raw Bearer / Authorization / sk-key leakage.
- Build observed: Main JS `371.44 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`, AiResponseReviewPanel `10.08 kB JS / 5.23 kB CSS`.

QA focus:

- Verify the new follow-up needs helper categories, severity set, empty state, prompt formatting, duplicate handling, and mutation safety.
- Verify the Review panel renders grouped needs, limits visible categories to 6, keeps evidence behind `<details>`, and drafts text only.
- Verify Lua apply remains parent-gated by `canApplyLua` / `isPasteReady`.
- Verify parser, pruning, adapter, sidecar, backend, package-lock, and storage boundaries remain unchanged.
- Watch Main CSS carefully: it remains below but close to the `60 kB` soft line.

Kimi QA result:

- APPROVED / ARCHIVED.
- Pipeline: `git status`, `smoke:ai-follow-up-needs`, `smoke:ai-workflow-state`, `lint`, `build`, `smoke:ai-client-parser`, `smoke:ai-adapter` all PASS.
- Sandbox escalation: not needed.
- Static checkpoints: `34 / 34` PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-qa.md`.
- Bundle baseline: Main JS `371.44 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`, AiResponseReviewPanel `10.08 kB JS / 5.23 kB CSS`.
- Main CSS remains below but close to the `60 kB` soft line with about `0.86 kB` headroom.

A2-2 closeout reference:

```text
docs/agent-ops/ai-follow-up-needs-review-closeout-2026-05-09.md
```

Closeout status:

- Closeout docs created by Codex.
- Scope: docs / handoff only after product QA approval.
- Next useful task: focused docs/handoff-only QA when Codex opens a directive.

## Latest Accepted QA - AI Drafting Workflow State

Target commit:

```text
eb689df Align AI drafting workflow state
```

Scope:

- Track A2-1 local UI workflow-state alignment.
- Adds `src/lib/aiWorkflowState.js`.
- Adds `npm run smoke:ai-workflow-state`.
- Wires main Output, AI Response Review, and AI Interpreter Chat surfaces to a shared `workflowState`.

Codex pre-QA:

- `npm run smoke:ai-workflow-state`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after sandbox `spawn EPERM` escalation.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw Bearer / Authorization / sk-key leakage.
- Bundle observed: Main JS `371.44 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`.

Kimi QA result:

- APPROVED / ARCHIVED.
- Pipeline: `git status`, `smoke:ai-workflow-state`, `lint`, `build`, `smoke:ai-client-parser`, `smoke:ai-adapter` all PASS.
- Static checkpoints: 38 / 38 PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-drafting-workflow-state-qa.md`.
- Bundle baseline: Main JS `371.44 kB`, Main CSS `59.14 kB`, aiContextPruning `8.56 kB`.
- Main CSS remains below but close to the `60 kB` soft line with about `0.86 kB` headroom.

## Latest Accepted QA - Template Inspector Search / Filter Release Closeout Docs

Target commit:

```text
2003b56 Document template inspector search filter release closeout
```

Scope:

- Docs / handoff only.
- No product code, server, tool, public data, package, lockfile, or release-tag change.

QA focus:

- Verify release closeout doc content for release tag `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Verify inventory and Kimi / Claude / Gemini CURRENT_TASK consistency.
- Verify handoff inbox shape.
- Kimi QA: APPROVED / ARCHIVED.
- Static checkpoints: 29 / 29 PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-search-filter-release-closeout-docs-qa.md`.

## Latest Release Closeout - Template Inspector Search / Filter

Current public release:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-search-filter
```

Release closeout reference:

```text
docs/agent-ops/template-inspector-search-filter-release-closeout-2026-05-09.md
```

Release closeout status:

- Closeout docs created by Codex.
- Scope: docs / handoff only after release-tag QA approval.
- Kimi closeout-docs QA: APPROVED / ARCHIVED.
- This release is closed and current.

## Latest Accepted QA - Template Inspector Search / Filter Release Tag

Release tag:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-search-filter
```

Tagged commit:

```text
004325d Mark template inspector search filter release in README
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-search-filter
```

Release title:

```text
CMO Lua Builder Template Inspector Search Filter UX
```

Codex pre-QA evidence:

- `npm run verify:release`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- GitHub Release exists and is not draft / not prerelease.
- Tag points at `004325d`.
- README current public release line references the new tag.
- Bundle baseline: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- `PresetGuide` lazy chunk baseline: `33.99 kB JS / 7.49 kB CSS`.
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.
- Kimi QA: APPROVED / ARCHIVED.
- Static checkpoints: 27 / 27 PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-search-filter-release-qa.md`.

## Latest Accepted QA - Template Inspector Search / Filter UX Closeout Docs

Target commit:

```text
bd3a5c5 Document template inspector search filter closeout
```

Scope:

- Docs / handoff only.
- No product code, server, tool, public data, package, lockfile, or release-tag change.

QA focus:

- Verify closeout doc content for A1 product commit `5dd1da1`.
- Verify Kimi / Claude archive references are correct.
- Verify inventory and Kimi / Claude / Gemini CURRENT_TASK consistency.
- Verify handoff inbox shape.
- Kimi QA: APPROVED / ARCHIVED.
- Static checkpoints: 25 / 25 PASS.
- Regression: none.
- Note: Kimi reported one EOF blank-line diff-check warning in the closeout doc; Codex removed it in the archive/standby commit.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-search-filter-closeout-docs-qa.md`.

## Latest Accepted QA - Template Inspector Search / Filter UX

Target commit:

```text
5dd1da1 Add template inspector search filter UX
```

Scope:

- `src/components/TemplateLibrary.jsx`
- `src/components/PresetGuide.css`

Codex pre-QA evidence:

- `npm run lint`: PASS
- A1 static verifier: PASS, Template Inspector annotations `51 / 51`
- `npm run build`: PASS after approved rerun for sandbox `spawn EPERM`
- `npm run smoke:ai-client-parser`: PASS
- `npm run smoke:ai-adapter`: PASS after approved rerun for sandbox `spawn EPERM`; no raw `Bearer` / `Authorization` / `sk-` leakage
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Expected lazy chunk growth: `PresetGuide` `33.99 kB JS / 7.49 kB CSS`

QA focus:

- Verify the 7 quick filters from Claude's taxonomy review.
- Verify OR / union semantics for multiple active filters.
- Verify all 8 safety badges and the universal AI draft / CMO engine verification footer.
- Verify no standalone `GUID`, standalone `Side`, or `Engine Test Required` quick filter was introduced.
- Verify prompt-copy fallback and `aiParsedResponse.isPasteReady` Lua apply gate remain unchanged.
- Verify no credential, storage, sidecar root, or filesystem-write behavior was introduced.
- Kimi QA: APPROVED / ARCHIVED.
- Static checkpoints: 27 / 27 PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-search-filter-ux-qa.md`.
- No release tag exists for this slice yet.

Template Inspector Search / Filter UX closeout reference:

```text
docs/agent-ops/template-inspector-search-filter-ux-closeout-2026-05-09.md
```

Closeout status:

- Closeout docs created by Codex.
- Scope: docs / handoff only after product QA approval.
- Next useful task: focused docs/handoff-only QA when Codex opens a directive.

## Latest Protected Baseline

Latest public release:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-completion
```

Tagged commit:

```text
59bdab9 Mark template inspector completion release in README
```

Release verification:

- `npm run verify:release`: PASS after approved rerun for sandbox `spawn EPERM`
- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Template Inspector annotations: `51 / 51`
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage

Template Inspector completion release-tag QA:

- Kimi QA: APPROVED / ARCHIVED.
- Release tag: `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
- Tagged commit: `59bdab9 Mark template inspector completion release in README`.
- GitHub Release title: `CMO Lua Builder Template Inspector Completion`.
- Static checkpoints: 20 / 20 PASS.
- `npm run verify:release`: PASS.
- Bundle baseline: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Template Inspector annotations: `51 / 51`, `0` missing.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-completion-release-qa.md`.

Template Inspector completion release closeout reference:

```text
docs/agent-ops/template-inspector-completion-release-closeout-2026-05-09.md
```

Template Inspector completion release closeout status:

- Closeout docs created by Codex.
- QA target commit: `9437c3d Document template inspector completion release closeout`.
- Release QA archive commit: `dbf3f9b Archive template inspector completion release QA`.
- Kimi closeout docs QA: APPROVED / ARCHIVED.
- Static checkpoints: 23 / 23 PASS.
- Scope: docs and handoff only.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-completion-release-closeout-docs-qa.md`.

Latest Template Inspector completion post-closeout operating recheck:

- QA target commit: `dd0e211 Record template inspector completion operating recheck`.
- `npm run verify:release`: PASS.
- Chain PASS: sidecar audit, scenario loader verification, lint, build, AI client parser smoke, and AI adapter smoke.
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Scenario baseline: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.
- Template Inspector annotations remain `51 / 51`, `0` missing.
- Kimi QA: APPROVED / ARCHIVED.
- Static checkpoints: 23 / 23 PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-completion-operating-recheck-qa.md`.

Latest protected code baseline:

```text
80a003a Complete template inspector annotations
```

Latest protected Template Inspector completion baseline:

```text
80a003a Complete template inspector annotations
```

Batch 7 planning commit:

```text
28b0875 Document template inspector batch 7 plan
```

Batch 7 Codex pre-QA:

- JSON coverage: `51 / 51` annotated resources, `0` missing
- `npm run lint`: PASS
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`)
- `npm run smoke:ai-adapter`: PASS after approved rerun for sandbox `spawn EPERM`; no raw `Bearer` / `sk-` leakage
- Product/data scope: `public/template-annotations.json` only
- Kimi QA: APPROVED / ARCHIVED
- Static checkpoints: 20 / 20 PASS
- Regression: none

Batch 7 QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-7-qa.md
```

Template Inspector completion closeout reference:

```text
docs/agent-ops/template-inspector-annotation-completion-closeout-2026-05-09.md
```

Template Inspector completion closeout status:

- Closeout docs created by Codex.
- QA target commit: `77e5393 Document template inspector annotation completion closeout`.
- Kimi closeout docs QA: APPROVED / ARCHIVED.
- Static checkpoints: 17 / 17 PASS.
- Scope: docs and handoff only.
- Regression: none.

Template Inspector completion closeout docs QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-completion-closeout-docs-qa.md
```

Latest protected Template Inspector Batch 6 baseline:

```text
81d5b66 Add template inspector annotation batch 6
```

Batch 6 planning commit:

```text
7bfc27c Document template inspector batch 6 plan
```

Batch 6 Codex pre-QA:

- JSON coverage: `42 / 51` annotated resources, `9` missing
- `npm run lint`: PASS
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`)
- `npm run smoke:ai-adapter`: PASS after approved rerun for sandbox `spawn EPERM`; no raw `Bearer` / `sk-` leakage
- Product/data scope: `public/template-annotations.json` only
- Kimi QA: APPROVED / ARCHIVED
- Static checkpoints: 17 / 17 PASS
- Regression: none

Batch 6 QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-6-qa.md
```

Batch 6 closeout reference:

```text
docs/agent-ops/template-inspector-batch-6-closeout-2026-05-09.md
```

Batch 6 closeout status:

- Closeout docs created by Codex.
- QA target commit: `4474fe9 Document template inspector batch 6 closeout`.
- Kimi closeout docs QA: APPROVED / ARCHIVED.
- Static checkpoints: 16 / 16 PASS.
- Scope: docs and handoff only.
- Regression: none.

Batch 6 closeout docs QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-batch-6-closeout-docs-qa.md
```

Latest protected Template Inspector Batch 5 baseline:

```text
a80b9ea Add template inspector annotation batch 5
```

Batch 5 planning commit:

```text
d99e45c Document template inspector batch 5 plan
```

Batch 5 Codex pre-QA:

- JSON coverage: `36 / 51` annotated resources, `15` missing
- `npm run lint`: PASS
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`)
- `npm run smoke:ai-adapter`: PASS after approved rerun for sandbox `spawn EPERM`; no raw `Bearer` / `sk-` leakage
- Product/data scope: `public/template-annotations.json` only
- Kimi QA: APPROVED / ARCHIVED
- Static checkpoints: 17 / 17 PASS
- Regression: none

Batch 5 QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-5-qa.md
```

Batch 5 closeout reference:

```text
docs/agent-ops/template-inspector-batch-5-closeout-2026-05-09.md
```

Batch 5 closeout status:

- Closeout docs created by Codex.
- QA target commit: `11367cd Document template inspector batch 5 closeout`.
- Kimi closeout docs QA: APPROVED / ARCHIVED.
- Static checkpoints: 15 / 15 PASS.
- Scope: docs and handoff only.
- Regression: none.

Batch 5 closeout docs QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-batch-5-closeout-docs-qa.md
```

Latest protected Template Inspector Batch 4 baseline:

```text
ac8949f Add template inspector annotation batch 4
```

Batch 4 planning commit:

```text
f2a2254 Document template inspector batch 4 plan
```

Latest protected Template Inspector Batch 4 QA baseline:

```text
306a9d6 Add template inspector batch 4 QA directive
```

Batch 4 QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-4-qa.md
```

Batch 4 QA result:

- Kimi QA: APPROVED / ARCHIVED
- JSON coverage: `30 / 51` annotated resources, `21` missing
- `npm run lint`: PASS
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`)
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage
- Regression: none

Batch 4 closeout reference:

```text
docs/agent-ops/template-inspector-batch-4-closeout-2026-05-09.md
```

Batch 4 closeout status:

- Closeout docs created by Codex.
- QA target commit: `3f8911b Document template inspector batch 4 closeout`.
- Kimi closeout docs QA: APPROVED / ARCHIVED.
- Static checkpoints: 15 / 15 PASS.
- Scope: docs and handoff only.
- Regression: none.

Batch 4 closeout docs QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-batch-4-closeout-docs-qa.md
```

Latest protected Template Inspector Batch 3 baseline:

```text
4d7208a Add template inspector annotation batch 3
```

Batch 3 planning commit:

```text
031ad02 Document template inspector batch 3 plan
```

Latest protected Template Inspector Batch 3 QA baseline:

```text
08a96bb Add template inspector batch 3 QA directive
```

Latest protected Template Inspector Batch 3 archive baseline:

```text
18689c6 Archive template inspector batch 3 QA
```

Batch 3 QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-3-qa.md
```

Batch 3 QA result:

- Kimi QA: APPROVED / ARCHIVED
- JSON coverage: `24 / 51` annotated resources, `27` missing
- `npm run lint`: PASS
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`)
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage
- Regression: none

Pending closeout reference:

```text
docs/agent-ops/template-inspector-batch-3-closeout-2026-05-09.md
```

Pending closeout docs QA target:

```text
be840ac Document template inspector batch 3 closeout
```

Latest protected Template Inspector Batch 3 closeout docs QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-batch-3-closeout-docs-qa.md
```

Batch 3 closeout docs QA result:

- Kimi QA: APPROVED / ARCHIVED
- Target commit: `be840ac Document template inspector batch 3 closeout`
- Static checkpoints: 15 / 15 PASS
- Scope: docs and handoff only
- Regression: none

Latest protected docs baseline:

```text
f46385b Mark template inspector annotation release in README
```

Latest protected closeout docs baseline:

```text
3ff471e Document template inspector annotations release closeout
```

Latest protected closeout docs QA baseline:

```text
e6b0c97 Archive template inspector annotations closeout docs QA
```

Latest protected agent handoff baseline:

```text
f2d7ceb Archive template inspector post-closeout recheck QA
```

Latest protected Template Inspector QA baseline:

```text
d85ea78 Archive template inspector annotations release QA
```

Latest protected smoke-test baseline:

```text
adddf64 Record template inspector post-closeout verification
```

Latest protected QA workflow baseline:

```text
d7afc39 Add release verification script
```

Latest release tag baseline:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-annotations
f46385b Mark template inspector annotation release in README
```

Release closeout reference:

```text
docs/agent-ops/template-inspector-annotations-release-closeout-2026-05-09.md
```

Latest operating baseline before the UI hint:

```text
146861a Record transient scenario smoke recheck
```

Latest product release commit:

```text
d215245 Improve sidecar root onboarding errors
```

Recent protection commits:

- `c668206` Externalize CMO scenario sidecars and loader tooling
- `4698bde` Add AI provider profiles and assistant safety workflow
- `6d57cae` Lazy split Preset Guide and template assets
- `e34132a` Record final protection QA and agent handoff evidence
- `f3eec7c` Refresh agent CURRENT_TASK baselines
- `6272ab9` Polish AI assistant and sidecar UX wording
- `d55b311` Document sidecar root override for fresh clones
- `d215245` Improve sidecar root onboarding errors
- `ba8005c` Refresh handoff baselines after onboarding release
- `f77c946` Archive post-release handoff QA directive
- `121d877` Archive focused UI regression QA directive
- `146861a` Record transient scenario smoke recheck
- `b052420` Refresh agent baselines after transient smoke recheck
- `cf77386` Add sidecar root settings hint
- `d9b8283` Add sidecar root hint QA directive
- `91d8e46` Mark sidecar root hint QA directive active
- `be13607` Archive sidecar root hint QA directive
- `e6f2057` Update README sidecar root guidance
- `6a927ab` Add README sidecar guidance QA directive
- `9cf77bd` Archive README sidecar guidance QA directive
- `607196f` Add AI client parser contract smoke
- `77af9a3` Add AI client parser smoke QA directive
- `c68a6c8` Archive AI client parser smoke QA directive
- `6aa7216` Refresh Claude and Gemini parser smoke baselines
- `92578e1` Refresh Kimi handoff commit list
- `d7afc39` Add release verification script
- `749c8b5` Add release verification QA directive
- `8e75991` Archive release verification QA directive
- `db22c6d` Add QA workflow release tag QA directive
- `74adcf3` Archive QA workflow release tag QA directive
- `7963e60` Refresh agents after QA workflow release
- `1b7e603` Document QA workflow release closeout
- `affc787` Link agents to QA workflow closeout
- `ee77ee9` Record QA workflow release in stabilization inventory
- `0ed9b34` Refresh QA workflow closeout references
- `1260e33` Clarify AI Lua apply safety wording
- `6856a8a` Add AI Lua apply safety wording QA directive
- `78b3c42` Archive AI Lua apply safety wording QA
- `a8e9b66` Refresh README after AI Lua safety wording QA
- `e85f004` Add AI Lua safety wording release QA directive
- `eb93f50` Archive AI Lua safety wording release QA
- `15bff5d` Refresh agent baselines after AI Lua safety release
- `6900afe` Document AI Lua safety wording release closeout
- `8f9641e` Clarify transient scenario sidecar UX
- `d3fe238` Add transient scenario sidecar UX QA directive
- `a0a52f9` Archive transient scenario sidecar UX QA
- `5c6f81f` Refresh agent baselines after transient sidecar UX
- `ffbd86e` Refresh README for transient sidecar UX release
- `386bf12` Add transient sidecar UX release QA directive
- `175b17a` Archive transient sidecar UX release QA
- `1192379` Document transient sidecar UX release closeout
- `f15115a` Add transient sidecar UX closeout docs QA directive
- `bb86df5` Archive transient sidecar UX closeout docs QA
- `5e8248c` Refresh agents after final release verification
- `2ba77a8` Polish sidecar cache settings wording
- `f8f5dc2` Add sidecar cache wording QA directive
- `564da22` Archive sidecar cache wording QA
- `3d754ab` Refresh agents after sidecar cache wording QA
- `f3539f5` Mark sidecar cache wording release in README
- `ed3b760` Add sidecar cache wording release QA directive
- `43d9287` Archive sidecar cache wording release QA
- `af84723` Document sidecar cache wording release closeout
- `3c202df` Add sidecar cache wording closeout docs QA directive
- `9822cd3` Archive sidecar cache wording closeout docs QA
- `fb33753` Refresh agents after sidecar cache closeout QA
- `ebf47b4` Record post-closeout release verification
- `05fd836` Add core template inspector annotations
- `ecc1964` Add template annotation coverage QA directive
- `350a515` Archive template annotation coverage QA
- `246c175` Add event template inspector annotations
- `8618dee` Add template annotation batch 2 QA directive
- `6d553b7` Archive template annotation batch 2 QA

Latest published releases:

- `release-2026-05-05-cmo-lua-builder-stable`
- `release-2026-05-06-cmo-lua-builder-docs-refresh`
- `release-2026-05-06-cmo-lua-builder-sidecar-onboarding`
- `release-2026-05-06-cmo-lua-builder-qa-workflow`
- `release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`
- `release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`
- `release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`

Accepted bundle baseline:

- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `PresetGuide`: `30.05 kB JS / 5.86 kB CSS`
- `AiAdapterSettings`: `10.44 kB JS / 2.43 kB CSS`
- `AiInterpreterChatPanel`: `10.19 kB JS / 6.19 kB CSS`
- `AiResponseReviewPanel`: `5.19 kB JS / 3.50 kB CSS`
- `IntentPlannerPanel`: `5.03 kB JS`
- `aiContextPruning`: `8.56 kB`

Latest post-release verification (`d215245`, fresh clone from `release-2026-05-06-cmo-lua-builder-sidecar-onboarding`):

- `npm run audit:scenario-sidecars`: PASS (`1899` in index, `3799` protected, `24` orphans / `5.6 MB`)
- `npm run verify:scenario-loader`: PASS (`1857` ready / `42` decoderFailed, issues `0`)
- `npm ci`: PASS (`0` vulnerabilities)
- `npm run lint`: PASS
- `npm run build`: PASS (`366.01 kB JS / 58.27 kB CSS`)
- `npm run smoke:ai-adapter`: PASS after approved spawn permissions; no `Bearer` / `sk-` leak

Latest operating recheck (`146861a`):

- `npm run audit:scenario-sidecars`: PASS (`1899` in index, `3799` protected, `24` orphans / `5.6 MB`)
- `npm run verify:scenario-loader`: PASS (`1857` ready / `42` decoderFailed, issues `0`)
- `npm run smoke:scenario-transient`: PASS after approved spawn permissions; returned an in-memory summary and left `.scenario-extract-cache/` empty

Latest UI hint QA (`cf77386`):

- `npm run lint`: PASS
- `npm run build`: PASS (`366.29 kB JS / 58.27 kB CSS`)
- `npm run smoke:ai-adapter`: PASS; no raw `Bearer` / `sk-` leakage
- Static checkpoints PASS: sidecar root hint, `%USERPROFILE%\.codex\cmo-scenario-sidecars`, `CMO_SCENARIO_SIDECAR_ROOT`, `.scen` not modified wording, command rows unchanged, prompt-copy fallback, and `isPasteReady` apply gate

Latest README guidance QA (`e6f2057`):

- `npm run lint`: PASS
- `npm run build`: PASS (`366.29 kB JS / 58.27 kB CSS`)
- Static checkpoints PASS: removed stale `556d99e` baseline, documented `release-2026-05-06-cmo-lua-builder-sidecar-onboarding`, mirrored Settings sidecar root hint, retained `CMO_SCENARIO_SIDECAR_ROOT`, and confirmed README-only scope

Latest AI client parser contract smoke QA (`607196f`):

- `npm run smoke:ai-client-parser`: PASS
- `npm run lint`: PASS
- `npm run build`: PASS (`366.29 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`)
- `npm run smoke:ai-adapter`: PASS; no raw `Bearer` / `sk-` leakage
- Static checkpoints PASS: OpenAI/Ollama/error text extraction, paste-ready response, missing heading blocker, placeholder blocker, unsafe Lua blocker, `BLOCKER` response, no new dependency, and unchanged `package-lock.json`

Latest release verification script self-check (`d7afc39`):

- `npm run verify:release`: PASS after approved spawn permissions
- Pipeline covered sidecar audit, scenario loader verification, lint, build, AI client parser smoke, and AI adapter smoke
- Build output remained `366.29 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Sidecar audit remained dry-run only (`1899` in index, `24` orphans / `5.6 MB`)

Latest release verification script QA (`d7afc39`):

- `git status --short --branch`: clean (`main...origin/main`)
- `npm run verify:release`: PASS
- Internal chain PASS: sidecar audit, scenario loader verification, lint, build, AI client parser smoke, and AI adapter smoke
- Static checkpoints PASS: `package.json` script order, README shortcut/manual pipeline, unchanged `package-lock.json`, no new dependencies, and no `src/**`, `server/**`, or `tools/**` change
- Regression: none

Latest QA workflow release creation (`e5cd403`):

- Tag pushed: `release-2026-05-06-cmo-lua-builder-qa-workflow`
- GitHub Release created: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-06-cmo-lua-builder-qa-workflow`
- Release title: `CMO Lua Builder QA Workflow Release`
- Release type: not draft, not prerelease

Latest QA workflow release tag QA (`e5cd403`):

- Current HEAD during QA: `db22c6d` directive bookkeeping commit
- Tag points at `e5cd403 Mark QA workflow release in README`
- GitHub Release title/URL verified, not draft, not prerelease
- `npm run verify:release`: PASS
- Build output remained `366.29 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Scenario baseline remained `1899 total / 1857 ready / 42 decoderFailed / issues 0`
- Static checkpoints PASS: README release line, README QA baseline, `package.json` script, release notes, README-only tag commit scope, and no product/dependency drift
- Regression: none

Latest QA workflow release closeout (`1b7e603`):

- Closeout doc added at `docs/agent-ops/qa-workflow-release-closeout-2026-05-07.md`
- Treat it as the concise operating reference for release verification, watch lines, GitHub Release checks, and next work candidates
- Follow-up references linked in agent handoffs (`affc787`) and stabilization inventory (`ee77ee9`)

Latest Codex product change QA-approved by Kimi (`1260e33`):

- Commit: `1260e33 Clarify AI Lua apply safety wording`
- Scope: `src/components/AiInterpreterChatPanel.jsx`, `src/components/AiResponseReviewPanel.jsx`, `src/components/LuaAssistant.jsx`
- Intent: make AI-generated Lua application read as a gated draft, not engine-verified final code
- Codex pre-QA: `npm run verify:release` PASS
- Observed build: `366.47 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`

Latest AI Lua apply safety wording QA (`1260e33`, archived under `_archive/2026-05-07/`):

- `git status --short --branch`: clean (`main...origin/main`)
- `npm run verify:release`: PASS
- Internal chain PASS: sidecar audit, scenario loader verification, lint, build, AI client parser smoke, and AI adapter smoke
- Build output: `366.47 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Static checkpoints PASS: `초안 준비`, `CMO 검증 필요`, apply tooltips, Working Lua placeholder, `isPasteReady` apply gate, disabled apply buttons, prompt-copy fallback, and no credential strings in changed UI surfaces
- Regression: none

Latest AI Lua safety wording release creation (`a8e9b66`):

- Tag pushed: `release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`
- Tagged commit: `a8e9b66 Refresh README after AI Lua safety wording QA`
- GitHub Release created: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`
- Release title: `CMO Lua Builder AI Lua Safety Wording Update`
- Release state: not draft, not prerelease
- Kimi release-tag QA: APPROVED

Latest AI Lua safety wording release-tag QA (`a8e9b66`, archived under `_archive/2026-05-07/`):

- Current HEAD during QA: `e85f004 Add AI Lua safety wording release QA directive`
- Tag points at `a8e9b66 Refresh README after AI Lua safety wording QA`
- GitHub Release title/URL verified, not draft, not prerelease
- Release notes mention gated draft wording, CMO engine verification, `npm run verify:release` PASS, and bundle baseline
- `npm run verify:release`: PASS
- Build output: `366.47 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`
- AI adapter smoke: PASS, no raw `Bearer` / `sk-` leakage
- Regression: none

Latest Codex product change QA-approved by Kimi (`8f9641e`):

- Commit: `8f9641e Clarify transient scenario sidecar UX`
- Scope: `src/components/LuaAssistant.jsx`
- Intent: make missing-sidecar and transient in-memory scenario open status messages clearer without changing loader behavior
- Codex pre-QA: `npm run verify:release` PASS
- Observed build: `366.60 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`

Latest transient scenario sidecar UX QA (`8f9641e`, archived under `_archive/2026-05-07/`):

- `git status --short --branch`: clean (`main...origin/main`)
- `npm run verify:release`: PASS
- `npm run smoke:scenario-transient`: PASS, returned an in-memory summary and left `.scenario-extract-cache/` empty
- Build output: `366.60 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Static checkpoints PASS: only `LuaAssistant.jsx` changed, transient success/failure wording, adapter transient open guidance, metadata-only guidance, unchanged `openScenarioTransient(file)` path, unchanged `adapter://scenario/transient-open`, unchanged `isPasteReady` apply gate, and no credential strings in changed UI surfaces
- Regression: none

Latest transient sidecar UX release creation (`ffbd86e`):

- Tag pushed: `release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`
- Tagged commit: `ffbd86e Refresh README for transient sidecar UX release`
- GitHub Release created: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`
- Release title: `CMO Lua Builder Transient Sidecar UX Update`
- Release state: not draft, not prerelease
- Kimi release-tag QA: APPROVED

Latest transient sidecar UX release-tag QA (`ffbd86e`, archived under `_archive/2026-05-07/`):

- Current branch during QA: clean (`main...origin/main`)
- Tag points at `ffbd86e Refresh README for transient sidecar UX release`
- GitHub Release title/URL verified, not draft, not prerelease
- Release notes mention transient in-memory summary, `.scen` not modified, temp files cleaned, `npm run verify:release` PASS, and `npm run smoke:scenario-transient` PASS
- `npm run verify:release`: PASS
- `npm run smoke:scenario-transient`: PASS, in-memory summary returned and `.scenario-extract-cache` empty
- Build output: `366.60 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage
- Regression: none

Latest transient sidecar UX release closeout:

- Closeout reference: `docs/agent-ops/transient-sidecar-ux-release-closeout-2026-05-07.md`
- Treat this as the concise operating reference for transient in-memory sidecar UX, release verification, watch lines, and next work candidates.

Latest transient sidecar UX closeout docs QA (`1192379`, archived under `_archive/2026-05-07/`):

- Target commit: `1192379 Document transient sidecar UX release closeout`
- `git status --short --branch`: clean (`main...origin/main`)
- `git show --stat --oneline 1192379`: expected docs/handoff scope only
- `git diff --check`: PASS
- Static checkpoints PASS: closeout doc, release tag, tagged commit, GitHub Release title/URL, release state, product UX commit, release QA commits, verification commands, bundle/scenario baselines, `.scen` not modified invariant, temp-cache cleanup invariant, `isPasteReady` gate, inventory entry, agent handoff baselines, clean inboxes, and no product/package drift
- Regression: none

Latest full operating recheck (`bb86df5`):

- Initial sandbox run reached Vite build and stopped on known `spawn EPERM`; approved rerun was used for final status.
- `npm run verify:release`: PASS.
- Internal chain PASS: sidecar audit, scenario loader verification, lint, build, AI client parser smoke, and AI adapter smoke.
- Build output: `366.60 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / `5.6 MB`.
- AI adapter smoke: PASS, no raw `Bearer` / `sk-` leakage.
- Working tree after recheck: clean (`main...origin/main`).

Latest Codex product change QA-approved by Kimi (`2ba77a8`):

- Commit: `2ba77a8 Polish sidecar cache settings wording`
- Scope: `src/App.jsx`
- Intent: replace leftover English labels in Settings > Storage > Scenario Sidecar Cache with compact Korean wording.
- Codex pre-QA: `npm run lint` PASS; `npm run build` PASS after approved run; `npm run smoke:ai-adapter` PASS after approved run.
- Observed build: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Kimi focused QA: APPROVED.

Latest sidecar cache settings wording QA (`2ba77a8`, archived under `_archive/2026-05-07/`):

- `git status --short --branch`: clean (`main...origin/main`)
- `git show --stat --oneline 2ba77a8`: `src/App.jsx` only, `7` insertions / `7` deletions
- `npm run lint`: PASS
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`)
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage
- Static checkpoints PASS: Korean sidecar index loading/success/error/pending/count labels, sidecar root hint, `CMO_SCENARIO_SIDECAR_ROOT`, `.scen` not modified wording, command rows, prompt-copy fallback, `isPasteReady` apply gate, and no new credential strings
- Regression: none

Latest sidecar cache wording release creation (`f3539f5`):

- Tag pushed: `release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`
- Tagged commit: `f3539f5 Mark sidecar cache wording release in README`
- GitHub Release created: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`
- Release title: `CMO Lua Builder Sidecar Cache Wording Update`
- Release state: not draft, not prerelease
- `npm run verify:release`: PASS before tagging
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Kimi release-tag QA: APPROVED

Latest sidecar cache wording release-tag QA (`f3539f5`, archived under `_archive/2026-05-08/`):

- Current branch during QA: clean (`main...origin/main`)
- Tag points at `f3539f5 Mark sidecar cache wording release in README`
- GitHub Release title/URL verified, not draft, not prerelease
- Release notes mention sidecar cache Korean wording polish, unchanged behavior/safety boundaries, `npm run verify:release` PASS, bundle baseline, sidecar/loader baseline, and AI adapter smoke auth safety
- `npm run verify:release`: PASS
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / `5.6 MB`
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage
- Regression: none

Latest sidecar cache wording release closeout:

- Closeout reference: `docs/agent-ops/sidecar-cache-wording-release-closeout-2026-05-08.md`
- Treat this as the concise operating reference for sidecar cache wording, release verification, watch lines, and next work candidates.
- Kimi closeout docs QA: APPROVED / ARCHIVED under `_archive/2026-05-08/`; target `af84723`, 16 / 16 static checkpoints PASS, no regression.

Latest post-closeout operating recheck (`fb33753`):

- Initial sandbox run hit Vite `spawn EPERM`; approved rerun was used.
- `npm run verify:release`: PASS.
- Chain PASS: sidecar audit, scenario loader verification, lint, build, AI client parser smoke, and AI adapter smoke.
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / `5.6 MB`.
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.
- Agent inboxes: Kimi / Claude / Gemini each contain only `_archive/` and `CURRENT_TASK.md`.

Latest Template Inspector annotation product change (`05fd836`):

- Commit: `05fd836 Add core template inspector annotations`.
- Scope: `public/template-annotations.json` only.
- Adds Template Inspector guide annotations for `doctrine_emcon.tpl.lua`, `mission_strike.tpl.lua`, `reference_point_add.tpl.lua`, and `unit_spawn.tpl.lua`.
- Coverage moved from `8 / 51` to `12 / 51` annotated builder resources in Codex pre-check.
- Codex pre-QA: JSON parse PASS, `npm run lint` PASS, `npm run build` PASS, `npm run smoke:ai-adapter` PASS after approved rerun for sandbox `spawn EPERM`.
- Observed build: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.

Latest Template Inspector annotation coverage QA (`05fd836`, archived under `_archive/2026-05-08/`):

- Kimi QA: APPROVED / ARCHIVED.
- `git show --name-only --oneline 05fd836`: `public/template-annotations.json` only.
- `npm run lint`: PASS.
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- JSON coverage: `12 / 51` annotated resources, `39` missing, four new annotation keys present.
- Static checkpoints: 15 / 15 PASS.
- Regression: none.

Latest Template Inspector annotation Batch 2 product change (`246c175`):

- Commit: `246c175 Add event template inspector annotations`.
- Scope: `public/template-annotations.json` only.
- Adds Template Inspector guide annotations for `event_simple.tpl.lua`, `event_regular_time.tpl.lua`, `event_unit_detected.tpl.lua`, `event_unit_enters_area.tpl.lua`, `loadout_set.tpl.lua`, and `zone_add.tpl.lua`.
- Coverage moved from `12 / 51` to `18 / 51` annotated builder resources in Codex pre-check.
- Codex pre-QA: JSON parse PASS, `npm run lint` PASS, `npm run build` PASS, `npm run smoke:ai-adapter` PASS with approved spawn permissions for build/smoke.
- Observed build: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.

Latest Template Inspector annotation Batch 2 QA (`246c175`, archived under `_archive/2026-05-09/`):

- Kimi QA: APPROVED / ARCHIVED.
- `git show --name-only --oneline 246c175`: `public/template-annotations.json` only.
- `npm run lint`: PASS.
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- JSON coverage: `18 / 51` annotated resources, `33` missing, six new annotation keys present.
- Static checkpoints: 17 / 17 PASS.
- Regression: none.

Latest Template Inspector annotations release creation (`f46385b`):

- Tag pushed: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Tagged commit: `f46385b Mark template inspector annotation release in README`.
- GitHub Release created: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Release title: `CMO Lua Builder Template Inspector Annotation Update`.
- Release state: not draft, not prerelease.
- `npm run verify:release`: PASS after approved rerun for sandbox `spawn EPERM`.
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.

Latest Template Inspector annotations release-tag QA (`f46385b`, archived under `_archive/2026-05-09/`):

- Kimi QA: APPROVED / ARCHIVED.
- Tag points at `f46385b Mark template inspector annotation release in README`.
- GitHub Release title: `CMO Lua Builder Template Inspector Annotation Update`.
- Release state: not draft, not prerelease.
- `npm run verify:release`: PASS.
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run, `3799` protected, `24` orphans / `5.6 MB`.
- Static checkpoints: 18 / 18 PASS.
- Regression: none.

Latest Template Inspector annotations release closeout docs:

- Target commit: `3ff471e Document template inspector annotations release closeout`.
- Closeout reference: `docs/agent-ops/template-inspector-annotations-release-closeout-2026-05-09.md`.
- Inventory updated: `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`.
- Scope: docs / handoff only; no product source, package, parser, adapter, pruning, or scenario-loader behavior changes.
- Treat this as the concise operating reference for Template Inspector annotation coverage, release verification, watch lines, and next work candidates.
- Kimi closeout docs QA: APPROVED / ARCHIVED under `_archive/2026-05-09/`; target `3ff471e`, 21 / 21 static checkpoints PASS, no regression.

Latest Template Inspector post-closeout operating recheck (Codex pre-QA):

- `npm run verify:release`: PASS.
- Chain PASS: sidecar audit, scenario loader verification, lint, build, AI client parser smoke, and AI adapter smoke.
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / `5.6 MB`.
- AI adapter smoke: PASS, sanitized HTTP 401 forwarding and no raw `Bearer` / `Authorization` / `sk-` leakage.
- No source, server, tool, package, dependency, or release-tag change was part of this recheck.
- Kimi recheck QA: APPROVED / ARCHIVED under `_archive/2026-05-09/`; target `adddf64`, 20 / 20 static checkpoints PASS, `npm run verify:release` PASS, no regression.
- Recheck QA archive commit: `f2d7ceb Archive template inspector post-closeout recheck QA`.

Watch lines:

- Main JS must stay under `400 kB`.
- Main CSS should stay below `60 kB`; report any rise above `60 kB` as regression.
- `aiContextPruning` must stay under `9 kB`; no pruning expansion unless Codex opens a task.

## Scenario / Sidecar Baseline

Current local verification baseline:

- Total `.scen`: `1899`
- `readyWithInternalSidecar`: `1857`
- `metadataOnlyNeedsDecoder`: `0`
- `decoderFailed`: `42`
- `verify:scenario-loader`: PASS, issues `0`

External sidecar root:

```text
C:\Users\dlwls\.codex\cmo-scenario-sidecars
```

Sidecar rules:

- Generated sidecars are local/regenerable.
- Do not delete sidecars or orphans unless Codex/user explicitly asks.
- Do not run broad `--all` extraction. Prefer Codex-selected official folders or explicit targets.
- `decoderLegacyCmano` is a known legacy limitation, not a fresh blocker.

## Standard QA Pipelines

Default code/UI/AI change:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

Scenario/sidecar/tooling change:

```powershell
git status --short
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run build
```

Full final verification:

```powershell
git status --short
npm run verify:release
```

If `smoke:ai-adapter` hits `spawn EPERM`, report it as sandbox/environment unless code evidence says otherwise. Codex can rerun with approved spawn permissions.

## Safety Contracts To Watch

- Lua apply is enabled only when `aiParsedResponse.isPasteReady === true`.
- Manual prompt-copy fallback must remain visible.
- AI adapter smoke must not leak raw `Bearer`, `Authorization`, or `sk-` values.
- Saved provider profiles must not persist raw `apiKey`.
- Context pruning must preserve DBID/GUID hints and hard-block stripping.
- Preset Guide custom save stores only the currently displayed form.
- Assistant template insertion appends below existing Lua text; it must not replace user content.

## Reporting Format

Keep reports compact:

- pipeline pass/fail
- bundle sizes
- scenario counts if relevant
- exact regression if any
- no broad refactor proposals unless Codex opens that task

## Boundaries

- Do not modify `src/**`, `server/**`, `tools/**`, `package.json`, docs, or handoff files.
- Do not commit.
- Do not install Vitest or introduce new test frameworks.
- Do not mass-decode scenario folders.
- Do not classify excluded user workspace files as official scenario defects.
