# Template Inspector Annotation Batch 4 Closeout - 2026-05-09

## Purpose

Close Template Inspector Annotation Batch 4 as the latest post-release operating baseline.

Batch 4 expands Template Inspector beginner / AI guidance from `24 / 51` annotated resources to `30 / 51`, focusing on mission support/cargo/ferry/mine workflows and KeyValue/event guard templates where invented Side, RP, Mission, cargo, key, or trigger values could create misleading or repeatedly firing Lua.

This is not a new public release tag. The current published release remains:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-annotations
```

## Commit Baseline

- Planning commit: `f2a2254 Document template inspector batch 4 plan`
- Product/data commit: `ac8949f Add template inspector annotation batch 4`
- Kimi QA directive commit: `306a9d6 Add template inspector batch 4 QA directive`
- Kimi QA archive / agent refresh commit: `d711c63 Archive template inspector batch 4 QA`
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-annotation-batch-4-qa.md`

## User-Facing Change

Batch 4 adds annotations for six additional templates:

- `mission_support.tpl.lua`
- `mission_cargo.tpl.lua`
- `mission_ferry.tpl.lua`
- `mission_mine.tpl.lua`
- `kvstore_set.tpl.lua`
- `event_kv_flag.tpl.lua`

The new guidance reinforces:

- Support missions must use real Side names and CMO-created RP names.
- Cargo missions must use pickup/dropoff RP names and cargo DBID/GUID sources.
- Ferry missions must use embarkation/destination RP names and make one-way direction explicit.
- Mine missions must use real minefield RP names and verify density / mine count values.
- KeyValue writes need intentional key naming to avoid state collisions.
- KeyValue flag events need clear one-shot guard behavior and repeat-action risk notes.

## Verification

Kimi independently approved Batch 4.

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
{ "annotated": 30, "total": 51, "missing": 21, "added": [true, true, true, true, true, true] }
```

## Stable Baseline

- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Template annotations: `30 / 51` resources annotated, `21` missing
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

- Kimi: Batch 4 QA approved and archived; next useful task is docs/handoff-only QA on this closeout.
- Claude: no focused parser/pruning/adapter/decoder review opened by this batch.
- Gemini: no separate wording review opened; Batch 4 wording can be reviewed later if Codex opens a focused wording pass.

## Next Work Candidates

1. Ask Kimi for a docs/handoff-only QA pass on this closeout.
2. After closeout QA passes, archive that directive and return all agent inboxes to standby.
3. Continue with Template Inspector Annotation Batch 5 as another small `public/template-annotations.json`-only batch.
4. Candidate Batch 5 focus: remaining event/action, scoring/message, weather, and utility templates where ambiguous Side, target, score, weather, or special-action values could encourage AI invention.
5. Defer a new public release tag until several post-release annotation batches are accumulated or the user explicitly wants a release cut.
