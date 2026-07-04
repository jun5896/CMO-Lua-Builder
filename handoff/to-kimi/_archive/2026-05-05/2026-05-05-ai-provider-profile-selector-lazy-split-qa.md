# Kimi QA Request — AI Provider Profile Selector Lazy Split

## Context

Codex split the Event/Lua Assistant AI provider profile selector out of the main `LuaAssistant.jsx` bundle.

Touched files in this pass:

- `src/components/LuaAssistant.jsx`
- `src/index.css`
- `src/components/AiProviderProfileSelector.jsx` (new)
- `src/components/AiProviderProfileSelector.css` (new)

## New Behavior

- `AiProviderProfileSelector` is now lazy-loaded from the AI Adapter readiness panel.
- The selector reads saved model profiles from localStorage only inside its lazy chunk.
- The main `LuaAssistant.jsx` keeps only the selected `providerOverride` object.
- AI calls still pass selected profile settings through `providerOverride`.
- Raw API keys are still not stored in profiles or passed through the selector.
- If no profile is selected, AI calls use the current adapter settings exactly as before.
- `Lua 적용` safety remains controlled only by `isPasteReady === true`.

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

- `index-*.js`: `398.17 kB`
- `index-*.css`: `64.08 kB`
- `AiProviderProfileSelector-*.js`: `1.64 kB`
- `AiProviderProfileSelector-*.css`: `0.30 kB`
- `AiAdapterSettings-*.js`: `10.87 kB`
- `AiAdapterSettings-*.css`: `2.05 kB`
- `AiResponseReviewPanel-*.js`: `4.12 kB`
- `AiResponseReviewPanel-*.css`: `2.42 kB`
- `AiInterpreterChatPanel-*.js`: `5.34 kB`
- `AiInterpreterChatPanel-*.css`: `3.30 kB`

Previous baseline before this split:

- `index-*.js`: `399.28 kB`
- `index-*.css`: `64.18 kB`

Expected effect:

- Main JS should decrease by about `1.1 kB`.
- Main CSS should decrease slightly.
- A new `AiProviderProfileSelector` lazy JS/CSS chunk should exist.

## Functional Checks

1. Confirm `AiProviderProfileSelector` is lazy-loaded from `LuaAssistant.jsx`.
2. Confirm profile selector still appears in the AI Adapter readiness panel after lazy load.
3. Confirm selecting a profile still updates `providerOverride` for AI calls.
4. Confirm clearing selection uses the current adapter settings as before.
5. Confirm saved profiles do not include raw `apiKey`.
6. Confirm manual Prompt copy fallback remains available.
7. Confirm `Lua 적용` remains disabled unless `isPasteReady === true`.
8. Confirm smoke output does not leak raw `Bearer` or `sk-` tokens.
9. Report if `index-*.js` crosses the `400 kB` watch line.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not install packages.
- Report only actionable regressions, bundle deltas, and security smoke changes.
