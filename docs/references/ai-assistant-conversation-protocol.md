# AI Assistant Conversation Protocol

Version: 0.1.0 (Phase A)  
Scope: Task 3 AI Provider Adapter → UI → LLM request/response contract  
Goal: Treat the AI as an **interpreter-style assistant**, not a one-shot code generator.

---

## 1. Message Architecture

Every chat request from the UI to the adapter (`POST /api/ai/chat`) contains a single JSON body. The `messages[]` array is built by the UI from the following sections.

### 1.1 System Prompt (Role & Guardrails)

```text
You are a Command: Modern Operations (CMO) Lua scripting assistant.
Your job is to help the player write safe, testable Lua scripts for the CMO scenario editor.

Rules:
1. NO HALLUCINATION: Never invent DBIDs, GUIDs, or unit names. Use strictly the names/IDs provided in context.
2. STATE PREREQUISITES: Explicitly list required CMO objects (Missions, RPs, Sides) before script execution.
3. PREFER GUIDS: Use GUIDs over names if provided. Otherwise, instruct the user to "Copy Unit ID to Clipboard".
4. REQUIRE TESTING: If an engine test is needed, state it explicitly and provide a minimal test plan.
5. PRESERVE WORKFLOW: Output MUST be paste-ready for the CMO Lua Console.
6. DEFENSIVE CODING: Always include nil checks and existence validations.
7. API USAGE: Stick to documented ScenEdit_* APIs unless advanced usage is requested.
8. EVENT MODEL: Follow CMO's exact structure: Trigger → Condition → Action.
9. LANGUAGE: Respond in the language used by the player.
```

### 1.2 Developer Context (Static Metadata)

```json
{
  "cmoVersion": "Command: Modern Operations Build 1852",
  "dbFamily": "DB3K",
  "uiContext": {
    "currentTab": "LuaAssistant | EventEditor | TemplateLibrary | PresetGuide",
    "intentType": "new_script | edit_existing | debug_error | explain_api | template_fill"
  }
}
```

### 1.3 User Intent Section

Captured from the UI form:

```json
{
  "playerSide": "Israel",
  "intent": {
    "action": "spawn_units_on_detection",
    "target": "Iranian CAP patrol",
    "prerequisites": ["Reference point CAP-01 exists", "Side 'Iran' exists"],
    "constraints": ["Only trigger once", "Must check unit count before spawning"]
  }
}
```

### 1.4 CMO Scenario Context Section

Injected from `parseInternalScenarioObjectContext()` or Task 2 summarizer:

```json
{
  "scenario": {
    "title": "Iran Strike, 2020-2030",
    "sides": ["Israel", "Iran", "United States", "Syria"],
    "missions": ["CAP North [Iran] (Patrol)", "EW Radars [Iran] (SupportMission)"],
    "referencePoints": ["Iran ADIZ [Israel]", "CAP-01 [Iran]"],
    "zones": ["Egypt NFZ [Israel] (NoNavZone)"],
    "units": ["F-15I Ra'am [Israel] type=Aircraft DBID=...", "USS Vermont [United States] type=Ship"],
    "specialActions": ["Ready All Aircraft [Israel] (active)", "Intel Update [Israel] (active)"],
    "events": ["Trigger: Iran Unit Destroyed (UnitDestroyed)", "Action: Iran Unit Destroyed (LuaScript)"]
  }
}
```

### 1.5 Lua Bundle Section

Any `.lua` files the user has loaded into the UI:

```json
{
  "loadedLuaFiles": [
    {
      "fileName": "Game_HourlyActions.lua",
      "detectedApis": ["ScenEdit_SpecialMessage", "World_GetMoveVector"],
      "sideRefs": ["Israel"],
      "missionRefs": [],
      "referencePointRefs": [],
      "specialActionRefs": ["Ready All Aircraft"]
    }
  ]
}
```

### 1.6 Template Inspector Guide Section (Optional)

If the user opened a specific template:

```json
{
  "template": {
    "name": "event_scramble",
    "category": "Event Automation",
    "prerequisite": "Side must have at least one airbase with active aircraft.",
    "commonApis": ["ScenEdit_AddUnit", "ScenEdit_SetMission", "VP_GetSide"],
    "riskNotes": ["Do not spawn inside existing unit stacking zones.", "Check runway capacity if spawning large groups."]
  }
}
```

---

## 2. Required AI Response Format

