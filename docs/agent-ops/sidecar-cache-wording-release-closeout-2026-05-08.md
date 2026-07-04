# Sidecar Cache Wording Release Closeout - 2026-05-08

## Purpose

Close the sidecar cache settings wording patch release as the current public operating baseline.

This release polishes Settings > Storage > Scenario Sidecar Cache so the remaining English index/status/count labels are now compact Korean wording, while preserving the existing sidecar safety and command behavior.

## Release Baseline

- Release tag: `release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`.
- Tagged commit: `f3539f5 Mark sidecar cache wording release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`.
- Release title: `CMO Lua Builder Sidecar Cache Wording Update`.
- Release state: not draft, not prerelease.
- Product wording commit: `2ba77a8 Polish sidecar cache settings wording`.
- Product QA directive commit: `f8f5dc2 Add sidecar cache wording QA directive`.
- Product QA closeout commit: `564da22 Archive sidecar cache wording QA`.
- Release marker commit: `f3539f5 Mark sidecar cache wording release in README`.
- Release QA directive commit: `ed3b760 Add sidecar cache wording release QA directive`.
- Release QA closeout commit: `43d9287 Archive sidecar cache wording release QA`.

## User-Facing Change

- Loading text now says `sidecar 인덱스를 확인하는 중입니다.`
- Successful index timestamp text now says `인덱스 생성 시각`.
- Unknown timestamp fallback now says `알 수 없음`.
- Pending total label now says `인덱스 확인 중`.
- Indexed total label now says `N개 시나리오 인덱싱됨`.
- Count labels now use `내부 컨텍스트 준비`, `메타데이터만`, and `디코더 실패`.

Unchanged:

- Sidecar root hint: `%USERPROFILE%\.codex\cmo-scenario-sidecars`.
- `CMO_SCENARIO_SIDECAR_ROOT` override hint.
- `.scen` not modified wording.
- Sidecar audit/prune/move command rows.
- Manual prompt-copy fallback.
- Lua apply gate: `aiParsedResponse.isPasteReady === true`.

## Verified Pipeline

Kimi independently approved both the product wording change and the release tag / GitHub Release.

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
- Scenario index: `1899`.
- Loader state: `1857 readyWithInternalSidecar`, `42 decoderFailed`, `0` issues.
- Sidecar audit: dry-run only, `3799` protected files, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

## Watch Lines

- Main JS must stay under `400 kB`.
- Main CSS should stay below `60 kB`; a rise above `60 kB` is a regression to inspect.
- `aiContextPruning` must stay under `9 kB` unless Codex explicitly opens a pruning expansion task.
- Sidecar audits must remain dry-run unless the user explicitly asks to prune orphans.
- Generated sidecars remain external/local data, not repository assets.
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

If `npm run verify:release` or `gh` hits `spawn EPERM` / keyring issues inside the sandbox, rerun with approved permissions before treating it as a product regression.

## Next Work Candidates

1. Keep the project in standby until a concrete product change is requested.
2. If Settings / sidecar wording resumes, preserve `.scen` not modified wording and the dry-run-first sidecar command guidance.
3. If scenario UX work resumes, protect the transient temp-cache cleanup invariant.
4. If AI assistant work resumes, protect `isPasteReady`, prompt-copy fallback, parser headings, and context-pruning DBID/GUID anchors.
5. If a new public release is needed, tag the product/docs commit, create the GitHub Release, then ask Kimi for a focused release-tag QA pass.
