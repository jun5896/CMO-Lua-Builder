# Kimi QA Directive - AI Follow-Up Needs Review

Status: active QA request

## Target

Primary product commit:

```text
b32c780 Add AI follow-up needs review
```

Supporting contract commit:

```text
64683a0 Add AI follow-up needs contract
```

Planning references:

```text
f587645 Add AI follow-up needs design
688b611 Add AI follow-up needs implementation plan
```

## Scope

Track A2-2 local AI interpreter/editor UI improvement.

This slice adds grouped CMO confirmation needs for blocked / ask-back AI responses and strengthens the review-panel follow-up draft. It does not open Track B behavior.

Changed product / test files:

- `src/lib/aiFollowUpNeeds.js`
- `tools/verify-ai-follow-up-needs-contract.mjs`
- `package.json`
- `src/components/AiResponseReviewPanel.jsx`
- `src/components/AiResponseReviewPanel.css`

Expected no-change areas:

- `src/lib/aiContextPruning.js`
- `src/lib/aiAdapterClient.js`
- `src/components/LuaAssistant.jsx`
- `src/components/AiInterpreterChatPanel.jsx`
- `src/index.css`
- `server/**`
- `public/**`
- `package-lock.json`

## Codex Pre-QA Evidence

Pipeline already run by Codex:

- `npm run smoke:ai-follow-up-needs`: PASS.
- `npm run smoke:ai-workflow-state`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:ai-adapter`: PASS after approved rerun for Windows sandbox `spawn EPERM`; no raw Bearer / Authorization / sk-key leakage.

Observed build output:

- Main JS: `371.44 kB`
- Main CSS: `59.14 kB`
- aiContextPruning: `8.56 kB`
- AiResponseReviewPanel JS: `10.08 kB`
- AiResponseReviewPanel CSS: `5.23 kB`

Main CSS remains under the `60 kB` soft line but still close. Report any rise above `60 kB`.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

If `npm run build` or `npm run smoke:ai-adapter` hits Windows sandbox `spawn EPERM`, rerun the same command with approved permissions and record that escalation as environmental.

## Static Checkpoints

1. `src/lib/aiFollowUpNeeds.js` exists.
2. It exports `FOLLOW_UP_NEED_CATEGORIES`, `deriveAiFollowUpNeeds`, and `formatFollowUpNeedsForPrompt`.
3. Categories include Side, Mission, Unit GUID, DBID, Loadout, RP / Zone, Posture / Doctrine / EMCON, Coordinates, Weather, Response Format, and Unsafe Lua.
4. Category severities are limited to `confirm`, `format`, and `safety`.
5. Duplicate evidence does not duplicate categories.
6. Returned category arrays and evidence arrays are mutation-safe across calls.
7. Empty parsed response returns `hasNeeds === false` and summary `확인 필요값 없음`.
8. `formatFollowUpNeedsForPrompt()` includes no-invention wording such as `추측하지 말 것`.
9. `package.json` includes `smoke:ai-follow-up-needs`.
10. `package-lock.json` is unchanged.
11. `AiResponseReviewPanel.jsx` imports and derives follow-up needs.
12. Review panel renders `CMO에서 확인할 값`.
13. Review panel limits visible categories to 6 with `.slice(0, 6)`.
14. Evidence is hidden behind `<details>`.
15. Empty / uncategorized blocked state has a user-facing fallback message.
16. Follow-up draft includes grouped needs via `formatFollowUpNeedsForPrompt(followUpNeeds)`.
17. Follow-up draft remains text-only and is not sent automatically.
18. `onDraftFollowUp` still only drafts into existing flow.
19. Lua apply remains controlled by parent `canApplyLua`.
20. Apply button remains disabled when `!canApplyLua`.
21. `parseAiInterpreterResponse()` contract is unchanged.
22. `src/lib/aiContextPruning.js` is unchanged.
23. `src/index.css` is unchanged; new styling is scoped to lazy `AiResponseReviewPanel.css`.
24. No CMO filesystem write, sidecar writer, log tailing, live read-back, or backend endpoint is introduced.
25. No new dependency, devDependency, or package-lock drift.
26. No new `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, or `sessionStorage` behavior is introduced.
27. `npm run smoke:ai-follow-up-needs` covers all 11 categories, empty state, prompt formatting, duplicate handling, and mutation safety.
28. `npm run smoke:ai-workflow-state` remains PASS.
29. `npm run smoke:ai-client-parser` remains PASS.
30. `npm run smoke:ai-adapter` reports no raw Bearer / Authorization / sk-key leakage.
31. Main JS remains under `400 kB`.
32. Main CSS remains under `60 kB`.
33. aiContextPruning remains under `9 kB`.
34. Track B remains deferred.

## Report Format

Please report:

- Pipeline results.
- Bundle table.
- Static checkpoint table.
- Any regression or drift.
- Final verdict.

Do not edit files and do not commit during QA.

## Kimi QA Result - APPROVED / ARCHIVED

Target:

```text
b32c780 Add AI follow-up needs review
64683a0 Add AI follow-up needs contract
```

Pipeline:

- `git status --short --branch`: clean (`main...origin/main`).
- `npm run smoke:ai-follow-up-needs`: PASS.
- `npm run smoke:ai-workflow-state`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS (`725ms`).
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, no auth leakage.
- Sandbox escalation: not needed.

Bundle:

- Main JS: `371.44 kB` (`< 400 kB`) PASS.
- Main CSS: `59.14 kB` (`< 60 kB`) PASS, `0.86 kB` headroom.
- aiContextPruning: `8.56 kB` (`< 9 kB`) PASS.
- AiResponseReviewPanel JS: `10.08 kB`.
- AiResponseReviewPanel CSS: `5.23 kB`.

Static checkpoints:

- `34 / 34` PASS.
- 11 follow-up need categories are present.
- Severity set is limited to `confirm`, `format`, and `safety`.
- Duplicate handling, mutation safety, empty state, and no-invention prompt formatting passed.
- Review panel renders `CMO에서 확인할 값`, limits visible categories to 6, and hides evidence behind `<details>`.
- Follow-up draft remains text-only and is not auto-sent.
- Lua apply remains parent-controlled by `canApplyLua`.
- Parser, pruning, adapter, sidecar, backend, lockfile, credential, and storage boundaries remain unchanged.
- Track B remains deferred.

Final verdict:

```text
APPROVED - AI follow-up needs review holds.
```

Regression: none.
