# Template Inspector Annotation Batch 5 Design

## Goal

Increase Template Inspector annotation coverage with a focused event / weather safety batch.

## Scope

Modify only `public/template-annotations.json`.

Add annotations for these six templates:

- `event_unit_destroyed.tpl.lua`
- `event_unit_damaged.tpl.lua`
- `event_missions_toggle.tpl.lua`
- `event_escalation.tpl.lua`
- `weather_random.tpl.lua`
- `event_dynamic_weather.tpl.lua`

## Rationale

These templates alter scoring, event triggers, mission activation, side posture/doctrine, and weather. They are high-risk for beginners because AI can easily invent Side names, DBIDs, damage thresholds, trigger options, posture values, doctrine fields, or weather ranges. The annotations should make those values explicitly source-bound and keep CMO engine validation visible.

## Data Contract

Each new annotation must include:

- `title`
- `summary`
- `beginnerNotes`
- `prerequisites`
- `safePattern`
- `aiHint`
- `checks`

The wording must keep CMO as the source of truth for Side names, target DBIDs, target type IDs, Mission names, trigger options, posture/doctrine values, and weather ranges. The annotations must not claim CMO engine-tested behavior unless explicitly verified.

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

After local verification, create a focused Kimi QA directive for Batch 5. Kimi should confirm the JSON-only product scope, coverage increase, event/weather safety wording, bundle watch lines, and AI adapter smoke redaction.
