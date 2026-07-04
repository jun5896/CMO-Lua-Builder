# B2 RunScript Sidecar Writer Release Closeout - 2026-05-10

## Status

APPROVED / RELEASED

## Release

- Tag: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Tagged commit: `8c7a18e Mark B2 RunScript sidecar writer release in README`.
- Tagged commit full SHA: `8c7a18e62d2bc041f9bcd1c6d31906c227b33540`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Release title: `CMO Lua Builder RunScript Sidecar Writer`.
- Release state: not draft, not prerelease.

## Purpose

B2 closes the first user-triggered CMO Lua write bridge after Track A local interpreter completion and Track B0/B0.1 integration probing.

The release preserves manual CMO control:

```lua
ScenEdit_RunScript('/AiAssist/<file>.lua')
```

The app prepares and writes paste-ready AI Lua drafts into the CMO Lua root `AiAssist` namespace, then displays a loader snippet for the user to run in CMO.

## Prior Runtime Facts

B0.1 established the runtime model on CMO Build 1868:

- `dofile(...)` is unavailable in the CMO console sandbox.
- `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` succeeded.
- Scenario-folder `.lua` auto-load remains unproven.

User-observed CMO output:

```text
AiAssist_B0RunScript_20260510_0448
'Yes'
```

## Included B2 Slices

- Planning: `3931a95 Plan B2 RunScript sidecar writer`.
- B2.1 writer helper: `b1fce05 Add B2 RunScript sidecar writer helper`.
- B2.2 adapter endpoint: `203b9d7 Add B2 RunScript sidecar endpoint`.
- B2.3 UI controls: `2df8e57 Add B2 sidecar save controls`.
- Closeout docs: `fc7a291 Document B2 RunScript sidecar writer closeout`.
- Release marker: `8c7a18e Mark B2 RunScript sidecar writer release in README`.

## QA Evidence

Kimi QA archives:

- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-plan-qa.md`.
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-helper-qa.md`.
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-endpoint-qa.md`.
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-ui-save-controls-qa.md`.
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-closeout-docs-qa.md`.
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-marker-qa.md`.
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-tag-qa.md`.

Release tag QA result:

- Verdict: APPROVED.
- Static checkpoints: `32 / 32 PASS`.
- Regression: none.
- Tag verified: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer -> 8c7a18e`.
- GitHub Release verified: `CMO Lua Builder RunScript Sidecar Writer`, not draft, not prerelease.
- `npm run verify:release`: PASS.

## Release Notes Coverage

The GitHub Release notes include:

- B2 RunScript sidecar writer path for CMO Lua drafts.
- `CMO 파일 준비` dry-run preview.
- `CMO Lua 폴더 저장` confirmed write.
- Manual `ScenEdit_RunScript('/AiAssist/<file>.lua')` execution in CMO.
- `dofile(...)` and scenario-folder auto-load are not claimed.
- Browser clients do not supply `cmoLuaRoot`.
- Save controls remain gated by `aiParsedResponse.isPasteReady`.
- No automatic CMO execution, polling, log tailing, live read-back, or AI auto-send.
- CMO engine verification remains required.

## Verification Baseline

Current final verification:

```powershell
npm run verify:release
```

Release QA observed:

- `audit:scenario-sidecars`: PASS, `1899` in index, `3799` protected, `24` orphans / `5.6 MB`, dry-run only.
- `verify:scenario-loader`: PASS, `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- `lint`: PASS.
- `build`: PASS.
- `smoke:ai-workflow-state`: PASS.
- `smoke:ai-follow-up-needs`: PASS.
- `smoke:ai-confirmed-context`: PASS.
- `smoke:ai-adapter-client-sidecar`: PASS.
- `smoke:ai-client-parser`: PASS.
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.

Bundle baseline:

- Main JS: `380.45 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.

## Preserved Boundaries

B2 release does not introduce:

- automatic CMO execution
- scenario-folder auto-load claim
- `dofile(...)` recommendation
- CMO polling
- log tailing
- live read-back
- AI auto-send
- browser-provided filesystem roots
- dependency or lockfile drift
- `src/index.css` growth

Still preserved:

- Manual prompt-copy fallback.
- Lua apply and sidecar save remain gated by paste-ready state.
- CMO engine verification remains required.

## Operating Result

B2 is now the current public release baseline for the local AI interpreter -> CMO Lua root handoff:

1. AI generates a paste-ready Lua draft.
2. User previews the file target and loader snippet with `CMO 파일 준비`.
3. User writes the draft with `CMO Lua 폴더 저장`.
4. User manually runs `ScenEdit_RunScript('/AiAssist/<file>.lua')` in CMO.
5. User verifies the result in the CMO engine.

## Next Recommended Gate

Recommended next track:

```text
B3 log feedback loop planning
```

B3 should remain planning-first and must not add automatic AI send. The expected safe shape is user-reviewed log/error feedback that can draft a follow-up prompt, not autonomous CMO or AI control.
