# Local Confirmed Context Workspace Design - 2026-05-09

## Purpose

Track A3 completes the next local AI editor step before Track B starts CMO in-game integration.

The local page already has the AI request builder, response parser, workflow state, follow-up needs review, Template Inspector coverage, and manual prompt-copy fallback. A3 adds a small "Confirmed Context Workspace" so values the user has verified in CMO can be carried through the local drafting loop without being reinvented or repeatedly retyped.

Track B remains deferred. This design does not read or write CMO scenario folders, logs, live state, or new backend endpoints.

## Current Baseline

Latest completed Track A checkpoint:

```text
b7dd3b6 Document AI drafting workflow A2 completion
290e1d7 Archive AI drafting workflow A2 completion QA
```

Current public release:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-search-filter
```

Current approved baseline:

- Main JS: `371.44 kB`, below the `400 kB` watch line.
- Main CSS: `59.14 kB`, below the `60 kB` watch line with about `0.86 kB` headroom.
- `aiContextPruning`: `8.56 kB`, below the `9 kB` hard line.
- Template Inspector annotations: `51 / 51`, `0` missing.
- `smoke:ai-workflow-state`: PASS.
- `smoke:ai-follow-up-needs`: PASS.
- `smoke:ai-client-parser`: PASS.
- `smoke:ai-adapter`: PASS, no raw auth leakage.

Existing local context surfaces:

- `objectContext` stores scenario names and identifiers entered or derived in the Context tab.
- `databaseContext` stores DB family/version, DBID, Loadout ID, GUID, and notes.
- `tempSessionPayload` already includes `objectContext` and `databaseContext`.
- `applyAssistantState()` already restores `objectContext` and `databaseContext`.
- `buildAssistantPrompt()` already tells the AI not to invent Side, Mission, Unit, RP/Zone, GUID, DBID, Loadout ID, coordinates, or weather values.
- `aiContextPruning` already uses `objectContext` and `databaseContext` for ask-back hints and identifier preservation.
- `AiResponseReviewPanel` can draft a follow-up instruction, but the user still has to connect missing values back to confirmed CMO facts manually.

## Problem

The UI has a place to enter context, but it does not clearly distinguish:

- Values copied from CMO or Database Viewer.
- Values inferred from a sidecar summary.
- Values that are only freeform notes.
- Values the AI asked the user to confirm.
- Values that are safe to carry into later prompt turns as source-backed facts.

This creates two frictions:

1. The same Side, Mission, Unit GUID, DBID, Loadout ID, RP/Zone, or coordinate values may need to be retyped across turns.
2. The AI prompt can contain object lists and notes, but it lacks a compact section that says, "These are user-confirmed CMO facts. Preserve them and do not substitute alternatives."

## Goals

1. Add a local-only workspace for confirmed CMO values.
2. Make each confirmed value source-labeled.
3. Feed confirmed values into AI prompt construction as explicit "user-confirmed CMO values".
4. Let follow-up drafting reuse confirmed values without auto-sending.
5. Keep persistence limited to the existing temp session/autosave payload.
6. Keep `aiParsedResponse.isPasteReady` as the only Lua apply gate.
7. Keep Track B work out of scope.
8. Avoid adding to `src/index.css`; Main CSS is close to its watch line.

## Non-Goals

A3 must not introduce:

- CMO scenario folder writes.
- Sidecar Lua writer endpoints.
- ExceptionLog or LuaHistory tailing.
- Live CMO read-back.
- New backend endpoints.
- New dependencies or test frameworks.
- Raw API key persistence.
- Permanent long-term memory.
- Automatic AI follow-up sending.
- Any bypass of `aiParsedResponse.isPasteReady`.
- A full object picker redesign. A3 should reuse the existing Context tab as much as possible.

## Selected Approach

Use the existing temp session/autosave route as the persistence layer.

Alternatives considered:

| Approach | Result | Reason |
| --- | --- | --- |
| Session-only React state | Not selected | Safest, but loses the workspace on reload and undermines the purpose of reducing repeated typing. |
| Existing temp session/autosave payload | Selected | Gives local continuity without adding a new storage channel or changing security boundaries. |
| Explicit import/export only | Not selected for first slice | Useful later, but too manual for the main drafting loop. |

This keeps A3 inside Track A: local editor state, local prompt quality, no game integration.

## Data Model

Add a small pure helper:

```text
src/lib/aiConfirmedContext.js
```

The helper should normalize entries into this shape:

```js
{
  id: "ctx_side_blue",
  type: "side",
  label: "Blue",
  value: "Blue",
  source: "manual-cmo-ui",
  sourceDetail: "Typed from CMO side list",
  notes: "",
  createdAt: "2026-05-09T00:00:00.000Z"
}
```

Supported `type` values for the first slice:

- `side`
- `mission`
- `unitGuid`
- `dbid`
- `loadout`
- `rpZone`
- `postureDoctrine`
- `coordinates`
- `weather`
- `note`

Supported `source` values for the first slice:

- `manual-cmo-ui`: user typed or pasted from CMO UI.
- `database-viewer`: value came from Database Viewer.
- `copy-unit-guid`: value came from Copy unit ID to clipboard.
- `scenario-sidecar-summary`: value came from the currently loaded sidecar summary, not live CMO read-back.
- `template-inspector`: value came from a template's requirement or safety hint.
- `ai-ask-back-resolution`: value was added while answering an AI ask-back.

Important constraints:

- Entries must not contain API keys, Bearer tokens, Authorization headers, or provider secrets.
- Duplicate handling should be deterministic. Same `type + value + source` should collapse to one entry.
- Helper outputs must be mutation-safe, returning cloned arrays/objects where practical.
- Display labels can be Korean in UI later, but helper constants should remain stable English identifiers.

## Prompt Integration

`buildAssistantPrompt()` should add a compact section when confirmed values exist:

```text
## User-confirmed CMO values
- Side: Blue (source: CMO UI)
- Unit GUID: 2f... (source: Copy unit ID to clipboard)
- DBID: 1234 (source: Database Viewer)

