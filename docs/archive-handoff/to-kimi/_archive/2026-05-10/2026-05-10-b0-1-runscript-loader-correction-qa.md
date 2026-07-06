# Kimi QA Directive - B0.1 RunScript Loader Correction

Status: APPROVED / ARCHIVED
Date: 2026-05-10

## Kimi Result

```text
APPROVED - B0.1 RunScript loader correction holds.
Static checkpoints: 34 / 34 PASS.
Source/package/public drift: none.
Regression: none.
```

## Target

Verify the current Codex working changes that revise Track B0.1 after the user-run CMO manual check.

The important manual result is:

```text
dofile([[C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\Lua test\AiAssist_B0LoadCheck.lua]])

ERROR: [string "Console"]:1: attempt to call a nil value (global 'dofile')
```

and then:

```text
print(ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua'))

AiAssist_B0RunScript_20260510_0448
'Yes'
```

Therefore B0.1 and future B2 planning must use explicit `ScenEdit_RunScript('/AiAssist_B0/<file>.lua')` from the CMO Lua root as the safe loader model. Do not treat scenario-folder auto-load or `dofile(...)` as proven.

## Expected Changed Files

The expected scope is tools / docs / handoff only:

```text
tools/prepare-cmo-lua-load-check.mjs
tools/verify-cmo-lua-load-check-contract.mjs
tools/probe-cmo-integration.mjs
docs/agent-ops/cmo-build-1868-db517-refresh-closeout-2026-05-10.md
docs/agent-ops/cmo-integration-probe-b0-2026-05-09.md
docs/agent-ops/cmo-integration-probe-b0-closeout-2026-05-10.md
docs/agent-ops/cmo-lua-load-check-b0-1-2026-05-10.md
docs/agent-ops/cmo-lua-load-check-b0-1-closeout-2026-05-10.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
docs/agent-ops/track-a-local-ai-interpreter-completion-closeout-2026-05-09.md
docs/superpowers/plans/2026-05-09-cmo-integration-probe.md
docs/superpowers/plans/2026-05-10-cmo-lua-load-check.md
docs/user-guides/template-inspector-guide-seed.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
handoff/to-kimi/CURRENT_TASK.md
handoff/to-kimi/2026-05-10-b0-1-runscript-loader-correction-qa.md
```

No `src/**`, `server/**`, `public/**`, `package.json`, `package-lock.json`, dependency, backend endpoint, CMO polling, log tailing, sidecar writer, or live read-back change is expected.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:cmo-lua-load-check
npm run smoke:cmo-integration-probe
npm run probe:cmo-lua-load-check -- --json
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `npm run build` or `npm run smoke:ai-adapter` hits Windows sandbox `spawn EPERM`, report that precisely. Codex pre-QA used approved spawn reruns and observed PASS.

Codex pre-QA evidence:

- `npm run smoke:cmo-lua-load-check`: PASS.
- `npm run smoke:cmo-integration-probe`: PASS.
- `npm run probe:cmo-lua-load-check -- --json`: PASS.
- `git diff --check`: PASS; only CRLF normalization warnings.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved rerun; Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- `npm run smoke:ai-adapter`: PASS after approved rerun; no raw Bearer / Authorization / sk-key leakage.

## Static Checkpoints

Verify:

1. `tools/prepare-cmo-lua-load-check.mjs` supports `--cmo-lua-root`, `--script-folder`, `--file-name`, `--marker`, `--write`, `--yes`, `--overwrite`, and `--json`.
2. `--scenario-folder` is rejected with a message that points to `--cmo-lua-root` and `ScenEdit_RunScript`.
3. Default output is dry-run and writes no file.
4. Write mode requires `--cmo-lua-root`, `--write`, and `--yes`.
5. Default script folder is `AiAssist_B0`.
6. Default file name is `AiAssist_B0LoadCheck.lua`.
7. File name namespace remains restricted to `AiAssist_B0*.lua`.
8. Generated Lua prints a marker only.
9. Generated Lua does not call `ScenEdit_SetKeyValue`, `os.*`, `io.*`, `require`, `dofile`, `loadfile`, `package.*`, or `debug.*`.
10. Loader snippet is exactly `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` for default options.
11. Loader snippet does not contain `dofile`.
12. JSON report includes `usesScenEditRunScript: true`.
13. JSON report includes `usesDofile: false`.
14. Manual steps tell the user not to use `dofile(...)`.
15. Manual steps say scenario-folder auto-load remains unproven.
16. Smoke contract covers no default write, gated write, no overwrite by default, unsafe file-name rejection, scenario-folder rejection, and RunScript snippet shape.
17. `tools/probe-cmo-integration.mjs` recommendations mention Build 1868 `dofile(...)` nil and explicit `ScenEdit_RunScript(...)` as the B2 loader model.
18. B0 docs record `dofile(...)` failed and `ScenEdit_RunScript(...)` succeeded.
19. B0.1 docs record the exact user marker `AiAssist_B0RunScript_20260510_0448`.
20. B0.1 docs record return value `Yes`.
21. B0.1 docs do not claim scenario-folder auto-load is proven.
22. B0.1 docs do not recommend `dofile(...)` as a fallback.
23. DB517 closeout doc still records DB517 as complete but now points the next integration path toward RunScript.
24. Template Inspector guide seed does not recommend `dofile`; it recommends `ScenEdit_RunScript('/Folder/File.lua')`.
25. Kimi / Claude / Gemini CURRENT_TASK files all point to B2 planning around the proven CMO Lua-root RunScript model.
26. No `src/**` files changed.
27. No `server/**` files changed.
28. No `public/**` data changed.
29. No `package.json` / `package-lock.json` drift.
30. No backend endpoint, CMO polling, log tailing, sidecar writer, or live read-back was introduced.
31. Main JS remains under `400 kB`.
32. Main CSS remains under `60 kB`.
33. `aiContextPruning` remains under `9 kB`.
34. AI adapter smoke shows no raw Bearer / Authorization / sk-key leakage.

## Regression Watch

Report as regression if any of these are true:

- The tool still writes to scenario folders by default.
- The tool still emits `dofile(...)` as a loader snippet.
- The docs imply CMO scenario-folder `.lua` auto-load is proven.
- The docs imply `ScenEdit_RunScript(...)` performs automatic execution without user action.
- New backend endpoints, log tailing, polling, live read-back, or sidecar writer behavior appears.
- Bundle watch lines are exceeded.
- Auth smoke leaks raw credential material.

## Expected Verdict Format

Please report:

- pipeline results
- bundle sizes
- exact static checkpoint pass/fail count
- whether any source / backend / package drift exists
- final verdict
