# Claude Directive: Context Pruning Phase 3.2c-3 DB Catalog / Side Posture Scope Review

## Status

Codex has implemented Context Pruning through Phase 3.2c-2b and completed a headroom recovery pass.

Completed sequence:

- Phase 1: `## Context Pack / Pruning Audit` stub added.
- Phase 2: `src/lib/aiContextPruning.js` added as lazy audit module.
- Phase 3: non-active Lua bodies omitted while active Lua is preserved.
- Phase 3.1: pruning visibility cards added.
- Phase 3.2a: API/Event/Trigger top-10 caps and briefing-like omission.
- Phase 3.2b-1: object list summaries with matched-reference preservation.
- Phase 3.2b-2: ask-back stabilization.
- Phase 3.2c-1: RP coordinate / zone polygon omission, preserving `referencePointZone`.
- Phase 3.2c-2a: mission detail omission, preserving `missionAssignment`.
- Phase 3.2c-2b: unit detail omission, preserving `missionAssignment`, `unitSpawnOrEdit`, `doctrineEmcon`, and `validationDebug`.
- Headroom recovery: compact audit labels and summary suffixes; behavior unchanged.

Latest Kimi QA:

- lint PASS
- build PASS
- smoke:ai-adapter PASS, no auth leak
- main JS `395.56 kB`
- main CSS `64.08 kB`
- `aiContextPruning-*.js` `8.59 kB`
- `aiContextPruning` is under the 9 kB watch line with about `0.41 kB` headroom.
- No regression in:
  - matched-reference preservation
  - unit detail preservation for unit-critical intents
  - geometry preservation for `referencePointZone`
  - mission detail preservation for `missionAssignment`
  - DBID/GUID preservation
  - `confirmedIdentifiersStripped`
  - `isPasteReady` Lua apply gate
  - provider profile override path
  - manual prompt-copy fallback

## Requested Review

Please provide a read-only technical review for the remaining risky part of Phase 3.2c:

**Phase 3.2c-3: DB catalog / side posture pruning**

Do not implement code. Codex needs a concrete scope-splitting recommendation before adding more logic to `aiContextPruning.js`.

The current chunk has only about `0.41 kB` headroom under the 9 kB line. A single combined DB + posture rollout is likely too large and too risky.

## Why This Needs Review

DB catalog and side posture are semantically different:

- DB catalog / DBID / loadout context affects whether AI can generate unit spawn or loadout Lua without inventing IDs.
- Side posture / doctrine / EMCON context affects relationship and behavior changes, where a wrong side or posture code can change scenario behavior.
- Both are safety-sensitive, but they probably need different ask-back and hard-block rules.

Codex needs to know whether to split this into smaller reversible slices, such as:

- `3.2c-3a`: DB catalog / DBID / loadout scope only.
- `3.2c-3b`: side posture / doctrine / EMCON scope only.
- `3.2c-3c`: optional compact telemetry / audit wording cleanup, only if needed.

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

Please answer with concrete, implementation-ready rules.

1. Recommended split
   - Should Codex implement `DB catalog` and `side posture` together or separately?
   - If separately, define exact sub-phases.
   - Include rough LOC and bundle delta estimate for each sub-phase.
   - Assume `aiContextPruning` should stay below 9 kB unless you explicitly recommend raising the watch line to 10 kB.

2. DB catalog rules
   - Which DB-related fields are never-prune?
   - Which fields can be summarized?
   - Which fields can be omitted?
   - Pay special attention to:
     - `dbFamily`
     - `dbVersion`
     - confirmed platform DBID
     - confirmed loadout ID
     - active Lua DBID/loadout hints
     - bulk DB catalog or known DBID range dumps

3. DB ask-back triggers
   - Exact ask-back labels for missing DB context.
   - Suggested labels:
     - `DBID`
     - `Loadout ID`
     - `DB family/version`
     - `Platform type`
   - Clarify which intents require each trigger:
     - `unitSpawnOrEdit`
     - `dbidLoadout`
     - `validationDebug`
     - `luaRepair`

4. DB hard-block triggers
   - Exact hard-block code names.
   - Suggested examples:
     - `dbContextStripped`
     - `confirmedDbidStripped`
     - `confirmedLoadoutStripped`
     - `dbFamilyVersionStripped`
   - Clarify whether these should block the AI call or only force ask-back.

5. Side posture / doctrine rules
   - Which side posture fields are never-prune?
   - Which can be summarized?
   - Which can be omitted?
   - Pay special attention to:
     - active side name
     - player/message side
     - relationship matrix
     - posture integer/code mappings
     - doctrine/EMCON fields
     - mission side ownership

6. Side posture ask-back triggers
   - Exact ask-back labels.
   - Suggested labels:
     - `Side name`
     - `Side posture`
     - `Doctrine field`
     - `EMCON setting`
   - Clarify which intents require each trigger:
     - `doctrineEmcon`
     - `missionAssignment`
     - `validationDebug`
     - `scenarioInspection`

7. Side posture hard-block triggers
   - Exact hard-block code names.
   - Suggested examples:
     - `activeSideStripped`
     - `sideDoctrineContextStripped`
     - `sidePostureMatrixStripped`
     - `postureCodeMappingStripped`
   - Clarify which are true hard-blocks versus ask-back.

8. Intent matrix addendum
   - Provide only the DB/posture delta for each intent:
     - `luaRepair`
     - `validationDebug`
     - `missionAssignment`
     - `unitSpawnOrEdit`
     - `dbidLoadout`
     - `referencePointZone`
     - `doctrineEmcon`
     - `scenarioInspection`
     - `generalAskBack`

9. Audit labels
   - Suggest compact labels for `actualOmit[]` and `summarized[]`.
   - Keep labels short because chunk size is tight.
   - Candidate labels:
     - `db.catalog`
     - `db.catalog.summary`
     - `db.confirmed`
     - `scenario.sidesPostures`
     - `scenario.sidesPostures.summary`
     - `scenario.sideDoctrine`

10. Kimi QA checklist
    - Provide a compact QA checklist for whichever sub-phase you recommend first.
    - Include:
      - lint/build/smoke
      - `aiContextPruning` chunk watch
      - DBID/loadout missing scenario
      - confirmed DBID/loadout preservation check
      - doctrine/side posture missing scenario
      - `isPasteReady` gate check
      - auth leak check

## Important Boundaries

- Review only; do not edit Codex workspace files unless explicitly reassigned.
- Do not implement Phase 3.2c-3 code in this review.
- Do not propose broad UI redesign.
- Do not change parser response contract unless absolutely necessary.
- Do not ask for mass scenario re-decode.
- Keep the answer concise enough for Codex to turn into a micro-slice implementation.

## Suggested Output Shape

Please return:

```md
# Context Pruning Phase 3.2c-3 DB/Posture Scope Review

## Verdict

## Recommended Split

## DB Catalog Rules

## DB Ask-Back / Hard-Block

## Side Posture Rules

## Side Posture Ask-Back / Hard-Block

## Intent Matrix Addendum

## Audit Labels

## First Micro-Slice Recommendation

## Kimi QA Checklist

## Red Flags / Open Questions
```
