# Kimi QA Directive - Template Inspector Search / Filter UX Closeout Docs

Status: ACTIVE

## Target

Target commit:

```text
bd3a5c5 Document template inspector search filter closeout
```

Scope:

- Docs / handoff only.
- No product code, server, tool, public data, package, lockfile, or release-tag change.

Do not edit files and do not commit. Treat this as a read-only QA pass.

## Required Checks

Run:

```powershell
git status --short --branch
git show --stat --oneline bd3a5c5
git show --name-only --oneline bd3a5c5
git diff --check bd3a5c5^ bd3a5c5
```

No build is required for this docs/handoff-only target unless you see unexpected product-code drift.

## Static Checkpoints

1. Closeout doc exists at `docs/agent-ops/template-inspector-search-filter-ux-closeout-2026-05-09.md`.
2. Closeout doc states current public release remains `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
3. Closeout doc records tagged commit `59bdab9 Mark template inspector completion release in README`.
4. Closeout doc records product commit `5dd1da1 Add template inspector search filter UX`.
5. Closeout doc records Kimi QA directive commit `f84bdf2 Open template inspector search filter QA directive`.
6. Closeout doc records archive commit `9768910 Archive template inspector search filter QA`.
7. Closeout doc records Kimi QA archive path `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-search-filter-ux-qa.md`.
8. Closeout doc records Claude review archive path `handoff/to-claude/_archive/2026-05-09/2026-05-09-template-inspector-filter-taxonomy-review.md`.
9. Closeout doc lists the 7 quick filters: Event, Mission, Unit, DBID / Loadout, RP / Zone, Doctrine / EMCON, KeyValue.
10. Closeout doc records excluded noisy filters: standalone GUID, standalone Side, Engine Test Required, demo values.
11. Closeout doc lists all 8 safety badges.
12. Closeout doc records the universal footer text: `AI draft. CMO engine verification is still required before execution.`
13. Closeout doc records Codex pre-QA and Kimi QA pipeline outcomes.
14. Closeout doc records bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
15. Closeout doc records `PresetGuide` lazy chunk baseline `33.99 kB JS / 7.49 kB CSS`.
16. Closeout doc records Template Inspector annotations `51 / 51`, `0` missing.
17. Closeout doc records unchanged contracts: prompt-copy fallback, `aiParsedResponse.isPasteReady`, parser, adapter, context pruning, sidecar behavior, package/dependency state.
18. Closeout doc records no release tag was created for this slice.
19. `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md` includes `Post-Release Template Inspector Search / Filter UX Closeout - 2026-05-09`.
20. Kimi `CURRENT_TASK.md` references the closeout doc and A1 approval.
21. Claude `CURRENT_TASK.md` is standby and references the archived taxonomy review / A1 implementation status.
22. Gemini `CURRENT_TASK.md` remains standby and references the A1 implementation status.
23. Target commit changes only docs and handoff files.
24. Target commit does not change `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json`.
25. Handoff inbox shape: Kimi has `_archive/`, `CURRENT_TASK.md`, and this active directive; Claude/Gemini have `_archive/` plus `CURRENT_TASK.md` only.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - template inspector search filter closeout docs hold.
```

Report any blocker or drift explicitly.

