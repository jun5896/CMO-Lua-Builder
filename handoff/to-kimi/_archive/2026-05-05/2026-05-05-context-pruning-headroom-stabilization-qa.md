# Kimi QA Request — Context Pruning Headroom Stabilization

## Scope

Codex completed a no-feature-expansion stabilization pass after Phase 3.2b-2.

Goal: keep Context Pruning behavior unchanged while moving the `aiContextPruning` lazy chunk farther below the 9 kB Phase 3.2b watch line.

Changed file:

- `src/lib/aiContextPruning.js`

## What Changed

1. Shortened human-facing pruning summary strings in the generated prompt:
   - Lua bundle summary labels are now more compact.
   - Object/API summary placeholder text is shorter.
   - Briefing omission placeholder text is shorter.

2. Shortened `plannedOmit` audit labels:
   - Example: `fullRpZoneList,templateAnnotations,unrelatedSides` became `rpZones,templates,otherSides`.

3. No pruning scope expansion.

4. No changes to:
   - `askBackHints` conditions.
   - `confirmedIdentifiersStripped` hard-block.
   - DBID/GUID preservation.
   - `isPasteReady` Lua apply gate.
   - provider profile override path.
   - prompt-copy fallback.

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
aiContextPruning-*.js           8.55 kB
AiResponseReviewPanel-*.js      5.15 kB
AiInterpreterChatPanel-*.js     8.75 kB
```

Improvement:

```text
aiContextPruning-*.js  8.96 kB -> 8.55 kB
Headroom vs 9 kB       0.04 kB -> 0.45 kB
```

Synthetic smoke:

- A mission-assignment prompt with 16 summarized units still produced:
  - `askBackHints=["Unit name disambiguation","Side name"]`
  - `summarized=["analysis.apiCalls.top10","objects.units.list"]`
  - `askBack=yes` in final audit
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
2. Fresh bundle sizes:
   - `index-*.js`
   - `index-*.css`
   - `aiContextPruning-*.js`
3. Confirm `aiContextPruning-*.js < 9 kB` and report exact headroom.
4. Confirm only output/audit wording was shortened, not pruning scope.
5. Confirm `Unit name disambiguation` ask-back still works for summarized units with no matched unit.
6. Confirm matched references still suppress unnecessary disambiguation hints.
7. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block are unchanged.
8. Confirm Lua apply is still gated only by `aiParsedResponse.isPasteReady`.
9. Confirm provider profile override and manual prompt-copy fallback are unchanged.
10. Confirm no raw API key / Bearer / localStorage / sessionStorage path was added.

## Regression Criteria

Treat as regression if any of these occur:

- `aiContextPruning-*.js` is 9 kB or larger.
- Main JS exceeds 400 kB.
- `askBackHints` no longer reach the final audit text.
- Matched object references still produce disambiguation hints.
- Any prompt path bypasses the `isPasteReady` Lua apply gate.
- Smoke output leaks raw `Bearer` or `sk-` values.
