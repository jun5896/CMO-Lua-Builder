# Kimi QA Request: AI Context Pruning Visibility Pass

## Context

Codex added a compact Context Pruning visibility card after the Phase 3 transform pass.

The goal is not to expand pruning scope yet. This pass only makes the latest pruning result visible in the AI review surfaces so users can see what was omitted or summarized before we prune larger object/mission/unit sections.

## Files touched by this pass

- `src/components/LuaAssistant.jsx`
- `src/components/AiResponseReviewPanel.jsx`
- `src/components/AiResponseReviewPanel.css`
- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiInterpreterChatPanel.css`

## Expected behavior

- `LuaAssistant.jsx` stores the latest pruning result in `aiPruningAudit`.
- The audit state includes:
  - `mode`
  - `actualOmit`
  - `summarized`
  - `askBackHints`
  - `tokens`
  - `tokenLimit`
  - `hardBlock`
  - `failures`
- AI Response Review panel shows a compact `Context Pruning` card when a pruning result exists.
- AI Interpreter Chat panel shows the same compact `Context Pruning` card when a pruning result exists.
- Failed pruning/audit attempts should display warning styling and the `hardBlock` or audit failure reason.
- No pruning logic change was made in this pass.

## Fresh Codex verification already run

Commands:

- `npm run lint` -> PASS
- `npm run build` -> PASS
- `npm run smoke:ai-adapter` -> PASS after expected sandbox `spawn EPERM` rerun outside sandbox

Fresh build sizes:

- `index-*.js`: `395.51 kB`
- `index-*.css`: `64.08 kB`
- `AiResponseReviewPanel-*.js`: `5.15 kB`
- `AiResponseReviewPanel-*.css`: `3.50 kB`
- `AiInterpreterChatPanel-*.js`: `8.75 kB`
- `AiInterpreterChatPanel-*.css`: `5.73 kB`
- `aiContextPruning-*.js`: `5.33 kB`

Mini functional check:

- Phase 3 pruning still removes non-active Lua bundle body.
- Active Lua remains present.
- Audit still includes `pruning=phase3`.
- `actualOmit=nonActiveLuaFile.body` remains possible.

## QA checklist

1. Run `git status --short`.
2. Run `npm run lint`.
3. Run `npm run build`.
4. Run `npm run smoke:ai-adapter`.
5. Confirm main JS remains below the 400 kB watch line.
6. Confirm `aiContextPruning-*.js` remains under 8 kB.
7. Confirm `AiResponseReviewPanel` receives and renders `pruningAudit`.
8. Confirm `AiInterpreterChatPanel` receives and renders `pruningAudit`.
9. Confirm `LuaAssistant.jsx` sets `aiPruningAudit` after successful pruning/audit.
10. Confirm `LuaAssistant.jsx` also records `hardBlock` or audit failures for blocked calls.
11. Confirm `isPasteReady` Lua apply gate remains unchanged.
12. Confirm no new `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` usage was added to the visibility pass.

## Report format requested

Please report:

- pass/fail for lint/build/smoke
- fresh bundle sizes
- visibility card source confirmation
- whether the pruning/audit call order remains unchanged
- any actionable regression only
