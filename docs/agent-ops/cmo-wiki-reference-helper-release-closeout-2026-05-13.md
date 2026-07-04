# CMO Wiki / Lua Reference Helper Release Closeout - 2026-05-13

## Status

APPROVED / RELEASED

## Release

- Tag: `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`.
- Tagged commit: `d09b0d7 Mark CMO wiki reference helper release in README`.
- Tagged commit full SHA: `d09b0d7ebebbefe0896f28dab4cc954b6a1470ed`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`.
- Release title: `CMO Lua Builder CMO Wiki Reference Helper`.
- Release state: not draft, not prerelease.

## Purpose

This release closes the CMO Wiki / Lua Reference Helper work as the current public baseline for the local advisory workspace.

It turns the completed Template Inspector annotation set into a deterministic, beginner-facing CMO Lua reference surface:

```text
AI chat remains the conversation surface.
The Lua editor remains a manual scratchpad.
The encyclopedia and right-side reference helper provide known CMO Lua guidance without becoming another AI.
```

## Included Chain

- Advisory workspace design: `88779c3 Design CMO wiki code assistant`.
- Review directives opened: `7266c12 Open CMO wiki code assistant reviews`.
- Implementation plan: `e699301 Plan CMO wiki code assistant implementation`.
- Wiki entry helper: `4f70332 Add CMO wiki entry helper`.
- Shared utility helpers: `30801bc Share CMO wiki utility helpers`.
- Encyclopedia panel: `32250e5 Add CMO Lua encyclopedia panel`.
- Lua editor reference helper: `11d6bcf Add Lua editor reference helper`.
- Product QA activation: `7ce5a38 Open CMO wiki code assistant QA`.
- Product closeout docs: `a695e34 Document CMO wiki code assistant closeout`.
- Closeout whitespace cleanup: `dcae3fa Fix CMO wiki closeout whitespace`.
- Release marker: `d09b0d7 Mark CMO wiki reference helper release in README`.
- Release marker QA archive: `e597e8a Archive CMO wiki release marker QA`.
- Release tag QA activation: `09e15a2 Open CMO wiki release tag QA`.
- Release tag QA whitespace cleanup: `ed05f01 Fix CMO wiki release tag QA whitespace`.

## Review Evidence

Claude architecture review:

- Directive archive: `handoff/to-claude/_archive/2026-05-13/2026-05-13-cmo-wiki-code-assistant-architecture-review.md`.
- Review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-CMO-Wiki-Code-Assistant\cmo-wiki-code-assistant-architecture-review.md`.
- Verdict: `APPROVED with refinements`.
- Applied direction: helper-first extraction, no duplicated TemplateLibrary utility logic, no second AI surface in the editor, lazy-loaded UI slices.

Gemini UX / wording review:

- Directive archive: `handoff/to-gemini/_archive/2026-05-13/2026-05-13-cmo-wiki-code-assistant-ux-review.md`.
- Verdict: `APPROVED WITH CHANGES`.
- Applied direction: beginner-facing wording, deterministic helper naming, text-only AI draft labels, and template creation de-emphasis.

## QA Evidence

Kimi QA archives:

- `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-code-assistant-qa.md`.
- `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-marker-qa.md`.
- `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-tag-qa.md`.

Kimi QA results:

- Product QA: APPROVED, `38 / 38 PASS`.
- Release marker QA: APPROVED, `25 / 25 PASS`.
- Release tag QA: APPROVED, `35 / 35 PASS`.
- Regression: none reported across the release chain.

## Release Notes Coverage

The GitHub Release notes include:

- CMO Lua encyclopedia.
- 51 / 51 template annotation baseline.
- Deterministic search and quick filters.
- Lua editor reference helper.
- Text-only AI chat drafts.
- No automatic AI send.
- No automatic CMO execution.
- No CMO file writes, deletes, polling, watcher, or live-state claim.
- No browser-provided filesystem roots.
- No backend endpoint changes.
- No dependency or lockfile drift.
- Manual prompt-copy fallback.
- `aiParsedResponse.isPasteReady` gate preservation.
- CMO engine verification remains required.
- `npm run verify:release` PASS with the 17-step release chain.
- Sidecar audit and scenario loader baselines.
- B2, B3, B4 smoke baselines.
- CMO Wiki / Lua Reference Helper smoke baseline.
- AI client parser smoke.
- AI adapter smoke with no raw `Bearer` / `Authorization` / `sk-` leakage.
- Bundle and QA evidence baselines.

## Verification Baseline

Release tag QA observed:

```powershell
npm run verify:release
```

Verification result:

- `audit:scenario-sidecars`: PASS, `1899` in index, `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.
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
- `smoke:cmo-state-snapshot`: PASS.
- `smoke:cmo-state-snapshot-endpoint`: PASS.
- `smoke:ai-adapter-client-state-snapshot`: PASS.
- `smoke:cmo-wiki-code-assistant`: PASS.
- `smoke:ai-client-parser`: PASS.
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.

Bundle baseline:

- Main JS: `253.81 kB`.
- Main CSS: `59.45 kB`.
- `aiContextPruning`: `8.56 kB`.
- `CmoWikiPanel`: `7.59 kB JS / 3.61 kB CSS`.
- `LuaEditorReferenceHelper`: `2.12 kB JS / 0.84 kB CSS`.
- `LuaAssistant`: `136.86 kB JS`.

## Preserved Boundaries

This release does not introduce:

- automatic AI send
- automatic CMO execution
- CMO file writes or deletes
- `.scen` mutation
- polling loop
- filesystem watcher
- live-state claim
- browser-provided filesystem root
- backend endpoint changes
- dependency or lockfile drift
- credential persistence
- raw auth leakage

Existing controls remain:

- Manual prompt-copy fallback.
- AI chat text-only draft insertion.
- B2 user-run `ScenEdit_RunScript('/AiAssist/<file>.lua')` path.
- B3 read-only log feedback path.
- B4 imported snapshot path.
- User-selected Confirmed Context promotion.
- `aiParsedResponse.isPasteReady` gate for Lua apply and sidecar save.
- CMO engine verification remains required.

## User-Facing Outcome

The public advisory workspace now supports:

1. AI chat as the primary place for user questions.
2. Manual Lua editing as a scratchpad and verification helper.
3. A CMO Lua encyclopedia based on known template annotations.
4. A deterministic editor-side Lua reference helper.
5. Text-only draft routing from wiki/helper context into AI chat.

## Next Recommended Gate

This release is tagged and public.

Recommended next gate:

```text
CMO Wiki / Lua Reference Helper post-release operating recheck
```

Optional manual gate after that:

```text
End-to-end advisory workflow smoke:
AI chat question -> wiki lookup -> Lua editor helper -> B2 save -> CMO RunScript -> B3 log feedback -> B4 snapshot import -> text-only follow-up draft
```
