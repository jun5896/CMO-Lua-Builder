# Template Inspector Annotation Batch 5 Closeout - 2026-05-09

## Purpose

Close Template Inspector Annotation Batch 5 as the latest post-release operating baseline.

Batch 5 expands Template Inspector beginner / AI guidance from `30 / 51` annotated resources to `36 / 51`, focusing on event scoring, damage triggers, mission toggles, escalation, and weather templates where invented Side, TargetFilter, DBID, Mission, trigger, posture, doctrine, or weather values could change scenario behavior.

This is not a new public release tag. The current published release remains:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-annotations
```

## Commit Baseline

- Planning commit: `d99e45c Document template inspector batch 5 plan`
- Product/data commit: `a80b9ea Add template inspector annotation batch 5`
- Kimi QA directive commit: `4c40061 Add template inspector batch 5 QA directive`
- Kimi QA archive / agent refresh commit: `d911ebb Archive template inspector batch 5 QA`
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-5-qa.md`

## User-Facing Change

Batch 5 adds annotations for six additional templates:

- `event_unit_destroyed.tpl.lua`
- `event_unit_damaged.tpl.lua`
- `event_missions_toggle.tpl.lua`
- `event_escalation.tpl.lua`
- `weather_random.tpl.lua`
- `event_dynamic_weather.tpl.lua`

The new guidance reinforces:

- UnitDestroyed scoring must use real TargetFilter values, DBID/type IDs, Side names, and repeated scoring review.
- UnitDamaged triggers must use real TargetFilter values, damage threshold review, and repeatable action review.
- Mission toggle events must use real Mission names, Side names, trigger options, and separate activate/deactivate lists.
- Escalation events must preserve posture direction and use real Side/posture/doctrine values.
- Random weather must use bounded ranges and avoid invented extreme values.
- Dynamic weather must use explicit baseline/range values, RegularTime interval review, and CMO engine verification.

## Verification

Kimi independently approved Batch 5.

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
{ "annotated": 36, "total": 51, "missing": 15, "added": [true, true, true, true, true, true] }
```

## Stable Baseline

- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Template annotations: `36 / 51` resources annotated, `15` missing
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

- Kimi: Batch 5 QA approved and archived; next useful task is docs/handoff-only QA on this closeout.
- Claude: no focused parser/pruning/adapter/decoder review opened by this batch.
- Gemini: no separate wording review opened; Batch 5 wording can be reviewed later if Codex opens a focused wording pass.

## Next Work Candidates

1. Ask Kimi for a docs/handoff-only QA pass on this closeout.
2. After closeout QA passes, archive that directive and return all agent inboxes to standby.
3. Continue with Template Inspector Annotation Batch 6 as another small `public/template-annotations.json`-only batch.
4. Candidate Batch 6 focus: remaining event complex/split/ambient/scen-loaded/unit-x/import/loadout templates where ambiguous event actions, split/merge behavior, contact/unit references, or import/loadout values could encourage AI invention.
5. Defer a new public release tag until several post-release annotation batches are accumulated or the user explicitly wants a release cut.
