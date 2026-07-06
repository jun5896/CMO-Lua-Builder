# Kimi QA Directive - Template Inspector Batch 6 Closeout Docs

Status: ACTIVE QA REQUEST

## Target

QA target commit:

```text
4474fe9 Document template inspector batch 6 closeout
```

Expected target scope:

- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `docs/agent-ops/template-inspector-batch-6-closeout-2026-05-09.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`
- `handoff/to-kimi/CURRENT_TASK.md`

Expected target stat:

```text
5 files changed, 182 insertions(+)
```

No product code, public data, server, tools, package, or lockfile changes are expected.

## Required Checks

Run/read:

```powershell
git status --short --branch
git show --stat --oneline 4474fe9
git show --name-only --oneline 4474fe9
git diff --check 4474fe9^ 4474fe9
```

No `npm` pipeline is required unless the file scope differs from docs/handoff-only.

## Static Checkpoints

1. Closeout doc exists at `docs/agent-ops/template-inspector-batch-6-closeout-2026-05-09.md`.
2. Closeout doc records current public release `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
3. Closeout doc records planning commit `7bfc27c`.
4. Closeout doc records product/data commit `81d5b66`.
5. Closeout doc records QA directive commit `e89b75e`.
6. Closeout doc records QA archive / agent refresh commit `aec194c`.
7. Closeout doc records the Batch 6 QA archive path.
8. Closeout doc lists all six Batch 6 templates:
   - `event_complex.tpl.lua`
   - `event_split_merge.tpl.lua`
   - `event_ambient_traffic.tpl.lua`
   - `event_scen_loaded.tpl.lua`
   - `event_unit_x.tpl.lua`
   - `inst_import.tpl.lua`
9. Closeout doc records JSON coverage `42 / 51` and `9` missing.
10. Closeout doc records Kimi QA pipeline results: lint PASS, build PASS, smoke PASS.
11. Closeout doc records bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
12. Closeout doc records unchanged invariants: src/server/tools/package unchanged, parser/pruning/adapter/sidecar unchanged.
13. Final stabilization inventory includes Batch 6 closeout after Batch 5 closeout.
14. Kimi / Claude / Gemini `CURRENT_TASK.md` files reference the Batch 6 closeout or Batch 6 approved baseline.
15. Handoff inbox state is clean: Kimi has `_archive/`, `CURRENT_TASK.md`, and this active directive; Claude/Gemini have `_archive/` and `CURRENT_TASK.md`.
16. Target commit does not change `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json`.

## Reporting

Report:

- Pipeline/status commands
- Static checkpoint table
- File-scope summary
- Regression summary
- Final verdict
