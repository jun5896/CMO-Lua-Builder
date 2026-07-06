# Claude Directive: Context Pruning Phase 3.2 Object/Mission/Unit Scope Review

## Status

Codex completed Context Pruning through Phase 3.1:

- Phase 1: `## Context Pack / Pruning Audit` stub added to the AI prompt.
- Phase 2: `src/lib/aiContextPruning.js` added as lazy judge/audit module.
- Phase 3: first actual transform added.
  - Non-active Lua file bodies inside `## Lua File Bundle Context` are omitted.
  - Active Lua remains preserved in `## Selected Lua File` or `## Current Lua`.
  - `applyContextPruning()` runs before `applyContextPruningAudit()`.
  - Hard block check exists between transform and audit.
- Phase 3.1: visibility cards added.
  - AI Response Review panel and AI Interpreter Chat panel show latest pruning audit values.
  - Fields visible: `mode`, `actualOmit`, `summarized`, `askBackHints`, `tokens`, `tokenLimit`, `hardBlock`, `failures`.

Latest Kimi QA:

- lint PASS
- build PASS
- smoke:ai-adapter PASS, no auth leak
- main JS `395.51 kB`
- main CSS `64.08 kB`
- `aiContextPruning-*.js` `5.33 kB`
- no regressions

## Requested Review

Please provide a read-only technical review before Codex expands pruning beyond Lua bundle bodies.

Target next implementation: **Context Pruning Phase 3.2: Object/Mission/Unit context pruning**

We need concrete rules for pruning or summarizing these prompt sections:

- `## Scenario Container Context`
- `## Registered CMO Objects`
- `## Database / Clipboard Context`
- `## Detected API/Trigger Hints`

The main risk: over-pruning object names or identifiers can cause the AI to invent Side/Mission/Unit/RP/Zone names or write Lua against the wrong scenario object.

## Current Safety Constraints

These must remain true:

- Do not prune system prompt / hard rules.
- Do not prune required response headings.
- Do not prune current user instruction.
- Do not prune active Lua snippet for `luaRepair` or `validationDebug`.
- Do not prune user-confirmed identifiers referenced by instruction or active Lua.
- If a required object/identifier is missing after pruning, force ask-back instead of allowing invention.
- `isPasteReady` remains the only Lua apply gate.
- Manual prompt-copy fallback remains visible.
- No raw `apiKey`, `Authorization`, `Bearer`, `localStorage`, or `sessionStorage` should be introduced.

## What Codex Needs From Claude

Please answer in a concrete, implementation-ready format:

1. `neverPruneObjectFields[]`
   - Which object fields/names must be preserved exactly?
   - Include Side, Mission, Unit, GUID, DBID, Loadout, RP, Zone, Event, Trigger, Action where relevant.

2. `summarizeObjectFields[]`
   - Which fields can be reduced to counts, top N, or selected samples?
   - Include safe limits such as top 10 or top 20.

3. `safeOmitObjectFields[]`
   - Which object context details can be omitted first?
   - Include when omission is allowed and what audit label to write.

4. Intent-specific rules
   - For each intent, list must-preserve and can-prune-first:
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
   - Which missing object signals should become `askBackHints`?
   - Please include exact suggested labels, e.g. `Mission name`, `Unit GUID`, `Side name`.

6. Hard-block triggers
   - Which pruning mistakes should block AI calls entirely?
   - Example: active Lua references a mission name but the mission list was fully omitted and no matching confirmed mission remains.

7. Audit labels
   - Suggest stable strings for `actualOmit[]` and `summarized[]`.
   - These labels appear in the UI visibility card, so keep them compact.

8. Minimal implementation plan
   - Recommend the smallest safe Codex implementation step.
   - Prefer a small Phase 3.2a if full object pruning is too risky.

## Important Boundaries

- Review only; do not edit Codex workspace files unless explicitly reassigned.
- Do not propose broad UI redesign.
- Do not propose changing parser response contract unless absolutely necessary.
- Keep response concise enough for Codex to implement directly.

## Suggested Output Shape

Please return:

```md
# Context Pruning Phase 3.2 Object Scope Review

## Verdict

## Rules

## Intent Matrix

## Ask-Back / Hard-Block

## Audit Labels

## Minimal Implementation Recommendation
```
