# Kimi QA Request — Context Pruning Phase 3.2c-3a Headroom Recovery

## Scope

Codex completed a no-feature-expansion headroom recovery pass after Phase 3.2c-3a DB catalog pruning.

Changed file:

- `src/lib/aiContextPruning.js`

Goal:

- Keep Phase 3.2c-3a DB catalog behavior unchanged.
- Keep Phase 3.2c-2b unit detail, 3.2c-2a mission detail, and 3.2c-1 geometry behavior unchanged.
- Recover `aiContextPruning` lazy chunk headroom before any future side posture / doctrine work.

## Implementation Summary

This pass only compacted internal plumbing and audit text:

- Removed the separate `findSectionEnd()` helper by inlining it into `replaceSection()`.
- Changed `replaceSection()` to return a compact tuple instead of an object.
- Shortened prompt-audit text:
  - Removed the redundant `include=` line.
  - Kept `actualOmit=`, `plannedOmit=`, and `pruning=`.
  - Kept `summaries=`, `missing=`, and `tokens=`.
  - Shortened non-contract words such as `confidence`, `askBack`, `objects`, and `promptCopy`.
- Did not add new pruning scope.

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
| `aiContextPruning-*.js` | 8.56 kB |
| `AiInterpreterChatPanel-*.js` | 8.75 kB |
| `AiResponseReviewPanel-*.js` | 5.15 kB |

Headroom effect:

| Asset | Before | After | Delta |
| --- | ---: | ---: | ---: |
| `aiContextPruning-*.js` | 8.80 kB | 8.56 kB | -0.24 kB |
| 9 kB watch headroom | 0.20 kB | 0.44 kB | +0.24 kB |
| `index-*.js` | 395.56 kB | 395.56 kB | 0 kB |
| `index-*.css` | 64.08 kB | 64.08 kB | 0 kB |

Synthetic checks run by Codex:

- `replace-section headroom synthetic PASS`
- `array replace synthetic PASS`
- `audit text compact synthetic PASS`

## Kimi QA Checklist

Please verify and report only actionable regressions:

1. `git status --short`
2. `npm run lint`
3. `npm run build`
4. `npm run smoke:ai-adapter`
5. Confirm `aiContextPruning-*.js` reports about 8.56 kB and remains below 9 kB.
6. Confirm DB catalog behavior from Phase 3.2c-3a is unchanged:
   - non-DB-critical intents compact `db.notes`, `db.weapon`, `db.sensor`, `db.mount`, `db.platform`, `db.loadout`, and `db.unitGuid`.
   - `unitSpawnOrEdit`, `dbidLoadout`, and `validationDebug` preserve DB context.
   - confirmed DBID/loadout values are not compacted.
7. Confirm bundle replacement still works:
   - multi-file Lua bundle still emits `nonActiveLuaFile.body` and `luaBundle.manifest`.
8. Confirm prompt-audit contract labels remain present:
   - `actualOmit=`
   - `plannedOmit=`
   - `pruning=`
   - `summaries=`
   - `missing=`
   - `tokens=`
9. Confirm matched-reference preservation still suppresses unnecessary disambiguation ask-back.
10. Confirm Phase 3.2c-2b unit detail behavior is unchanged.
11. Confirm Phase 3.2c-2a mission detail behavior is unchanged.
12. Confirm Phase 3.2c-1 geometry behavior is unchanged.
13. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block remain unchanged.
14. Confirm Lua apply remains gated only by `aiParsedResponse.isPasteReady`.
15. Confirm provider profile override, prompt-copy fallback, and AI adapter smoke remain unchanged.
16. Confirm no raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` behavior was introduced.

## Watch Note

`aiContextPruning-*.js` is now `8.56 kB`, leaving about `0.44 kB` under the 9 kB watch line.

This restores enough headroom for a very small Phase 3.2c-3b posture-shape investigation or micro-slice, but a broad side posture implementation should still be split and QA-gated.

## Regression Criteria

Fail the QA if any of the following occur:

- `aiContextPruning-*.js` exceeds 9 kB.
- DB catalog behavior changes from Phase 3.2c-3a.
- Lua bundle section replacement stops working.
- Required audit labels disappear.
- Matched references outside top-N are no longer preserved.
- Unit detail / mission detail / geometry behavior changes.
- DBID/GUID hints are pruned or hard-block detection weakens.
- Lua apply becomes possible when `isPasteReady !== true`.
- AI adapter smoke leaks auth-like text.
