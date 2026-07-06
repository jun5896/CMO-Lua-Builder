# Kimi QA Request — AI Context Pack Structure Pass

Status: ready for QA after Codex implementation.
Owner boundary: Kimi validates only. Do not edit `src/**`, `server/**`, `tools/**`, `package.json`, or handoff files.

## What changed

Codex implemented the first Context Pruning preparation pass in `src/components/LuaAssistant.jsx`.

This is intentionally **structure-only**:

- AI prompts now include a `## Context Pack / Pruning Audit` section.
- No aggressive pruning is active yet.
- Existing prompt sections remain present.
- AI calls are blocked if the Context Pack audit section is missing from the request prompt.
- `isPasteReady === true` remains the only Lua apply path.

## Expected fresh-build baseline from Codex

- `npm run lint`: PASS
- `npm run build`: PASS
- `npm run smoke:ai-adapter`: PASS
- Main JS: `index-*.js` around `399.72 kB`
- Main CSS: `index-*.css` around `64.08 kB`
- Existing lazy chunks should still be present:
  - `AiAdapterSettings-*.js/css`
  - `AiResponseReviewPanel-*.js/css`
  - `AiInterpreterChatPanel-*.js/css`
  - `AiProviderProfileSelector-*.js/css`

## QA commands

Run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` fails with `spawn EPERM`, report it as sandbox/environment unless Codex explicitly asks for deeper backend review.

## Static checks

Verify in `src/components/LuaAssistant.jsx`:

1. `buildContextPackSection()` exists and emits `## Context Pack / Pruning Audit`.
2. `buildAssistantPrompt()` includes the context pack before `## Goal`.
3. `callAiAdapter()` blocks calls when the prompt no longer contains `## Context Pack / Pruning Audit`.
4. Existing full prompt sections are still present:
   - `## Goal`
   - `## In-Game Context`
   - `## Scenario Container Context`
   - `## Registered CMO Objects`
   - `## Database / Clipboard Context`
   - `## User Intent`
   - `## Generated Lua Draft`
   - `## Detected API/Trigger Hints`
5. Placeholder/prior blocker data only sets `askBack`; it must not enable Lua apply.
6. Lua apply remains gated by `aiParsedResponse.isPasteReady`.
7. Provider profile override still flows through `sendCmoAiPrompt()`.
8. No raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` was added to the Context Pack path.

## Report format

Return:

- Pipeline pass/fail.
- Bundle sizes and delta from Codex baseline.
- Whether the Context Pack section is present in prompt assembly.
- Whether full prompt inclusion is preserved.
- Whether any actionable regression exists.

Avoid broad refactor suggestions unless a test fails or the JS bundle crosses the 400 kB watch line by more than measurement noise.
