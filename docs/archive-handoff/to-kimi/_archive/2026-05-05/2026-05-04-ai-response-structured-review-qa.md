# Kimi QA Request — AI Response Structured Review UI

## Context

Codex added a first-pass structured AI response review panel inside `Event / Lua Assistant > Output & Validation`.

The AI response parser already returned:

- `assumptions`
- `prerequisites`
- `validationChecklist`
- `followUpQuestions`
- `blockers`
- `warnings`
- `isPasteReady`
- extracted `lua`

This pass surfaces those parsed fields in the UI so users do not have to inspect only the raw AI response.

## Changed Areas

- `src/components/LuaAssistant.jsx`
- `src/index.css`

## Please Run

From `C:\Users\dlwls\.codex\cmo-lua-ui`:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `npm run smoke:ai-adapter` fails with `spawn EPERM`, classify it as sandbox/environment unless adapter output shows an auth leak.

## Functional Checks

1. `Output & Validation > AI 응답` tab renders without crashing when `aiResponse` exists.
2. The UI shows:
   - section count
   - blocker count
   - warning count
   - Lua found/missing status
   - Paste-ready Lua readiness card
   - assumptions / CMO UI prerequisites / validation checklist / follow-up blockers cards
3. `Lua 적용` remains disabled when parser returns blockers.
4. `Lua 적용` becomes available only when `isPasteReady === true`.
5. Existing manual `Prompt 복사` fallback still exists.
6. AI Adapter security smoke still reports no raw key/auth leak.

## Bundle Watch

Report bundle sizes. Current Codex build after this change:

- `index-*.js`: `398.93 kB`
- `index-*.css`: `65.99 kB`
- `AiAdapterSettings-*.css`: `2.05 kB`

JS is close to the `400 kB` watch line. Please report if the QA run crosses it.

## Boundaries

- Do not edit `src/**`.
- Do not commit.
- Do not install packages.
- Report only actionable regressions and bundle/security changes.
