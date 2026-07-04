# Kimi QA Directive - Template Inspector Annotation Batch 6

Status: ACTIVE QA REQUEST

## Target

QA target commit:

```text
81d5b66 Add template inspector annotation batch 6
```

Planning commit:

```text
7bfc27c Document template inspector batch 6 plan
```

Scope:

- Product/data file: `public/template-annotations.json`
- No expected changes to `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json`
- Current expected coverage after target commit: `42 / 51` annotated resources, `9` missing

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits sandbox `spawn EPERM`, report it as environment/sandbox and use Codex-provided approved rerun evidence if present.

## Expected Bundle Watch Lines

- Main JS: about `366.67 kB`, must remain `< 400 kB`
- Main CSS: about `58.27 kB`, must remain `< 60 kB`
- `aiContextPruning-*.js`: about `8.56 kB`, must remain `< 9 kB`

## JSON Coverage Check

Verify:

- `public/template-annotations.json` parses successfully.
- `manifest.templates + manifest.presets = 51`.
- `Object.keys(templateAnnotations.templates).length = 42`.
- Missing count is `9`.
- These six Batch 6 keys exist:
  - `event_complex.tpl.lua`
  - `event_split_merge.tpl.lua`
  - `event_ambient_traffic.tpl.lua`
  - `event_scen_loaded.tpl.lua`
  - `event_unit_x.tpl.lua`
  - `inst_import.tpl.lua`

Each new annotation must include:

- `title`
- `summary`
- `beginnerNotes`
- `prerequisites`
- `safePattern`
- `aiHint`
- `checks`

## Static Checkpoints

1. Target commit changes `public/template-annotations.json` only.
2. JSON parses successfully.
3. Coverage increases from `36 / 51` to `42 / 51`.
4. Missing count decreases from `15` to `9`.
5. All six Batch 6 keys exist.
6. All six Batch 6 annotations include the seven required fields.
7. `event_complex.tpl.lua` warns that trigger, condition, action, LuaScript type/name/opts must come from CMO Event Editor or user-provided values, not AI invention.
8. `event_split_merge.tpl.lua` requires GUID-first lookup, warns about selected-unit merge behavior, and recommends CMO engine testing.
9. `event_ambient_traffic.tpl.lua` requires real Civilian ship DBIDs, explicit coordinate bounds, water-only spawn filter verification, and small spawn-count tests.
10. `event_scen_loaded.tpl.lua` warns about startup execution, idempotent KeyValue guard, and avoiding destructive boot actions.
11. `event_unit_x.tpl.lua` warns that `ScenEdit_UnitX()` payload fields are trigger-specific and requires nil/field validation.
12. `inst_import.tpl.lua` requires trusted `.inst` filename/source, real Side name, DB compatibility check, and import result verification.
13. `src/**`, `server/**`, `tools/**`, `package.json`, and `package-lock.json` are unchanged by the target commit.
14. `npm run lint` passes.
15. `npm run build` passes and bundle watch lines remain under limits.
16. `npm run smoke:ai-adapter` passes with no raw `Bearer`, `Authorization`, or `sk-` leakage.
17. Parser, adapter, context pruning, sidecar, prompt-copy fallback, and Lua apply gate behavior remain unchanged.

## Reporting

Report:

- Pipeline results
- Bundle sizes
- JSON coverage result
- Static checkpoint table
- Regression summary
- Final verdict
