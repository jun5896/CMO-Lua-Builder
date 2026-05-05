# Kimi QA Request: Context Pruning Phase 3.2b-1

## Context

Codex implemented the smallest object-scope pruning pass after Claude's Phase 3.2 review.

This pass is intentionally conservative:

- Summarize long `## Registered CMO Objects` list lines.
- Preserve any object item matched by active Lua or current intent text, even when it is outside the top-N window.
- Preserve DBID/Loadout ID and GUID hints exactly.
- Do not prune object detail dumps, coordinates, polygons, database context, or side posture yet.

## Files touched by this pass

- `src/lib/aiContextPruning.js`

## Expected behavior

The following object lines may be summarized when they exceed their limit:

- `Sides` -> keep first 12
- `Units / GUIDs` -> keep first 10 + matched references
- `Missions` -> keep first 10 + matched references
- `Reference Points` -> keep first 5 + matched references
- `Zones` -> keep first 20 + matched references
- `Events` -> keep first 10 + matched references
- `Special Actions` -> keep first 10 + matched references
- `Lua files` -> keep first 3 + matched references

Expected summarized labels:

- `objects.sides.list`
- `objects.units.list`
- `objects.missions.list`
- `objects.referencePoints.list`
- `objects.zones.list`
- `objects.events.list`
- `objects.specialActions.list`
- `objects.luaFiles.list`

Matched references should also add compact preserved labels such as:

- `objects.units.list.matched`
- `objects.missions.list.matched`

## Safety expectations

- `DB/Loadout IDs in Lua` and `Combined DB/Loadout IDs` remain untouched.
- `Scenario GUIDs in Lua` and `Combined GUIDs` remain untouched.
- If DBID/GUID hints disappear after pruning, `hardBlock=confirmedIdentifiersStripped` should block the call.
- Existing `isPasteReady` Lua apply gate remains unchanged.
- Provider profile override path remains unchanged.
- No secrets or browser storage use is added.

## Fresh Codex verification already run

Commands:

- `npm run lint` -> PASS
- `npm run build` -> PASS
- `npm run smoke:ai-adapter` -> PASS after expected sandbox `spawn EPERM` rerun outside sandbox

Fresh build sizes:

- `index-*.js`: `395.51 kB`
- `index-*.css`: `64.08 kB`
- `aiContextPruning-*.js`: `8.06 kB`

Note: Claude Phase 3.2 review suggested a 3.2b chunk watch line of `< 9 kB`; this pass is inside that limit.

Mini functional check:

- Long Units / Missions / RP / Zones / Events / Special Actions / Lua files lists were summarized.
- Matched unit `Alpha Target` was preserved despite being outside the first 10.
- Matched mission `Nakhimov Patrol` was preserved despite being outside the first 10.
- DBID line was preserved.
- GUID line was preserved.
- Audit still includes `pruning=phase3`.
- Audit failures were empty.

Real fixture calibration:

- Fixture: `fixtures/scenario-summary-samples/iran-strike-real-summary.json`
- Scenario: `Iran Strike, 2020-2030`
- Estimated prompt tokens: `4937 -> 1393`
- Estimated reduction: `3544 tokens`, about `71.8%`
- Hard block: none
- Audit failures: none
- Preserved active unit reference: yes
- Preserved active mission reference: yes
- Preserved DBID `48`: yes
- Preserved sample GUID: yes
- Audit still includes `pruning=phase3`: yes

## QA checklist

1. Run `git status --short`.
2. Run `npm run lint`.
3. Run `npm run build`.
4. Run `npm run smoke:ai-adapter`.
5. Confirm main JS remains below the 400 kB watch line.
6. Confirm `aiContextPruning-*.js` remains below the Phase 3.2b watch line of `9 kB`.
7. Confirm object list lines are summarized at their expected limits.
8. Confirm active Lua / intent matched object names are preserved even outside top-N.
9. Confirm DBID/Loadout ID and GUID hint lines are not pruned or summarized.
10. Confirm `confirmedIdentifiersStripped` hard-block exists.
11. Confirm the Iran Strike fixture calibration remains in the same shape: no hardBlock, no audit failure, active unit/mission preserved, DBID/GUID preserved.
12. Confirm `isPasteReady` Lua apply gate remains unchanged.
13. Confirm provider profile override path remains unchanged.
14. Confirm no new `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` usage was added.

## Report format requested

Please report:

- pass/fail for lint/build/smoke
- fresh bundle sizes
- `aiContextPruning` chunk size
- object list summary confirmation
- matched reference preservation confirmation
- DBID/GUID preservation confirmation
- real fixture calibration result
- any actionable regression only
