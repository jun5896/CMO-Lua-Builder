# Template Inspector Annotation Batch 6 Closeout - 2026-05-09

## Purpose

Close Template Inspector Annotation Batch 6 as the latest post-release operating baseline.

Batch 6 expands Template Inspector beginner / AI guidance from `36 / 51` annotated resources to `42 / 51`, focusing on complex event wiring, split/merge operations, ambient traffic spawning, scenario-load startup Lua, `ScenEdit_UnitX()` payload handling, and `.inst` import behavior where invented event options, GUIDs, DBIDs, coordinate bounds, file paths, or Side names could change scenario behavior.

This is not a new public release tag. The current published release remains:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-annotations
```

## Commit Baseline

- Planning commit: `7bfc27c Document template inspector batch 6 plan`
- Product/data commit: `81d5b66 Add template inspector annotation batch 6`
- Kimi QA directive commit: `e89b75e Add template inspector batch 6 QA directive`
- Kimi QA archive / agent refresh commit: `aec194c Archive template inspector batch 6 QA`
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-6-qa.md`

## User-Facing Change

Batch 6 adds annotations for six additional templates:

- `event_complex.tpl.lua`
- `event_split_merge.tpl.lua`
- `event_ambient_traffic.tpl.lua`
- `event_scen_loaded.tpl.lua`
- `event_unit_x.tpl.lua`
- `inst_import.tpl.lua`

The new guidance reinforces:

- Complex events must use real Trigger, Condition, Action, LuaScript type/name/opts from CMO Event Editor or user-provided values.
- Split / merge operations must prefer GUID lookup, warn about selected-unit merge behavior, and require CMO engine testing.
- Ambient traffic spawning must use real Civilian ship DBIDs, explicit coordinate bounds, water-only filter verification, and small spawn-count tests.
- Scenario-loaded events must use idempotent startup behavior, KeyValue guards, and avoid destructive boot actions.
- UnitX events must treat `ScenEdit_UnitX()` payload fields as trigger-specific and validate nil / field presence.
- INST import must use trusted `.inst` filenames, real Side names, DB compatibility checks, and import result verification.

## Verification

Kimi independently approved Batch 6.

Pipeline:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-adapter
```

Result:

- `git status --short --branch`: clean (`main...origin/main`)
- `npm run lint`: PASS
- `npm run build`: PASS
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage

JSON / coverage result:

```json
{ "annotated": 42, "total": 51, "missing": 9, "added": [true, true, true, true, true, true] }
```

## Stable Baseline

- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Template annotations: `42 / 51` resources annotated, `9` missing
- Scenario baseline remains `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`
- AI adapter smoke remains free of raw `Bearer`, `Authorization`, and `sk-` leakage

## Invariants

Unchanged:

- Product source code under `src/**`, `server/**`, and `tools/**`
- `package.json`, `package-lock.json`, and dependencies
- Parser response contract and paste-ready gating
- Context pruning and DBID/GUID preservation
- Provider secret handling and AI adapter redaction
- Scenario sidecar storage and loader behavior
- Current public release tag

Annotation rules preserved:

- Do not claim CMO engine-tested behavior unless explicitly verified.
- Keep CMO API names such as `ScenEdit_*`, `Tool_*`, `VP_*`, and `World_*` exact.
- Treat uncertain CMO behavior as requiring CMO engine verification.
- Keep Template Inspector annotations in `public/template-annotations.json` rather than always-loaded React source.

## Agent State

- Kimi: Batch 6 QA approved and archived; next useful task is docs/handoff-only QA on this closeout.
- Claude: no focused parser/pruning/adapter/decoder review opened by this batch.
- Gemini: no separate wording review opened; Batch 6 wording can be reviewed later if Codex opens a focused wording pass.

## Next Work Candidates

1. Ask Kimi for a docs/handoff-only QA pass on this closeout.
2. After closeout QA passes, archive that directive and return all agent inboxes to standby.
3. Continue with Template Inspector Annotation Batch 7 as another small `public/template-annotations.json`-only batch.
4. Candidate Batch 7 focus: the remaining unannotated templates / presets, especially `event_random_start_weather.tpl.lua`, `loadout_scramble.tpl.lua`, and `mission_generic.tpl.lua`, plus any manifest presets not yet covered.
5. Defer a new public release tag until the remaining annotation coverage is closed or the user explicitly wants a release cut.
