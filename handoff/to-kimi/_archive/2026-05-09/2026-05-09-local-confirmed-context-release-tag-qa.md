# Kimi QA Directive - Local Confirmed Context Release Tag

## Target Release

```text
release-2026-05-09-cmo-lua-builder-local-confirmed-context
```

Tagged commit:

```text
85ccada Mark local confirmed context release in README
```

GitHub Release:

```text
Title: CMO Lua Builder Local Confirmed Context Workspace
URL: https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-local-confirmed-context
Draft: false
Prerelease: false
```

## Scope

- Release marker and verification baseline refresh.
- `README.md` now points to the local confirmed context public release.
- `package.json` `verify:release` now includes the Track A AI editor smokes:
  - `smoke:ai-workflow-state`
  - `smoke:ai-follow-up-needs`
  - `smoke:ai-confirmed-context`
- No product source, server, public data, dependency, or lockfile change expected.

## Required Pipeline

Run:

```powershell
git status --short --branch
git rev-list -n 1 release-2026-05-09-cmo-lua-builder-local-confirmed-context
git show -s --oneline release-2026-05-09-cmo-lua-builder-local-confirmed-context
gh release view release-2026-05-09-cmo-lua-builder-local-confirmed-context
npm run verify:release
```

## Codex Pre-QA Result

- Tag points to `85ccadab0818d0f9089f923b02171d1065c2f42a`.
- Tagged commit message: `85ccada Mark local confirmed context release in README`.
- GitHub Release exists, not draft, not prerelease.
- `npm run verify:release`: PASS with the expanded 9-step chain.
- Sidecar audit: `1899` scenarios in index, `3799` protected files, `24` orphans / `5.6 MB`, dry-run only.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Build: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- AI adapter smoke: no raw Bearer / Authorization / sk-key leakage.

## Static Checkpoints

1. Release tag exists.
2. Release tag points to `85ccada`.
3. Tagged commit message is `Mark local confirmed context release in README`.
4. GitHub Release title is `CMO Lua Builder Local Confirmed Context Workspace`.
5. GitHub Release is not draft.
6. GitHub Release is not prerelease.
7. Release notes mention local Confirmed Context Workspace.
8. Release notes mention source-labeled CMO values.
9. Release notes mention prompt reuse.
10. Release notes mention temp-session persistence.
11. Release notes mention text-only follow-up drafts.
12. Release notes mention `npm run verify:release` PASS.
13. Release notes mention sidecar audit and scenario loader baseline.
14. Release notes mention AI workflow, follow-up needs, confirmed context, client parser, and adapter smokes.
15. Release notes mention no raw Bearer / Authorization / sk leakage.
16. Release notes mention no backend endpoint, CMO filesystem writes, log tailing, or live read-back.
17. Release notes mention bundle baseline `377.99 kB JS / 59.14 kB CSS / 8.56 kB aiContextPruning`.
18. `README.md` current public release line references `release-2026-05-09-cmo-lua-builder-local-confirmed-context`.
19. `README.md` QA manual pipeline includes `smoke:ai-workflow-state`, `smoke:ai-follow-up-needs`, and `smoke:ai-confirmed-context`.
20. `README.md` bundle baseline records Main JS `377.99 kB`, Main CSS `59.14 kB`, and `aiContextPruning` `8.56 kB`.
21. `package.json` `verify:release` includes the three Track A AI editor smokes before parser/adapter smoke.
22. `package-lock.json` is unchanged.
23. No `src/**`, `server/**`, `public/**`, or `tools/**` change in tagged commit.
24. `npm run verify:release` remains PASS.
25. Main JS remains below `400 kB`.
26. Main CSS remains below `60 kB`.
27. `aiContextPruning` remains below `9 kB`.
28. AI adapter smoke reports no raw auth leakage.

## Expected Verdict

Approve only if the release tag, GitHub Release, README baseline, expanded `verify:release` chain, and security/bundle watch lines all hold.
