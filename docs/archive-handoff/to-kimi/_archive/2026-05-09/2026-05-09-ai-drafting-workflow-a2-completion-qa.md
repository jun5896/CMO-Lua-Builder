# Kimi QA Directive - AI Drafting Workflow A2 Completion Checklist

Status: ACTIVE

## Target

Target commit:

```text
b7dd3b6 Document AI drafting workflow A2 completion
```

Scope:

- Docs / handoff only.
- No product code, server, tool, public data, package, lockfile, or release-tag change.

Do not edit files and do not commit. Treat this as a read-only QA pass.

## Required Checks

Run:

```powershell
git status --short --branch
git show --stat --oneline b7dd3b6
git show --name-only --oneline b7dd3b6
git diff --check b7dd3b6^ b7dd3b6
```

No build is required for this docs/handoff-only target unless you see unexpected product-code drift. Codex already ran `npm run verify:release` after approved sandbox escalation and recorded the result.

## Static Checkpoints

1. Checklist doc exists at `docs/agent-ops/ai-drafting-workflow-a2-completion-checklist-2026-05-09.md`.
2. Checklist states current public release remains `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
3. Checklist records tagged commit `004325d Mark template inspector search filter release in README`.
4. Checklist records GitHub Release URL and title `CMO Lua Builder Template Inspector Search Filter UX`.
5. Checklist records A2-1 design, implementation plan, product, QA directive, and QA archive commits.
6. Checklist records A2-1 QA evidence path.
7. Checklist records A2-2 design, implementation plan, contract/helper, product, QA directive, QA archive, closeout, and closeout-QA archive commits.
8. Checklist records A2-2 QA evidence paths.
9. Checklist table includes intent/prompt start, template/preset context, adapter send, parser sections, workflow state, ready gate, ask-back needs, blocked disable, text-only follow-up, manual fallback, Working Draft gate, CMO engine verification, context pruning, and no Track B behavior.
10. Checklist records Codex `npm run verify:release` PASS after approved sandbox rerun.
11. Checklist records sidecar audit `1899` index / `3799` protected / `24` orphans.
12. Checklist records scenario loader `1899 / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
13. Checklist records `lint`, `build`, `smoke:ai-client-parser`, and `smoke:ai-adapter` PASS.
14. Checklist records no raw Bearer / Authorization / sk-key leakage.
15. Checklist records bundle baseline `371.44 kB JS / 59.14 kB CSS / 8.56 kB aiContextPruning`.
16. Checklist records AiInterpreterChatPanel `10.38 kB JS / 6.73 kB CSS`.
17. Checklist records AiResponseReviewPanel `10.08 kB JS / 5.23 kB CSS`.
18. Checklist records Main CSS below but close to `60 kB`.
19. Checklist states Track A2 is complete.
20. Checklist does not state Track A is fully complete.
21. Checklist recommends A3 Local Confirmed Context Workspace before Track B.
22. Inventory includes `Post-Release AI Drafting Workflow A2 Completion Checklist - 2026-05-09`.
23. Kimi CURRENT_TASK.md references the A2 completion checklist.
24. Claude CURRENT_TASK.md references the A2 completion checklist and remains standby.
25. Gemini CURRENT_TASK.md references the A2 completion checklist and remains standby.
26. Target commit changes only docs and handoff files.
27. Target commit does not change `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json`.
28. Handoff inbox shape: Kimi has `_archive/`, `CURRENT_TASK.md`, and this active directive; Claude/Gemini have `_archive/` plus `CURRENT_TASK.md` only.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - AI drafting workflow A2 completion checklist holds.
```

Report any blocker or drift explicitly.

## Kimi QA Result - APPROVED / ARCHIVED

Target commit:

```text
b7dd3b6 Document AI drafting workflow A2 completion
```

Pipeline:

- `git status --short --branch`: clean (`main...origin/main`).
- `git show --stat --oneline b7dd3b6`: 5 files, 238 insertions.
- `git show --name-only --oneline b7dd3b6`: docs 2 files + handoff 3 files.
- `git diff --check b7dd3b6^ b7dd3b6`: no whitespace issues.

Static checkpoints:

- `28 / 28` PASS.
- Checklist doc exists and records the current public release `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Checklist records tagged commit `004325d`, GitHub Release URL, and title.
- Checklist records A2-1 and A2-2 commits / QA evidence paths.
- Checklist table covers intent/prompt, template context, adapter, parser, workflow state, ready gate, ask-back, blocked, text-only follow-up, manual fallback, Working Draft gate, CMO engine verification, context pruning, and no Track B behavior.
- Checklist records `npm run verify:release` PASS after approved sandbox rerun.
- Checklist records sidecar audit, scenario loader, lint, build, AI client parser smoke, and AI adapter smoke baselines.
- Checklist records no raw Bearer / Authorization / sk-key leakage.
- Checklist records bundle and lazy chunk baselines.
- Checklist states Track A2 is complete.
- Checklist does not state Track A is fully complete.
- Checklist recommends A3 Local Confirmed Context Workspace before Track B.
- Inventory and Kimi / Claude / Gemini CURRENT_TASK files reference the A2 completion checklist consistently.
- Target commit changes docs / handoff only.
- No `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, or `package-lock.json` changes.
- Handoff inbox shape matches expectation.

Final verdict:

```text
APPROVED - AI drafting workflow A2 completion checklist holds.
```

Regression: none.
