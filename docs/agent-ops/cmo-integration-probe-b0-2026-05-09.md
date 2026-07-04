# CMO Integration Probe B0 - 2026-05-09

## Status

OPEN FOR KIMI QA

## Purpose

Track B starts with a fact-finding probe before any in-game integration work.

B0 answers this question:

```text
What can this local CMO installation safely support for future AI assistant integration?
```

This is not an in-game automation feature yet.

## Added Commands

```powershell
npm run probe:cmo-integration
npm run probe:cmo-integration -- --json
npm run smoke:cmo-integration-probe
```

The probe supports:

```text
--cmo-root <path>
--scenarios-root <path>
--logs-root <path>
--scenario-folder <path>
--json
--strict
```

Environment fallbacks:

```text
CMO_ROOT
CMO_SCENARIOS_ROOT
CMO_LOGS_ROOT
```

## Safety Boundary

The B0 probe is dry-run only.

It does not:

- Write files.
- Delete files.
- Modify `.scen` files.
- Create `.lua` files.
- Tail logs.
- Add backend endpoints.
- Start polling.
- Send AI requests.
- Claim CMO Lua execution.
- Claim live CMO read-back.

Write permission is checked only with `fs.access(..., W_OK)`.

## Current Local Probe Result

Command:

```powershell
npm run probe:cmo-integration -- --json
```

Observed summary:

```text
total:   8
passed:  6
warned:  1
failed:  0
manual:  1
unknown: 0
```

Observed roots:

```text
CMO root:        C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations
Scenarios root:  C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios
Logs root:       C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Logs
```

Capabilities:

- PASS: CMO root exists.
- PASS: Scenarios root exists.
- PASS: Logs root exists.
- PASS: Scenario folder write access is available by access check only.
- PASS: `ExceptionLog_*.txt` files exist; 9 files observed.
- WARN: `LuaHistory_*.txt` files not observed yet.
- MANUAL: Scenario-folder `.lua` auto-load behavior still needs a disposable-scenario manual check.
- PASS: Future adapter path prefixes can start from CMO root / Scenarios root / Logs root.

## TDD Evidence

RED:

```text
npm run smoke:cmo-integration-probe
ERR_MODULE_NOT_FOUND: tools/probe-cmo-integration.mjs
```

GREEN:

```text
npm run smoke:cmo-integration-probe
PASS - CMO integration probe contract holds.
```

The smoke uses a temporary fixture CMO root and verifies:

- No files are written by the probe.
- Root detection works.
- Scenario write access check uses access only.
- `ExceptionLog_*.txt` detection works.
- `LuaHistory_*.txt` detection works.
- `.lua` auto-load remains manual.
- Safe path prefixes are reported.
- Argument parsing works.

## Codex Pre-QA Pipeline

```text
npm run smoke:cmo-integration-probe: PASS
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

## Implication for Track B

Track B can proceed to B1/B2 planning after Kimi QA, but B2 must not assume scenario-folder `.lua` auto-load yet.

Recommended next manual fact:

```text
Use a disposable CMO Lua-root marker script to test whether CMO can explicitly execute AiAssist_B0Probe.lua through `ScenEdit_RunScript(...)`.

Follow-up result on Build 1868: `dofile(...)` is nil in the CMO console sandbox, while `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` returned `Yes` and printed the marker. B2 must not use `dofile(...)` as its fallback model.
```

Until that is proven, B2 should prefer an explicit loader snippet model.
