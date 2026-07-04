# Kimi QA Directive - Template Inspector Completion Operating Recheck

Status: ACTIVE QA REQUEST

## Target

Verify the post-closeout operating recheck after the Template Inspector completion release closeout and closeout-docs QA.

Target commit:

```text
dd0e211 Record template inspector completion operating recheck
```

## Scope

Focused QA for release verification evidence and docs / handoff consistency.

Do not edit files, do not commit, do not retag, and do not create another release.

## Required Commands

Run:

```powershell
git status --short --branch
git show --stat --oneline dd0e211
git show --name-only --oneline dd0e211
git diff --check dd0e211^ dd0e211
npm run verify:release
```

If `npm run verify:release`, `npm run build`, or `npm run smoke:ai-adapter` hits sandbox `spawn EPERM`, report it and rerun with approved permissions before treating it as a product regression.

## Static Checkpoints

1. Target commit changes only docs / handoff files.
2. No `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json` changes.
3. `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md` includes `Post-Release Template Inspector Completion Operating Recheck - 2026-05-09`.
4. Operating recheck section appears after `Post-Release Template Inspector Completion Release Closeout - 2026-05-09`.
5. Operating recheck section records `npm run verify:release`.
6. Operating recheck section records all six chain steps: sidecar audit, scenario loader, lint, build, AI client parser smoke, AI adapter smoke.
7. Operating recheck section records bundle baseline `366.67 kB` JS / `58.27 kB` CSS / `8.56 kB` `aiContextPruning`.
8. Operating recheck section records scenario baseline `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
9. Operating recheck section records sidecar audit dry-run baseline `3799` protected, `24` orphans / about `5.6 MB`.
10. Operating recheck section records AI client parser smoke PASS.
11. Operating recheck section records AI adapter smoke with sanitized HTTP 401 forwarding and no raw auth leakage.
12. Operating recheck section records current public release remains `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
13. Operating recheck section records Template Inspector annotations remain `51 / 51`, `0` missing.
14. Operating recheck section records invariant status: parser / adapter / pruning / scenario-loader / prompt-copy / Lua apply contracts unchanged.
15. Kimi `CURRENT_TASK.md` includes the Codex operating recheck summary.
16. Claude `CURRENT_TASK.md` includes the post-closeout operating recheck summary.
17. Gemini `CURRENT_TASK.md` includes the post-closeout operating recheck summary.
18. `npm run verify:release` remains PASS.
19. Main JS remains below `400 kB`.
20. Main CSS remains below `60 kB`.
21. `aiContextPruning` remains below `9 kB`.
22. AI adapter smoke reports no raw `Bearer`, `Authorization`, or `sk-` leakage.
23. Handoff inbox shape is expected: Kimi has `CURRENT_TASK.md`, `_archive/`, and this active directive; Claude/Gemini have `CURRENT_TASK.md` and `_archive/` only.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - template inspector completion operating recheck holds.
```

Report any blocker or drift explicitly.
