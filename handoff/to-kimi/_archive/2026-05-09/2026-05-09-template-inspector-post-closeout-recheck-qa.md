# Kimi QA Directive - Template Inspector Post-Closeout Operating Recheck

Status: APPROVED / ARCHIVED

## Target

Verify the post-closeout operating recheck after the Template Inspector annotations release closeout and closeout-docs QA.

Target commit:

```text
adddf64 Record template inspector post-closeout verification
```

## Scope

Focused QA for release verification evidence and docs / handoff consistency.

Do not edit files, do not commit, do not retag, and do not create another release.

## Required Commands

Run:

```powershell
git status --short --branch
git show --stat --oneline adddf64
git show --name-only --oneline adddf64
git diff --check adddf64^ adddf64
npm run verify:release
```

If `npm run verify:release`, `npm run build`, or `npm run smoke:ai-adapter` hits sandbox `spawn EPERM`, report it and rerun with approved permissions before treating it as a product regression.

## Static Checkpoints

1. Target commit changes only docs / handoff files.
2. No `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json` changes.
3. `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md` includes `Post-Release Template Inspector Annotations Operating Recheck - 2026-05-09`.
4. Operating recheck section appears after `Post-Release Template Inspector Annotations Closeout - 2026-05-09`.
5. Operating recheck section records `npm run verify:release`.
6. Operating recheck section records all six chain steps: sidecar audit, scenario loader, lint, build, AI client parser smoke, AI adapter smoke.
7. Operating recheck section records bundle baseline `366.67 kB` JS / `58.27 kB` CSS / `8.56 kB` `aiContextPruning`.
8. Operating recheck section records scenario baseline `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
9. Operating recheck section records sidecar audit dry-run baseline `3799` protected, `24` orphans / about `5.6 MB`.
10. Operating recheck section records AI adapter smoke with sanitized HTTP 401 forwarding and no raw auth leakage.
11. Operating recheck section records invariant status: Template Inspector release remains current public baseline, annotations stay in `public/template-annotations.json`, and parser / adapter / pruning / scenario-loader / Lua apply contracts unchanged.
12. Kimi `CURRENT_TASK.md` includes the Codex pre-QA operating recheck summary.
13. Claude `CURRENT_TASK.md` includes the post-closeout operating recheck summary.
14. Gemini `CURRENT_TASK.md` includes the post-closeout operating recheck summary.
15. `npm run verify:release` remains PASS.
16. Main JS remains below `400 kB`.
17. Main CSS remains below `60 kB`.
18. `aiContextPruning` remains below `9 kB`.
19. AI adapter smoke reports no raw `Bearer`, `Authorization`, or `sk-` leakage.
20. Handoff inbox shape is expected: Kimi has `CURRENT_TASK.md`, `_archive/`, and this active directive; Claude/Gemini have `CURRENT_TASK.md` and `_archive/` only.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - template inspector post-closeout operating recheck holds.
```

Report any blocker or drift explicitly.

## Kimi QA Result

Final verdict:

```text
APPROVED - template inspector post-closeout operating recheck holds.
```

Summary:

- Target commit: `adddf64 Record template inspector post-closeout verification`.
- `git status --short --branch`: clean (`main...origin/main`).
- `git show --stat --oneline adddf64`: 4 files changed, 59 insertions.
- `git show --name-only --oneline adddf64`: docs 1 file plus handoff 3 files.
- `git diff --check adddf64^ adddf64`: PASS, no whitespace or syntax issues.
- `npm run verify:release`: PASS, full six-step chain passed.
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.
- Bundle: Main JS `366.67 kB`, Main CSS `58.27 kB`, `aiContextPruning` `8.56 kB`.
- Static checkpoints: 20 / 20 PASS.
- Target commit changes only docs / handoff files; no product or package drift.
- Handoff inbox shape matches expected state.
- Regression: none.
