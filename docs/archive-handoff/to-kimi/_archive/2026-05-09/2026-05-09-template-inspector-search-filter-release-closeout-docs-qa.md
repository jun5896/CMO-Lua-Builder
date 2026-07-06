# Kimi QA Directive - Template Inspector Search / Filter Release Closeout Docs

Status: ACTIVE

## Target

Target commit:

```text
2003b56 Document template inspector search filter release closeout
```

Scope:

- Docs / handoff only.
- No product code, server, tool, public data, package, lockfile, or release-tag change.

Do not edit files and do not commit. Treat this as a read-only QA pass.

## Required Checks

Run:

```powershell
git status --short --branch
git show --stat --oneline 2003b56
git show --name-only --oneline 2003b56
git diff --check 2003b56^ 2003b56
```

No build is required for this docs/handoff-only target unless you see unexpected product-code drift.

## Static Checkpoints

1. Release closeout doc exists at `docs/agent-ops/template-inspector-search-filter-release-closeout-2026-05-09.md`.
2. Closeout doc records release tag `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
3. Closeout doc records tagged commit `004325d Mark template inspector search filter release in README`.
4. Closeout doc records GitHub Release URL and title `CMO Lua Builder Template Inspector Search Filter UX`.
5. Closeout doc records release state not draft, not prerelease.
6. Closeout doc records product UX commit `5dd1da1 Add template inspector search filter UX`.
7. Closeout doc records product QA archive commit `9768910`.
8. Closeout doc records product closeout commit `bd3a5c5`.
9. Closeout doc records product closeout QA archive commit `52dfe94`.
10. Closeout doc records release marker commit `004325d`.
11. Closeout doc records release QA directive commit `be448f8`.
12. Closeout doc records release QA archive commit `b90d1b9`.
13. Closeout doc records release QA archive path `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-search-filter-release-qa.md`.
14. Closeout doc lists the 7 quick filters.
15. Closeout doc records excluded noisy filters: standalone GUID, standalone Side, Engine Test Required, demo values.
16. Closeout doc lists all 8 safety badges.
17. Closeout doc records the AI draft / CMO engine verification footer.
18. Closeout doc records Kimi release QA pipeline results and 27 / 27 checkpoints.
19. Closeout doc records bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
20. Closeout doc records `PresetGuide` lazy chunk `33.99 kB JS / 7.49 kB CSS`.
21. Closeout doc records Template Inspector annotations `51 / 51`, `0` missing.
22. Closeout doc records unchanged contracts: prompt-copy, `aiParsedResponse.isPasteReady`, parser, adapter, pruning, sidecar, dependencies.
23. Inventory includes `Post-Release Template Inspector Search / Filter Release Closeout - 2026-05-09`.
24. Kimi `CURRENT_TASK.md` references the release closeout doc and current public release.
25. Claude `CURRENT_TASK.md` references the current public release and release closeout.
26. Gemini `CURRENT_TASK.md` references the current public release and release closeout.
27. Target commit changes only docs and handoff files.
28. Target commit does not change `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json`.
29. Handoff inbox shape: Kimi has `_archive/`, `CURRENT_TASK.md`, and this active directive; Claude/Gemini have `_archive/` plus `CURRENT_TASK.md` only.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - template inspector search filter release closeout docs hold.
```

Report any blocker or drift explicitly.

