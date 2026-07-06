# Kimi QA Request — Context Pruning Phase 3.2c-2a Headroom Recovery

## Scope

Codex completed a no-feature-expansion headroom recovery pass after Phase 3.2c-2a mission detail omission.

Changed file:

- `src/lib/aiContextPruning.js`

Goal:

- Keep Phase 3.2c-1 geometry omission and Phase 3.2c-2a mission detail omission behavior unchanged.
- Recover `aiContextPruning` lazy chunk headroom under the 9 kB watch line.
- Do not touch parser response contract, provider settings, AI secrets, or Lua apply gating.

## Implementation Summary

- Merged the separate geometry and mission-detail pruning helpers into one compact detail-line helper.
- Kept intent-specific preservation rules:
  - `referencePointZone` preserves RP coordinate and zone polygon lines.
  - `missionAssignment` preserves mission detail and mission roster lines.
- Kept non-target intent omission labels:
  - `objects.rp.coords`
  - `objects.zones.polygons`
  - `objects.missions.detail`
- Simplified `plannedOmissions()` so it returns compact comma-separated labels directly.
- Combined briefing / description / note omission into one matcher while preserving thresholds:
  - `Briefing` and `Description`: omit only when line text is at least 180 chars.
  - `Note`: omit only when line text is at least 320 chars.

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
| `aiContextPruning-*.js` | 8.55 kB |
| `AiInterpreterChatPanel-*.js` | 8.75 kB |
| `AiResponseReviewPanel-*.js` | 5.15 kB |

Headroom effect:

| Asset | Before | After | Delta |
| --- | ---: | ---: | ---: |
| `aiContextPruning-*.js` | 8.75 kB | 8.55 kB | -0.20 kB |
| 9 kB watch headroom | 0.25 kB | 0.45 kB | +0.20 kB |

Synthetic checks run by Codex:

- `generic-detail synthetic PASS`
- `headroom synthetic PASS`
- `briefing synthetic PASS`
- `headroom full synthetic PASS`

## Kimi QA Checklist

Please verify and report only actionable regressions:

1. `git status --short`
2. `npm run lint`
3. `npm run build`
4. `npm run smoke:ai-adapter`
5. Confirm `aiContextPruning-*.js` stays below 9 kB.
6. Confirm `referencePointZone` still preserves geometry lines.
7. Confirm non-`referencePointZone` long RP/Zone geometry lines still emit `objects.rp.coords` / `objects.zones.polygons`.
8. Confirm `missionAssignment` still preserves mission detail / mission roster lines.
9. Confirm non-`missionAssignment` long mission detail lines still emit `objects.missions.detail`.
10. Confirm long briefing/description/note omission still emits `scenario.briefing`.
11. Confirm `plannedOmit=` still emits compact comma-separated labels.
12. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block remain unchanged.
13. Confirm Lua apply remains gated only by `aiParsedResponse.isPasteReady`.
14. Confirm provider profile override, prompt-copy fallback, and AI adapter smoke remain unchanged.
15. Confirm no raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` behavior was introduced in pruning code.

## Regression Criteria

Fail the QA if any of the following occur:

- `aiContextPruning-*.js` exceeds 9 kB without an explicit Codex note.
- `referencePointZone` loses geometry context.
- `missionAssignment` loses mission detail context.
- DBID/GUID hints are pruned or hard-block detection weakens.
- Lua apply becomes possible when `isPasteReady !== true`.
- AI adapter smoke leaks auth-like text.
