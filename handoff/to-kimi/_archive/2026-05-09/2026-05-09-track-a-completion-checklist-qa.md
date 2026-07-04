# Kimi QA Directive - Track A Completion Checklist

## Target

```text
docs/agent-ops/track-a-local-ai-interpreter-completion-checklist-2026-05-09.md
```

Target commit scope:

- Docs / handoff only.
- No product code, server, tools, public data, package, dependency, or lockfile change expected.

## Current Public Release

```text
release-2026-05-09-cmo-lua-builder-local-confirmed-context
```

## Required Pipeline

Run:

```powershell
git status --short --branch
git show --stat --oneline HEAD
git show --name-only --oneline HEAD
git diff --check HEAD^ HEAD
```

Optional if you want to refresh runtime evidence:

```powershell
npm run verify:release
```

## Codex Pre-QA Evidence

- `npm run verify:release`: PASS.
- Sidecar audit: `1899` scenarios in index, `3799` protected files, `24` orphans / `5.6 MB`, dry-run only.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Build: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- AI workflow state smoke: PASS.
- AI follow-up needs smoke: PASS.
- AI confirmed context smoke: PASS.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS, no raw auth leakage.

## Static Checkpoints

1. Track A completion checklist doc exists.
2. Checklist references current public release `release-2026-05-09-cmo-lua-builder-local-confirmed-context`.
3. Checklist references A1 Template Inspector Search / Filter UX.
4. Checklist references A2 AI Drafting Workflow.
5. Checklist references A3 Local Confirmed Context Workspace.
6. Checklist records Template Inspector annotations `51 / 51`, `0` missing.
7. Checklist records A2 workflow state and follow-up needs as completed.
8. Checklist records A3 confirmed context as completed.
9. Checklist marks Track A complete as a local AI interpreter UI baseline.
10. Checklist explicitly does not claim CMO Lua execution.
11. Checklist explicitly does not claim live CMO read-back.
12. Checklist explicitly does not claim CMO scenario folder writes.
13. Checklist explicitly does not claim CMO log tailing.
14. Checklist recommends B0 CMO Integration Probe as the next Track B step.
15. Checklist records `npm run verify:release` PASS.
16. Checklist records the expanded 9-step verification chain.
17. Checklist records Main JS `377.99 kB`, Main CSS `59.14 kB`, and `aiContextPruning` `8.56 kB`.
18. Checklist records scenario baseline `1899 / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
19. Checklist records sidecar audit `3799` protected and `24` orphans / `5.6 MB`.
20. Inventory includes a matching Track A completion section.
21. Kimi CURRENT_TASK.md references this active QA directive.
22. Claude CURRENT_TASK.md records Track A completion checklist status and remains standby.
23. Gemini CURRENT_TASK.md records Track A completion checklist status and remains standby.
24. Target commit changes docs / handoff only.
25. `src/**`, `server/**`, `tools/**`, `public/**`, `package.json`, and `package-lock.json` are unchanged.

## Expected Verdict

Approve only if Track A is closed as a local UI baseline and all Track B capabilities remain explicitly deferred to B0+.
