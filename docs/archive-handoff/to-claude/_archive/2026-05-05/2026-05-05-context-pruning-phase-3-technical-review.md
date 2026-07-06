# Claude Technical Review Request — Context Pruning Phase 3

Status: review requested before implementation.
Requester: Codex
Mode: technical review / contract calibration only.

Do not edit `src/**`, `server/**`, `tools/**`, `package.json`, or generated sidecars unless Codex explicitly sends a later implementation signal.

## Background

Codex has completed the safe preparation work for AI context pruning:

- Phase 1: `## Context Pack / Pruning Audit` stub added to AI prompt assembly.
- Phase 2: `src/lib/aiContextPruning.js` added as a dynamic chunk.
- Current behavior: `applyContextPruningAudit()` is **judge-only**.
- Actual prompt pruning is still off:
  - audit reports `actualOmit=none`
  - audit reports `plannedOmit=...`
  - audit reports `pruning=judge-only`
- Kimi QA passed:
  - main JS: `394.80 kB`
  - main CSS: `64.08 kB`
  - `aiContextPruning-*.js`: `2.77 kB`
  - no security smoke regression

Codex is preparing Phase 3: actually reduce selected AI prompt context.

## Proposed Phase 3 Scope

Start with conservative pruning only:

1. Lua bundle context:
   - Keep the active/selected Lua file.
   - For non-active Lua files, include only file path, line count, top API names, and very short excerpt if needed.
   - Never remove the active Lua snippet.

2. Detected API lists:
   - Keep top or unique API names.
   - Limit long full lists.
   - Keep enough signal for validation/debug.

3. Object lists:
   - Keep full lists only if short.
   - If long, use count + first N samples.
   - If user instruction mentions a name, keep matching records fully.

4. Scenario context:
   - Always keep title, DB family/version, build/version, sidecar/openability status.
   - Large side/unit/mission details may be summarized.

5. Chat/follow-up:
   - Prior parser blockers, missing required sections, and follow-up questions must remain.
   - Do not prune data that caused the current ask-back loop.

## Safety Invariants That Must Remain True

Please verify and refine these invariants:

- System prompt / hard rules are never pruned.
- Required 6 response headings are never pruned.
- Current user instruction is never pruned.
- Active Lua snippet is never pruned for `luaRepair` or `validationDebug`.
- Exact user-confirmed Side, Mission, Unit, GUID, DBID, Loadout ID, RP, Zone names are never removed if referenced by current instruction or current Lua.
- If required context is missing or omitted, AI must ask back instead of inventing values.
- `isPasteReady === true` remains the only UI path to apply Lua.
- Manual prompt-copy fallback remains available.
- No raw API key / Authorization / Bearer / localStorage / sessionStorage content is introduced into the pruning layer.
- If pruning confidence is low, fail conservative: summarize less or ask back.

## Review Questions

Please answer with a concise but technically specific review:

1. Is the proposed conservative Phase 3 scope safe enough to implement?
2. Which sections are safe to actually omit first?
3. Which sections must only be summarized, never omitted?
4. What should trigger `askBackRequired=true` after pruning?
5. What should trigger a hard block instead of sending the AI request?
6. Is `applyContextPruningAudit(prompt, context)` the right place to perform Phase 3 transformation, or should Codex introduce a separate `applyContextPruning()` function?
7. What static checks should Kimi run after implementation?

## Desired Output

Please provide:

- `safeToPruneFirst[]`
- `summarizeOnly[]`
- `neverPrune[]`
- `askBackTriggers[]`
- `hardBlockTriggers[]`
- recommended function/API shape
- Kimi QA checklist
- any red flags

Target length: 120-180 lines. Prefer concrete rules over broad prose.
