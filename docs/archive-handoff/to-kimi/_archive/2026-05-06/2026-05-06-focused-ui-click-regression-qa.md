# Kimi QA Directive - Focused UI Click Regression

Date: 2026-05-06
Requested by: Codex
Mode: read-only QA / focused UI regression monitor

## Purpose

Run a focused regression pass for the next implementation candidate from `docs/agent-ops/next-phase-parallel-plan-2026-05-03.md`:

> Focused UI click regression pass for template insertion and preset save/modify behavior.

This is a QA-only directive. Codex is not opening a new feature or refactor in this pass.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not archive this directive; Codex will archive it after your report.
- Do not install new test frameworks.
- Do not run broad scenario extraction or sidecar pruning.
- Do not change release tags.

## Current Baseline

Expected latest HEAD:

```text
f77c946 Archive post-release handoff QA directive
```

Expected release tag distinction:

- `release-2026-05-06-cmo-lua-builder-sidecar-onboarding` points at `d215245`
- `f77c946` is post-release docs/handoff archive only

Accepted bundle baseline:

- Main JS: about `366.01 kB`
- Main CSS: `58.27 kB`
- `PresetGuide`: `30.05 kB JS / 5.86 kB CSS`
- `AiInterpreterChatPanel`: about `10.08 kB JS / 6.19 kB CSS`
- `aiContextPruning`: `8.56 kB`, must stay under `9 kB`

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits `spawn EPERM`, report it as sandbox/environment unless code evidence says otherwise. Codex can rerun with approved spawn permissions.

## Static UI Checkpoints

Verify these source-level UI contracts:

1. `PresetGuide` remains lazy-loaded from `src/App.jsx`.
2. `PresetGuide.jsx` imports `./PresetGuide.css`, keeping Preset Guide styles out of main CSS.
3. Event/Lua Assistant left pane still shows `템플릿 / 프리셋 삽입`.
4. Template / preset insertion is append-only and does not replace existing Lua text.
5. `폼 추가 / Builder Forms` wording remains scoped to Preset Guide, not Event/Lua Assistant.
6. Custom preset save stores only the currently displayed form.
7. Custom preset button label remains `수정`.
8. Manual prompt-copy fallback remains visible.
9. Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.
10. Apply controls remain disabled when `canApplyAiLua` is false.
11. Sidecar/cache wording still states that original `.scen` files are not modified.
12. No raw credential strings were introduced in changed UI surfaces.

Useful source anchors observed by Codex before creating this directive:

- `src/App.jsx`: lazy `PresetGuide` import and `템플릿 / 프리셋 삽입`
- `src/components/PresetGuide.jsx`: `./PresetGuide.css`, `수정`, `현재 표시된 폼 하나만...`
- `src/components/LuaAssistant.jsx`: `canApplyAiLua = aiParsedResponse.isPasteReady`, `Prompt 복사`

## Optional Manual UI Smoke

If you can run a local browser pass safely:

1. Start the app with `npm run dev`.
2. Open the Event/Lua Assistant.
3. Type or paste a small existing Lua draft.
4. Insert any template/preset from `템플릿 / 프리셋 삽입`.
5. Confirm the inserted text is appended below existing content.
6. Open Preset Guide.
7. Add a Builder Forms item, save a custom preset, then use `수정`.
8. Confirm only the current displayed form is saved/restored.

If browser interaction is unavailable, static verification plus pipeline is acceptable for this directive.

## Report Format

Return a compact QA report with:

- pipeline results
- bundle sizes
- static checkpoint table
- optional manual UI smoke result, or note that it was not run
- regressions, if any
- final verdict

Expected verdict if all checks pass:

```text
APPROVED - focused UI click regression baseline holds.
```
