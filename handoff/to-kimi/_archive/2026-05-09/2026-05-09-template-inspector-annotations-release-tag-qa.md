# Kimi QA Directive - Template Inspector Annotations Release Tag

Status: APPROVED / ARCHIVED

## Target

Verify the Template Inspector annotations public release tag and GitHub Release.

Release tag:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-annotations
```

Tagged commit:

```text
f46385b Mark template inspector annotation release in README
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-annotations
```

## Scope

Read-only release-tag / release-notes QA.

Do not edit files, do not commit, do not retag, and do not create another release.

## Required Commands

Run:

```powershell
git status --short --branch
git rev-list -n 1 release-2026-05-09-cmo-lua-builder-template-inspector-annotations
git show -s --oneline release-2026-05-09-cmo-lua-builder-template-inspector-annotations
npm run verify:release
& "C:\Program Files\GitHub CLI\gh.exe" release view release-2026-05-09-cmo-lua-builder-template-inspector-annotations --repo jun5896/CMO-Lua-Builder
```

If `npm run verify:release`, `npm run build`, `npm run smoke:ai-adapter`, or `gh` hits sandbox `spawn EPERM` / network refusal, report it and rerun with approved permissions before treating it as a product regression.

## Static Checkpoints

1. Tag exists and points to `f46385b`.
2. Tagged commit message is `Mark template inspector annotation release in README`.
3. GitHub Release title is `CMO Lua Builder Template Inspector Annotation Update`.
4. GitHub Release is not draft.
5. GitHub Release is not prerelease.
6. Release notes mention Template Inspector guidance coverage from `8 / 51` to `18 / 51`.
7. Release notes list the 10 newly covered annotation templates.
8. Release notes mention `npm run verify:release` PASS.
9. Release notes mention the sandbox `spawn EPERM` approved rerun context.
10. Release notes mention bundle baseline `366.67 kB` JS / `58.27 kB` CSS / `8.56 kB` `aiContextPruning`.
11. Release notes mention sidecar audit / scenario loader baseline.
12. Release notes mention AI adapter smoke auth safety.
13. README current public release line references `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
14. `npm run verify:release` remains PASS.
15. Main JS remains below `400 kB`.
16. Main CSS remains below `60 kB`.
17. `aiContextPruning` remains below `9 kB`.
18. AI adapter smoke reports no raw `Bearer`, `Authorization`, or `sk-` leakage.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - template inspector annotations release tag holds.
```

Report any blocker or drift explicitly.

## Kimi QA Result

Final verdict:

```text
APPROVED - template inspector annotations release tag holds.
```

Summary:

- Release tag: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Tagged commit: `f46385b Mark template inspector annotation release in README`.
- `git status --short --branch`: clean (`main...origin/main`).
- `npm run verify:release`: PASS.
- GitHub Release title: `CMO Lua Builder Template Inspector Annotation Update`.
- GitHub Release state: not draft, not prerelease.
- Release notes include coverage `8 / 51` to `18 / 51`, 10 annotation templates, `verify:release` PASS, sandbox `spawn EPERM` approved rerun context, bundle baseline, sidecar/loader baseline, and AI adapter smoke auth safety.
- Bundle: Main JS `366.67 kB`, Main CSS `58.27 kB`, `aiContextPruning` `8.56 kB`.
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run, `3799` protected, `24` orphans / `5.6 MB`.
- Static checkpoints: 18 / 18 PASS.
- Regression: none.
