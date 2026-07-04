# Kimi QA Directive - Template Inspector Batch 5 Closeout Docs

Status: ACTIVE

## Target

QA target commit:

```text
11367cd Document template inspector batch 5 closeout
```

Scope:

- `docs/agent-ops/template-inspector-batch-5-closeout-2026-05-09.md`
- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `handoff/to-kimi/CURRENT_TASK.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`

Do not modify files and do not commit.

## Required Checks

Run:

```powershell
git status --short --branch
git show --stat --oneline 11367cd
git show --name-only --oneline 11367cd
git diff --check 11367cd^ 11367cd
```

This is a docs/handoff-only closeout. Full product pipeline is optional unless scope drift is detected.

## Static Checkpoints

Confirm:

1. Closeout doc exists at `docs/agent-ops/template-inspector-batch-5-closeout-2026-05-09.md`.
2. Closeout doc records current public release remains `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
3. Closeout doc records planning commit `d99e45c`.
4. Closeout doc records product/data commit `a80b9ea`.
5. Closeout doc records QA directive commit `4c40061`.
6. Closeout doc records QA archive / agent refresh commit `d911ebb`.
7. Closeout doc records the six Batch 5 templates:
   - `event_unit_destroyed.tpl.lua`
   - `event_unit_damaged.tpl.lua`
   - `event_missions_toggle.tpl.lua`
   - `event_escalation.tpl.lua`
   - `weather_random.tpl.lua`
   - `event_dynamic_weather.tpl.lua`
8. Closeout doc records JSON coverage `36 / 51` and `15` missing.
9. Closeout doc records Batch 5 Kimi QA pipeline results: lint PASS, build PASS, smoke PASS.
10. Closeout doc records bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
11. Closeout doc preserves invariants: no `src/**`, `server/**`, `tools/**`, package/dependency drift, parser/pruning/adapter/sidecar behavior unchanged.
12. `final-stabilization-change-inventory-2026-05-05.md` includes a Batch 5 closeout section after the Batch 4 closeout section.
13. Kimi / Claude / Gemini `CURRENT_TASK.md` files reference the Batch 5 closeout where appropriate.
14. Handoff inbox state remains clean except this active directive: Kimi has `_archive`, `CURRENT_TASK.md`, and this directive; Claude/Gemini have `_archive` and `CURRENT_TASK.md`.
15. Target commit does not modify `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json`.

## Expected Verdict

If all checkpoints pass:

```text
APPROVED - template inspector batch 5 closeout docs hold.
```
