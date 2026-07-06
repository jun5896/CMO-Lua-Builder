# Kimi QA Directive - Track B0.1 CMO Lua Load Check

## Target

```text
Track B0.1 CMO Lua Load Check
```

Target files:

```text
package.json
tools/prepare-cmo-lua-load-check.mjs
tools/verify-cmo-lua-load-check-contract.mjs
docs/agent-ops/cmo-lua-load-check-b0-1-2026-05-10.md
docs/superpowers/plans/2026-05-10-cmo-lua-load-check.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-kimi/CURRENT_TASK.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
```

## Scope

Verify that Codex added B0.1 as a safe preparation step for a disposable CMO scenario `.lua` load check.

This is not in-game automation yet.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:cmo-lua-load-check
npm run lint
npm run build
npm run smoke:ai-adapter
```

Optional dry-run:

```powershell
npm run probe:cmo-lua-load-check -- --json
```

## Expected Codex Evidence

- TDD RED: `npm run smoke:cmo-lua-load-check` failed because `tools/prepare-cmo-lua-load-check.mjs` was missing.
- TDD GREEN: `npm run smoke:cmo-lua-load-check` PASS.
- Dry-run: `npm run probe:cmo-lua-load-check -- --json` PASS.
- Dry-run result includes `mode: dry-run`, `wroteFile: false`, `fileName: AiAssist_B0LoadCheck.lua`.
- Loader snippet shape: `dofile([[<scenario-folder>\AiAssist_B0LoadCheck.lua]])`.
- Generated Lua prints a marker only.

## Static Checkpoints

1. `package.json` adds `probe:cmo-lua-load-check`.
2. `package.json` adds `smoke:cmo-lua-load-check`.
3. `verify:release` is not expanded for B0.1 yet.
4. `package-lock.json` is unchanged.
5. No dependency or devDependency is added.
6. `tools/prepare-cmo-lua-load-check.mjs` exists.
7. `tools/verify-cmo-lua-load-check-contract.mjs` exists.
8. Tool exports `buildLuaLoadCheck`, `parseLoadCheckArgs`, and `runLuaLoadCheck`.
9. Tool supports `--scenario-folder`, `--file-name`, `--marker`, `--write`, `--yes`, `--overwrite`, and `--json`.
10. Default file name is `AiAssist_B0LoadCheck.lua`.
11. File name namespace is restricted to `AiAssist_B0*.lua`.
12. Default run is dry-run.
13. Default dry-run writes no files.
14. Write requires `--scenario-folder`.
15. Write requires `--write`.
16. Write requires `--yes`.
17. Existing file is not overwritten unless `--overwrite`.
18. Generated Lua contains a marker and `print(marker)`.
19. Generated Lua does not call `ScenEdit_SetKeyValue`.
20. Generated Lua does not call `os.*`.
21. Generated Lua does not call `io.*`.
22. Generated Lua does not call `require`.
23. Generated Lua does not contain file write/delete APIs.
24. Loader snippet uses `dofile([[...]])`.
25. Documentation says auto-load is not proven.
26. Documentation says disposable/test scenario only.
27. Documentation says B2 must keep explicit loader snippet as safe default until manual CMO check is complete.
28. Smoke test verifies before/after no default write.
29. Smoke test verifies `--write --yes` writes one fixture file.
30. Smoke test verifies missing `--yes` blocks writing.
31. Smoke test verifies no overwrite by default.
32. Smoke test verifies unsafe file names are rejected.
33. No `src/**` changes.
34. No `server/**` changes.
35. No backend endpoint added.
36. No CMO polling, log tailing, live read-back, or AI auto-send added.
37. Main JS < 400 kB.
38. Main CSS < 60 kB.
39. `aiContextPruning` < 9 kB.
40. AI adapter smoke reports no raw Bearer / Authorization / `sk-` leakage.

## Regression Watch

Report any of these as blockers:

- Any default write behavior.
- Any generated Lua scenario-state mutation.
- Any wording implying `.lua` auto-load is already proven.
- Any backend endpoint or polling behavior.
- Any credential/storage persistence change.
- Main CSS crossing 60 kB.
