# Kimi QA Directive - Track B0 CMO Integration Probe

## Target

```text
Track B0 CMO Integration Probe
```

Target files:

```text
package.json
tools/probe-cmo-integration.mjs
tools/verify-cmo-integration-probe-contract.mjs
docs/agent-ops/cmo-integration-probe-b0-2026-05-09.md
docs/superpowers/plans/2026-05-09-cmo-integration-probe.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-kimi/CURRENT_TASK.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
```

## Scope

Verify that Codex opened Track B0 as a read-only local CMO capability probe.

This QA should not treat B0 as in-game integration.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:cmo-integration-probe
npm run lint
npm run build
npm run smoke:ai-adapter
```

Optional local observation:

```powershell
npm run probe:cmo-integration -- --json
```

## Expected Codex Evidence

TDD:

- RED: `npm run smoke:cmo-integration-probe` failed before implementation because `tools/probe-cmo-integration.mjs` was missing.
- GREEN: `npm run smoke:cmo-integration-probe` passed after implementation.

Local probe:

- `npm run probe:cmo-integration -- --json`: ran successfully.
- Summary: `6 pass / 1 warn / 0 fail / 1 manual / 0 unknown`.
- CMO root, Scenarios root, Logs root, scenario write-access check, ExceptionLog pattern, and safe path prefixes passed.
- `LuaHistory_*.txt`: WARN because no matching files were observed yet.
- Scenario-folder `.lua` auto-load: MANUAL, not proven.

## Static Checkpoints

1. `package.json` adds `probe:cmo-integration`.
2. `package.json` adds `smoke:cmo-integration-probe`.
3. `package.json` does not silently expand `verify:release` for B0.
4. `package-lock.json` is unchanged.
5. No new dependency or devDependency is added.
6. `tools/probe-cmo-integration.mjs` exists.
7. `tools/probe-cmo-integration.mjs` exports `parseProbeArgs`, `runCmoIntegrationProbe`, and `formatProbeReport`.
8. Probe supports `--cmo-root`, `--scenarios-root`, `--logs-root`, `--scenario-folder`, `--json`, and `--strict`.
9. Probe supports `CMO_ROOT`, `CMO_SCENARIOS_ROOT`, and `CMO_LOGS_ROOT` environment fallbacks.
10. Probe checks CMO root existence.
11. Probe checks Scenarios root existence.
12. Probe checks Logs root existence.
13. Probe checks scenario write capability using access-only behavior, not a write test.
14. Probe checks `ExceptionLog_*.txt` file patterns.
15. Probe checks `LuaHistory_*.txt` file patterns.
16. Probe reports scenario-folder `.lua` auto-load as manual / not proven.
17. Probe reports future safe path prefixes.
18. Probe does not call `writeFile`, `appendFile`, `rm`, `unlink`, `rename`, or `watch`.
19. Probe does not add server endpoints.
20. Probe does not tail logs, poll CMO, or send AI requests.
21. Smoke test creates a temporary fixture CMO root.
22. Smoke test verifies no files are written by comparing before/after fixture files.
23. Smoke test verifies ExceptionLog and LuaHistory detection.
24. Smoke test verifies missing-root behavior.
25. Documentation records B0 as dry-run only.
26. Documentation records current local probe summary.
27. Documentation records `.lua` auto-load as manual pending fact.
28. Handoff state opens only this Kimi QA directive; Claude/Gemini remain standby.
29. Product source UI under `src/**` is unchanged.
30. `server/**` is unchanged.
31. Main JS remains < 400 kB.
32. Main CSS remains < 60 kB.
33. `aiContextPruning` remains < 9 kB.
34. AI adapter smoke reports no raw Bearer / Authorization / `sk-` leakage.

## Regression Watch

Report any of these as blockers:

- Any actual file write/delete in the probe.
- Any backend endpoint added before B0 is approved.
- Any wording implying CMO `.lua` auto-load is already proven.
- Any credential or storage persistence change.
- Main CSS crossing 60 kB.
- `aiContextPruning` crossing 9 kB.
