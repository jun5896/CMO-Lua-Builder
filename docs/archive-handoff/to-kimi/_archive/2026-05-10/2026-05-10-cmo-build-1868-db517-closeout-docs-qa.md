# Kimi QA Directive - CMO Build 1868 / DB517 Closeout Docs

## Target

```text
CMO Build 1868 / DB517 closeout and release-notes docs
```

Target files:

```text
docs/agent-ops/cmo-build-1868-db517-refresh-closeout-2026-05-10.md
docs/agent-ops/cmo-build-1868-db517-refresh-release-notes-2026-05-10.md
docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md
handoff/to-kimi/CURRENT_TASK.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
```

## Scope

Verify docs/handoff-only closure for the already-approved DB517 refresh.

This QA does not re-open product behavior. It checks that the closeout and release-notes draft accurately reflect:

- Product commit `f7a696a Refresh CMO DB517 references`.
- Kimi DB517 QA archive path.
- Build 1868 / DB517 local baseline.
- No Track B automation behavior introduced.
- Next gate returns to B0.1 disposable CMO scenario manual load check.

## Required Pipeline

Run:

```powershell
git status --short --branch
git show --stat --oneline HEAD
git diff --check HEAD^ HEAD
```

Static docs checks are sufficient. Product pipeline does not need to be re-run unless you detect unexpected source/package drift.

## Static Checkpoints

1. Closeout doc exists.
2. Release-notes draft doc exists.
3. Closeout doc records status `APPROVED / ARCHIVED`.
4. Closeout doc records target commit `f7a696a Refresh CMO DB517 references`.
5. Closeout doc records QA archive `handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-refresh-qa.md`.
6. Closeout doc records official source `https://forums.matrixgames.com/viewtopic.php?t=417070`.
7. Closeout doc records Kimi verdict `APPROVED - CMO Build 1868 / DB517 refresh holds`.
8. Closeout doc records `32 / 32 PASS`.
9. Closeout doc records `DB3K_517.db3` and `CWDB_517.db3`.
10. Closeout doc records component entries `101078`.
11. Closeout doc records DB3K references `72796` and CWDB references `28282`.
12. Closeout doc records scanner result `CMO v1.09 Build 1868 (Public Beta)`.
13. Closeout doc records generated DB asset delta `+2 / ~0 / -0`.
14. Closeout doc records bundle baseline `377.99 kB / 59.14 kB / 8.56 kB`.
15. Closeout doc records Template Inspector `51 / 51`, `0 missing`.
16. Closeout doc records unchanged boundaries: no `src/**`, no `server/**`, no backend endpoint, no polling, no log tailing, no sidecar writer, no live read-back, no dependency/lockfile change.
17. Closeout doc records manual prompt-copy fallback and `aiParsedResponse.isPasteReady` Lua apply gate unchanged.
18. Closeout doc records historical DB516 references may remain valid in archived/sample docs.
19. Closeout doc records next gate as B0.1 disposable CMO scenario manual check.
20. Release-notes draft records proposed tag `release-2026-05-10-cmo-lua-builder-db517-refresh`.
21. Release-notes draft explicitly says no release tag has been created yet.
22. Release-notes draft records DB517 user-facing changes.
23. Release-notes draft records local generated artifacts and component index counts.
24. Release-notes draft records Kimi QA approval and no regression.
25. Release-notes draft records unchanged automation/safety boundaries.
26. Release-notes draft release checklist keeps B0.1 manual CMO load-check as next Track B gate.
27. Inventory includes a `CMO Build 1868 / DB517 Refresh Closeout - 2026-05-10` section after B0.1 closeout.
28. Inventory records closeout doc, release-notes draft, QA archive, target commit, DB517 baseline, and next B0.1 gate.
29. Kimi `CURRENT_TASK.md` opens only this active directive at top level.
30. Claude `CURRENT_TASK.md` records DB517 closeout docs pending/standby and returns to B0.1 after closure.
31. Gemini `CURRENT_TASK.md` records DB517 closeout docs pending/standby and returns to B0.1 after closure.
32. Target commit changes docs/handoff only.
33. `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, and `package-lock.json` are unchanged by this docs closeout.
34. Handoff inbox state is clean except Kimi top-level active directive.

## Regression Watch

Report any of these as blockers:

- Release-notes draft implying a tag already exists.
- Any claim that DB517 refresh proves CMO `.lua` auto-load.
- Any claim that live read-back, polling, log tailing, or sidecar writer is now implemented.
- Any docs drift that changes the next gate away from B0.1 manual CMO load-check.
- Any source/package/public data change in this docs-only closeout.
