# Kimi QA Request — Context Pruning Phase 3.2c-3a DB Catalog

## Scope

Codex implemented the first DB/posture micro-slice recommended by Claude:

- Phase 3.2c-3a: DB catalog per-field pruning only.
- Side posture / doctrine / EMCON pruning is not implemented in this pass.

Changed file:

- `src/lib/aiContextPruning.js`

## Implementation Summary

New helper:

- `compactDbLines(prompt, intentName, decisions)`

Behavior:

- For `unitSpawnOrEdit`, `dbidLoadout`, and `validationDebug`, DB context lines are preserved.
- For other intents, optional DB fields with `(not provided)` are compacted:
  - `Weapon DBID` → `db.weapon`
  - `Sensor DBID` → `db.sensor`
  - `Mount DBID` → `db.mount`
  - `Platform DBID` → `db.platform`
  - `Loadout ID` → `db.loadout`
  - `Scenario unit GUID` → `db.unitGuid`
- `Notes` is compacted as `db.notes` for non-DB-critical intents.
- Confirmed DBID/loadout/GUID values are not compacted by this helper.
- Existing `DB/Loadout IDs in Lua` and `Combined DB/Loadout IDs` preservation remains handled by `confirmedIdentifiersStripped`.

Audit wording was also compacted to keep the lazy chunk under the watch line:

- `confidence` → `conf`
- `askBack` → `ask`
- `objects` → `obj` in non-contract audit text
- `promptCopy` → `copy` in safety text

Contract labels that Kimi checks should remain:

- `actualOmit=`
- `plannedOmit=`
- `pruning=`
- DB audit labels listed above

## Codex Verification

Commands:

- `npm run lint` — PASS
- `npm run build` — PASS
- `npm run smoke:ai-adapter` — PASS after sandbox EPERM retry outside sandbox, no auth leak

Fresh build sizes:

| Asset | Size |
| --- | ---: |
| `index-*.js` | 395.56 kB |
| `index-*.css` | 64.08 kB |
| `aiContextPruning-*.js` | 8.80 kB |
| `AiInterpreterChatPanel-*.js` | 8.75 kB |
| `AiResponseReviewPanel-*.js` | 5.15 kB |

Delta from previous accepted baseline:

| Asset | Before | After | Delta |
| --- | ---: | ---: | ---: |
| `aiContextPruning-*.js` | 8.59 kB | 8.80 kB | +0.21 kB |
| 9 kB watch headroom | 0.41 kB | 0.20 kB | -0.21 kB |
| `index-*.js` | 395.56 kB | 395.56 kB | 0 kB |
| `index-*.css` | 64.08 kB | 64.08 kB | 0 kB |

Synthetic checks run by Codex:

- `db-scope synthetic PASS`
- `db-scope compact synthetic PASS`
- `db-scope inline synthetic PASS`
- `db notes synthetic PASS`
- `db audit compact synthetic PASS`
- `db audit compact2 synthetic PASS`

## Kimi QA Checklist

Please verify and report only actionable regressions:

1. `git status --short`
2. `npm run lint`
3. `npm run build`
4. `npm run smoke:ai-adapter`
5. Confirm `aiContextPruning-*.js` stays below 9 kB and reports about 8.80 kB.
6. Confirm non-DB-critical intents compact empty optional DB fields:
   - `db.notes`
   - `db.weapon`
   - `db.sensor`
   - `db.mount`
   - `db.platform`
   - `db.loadout`
   - `db.unitGuid`
7. Confirm DB-critical intents preserve DB lines:
   - `unitSpawnOrEdit`
   - `dbidLoadout`
   - `validationDebug`
8. Confirm missing DB ask-back still works:
   - `unitSpawnOrEdit` with empty `platformDbid` includes `DBID`.
   - `dbidLoadout` with empty `loadoutId` includes `Loadout ID`.
9. Confirm confirmed DBID/loadout values are not compacted:
   - `Platform DBID: 12345` remains present.
   - `Loadout ID: 67` remains present.
   - `actualOmit` should not include `db.platform` / `db.loadout` for confirmed values.
10. Confirm `DB/Loadout IDs in Lua` and `Combined DB/Loadout IDs` preservation still works.
11. Confirm `confirmedIdentifiersStripped` hard-block remains unchanged.
12. Confirm Phase 3.2c-2b unit detail behavior is unchanged.
13. Confirm Phase 3.2c-1 geometry behavior is unchanged.
14. Confirm Phase 3.2c-2a mission detail behavior is unchanged.
15. Confirm Lua apply remains gated only by `aiParsedResponse.isPasteReady`.
16. Confirm provider profile override, prompt-copy fallback, and AI adapter smoke remain unchanged.
17. Confirm no raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` behavior was introduced in pruning code.

## Watch Note

`aiContextPruning-*.js` is now `8.80 kB`, leaving about `0.20 kB` under the 9 kB watch line.

Do not proceed to Phase 3.2c-3b side posture pruning without either:

- another headroom recovery pass, or
- explicit Codex decision to keep 9 kB as a hard line and accept very small margin, or
- explicit watch-line adjustment.

## Regression Criteria

Fail the QA if any of the following occur:

- `aiContextPruning-*.js` exceeds 9 kB.
- DB-critical intents lose DB context.
- Confirmed DBID/loadout/GUID values are compacted or stripped.
- DB ask-back for `DBID` or `Loadout ID` stops firing.
- `confirmedIdentifiersStripped` weakens.
- Unit detail / geometry / mission detail pruning behavior changes.
- Lua apply becomes possible when `isPasteReady !== true`.
- AI adapter smoke leaks auth-like text.
