# Kimi QA Directive - Final Protection Group 5 Docs / Agent Handoff Evidence

## Role

Read-only QA / regression monitor / commit-hygiene watcher. Do not edit files and do not commit.

## Scope

Verify final protection group 5:

- Handoff top-level inbox cleanliness
- Archive evidence preservation
- Final stabilization inventory consistency
- Agent role/current-task documents are present
- Docs-only status remains separate from product code validation

## Baseline

Current accepted technical baseline from groups 1-4:

- Main JS: `366.05 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning-*.js`: `8.56 kB`
- Scenario loader: `1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`
- Kimi archived QA files: `41`
- Claude archived review files: `5`
- Active handoff top-level should contain only `CURRENT_TASK.md` plus `_archive` directories, except for this active Group 5 QA directive while it is being verified.

## Pipeline

Docs-only QA should not rerun the full product pipeline unless you see a product-code regression signal.

Run:

```powershell
git status --short
Get-ChildItem -Path handoff\to-kimi,handoff\to-claude,handoff\to-gemini -Force
Get-ChildItem -Path handoff\to-kimi\_archive\2026-05-05,handoff\to-claude\_archive\2026-05-05 -File
```

Optional spot checks:

```powershell
Select-String -Path handoff\README.md -Pattern "CURRENT_TASK|archive|group 4"
Select-String -Path docs\agent-ops\final-stabilization-change-inventory-2026-05-05.md -Pattern "Group 1 status|Group 2 status|Group 3 status|Group 4 status|Group 5"
```

## Checkpoints

1. `handoff/to-kimi` top-level contains only `_archive`, `CURRENT_TASK.md`, and this active Group 5 QA directive.
2. `handoff/to-claude` top-level contains only `_archive` and `CURRENT_TASK.md`.
3. `handoff/to-gemini` top-level contains only `CURRENT_TASK.md` unless a Gemini archive was explicitly created later.
4. No date-stamped one-off QA/review directive remains open at agent top level except this active Group 5 QA directive.
5. `handoff/to-kimi/_archive/2026-05-05/` contains the completed final protection group 1-4 QA handoff files.
6. `handoff/to-claude/_archive/2026-05-05/` contains the completed five context-pruning review directive files.
7. `handoff/README.md` documents active-file policy and archive layout.
8. `handoff/README.md` records final protection group 1-4 handoff archival.
9. `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md` records groups 1-4 as approved for protection staging.
10. `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md` records Group 5 self-verification.
11. Snapshot counts are internally consistent:
    - modified tracked files: `24`
    - untracked files/directories visible to Git: `28`
    - Kimi archived QA files: `41`
    - Claude archived directive files: `5`
12. Evidence docs exist:
    - `docs/agent-ops/context-pruning-phase-3-closeout-2026-05-05.md`
    - `docs/agent-ops/scenario-sidecar-migration-closeout-2026-05-05.md`
    - `docs/agent-ops/next-phase-parallel-plan-2026-05-03.md`
    - `docs/references/scenario-sidecar-cache-policy.md`
13. No generated product data is listed for commit as evidence:
    - `dist/`
    - `.scenario-extract-cache/`
    - project-local `scenario-sidecars/`
    - external `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
14. No commit was created during this QA pass.

## Expected Verdict Format

Return a concise QA report with:

- Status result
- Active inbox table
- Archive evidence table
- Inventory/doc consistency table
- Any blocker or drift
- Final verdict: `APPROVED` or `BLOCKED`
