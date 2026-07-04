# Kimi QA Directive - Transient Sidecar UX Release Tag

Status: APPROVED / ARCHIVED

## Purpose

Verify that the transient scenario sidecar UX release tag and GitHub Release match the accepted QA baseline. This is a read-only release-tag verification pass.

## Release Target

Expected release tag:

```text
release-2026-05-07-cmo-lua-builder-transient-sidecar-ux
```

Expected tagged commit:

```text
ffbd86e Refresh README for transient sidecar UX release
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-transient-sidecar-ux
```

Expected release title:

```text
CMO Lua Builder Transient Sidecar UX Update
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
git rev-list -n 1 release-2026-05-07-cmo-lua-builder-transient-sidecar-ux
git show -s --oneline release-2026-05-07-cmo-lua-builder-transient-sidecar-ux
& "C:\Program Files\GitHub CLI\gh.exe" release view release-2026-05-07-cmo-lua-builder-transient-sidecar-ux --repo jun5896/CMO-Lua-Builder
npm run verify:release
npm run smoke:scenario-transient
```

## Static Checkpoints

1. Tag exists and points to `ffbd86e`.
2. GitHub Release title is `CMO Lua Builder Transient Sidecar UX Update`.
3. GitHub Release is not draft and not prerelease.
4. Release notes mention transient in-memory summary when a matching sidecar is missing.
5. Release notes mention the original `.scen` is not modified and temporary files are cleaned.
6. Release notes mention `npm run verify:release` PASS.
7. Release notes mention `npm run smoke:scenario-transient` PASS and empty `.scenario-extract-cache`.
8. Release notes mention bundle baseline `366.60 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
9. README current public release line references `release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`.
10. `npm run verify:release` remains PASS.
11. `npm run smoke:scenario-transient` remains PASS.
12. Main JS, Main CSS, and `aiContextPruning` remain under watch lines.
13. AI adapter smoke reports no raw `Bearer`, `Authorization`, or `sk-` leakage.

## Expected Baseline

- Tagged commit: `ffbd86e`
- Main JS: `366.60 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Scenario loader: `1899 total / 1857 ready / 42 decoderFailed / issues 0`
- Sidecar audit: dry-run only, `24` orphans / `5.6 MB`
- AI adapter smoke: PASS, no raw auth leakage
- Transient smoke: PASS, in-memory summary returned, temp cache empty

## Expected Final Verdict

```text
APPROVED - transient sidecar UX release tag holds.
```
