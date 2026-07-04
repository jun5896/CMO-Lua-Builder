# AI Follow-Up Needs Design - 2026-05-09

## Purpose

Track A2-2 improves the ask-back and follow-up loop inside the local AI interpreter UI.

A2-1 made the AI response state consistent across the main Output panel, Review panel, and Chat panel. A2-2 builds on that by making `askBack` and `blocked` states easier to act on: the UI should show which CMO-confirmed values are missing or unsafe to invent, and the follow-up draft should carry those needs forward without sending anything automatically.

Track B remains deferred. This design does not touch CMO files, logs, live read-back, or backend endpoints.

## Current Baseline

Latest approved A2-1 commit:

```text
eb689df Align AI drafting workflow state
```

Latest A2-1 QA:

- Kimi QA: APPROVED / ARCHIVED.
- Static checkpoints: 38 / 38 PASS.
- Main JS: `371.44 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Main CSS has only about `0.86 kB` headroom below the `60 kB` soft line.

Existing useful behavior:

- `parseAiInterpreterResponse()` separates blockers, warnings, prerequisites, validation checklist, and follow-up questions.
- `deriveAiWorkflowState()` classifies `ready`, `askBack`, `blocked`, `error`, `calling`, and `idle`.
- `AiResponseReviewPanel` can draft a follow-up instruction.
- `AiInterpreterChatPanel` sends follow-up prompts only after user action.
- `Prompt 복사` and `요청문 복사` fallbacks remain available.
- `aiParsedResponse.isPasteReady` remains the only Lua apply gate.

## Problem

The UI currently tells the user that more review or more CMO values are needed, but it does not clearly group those needs.

Examples:

- A response may ask for a Side name, Mission name, Unit GUID, DBID, Loadout ID, RP/Zone, posture, doctrine, EMCON, coordinates, or weather range.
- These needs can appear in blockers, warnings, prerequisites, or follow-up questions.
- The current follow-up draft includes raw lists, but it does not summarize the categories or remind the model which values must be confirmed in CMO.
- A beginner can still wonder: "What exactly do I need to go find in CMO before asking again?"

## Goals

1. Surface missing or confirmation-needed CMO values as clear categories.
2. Improve the follow-up draft so it says what the user must confirm and what the AI must not invent.
3. Keep user approval required before every AI call.
4. Keep all apply-gate behavior unchanged.
5. Keep the change local to Track A UI and pure helper code.
6. Avoid adding to Main CSS unless absolutely necessary.

## Non-Goals

A2-2 must not introduce:

- CMO scenario folder writes.
- Sidecar Lua writer endpoints.
- ExceptionLog or LuaHistory tailing.
- Live scenario read-back.
- New backend endpoints.
- New dependencies or test frameworks.
- Long-term memory or localStorage/sessionStorage changes.
- Any bypass of `aiParsedResponse.isPasteReady`.
- Automatic follow-up sending.
- An input wizard for filling values. That belongs to A3 or Track B if still needed.

## Architecture

### New Pure Helper

Create a small pure helper:

```text
src/lib/aiFollowUpNeeds.js
```

It should export:

```javascript
FOLLOW_UP_NEED_CATEGORIES
deriveAiFollowUpNeeds(parsedResponse, applyBlockedReason)
formatFollowUpNeedsForPrompt(needs)
```

The helper reads strings from:

- `parsedResponse.blockers`
- `parsedResponse.warnings`
- `parsedResponse.followUpQuestions`
- `parsedResponse.prerequisites`
- `parsedResponse.missingRequiredSections`
- `applyBlockedReason`

It returns a compact object:

```javascript
{
  categories: [
    {
      id: 'side',
      label: 'Side',
      promptLabel: 'Side name',
      severity: 'confirm',
      reason: 'Side 이름은 CMO 내부 UI에서 확인해야 합니다.',
      evidence: ['...matched source text...'],
    },
  ],
  summary: 'Side, Unit GUID, DBID 확인 필요',
  hasNeeds: true,
}
```

The helper must be side-effect free:

- No React imports.
- No fetch.
- No filesystem access.
- No storage access.
- No credential strings.

### Categories

Initial categories:

| id | Label | Detect examples | Guidance |
|---|---|---|---|
| `side` | Side | `Side`, `side name`, `DetectorSideID`, `target_side` | Use actual CMO Side name. |
| `mission` | Mission | `Mission`, `mission name`, `AssignUnitToMission` | Use existing Mission name from CMO. |
| `unitGuid` | Unit GUID | `GUID`, `Unit GUID`, `unit id`, `Copy unit ID` | Prefer CMO "Copy unit ID to clipboard GUID". |
| `dbid` | DBID | `DBID`, `Database Viewer`, `weapon dbid`, `aircraft dbid` | Confirm in current scenario DB. |
| `loadout` | Loadout ID | `Loadout`, `loadoutId`, `Loadout ID` | Confirm in current DB/loadout context. |
| `rpZone` | RP / Zone | `RP`, `Reference Point`, `Zone`, `No-Nav`, `Exclusion` | Use existing RP/Zone names or map coordinates from CMO. |
| `postureDoctrine` | Posture / Doctrine / EMCON | `posture`, `Doctrine`, `EMCON`, `WRA` | Do not infer relationship/EMCON settings. |
| `coordinates` | Coordinates | `latitude`, `longitude`, `lat`, `lon`, `coordinate` | Use CMO map values; do not invent. |
| `weather` | Weather | `weather`, `sea state`, `rain`, `cloud`, `temperature` | Use explicit bounded values. |
| `format` | Response Format | `Missing section`, `Paste-ready Lua`, `fenced Lua` | Ask the model to preserve required headings. |
| `unsafeLua` | Unsafe Lua | `unsafe Lua`, `os.`, `io.`, `require`, `dofile`, `loadfile` | Ask for CMO-safe Lua surface only. |

`format` and `unsafeLua` are not CMO lookup values, but they are useful corrective categories for blocked responses.

### Severity

Use three severities:

- `confirm`: user must confirm real CMO values.
- `format`: AI must fix response shape.
- `safety`: AI must remove unsafe/placeholder behavior.

This keeps value lookup separate from parser/safety correction.

## UI Changes

### Review Panel

Modify:

```text
src/components/AiResponseReviewPanel.jsx
src/components/AiResponseReviewPanel.css
```

Add a "CMO에서 확인할 값" card when `deriveAiFollowUpNeeds(...).hasNeeds === true`.

The card should:

- Show up to the first 6 categories.
- Use compact badges with label and severity tone.
- Show one short guidance sentence per category.
- Include evidence only in `<details>` or a compact secondary line to avoid visual noise.
- Stay inside the lazy Review panel CSS, not `src/index.css`.

Empty state:

- If no categories are detected but the response is blocked, show "분류된 확인값 없음. 차단 사유와 응답 형식을 먼저 확인하세요."
- Do not show the card for clean `ready` responses unless categories are present from warnings.

### Follow-Up Draft

Update `buildFollowUpInstruction()` in `AiResponseReviewPanel.jsx`.

The generated draft should include:

```text
확인 필요값:
- Side: CMO UI의 실제 Side 이름을 사용
- Unit GUID: 배치된 유닛은 Copy unit ID to clipboard GUID 우선
- DBID: 현재 시나리오 DB의 Database Viewer 기준

