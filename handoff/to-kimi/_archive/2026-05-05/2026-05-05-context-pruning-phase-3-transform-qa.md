# Kimi QA Request: AI Context Pruning Phase 3 Transform

## Context

Codex implemented the first actual pruning transform after Claude's Phase 3 technical review.

This pass is intentionally conservative:

- Keep all safety rails, response headings, current user instruction, active Lua, provider override, prompt-copy fallback, and `isPasteReady` apply gate.
- Actually prune only the largest safe first target: non-active Lua file bodies inside `## Lua File Bundle Context`.
- Summarize long API/helper hint lines when they exceed a large threshold.
- Keep the existing judge/audit verifier as a second step after pruning.

## Files touched by this pass

- `src/lib/aiContextPruning.js`
- `src/components/LuaAssistant.jsx`

## Expected implementation shape

`src/lib/aiContextPruning.js` now exports both:

- `applyContextPruning(prompt, context)`
- `applyContextPruningAudit(prompt, context)`

`LuaAssistant.jsx` should call them in this order:

1. Build the full prompt.
2. `applyContextPruning(requestPrompt, pruningContext)`.
3. If `prunedResult.hardBlock` exists, block the AI call.
4. `applyContextPruningAudit(prunedResult.prompt, { ...pruningContext, decisions: prunedResult.decisions })`.
5. If audit failures exist, block the AI call.
6. Send only the audited prompt to `sendCmoAiPrompt()`.

## Fresh Codex verification already run

Commands:

- `npm run lint` -> PASS
- `npm run build` -> PASS
- `npm run smoke:ai-adapter` -> PASS after expected sandbox `spawn EPERM` rerun outside sandbox

Fresh build sizes:

- `index-*.js`: `395.04 kB`
- `index-*.css`: `64.08 kB`
- `aiContextPruning-*.js`: `5.33 kB`

Mini functional check:

- Two-file Lua bundle prompt was pruned.
- Non-active bundle body was removed.
- Active Lua in `## Selected Lua File` remained present.
- Audit failures were empty.

## QA checklist

1. Run `git status --short`.
2. Run `npm run lint`.
3. Run `npm run build`.
4. Run `npm run smoke:ai-adapter`.
5. Confirm `aiContextPruning-*.js` stays under `8 kB`.
6. Confirm `LuaAssistant.jsx` calls `applyContextPruning()` before `applyContextPruningAudit()`.
7. Confirm a hard block check exists between pruning and audit.
8. Confirm `## Lua File Bundle Context` pruning does not remove `## Selected Lua File` or `## Current Lua`.
9. Confirm audit output can show `actualOmit=nonActiveLuaFile.body` and `pruning=phase3` when bundle pruning happens.
10. Confirm `Lua apply` still depends only on `aiParsedResponse.isPasteReady`.
11. Confirm provider profile override still flows through `sendCmoAiPrompt()`.
12. Confirm no new `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` usage was added to pruning logic.

## Report format requested

Please report:

- pass/fail for lint/build/smoke
- fresh bundle sizes
- `aiContextPruning` chunk size
- whether call order is correct
- whether active Lua preservation is confirmed
- any actionable regression only
