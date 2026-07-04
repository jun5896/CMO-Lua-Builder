# Kimi QA Directive - AI Drafting Workflow State

## Target

Review product commit:

```text
eb689df Align AI drafting workflow state
```

Track:

```text
Track A2-1 - Workflow State Contract + UI Wording Alignment
```

## Scope

Product/local UI only:

- `package.json`
- `src/lib/aiWorkflowState.js`
- `tools/verify-ai-workflow-state-contract.mjs`
- `src/components/LuaAssistant.jsx`
- `src/components/AiResponseReviewPanel.jsx`
- `src/components/AiResponseReviewPanel.css`
- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiInterpreterChatPanel.css`
- `src/index.css`

No Track B behavior is expected.

## Codex Pre-QA Verification

Codex ran:

```powershell
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
git diff --check
```

Observed:

- `smoke:ai-workflow-state`: PASS.
- `lint`: PASS.
- `build`: PASS after sandbox `spawn EPERM` rerun via approved escalation.
- `smoke:ai-client-parser`: PASS.
- `smoke:ai-adapter`: PASS, no raw Bearer / Authorization / sk-key leakage.
- `git diff --check`: PASS, only CRLF warnings.

Bundle baseline from Codex build:

```text
Main JS:              371.44 kB  (< 400 kB)
Main CSS:              59.14 kB  (< 60 kB)
aiContextPruning:       8.56 kB  (< 9 kB)
AiInterpreterChat JS:  10.38 kB
AiInterpreterChat CSS:  6.73 kB
AiResponseReview JS:    5.25 kB
AiResponseReview CSS:   3.69 kB
```

Note:

- Main CSS is now close to the soft line: `59.14 kB`, about `0.86 kB` below `60 kB`.
- Kimi should report any drift above `60 kB`.

## Required QA Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

If `npm run build` or `npm run smoke:ai-adapter` hits sandbox `spawn EPERM`, rerun through the approved escalation path and note it in the report.

## Static Checkpoints

1. `src/lib/aiWorkflowState.js` exists.
2. It exports `AI_WORKFLOW_STATES` and `deriveAiWorkflowState`.
3. State ids are exactly `idle`, `calling`, `ready`, `askBack`, `blocked`, `error`.
4. `calling` wins over stale ready response.
5. Pruning hard block / failure wins over stale ready response.
6. `ready` returns `canApplyLua === true` only when `parsedResponse.isPasteReady === true`.
7. `idle`, `calling`, `askBack`, `blocked`, and `error` return `canApplyLua === false`.
8. Returned `nextActions` arrays are not shared between calls.
9. `tools/verify-ai-workflow-state-contract.mjs` covers all six states.
10. `tools/verify-ai-workflow-state-contract.mjs` covers stale ready while calling.
11. `tools/verify-ai-workflow-state-contract.mjs` covers stale ready plus pruning hard block.
12. `package.json` includes `smoke:ai-workflow-state`.
13. `package-lock.json` is unchanged.
14. `LuaAssistant.jsx` derives `canApplyAiLua` from `aiWorkflowState.canApplyLua`.
15. `LuaAssistant.jsx` still passes apply buttons through `disabled={!canApplyAiLua}`.
16. `LuaAssistant.jsx` clears stale `aiResponse` on true call/setup/pruning errors.
17. `LuaAssistant.jsx` clears stale `aiPruningAudit` at the start of a new AI call.
18. Parser non-ready AI responses remain visible as `askBack` or `blocked`.
19. Main output panel shows the workflow state card.
20. `AiResponseReviewPanel.jsx` accepts `workflowState`.
21. Review summary card uses `workflowState` title/body/tone.
22. Review follow-up button only drafts text and does not auto-send.
23. Review apply button remains disabled unless `canApplyLua`.
24. `AiInterpreterChatPanel.jsx` accepts `workflowState`.
25. Chat mode card uses shared `workflowState`.
26. Chat next actions use `workflowState.nextActions` when present.
27. Chat history may show workflow label, but history remains capped at `MAX_CHAT_HISTORY = 5`.
28. Main `Prompt 복사` fallback remains visible.
29. Chat `요청문 복사` fallback remains visible.
30. `parseAiInterpreterResponse()` contract is unchanged.
31. `src/lib/aiContextPruning.js` is unchanged.
32. No Track B behavior is introduced: no CMO scenario folder writes, no log tailing, no live read-back, no backend endpoint.
33. No new dependency or devDependency is added.
34. No new `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, or `sessionStorage` usage is introduced by this diff.
35. Main JS remains under `400 kB`.
36. Main CSS remains under `60 kB`.
37. `aiContextPruning` remains under `9 kB`.
38. AI adapter smoke reports no raw Bearer / Authorization / sk-key leakage.

## Expected Verdict

Approve only if all pipeline steps pass and every state except `ready` keeps Lua apply disabled.

If approved, report:

- Exact bundle sizes.
- Whether Main CSS is still below `60 kB`.
- Whether `smoke:ai-workflow-state` passed.
- Whether any sandbox escalation was needed for build or adapter smoke.
