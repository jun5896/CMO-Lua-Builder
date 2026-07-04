# Template Inspector Annotation Batch 7 Design

## Goal

Complete Template Inspector annotation coverage by documenting the final three templates and six presets.

## Scope

Modify only `public/template-annotations.json`.

Add annotations for these nine resources:

- `event_random_start_weather.tpl.lua`
- `loadout_scramble.tpl.lua`
- `mission_generic.tpl.lua`
- `advanced_ops.lua`
- `airbase_scramble.lua`
- `cap_patrol.lua`
- `multi_file_pack.lua`
- `quickbattle.lua`
- `strike_alpha.lua`

## Rationale

Batch 7 closes the remaining annotation gap from `42 / 51` to `51 / 51`. The remaining resources mix high-risk startup weather, loadout / launch behavior, generic mission creation, and presets that bundle multiple Side, RP, DBID, event, mission, weather, or import assumptions. The annotations should make those assumptions explicit and keep AI-generated guidance source-bound.

## Data Contract

Each new annotation must include:

- `title`
- `summary`
- `beginnerNotes`
- `prerequisites`
- `safePattern`
- `aiHint`
- `checks`

The wording must keep CMO as the source of truth for Side names, DBID / Loadout ID values, base names, mission names, RP names, trigger options, posture/doctrine values, weather ranges, and `.inst` filenames. Preset annotations should clearly warn that demo values are examples and must be replaced with scenario-specific values before use.

## Verification

Use an inline Node check that fails before the nine annotations exist and passes after all required keys and fields are present. Then run:

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

After local verification, create a focused Kimi QA directive for Batch 7. Kimi should confirm JSON-only product scope, complete `51 / 51` coverage, preset safety wording, bundle watch lines, and AI adapter smoke redaction.
