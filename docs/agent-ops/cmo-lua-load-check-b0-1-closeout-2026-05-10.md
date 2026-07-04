# CMO Lua Load Check B0.1 Closeout - 2026-05-10

## Status

APPROVED / ARCHIVED

## Target

```text
67043ca Add B0.1 CMO Lua load check
```

Implementation reference:

```text
docs/agent-ops/cmo-lua-load-check-b0-1-2026-05-10.md
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b0-1-cmo-lua-load-check-qa.md
```

RunScript correction QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b0-1-runscript-loader-correction-qa.md
```

## Kimi Verdict

```text
APPROVED - Track B0.1 CMO Lua load check holds.
Regression: none.
```

Kimi static checkpoints:

```text
40 / 40 PASS
```

RunScript correction verdict:

```text
APPROVED - B0.1 RunScript loader correction holds.
Static checkpoints: 34 / 34 PASS.
Regression: none.
```

## Pipeline

```text
git status --short --branch: clean (main...origin/main)
npm run smoke:cmo-lua-load-check: PASS
npm run lint: PASS
npm run build: PASS
npm run smoke:ai-adapter: PASS, no auth leakage
```

Bundle baseline:

```text
Main JS: 377.99 kB
Main CSS: 59.14 kB
aiContextPruning: 8.56 kB
```

## Approved B0.1 Boundary

B0.1 is approved as a preparation tool only.

Approved behavior:

- `probe:cmo-lua-load-check` command exists.
- `smoke:cmo-lua-load-check` command exists.
- Default execution is dry-run.
- Default dry-run writes no files.
- Revised write mode requires `--cmo-lua-root`, `--write`, and `--yes`.
- File namespace is restricted to `AiAssist_B0*.lua`.
- Generated Lua contains a marker and `print(marker)` only.
- Original loader snippet used `dofile([[...]])`; this was later disproven by the user-run CMO check below.

Preserved constraints:

- No `package-lock.json` drift.
- No new dependency.
- No `src/**` change.
- No `server/**` change.
- No backend endpoint.
- No CMO polling.
- No log tailing.
- No live read-back.
- No AI auto-send.
- No claim that `.lua` auto-load is proven.

## Next Gate

The user-approved manual check is complete.

The manual check should determine:

```text
B2 should use explicit ScenEdit_RunScript(...) from the CMO Lua root.
Scenario-folder auto-load remains unproven.
```

## User Manual Result

User-run CMO check on Build 1868 found:

```text
dofile([[C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\Lua test\AiAssist_B0LoadCheck.lua]])
ERROR: [string "Console"]:1: attempt to call a nil value (global 'dofile')
```

The same error was written to `LuaHistory_2026-05-10.txt`.

Follow-up CMO Lua-root check:

```lua
print(ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua'))
```

CMO output:

```text
AiAssist_B0RunScript_20260510_0448
'Yes'
```

Revised Track B2 implication:

- Scenario-folder auto-load is still not proven.
- `dofile(...)` is not available in the CMO Build 1868 console sandbox.
- Explicit `ScenEdit_RunScript('/AiAssist_B0/<file>.lua')` from the CMO Lua root is proven and should be the safe default for B2.
