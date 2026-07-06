# Kimi QA Request — AI Context Pack Stub Headroom Pass

Status: ready for QA after Codex implementation.
Owner boundary: Kimi validates only. Do not edit `src/**`, `server/**`, `tools/**`, `package.json`, or handoff files.

## What changed

Codex reduced main-bundle pressure by replacing the in-component Context Pack v1 builder with a tiny stub.

Touched files:

- `src/components/LuaAssistant.jsx`

Important behavior:

- The prompt still includes `## Context Pack / Pruning Audit`.
- The prompt now contains a short v1 stub only.
- The richer v2 judge-only audit is still applied by the dynamically imported `src/lib/aiContextPruning.js` immediately before AI calls.
- Actual pruning remains off.
- Existing full prompt sections remain preserved.
- AI calls are still blocked if the Context Pack section is missing.
- `isPasteReady === true` remains the only Lua apply path.

## Codex verification baseline

- `npm run lint`: PASS
- `npm run build`: PASS
- `npm run smoke:ai-adapter`: PASS
- Main JS: `index-*.js` around `399.09 kB`
- Main CSS: `index-*.css` around `64.08 kB`
- Dynamic chunk remains: `aiContextPruning-*.js` around `2.77 kB`

Previous judge-only baseline:

- Main JS was around `399.68 kB`
- This pass should reduce main JS by about `0.59 kB`

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

1. `buildContextPackSection()` was removed from `src/components/LuaAssistant.jsx`.
2. `buildAssistantPrompt()` still emits `## Context Pack / Pruning Audit` before `## Goal`.
3. The emitted stub mentions that v2 audit is applied before AI call and `pruning=off`.
4. `src/components/LuaAssistant.jsx` still dynamically imports `../lib/aiContextPruning` inside `callAiAdapter()`.
5. `src/lib/aiContextPruning.js` remains unchanged in behavior:
   - `applyContextPruningAudit()` exists.
   - `actualOmit=none`
   - `plannedOmit`
   - `pruning=judge-only`
   - `missing`
   - `askBack`
   - `safety`
6. Existing full prompt sections remain present.
7. Context Pack section missing still blocks AI call.
8. Lua apply remains gated by `aiParsedResponse.isPasteReady`.
9. Provider profile override still flows through `sendCmoAiPrompt()`.
10. No raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` was added.

## Report format

Return:

- Pipeline pass/fail.
- Bundle sizes and delta from `399.68 kB` JS / `64.08 kB` CSS baseline.
- Whether v1 stub plus dynamic v2 audit behavior is preserved.
- Whether `aiContextPruning-*.js` remains a separate chunk.
- Whether any actionable regression exists.

Flag JS watch-line risk if main JS crosses 400 kB or leaves less than 0.25 kB margin.
