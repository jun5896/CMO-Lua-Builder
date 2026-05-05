# Kimi QA Request — AI Provider Model Profiles / Assistant Selection

## Context

Codex connected the existing AI provider model/profile work into the Event/Lua Assistant call path.

Touched files in this pass:

- `server/ai-provider-adapter.mjs`
- `src/lib/aiAdapterClient.js`
- `src/components/LuaAssistant.jsx`
- `src/index.css`

Pre-existing related files to keep in scope:

- `server/providers.mjs`
- `src/components/AiAdapterSettings.jsx`
- `src/components/AiAdapterSettings.css`
- `src/lib/aiProviderProfiles.js`

## New Behavior

- Settings already supports `모델 목록 불러오기` through `POST /api/ai/models`.
- OpenAI-compatible / LM Studio list models through upstream `GET /v1/models`.
- Ollama lists models through upstream `GET /api/tags`.
- Settings can save multiple provider/model profiles without storing raw API keys.
- Event/Lua Assistant now has an AI model profile selector in the AI Adapter readiness panel.
- Selecting a profile sends provider/baseUrl/model/generation settings as `providerOverride` for AI calls.
- The adapter still uses its in-memory API key; raw keys are not stored in localStorage profiles.
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

- `index-*.js`: `399.28 kB`
- `index-*.css`: `64.18 kB`
- `AiAdapterSettings-*.js`: `10.87 kB`
- `AiAdapterSettings-*.css`: `2.05 kB`
- `AiResponseReviewPanel-*.js`: `4.12 kB`
- `AiResponseReviewPanel-*.css`: `2.42 kB`
- `AiInterpreterChatPanel-*.js`: `5.34 kB`
- `AiInterpreterChatPanel-*.css`: `3.30 kB`

Watch note:

- `index-*.js` is still under the `400 kB` watch line, but the margin is small.
- Please report any further JS increase clearly.

## Functional Checks

1. Confirm `POST /api/ai/models` still exists in `server/ai-provider-adapter.mjs`.
2. Confirm `server/providers.mjs` maps:
   - OpenAI-compatible / LM Studio to `/v1/models`
   - Ollama to `/api/tags`
3. Confirm `src/lib/aiAdapterClient.js` sends `providerOverride` only when options include it.
4. Confirm saved profiles do not include raw `apiKey`.
5. Confirm Event/Lua Assistant profile selector appears in the AI Adapter readiness panel.
6. Confirm selecting a profile does not remove the manual Prompt copy fallback.
7. Confirm AI calls still block when no model is available.
8. Confirm `Lua 적용` remains gated by `isPasteReady === true`.
9. Confirm smoke output does not leak raw `Bearer` or `sk-` tokens.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not install packages.
- Report only actionable regressions, bundle deltas, and security smoke changes.
