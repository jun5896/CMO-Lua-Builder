# B4 User-Triggered State Export Closeout - 2026-05-11

## Status

APPROVED / READY FOR CLOSEOUT QA

## Purpose

B4 closes the first user-triggered CMO state snapshot import path after B2 created the manual RunScript write bridge and B3 created read-only log feedback.

The completed path is intentionally manual and review-first:

```text
User copies Tool_DumpEvents() / ScenEdit_GetEvent(...) output from CMO
-> UI user pastes the export text
-> UI user clicks 스냅샷 가져오기
-> adapter imports and redacts a bounded snapshot
-> UI shows 가져온 CMO 스냅샷
-> UI prepares 후속 질문 초안
-> user reviews and explicitly sends AI follow-up if needed
```

B4 is not live read-back. It is a timestamped imported snapshot.

## Included B4 Slices

- Planning: `2639944 Plan B4 user-triggered state export`.
- Planning QA / Claude review archive: `dcffbc2 Archive B4 planning QA and review`.
- B4.1 helper: `876903f Add B4 CMO state snapshot helper`.
- B4.1 QA archive: `af52916 Archive B4 state snapshot helper QA`.
- B4.2 endpoint: `92a5ca6 Add B4 CMO state snapshot endpoint`.
- B4.2 QA activation: `aaebbd1 Mark B4 state snapshot endpoint QA active`.
- B4.2 QA archive: `bcdfd1c Archive B4 state snapshot endpoint QA`.
- B4.3 UI: `5d3b06d Add B4 CMO state snapshot UI`.
- B4.3 QA activation: `de0439a Mark B4 state snapshot UI QA active`.

## QA Evidence

Kimi QA archives:

- `handoff/to-kimi/_archive/2026-05-11-b4-user-triggered-state-export-planning-qa.md`.
- `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-helper-qa.md`.
- `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-endpoint-qa.md`.
- `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-ui-qa.md`.

Claude design review:

- Directive archive: `handoff/to-claude/_archive/2026-05-11/2026-05-11-b4-user-triggered-state-export-design-review.md`.
- Review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B4-User-Triggered-State-Export\b4-user-triggered-state-export-review.md`.
- Verdict: `APPROVED with refinements`.

Kimi slice results:

- Planning QA: APPROVED, `55 / 55 PASS`.
- B4.1 helper QA: APPROVED, `80 / 80 PASS`.
- B4.2 endpoint QA: APPROVED, `70 / 70 PASS`.
- B4.3 UI QA: APPROVED, `74 / 74 PASS`.
- Regression: none reported across all B4 slices.

## Implemented Capability

### B4.1 Helper

- `server/cmo-state-snapshot-importer.mjs`.
- Wraps `tools/parse-cmo-event-export.mjs`.
- Rejects empty imports.
- Rejects inputs larger than `256 KiB`.
- Redacts local paths and credential-like text before parse.
- Uses parser-safe replacement tokens so redaction does not create fake XML/Lua structures.
- Sets `source.live === false`.
- Caps event list at `50`.
- Caps special action list at `50`.
- Caps warnings at `20`.
- Converts Lua bodies into bounded previews only.
- Strips parser `raw`, full `luaScript`, and full `luaScripts` fields.
- Reports truncation signals and preview char unit (`utf16-code-units`).

### B4.2 Endpoint

- `POST /api/cmo/state-snapshot/import`.
- Adapter forwards only `text` and `sourceHint`.
- Browser-provided `cmoRoot`, `logsRoot`, `scenarioRoot`, `luaRoot`, `filePath`, and `scriptPath` are ignored.
- Response is passed through `deepScrubSecrets`.
- Logs only event count metadata.
- Endpoint does not call AI, execute CMO Lua, write files, poll, watch, or claim live read-back.

### B4.3 UI

- `importCmoStateSnapshot()` client helper.
- `CMO 상태 스냅샷 가져오기` panel in the output workspace.
- Manual text area for pasted CMO export text.
- Source hint selector for `Tool_DumpEvents()`, `ScenEdit_GetEvent(...)`, Lua Console paste, mixed text, and auto classify.
- `스냅샷 가져오기` button.
- `가져온 CMO 스냅샷` preview with timestamp, source type, `live=false`, counts, and bounded event preview.
- `후속 질문 초안 만들기` inserts a text-only draft into AI chat input.
- `초안 복사` preserves manual fallback.
- User-selected snapshot object-context hints can be promoted into Confirmed Context one value at a time.

## Verification Baseline

Current final verification:

```powershell
npm run verify:release
```

B4.3 QA observed:

- `audit:scenario-sidecars`: PASS, `1899` in index, `3799` protected, `24` orphans / `5.6 MB`, dry-run only.
- `verify:scenario-loader`: PASS, `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- `lint`: PASS.
- `build`: PASS.
- `smoke:ai-workflow-state`: PASS.
- `smoke:ai-follow-up-needs`: PASS.
- `smoke:ai-confirmed-context`: PASS.
- `smoke:ai-adapter-client-sidecar`: PASS.
- `smoke:cmo-log-feedback`: PASS.
- `smoke:cmo-log-feedback-endpoint`: PASS.
- `smoke:ai-adapter-client-log-feedback`: PASS.
- `smoke:ai-client-parser`: PASS.
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.

B4-specific smokes:

- `npm run smoke:cmo-state-snapshot`: PASS.
- `npm run smoke:cmo-state-snapshot-endpoint`: PASS.
- `npm run smoke:ai-adapter-client-state-snapshot`: PASS.

Bundle baseline:

- Main JS: `391.65 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.

## Preserved Boundaries

B4 does not introduce:

- automatic AI send
- automatic CMO execution
- CMO polling loop
- filesystem watcher
- live read-back claim
- browser-provided filesystem root
- CMO file writes or deletes
- `.scen` mutation
- new dependencies
- package-lock drift
- credential persistence
- CSS drift in `src/index.css`

Existing controls preserved:

- Manual `Prompt 복사` fallback.
- B2 `CMO 파일 준비` / `CMO Lua 폴더 저장`.
- Manual `ScenEdit_RunScript('/AiAssist/<file>.lua')` execution.
- B3 `CMO 로그 확인` read-only feedback path.
- `aiParsedResponse.isPasteReady` gate for Lua apply and sidecar write.
- CMO engine verification remains required.

## Operational Meaning

B4 adds the first practical user-triggered state import loop:

- B2 can write a user-approved AI Lua draft to CMO Lua root.
- User manually runs the script in CMO.
- B3 can read resulting CMO logs safely.
- B4 can import manually copied CMO event/state export text safely.
- UI can turn that snapshot into a text-only AI follow-up draft.

This is still deliberately manual at the risk boundaries. It improves context quality without pretending to be a live daemon.

## Next Recommended Gate

Recommended next step:

```text
B4 release marker / README update
```

Expected release tag proposal:

```text
release-2026-05-11-cmo-lua-builder-state-snapshot-import
```

At release marker time, expand `verify:release` to include B4 smokes:

```text
smoke:cmo-state-snapshot
smoke:cmo-state-snapshot-endpoint
smoke:ai-adapter-client-state-snapshot
```

Keep release notes explicit that B4 is imported snapshot context, not live read-back and not automatic AI execution.
