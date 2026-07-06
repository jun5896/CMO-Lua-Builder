# Kimi QA Request — Context Pruning Phase 3.2c-2b Unit Detail Omission

## Scope

Codex implemented the next small Phase 3.2c-2 slice: unit detail omission.

Changed file:

- `src/lib/aiContextPruning.js`

Goal:

- Omit long unit detail lines for intents that do not need full unit records.
- Preserve unit detail lines for intents where unit records are operationally important.
- Keep Phase 3.2c-1 geometry omission and Phase 3.2c-2a mission detail omission behavior unchanged.

## Implementation Summary

New omission label:

- `objects.units.detail`

Unit detail lines are preserved for:

- `missionAssignment`
- `unitSpawnOrEdit`
- `doctrineEmcon`
- `validationDebug`

Unit detail lines are omitted for other intents when the line is long enough:

- `Unit detail`
- `Unit details`
- `Units detail`
- `Units details`
- `Unit full detail`
- `Unit full details`
- `Unit roster`
- `Unit status`
- `Unit loadout`

Existing preserved behavior:

- `referencePointZone` still preserves RP coordinate / zone polygon lines.
- `missionAssignment` still preserves mission detail / mission roster lines.
- DBID/GUID hint lines remain outside pruning targets.
- Lua apply remains gated by `aiParsedResponse.isPasteReady`.

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
| `aiContextPruning-*.js` | 8.77 kB |
| `AiInterpreterChatPanel-*.js` | 8.75 kB |
| `AiResponseReviewPanel-*.js` | 5.15 kB |

Delta from previous headroom baseline:

| Asset | Before | After | Delta |
| --- | ---: | ---: | ---: |
| `aiContextPruning-*.js` | 8.55 kB | 8.77 kB | +0.22 kB |
| 9 kB watch headroom | 0.45 kB | 0.23 kB | -0.22 kB |
| `index-*.js` | 395.56 kB | 395.56 kB | 0 kB |
| `index-*.css` | 64.08 kB | 64.08 kB | 0 kB |

Synthetic checks run by Codex:

- `unit-detail synthetic PASS`
- `unit-detail label coverage PASS`

## Kimi QA Checklist

Please verify and report only actionable regressions:

1. `git status --short`
2. `npm run lint`
3. `npm run build`
4. `npm run smoke:ai-adapter`
5. Confirm `aiContextPruning-*.js` stays below 9 kB.
6. Confirm long unit detail lines emit `objects.units.detail` for non-unit-critical intents.
7. Confirm `missionAssignment` preserves unit detail lines.
8. Confirm `unitSpawnOrEdit` preserves unit detail lines.
9. Confirm `doctrineEmcon` preserves unit detail lines.
10. Confirm `validationDebug` preserves unit detail lines.
11. Confirm Phase 3.2c-1 geometry behavior is unchanged:
    - `referencePointZone` preserves geometry.
    - non-`referencePointZone` geometry can emit `objects.rp.coords` / `objects.zones.polygons`.
12. Confirm Phase 3.2c-2a mission detail behavior is unchanged:
    - `missionAssignment` preserves mission detail.
    - non-`missionAssignment` mission detail can emit `objects.missions.detail`.
13. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block remain unchanged.
14. Confirm Lua apply remains gated only by `aiParsedResponse.isPasteReady`.
15. Confirm provider profile override, prompt-copy fallback, and AI adapter smoke remain unchanged.
16. Confirm no raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` behavior was introduced in pruning code.

## Watch Note

`aiContextPruning-*.js` is now `8.77 kB`, leaving only `0.23 kB` under the 9 kB watch line.

If this pass is accepted, the next step should be either:

- a headroom recovery pass before adding more Phase 3.2c logic, or
- an explicit watch-line adjustment to 10 kB before Phase 3.2c-3.

## Regression Criteria

Fail the QA if any of the following occur:

- `aiContextPruning-*.js` exceeds 9 kB without explicit Codex approval.
- `missionAssignment`, `unitSpawnOrEdit`, `doctrineEmcon`, or `validationDebug` loses unit detail context.
- `referencePointZone` loses geometry context.
- `missionAssignment` loses mission detail context.
- DBID/GUID hints are pruned or hard-block detection weakens.
- Lua apply becomes possible when `isPasteReady !== true`.
- AI adapter smoke leaks auth-like text.
