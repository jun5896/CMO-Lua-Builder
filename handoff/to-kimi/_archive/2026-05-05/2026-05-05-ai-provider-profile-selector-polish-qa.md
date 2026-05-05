# Kimi QA Request - AI Provider Profile Selector Polish

## Context

Codex made a small Event / Lua Assistant profile-selector polish pass after Context Pruning Phase 3 closeout.

Changed files:

- `src/components/AiProviderProfileSelector.jsx`
- `src/components/AiProviderProfileSelector.css`

Related existing file:

- `src/lib/aiProviderProfiles.js`

## What Changed

- `AiProviderProfileSelector` now reads saved profiles through the shared `readAiProviderProfiles()` utility instead of duplicating localStorage parsing.
- The assistant-side selector now shows a compact profile summary:
  - no profile selected: Settings default model is active.
  - profile selected: provider type, model, generation mode, and `key 미저장`.
- Refresh button label was shortened to `새로고침`.
- Responsive CSS was added so the selector summary wraps more safely on narrow widths.

## QA Pipeline

Run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits sandbox `spawn EPERM`, rerun it outside sandbox as usual.

## Checkpoints

1. `lint`, `build`, and `smoke:ai-adapter` pass.
2. No raw `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, or `sessionStorage` is newly introduced in `AiProviderProfileSelector.jsx`.
3. Selecting a saved profile still sends a provider override without an API key.
4. Selecting the empty option still falls back to current Settings model.
5. `새로고침` reloads localStorage profiles and clears an active profile if it was deleted.
6. Event / Lua Assistant manual prompt-copy fallback remains present.
7. Lua apply gate remains controlled by `aiParsedResponse.isPasteReady === true`.
8. Bundle report should include:
   - main `index-*.js`
   - main `index-*.css`
   - `AiProviderProfileSelector-*.js`
   - `AiProviderProfileSelector-*.css`
   - shared `aiProviderProfiles-*.js` if emitted
   - `aiContextPruning-*.js` unchanged near the current baseline.

## Expected Local Baseline From Codex

Codex local QA before handoff:

- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS after sandbox escalation.
- Main JS: `395.60 kB`.
- Main CSS: `64.08 kB`.
- `AiProviderProfileSelector` lazy chunk: `1.72 kB JS`, `0.75 kB CSS`.
- Shared `aiProviderProfiles` chunk: `1.36 kB JS`.
- `aiContextPruning`: `8.56 kB`.

## Report Format

Report only:

- Pass/fail for each pipeline step.
- Bundle sizes and watch-line status.
- Any actionable regression.
- Any critical untracked source file note.

No broad refactor recommendations unless a regression is found.
