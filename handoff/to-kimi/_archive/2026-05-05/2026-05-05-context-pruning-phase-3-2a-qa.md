# Kimi QA Request: Context Pruning Phase 3.2a

## Context

Codex implemented the first Claude-approved Phase 3.2 object-scope pruning step.

This is the smallest safe sub-phase:

- Cap API/Event/Trigger hint lists to top 10.
- Omit long briefing/description/note-like scenario text with a placeholder.
- Preserve DBID/Loadout ID hints and GUID hints exactly.
- Do not prune object lists, mission lists, unit lists, RP/Zone lists, or database context yet.

## Files touched by this pass

- `src/lib/aiContextPruning.js`

## Expected behavior

### API/Event/Trigger cap

The pruning transform should summarize these lines when they contain more than 10 comma-separated items:

- `- APIs: ...`
- `- Combined APIs: ...`
- `- Event helpers: ...`
- `- Combined event helpers: ...`
- `- Trigger hints: ...`
- `- Combined trigger hints: ...`

Expected audit labels:

- `analysis.apiCalls.top10`
- `analysis.eventCalls.top10`
- `analysis.triggerHints.top10`

### DBID/GUID preservation

These lines must remain untouched:

- `- DB/Loadout IDs in Lua: ...`
- `- Scenario GUIDs in Lua: ...`
- `- Combined DB/Loadout IDs: ...`
- `- Combined GUIDs: ...`

Reason: Claude identified DBID/GUID hints as active Lua extracted identifiers and therefore user-confirmed context.

### Briefing omission

Long briefing-like text should be replaced with a placeholder and recorded as:

- `scenario.briefing`

This currently applies to:

- `- Briefing: <long text>`
- `- Description: <long text>`
- long `- Note: <long text>`

## Fresh Codex verification already run

Commands:

- `npm run lint` -> PASS
- `npm run build` -> PASS
- `npm run smoke:ai-adapter` -> PASS after expected sandbox `spawn EPERM` rerun outside sandbox

Fresh build sizes:

- `index-*.js`: `395.51 kB`
- `index-*.css`: `64.08 kB`
- `aiContextPruning-*.js`: `6.07 kB`

Mini functional check:

- 14 API/Event/Trigger hints were capped to top 10.
- DBID line was preserved.
- GUID line was preserved.
- Long note/briefing text was omitted.
- Audit still includes `pruning=phase3`.
- Audit failures were empty.

## QA checklist

1. Run `git status --short`.
2. Run `npm run lint`.
3. Run `npm run build`.
4. Run `npm run smoke:ai-adapter`.
5. Confirm main JS remains below the 400 kB watch line.
6. Confirm `aiContextPruning-*.js` remains under 8 kB.
7. Confirm API/Event/Trigger lines cap at 10 and emit the expected `summarized[]` labels.
8. Confirm DBID/Loadout ID and GUID hint lines are not pruned or summarized.
9. Confirm long briefing-like text emits `actualOmit=scenario.briefing`.
10. Confirm `isPasteReady` Lua apply gate remains unchanged.
11. Confirm provider profile override path remains unchanged.
12. Confirm no new `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` usage was added.

## Report format requested

Please report:

- pass/fail for lint/build/smoke
- fresh bundle sizes
- `aiContextPruning` chunk size
- API/Event/Trigger cap confirmation
- DBID/GUID preservation confirmation
- any actionable regression only