규칙:
- Side/Mission/GUID/DBID/Loadout/RP/Zone/posture/doctrine/EMCON/coordinates/weather 값은 추측하지 말 것
- 부족하면 BLOCKER 또는 Follow-up question으로 되물을 것
- 안전한 경우에만 ## Paste-ready Lua 섹션에 fenced Lua를 작성할 것
```

The draft must remain plain text inserted into chat input. It must not call AI automatically.

### Chat Panel

A2-2 should avoid changing `AiInterpreterChatPanel.jsx` unless needed for copy consistency.

Allowed minimal change:

- If the follow-up draft is present, the existing chat panel can keep showing it as user-editable text.
- No new send behavior.
- No history/storage changes.

## Testing Strategy

No new test framework.

Add a focused Node smoke:

```text
tools/verify-ai-follow-up-needs-contract.mjs
```

Add package script:

```json
"smoke:ai-follow-up-needs": "node tools/verify-ai-follow-up-needs-contract.mjs"
```

Smoke coverage:

1. Side/Mission/GUID/DBID/Loadout/RP/Zone/Posture/Doctrine/EMCON categories are detected from mixed parser text.
2. Format category is detected from missing section / missing Paste-ready Lua language.
3. Unsafe Lua category is detected from unsafe Lua blocker text.
4. Duplicate evidence does not duplicate categories.
5. Empty parsed response returns `hasNeeds === false`.
6. `formatFollowUpNeedsForPrompt()` includes no-invention wording and category labels.
7. Returned arrays are fresh and mutation-safe.

Standard verification:

```powershell
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

Bundle watch:

- Main JS must stay below `400 kB`.
- Main CSS must stay below `60 kB`.
- `aiContextPruning` must stay below `9 kB`.
- Review panel lazy CSS may grow modestly.
- Avoid `src/index.css` changes for A2-2.

## Kimi QA Focus

Kimi should verify:

- New helper exists and is covered by smoke.
- New package script exists; no package-lock drift.
- Review panel shows grouped needs for ask-back/blocked cases.
- Follow-up draft includes grouped needs and no-invention rules.
- Follow-up draft is not sent automatically.
- Apply buttons remain gated by `canApplyLua`.
- `parseAiInterpreterResponse()` unchanged.
- `aiContextPruning.js` unchanged.
- No Track B behavior.
- No new credential/storage strings.
- Main CSS stays below `60 kB`.

## Success Criteria

A2-2 is successful when:

- A blocked or ask-back response gives the user a clear checklist of what to confirm in CMO.
- The follow-up draft is more actionable than a raw blocker dump.
- The AI is explicitly reminded not to invent CMO identifiers, names, posture/doctrine/EMCON, coordinates, or weather values.
- The user still has to press the AI call button manually.
- The apply gate remains unchanged.
- No Track B integration behavior is introduced.

## Recommended Implementation Slice

Implement as one focused product slice:

1. Add `aiFollowUpNeeds` helper and smoke.
2. Wire Review panel needs card and follow-up draft formatting.
3. Run focused verification.
4. Open Kimi QA directive.

Do not release-tag A2-2 until after Kimi approval and closeout.

## Open Decision

A2-2 should not add a value-entry wizard. If users still struggle after this polish, A3 can decide whether session context or a lightweight value staging UI is needed.