Use these exact values when relevant. Do not replace them with guessed alternatives. If a required value is not listed here, ask back instead of inventing it.
```

This section should appear near the existing object and database context blocks, before the final no-invention constraints.

The prompt should still include `objectContext` and `databaseContext`. A3 does not delete those surfaces; it gives the user a way to mark selected values as confirmed and source-backed.

## UI Integration

Reuse the existing Context tab inside `LuaAssistant.jsx`.

First slice UI:

- Add a "Confirmed Context" section below or near the existing object/database context cards.
- Show confirmed entries as compact chips grouped by type.
- Provide a small form with:
  - type selector,
  - value input,
  - source selector,
  - optional note/source detail,
  - add button.
- Provide small "promote" actions from existing `databaseContext` fields where low-risk:
  - Unit GUID -> `unitGuid`, source `copy-unit-guid` or `manual-cmo-ui`.
  - Platform DBID -> `dbid`, source `database-viewer`.
  - Loadout ID -> `loadout`, source `database-viewer`.
  - Notes -> `note`, source `manual-cmo-ui`.
- Keep deletion local and explicit. Removing a confirmed entry should not clear the original object/database fields.

Avoid a broad visual redesign. The goal is a dependable local context rail, not a new template wizard.

## Temp Session Integration

Extend `tempSessionPayload` with:

```js
confirmedContext
```

Update:

- Initial React state.
- Payload save path.
- `applyAssistantState()` restore path.
- `hasMeaningfulAssistantState()` diff check.
- Reset/clear behavior where existing assistant state is intentionally cleared.

Persistence remains whatever the existing temp session/autosave flow already does. A3 should not add a separate `localStorage` or `sessionStorage` feature.

## Follow-Up Integration

`AiResponseReviewPanel` can receive confirmed context in a later implementation slice if needed, but the first implementation can keep follow-up behavior simple:

- Follow-up draft remains text-only.
- No automatic send.
- If confirmed values exist, the draft can include a compact "Already confirmed" block.
- Missing values from `aiFollowUpNeeds` still remain ask-back requirements.
- Confirmed values must not suppress safety categories such as unsafe Lua or response format problems.

## Context Pruning Integration

A3 should be conservative:

- Keep `aiContextPruning.js` behavior unchanged unless a small pure helper extension is clearly needed.
- Confirmed DBID/GUID values should naturally appear in the prompt's confirmed-values section, allowing existing identifier-preservation checks to see them.
- If the implementation needs pruning awareness, pass `confirmedContext` through the pruning context as a read-only list. Do not weaken any hard block.
- `confirmedIdentifiersStripped` must remain a hard block.

## Testing

Add a small smoke script:

```text
tools/verify-ai-confirmed-context.mjs
```

Add package script:

```text
smoke:ai-confirmed-context
```

The smoke should cover:

1. Normalization of all first-slice types.
2. Source label mapping.
3. Duplicate collapse.
4. Prompt formatting includes exact values and no-invention language.
5. Empty state returns no prompt section.
6. Returned arrays/objects are mutation-safe enough for UI use.
7. Credential-like strings are rejected or redacted if the helper accepts freeform values.

Expected A3 verification pipeline:

```text
npm run smoke:ai-confirmed-context
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

