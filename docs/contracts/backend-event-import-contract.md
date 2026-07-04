# Backend Event Import Contract

**Task:** Claude Task 1 — CMO Event Export Parser
**Source spec:** `~/.codex/cmo-lua-ui/handoff/to-claude/2026-05-02-task-1-event-export-parser.md`
**Implementation:** `tools/parse-cmo-event-export.mjs` (Claude workspace)
**Status:** draft — awaiting codex review

---

## Purpose

Convert CMO engine-exported event/Lua text into a stable JSON shape that codex's UI can consume. Tolerant of imperfect copy/paste; preserves unknowns under `raw`; never decodes `.scen` `Scenario_Compressed` payloads.

---

## Supported input types

| Source `type` | Detection cue | Notes |
|---|---|---|
| `toolDumpEvents` | `<EventTriggers>`, `<EventActions>`, `<SimEvents>`, `<SpecialActions>` containers (or legacy `<Event>` blocks) | Output of `Tool_DumpEvents()`. **Real CMO format calibrated 2026-05-02.** Best fidelity. |
| `scenEditGetEvent` | Lua table dump containing `name = "..."` + `triggers = {...}` | Output of `ScenEdit_GetEvent(...)` printed via Lua Console. |
| `pastedLuaConsole` | `ScenEdit_SetEvent(...)`, `ScenEdit_SetTrigger(...)`, etc. | Code that the user pasted into / copied from the Console. |
| `mixed` | n/a | Combination of multiple types in one input. Parser tries all, dedupes by event name. |
| `unknown` | nothing matches | Returns `events: []` plus warnings. |

You can override auto-detection with `--type <t>`.

### Real CMO `Tool_DumpEvents()` shape (verified 2026-05-02)

```xml
<EventTriggers>
  <EventTrigger_<TYPE>>            <!-- TYPE in element name; UnitDestroyed, RegularTime, ... -->
    <ID>BI5B3D-...</ID>            <!-- pool key -->
    <Description>foo</Description>  <!-- this is the trigger's NAME (not <Name>) -->
    ...type-specific fields...
  </EventTrigger_<TYPE>>
  ...more triggers...
</EventTriggers>

<EventConditions>
  <EventCondition_LuaScript>
    <ID>...</ID>
    <Description>Lua_Foo</Description>
    <ScriptText>...lua source (XML-entity-encoded)...</ScriptText>
  </EventCondition_LuaScript>
</EventConditions>

<EventActions>
  <EventAction_<TYPE>>             <!-- LuaScript / Points / ChangeMissionStatus / EndScenario / ... -->
    <ID>...</ID>
    <Description>...</Description>
    <ScriptText>...</ScriptText>   <!-- only if TYPE == LuaScript -->
    <ScriptFor>0</ScriptFor>       <!-- LuaScript only -->
    ...other type-specific fields...
  </EventAction_<TYPE>>
</EventActions>

<SimEvents>
  <SimEvent>
    <ID>...</ID>
    <Description>EventName</Description>      <!-- this is the EVENT name -->
    <IsRepeatable>True</IsRepeatable>
    <IsActive>True</IsActive>
    <IsShown>True</IsShown>
    <Probability>100</Probability>
    <Triggers>
      <Trigger>BI5B3D-...</Trigger>            <!-- ID reference into trigger pool -->
    </Triggers>
    <Conditions />                              <!-- self-closing if empty -->
    <Actions>
      <Action>BI5B3D-...</Action>               <!-- ID reference into action pool -->
    </Actions>
  </SimEvent>
</SimEvents>

<SpecialActions>
  <SpecialAction>
    <ID>...</ID>
    <Name>Display name</Name>                   <!-- <Name> here, NOT <Description> -->
    <Description>Tooltip text</Description>
    <IsRepeatable>True</IsRepeatable>
    <IsActive>True</IsActive>
    <ScriptText>...</ScriptText>
  </SpecialAction>
</SpecialActions>
```

Key model: pool + reference. Triggers/Conditions/Actions are independent ID-keyed pools; SimEvents reference them by ID. SpecialActions are independent of events.

