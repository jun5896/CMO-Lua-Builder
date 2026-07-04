# CMO Integration Probe B0 Closeout - 2026-05-10

## Status

APPROVED / ARCHIVED

## Target

```text
c950ecd Add B0 CMO integration probe
```

Implementation reference:

```text
docs/agent-ops/cmo-integration-probe-b0-2026-05-09.md
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-b0-cmo-integration-probe-qa.md
```

## Kimi Verdict

```text
APPROVED - Track B0 CMO integration probe holds.
Regression: none.
```

Kimi static checkpoints:

```text
34 / 34 PASS
```

## Pipeline

```text
git status --short --branch: clean (main...origin/main)
npm run smoke:cmo-integration-probe: PASS
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

## Approved B0 Capability Matrix

```text
CMO root: PASS
Scenarios root: PASS
Logs root: PASS
Scenario folder write access: PASS by fs.access only
ExceptionLog_*.txt: PASS
LuaHistory_*.txt: WARN, no matching files observed yet
Scenario-folder .lua auto-load: MANUAL, not proven
Safe path prefixes: PASS
```

Observed summary:

```text
6 pass / 1 warn / 0 fail / 1 manual / 0 unknown
```

## Preserved Boundaries

B0 remains a probe only.

It does not:

- Write or delete files.
- Modify `.scen` files.
- Add backend endpoints.
- Tail logs.
- Poll CMO.
- Send AI requests.
- Claim `.lua` auto-load is proven.
- Claim live CMO read-back.
- Claim scenario folder sidecar deployment.

## Next Gate

Track B can continue, but the next step should stay honest about the remaining unknown:

```text
Scenario-folder .lua auto-load is not proven yet.
```

Recommended next slice:

```text
B0.1 disposable scenario .lua load check
```

Follow-up manual result on Build 1868 disproved `dofile(...)`: the CMO console reported `attempt to call a nil value (global 'dofile')`. `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` returned `Yes` and printed the marker. B2 must use explicit `ScenEdit_RunScript(...)` from the CMO Lua root rather than assuming automatic scenario-folder execution or `dofile(...)`.
