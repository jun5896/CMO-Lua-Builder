# Kimi QA Request - Final Protection Group 2 AI Provider

## Scope

Read-only QA for final protection group 2: AI Provider Adapter And Model Profiles.

Codex already ran a self-verification pass. Please independently verify provider model listing, provider-default generation settings, saved model profiles, and no raw API-key persistence/regression.

Do not modify files.

## Files In Scope

- `server/.env.example`
- `server/ai-provider-adapter.mjs`
- `server/providers.mjs`
- `src/lib/aiAdapterClient.js`
- `src/lib/aiProviderProfiles.js`
- `src/components/AiAdapterSettings.jsx`
- `src/components/AiAdapterSettings.css`
- `src/components/AiProviderProfileSelector.jsx`
- `src/components/AiProviderProfileSelector.css`
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
- `AiAdapterSettings-*.js`: about `10.44 kB`
- `AiAdapterSettings-*.css`: about `2.43 kB`
- `AiProviderProfileSelector-*.js`: about `1.72 kB`
- `AiProviderProfileSelector-*.css`: about `0.75 kB`
- `aiProviderProfiles-*.js`: about `1.36 kB`

## Required Static Checks

Please confirm:

1. `server/ai-provider-adapter.mjs` exposes `POST /api/ai/models`.
2. Model list responses are passed through secret scrubbing before returning.
3. `server/providers.mjs` maps:
   - OpenAI-compatible / LM Studio to `/v1/models`
   - Ollama to `/api/tags`
4. Provider-default generation mode does not send temperature/max token fields downstream.
5. Manual generation mode still sends temperature/max tokens.
6. Saved profiles in `src/lib/aiProviderProfiles.js` do not contain an `apiKey` field.
7. `AiProviderProfileSelector` builds `providerOverride` without an `apiKey`.
8. `aiAdapterClient.settingsPayload()` includes `apiKey` only for Settings form save/test/model-list payloads when the user typed a key.
9. Manual Prompt copy fallback remains present.
10. Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.
11. `smoke:ai-adapter` confirms no raw `Bearer`, `Authorization`, or `sk-` value in adapter response/log output.

## Regression Watch

- Do not report `apiKey` references in Settings form code as a regression by itself; Settings must be able to send a typed key to the local adapter.
- Do report if saved profiles persist raw keys.
- Do report if provider override from selected profile can contain raw keys.
- Do report if `/api/ai/models` returns upstream auth details unsanitized.
- Do report if main JS rises near `400 kB` or main CSS rises above `60 kB`.

## Report Format

Please report:

- Pipeline table
- Bundle table
- Provider/model-list static checkpoint table
- Security boundary table
- Regressions, or `none`

Kimi should remain read-only for this pass.
