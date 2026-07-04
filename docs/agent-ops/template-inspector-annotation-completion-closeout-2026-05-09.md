# Template Inspector Annotation Completion Closeout - 2026-05-09

## Purpose

Close the Template Inspector annotation expansion as a complete `51 / 51` coverage baseline.

Batch 7 expands Template Inspector beginner / AI guidance from `42 / 51` annotated resources to `51 / 51`, closing the remaining three templates and six presets. The final batch focuses on startup weather, loadout scramble, generic mission fallback, and demo presets where example Side names, DBIDs, Loadout IDs, RP names, coordinates, trigger options, multi-file paths, weather ranges, or `.inst` filenames must not be treated as scenario-specific truth.

This is not a new public release tag. The current published release remains:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-annotations
```

## Commit Baseline

- Planning commit: `28b0875 Document template inspector batch 7 plan`
- Product/data commit: `80a003a Complete template inspector annotations`
- Kimi QA directive commit: `ce0ef6d Add template inspector batch 7 QA directive`
- Kimi QA archive / agent refresh commit: `af0ed01 Archive template inspector batch 7 QA`
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-7-qa.md`

## User-Facing Change

Batch 7 adds annotations for the final nine resources:

- `event_random_start_weather.tpl.lua`
- `loadout_scramble.tpl.lua`
- `mission_generic.tpl.lua`
- `advanced_ops.lua`
- `airbase_scramble.lua`
- `cap_patrol.lua`
- `multi_file_pack.lua`
- `quickbattle.lua`
- `strike_alpha.lua`

The new guidance reinforces:

- Random-start weather must use a one-shot RegularTime / KeyValue guard, bounded weather ranges, and a real player Side message target.
- Loadout scramble must use real aircraft DBID, Loadout ID, host base, optional Mission, and launch behavior validation.
- Generic Mission fallback must use CMO-valid mission kind/subtype values and follow-up mission-specific settings.
- Advanced Operations and Strike Alpha presets contain demo Side, RP, DBID, weapon, coordinate, event, weather, and `.inst` values that must be replaced with scenario-specific values.
- Airbase Scramble must validate UnitDetected trigger values, interceptor DBID/loadout/base, repeated scramble risk, and immediate launch behavior.
- CAP Patrol must validate RP box coordinates, CAP aircraft DBID, patrol zone RP names, and one-third rule behavior.
- Multi-file Pack must validate output deployment, side-file naming, and `ScenEdit_RunScript` paths.
- Quick Battle must treat DB3K_516 DBIDs and randomized coordinates as examples with replay variability.

## Verification

Kimi independently approved Batch 7.

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
{ "annotated": 51, "total": 51, "missing": 0, "added": [true, true, true, true, true, true, true, true, true] }
```

## Stable Baseline

- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Template annotations: `51 / 51` resources annotated, `0` missing
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
- Treat demo preset values as examples, not scenario-specific truth.
- Keep Template Inspector annotations in `public/template-annotations.json` rather than always-loaded React source.

## Agent State

- Kimi: Batch 7 QA approved and archived; next useful task is docs/handoff-only QA on this completion closeout.
- Claude: no focused parser/pruning/adapter/decoder review opened by this batch.
- Gemini: no separate wording review opened; completion wording can be reviewed later if Codex opens a focused wording pass.

## Next Work Candidates

1. Ask Kimi for a docs/handoff-only QA pass on this completion closeout.
2. After closeout QA passes, archive that directive and return all agent inboxes to standby.
3. Decide whether to cut a new public release tag for the `51 / 51` Template Inspector completion baseline.
4. If cutting a release, run `npm run verify:release`, update README release line/baseline, tag the chosen commit, create GitHub Release notes, then ask Kimi for release-tag QA.
