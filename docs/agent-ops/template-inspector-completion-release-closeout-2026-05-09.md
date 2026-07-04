# Template Inspector Completion Release Closeout - 2026-05-09

## Purpose

Close the Template Inspector completion release as the current public operating baseline.

This release promotes the completed Template Inspector annotation set from post-release operating work to a published release baseline. Template Inspector guidance now covers all `51 / 51` builder resources with no missing annotations, while preserving the existing parser, adapter, context-pruning, scenario-sidecar, and Lua apply safety contracts.

## Release Baseline

- Release tag: `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
- Tagged commit: `59bdab9 Mark template inspector completion release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
- Release title: `CMO Lua Builder Template Inspector Completion`.
- Release state: not draft, not prerelease.
- Completion product/data commit: `80a003a Complete template inspector annotations`.
- Completion closeout commit: `77e5393 Document template inspector annotation completion closeout`.
- Completion closeout QA archive commit: `eb9c9b0 Archive template inspector completion closeout QA`.
- Release marker commit: `59bdab9 Mark template inspector completion release in README`.
- Release QA directive commit: `da57221 Add template inspector completion release QA directive`.
- Release QA archive commit: `dbf3f9b Archive template inspector completion release QA`.
- Release QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-completion-release-qa.md`.

## User-Facing Change

Template Inspector annotations now cover all 51 resources.

The final completion release includes guidance for:

- Core templates such as doctrine/EMCON, strike mission, reference point, unit spawn, loadout, and zone operations.
- Event templates for triggers, RegularTime behavior, unit detection, area entry, damage/destroyed scoring, mission toggles, escalation, weather, KeyValue flags, UnitX payloads, and scenario-loaded guards.
- Mission templates for support, cargo, ferry, mine, and generic mission creation.
- Advanced presets such as advanced operations, airbase scramble, CAP patrol, multi-file output, quick battle, and strike alpha.

The guidance reinforces:

- Side, Mission, Unit, RP, Zone, DBID, Loadout ID, GUID, posture, doctrine, EMCON, trigger option, coordinate, weather, and `.inst` values must come from CMO, Database Viewer, or user-confirmed context.
- Demo preset values are examples only and must not be treated as scenario-specific truth.
- CMO engine verification is still required after AI-assisted Lua drafting.
- Exact CMO API names such as `ScenEdit_*`, `Tool_*`, `VP_*`, and `World_*` must remain unchanged.
- Uncertain CMO behavior should be documented as requiring verification rather than presented as fact.

Unchanged:

- Product source code under `src/**`, `server/**`, and `tools/**`.
- `package.json`, `package-lock.json`, and runtime dependencies.
- Parser response contract and paste-ready gating.
- Context pruning and DBID/GUID preservation.
- Provider secret handling and AI adapter redaction.
- Scenario sidecar storage and loader behavior.

## Verified Pipeline

Kimi independently approved the completion release tag and GitHub Release.

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

Kimi release QA result:

- `git status --short --branch`: clean (`main...origin/main`).
- Tag points at `59bdab9 Mark template inspector completion release in README`.
- GitHub Release title: `CMO Lua Builder Template Inspector Completion`.
- Release state: not draft, not prerelease.
- `npm run verify:release`: PASS.
- AI adapter smoke: PASS with no raw `Bearer`, `Authorization`, or `sk-` leakage.
- Static checkpoints: 20 / 20 PASS.
- Regression: none.

## Stable Baseline

- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Template annotations: `51 / 51` resources annotated, `0` missing.
- Scenario index: `1899`.
- Loader state: `1857 readyWithInternalSidecar`, `42 decoderFailed`, `0` issues.
- Sidecar audit: dry-run only, `3799` protected files, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer`, `Authorization`, or `sk-` leakage.

## Watch Lines

- Main JS must stay under `400 kB`.
- Main CSS should stay below `60 kB`; a rise above `60 kB` is a regression to inspect.
- `aiContextPruning` must stay under `9 kB` unless Codex explicitly opens a pruning expansion task.
- Template annotations should remain in `public/template-annotations.json` or other data/lazy assets, not always-loaded React source.
- Annotation wording must not imply CMO engine-tested behavior unless Codex/user has verified it.
- DBID, Loadout ID, GUID, Side, Mission, RP, Zone, posture, doctrine, EMCON, coordinate, and weather claims must remain source-anchored.
- AI Lua apply must remain gated by `aiParsedResponse.isPasteReady === true`.

## Agent State

- Kimi: release-tag QA approved and archived; next useful task is docs/handoff-only QA on this release closeout.
- Claude: standby; no focused parser, pruning, adapter, decoder, or always-visible assistant review opened by this release.
- Gemini: standby; no separate wording review opened by this release.
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

1. Ask Kimi for a docs/handoff-only QA pass on this release closeout.
2. After closeout QA passes, archive that directive and return all agent inboxes to standby.
3. Keep the project in stable maintenance unless the user opens a concrete UI, parser, sidecar, provider, or Template Inspector follow-up.
4. If Template Inspector annotations resume, treat future work as wording refinement, search/filter UX, or localization polish rather than coverage expansion.
5. If a new public release is needed, tag the chosen commit, create GitHub Release notes, then ask Kimi for focused release-tag QA.
