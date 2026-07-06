# Kimi QA Directive - Template Inspector Completion Release Tag

Status: ACTIVE QA REQUEST

## Target

Release tag:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-completion
```

Tagged commit:

```text
59bdab9 Mark template inspector completion release in README
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-completion
```

Expected title:

```text
CMO Lua Builder Template Inspector Completion
```

## Required Checks

Run/read:

```powershell
git status --short --branch
git rev-list -n 1 release-2026-05-09-cmo-lua-builder-template-inspector-completion
git show -s --oneline release-2026-05-09-cmo-lua-builder-template-inspector-completion
gh release view release-2026-05-09-cmo-lua-builder-template-inspector-completion --json tagName,targetCommitish,name,isDraft,isPrerelease,url,body
npm run verify:release
```

If `verify:release` hits sandbox `spawn EPERM`, report it as environment/sandbox and use Codex-provided approved rerun evidence if present.

## Expected Verification Baseline

- `npm run verify:release`: PASS
- Sidecar audit: `1899` scenarios in index, `3799` protected sidecars, `24` orphans / about `5.6 MB`, dry-run only
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`
- AI client parser smoke: PASS
- AI adapter smoke: PASS, no raw `Bearer`, `Authorization`, or `sk-` leakage

## Expected Bundle Baseline

- Main JS: `366.67 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Template Inspector annotations: `51 / 51`

## Static Checkpoints

1. Tag exists and points to `59bdab9`.
2. Tagged commit message is `Mark template inspector completion release in README`.
3. GitHub Release title is `CMO Lua Builder Template Inspector Completion`.
4. GitHub Release is not draft.
5. GitHub Release is not prerelease.
6. Release notes mention `51 / 51` annotations and `0` missing.
7. Release notes mention final guidance coverage for startup weather, loadout scramble, generic mission fallback, advanced ops, airbase scramble, CAP patrol, multi-file output, quickbattle, and strike alpha presets.
8. Release notes mention `npm run verify:release`: PASS.
9. Release notes mention sidecar audit and scenario loader baselines.
10. Release notes mention AI client parser smoke and AI adapter smoke.
11. Release notes mention no raw `Bearer` / `Authorization` / `sk-` leakage.
12. Release notes mention bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
13. Release notes mention Template Inspector guidance remains data-driven in `public/template-annotations.json`.
14. Release notes mention demo preset values are examples, not scenario-specific truth.
15. README current public release line references `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
16. README QA baseline includes Template Inspector annotations `51 / 51`.
17. `npm run verify:release` remains PASS.
18. Main JS < `400 kB`, Main CSS < `60 kB`, `aiContextPruning` < `9 kB`.
19. AI adapter smoke reports no raw `Bearer`, `Authorization`, or `sk-` leakage.
20. Release-tag commit scope is README-only after completion closeout; no `src/**`, `server/**`, `tools/**`, `public/**`, dependency, or lockfile drift.

## Reporting

Report:

- Tag / commit mapping
- GitHub Release metadata
- Pipeline result
- Bundle / sidecar / scenario baseline
- Static checkpoint table
- Regression summary
- Final verdict
