# AI Lua Safety Wording Release Closeout - 2026-05-07

## Purpose

Close the AI Lua safety wording patch release as the current public operating baseline.

This release clarifies that AI-generated Lua applied through the UI is a gated draft, not CMO engine-verified final code.

## Release Baseline

- Release tag: `release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`.
- Tagged commit: `a8e9b66 Refresh README after AI Lua safety wording QA`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`.
- Release title: `CMO Lua Builder AI Lua Safety Wording Update`.
- Release state: not draft, not prerelease.
- Product safety commit: `1260e33 Clarify AI Lua apply safety wording`.
- Release QA directive commit: `e85f004 Add AI Lua safety wording release QA directive`.
- Release QA closeout commit: `eb93f50 Archive AI Lua safety wording release QA`.
- Agent baseline refresh commit: `15bff5d Refresh agent baselines after AI Lua safety release`.

## User-Facing Change

- AI Lua ready state now uses draft-oriented wording such as `초안 준비`.
- Review/chat/apply UI now states `CMO 검증 필요`.
- Working Draft placeholder no longer implies final paste-ready safety.
- Existing parser and apply behavior did not change: Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.

## Verified Pipeline

Kimi independently approved the release tag and GitHub Release after Codex created them.

The release was verified with:

```powershell
npm run verify:release
```

This expands to:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

## Stable Baseline

- Main JS: `366.47 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario index: `1899`.
- Loader state: `1857 readyWithInternalSidecar`, `42 decoderFailed`, `0` issues.
- Sidecar audit: dry-run only, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `sk-` leakage.

## Watch Lines

- Main JS must stay under `400 kB`.
- Main CSS should stay below `60 kB`; a rise above `60 kB` is a regression to inspect.
- `aiContextPruning` must stay under `9 kB` unless Codex explicitly opens a pruning expansion task.
- Sidecar audits must remain dry-run unless the user explicitly asks to prune orphans.
- Generated sidecars remain external/local data, not repository assets.
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

If `npm run verify:release` or `gh` hits `spawn EPERM` / keyring issues inside the sandbox, rerun with approved permissions before treating it as a product regression.

## Next Work Candidates

1. Keep the project in standby until a concrete product change is requested.
2. If AI assistant work resumes, protect `isPasteReady`, prompt-copy fallback, parser headings, and context-pruning DBID/GUID anchors.
3. If UI wording resumes, preserve the "draft until CMO engine verified" language around AI-generated Lua.
4. If scenario work resumes, start with sidecar audit and loader verification before touching storage or decoder code.
5. If a new public release is needed, tag the product/docs commit, create the GitHub Release, then ask Kimi for a focused release-tag QA pass.