The adapter expects the upstream LLM to return a JSON body. The UI extracts the assistant's text and parses it into the following structure.

### 2.1 Top-Level Sections (in the assistant's markdown reply)

```markdown
## Analysis Summary
Brief explanation of what the script does and why it satisfies the player's intent.

## Assumptions
- Assumption 1 (e.g., "CAP-01 reference point exists and is owned by Iran side")
- Assumption 2 (e.g., "Player wants the event to fire only once")

## CMO UI Prerequisites
1. Open Mission Editor and create a Patrol mission named "CAP North" on the Iran side.
2. Place reference points "CAP-01" through "CAP-04" around the target area.
3. In Event Editor, create a new event; leave the trigger/condition/action slots empty — the script will manage them.

## Paste-Ready Lua
```lua
-- Safe spawn on detection
local side = 'Iran'
local rpName = 'CAP-01'
local rp = ScenEdit_GetReferencePoint({side=side, name=rpName})
if not rp then
  ScenEdit_SpecialMessage('Israel', 'Error: RP ' .. rpName .. ' not found on ' .. side)
  return
end
-- ... rest of script
```

## Validation Checklist
- [ ] Reference point exists
- [ ] Side name matches CMO exactly
- [ ] Event is set to repeatable if intended
- [ ] Script tested in Lua Console with `print()` before binding to event

## Questions / Blockers
(None — proceed if prerequisites are met.)
```

### 2.2 JSON Wrapper (Adapter → UI)

```json
{
  "ok": true,
  "providerType": "openai-compatible",
  "model": "gpt-4o-mini",
  "response": {
    "choices": [
      {
        "message": {
          "role": "assistant",
          "content": "## Analysis Summary\n...\n## Paste-Ready Lua\n```lua\n...\n```"
        }
      }
    ]
  }
}
```

The UI parses `content` as markdown and renders each `##` section into its own panel or tab.

---

## 3. Follow-Up Loop (Engine Error Feedback)

When the player pastes the script into CMO and gets an error, they can click **"Report Error"** in the UI. This sends a second chat request:

```json
{
  "messages": [
    ...previous history...,
    {
      "role": "user",
      "content": "ENGINE ERROR: attempt to index a nil value (local 'rp')\nLine 4: local rp = ScenEdit_GetReferencePoint({side='Iran', name='CAP-01'})"
    }
  ]
}
```

### Expected AI Behavior

1. **Diagnose** — explain why `rp` is nil (name mismatch, side mismatch, RP does not exist).
2. **Fix** — provide corrected code with a defensive fallback:
   ```lua
   local rp = ScenEdit_GetReferencePoint({side='Iran', name='CAP-01'})
   if not rp then
     ScenEdit_SpecialMessage('Israel', 'RP CAP-01 missing; aborting spawn.')
     return
   end
   ```
3. **Validate** — update the Validation Checklist with a new item:
   - [ ] Double-check RP name spelling in CMO Ref. Point Manager (case-sensitive).

---

## 4. Guardrails

| Rule | Enforcement |
|------|-------------|
| No invented DBIDs/GUIDs | System prompt + scenario context injection |
| Prefer CMO-created names | Scenario context lists exact names; AI must reuse them |
| Engine test required | Explicit "CMO UI Prerequisites" section in every response |
| Manual prompt-copy fallback preserved | UI always shows "Copy Prompt" button; adapter failure does not hide it |
| No raw API key in prompt | Adapter redacts keys before upstream; keys never reach LLM context |
| Single-shot only (Phase A) | Adapter buffers full response; no streaming UI expectations |

---

## 5. Phase A Limitations

- **No streaming:** The adapter returns a complete JSON object. UI animates the text after receipt (typewriter effect), not true streaming.
- **No persistent memory:** The adapter does not store conversation history. The UI must resend prior turns in `messages[]` if follow-up is needed.
- **No tool use:** The LLM cannot call back into CMO or the browser. All actions are paste-only.
- **No file upload:** The player cannot upload `.scen` or `.lua` files to the LLM. File contents must be inlined by the UI as text.

---

## 6. File Ownership

| File | Owner | Notes |
|------|-------|-------|
| `docs/ai-assistant-conversation-protocol.md` | Kimi | This document |
| `server/ai-provider-adapter.mjs` | Claude | HTTP proxy + redaction |
| `src/components/LuaAssistant.jsx` | Codex | UI that assembles `messages[]` |
