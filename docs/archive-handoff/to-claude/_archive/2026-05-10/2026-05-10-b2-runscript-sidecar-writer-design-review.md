# Claude Review Directive - B2 RunScript Sidecar Writer Design

Status: REVIEWED / ARCHIVED
Date: 2026-05-10

## Result

Claude review completed from the Claude workspace:

```text
APPROVED with minor refinements.
Codex may proceed to B2.1 writer-helper implementation.
```

Review memo:

```text
C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B2-RunScript-Sidecar-Writer\b2-runscript-sidecar-writer-review.md
```

## Request

Review the B2 RunScript Sidecar Writer design before Codex implements any writer endpoint or UI controls.

Design references:

```text
docs/superpowers/specs/2026-05-10-b2-runscript-sidecar-writer-design.md
docs/superpowers/plans/2026-05-10-b2-runscript-sidecar-writer.md
docs/agent-ops/b2-runscript-sidecar-writer-planning-2026-05-10.md
```

## Known CMO Facts

- CMO Build 1868 console sandbox reports `dofile(...)` as nil.
- User-run CMO check succeeded with `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')`.
- The marker was `AiAssist_B0RunScript_20260510_0448`.
- CMO returned `Yes`.
- Scenario-folder `.lua` auto-load remains unproven.

## Review Focus

Please review:

1. Whether B2 should use fixed CMO `Lua` root plus `AiAssist` namespace.
2. Whether the endpoint should reject browser-supplied filesystem roots.
3. Whether `dryRun: false` + `confirmWrite: true` is enough as the write confirmation contract.
4. Whether the filename namespace `AiAssist_*.lua` is strict enough.
5. Whether blocking nested `ScenEdit_RunScript` inside saved content is appropriate for the first B2 slice.
6. Whether overwrite rejection is acceptable for B2.1, with backup retention deferred until overwrite exists.
7. Whether the plan misses any CMO runtime or Lua sandbox hazard.
8. Whether Kimi QA checkpoints are sufficient for path traversal, no-overwrite, and no automatic execution.

## Boundaries

- Read-only review only.
- Do not edit `src/**`, `server/**`, `tools/**`, docs, or handoff files.
- Do not commit.
- Do not open CMO or write to the CMO install folder.

## Expected Output

Write one review memo under:

```text
handoff/to-codex/Track-B2-RunScript-Sidecar-Writer/
```

Please include:

- approved / changes requested verdict
- blockers if any
- specific contract edits if needed
- whether Codex can proceed to B2.1 writer-helper implementation
