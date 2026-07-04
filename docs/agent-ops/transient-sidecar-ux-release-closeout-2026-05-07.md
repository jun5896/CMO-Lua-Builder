# Transient Sidecar UX Release Closeout - 2026-05-07

## Purpose

Close the transient scenario sidecar UX patch release as the current public operating baseline.

This release clarifies what happens when a matching scenario sidecar is missing: the AI adapter can open the `.scen` as a temporary in-memory summary, without modifying the original scenario file and without leaving temporary extraction files behind.

## Release Baseline

- Release tag: `release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`.
- Tagged commit: `ffbd86e Refresh README for transient sidecar UX release`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`.
- Release title: `CMO Lua Builder Transient Sidecar UX Update`.
- Release state: not draft, not prerelease.
- Product UX commit: `8f9641e Clarify transient scenario sidecar UX`.
- Product QA directive commit: `d3fe238 Add transient scenario sidecar UX QA directive`.
- Product QA closeout commit: `a0a52f9 Archive transient scenario sidecar UX QA`.
- Release QA directive commit: `386bf12 Add transient sidecar UX release QA directive`.
- Release QA closeout commit: `175b17a Archive transient sidecar UX release QA`.

## User-Facing Change

- Missing-sidecar status now says the UI will try an AI adapter temporary in-memory open.
- Successful transient open now says summary JSON was generated in memory and temporary files were cleaned.
- Failure wording now points to adapter availability or decoder failure, without implying that `.scen` was changed.
- Scenario inspector guidance now mentions adapter transient open or `prepare:scenario`.
- Existing behavior did not change: `openScenarioTransient(file)`, `adapter://scenario/transient-open`, sidecar loading, prompt-copy fallback, and `isPasteReady` Lua apply gating remain unchanged.

## Verified Pipeline

Kimi independently approved both the product UX change and the release tag / GitHub Release.

The release was verified with:

```powershell
npm run verify:release
npm run smoke:scenario-transient
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

- Main JS: `366.60 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario index: `1899`.
- Loader state: `1857 readyWithInternalSidecar`, `42 decoderFailed`, `0` issues.
- Sidecar audit: dry-run only, `24` orphans / about `5.6 MB`.
- Transient smoke: PASS, in-memory summary returned and `.scenario-extract-cache` remained empty.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

## Watch Lines

- Main JS must stay under `400 kB`.
- Main CSS should stay below `60 kB`; a rise above `60 kB` is a regression to inspect.
- `aiContextPruning` must stay under `9 kB` unless Codex explicitly opens a pruning expansion task.
- Sidecar audits must remain dry-run unless the user explicitly asks to prune orphans.
- Generated sidecars remain external/local data, not repository assets.
- Transient scenario opens must not leave files in `.scenario-extract-cache`.
- Missing-sidecar UX must not imply that original `.scen` files are modified.
- AI Lua apply must remain gated by `aiParsedResponse.isPasteReady === true`.

## Agent State

- Kimi: standby; no active date-stamped directive.
- Claude: standby; review only on focused parser, pruning, adapter, decoder, or always-visible assistant surface signals.
- Gemini: standby; wording review only on focused UI/beginner guidance requests.
- Handoff inboxes: top-level `CURRENT_TASK.md` plus `_archive/` only.

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

For transient sidecar behavior verification, use:

```powershell
npm run smoke:scenario-transient
```

If `npm run verify:release`, `npm run smoke:scenario-transient`, or `gh` hits `spawn EPERM` / keyring issues inside the sandbox, rerun with approved permissions before treating it as a product regression.

## Next Work Candidates

1. Keep the project in standby until a concrete product change is requested.
2. If scenario UX work resumes, protect the `.scen` not modified guarantee and the transient temp-cache cleanup invariant.
3. If AI assistant work resumes, protect `isPasteReady`, prompt-copy fallback, parser headings, and context-pruning DBID/GUID anchors.
4. If UI work resumes, preserve lazy split boundaries and re-run `npm run verify:release`.
5. If a new public release is needed, tag the product/docs commit, create the GitHub Release, then ask Kimi for a focused release-tag QA pass.
