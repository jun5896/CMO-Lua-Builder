# Kimi QA Directive - Final Protection Group 4 Preset Guide / Template / CSS Lazy Split

## Role

Read-only QA / regression monitor. Do not edit `src/**`, `server/**`, `tools/**`, `package.json`, docs, or handoff files. Do not commit.

## Scope

Verify final protection group 4:

- Preset Guide lazy split
- Preset Guide route-specific CSS split
- Template annotation external asset loading
- Assistant template insertion behavior
- Selected-form-only custom preset save behavior

## Baseline

- Main JS: `366.05 kB`
- Main CSS: `58.27 kB`
- `PresetGuide-*.js`: `30.05 kB`
- `PresetGuide-*.css`: `5.86 kB`
- `AiAdapterSettings-*.js`: `10.44 kB`
- `AiAdapterSettings-*.css`: `2.43 kB`
- `AiInterpreterChatPanel-*.js`: `10.06 kB`
- `AiInterpreterChatPanel-*.css`: `6.19 kB`
- `aiContextPruning-*.js`: `8.56 kB`

Watch lines:

- Main JS must stay under `400 kB`.
- Main CSS should stay under `60 kB`.
- `aiContextPruning-*.js` must stay under `9 kB`.

## Pipeline

Run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits sandbox `spawn EPERM`, report it and rerun only with the approved smoke-test path if available.

## Static Checkpoints

1. `src/App.jsx` lazy-loads `PresetGuide` with `lazy(() => import('./components/PresetGuide'))`.
2. `src/App.jsx` renders `PresetGuide` under `Suspense` only in the `guide` workspace panel.
3. `src/components/PresetGuide.jsx` imports `./PresetGuide.css`.
4. Build emits both `PresetGuide-*.js` and `PresetGuide-*.css`.
5. Main `index-*.css` remains near `58.27 kB`, below the `60 kB` watch line.
6. Event/Lua Assistant first-load styles do not depend on `PresetGuide.css`.
7. `public/template-annotations.json` exists.
8. `src/components/TemplateLibrary.jsx` loads `/template-annotations.json` and uses annotation fallback safely.
9. `PresetGuide` custom save stores only the currently selected/displayed form, not the whole builder list.
10. User custom preset button label remains `수정`.
11. Assistant template insertion appends generated Lua below existing text instead of replacing it.
12. Insertion palette and Builder Forms continue to share group descriptions from `FEATURE_FORM_GROUPS`.
13. Manual Prompt copy fallback remains present.
14. Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.
15. `smoke:ai-adapter` confirms no `Bearer` / `sk-` leakage.

## Expected Verdict Format

Return a concise QA report with:

- Pipeline results
- Bundle table vs baseline
- Static checkpoint table
- Regression notes, if any
- Final verdict: `APPROVED` or `BLOCKED`
