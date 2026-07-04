# CMO Lua Load Check B0.1 - 2026-05-10

## Status

OPEN FOR KIMI QA

## Purpose

B0 approved the local CMO environment probe, but one critical fact remains unresolved:

```text
Does CMO auto-load .lua files placed in a scenario folder, or should Track B use explicit ScenEdit_RunScript(...)?
```

B0.1 adds a safe preparation tool for that manual disposable-scenario check.

This is not CMO automation yet. It only prepares a harmless load-check file and instructions.

## Added Commands

```powershell
npm run probe:cmo-lua-load-check
npm run probe:cmo-lua-load-check -- --json
npm run smoke:cmo-lua-load-check
```

## Safety Boundary

Default mode is dry-run.

The tool writes only when all of these are provided:

```text
--cmo-lua-root <path>
--write
--yes
```

Write target is restricted to a safe CMO Lua-root subfolder:

```text
<CMO Lua root>\AiAssist_B0*\AiAssist_B0*.lua
```

The default file is:

```text
AiAssist_B0LoadCheck.lua
```

The generated Lua is intentionally harmless:

```lua
-- AiAssist B0.1 disposable Lua load check.
-- Harmless by design: prints a marker only; no scenario state is modified.
local marker = 'AiAssist_B0LoadCheck_<timestamp>'
print(marker)
```

It does not call:

- `ScenEdit_SetKeyValue`.
- `os.*`.
- `io.*`.
- `require`.
- file write/delete APIs.

## Dry-Run Evidence

Command:

```powershell
npm run probe:cmo-lua-load-check -- --json
```

Observed:

```text
mode: dry-run
wroteFile: false
fileName: AiAssist_B0LoadCheck.lua
loaderSnippet: ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')
luaAutoLoadProven: false
mutatesScenarioState: false
```

Manual check remains pending until the user runs CMO with a disposable scenario.

## TDD Evidence

RED:

```text
npm run smoke:cmo-lua-load-check
ERR_MODULE_NOT_FOUND: tools/prepare-cmo-lua-load-check.mjs
```

GREEN:

```text
npm run smoke:cmo-lua-load-check
PASS - CMO Lua load-check contract holds.
```

The smoke verifies:

- Default run writes no files.
- `--write` without `--yes` stays blocked.
- `--write --yes --cmo-lua-root <fixture>` writes exactly one file under `AiAssist_B0`.
- Re-run without `--overwrite` fails.
- Unsafe file names are rejected.
- Generated Lua prints a marker only.
- Loader snippet uses `ScenEdit_RunScript('/AiAssist_B0/...')`.

## Codex Pre-QA Pipeline

```text
npm run smoke:cmo-lua-load-check: PASS
npm run lint: PASS
npm run build: PASS
npm run smoke:ai-adapter: PASS
```

Build baseline:

```text
Main JS: 377.99 kB
Main CSS: 59.14 kB
aiContextPruning: 8.56 kB
```

AI adapter smoke:

```text
PASS - no raw Bearer / Authorization / sk- leakage.
```

## Manual CMO Step After QA

After Kimi approves B0.1, use a disposable CMO Lua-root folder and run either:

```powershell
npm run probe:cmo-lua-load-check -- --cmo-lua-root "<CMO install>\Lua" --write --yes
```

Then in CMO:

1. Run the printed `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` snippet.
2. Check Lua console or `LuaHistory_*.txt` for the marker.
3. Treat scenario-folder auto-load as unproven unless a separate automatic marker appears before any explicit script call.

## Manual Result

User-run CMO check on Build 1868 produced:

```text
dofile([[C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\Lua test\AiAssist_B0LoadCheck.lua]])
ERROR: [string "Console"]:1: attempt to call a nil value (global 'dofile')
```

The CMO `LuaHistory_2026-05-10.txt` log recorded the same error.

The follow-up CMO Lua-root check succeeded:

```lua
print(ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua'))
```

CMO output:

```text
AiAssist_B0RunScript_20260510_0448
'Yes'
```

## Track B Implication

Until the manual marker check is complete:

- B2 must not assume automatic scenario-folder `.lua` execution.
- B2 must not use `dofile(...)` as a fallback; CMO Build 1868 reports it as nil in the console sandbox.
- B2 should use explicit `ScenEdit_RunScript('/AiAssist_B0/<file>.lua')` from the CMO Lua root as the safe default.
