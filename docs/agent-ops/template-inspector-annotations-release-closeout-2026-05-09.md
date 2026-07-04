# Template Inspector Annotations Release Closeout - 2026-05-09

## Purpose

Close the Template Inspector annotation release as the current public operating baseline.

This release expands beginner-facing Template Inspector guidance from `8 / 51` annotated builder resources to `18 / 51`, adding safety notes for core Lua templates and event/action templates without changing product code, parser behavior, provider behavior, or bundle structure.

## Release Baseline

- Release tag: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Tagged commit: `f46385b Mark template inspector annotation release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Release title: `CMO Lua Builder Template Inspector Annotation Update`.
- Release state: not draft, not prerelease.
- Batch 1 product commit: `05fd836 Add core template inspector annotations`.
- Batch 1 QA directive commit: `ecc1964 Add template annotation coverage QA directive`.
- Batch 1 QA closeout commit: `350a515 Archive template annotation coverage QA`.
- Batch 2 product commit: `246c175 Add event template inspector annotations`.
- Batch 2 QA directive commit: `8618dee Add template annotation batch 2 QA directive`.
- Batch 2 QA closeout commit: `6d553b7 Archive template annotation batch 2 QA`.
- Release marker commit: `f46385b Mark template inspector annotation release in README`.
- Release QA directive commit: `1c8fd88 Add template inspector annotations release QA directive`.
- Release QA closeout commit: `d85ea78 Archive template inspector annotations release QA`.
- Agent baseline refresh commit: `1d15092 Refresh agents after template inspector release QA`.

## User-Facing Change

Template Inspector annotations now cover 10 additional high-value templates:

- `doctrine_emcon.tpl.lua`
- `mission_strike.tpl.lua`
- `reference_point_add.tpl.lua`
- `unit_spawn.tpl.lua`
- `event_simple.tpl.lua`
- `event_regular_time.tpl.lua`
- `event_unit_detected.tpl.lua`
- `event_unit_enters_area.tpl.lua`
- `loadout_set.tpl.lua`
- `zone_add.tpl.lua`

The annotations reinforce:

- CMO engine validation is still required after AI-assisted Lua drafting.
- Side, Mission, Unit, RP, Zone, DBID, Loadout ID, and GUID values must come from CMO or user-confirmed context, not invention.
- Event Trigger and LuaScript Action concepts remain separate.
- Repeating time events need duplicate-action guards.
- Detector side, target filters, target type, and MCL values should be verified instead of guessed.
- RP coordinates and Zone names should be user/CMO supplied.
- Loadout IDs and platform DBIDs should come from the scenario database viewer.

Unchanged:

- Product source code under `src/**`, `server/**`, and `tools/**`.
- `package.json`, `package-lock.json`, and runtime dependencies.
- Parser response contract and paste-ready gating.
- Context pruning and DBID/GUID preservation.
- Provider secret handling and AI adapter redaction.
- Scenario sidecar storage and loader behavior.

## Verified Pipeline

Kimi independently approved both annotation batches and the release tag / GitHub Release.

The release was verified with:

```powershell
npm run verify:release
```

`npm run verify:release` expands to:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

## Stable Baseline

- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Template annotations: `18 / 51` resources annotated, `33` missing.
- Scenario index: `1899`.
- Loader state: `1857 readyWithInternalSidecar`, `42 decoderFailed`, `0` issues.
- Sidecar audit: dry-run only, `3799` protected files, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

## Watch Lines

- Main JS must stay under `400 kB`.
- Main CSS should stay below `60 kB`; a rise above `60 kB` is a regression to inspect.
- `aiContextPruning` must stay under `9 kB` unless Codex explicitly opens a pruning expansion task.
- Template annotations should remain in `public/template-annotations.json` instead of inflating always-loaded React source.
- Annotation wording must not imply CMO engine-tested behavior unless Codex/user has verified it.
- DBID, Loadout ID, GUID, Side, Mission, RP, and Zone claims must remain source-anchored.
- AI Lua apply must remain gated by `aiParsedResponse.isPasteReady === true`.

## Agent State

- Kimi: standby except when Codex opens a focused QA directive.
- Claude: standby; review only on focused parser, pruning, adapter, decoder, or always-visible assistant surface signals.
- Gemini: standby; wording review only on focused UI/beginner guidance requests.
- Handoff inboxes should return to top-level `CURRENT_TASK.md` plus `_archive/` after QA directives are archived.

## Operational Rule

For release candidates, use:

```powershell
git status --short --branch
npm run verify:release
git tag --points-at HEAD
```

For GitHub Release verification, use:

```powershell
& "C:\Program Files\GitHub CLI\gh.exe" release view <tag> --repo jun5896/CMO-Lua-Builder
```

If `npm run verify:release` or `gh` hits `spawn EPERM` / keyring issues inside the sandbox, rerun with approved permissions before treating it as a product regression.

## Next Work Candidates

1. Run focused closeout-docs QA for this document and the agent handoff references.
2. Continue annotation coverage in small batches, keeping each batch in `public/template-annotations.json` only.
3. Prioritize remaining templates that can prevent CMO identifier invention or event/trigger confusion.
4. If Template Inspector wording resumes, preserve exact CMO API names and mark uncertain behavior as needing Codex/user verification.
5. If a new public release is needed, tag the product/docs commit, create the GitHub Release, then ask Kimi for a focused release-tag QA pass.
