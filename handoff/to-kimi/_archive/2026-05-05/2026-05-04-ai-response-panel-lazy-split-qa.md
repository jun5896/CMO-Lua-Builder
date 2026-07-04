# Kimi QA Request — AI Response Review Panel Lazy Split

## Context

Codex split the structured AI response review UI out of `LuaAssistant.jsx` into a lazy component:

- `src/components/AiResponseReviewPanel.jsx`
- `src/components/AiResponseReviewPanel.css`

`LuaAssistant.jsx` now lazy-loads this panel only when:

- `Output & Validation`
- `AI 응답` tab
- `aiResponse` exists

The goal is to reduce the main bundle before the next AI chat/interpreter UI work.

## Please Run

From `C:\Users\dlwls\.codex\cmo-lua-ui`:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `npm run smoke:ai-adapter` fails with `spawn EPERM`, classify it as sandbox/environment unless adapter output shows an auth leak.

## Expected Current Build From Codex

- `index-*.js`: `396.14 kB`
- `index-*.css`: `63.81 kB`
- `AiResponseReviewPanel-*.js`: `3.01 kB`
- `AiResponseReviewPanel-*.css`: `2.32 kB`
- `AiAdapterSettings-*.js`: `10.87 kB`
- `AiAdapterSettings-*.css`: `2.05 kB`

Previous baseline before this split:

- `index-*.js`: `398.93 kB`
- `index-*.css`: `65.99 kB`

## Functional Checks

1. Confirm `AiResponseReviewPanel-*.js` and `AiResponseReviewPanel-*.css` are separate lazy chunks.
2. Confirm `Output & Validation > AI 응답` still renders the structured cards when `aiResponse` exists:
   - paste-ready card
   - section/blocker/warning/Lua counters
   - Assumptions
   - CMO UI prerequisites
   - Validation checklist
   - Follow-up / blockers
3. Confirm `Lua 적용` remains gated by `isPasteReady === true`.
4. Confirm manual `Prompt 복사` fallback remains available.
5. Confirm no raw API key/auth leak in smoke output.
6. Report if `index-*.js` crosses the `400 kB` watch line.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not install packages.
- Report only actionable regressions, bundle deltas, and security smoke changes.
