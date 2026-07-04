# Claude Directive: Context Pruning Phase 3.2c Detail / Coordinate / Polygon Scope Review

## Status

Codex completed Context Pruning through Phase 3.2b stabilization.

Completed sequence:

- Phase 1: `## Context Pack / Pruning Audit` stub added to AI prompt.
- Phase 2: `src/lib/aiContextPruning.js` added as lazy judge/audit module.
- Phase 3: non-active Lua file bodies are omitted while active Lua remains preserved.
- Phase 3.1: pruning visibility cards added to AI Response Review and AI Interpreter Chat panels.
- Phase 3.2a: API/Event/Trigger hint lists capped to top 10; briefing-like long text omitted.
- Phase 3.2b-1: object list summaries added with matched-reference preservation.
- Phase 3.2b-2: ask-back hints stabilized and propagated into final audit.
- Headroom pass: wording shortened without behavior change.

Latest Kimi QA:

- lint PASS
- build PASS
- smoke:ai-adapter PASS, no auth leak
- main JS `395.56 kB`
- main CSS `64.08 kB`
- `aiContextPruning-*.js` `8.55 kB`
- `aiContextPruning` is under the Phase 3.2b 9 kB watch line with about `0.45 kB` headroom.
- No regression in:
  - `askBackHints`
  - matched-reference suppression
  - DBID/GUID preservation
  - `confirmedIdentifiersStripped`
  - `isPasteReady` Lua apply gate
  - provider profile override path
  - manual prompt-copy fallback

## Requested Review

Please provide a read-only technical review for the next risky pruning step:

**Context Pruning Phase 3.2c: detail / coordinate / polygon pruning**

This phase should decide whether Codex may prune or summarize expensive detail fields beyond simple object lists.

Candidate pruning targets:

- Unit full detail dumps
- Mission full detail dumps
- Reference point coordinates
- Zone polygons / polygon point lists
- Side posture / doctrine relationship dumps
- Database full catalog / DBID range dumps
- Scenario briefing / long description text, if any remaining source still emits it

The main risk is not bundle size. The risk is semantic corruption:

- AI may write Lua against a wrong RP/Zone if coordinates or polygons were removed.
- AI may assign a unit to a wrong mission if mission detail was summarized too aggressively.
- AI may invent a DBID/loadout if database context was omitted.
- AI may mis-handle doctrine/EMCON if side posture context was removed.

## Current Safety Constraints

These must remain true:

- Do not prune system prompt / hard rules.
- Do not prune required response headings.
- Do not prune current user instruction.
- Do not prune active Lua snippet for `luaRepair` or `validationDebug`.
- Do not prune user-confirmed names/identifiers referenced by instruction or active Lua.
- Do not prune DBID/GUID/Loadout hints extracted from active Lua.
- If a required object/identifier is missing after pruning, force ask-back instead of allowing invention.
- `isPasteReady` remains the only Lua apply gate.
- Manual prompt-copy fallback remains visible.
- No raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` should be introduced.

## What Codex Needs From Claude

Please answer in concrete, implementation-ready rules.

1. `neverPruneDetailFields[]`
   - Which detail fields must be preserved exactly?
   - Include intent-specific exceptions.
   - Pay special attention to:
     - active RP/Zone geometry for `referencePointZone`
     - active Mission detail for `missionAssignment`
     - active Side doctrine/posture for `doctrineEmcon`
     - DB family/version and confirmed DBID/loadout for `dbidLoadout` and `unitSpawnOrEdit`

2. `summarizeDetailFields[]`
   - Which details can become counts, first N, top N, or compact shape summaries?
   - Include safe limits and summary shapes.
   - Examples:
     - `referencePoints.coordinates -> count + named active RP full + first 5 sample names`
     - `zones.polygons -> count + active zone polygon only`
     - `missions.fullDetail -> active mission full + other missions top 10 names`

3. `safeOmitDetailFields[]`
   - Which fields can be omitted entirely?
   - Include the required audit label and required placeholder text.
   - Example shape:
     - `objects.rp.coords`: omit only when intent is not `referencePointZone`
     - placeholder: `[objects.rp.coords omitted: N points; ask user for exact RP if needed]`

4. Intent-specific preserve/prune matrix
   - For each intent, list:
     - must-preserve detail fields
     - summarize-only detail fields
     - safe omit-first detail fields
   - Cover:
     - `luaRepair`
     - `validationDebug`
     - `missionAssignment`
     - `unitSpawnOrEdit`
     - `dbidLoadout`
     - `referencePointZone`
     - `doctrineEmcon`
     - `scenarioInspection`
     - `generalAskBack`

5. Ask-back triggers
   - Which missing detail signals should become `askBackHints` instead of allowing AI to proceed?
   - Please include exact labels.
   - Suggested examples:
     - `Reference point coordinates`
     - `Zone polygon`
     - `Mission detail`
     - `Side posture`
     - `DBID`
     - `Loadout ID`

6. Hard-block triggers
   - Which pruning mistakes should block the AI call entirely?
   - Please include exact code names.
   - Suggested examples:
     - `activeZonePolygonStripped`
     - `activeReferencePointCoordsStripped`
     - `activeMissionDetailStripped`
     - `dbContextStripped`
     - `sideDoctrineContextStripped`
     - `confirmedIdentifiersStripped`

7. Audit labels
   - Suggest stable compact labels for `actualOmit[]` and `summarized[]`.
   - These labels appear in the UI pruning visibility card.
   - Keep them short and grep-friendly.
   - Suggested namespace:
     - `objects.units.detail`
     - `objects.missions.detail`
     - `objects.rp.coords`
     - `objects.zones.polygons`
     - `scenario.sidesPostures`
     - `db.fullCatalog`

8. Minimal implementation plan
   - Recommend whether Codex should do:
     - Phase 3.2c-1: only coordinates/polygons
     - Phase 3.2c-2: mission/unit detail dumps
     - Phase 3.2c-3: DB catalog and side posture
   - Prefer small reversible steps.
   - Include rough LOC and bundle-risk estimate if possible.

9. Kimi QA checklist
   - Provide a compact QA checklist Kimi can run after Codex implementation.
   - Include:
     - lint/build/smoke
     - bundle size watch lines
     - one synthetic RP/Zone scenario
     - one mission assignment scenario
     - one DBID/loadout scenario
     - one matched-reference preservation check
     - one hard-block check

## Important Boundaries

- Review only; do not edit Codex workspace files unless explicitly reassigned.
- Do not implement Phase 3.2c code in this review.
- Do not propose broad UI redesign.
- Do not change parser response contract unless absolutely necessary.
- Do not ask for mass scenario re-decode.
- Keep the answer concrete enough for Codex to implement directly.

## Suggested Output Shape

Please return:

```md
# Context Pruning Phase 3.2c Detail Scope Review

## Verdict

## Never Prune

## Summarize Only

## Safe Omit

## Intent Matrix

## Ask-Back Triggers

## Hard-Block Triggers

## Audit Labels

## Minimal Implementation Plan

## Kimi QA Checklist

## Red Flags / Open Questions
```
