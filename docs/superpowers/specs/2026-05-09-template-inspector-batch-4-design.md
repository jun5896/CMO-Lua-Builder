# Template Inspector Annotation Batch 4 Design

## Goal

Increase Template Inspector annotation coverage with a focused mission / KeyValue guard batch.

## Scope

Modify only `public/template-annotations.json`.

Add annotations for these six templates:

- `mission_support.tpl.lua`
- `mission_cargo.tpl.lua`
- `mission_ferry.tpl.lua`
- `mission_mine.tpl.lua`
- `kvstore_set.tpl.lua`
- `event_kv_flag.tpl.lua`

## Rationale

These templates cover mission creation and one-shot state management. They are beginner-facing but still risky: RP names can be invented, mission type semantics can be misunderstood, cargo DBID/GUID values can be wrong, and KeyValue flags can accidentally make repeatable events fire more than once or never fire again.

## Data Contract

Each new annotation must include:

- `title`
- `summary`
- `beginnerNotes`
- `prerequisites`
- `safePattern`
- `aiHint`
- `checks`

The wording must keep CMO as the source of truth for Side names, Mission names, RP names, cargo DBIDs/GUIDs, and KeyValue keys. The annotations must not claim CMO engine-tested behavior unless explicitly verified.

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

After local verification, create a focused Kimi QA directive for Batch 4. Kimi should confirm the JSON-only product scope, coverage increase, mission/RP/KeyValue safety wording, bundle watch lines, and AI adapter smoke redaction.
