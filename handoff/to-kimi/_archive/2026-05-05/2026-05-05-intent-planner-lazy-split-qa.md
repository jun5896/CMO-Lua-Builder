# Kimi QA Request — Intent Planner Lazy Split

Status: ready for QA after Codex implementation.
Owner boundary: Kimi validates only. Do not edit `src/**`, `server/**`, `tools/**`, `package.json`, or handoff files.

## What changed

Codex split the Event/Lua Assistant `Intent Planner` tab out of `LuaAssistant.jsx` into a lazy component.

Touched files:

- `src/components/LuaAssistant.jsx`
- `src/components/IntentPlannerPanel.jsx`

Important behavior:

- `Intent Planner` should render only when the Intent Planner tab is opened.
- State remains owned by `LuaAssistant.jsx`.
- The new component is presentation/control UI only.
- Event name, player side, trigger type, action type, repeat mode, KeyValue, detail tabs, generated plan, missing field box, and setup checklist should behave the same.
- No AI adapter, provider profile, context pack, or Lua apply behavior should change.

## Codex verification baseline

- `npm run lint`: PASS
- `npm run build`: PASS
- `npm run smoke:ai-adapter`: PASS
- Main JS: `index-*.js` around `394.80 kB`
- Main CSS: `index-*.css` around `64.08 kB`
- New lazy chunk: `IntentPlannerPanel-*.js` around `5.03 kB`

Previous stub-headroom baseline:

- Main JS was around `399.09 kB`
- This split should reduce main JS by about `4.29 kB`

## QA commands

Run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` fails with `spawn EPERM`, report it as sandbox/environment unless Codex explicitly asks for backend review.

## Static checks

Verify:

1. `src/components/IntentPlannerPanel.jsx` exists.
2. `src/components/LuaAssistant.jsx` lazy imports `./IntentPlannerPanel`.
3. Build output includes a separate `IntentPlannerPanel-*.js` chunk.
4. `LuaAssistant.jsx` no longer contains the full Intent Planner JSX block.
5. `Intent Planner` state remains in `LuaAssistant.jsx`:
   - `intent`
   - `activeIntentDetailTab`
   - `intentContentWidth`
   - `eventPlan`
   - `uiSetupText`
6. `IntentPlannerPanel` receives callbacks from parent:
   - `onIntentChange`
   - `onIntentDetailTabChange`
   - `onResizeStart`
7. Context Pack behavior remains:
   - stub section still present
   - dynamic `aiContextPruning` import still present
8. Lua apply remains gated by `aiParsedResponse.isPasteReady`.
9. Provider profile override still flows through `sendCmoAiPrompt()`.
10. No raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` was added.

## Report format

Return:

- Pipeline pass/fail.
- Bundle sizes and delta from `399.09 kB` JS / `64.08 kB` CSS baseline.
- Whether `IntentPlannerPanel-*.js` is a separate chunk.
- Whether Intent Planner behavior appears preserved by static checks.
- Whether any actionable regression exists.

Flag only actionable issues. Avoid broad refactor suggestions unless a test fails or main JS regresses above 400 kB.
