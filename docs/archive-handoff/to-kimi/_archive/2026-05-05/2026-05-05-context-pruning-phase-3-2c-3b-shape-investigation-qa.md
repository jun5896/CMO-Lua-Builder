# Kimi QA Request — Context Pruning Phase 3.2c-3b Shape Investigation / Headroom Refresh

## Scope

Codex performed the Phase 3.2c-3b pre-implementation investigation.

Result:

- Side posture / doctrine / EMCON does **not** currently have a dedicated prompt section or stable line shape.
- `Doctrine/EMCON` is currently detected as a Lua analysis risk only.
- Prompt context currently exposes:
  - `Sides` via object context.
  - `intent.playerSide`.
  - mission side ownership in mission labels.
  - no explicit posture matrix.
  - no explicit doctrine field dump.
  - no explicit EMCON setting dump.

Decision:

- Do **not** implement side posture pruning yet.
- Treat Phase 3.2c-3b as blocked on data-shape definition.
- Keep current pruning logic limited to previously implemented DB/object/detail geometry scopes.

Changed file:

- `src/lib/aiContextPruning.js`

## Implementation Summary

No side-posture pruning scope was added.

Codex only applied a follow-up headroom refresh:

- Inlined `findSectionEnd()` into `replaceSection()`.
- Changed `replaceSection()` from object return to tuple return.
- Shortened prompt-audit text while preserving required labels:
  - `actualOmit=`
  - `plannedOmit=`
  - `pruning=`
  - `summaries=`
  - `missing=`
  - `tokens=`
- Removed the redundant `include=` audit line.

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

Headroom:

| Asset | Previous accepted | Current | Delta |
| --- | ---: | ---: | ---: |
| `aiContextPruning-*.js` | 8.80 kB | 8.56 kB | -0.24 kB |
| 9 kB watch headroom | 0.20 kB | 0.44 kB | +0.24 kB |

Static shape findings:

- `src/components/LuaAssistant.jsx` has `Doctrine/EMCON` risk detection in Lua analysis.
- `buildObjectContextSummary()` and prompt assembly include object context and database context.
- No dedicated prompt labels were found for:
  - `Side posture`
  - `sideDoctrine`
  - `sidesPostures`
  - `relationshipMatrix`
  - `EMCON setting`
  - `postureCodeMapping`

## Kimi QA Checklist

Please verify and report only actionable regressions:

1. `git status --short`
2. `npm run lint`
3. `npm run build`
4. `npm run smoke:ai-adapter`
5. Confirm `aiContextPruning-*.js` reports about 8.56 kB and remains below 9 kB.
6. Confirm no new side posture / doctrine / EMCON pruning helper was added.
7. Confirm no prompt pruning labels were introduced for posture yet:
   - `scenario.sidesPostures`
   - `scenario.sideDoctrine`
   - `scenario.emcon`
   - `scenario.relMatrix`
8. Confirm required audit labels remain present:
   - `actualOmit=`
   - `plannedOmit=`
   - `pruning=`
   - `summaries=`
   - `missing=`
   - `tokens=`
9. Confirm Lua bundle replacement still works after tuple return conversion.
10. Confirm DB catalog behavior from Phase 3.2c-3a is unchanged.
11. Confirm Phase 3.2c-2b unit detail behavior is unchanged.
12. Confirm Phase 3.2c-2a mission detail behavior is unchanged.
13. Confirm Phase 3.2c-1 geometry behavior is unchanged.
14. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block remain unchanged.
15. Confirm Lua apply remains gated only by `aiParsedResponse.isPasteReady`.
16. Confirm provider profile override, prompt-copy fallback, and AI adapter smoke remain unchanged.
17. Confirm no raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` behavior was introduced.

## Regression Criteria

Fail the QA if any of the following occur:

- `aiContextPruning-*.js` exceeds 9 kB.
- Any side posture pruning behavior appears before data shape is defined.
- Required audit labels disappear.
- Lua bundle replacement breaks.
- DB catalog behavior changes from Phase 3.2c-3a.
- Unit detail / mission detail / geometry behavior changes.
- DBID/GUID hints are pruned or hard-block detection weakens.
- Lua apply becomes possible when `isPasteReady !== true`.
- AI adapter smoke leaks auth-like text.

## Next Recommendation

Before implementing Phase 3.2c-3b, Codex should define or expose a stable posture data shape in the prompt, for example:

- `- Side posture matrix: ...`
- `- Doctrine fields: ...`
- `- EMCON settings: ...`
- `- Posture code mapping: Friendly/Neutral/Unfriendly/Hostile`

Until that shape exists, pruning posture data would be a no-op at best and unsafe at worst.
