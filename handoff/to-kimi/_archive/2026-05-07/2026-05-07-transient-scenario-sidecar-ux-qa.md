# Kimi QA Directive - Transient Scenario Sidecar UX

Status: APPROVED / ARCHIVED

Target commit:

```text
8f9641e Clarify transient scenario sidecar UX
```

## Purpose

Verify that the scenario transient-open UX wording is clearer while the underlying sidecar loading, transient in-memory summary path, scenario safety boundaries, and release watch lines remain unchanged.

This was a focused UI wording / scenario-loader regression pass.

## QA Result

Final verdict:

```text
APPROVED - transient scenario sidecar UX holds.
```

Pipeline:

- `git status --short --branch`: clean (`main...origin/main`)
- `npm run verify:release`: PASS
- `npm run smoke:scenario-transient`: PASS, returned an in-memory summary and left `.scenario-extract-cache/` empty

Bundle sizes:

- Main JS: `366.60 kB` (`< 400 kB`)
- Main CSS: `58.27 kB` (`< 60 kB`)
- `aiContextPruning`: `8.56 kB` (`< 9 kB`)

Static checkpoints:

1. `src/components/LuaAssistant.jsx` was the only product source changed by `8f9641e`.
2. Missing sidecar status says the app is trying `AI adapter` transient in-memory open.
3. Transient success note says summary JSON was generated in memory and temporary files were cleaned.
4. Transient failure note is Korean and explains adapter/decoder failure without implying `.scen` modification.
5. Scenario inspector sidecar step mentions adapter transient open or `prepare:scenario`.
6. Metadata-only status no longer points users only to legacy `public/scenario-scan-samples`.
7. `openScenarioTransient(file)` call path is unchanged.
8. `sidecarUrl` remains `adapter://scenario/transient-open`.
9. Lua apply safety remains unchanged: `canApplyAiLua` is still derived from `aiParsedResponse.isPasteReady`.
10. No raw credential strings were introduced in changed UI surfaces.
11. Main JS, Main CSS, and `aiContextPruning` remain under watch lines.
12. `smoke:scenario-transient` returned an in-memory summary and left `.scenario-extract-cache/` empty.

Regression:

- None.
