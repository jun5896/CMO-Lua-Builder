# Template Inspector Annotation Batch 3 Design

## Goal

Increase Template Inspector annotation coverage with a focused safety batch for templates where users can easily provide unsafe or invented identifiers.

## Scope

Modify only `public/template-annotations.json`.

Add annotations for these six templates:

- `side_posture.tpl.lua`
- `event_contact_emcon.tpl.lua`
- `unit_spawn_random.tpl.lua`
- `event_teleport.tpl.lua`
- `event_dbid_score.tpl.lua`
- `event_cargo_drop.tpl.lua`

## Rationale

These templates touch high-risk values: side posture codes, EMCON state, contact posture, DBID scoring, random coordinates, unit GUIDs, and cargo unload actions. The annotation text should steer users and AI assistants toward source-anchored values, ask-back behavior, and CMO engine verification.

## Data Contract

Each new template annotation must include:

- `title`
- `summary`
- `beginnerNotes`
- `prerequisites`
- `safePattern`
- `aiHint`
- `checks`

The annotations must not claim that generated Lua is engine-verified. They should preserve the established wording pattern: CMO UI or Database Viewer as the source of truth, no invented Side/RP/GUID/DBID values, and CMO engine testing required for risky behavior.

## Verification

Run an inline Node check that fails before the batch exists and passes after all six keys are present with required fields. Then run:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Expected watch lines after build:

- Main JS under `400 kB`
- Main CSS under `60 kB`
- `aiContextPruning` under `9 kB`

## QA Handoff

After local verification, create a focused Kimi QA directive for Batch 3. The directive should ask Kimi to confirm the file-only scope, annotation coverage increase, static safety wording, bundle watch lines, and AI adapter smoke redaction.
