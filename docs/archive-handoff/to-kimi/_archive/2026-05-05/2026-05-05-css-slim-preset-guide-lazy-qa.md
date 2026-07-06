# Kimi QA Request — CSS Slim / Preset Guide Lazy Split

## Context

Codex performed a CSS slim pass after the handoff cleanup and provider/chat polishing work. The goal was to reduce the main CSS watch-line pressure without changing Event/Lua Assistant safety behavior.

Primary change:

- `PresetGuide` is now lazy-loaded from `src/App.jsx`.
- Preset Guide-only styles moved from `src/index.css` into `src/components/PresetGuide.css`.
- `src/components/PresetGuide.jsx` imports `./PresetGuide.css`.
- `.ai-settings-grid` moved from global `src/index.css` into `src/components/AiAdapterSettings.css`.

No intentional changes to AI response parsing, Lua apply gates, provider model calls, context pruning, scenario loader, or sidecar migration.

## Codex Verification

Run completed:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Observed result:

- `npm run lint`: PASS
- `npm run build`: PASS
- `npm run smoke:ai-adapter`: PASS, no Bearer / sk-key leak
- First smoke attempt hit sandbox `spawn EPERM`; Codex reran the same command with approval because the harness needs to spawn a local mock server.

## Codex Fresh Build Sizes

```text
index-*.js                       366.05 kB
index-*.css                       58.27 kB
PresetGuide-*.js                  30.05 kB
PresetGuide-*.css                  5.86 kB
AiAdapterSettings-*.js            10.44 kB
AiAdapterSettings-*.css            2.43 kB
AiInterpreterChatPanel-*.js       10.06 kB
AiInterpreterChatPanel-*.css       6.19 kB
AiResponseReviewPanel-*.js         5.15 kB
AiResponseReviewPanel-*.css        3.50 kB
aiContextPruning-*.js              8.56 kB
AiProviderProfileSelector-*.js     1.72 kB
AiProviderProfileSelector-*.css    0.75 kB
```

Watch-line impact:

- Main JS: `395.60 kB -> 366.05 kB`
- Main CSS: `64.08 kB -> 58.27 kB`
- Main CSS is now below the local soft `~60 kB` watch line.
- Preset Guide is now a separate lazy chunk: `30.05 kB JS / 5.86 kB CSS`.

## Required QA Pipeline

Please run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If the smoke test reports `spawn EPERM`, report it as sandbox spawn restriction and ask Codex/user to rerun with approval. Do not change source files.

## Checkpoints

1. `lint`, `build`, and `smoke:ai-adapter` pass.
2. `dist/assets/PresetGuide-*.js` and `dist/assets/PresetGuide-*.css` exist.
3. `index-*.css` is near `58.27 kB` and below the previous `64.08 kB` baseline.
4. `index-*.js` remains under `400 kB`; expected near `366.05 kB`.
5. Preset Guide tab still lazy-loads under `Suspense` and renders after selecting the `Preset Guide` workspace tab.
6. Event/Lua Assistant first-load UI still keeps global styles for always-visible surfaces.
7. Settings > AI Adapter still renders correctly after opening the Settings tab, including `.ai-settings-grid`.
8. Manual `Prompt 복사` fallback remains present.
9. Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.
10. `aiContextPruning-*.js` remains near `8.56 kB`; no pruning behavior changes expected.
11. AI adapter smoke confirms no raw `Bearer`, `sk-`, or upstream auth leak in response/log.

## Regression Watch

- Preset Guide layout: check that tabs, encyclopedia, custom preset list, and builder panel do not lose styling after lazy load.
- Mobile/narrow layout: Preset Guide grid should still collapse to one column because the moved media rule is now inside `PresetGuide.css`.
- Event/Lua Assistant and Settings should not depend on `PresetGuide.css`.
- Treat any missing Preset Guide CSS chunk as a regression.

## Expected Verdict Format

Please report:

- Pipeline table
- Bundle sizes table
- Preset Guide lazy split checkpoint table
- Any regression or "none"

Kimi should stay read-only for this QA pass.
