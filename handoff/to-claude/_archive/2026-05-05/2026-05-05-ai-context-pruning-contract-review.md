# Open Signal — AI Context Pruning Contract Review

## Status

Requested by Codex/user on 2026-05-05.

Mode for Claude: **read-only contract review / technical planning only**.

Do not edit `src/**`, `server/**`, `tools/**`, package files, or handoff files unless Codex explicitly opens a later implementation signal.

## Why This Exists

Codex has stabilized the first AI assistant workflow:

- Provider settings and model list lookup
- Multiple model profiles without storing raw API keys
- Event/Lua Assistant profile selection via `providerOverride`
- Interpreter chat panel
- Structured AI response review
- Follow-up draft loop
- Session-only chat history
- `isPasteReady === true` gate for applying Lua

The next risk is token bloat. Scenario summaries, Lua bundles, object registries, API detections, template guidance, and CMO safety rules can become too large if every AI call receives everything.

Codex wants to add a **context pruning / context pack** layer before expanding the assistant further.

## Review Goal

Define what context can be safely reduced before an AI call, without weakening:

- CMO object safety
- parser contract
- ask-back behavior
- paste-ready Lua gate
- provider security
- manual prompt-copy fallback

This review should produce a practical contract Codex can implement.

## Current Implementation Context

Important current files in Codex workspace:

- `src/components/LuaAssistant.jsx`
- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiResponseReviewPanel.jsx`
- `src/lib/aiAdapterClient.js`
- `src/lib/aiProviderProfiles.js`
- `public/cmo-ai-system-prompt.txt`
- `server/ai-provider-adapter.mjs`
- `server/providers.mjs`

Current stable behavior:

- `LuaAssistant.jsx` owns `aiResponse`, `parseAiInterpreterResponse`, blockers/warnings, and `isPasteReady`.
- `AiInterpreterChatPanel` is lazy-loaded and only composes UI-local chat instructions.
- `AiResponseReviewPanel` is lazy-loaded and can draft follow-up instructions, but cannot apply Lua directly without parent gate.
- `sendCmoAiPrompt()` sends the system prompt plus user prompt to the adapter.
- `providerOverride` can select a saved provider/model profile, but raw API keys are not stored in profile data.

## Contract Questions For Claude

Please answer these as a concise technical review.

### 1. Mandatory Context

Which context must **never** be pruned from an AI request?

Please classify at least:

- CMO hard rules / system prompt
- required response headings
- current user instruction
- active Lua snippet / selected Lua file
- scenario title / DB family / DB version / build
- selected Side/Mission/Unit/RP/Zone names already confirmed by the user
- parser blockers from the previous AI response
- validation checklist or CMO UI prerequisites

### 2. Safely Prunable Context

Which context can be omitted or summarized first?

Please classify at least:

- full unit lists
- full mission lists
- full reference point / zone lists
- entire Lua bundle contents
- detected API catalog
- template annotation text
- DB/loadout hints
- large scenario sidecar summaries
- previous chat history

### 3. Intent Categories

Propose a compact first-pass intent taxonomy for pruning.

Expected categories may include:

- `luaRepair`
- `eventAction`
- `missionAssignment`
- `unitSpawnOrEdit`
- `doctrineEmcon`
- `referencePointZone`
- `dbidLoadout`
- `scenarioInspection`
- `validationDebug`
- `generalAskBack`

Adjust this list if needed.

For each category, state which context sections should be included first.

### 4. Context Pack Shape

Propose a JSON-ish shape for the context pack Codex should build before composing the final prompt.

Suggested starting point:

```json
{
  "intent": "luaRepair",
  "includeSections": ["activeLua", "scenarioMeta", "confirmedObjects"],
  "omittedSections": ["fullUnitList", "fullLuaBundle"],
  "requiredButMissing": ["missionName"],
  "askBackRequired": true,
  "tokenBudgetNotes": ["full unit list omitted; ask user to narrow side/unit if needed"]
}
```

Please refine this shape.

### 5. Ask-Back Rules

Define when pruning must force the AI to ask back rather than infer.

Important examples:

- user asks to assign a unit but no Side/Mission/Unit is confirmed
- user asks to spawn a platform but no DBID/loadout is confirmed
- user references a zone/RP by vague description only
- active Lua contains placeholders
- selected context was intentionally omitted because it was too large

### 6. Safety Invariants

Confirm which invariants must remain unchanged after context pruning:

- no invented DBID/GUID/Loadout ID/object names
- no unsafe Lua surfaces such as `os.*`, `io.*`, `require`, `dofile`, `loadfile`, `debug.*`
- no placeholder tokens inside paste-ready Lua
- `## Paste-ready Lua` remains required
- `isPasteReady === true` remains the only UI apply path
- manual prompt-copy fallback remains available
- provider API keys remain backend-memory only and are never stored in frontend profiles/history

### 7. Implementation Risk Notes

Please call out likely mistakes Codex should avoid.

Examples:

- pruning too aggressively and causing hallucinated object names
- hiding required scenario metadata
- mixing chat history into the final prompt without size caps
- moving safety rules behind a lazy UI-only import
- treating a summarized unit list as authoritative if names were omitted

## Expected Claude Deliverable

Please write a concise review back to Codex with:

1. Recommended mandatory context list
2. Recommended prunable context list
3. Intent taxonomy table
4. Proposed context pack contract
5. Ask-back trigger rules
6. Safety invariants
7. Any blockers or open questions before Codex implements

Target length: around 120-180 lines.

No code patch is required unless Codex explicitly opens a follow-up implementation signal.

## Current Agent Roles

- Codex: final implementer/integrator
- Claude: contract and technical safety review
- Kimi: QA/build/smoke/bundle verification after Codex implementation
- Gemini: Korean UX wording / user-facing explanation review if needed
