# Kimi QA Directive - Template Inspector Search / Filter Release Tag

Status: ACTIVE

## Target

Release tag:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-search-filter
```

Tagged commit:

```text
004325d Mark template inspector search filter release in README
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-search-filter
```

Release title:

```text
CMO Lua Builder Template Inspector Search Filter UX
```

Do not edit files and do not commit. Treat this as a read-only release-tag QA pass.

## Required Commands

Run:

```powershell
git status --short --branch
git rev-list -n 1 release-2026-05-09-cmo-lua-builder-template-inspector-search-filter
git show -s --oneline release-2026-05-09-cmo-lua-builder-template-inspector-search-filter
npm run verify:release
gh release view release-2026-05-09-cmo-lua-builder-template-inspector-search-filter --repo jun5896/CMO-Lua-Builder
```

If `npm run verify:release`, `npm run build`, `npm run smoke:ai-adapter`, or `gh release view` hits sandbox `spawn EPERM` / keyring / network restrictions, rerun with approved permissions before treating it as a regression.

## Expected Baseline

Codex release verification observed:

```text
npm run verify:release: PASS after approved rerun for Windows sandbox spawn EPERM
Main JS:              366.67 kB  (< 400 kB)
Main CSS:              58.27 kB  (< 60 kB)
aiContextPruning:       8.56 kB  (< 9 kB)
PresetGuide lazy JS:   33.99 kB
PresetGuide lazy CSS:   7.49 kB
Template Inspector:    51 / 51 annotations, 0 missing
Scenario loader:       1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0
Sidecar audit:         3799 protected / 24 orphans / about 5.6 MB, dry-run only
```

AI adapter smoke should show sanitized HTTP 401 forwarding and no raw `Bearer`, `Authorization`, or `sk-` leakage.

## Static Checkpoints

1. Release tag exists.
2. Release tag points to `004325d`.
3. Tagged commit message is `Mark template inspector search filter release in README`.
4. GitHub Release title is `CMO Lua Builder Template Inspector Search Filter UX`.
5. GitHub Release is not draft.
6. GitHub Release is not prerelease.
7. GitHub Release notes mention Template Inspector Search / Filter UX.
8. GitHub Release notes mention the completed `51 / 51` annotation baseline.
9. GitHub Release notes list the 7 quick filters.
10. GitHub Release notes mention excluded noisy filters: standalone GUID, standalone Side, Engine Test Required, demo values.
11. GitHub Release notes mention safety badges.
12. GitHub Release notes include the AI draft / CMO engine verification footer behavior.
13. GitHub Release notes mention `npm run verify:release` PASS.
14. GitHub Release notes mention sidecar audit and scenario loader baselines.
15. GitHub Release notes mention AI client parser smoke and AI adapter smoke.
16. GitHub Release notes mention no raw `Bearer` / `Authorization` / `sk-` leakage.
17. GitHub Release notes mention bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
18. GitHub Release notes mention `PresetGuide` lazy chunk `33.99 kB JS / 7.49 kB CSS`.
19. README current public release line references `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
20. README bundle baseline records `PresetGuide` `33.99 kB JS / 7.49 kB CSS`.
21. `npm run verify:release` remains PASS.
22. Main JS remains below `400 kB`.
23. Main CSS remains below `60 kB`.
24. `aiContextPruning` remains below `9 kB`.
25. AI adapter smoke reports no raw auth leakage.
26. Release marker commit is README-only.
27. No `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, `package-lock.json`, dependency, or lockfile drift.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - template inspector search filter release tag holds.
```

Report any blocker or drift explicitly.

