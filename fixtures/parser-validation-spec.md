# Parser Validation Spec

Target parser: `parse-cmo-event-export.mjs` (Claude backend task)
Input scope: `fixtures/event-export-samples/*.txt`

## Input → Expected Output Matrix

### 1. tool-dump-events-sample.txt

**Source type:** `toolDumpEvents`
**Expected event count:** 3

| Event # | Name | isActive | isRepeatable | probability | Lua Actions |
|---------|------|----------|--------------|-------------|-------------|
| 1 | Ready All Aircraft | true | true | 100 | 0 |
| 2 | Intel Update | true | false | 100 | 2 |
| 3 | Delayed Strike Wave | false | false | 75 | 1 |

**Expected `detectedApis`:** (none — this dump format does not contain raw Lua scripts)

**Expected `warnings`:**
- `["Event #3 has no description; preserving empty string"]`

---

### 2. scenedit-getevent-sample.txt

**Source type:** `scenEditGetEvent`
**Expected event count:** 1

**Expected `events[0]`:**
```json
{
  "name": "Intel Update",
  "description": "Display intel update message via special action.",
  "isActive": true,
  "isRepeatable": false,
  "probability": 100,
  "triggers": [
    { "type": "SpecialAction", "specialaction": "Intel Update", "mode": "Scored", "random": false }
  ],
  "conditions": [
    { "type": "LuaScript", "description": "Check side exists", "script": "local side = 'Israel'\nif ScenEdit_GetSideOptions(side).name then\n  return true\nend\nreturn false", "isInverted": false }
  ],
  "actions": [
    { "type": "LuaScript", "description": "Send intel message", "script": "ScenEdit_SpecialMessage('Israel', 'Intel updated at T+5min')\nWorld_GetMoveVector()", "isInverted": false },
    { "type": "Points", "description": "Award points", "side": "Israel", "points": 100, "reset": false }
  ],
  "luaScripts": [
    "local side = 'Israel'\nif ScenEdit_GetSideOptions(side).name then\n  return true\nend\nreturn false",
    "ScenEdit_SpecialMessage('Israel', 'Intel updated at T+5min')\nWorld_GetMoveVector()"
  ]
}
```

**Expected `detectedApis`:**
```json
[
  "ScenEdit_GetEvent",
  "ScenEdit_GetSideOptions",
  "ScenEdit_SpecialMessage",
  "World_GetMoveVector"
]
```

**Expected `warnings`:** `[]`

---

### 3. mixed-console-paste-sample.txt

**Source type:** `pastedLuaConsole` (with `mixed` heuristic because of garbled lines)
**Expected event count:** 1

**Expected `events[0]`:**
```json
{
  "name": "Delayed Strike Wave",
  "description": "",
  "isActive": false,
  "isRepeatable": false,
  "probability": 75,
  "triggers": [
    { "type": "Time", "time": 1800 }
  ],
  "conditions": [
    { "type": "UnitRemains", "unit": "F-15I Ra'am", "raw": { "type": "UnitRemains", "unit": "F-15I Ra'am" } }
  ],
  "actions": [
    { "type": "LuaScript", "description": "spawn strike", "script": "local g = ScenEdit_GetUnit({side='Israel', name='Strike Lead'})\nif g then\n  Command_ScenEdit_AddUnit({...})\n  VP_GetSide({side='Israel'})\nend", "isInverted": false }
  ],
  "luaScripts": [
    "local g = ScenEdit_GetUnit({side='Israel', name='Strike Lead'})\nif g then\n  Command_ScenEdit_AddUnit({...})\n  VP_GetSide({side='Israel'})\nend"
  ]
}
```

**Expected `detectedApis`:**
```json
[
  "ScenEdit_GetEvent",
  "ScenEdit_GetUnit",
  "Command_ScenEdit_AddUnit",
  "VP_GetSide"
]
```

**Expected `warnings`:**
```json
[
  "Detected garbled/incomplete lines in condition block; preserved raw fragment",
  "Detected trailing non-Lua text after closing brace; ignored 'Cheers, player123'",
  "Detected leading non-Lua text before opening brace; ignored 'Hey guys...'"
]
```

---

## Contract Rules (for Claude parser)

1. **Preserve raw:** Any field not explicitly mapped goes into `raw`.
2. **Lua extraction:** Every `LuaScript` action/condition script must be appended to `event.luaScripts[]`.
3. **API detection:** Scan all Lua bodies for regex `\b(ScenEdit_|VP_|Tool_|World_|Command_)\w+\b`.
4. **Tolerate imperfections:** Return warnings instead of throwing when input is ambiguous.
5. **No hard failures:** If a block is unreadable, emit a warning and continue parsing the rest.
