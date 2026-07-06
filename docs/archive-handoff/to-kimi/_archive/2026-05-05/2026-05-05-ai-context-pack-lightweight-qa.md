# Kimi QA Request — AI Context Pack Lightweight Pass

Status: ready for QA after Codex implementation.
Owner boundary: Kimi validates only. Do not edit `src/**`, `server/**`, `tools/**`, `package.json`, or handoff files.

## What changed

Codex kept the AI Context Pack structure but compressed the in-bundle logic and prompt text to recover JS bundle headroom.

Touched file:

- `src/components/LuaAssistant.jsx`

The behavior should remain:

- `## Context Pack / Pruning Audit` is still included in AI prompt assembly.
- No actual pruning is active yet.
- Existing full prompt sections are preserved.
- AI calls are still blocked if the Context Pack audit section is missing.
- `isPasteReady === true` remains the only Lua apply path.

## Codex verification baseline

- `npm run lint`: PASS
- `npm run build`: PASS
- `npm run smoke:ai-adapter`: PASS
- Main JS: `index-*.js` around `399.07 kB`
- Main CSS: `index-*.css` around `64.08 kB`

Previous Context Pack baseline:

- Main JS was around `399.72 kB`
- This lightweight pass should reduce main JS by about `0.65 kB`

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

Verify in `src/components/LuaAssistant.jsx`:

1. `buildContextPackSection()` still exists.
2. It still emits `## Context Pack / Pruning Audit`.
3. The emitted section still contains:
   - included safety context
   - `omit=none`
   - `pruning=off`
   - `askBack`
   - safety marker including `applyGate` and `promptCopy`
4. `buildAssistantPrompt()` still places the context pack before `## Goal`.
5. `callAiAdapter()` still blocks when the context pack section is missing.
6. Existing prompt sections remain present.
7. Lua apply remains gated by `aiParsedResponse.isPasteReady`.
8. Provider profile override still flows through `sendCmoAiPrompt()`.
9. No raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` was added to the context-pack path.

## Report format

Return:

- Pipeline pass/fail.
- Bundle sizes and delta from `399.72 kB` JS / `64.08 kB` CSS baseline.
- Whether Context Pack behavior survived the lightweight pass.
- Whether any actionable regression exists.

Avoid broad refactor suggestions unless a test fails or the JS bundle crosses the 400 kB watch line.