XML entity encoding: `<`, `>`, `&` are `&lt;`, `&gt;`, `&amp;` inside `<ScriptText>` and free text. Parser decodes entities for `luaScript` field; `raw` keeps original.

---

## Output schema (JSON)

> **Schema extension (2026-05-02 calibration):** Added top-level `specialActions[]` array. Codex's original spec mentioned `objectContext.specialActions` as a name-list only, but real CMO `Tool_DumpEvents()` output ships SpecialAction objects with full bodies (id, name, description, isActive, isRepeatable, luaScript). They are NOT bound to events, so they live at top level. Names are also mirrored into `objectContext.specialActions` for backward compat.

```jsonc
{
  "source": {
    "type":     "toolDumpEvents | scenEditGetEvent | pastedLuaConsole | mixed | unknown",
    "fileName": "input.txt or null",
    "parsedAt": "2026-05-02T12:34:56.000Z"
  },
  "scenario": {                     // best-effort; any field may be absent
    "title":     "Demo Strike East Sea",
    "dbVersion": "DB3K_516",
    "build":     "1852"
  },
  "events": [
    {
      "name":         "Hostilities_Open",
      "description":  "(optional)",
      "isActive":     true,
      "isRepeatable": false,
      "probability":  100,
      "triggers": [
        {
          "name": "Hostilities_Open_trig",
          "type": "UnitDestroyed",
          "raw":  "<original block as captured (string)>"
        }
      ],
      "conditions": [],
      "actions": [
        {
          "name":      "Hostilities_Open_action",
          "type":      "LuaScript",
          "luaScript": "...the Lua body, unmodified...",
          "raw":       "<original block as captured (string)>"
        }
      ],
      "luaScripts": [
        "...same Lua body(ies), deduped..."
      ]
    }
  ],
  "specialActions": [               // NEW: top-level array, real-CMO observed
    {
      "id":           "BI5B3D-0HN2LHBUUGB2Q",
      "name":         "Attempt search and rescue",
      "description":  "Attempt to rescue a downed pilot...",
      "isActive":     true,
      "isRepeatable": true,
      "luaScript":    "AttemptRescue()"
    }
  ],
  "objectContext": {                // best-effort name harvest
    "sides":           ["Blue", "Red"],
    "missions":        ["Blue_East_Sea_CAP"],
    "units":           ["QRA-Osan-1"],
    "referencePoints": ["ESEA-RP-1"],
    "zones":           [],
    "specialActions":  ["Attempt search and rescue"],   // names mirrored from top-level
    "luaFiles":        []
  },
  "detectedApis": [                 // dedup'd, sorted
    "ScenEdit_GetKeyValue",
    "ScenEdit_SetKeyValue",
    "ScenEdit_SetSidePosture",
    "ScenEdit_SpecialMessage"
  ],
  "warnings": [
    "(human-readable strings; never throws)"
  ]
}
```

### Field-by-field rules

- `source.type` is one of the 5 enum values above.
- `source.parsedAt` is an ISO-8601 UTC timestamp.
- `scenario.*` fields are **optional** — present only when the parser can confidently extract them. Never fabricated.
- `events[].name` defaults to `'unnamed'` when no name is found in source.
- `events[].isActive` defaults to `true`, `isRepeatable` to `false`, `probability` to `100`.
- `events[].triggers/conditions/actions` arrays may be empty.
- Each child object has `name`, `type`, `raw` at minimum.
- `actions[*].luaScript` is set when `type == 'LuaScript'` and a body could be extracted.
- `events[].luaScripts` is the deduped list of all Lua bodies attached to that event's actions (convenience for downstream scoring/display).
- `objectContext` arrays are dedup'd lists of names found via `<key> = "..."` patterns. **Hints, not authoritative** — UI should treat them as suggestions until the user verifies.
- `detectedApis` is sorted, deduped, no namespace prefix stripped.
- `warnings` is always an array; empty when nothing is suspect.

### Stability guarantees

- Parser **never throws** on malformed input. Errors surface as warnings + empty events.
- `raw` strings preserve original bytes (whitespace + nested tables intact). Downstream can re-parse if needed.
- `luaScripts` and `actions[].luaScript` are byte-identical to the source (no rewriting / formatting).

### Compatibility caveats

