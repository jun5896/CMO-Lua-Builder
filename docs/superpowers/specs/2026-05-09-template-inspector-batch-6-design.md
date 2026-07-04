# Template Inspector Annotation Batch 6 Design

## Goal

Increase Template Inspector annotation coverage with a focused complex-event and import safety batch.

## Scope

Modify only `public/template-annotations.json`.

Add annotations for these six templates:

- `event_complex.tpl.lua`
- `event_split_merge.tpl.lua`
- `event_ambient_traffic.tpl.lua`
- `event_scen_loaded.tpl.lua`
- `event_unit_x.tpl.lua`
- `inst_import.tpl.lua`

## Rationale

These templates are high-impact because they can create multi-part events, split or merge units, spawn ambient traffic, run Lua on scenario load, access `ScenEdit_UnitX()`, or import `.inst` files. A bad AI answer can invent trigger options, GUIDs, DBIDs, coordinate bounds, startup side effects, or file paths. The annotations should keep those inputs source-bound and make CMO engine validation explicit.

## Data Contract

Each new annotation must include:

- `title`
- `summary`
- `beginnerNotes`
- `prerequisites`
- `safePattern`
- `aiHint`
- `checks`

The wording must keep CMO as the source of truth for event names, trigger/condition/action options, Side names, GUIDs, DBIDs, coordinate bounds, `.inst` filenames, and import targets. The annotations must not claim CMO engine-tested behavior unless explicitly verified.

## Verification

Use an inline Node check that fails before the six annotations exist and passes after all required keys and fields are present. Then run:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Expected post-build watch lines:

- Main JS under `400 kB`
- Main CSS under `60 kB`
- `aiContextPruning` under `9 kB`

## QA Handoff

After local verification, create a focused Kimi QA directive for Batch 6. Kimi should confirm the JSON-only product scope, coverage increase, complex-event/import safety wording, bundle watch lines, and AI adapter smoke redaction.
