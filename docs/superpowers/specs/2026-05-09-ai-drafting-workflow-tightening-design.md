# AI Drafting Workflow Tightening Design - 2026-05-09

## Purpose

Track A completes the local web UI as an AI Lua interpreter / editor workstation before any direct CMO in-game integration begins.

Track A2 tightens the existing AI drafting loop so the user can move from intent to reviewed paste-ready Lua inside the local page without ambiguity. The page should clearly guide the user through AI call, response review, ask-back, blocker handling, follow-up drafting, manual prompt-copy fallback, and safe Working Draft application.

Track B remains deferred until A is complete.

## Current Baseline

Current public release:

```text
release-2026-05-09-cmo-lua-builder-template-inspector-search-filter
```

Already completed:

- Template Inspector annotations: `51 / 51`, `0` missing.
- Template Inspector Search / Filter UX release: complete.
- Prompt-copy fallback remains available.
- `parseAiInterpreterResponse()` classifies AI responses.
- `aiParsedResponse.isPasteReady` is the only Lua apply gate.
- `AiResponseReviewPanel` can draft follow-up instructions.
- `AiInterpreterChatPanel` can send follow-up chat prompts and keeps module-memory history capped at 5.
- `npm run verify:release` is the release verification entrypoint.

## A Completion Definition

Track A is complete when the local web UI can guide a user through this loop without relying on CMO integration:

```text
User intent
→ template / preset / context selection
→ AI request construction
→ AI response parsing
→ ready / ask-back / blocker / error state
→ follow-up or correction when needed
→ paste-ready Lua applied only through the gate
→ Working Draft remains an editable local draft
→ manual prompt-copy fallback remains available
→ CMO engine verification remains explicitly required
```

Completion does not mean CMO has executed the Lua. It means the local UI's AI interpreter loop is coherent, safe, and internally complete.

## Track A2 Scope

Track A2 focuses on workflow state clarity and UI alignment across:

- `src/components/LuaAssistant.jsx`
- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiResponseReviewPanel.jsx`
- The corresponding lazy CSS files if needed

Track A2 should create a single conceptual workflow state contract and align the visible UI language to it.

## Non-Goals

Track A2 must not introduce:

- CMO scenario folder writes.
- Sidecar Lua writer endpoints.
- ExceptionLog or LuaHistory tailing.
- Live scenario read-back.
- New backend endpoints.
- New dependencies or test frameworks.
- Raw API key persistence.
- Long-term localStorage memory.
- Any bypass of `aiParsedResponse.isPasteReady`.

Those belong to Track B or later Track A3 work.

## Workflow State Contract

The UI should speak in these states:

| State | Meaning | Apply Lua | Primary next action |
|---|---|---:|---|
| `idle` | No active AI response is available. | Disabled | Review prompt or use prompt-copy fallback. |
| `calling` | AI request is in flight. | Disabled | Wait; prevent duplicate sends. |
| `ready` | Parser found paste-ready Lua and no blockers. | Enabled | Review assumptions/checklist, apply to Working Draft if acceptable, then test in CMO. |
| `askBack` | AI needs user-confirmed CMO values before safe Lua. | Disabled | Confirm Side/Mission/GUID/DBID/RP/Zone/etc. in CMO UI and send follow-up. |
| `blocked` | Parser, safety, placeholder, unsafe Lua, missing section, pruning, or format gate blocks application. | Disabled | Inspect blocker and draft a corrective follow-up. |
| `error` | Adapter, provider, pruning audit, context-pack, or model-selection failure. | Disabled | Fix configuration or prompt context; prompt-copy fallback remains available. |

State labels may be localized, but the behavior must remain exact.

## UI Alignment

A2 should align three surfaces:

1. Main Output / Validation toolbar in `LuaAssistant.jsx`.
2. Review diagnostics in `AiResponseReviewPanel.jsx`.
3. Follow-up chat flow in `AiInterpreterChatPanel.jsx`.

All three should use the same state meaning:

- `ready` never implies CMO engine verification is complete.
- `askBack` means missing CMO-confirmed values, not a fatal parser failure.
- `blocked` means do not paste or apply; inspect and revise.
- `error` means call/setup/context failure rather than a Lua response state.

The main panel should make the current state easy to see before the user reaches secondary panels.

## Follow-Up Rules

- Follow-up drafts may be generated automatically as text.
- Follow-up drafts must not be sent automatically.
- User approval remains required for every AI call.
- Follow-up instructions should preserve the no-invention rule for Side, Mission, Unit GUID, DBID, Loadout ID, RP, Zone, posture, doctrine, EMCON, coordinates, and weather values.
- A follow-up that resolves ask-back values should return to the same parser/apply gate path as a first call.

## Manual Fallback Rules

Manual fallback is part of A completion, not a backup afterthought.

Must remain available:

- Main `Prompt 복사`.
- Chat `요청문 복사`.
- Working Draft manual editing.
- Generated / draft copy actions already present in the output surface.

Fallback wording should make clear that external AI output must still go through the same parser and safety expectations when brought back into the local UI.

## Agent Role Split

### Codex

Codex owns implementation, integration, commits, release orchestration, and handoff creation.

Codex must keep Track A2 inside the local UI scope and avoid opening Track B functionality.

### Kimi

Kimi owns QA, regression monitoring, bundle watch lines, smoke checks, and commit hygiene.

Kimi should verify:

- `npm run lint`
- `npm run build`
- `npm run smoke:ai-client-parser`
- `npm run smoke:ai-adapter`
- Main JS under `400 kB`
- Main CSS under `60 kB`
- `aiContextPruning` under `9 kB`
- `ready` enables Lua apply
- `askBack`, `blocked`, `error`, and `calling` disable Lua apply
- Prompt-copy fallback remains visible
- No raw credential or storage drift

### Claude

Claude owns workflow-state and safety-contract review.

Claude should review:

- State names and transition conditions.
- Whether ask-back and blocker states are distinct.
- Whether ready wording avoids implying CMO engine verification.
- Whether the A completion gate is sufficient before B0.
- Whether parser/pruning/apply-gate contracts are preserved.

### Gemini

Gemini owns Korean UX wording and beginner guidance.

Gemini should review:

- State labels and descriptions.
- Button and tooltip wording.
- Whether "Lua 초안" avoids overclaiming.
- Whether next actions are short and clear.
- Whether Korean/English mixed labels are acceptable.

## Suggested Slices

### A2-1: Workflow State Contract + UI Wording Alignment

Create a small shared state derivation for current AI workflow status and align the visible wording in main, review, and chat surfaces.

Expected changes:

- Add a pure workflow state helper, preferably near the UI owner rather than in server/backend code.
- Align state labels and next actions.
- Keep existing parser and apply gate intact.
- Add Kimi QA directive.

### A2-2: Ask-Back / Follow-Up Loop Polish

Make ask-back values and follow-up drafts easier to act on.

Expected changes:

- Improve follow-up draft wording.
- Surface missing value categories clearly.
- Keep user approval before AI send.
- Preserve manual prompt-copy fallback.

### A2-3: A Completion Checklist / Closeout

Document and verify that the local page is ready to serve as the base for Track B.

Expected changes:

- Add A completion checklist.
- Run focused QA.
- Close out Track A or decide whether A3 is needed first.

## Testing Strategy

No new test framework should be introduced for A2.

Use focused static and smoke verification:

- `npm run lint`
- `npm run build`
- `npm run smoke:ai-client-parser`
- `npm run smoke:ai-adapter`
- Targeted static checks for state labels, apply gate, prompt-copy fallback, and no credential/storage drift.

Manual or static QA scenarios:

1. Idle: no AI response, copy prompt available, apply disabled.
2. Calling: duplicate call prevented, apply disabled.
3. Ready: paste-ready response enables apply but still says CMO verification required.
4. Ask-back: follow-up questions disable apply and guide user to confirm CMO values.
5. Blocked: blocker disables apply and offers review/follow-up path.
6. Error: adapter/config/context failure disables apply and keeps fallback available.

## Success Criteria

A2-1 is successful when:

- The UI consistently communicates the current AI workflow state.
- The same response cannot look "ready" in one panel and "hold" in another without explanation.
- Apply remains impossible unless `aiParsedResponse.isPasteReady === true`.
- Ask-back and blocker states guide different next actions.
- User approval is still required before follow-up sends.
- No Track B integration behavior is introduced.

Track A moves toward completion when:

- A2-1 and A2-2 are complete and approved.
- A3 is either completed or explicitly declared unnecessary for the first B0 probe.
- The A completion checklist passes.

## Open Decision

The next implementation target should be:

```text
A2-1: Workflow State Contract + UI Wording Alignment
```

After this spec is approved, Codex should create an implementation plan and then open Claude / Gemini review directives before code changes if the wording or state contract remains ambiguous.