- The Lua-table parser is regex-based, not a full Lua parser. Edge cases:
  - Strings containing literal `}` may confuse boundary detection. Mitigation: balanced-brace tracking is on, but quoted strings with unbalanced braces inside are NOT respected. Such inputs will produce a warning.
  - Multi-event dumps from `ScenEdit_GetEvent` (if such a thing exists in CMO) are handled per-event by sniffing `name = "..."` proximity to `triggers = {`.
- The XML parser is permissive (case-insensitive tag names, attribute or element form for fields). It does not validate against any DTD.

---

## CLI

```bash
node tools/parse-cmo-event-export.mjs <input.txt> [--out <out.json>] [--type <t>]
node tools/parse-cmo-event-export.mjs --stdin [--type <t>]
```

| Flag | Meaning |
|---|---|
| `<input>` (positional) | Path to input file. Required unless `--stdin`. |
| `--stdin` | Read input from standard input. |
| `--type <t>` | Force source type. One of the 5 enum values. |
| `--out <path>` | Write JSON to file. Without it, JSON goes to stdout. |
| `-h`, `--help` | Usage message. |

Exit codes: `0` always (parser is total — bad input → empty events + warnings).

### Programmatic usage

The module exports `parse(text, opts)` so codex's UI can call it directly without spawning a process:

```js
import { parse } from './parse-cmo-event-export.mjs';
const result = parse(text, { type: 'toolDumpEvents', fileName: 'dump.xml' });
```

---

## Test fixtures + samples

Bundled in `handoff/to-codex/Task-1/`:

```
fixtures/
  fixture-01-tool-dump-events.xml      Tool_DumpEvents() XML, 2 events
  fixture-02-scenedit-getevent.lua     ScenEdit_GetEvent table dump, 1 event
  fixture-03-pasted-console.lua        Pasted console code, 1 event
samples/
  sample-01.json                       parser output for fixture-01
  sample-02.json                       parser output for fixture-02
  sample-03.json                       parser output for fixture-03
```

Reproduce:
```bash
node tools/parse-cmo-event-export.mjs handoff/to-codex/Task-1/fixtures/fixture-01-tool-dump-events.xml \
     --out handoff/to-codex/Task-1/samples/sample-01.json
```

Smoke-test results (current run):

| Fixture | Type | Events | LuaScripts | Warnings |
|---|---|---|---|---|
| 01 (XML)  | `toolDumpEvents`   | 2 | 2 (139B + 132B) | 0 |
| 02 (Lua)  | `scenEditGetEvent` | 1 | 1 (348B)        | 0 |
| 03 (Lua)  | `pastedLuaConsole` | 1 | 1 (332B)        | 0 |

---

## Scope boundary (Claude side)

- Parser is **UI-agnostic** — no DOM, no React, no fetch. Pure Node.js.
- No network calls, no file writes outside `--out`.
- No API key handling, no LLM inference.
- Lives entirely in Claude's workspace until codex pulls it in.
- Future enhancements (e.g., richer Lua parsing) require either Claude proposing in `to-codex/` or codex opening another task.

---

## Codex integration path (per Codex spec)

When codex is ready to integrate:

1. Pull `tools/parse-cmo-event-export.mjs` to `cmo-lua-ui/tools/parse-cmo-event-export.mjs`.
2. Pull this contract to `cmo-lua-ui/docs/backend-event-import-contract.md`.
3. (Later) Wire into `LuaAssistant.jsx` import flow as an alternative to client-side regex analysis.

Codex retains final review/integration authority. Claude does not write into `~/.codex/`.

---

## Open questions (for codex)

1. Is the assumed XML shape from `Tool_DumpEvents()` realistic? If actual output differs, please paste a real sample and the parser can be adjusted.
2. Should `objectContext.units` distinguish between GUIDs and names? Currently a single dedup'd list — UI may want them split.
3. Should `detectedApis` carry call-site info (line/column / count) for richer downstream tooling?
4. For events with multiple actions, is the order in `actions[]` significant downstream? Parser preserves source order.

---

## Revision marker

| Rev | Date | Change |
|---|---|---|
| 1 | 2026-05-02 | Initial draft, 3 fixtures pass smoke test. |
