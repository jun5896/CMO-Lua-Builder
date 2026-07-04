# Kimi QA Request - Final Protection Group 3 AI Assistant

## Scope

Read-only QA for final protection group 3: AI Assistant Chat, Review, And Context Pruning.

Codex already ran a self-verification pass. Please independently verify the interpreter chat loop, structured response review, paste-ready Lua gate, prompt-copy fallback, and context pruning safety layer.

Do not modify files.

## Files In Scope

- `public/cmo-ai-system-prompt.txt`
- `src/components/LuaAssistant.jsx`
- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiInterpreterChatPanel.css`
- `src/components/AiResponseReviewPanel.jsx`
- `src/components/AiResponseReviewPanel.css`
- `src/components/IntentPlannerPanel.jsx`
- `src/lib/aiContextPruning.js`
- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`

## Required Pipeline

Run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `npm run smoke:ai-adapter` reports `spawn EPERM`, report it as a sandbox spawn restriction and ask Codex/user to rerun with approval. Do not work around it with source changes.

## Expected Build Baseline

- Main JS: about `366.05 kB`
- Main CSS: about `58.27 kB`
- `AiInterpreterChatPanel-*.js`: about `10.06 kB`
- `AiInterpreterChatPanel-*.css`: about `6.19 kB`
- `AiResponseReviewPanel-*.js`: about `5.15 kB`
- `AiResponseReviewPanel-*.css`: about `3.50 kB`
- `IntentPlannerPanel-*.js`: about `5.03 kB`
- `aiContextPruning-*.js`: about `8.56 kB`, must remain under `9 kB`

## Required Static Checks

Please confirm:

1. `public/cmo-ai-system-prompt.txt` includes:
   - no invention of DBID/GUID/Loadout/object names
   - ask-back instead of placeholders
   - unsafe Lua restrictions
   - required response headings
2. `LuaAssistant.jsx` derives `canApplyAiLua` from `aiParsedResponse.isPasteReady`.
3. `applyAiLuaBlock()` returns early when `canApplyAiLua` is false.
4. Main output toolbar and AI response toolbar disable Apply buttons when `!canApplyAiLua`.
5. `AiResponseReviewPanel` receives `canApplyLua` and `onApplyLua` from the parent and cannot bypass the parent gate.
6. `AiInterpreterChatPanel` receives `canApplyLua` and `onApplyLua` from the parent and cannot bypass the parent gate.
7. Manual Prompt copy fallback remains present in the main assistant and chat panel.
8. `callAiAdapter()` blocks if `## Context Pack / Pruning Audit` is missing.
9. `callAiAdapter()` runs `applyContextPruning()` before `applyContextPruningAudit()`.
10. Context pruning `hardBlock` and audit `failures` stop before `sendCmoAiPrompt()`.
11. `aiContextPruning.js` preserves DBID/GUID hints and emits `confirmedIdentifiersStripped` hard block if they disappear.
12. `AiResponseReviewPanel` follow-up action only drafts a retry/chat instruction; it does not auto-send or auto-apply Lua.
13. `AiInterpreterChatPanel` composed prompt reinforces required headings, ask-back behavior, and paste-ready-only Lua.
14. Chat history is module-memory only, capped at `5`, and does not use `localStorage` or `sessionStorage`.
15. `smoke:ai-adapter` confirms no raw `Bearer`, `Authorization`, or `sk-` value in adapter response/log output.

## Regression Watch

- Report if any Lua apply path no longer depends on `isPasteReady`.
- Report if `Prompt 복사` fallback disappears.
- Report if context pruning failure can fall through to an AI call.
- Report if DBID/GUID hints are pruned without a hard block.
- Report if `aiContextPruning-*.js` exceeds `9 kB`.
- Report if main CSS rises above `60 kB` or main JS rises near `400 kB`.

## Report Format

Please report:

- Pipeline table
- Bundle table
- AI safety/static checkpoint table
- Context pruning checkpoint table
- Regressions, or `none`

Kimi should remain read-only for this pass.
