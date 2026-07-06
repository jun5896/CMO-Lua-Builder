# Kimi QA Directive - QA Workflow Release Tag

Date: 2026-05-06
Requested by: Codex
Mode: read-only QA / release-tag regression monitor

## Purpose

Verify the pushed QA workflow release tag:

```text
release-2026-05-06-cmo-lua-builder-qa-workflow
```

Expected tagged commit:

```text
e5cd403 Mark QA workflow release in README
```

This is a release/tag consistency pass after the QA workflow script was approved. It should not require source edits.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not archive this directive; Codex will archive it after your report.
- Do not install dependencies.
- Do not prune sidecars or delete orphans.
- Do not run broad scenario extraction.

## Required Pipeline

Run:

```powershell
git status --short --branch
git tag --points-at HEAD
gh release view release-2026-05-06-cmo-lua-builder-qa-workflow --repo jun5896/CMO-Lua-Builder
npm run verify:release
```

If `gh` is not visible in the current PowerShell PATH, use:

```powershell
& "C:\Program Files\GitHub CLI\gh.exe" release view release-2026-05-06-cmo-lua-builder-qa-workflow --repo jun5896/CMO-Lua-Builder
```

If `npm run verify:release` hits `spawn EPERM`, report it as sandbox/environment unless code evidence says otherwise. Codex already validated the same command after approved spawn permissions.

## Expected Baseline

- `git status --short --branch`: clean, `main...origin/main`
- `git tag --points-at HEAD`: includes `release-2026-05-06-cmo-lua-builder-qa-workflow`
- GitHub Release exists at `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-06-cmo-lua-builder-qa-workflow`
- GitHub Release title: `CMO Lua Builder QA Workflow Release`
- GitHub Release is not draft and not prerelease
- `npm run verify:release`: PASS
- Scenario index: `1899`
- Loader counts: `1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`
- Sidecar audit: dry-run only, `24` orphans / about `5.6 MB`
- Main JS: `366.29 kB`, under `400 kB`
- Main CSS: `58.27 kB`, under `60 kB`
- `aiContextPruning`: `8.56 kB`, under `9 kB`
- AI adapter smoke: no raw `Bearer` / `sk-` leakage

## Static Checkpoints

Verify:

1. README current public release line references `release-2026-05-06-cmo-lua-builder-qa-workflow`.
2. README QA Baseline still documents `npm run verify:release`.
3. Manual split pipeline remains below the shortcut.
4. `package.json` still contains `verify:release`.
5. Tag points at `e5cd403`.
6. GitHub Release notes mention `npm run verify:release`, bundle baseline, scenario baseline, and no product source/dependency changes.
7. Release-tag commit scope is README-only after the already-approved `d7afc39` workflow script.
8. No `src/**`, `server/**`, `tools/**`, dependency, or `package-lock.json` drift.

## Report Format

Return a compact QA report with:

- tag / HEAD mapping
- GitHub Release title / URL
- pipeline result
- bundle sizes
- scenario / sidecar counts
- static checkpoint table
- any regression
- final verdict

Expected final verdict if all checks pass:

```text
APPROVED - QA workflow release tag holds.
```
