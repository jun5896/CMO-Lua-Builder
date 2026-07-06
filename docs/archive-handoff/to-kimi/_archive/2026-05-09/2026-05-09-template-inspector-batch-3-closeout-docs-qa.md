# Kimi QA Directive - Template Inspector Batch 3 Closeout Docs

Status: ACTIVE

## Target

QA target commit:

```text
be840ac Document template inspector batch 3 closeout
```

Scope:

- `docs/agent-ops/template-inspector-batch-3-closeout-2026-05-09.md`
- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `handoff/to-kimi/CURRENT_TASK.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`

Do not modify files and do not commit.

## Required Checks

Run:

```powershell
git status --short --branch
git show --stat --oneline be840ac
git show --name-only --oneline be840ac
git diff --check be840ac^ be840ac
```

This is a docs/handoff-only closeout. Full product pipeline is optional unless scope drift is detected.

## Static Checkpoints

Confirm:

1. Closeout doc exists at `docs/agent-ops/template-inspector-batch-3-closeout-2026-05-09.md`.
2. Closeout doc records current public release remains `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
3. Closeout doc records planning commit `031ad02`.
4. Closeout doc records product/data commit `4d7208a`.
5. Closeout doc records QA directive commit `08a96bb`.
6. Closeout doc records QA archive / agent refresh commit `18689c6`.
7. Closeout doc records the six Batch 3 templates:
   - `side_posture.tpl.lua`
   - `event_contact_emcon.tpl.lua`
   - `unit_spawn_random.tpl.lua`
   - `event_teleport.tpl.lua`
   - `event_dbid_score.tpl.lua`
   - `event_cargo_drop.tpl.lua`
8. Closeout doc records JSON coverage `24 / 51` and `27` missing.
9. Closeout doc records Batch 3 Kimi QA pipeline results: lint PASS, build PASS, smoke PASS.
10. Closeout doc records bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
11. Closeout doc preserves invariants: no `src/**`, `server/**`, `tools/**`, package/dependency drift, parser/pruning/adapter/sidecar behavior unchanged.
12. `final-stabilization-change-inventory-2026-05-05.md` includes a Batch 3 closeout section after the post-closeout operating recheck.
13. Kimi / Claude / Gemini `CURRENT_TASK.md` files reference the Batch 3 closeout where appropriate.
14. Handoff inbox state remains clean except this active directive: Kimi has `_archive`, `CURRENT_TASK.md`, and this directive; Claude/Gemini have `_archive` and `CURRENT_TASK.md`.
15. Target commit does not modify `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json`.

## Expected Verdict

If all checkpoints pass:

```text
APPROVED - template inspector batch 3 closeout docs hold.
```
