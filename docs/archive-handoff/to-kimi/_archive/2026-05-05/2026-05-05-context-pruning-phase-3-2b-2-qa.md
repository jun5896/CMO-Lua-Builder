# Kimi QA Request — Context Pruning Phase 3.2b-2 Ask-Back Stabilization

## Scope

Codex completed a small stabilization pass for Context Pruning Phase 3.2b.

Goal: keep the existing object-list pruning scope unchanged, but make ask-back hints survive from pruning transform into the final audit text so AI follow-up behavior remains fail-closed when object lists are summarized.

Changed files:

- `src/lib/aiContextPruning.js`
- `src/components/LuaAssistant.jsx`

## What Changed

1. `LuaAssistant.jsx` now passes the user-facing task text into the pruning context:
   - `objective`
   - `userContext: context`

2. `LuaAssistant.jsx` now passes `prunedResult.askBackHints` into `applyContextPruningAudit()`, so the final `## Context Pack / Pruning Audit` line can show `askBack=yes` and the exact missing/hint labels.

3. `aiContextPruning.js` now emits conservative ask-back hints when object lists were summarized and no matched object was preserved:
   - `Unit name disambiguation`
   - `Mission name`
   - `Reference point name`
   - `Zone name`
   - `Side name`
   - Existing `DBID` / `Loadout ID` behavior remains.

4. The implementation intentionally avoids expanding pruning scope. It only changes hint synthesis and audit propagation.

## Codex Verification Already Run

Commands:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Notes:

- First smoke run hit sandbox `spawn EPERM`.
- Escalated rerun passed with no Bearer / `sk-` leak.

Fresh build sizes:

```text
index-*.js                    395.56 kB
index-*.css                    64.08 kB
aiContextPruning-*.js           8.96 kB
AiResponseReviewPanel-*.js      5.15 kB
AiInterpreterChatPanel-*.js     8.75 kB
```

Watch lines:

- Main JS remains under 400 kB.
- `aiContextPruning-*.js` remains under the Phase 3.2b 9 kB watch line.
- Main CSS remains over the soft 60 kB watch line, unchanged by this pass.

Synthetic smoke:

- A prompt with 16 summarized units, no matched unit, and mission-assignment intent produced:
  - `askBackHints=["Unit name disambiguation","Side name"]`
  - `summarized=["objects.units.list"]`
  - final audit includes `Unit name disambiguation`
  - final audit includes `askBack=yes`
  - no hardBlock

## Kimi Checks Requested

Please run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

Report:

1. Pass/fail for lint/build/smoke.
2. Fresh bundle sizes, especially:
   - `index-*.js`
   - `index-*.css`
   - `aiContextPruning-*.js`
3. Confirm `aiContextPruning-*.js < 9 kB`.
4. Confirm `LuaAssistant.jsx` passes `objective`, `userContext`, and `askBackHints` through the pruning/audit path.
5. Confirm `buildAudit()` combines `requiredButMissing()` with `context.askBackHints`.
6. Confirm `Unit name disambiguation` is emitted when:
   - `objects.units.list` is summarized,
   - no `objects.units.list.matched` preservation exists,
   - intent is one of `missionAssignment`, `unitSpawnOrEdit`, `luaRepair`, or `validationDebug`.
7. Confirm matched references still suppress unnecessary disambiguation hints.
8. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block behavior are unchanged.
9. Confirm Lua apply is still gated only by `aiParsedResponse.isPasteReady`.
10. Confirm provider profile override path and manual prompt-copy fallback remain unchanged.
11. Confirm no raw API key / Bearer / localStorage / sessionStorage path was added.

## Regression Criteria

Treat as regression if any of these occur:

- Main JS exceeds 400 kB.
- `aiContextPruning-*.js` exceeds 9 kB.
- `askBackHints` are visible in `nextPruningAudit` but missing from final audit text.
- `Unit name disambiguation` appears even when a matching unit reference was preserved.
- Any prompt path bypasses the `isPasteReady` Lua apply gate.
- Smoke output leaks raw `Bearer` or `sk-` values.
