# Kimi QA Request — AI Context Pruning Judge-Only Pass

Status: ready for QA after Codex implementation.
Owner boundary: Kimi validates only. Do not edit `src/**`, `server/**`, `tools/**`, `package.json`, or handoff files.

## What changed

Codex implemented Context Pruning phase 2 as a **judge-only** layer.

Touched files:

- `src/components/LuaAssistant.jsx`
- `src/lib/aiContextPruning.js`

Important behavior:

- Actual prompt pruning is still not active.
- `src/lib/aiContextPruning.js` is dynamically imported only when an AI call is sent.
- The module replaces the lightweight `## Context Pack / Pruning Audit` section with a richer v2 audit.
- The v2 audit classifies intent and records planned omissions, summaries, missing requirements, ask-back state, and safety markers.
- Existing full prompt sections remain preserved.
- AI calls are blocked if the Context Pack section is missing or secret-like text is detected.
- `isPasteReady === true` remains the only Lua apply path.

## Codex verification baseline

- `npm run lint`: PASS
- `npm run build`: PASS
- `npm run smoke:ai-adapter`: PASS
- Main JS: `index-*.js` around `399.68 kB`
- Main CSS: `index-*.css` around `64.08 kB`
- New lazy/dynamic chunk: `aiContextPruning-*.js` around `2.77 kB`

Previous lightweight baseline:

- Main JS was around `399.07 kB`
- This pass adds about `0.61 kB` to main JS and creates the dynamic pruning chunk.

## QA commands

Run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` fails with `spawn EPERM`, report it as sandbox/environment unless Codex explicitly asks for backend review.

## Static checks

Verify:

1. `src/lib/aiContextPruning.js` exists and exports `applyContextPruningAudit()`.
2. Build output includes a separate `aiContextPruning-*.js` chunk.
3. `src/components/LuaAssistant.jsx` uses `await import('../lib/aiContextPruning')` inside the AI call path.
4. `applyContextPruningAudit()` emits v2 audit fields:
   - `intent`
   - `actualOmit=none`
   - `plannedOmit`
   - `pruning=judge-only`
   - `missing`
   - `askBack`
   - `safety`
5. Existing full prompt sections remain present.
6. AI call is blocked when the Context Pack section is missing.
7. AI call is blocked when `applyContextPruningAudit()` reports failures.
8. Lua apply remains gated by `aiParsedResponse.isPasteReady`.
9. Provider profile override still flows through `sendCmoAiPrompt()`.
10. No raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` was added to the context-pruning path.

## Report format

Return:

- Pipeline pass/fail.
- Bundle sizes and delta from `399.07 kB` JS / `64.08 kB` CSS baseline.
- Whether `aiContextPruning-*.js` is a separate chunk.
- Whether the pass is truly judge-only and does not remove prompt sections.
- Whether any actionable regression exists.

Flag JS watch-line risk if main JS crosses 400 kB or leaves less than 0.25 kB margin.
