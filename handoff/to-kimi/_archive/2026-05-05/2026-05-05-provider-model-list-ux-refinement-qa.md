# Kimi QA Request - Provider Model List UX Refinement

## Context

Codex made a small Settings > AI Adapter UX pass after the provider profile selector polish.

Changed files:

- `src/components/AiAdapterSettings.jsx`
- `src/components/AiAdapterSettings.css`

## What Changed

- Selecting a model from the `Provider models` dropdown now also adds that model to the multi-select chip list.
- The loaded model picker now shows:
  - total model count,
  - save-target count,
  - `key 미저장` reminder.
- Added `전체 선택` and `선택 해제` buttons for fetched provider models.
- Added a short save hint explaining whether selected chips or the current `Model` field will be saved.
- Renamed the bulk-save button to `선택 모델 프로필 저장`.
- Disabled the bulk-save button when there is no selected model and no manual `Model` value.
- Added compact CSS inside the lazy `AiAdapterSettings` chunk only.

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
2. Main `index-*.js` remains under `400 kB`.
3. Main `index-*.css` stays unchanged near the current `64.08 kB` baseline.
4. `aiContextPruning-*.js` remains unchanged near the current `8.56 kB` baseline.
5. `AiAdapterSettings-*.js` and `AiAdapterSettings-*.css` may grow slightly because this is Settings-only lazy UI.
6. Selecting a model in the dropdown sets the `Model` field and marks that model chip selected.
7. `전체 선택` selects all fetched models; `선택 해제` clears selected chips.
8. Bulk save uses selected chips when present, otherwise the current `Model` field.
9. API key is still not stored in model profiles.
10. Manual prompt-copy fallback and `isPasteReady` Lua apply gate remain unaffected.
11. No raw `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, or `sessionStorage` is newly introduced in this pass.

## Expected Local Baseline From Codex

Codex local QA before handoff:

- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS after sandbox escalation.
- Main JS: `395.60 kB`.
- Main CSS: `64.08 kB`.
- `AiAdapterSettings` lazy chunk: `10.45 kB JS`, `2.33 kB CSS`.
- `AiProviderProfileSelector` lazy chunk: `1.72 kB JS`, `0.75 kB CSS`.
- `aiContextPruning`: `8.56 kB`.

## Report Format

Report only:

- Pass/fail for each pipeline step.
- Bundle sizes and watch-line status.
- Any actionable regression.
- Any critical untracked source file note.

No broad refactor recommendations unless a regression is found.
