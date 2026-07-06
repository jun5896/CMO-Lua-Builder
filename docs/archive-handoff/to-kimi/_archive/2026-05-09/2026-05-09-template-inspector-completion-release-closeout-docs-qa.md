# Kimi QA Directive - Template Inspector Completion Release Closeout Docs

Status: ACTIVE QA REQUEST

## Target

QA target commit:

```text
9437c3d Document template inspector completion release closeout
```

Expected target scope:

- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `docs/agent-ops/template-inspector-completion-release-closeout-2026-05-09.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`
- `handoff/to-kimi/CURRENT_TASK.md`

Expected target stat:

```text
5 files changed, 214 insertions(+)
```

No product code, public data, server, tools, package, or lockfile changes are expected.

## Required Checks

Run/read:

```powershell
git status --short --branch
git show --stat --oneline 9437c3d
git show --name-only --oneline 9437c3d
git diff --check 9437c3d^ 9437c3d
```

No `npm` pipeline is required unless the file scope differs from docs/handoff-only.

## Static Checkpoints

1. Completion release closeout doc exists at `docs/agent-ops/template-inspector-completion-release-closeout-2026-05-09.md`.
2. Closeout doc records release tag `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
3. Closeout doc records tagged commit `59bdab9 Mark template inspector completion release in README`.
4. Closeout doc records GitHub Release URL and title `CMO Lua Builder Template Inspector Completion`.
5. Closeout doc records release state as not draft and not prerelease.
6. Closeout doc records completion product/data commit `80a003a`.
7. Closeout doc records completion closeout commit `77e5393`.
8. Closeout doc records completion closeout QA archive commit `eb9c9b0`.
9. Closeout doc records release QA directive commit `da57221`.
10. Closeout doc records release QA archive commit `dbf3f9b`.
11. Closeout doc records the archived release QA path under `handoff/to-kimi/_archive/2026-05-09/`.
12. Closeout doc records `npm run verify:release` and its six-step expanded pipeline.
13. Closeout doc records Kimi release QA result: `20 / 20` static checkpoints PASS and no regression.
14. Closeout doc records bundle baseline `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
15. Closeout doc records Template Inspector coverage `51 / 51` and `0` missing.
16. Closeout doc records scenario baseline `1899 / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
17. Closeout doc records sidecar audit baseline `3799` protected and `24` orphans / about `5.6 MB`.
18. Closeout doc records unchanged invariants: parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts unchanged.
19. Closeout doc records that future Template Inspector work is wording/search/filter/localization refinement rather than coverage expansion.
20. Final stabilization inventory includes Template Inspector completion release closeout after completion annotation closeout.
21. Kimi / Claude / Gemini `CURRENT_TASK.md` files reference the completion release closeout document.
22. Handoff inbox state is clean: Kimi has `_archive/`, `CURRENT_TASK.md`, and this active directive; Claude/Gemini have `_archive/` and `CURRENT_TASK.md`.
23. Target commit does not change `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json`.

## Reporting

Report:

- Pipeline/status commands
- Static checkpoint table
- File-scope summary
- Regression summary
- Final verdict