`npm run verify:release` remains the full release gate later, but the focused A3 QA should include the new smoke first.

## QA Checklist For Kimi

Static checkpoints should verify:

1. `src/lib/aiConfirmedContext.js` exists and exports pure helpers.
2. No new dependency or lockfile drift.
3. No new backend endpoint.
4. No CMO filesystem read/write path.
5. No sidecar writer or log tailing.
6. No new `localStorage` or `sessionStorage` persistence channel for confirmed context.
7. `tempSessionPayload` includes `confirmedContext`.
8. `applyAssistantState()` restores `confirmedContext`.
9. `hasMeaningfulAssistantState()` accounts for `confirmedContext`.
10. Prompt contains `User-confirmed CMO values` only when entries exist.
11. Prompt tells the AI not to replace confirmed values with guessed alternatives.
12. Duplicate confirmed entries collapse deterministically.
13. Entries expose source labels.
14. UI shows confirmed chips grouped or clearly labeled by type.
15. Removing a confirmed chip does not clear original object/database context fields.
16. Follow-up draft remains text-only and user-triggered.
17. Apply buttons remain controlled by `canApplyAiLua`.
18. `aiParsedResponse.isPasteReady` remains the only apply gate.
19. `aiContextPruning` hard blocks are not weakened.
20. Prompt-copy fallback remains.
21. Main JS remains below `400 kB`.
22. Main CSS remains below `60 kB`.
23. `aiContextPruning` remains below `9 kB`.
24. AI adapter smoke shows no raw auth leakage.

## Risks

| Risk | Mitigation |
| --- | --- |
| Confirmed values feel like engine-verified Lua | Use wording such as "CMO-confirmed value" only for facts, and keep "AI draft / CMO engine verification required" language intact. |
| Main CSS crosses `60 kB` | Do not add `src/index.css`; keep any style changes in lazy component CSS or existing local CSS. |
| User assumes sidecar summary is live CMO state | Label `scenario-sidecar-summary` as "loaded summary, not live read-back". |
| Over-broad persistence becomes unwanted memory | Use existing temp session only; defer long-term learning to a later explicit Track A decision. |
| Confirmed values override missing safety needs | Confirmed values are facts, not safety waivers. Unsafe Lua and format blockers remain blockers. |

## Completion Definition

A3 is complete when:

- The user can add source-labeled confirmed context values in the local page.
- Those values survive the existing temp session/autosave restore path.
- AI prompts include a clear confirmed-values section.
- Follow-up drafting can reuse confirmed values without auto-sending.
- No Track B integration is introduced.
- Focused smoke and standard safety checks pass.
- Kimi QA approves the implementation and closeout docs.

## Next Step After Approval

If this design is approved, the next step is an implementation plan for the first A3 slice:

1. Pure helper and smoke test.
2. `LuaAssistant.jsx` state, temp session, and prompt integration.
3. Minimal Context tab UI.
4. Optional follow-up draft inclusion if the bundle/CSS budget remains healthy.
5. Kimi QA directive and closeout.
