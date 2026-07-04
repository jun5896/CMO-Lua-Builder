# QA Workflow Release Closeout - 2026-05-07

## Purpose

Close the QA workflow release as the current public operating baseline.

The project now has a single release verification entrypoint:

```powershell
npm run verify:release
```

This command is the preferred final check before release tags, GitHub Releases, and post-release handoff refreshes.

## Release Baseline

- Release tag: `release-2026-05-06-cmo-lua-builder-qa-workflow`.
- Tagged commit: `e5cd403 Mark QA workflow release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-06-cmo-lua-builder-qa-workflow`.
- Release title: `CMO Lua Builder QA Workflow Release`.
- Release state: not draft, not prerelease.
- Release QA closure bookkeeping: `7963e60 Refresh agents after QA workflow release`.
- Closeout document commit: `1b7e603 Document QA workflow release closeout`.
- Agent closeout reference commit: `affc787 Link agents to QA workflow closeout`.
- Stabilization inventory reference commit: `ee77ee9 Record QA workflow release in stabilization inventory`.

## Verified Pipeline

`npm run verify:release` expands to:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

Kimi independently approved the release tag and GitHub Release after Codex created them.

## Stable Baseline

- Main JS: `366.29 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario index: `1899`.
- Loader state: `1857 readyWithInternalSidecar`, `42 decoderFailed`, `0` issues.
- Sidecar audit: dry-run only, `24` orphans / about `5.6 MB`.
- AI adapter smoke: PASS with no raw `Bearer` / `sk-` leakage.
- AI client parser smoke: PASS.

## Watch Lines

- Main JS must stay under `400 kB`.
- Main CSS should stay below `60 kB`; a rise above `60 kB` is a regression to inspect.
- `aiContextPruning` must stay under `9 kB` unless Codex explicitly opens a pruning expansion task.
- Sidecar audits must remain dry-run unless the user explicitly asks to prune orphans.
- Generated sidecars remain external/local data, not repository assets.

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
gh release view <tag> --repo jun5896/CMO-Lua-Builder
```

If the Codex shell cannot see `gh` in `PATH`, use:

```powershell
& "C:\Program Files\GitHub CLI\gh.exe" release view <tag> --repo jun5896/CMO-Lua-Builder
```

If `npm run verify:release` or `gh` hits `spawn EPERM` / keyring issues inside the sandbox, rerun with approved permissions before treating it as a product regression.

## Next Work Candidates

1. Keep the project in standby until a concrete product change is requested.
2. If UI work resumes, preserve lazy split boundaries and re-run `npm run verify:release`.
3. If AI assistant work resumes, protect `isPasteReady`, prompt-copy fallback, parser headings, and context-pruning DBID/GUID anchors.
4. If scenario work resumes, start with sidecar audit and loader verification before touching storage or decoder code.
5. If a new public release is needed, tag the product/docs commit, create the GitHub Release, then ask Kimi for a focused release-tag QA pass.
