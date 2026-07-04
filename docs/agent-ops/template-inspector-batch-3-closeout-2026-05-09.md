# Template Inspector Annotation Batch 3 Closeout - 2026-05-09

## Purpose

Close Template Inspector Annotation Batch 3 as the latest post-release operating baseline.

Batch 3 expands Template Inspector beginner / AI guidance from `18 / 51` annotated resources to `24 / 51`, focusing on templates where invented Side, posture, EMCON, GUID, DBID, Loadout, RP, or coordinate values could cause unsafe or misleading Lua output.

This is not a new public release tag. The current published release remains:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-annotations
```

## Commit Baseline

- Planning commit: `031ad02 Document template inspector batch 3 plan`
- Product/data commit: `4d7208a Add template inspector annotation batch 3`
- Kimi QA directive commit: `08a96bb Add template inspector batch 3 QA directive`
- Kimi QA archive / agent refresh commit: `18689c6 Archive template inspector batch 3 QA`
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-3-qa.md`

## User-Facing Change

Batch 3 adds annotations for six additional templates:

- `side_posture.tpl.lua`
- `event_contact_emcon.tpl.lua`
- `unit_spawn_random.tpl.lua`
- `event_teleport.tpl.lua`
- `event_dbid_score.tpl.lua`
- `event_cargo_drop.tpl.lua`

The new guidance reinforces:

- Side posture is directional and must use real Side / posture values.
- Contact EMCON changes must not invent contact type, posture, or EMCON values.
- Random spawn coordinate bounds must come from the map, not AI guesses.
- Teleport / relocate workflows should prefer GUIDs and map-confirmed coordinate bounds.
- DBID scoring must use Database Viewer sourced DBIDs and unit type checks.
- Cargo drop zones must use existing RP names, with GUID-first unit lookup.

## Verification

Kimi independently approved Batch 3.

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
{ "annotated": 24, "total": 51, "missing": 27, "added": [true, true, true, true, true, true] }
```

## Stable Baseline

- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Template annotations: `24 / 51` resources annotated, `27` missing
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
- Keep CMO API names such as `ScenEdit_*`, `VP_*`, and `World_GetElevation` exact.
- Treat uncertain CMO behavior as requiring CMO engine verification.
- Keep Template Inspector annotations in `public/template-annotations.json` rather than always-loaded React source.

## Agent State

- Kimi: Batch 3 QA approved and archived; standby until Codex opens a new focused directive.
- Claude: no focused parser/pruning/adapter/decoder review opened by this batch.
- Gemini: no separate wording review opened; Batch 3 wording can be reviewed later if Codex opens a focused wording pass.

## Next Work Candidates

1. Ask Kimi for a docs/handoff-only QA pass on this closeout.
2. After closeout QA passes, archive that directive and return all agent inboxes to standby.
3. Continue with Template Inspector Annotation Batch 4, preferably another small `public/template-annotations.json`-only batch.
4. Candidate Batch 4 focus: mission support/cargo/ferry/mine and KeyValue/event guard templates, prioritizing cases where RP names, mission names, or one-shot guards prevent AI invention or repeat-action mistakes.
5. Defer a new public release tag until several post-release annotation batches are accumulated or the user explicitly wants a release cut.
