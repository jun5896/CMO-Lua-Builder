# Template Inspector Search / Filter Release Closeout - 2026-05-09

## Purpose

Close the Template Inspector Search / Filter UX release as the current public operating baseline.

This release promotes Track A1 from an approved post-release operating slice to a published release baseline. Template Inspector now combines full `51 / 51` annotation coverage with first-slice search filters, safety badges, result counts, and a persistent AI draft / CMO engine verification footer.

## Release Baseline

- Release tag: `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Tagged commit: `004325d Mark template inspector search filter release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Release title: `CMO Lua Builder Template Inspector Search Filter UX`.
- Release state: not draft, not prerelease.
- Product UX commit: `5dd1da1 Add template inspector search filter UX`.
- Product QA directive commit: `f84bdf2 Open template inspector search filter QA directive`.
- Product QA archive commit: `9768910 Archive template inspector search filter QA`.
- Product closeout commit: `bd3a5c5 Document template inspector search filter closeout`.
- Product closeout QA directive commit: `5ee2d6a Add template inspector search filter closeout QA directive`.
- Product closeout QA archive commit: `52dfe94 Archive template inspector search filter closeout QA`.
- Release marker commit: `004325d Mark template inspector search filter release in README`.
- Release QA directive commit: `be448f8 Add template inspector search filter release QA directive`.
- Release QA archive commit: `b90d1b9 Archive template inspector search filter release QA`.
- Release QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-search-filter-release-qa.md`.

## User-Facing Change

Template Inspector now supports quick filters:

- `Event`
- `Mission`
- `Unit`
- `DBID / Loadout`
- `RP / Zone`
- `Doctrine / EMCON`
- `KeyValue`

The first slice intentionally excludes noisy or misleading quick filters:

- Standalone `GUID`.
- Standalone `Side`.
- `Engine Test Required`.
- `demo values`.

Template Inspector now shows safety badges:

- `engine test required`
- `needs Side`
- `needs Mission`
- `needs Unit GUID`
- `needs DBID`
- `needs Loadout`
- `needs RP / Zone`
- `affects Side-wide`

Every selected source detail includes:

```text
AI draft. CMO engine verification is still required before execution.
```

Unchanged:

- Manual prompt-copy fallback.
- Lua apply gate: `aiParsedResponse.isPasteReady === true`.
- Parser response contract.
- AI adapter provider routing and secret redaction.
- Context pruning and `aiContextPruning` bundle.
- Scenario sidecar storage, transient open behavior, and sidecar command rows.
- Runtime dependencies, package lockfile, server tools, and public data assets.

## Verified Pipeline

Kimi independently approved the release tag and GitHub Release.

The release was verified with:

```powershell
npm run verify:release
```

Kimi release QA result:

- `git status --short --branch`: clean (`main...origin/main`).
- Tag points at `004325d Mark template inspector search filter release in README`.
- GitHub Release title: `CMO Lua Builder Template Inspector Search Filter UX`.
- Release state: not draft, not prerelease.
- `npm run verify:release`: PASS.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with sanitized HTTP 401 forwarding and no raw `Bearer`, `Authorization`, or `sk-` leakage.
- Static checkpoints: 27 / 27 PASS.
- Regression: none.

## Stable Baseline

- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- `PresetGuide` lazy JS: `33.99 kB`.
- `PresetGuide` lazy CSS: `7.49 kB`.
- Template annotations: `51 / 51` resources annotated, `0` missing.
- Scenario index: `1899`.
- Loader state: `1857 readyWithInternalSidecar`, `42 decoderFailed`, `0` issues.
- Sidecar audit: dry-run only, `3799` protected files, `24` orphans / about `5.6 MB`.

## Watch Lines

- Main JS must stay under `400 kB`.
- Main CSS should stay below `60 kB`.
- `aiContextPruning` must stay under `9 kB` unless Codex explicitly opens a pruning expansion task.
- `PresetGuide` remains a lazy chunk; future Template Inspector UX should stay out of always-visible `index.css` / main JS where practical.
- AI Lua apply must remain gated by `aiParsedResponse.isPasteReady === true`.
- Safety wording must not imply CMO engine-verified behavior unless verified in CMO.

## Agent State

- Kimi: release-tag QA approved and archived; next useful task is docs/handoff-only QA on this release closeout.
- Claude: standby; no focused parser, pruning, adapter, decoder, or always-visible assistant review opened by this release.
- Gemini: standby; no separate wording review opened by this release.
- Handoff inboxes should return to top-level `CURRENT_TASK.md` plus `_archive/` after QA directives are archived.

## Next Work Candidates

1. Ask Kimi for docs/handoff-only QA on this release closeout.
2. After closeout QA passes, archive that directive and return all agent inboxes to standby.
3. Choose the next track:
   - Track A2: AI drafting workflow tightening inside the local Lua editor.
   - Track B0: CMO integration probe before deeper in-game editor integration.
4. Keep release verification anchored on `npm run verify:release`.
