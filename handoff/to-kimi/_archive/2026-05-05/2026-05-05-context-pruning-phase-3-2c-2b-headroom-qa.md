# Kimi QA Request — Context Pruning Phase 3.2c-2b Headroom Recovery

## Scope

Codex completed a no-feature-expansion headroom recovery pass after Phase 3.2c-2b Unit detail omission.

Changed file:

- `src/lib/aiContextPruning.js`

Goal:

- Keep Phase 3.2c-2b unit detail omission behavior unchanged.
- Keep Phase 3.2c-1 geometry omission and Phase 3.2c-2a mission detail omission behavior unchanged.
- Recover `aiContextPruning` lazy chunk headroom under the 9 kB watch line.

## Implementation Summary

- Shortened `plannedOmit` audit labels without changing pruning decisions.
- Shortened Lua bundle summary text while preserving the same facts.
- Shortened top-10 API/Event/Trigger and object-list summary suffixes.
- Simplified matched-reference needle extraction:
  - Still keeps the full item text.
  - Still keeps a shortened pre-bracket/pre-paren form.
  - Still keeps the post-colon display name.
- No new pruning scope was added.

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
| `aiContextPruning-*.js` | 8.59 kB |
| `AiInterpreterChatPanel-*.js` | 8.75 kB |
| `AiResponseReviewPanel-*.js` | 5.15 kB |

Headroom effect:

| Asset | Before | After | Delta |
| --- | ---: | ---: | ---: |
| `aiContextPruning-*.js` | 8.77 kB | 8.59 kB | -0.18 kB |
| 9 kB watch headroom | 0.23 kB | 0.41 kB | +0.18 kB |
| `index-*.js` | 395.56 kB | 395.56 kB | 0 kB |
| `index-*.css` | 64.08 kB | 64.08 kB | 0 kB |

Synthetic checks run by Codex:

- `headroom behavior synthetic PASS`
- `headroom matched synthetic PASS`

## Kimi QA Checklist

Please verify and report only actionable regressions:

1. `git status --short`
2. `npm run lint`
3. `npm run build`
4. `npm run smoke:ai-adapter`
5. Confirm `aiContextPruning-*.js` stays below 9 kB and reports about 8.59 kB.
6. Confirm `plannedOmit=` still emits compact comma-separated labels.
7. Confirm matched-reference preservation still works:
   - Object list summary emits the relevant `*.matched` preserved label when the user/Lua references an item outside top-N.
   - Matched preservation still suppresses unnecessary disambiguation ask-back.
8. Confirm Phase 3.2c-2b unit detail behavior is unchanged:
   - Non-unit-critical intents can emit `objects.units.detail`.
   - `missionAssignment`, `unitSpawnOrEdit`, `doctrineEmcon`, and `validationDebug` preserve unit detail.
9. Confirm Phase 3.2c-1 geometry behavior is unchanged.
10. Confirm Phase 3.2c-2a mission detail behavior is unchanged.
11. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block remain unchanged.
12. Confirm Lua apply remains gated only by `aiParsedResponse.isPasteReady`.
13. Confirm provider profile override, prompt-copy fallback, and AI adapter smoke remain unchanged.
14. Confirm no raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` behavior was introduced in pruning code.

## Regression Criteria

Fail the QA if any of the following occur:

- `aiContextPruning-*.js` exceeds 9 kB.
- Matched references outside top-N are no longer preserved.
- Unit detail preservation regresses for unit-critical intents.
- Geometry or mission-detail pruning behavior changes.
- DBID/GUID hints are pruned or hard-block detection weakens.
- Lua apply becomes possible when `isPasteReady !== true`.
- AI adapter smoke leaks auth-like text.
