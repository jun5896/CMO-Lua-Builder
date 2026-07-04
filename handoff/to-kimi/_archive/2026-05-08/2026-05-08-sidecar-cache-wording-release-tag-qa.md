# Kimi QA Directive - Sidecar Cache Wording Release Tag

Status: APPROVED / ARCHIVED

## Purpose

Verify that the sidecar cache settings wording release tag and GitHub Release match the accepted QA baseline. This is a read-only release-tag verification pass.

## Release Target

Expected release tag:

```text
release-2026-05-08-cmo-lua-builder-sidecar-cache-wording
```

Expected tagged commit:

```text
f3539f5 Mark sidecar cache wording release in README
```

Product wording commit:

```text
2ba77a8 Polish sidecar cache settings wording
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-08-cmo-lua-builder-sidecar-cache-wording
```

Expected release title:

```text
CMO Lua Builder Sidecar Cache Wording Update
```

## Boundaries

- Do not edit files.
- Do not commit.
- Do not create, delete, move, or retag Git tags.
- Do not edit the GitHub Release.
- Do not install dependencies.
- Do not prune or delete sidecars.
- Do not run broad scenario extraction.
- Treat `_archive/` as evidence only, not active instruction.

## Required Commands

```powershell
git status --short --branch
git rev-list -n 1 release-2026-05-08-cmo-lua-builder-sidecar-cache-wording
git show -s --oneline release-2026-05-08-cmo-lua-builder-sidecar-cache-wording
& "C:\Program Files\GitHub CLI\gh.exe" release view release-2026-05-08-cmo-lua-builder-sidecar-cache-wording --repo jun5896/CMO-Lua-Builder
npm run verify:release
```

## Static Checkpoints

1. Tag exists and points to `f3539f5`.
2. Tagged commit is `f3539f5 Mark sidecar cache wording release in README`.
3. GitHub Release title is `CMO Lua Builder Sidecar Cache Wording Update`.
4. GitHub Release is not draft and not prerelease.
5. Release notes mention the sidecar cache settings Korean wording polish.
6. Release notes mention unchanged behavior/safety boundaries.
7. Release notes mention `npm run verify:release` PASS.
8. Release notes mention bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
9. Release notes mention sidecar audit / scenario loader baseline.
10. Release notes mention AI adapter smoke with no raw auth leakage.
11. README current public release line references `release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`.
12. README bundle baseline is `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
13. `npm run verify:release` remains PASS.
14. Main JS, Main CSS, and `aiContextPruning` remain under watch lines.
15. AI adapter smoke reports no raw `Bearer`, `Authorization`, or `sk-` leakage.

## Expected Baseline

- Tagged commit: `f3539f5`
- Product wording commit: `2ba77a8`
- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Scenario loader: `1899 total / 1857 ready / 42 decoderFailed / issues 0`
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`
- AI adapter smoke: PASS, no raw auth leakage
- Kimi product QA: APPROVED, no regression

## Expected Final Verdict

```text
APPROVED - sidecar cache wording release tag holds.
```
