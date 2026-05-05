# Kimi QA Request — AI Settings CSS Lazy Split

## Context

Codex moved AI Adapter Settings-only CSS out of `src/index.css` into:

- `src/components/AiAdapterSettings.css`

`src/components/AiAdapterSettings.jsx` now imports that CSS directly. Because `AiAdapterSettings` is lazy-loaded from `src/App.jsx`, the goal is to keep Event/Lua Assistant main CSS smaller while preserving the Settings > AI Adapter UI.

## Please Run

From `C:\Users\dlwls\.codex\cmo-lua-ui`:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `npm run smoke:ai-adapter` fails with `spawn EPERM`, report it as sandbox/environment unless the adapter output itself shows a security leak.

## Checkpoints

1. Confirm lint/build/smoke all pass.
2. Report bundle sizes from `npm run build`, especially:
   - `dist/assets/index-*.css`
   - `dist/assets/AiAdapterSettings-*.css`
   - `dist/assets/index-*.js`
3. Confirm `AiAdapterSettings-*.css` exists as a separate chunk.
4. Confirm Event/Lua Assistant AI status/readiness UI is still styled even before opening Settings.
5. Confirm Settings > AI Adapter tab is still styled after opening the AI settings panel.
6. Report only actionable regressions. Do not propose broad refactors in this pass.

## Boundaries

- Do not edit `src/**`.
- Do not commit.
- Do not delete generated sidecars/cache files.
- Do not install new packages.

## Expected Result

The main CSS should be smaller than the previous `66.98 kB` baseline, with AI settings styles moved into a separate lazy CSS asset.
