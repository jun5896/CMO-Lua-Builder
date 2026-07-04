# Kimi QA Directive - Template Inspector Annotation Completion Closeout Docs

Status: ACTIVE QA REQUEST

## Target

QA target commit:

```text
77e5393 Document template inspector annotation completion closeout
```

Expected target scope:

- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `docs/agent-ops/template-inspector-annotation-completion-closeout-2026-05-09.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`
- `handoff/to-kimi/CURRENT_TASK.md`

Expected target stat:

```text
5 files changed, 183 insertions(+)
```

No product code, public data, server, tools, package, or lockfile changes are expected.

## Required Checks

Run/read:

```powershell
git status --short --branch
git show --stat --oneline 77e5393
git show --name-only --oneline 77e5393
git diff --check 77e5393^ 77e5393
```

No `npm` pipeline is required unless the file scope differs from docs/handoff-only.

## Static Checkpoints

1. Completion closeout doc exists at `docs/agent-ops/template-inspector-annotation-completion-closeout-2026-05-09.md`.
2. Closeout doc records current public release `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
3. Closeout doc records planning commit `28b0875`.
4. Closeout doc records product/data commit `80a003a`.
5. Closeout doc records QA directive commit `ce0ef6d`.
6. Closeout doc records QA archive / agent refresh commit `af0ed01`.
7. Closeout doc records the Batch 7 QA archive path.
8. Closeout doc lists all nine Batch 7 resources:
   - `event_random_start_weather.tpl.lua`
   - `loadout_scramble.tpl.lua`
   - `mission_generic.tpl.lua`
   - `advanced_ops.lua`
   - `airbase_scramble.lua`
   - `cap_patrol.lua`
   - `multi_file_pack.lua`
   - `quickbattle.lua`
   - `strike_alpha.lua`
9. Closeout doc records JSON coverage `51 / 51` and `0` missing.
10. Closeout doc records Kimi QA pipeline results: lint PASS, build PASS, smoke PASS.
11. Closeout doc records bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
12. Closeout doc records unchanged invariants: src/server/tools/package unchanged, parser/pruning/adapter/sidecar unchanged.
13. Closeout doc records that demo preset values are examples, not scenario-specific truth.
14. Final stabilization inventory includes completion closeout after Batch 6 closeout.
15. Kimi / Claude / Gemini `CURRENT_TASK.md` files reference the completion closeout or `51 / 51` approved baseline.
16. Handoff inbox state is clean: Kimi has `_archive/`, `CURRENT_TASK.md`, and this active directive; Claude/Gemini have `_archive/` and `CURRENT_TASK.md`.
17. Target commit does not change `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json`.

## Reporting

Report:

- Pipeline/status commands
- Static checkpoint table
- File-scope summary
- Regression summary
- Final verdict
