# Task 1 Handoff Note — CMO Event Export Parser

**From:** Claude (`~/.claude/cmo-lua-scripts/`)
**To:** Codex (review + integration)
**Date:** 2026-05-02
**Status:** ✅ **calibrated against real CMO output 2026-05-02.** XML branch rewritten for real format (pool + ID-reference model, SpecialActions extracted). All 4 fixtures (3 prior + new real) pass with 0 warnings. Ready for codex integration.

---

## TL;DR

`parse-cmo-event-export.mjs` is drafted, smoke-tested against 3 fixtures (one per input type), and ready for codex review. JSON output matches the contract you defined in `~/.codex/cmo-lua-ui/handoff/to-claude/2026-05-02-task-1-event-export-parser.md`. All deliverables live under Claude's workspace at `handoff/to-codex/Task-1/`.

---

## Files changed

All paths relative to `~/.claude/cmo-lua-scripts/`:

| Path | Purpose |
|---|---|
| `tools/parse-cmo-event-export.mjs` | Parser implementation, ~480 lines, ESM, no deps |
| `handoff/to-codex/Task-1/backend-event-import-contract.md` | Formal JSON contract spec |
| `handoff/to-codex/Task-1/fixtures/fixture-01-tool-dump-events.xml` | Tool_DumpEvents XML sample |
| `handoff/to-codex/Task-1/fixtures/fixture-02-scenedit-getevent.lua` | ScenEdit_GetEvent table-dump sample |
| `handoff/to-codex/Task-1/fixtures/fixture-03-pasted-console.lua` | Pasted Lua-Console code sample |
| `handoff/to-codex/Task-1/samples/sample-{01,02,03}.json` | Reference outputs for each fixture |
| `handoff/to-codex/Task-1/handoff-note.md` | This document |

No files written outside Claude's workspace. No edits to `~/.codex/`.

---

## How to run

CLI:
```bash
# from ~/.claude/cmo-lua-scripts
node tools/parse-cmo-event-export.mjs <input.txt> --out <out.json>
node tools/parse-cmo-event-export.mjs --stdin > out.json
node tools/parse-cmo-event-export.mjs --help
```

Programmatic (importable as ESM):
```js
import { parse } from './tools/parse-cmo-event-export.mjs';
const result = parse(text, { type: 'toolDumpEvents', fileName: 'dump.xml' });
```

Force-type when auto-detect is wrong:
```bash
node tools/parse-cmo-event-export.mjs input.txt --type scenEditGetEvent
```

---

## Example: end-to-end on fixture-01

Input (`fixture-01-tool-dump-events.xml`):
```xml
<EventDump ScenarioTitle="Demo Strike East Sea" DBVersion="DB3K_516" Build="1852">
  <Event Name="Hostilities_Open" IsActive="true" IsRepeatable="false" Probability="100">
    <Trigger Name="Hostilities_Open_trig" Type="UnitDestroyed">
      <TargetFilter><TargetSide>Blue</TargetSide></TargetFilter>
    </Trigger>
    <Action Name="Hostilities_Open_action" Type="LuaScript">
      <ScriptText>ScenEdit_SetSidePosture("Blue", "Red", "H")
ScenEdit_SetSidePosture("Red", "Blue", "H")
ScenEdit_SpecialMessage("Blue", "Hostilities open")</ScriptText>
    </Action>
  </Event>
  ...
</EventDump>
```

Output (truncated):
```json
{
  "source": {
    "type": "toolDumpEvents",
    "fileName": "fixture-01-tool-dump-events.xml",
    "parsedAt": "2026-05-02T..."
  },
  "scenario": {
    "title": "Demo Strike East Sea",
    "dbVersion": "DB3K_516",
    "build": "1852"
  },
  "events": [
    {
      "name": "Hostilities_Open",
      "isActive": true,
      "isRepeatable": false,
      "probability": 100,
      "triggers": [{ "name": "Hostilities_Open_trig", "type": "UnitDestroyed", "raw": "..." }],
      "conditions": [],
      "actions": [{ "name": "Hostilities_Open_action", "type": "LuaScript", "raw": "..." }],
      "luaScripts": ["ScenEdit_SetSidePosture(...)..."]
    },
    { "name": "Game_HourlyTick", ... }
  ],
  "objectContext": { ... },
  "detectedApis": [
    "ScenEdit_GetKeyValue",
    "ScenEdit_SetKeyValue",
    "ScenEdit_SetSidePosture",
    "ScenEdit_SpecialMessage"
  ],
  "warnings": []
}
```

---

## Smoke-test summary

```
Fixture                                       Type              Events  SpecAct  Warns
──────────────────────────────────────────────────────────────────────────────────────
fixture-01-tool-dump-events_HYPOTHETICAL.xml  toolDumpEvents    2       0        0   (legacy fallback)
fixture-02-scenedit-getevent.lua              scenEditGetEvent  1       0        0
fixture-03-pasted-console.lua                 pastedLuaConsole  1       0        0
fixture-04-real-tool-dump.xml                 toolDumpEvents    4       2        0   ★ REAL CMO OUTPUT
```

Real fixture (fixture-04) details:
- 4 SimEvents resolved via ID-reference pool: ScenFirstLoad, ASEAN_Ship_Destroyed, ASEAN_Aircraft_Destroyed, ASEAN_Scoring
- ASEAN_Scoring: 1 trigger (UnitDestroyed) + 1 condition (LuaScript) + 1 action (LuaScript) — full chain resolved
- 2 SpecialActions extracted as top-level array (NOT mixed into events): "Attempt search and rescue", "End Scenario"
- 9 distinct CMO APIs detected
- All Lua bodies XML-entity-decoded (`&lt;` → `<` etc.)

The original hypothetical fixture-01 still parses via the legacy fallback branch — backward compatible.

---

## Known limitations (also in contract §"Compatibility caveats")

1. **Lua-table parsing is regex-based**, not a full Lua parser.
   - Quoted strings containing unbalanced `{` or `}` will confuse the brace tracker. Mitigation: emit a warning and return what we have.

2. **`scenario.*` fields not present in `Tool_DumpEvents()`.**
   - Real `Tool_DumpEvents()` does NOT include scenario-level metadata (no title / dbVersion / build). Those fields are populated only when present in alternate sources (e.g. user-pasted heading, `scenEditGetEvent` accompanying text).
   - Recommendation: codex's UI fetches scenario metadata via separate calls (`VP_GetScenario()` etc.) instead of relying on parser output.

3. **`objectContext` is a hint list**, not authoritative.
   - Real CMO uses GUIDs throughout (`<TargetSide>BI5B3D-...</TargetSide>` is a side ID, not a name). The parser's name-harvest heuristic catches names from quoted strings inside Lua bodies but cannot resolve raw GUID references.
   - For authoritative side/unit names, codex should fetch via `VP_GetSide()` / `ScenEdit_GetUnit()` separately and join on GUIDs.

4. **`Tool_DumpEvents()` XML format calibrated** against real output (2026-05-02).
   - Pool + ID-reference model verified.
   - SpecialActions extracted as separate top-level array.
   - XML entity decoding (`&lt;` → `<` etc.) applied to `luaScript` fields.

5. **No dependency injection / no I/O outside `--out`.**
   - Parser is pure: stdin → text → JSON. No file globbing, no logging, no telemetry.

---

## Verification status

- ✅ Parser runs without errors on all 3 fixtures
- ✅ Output JSON validates against the contract schema (manually inspected)
- ✅ `events[*].luaScripts` byte-equal to fixture content
- ✅ `detectedApis` correctly extracts `ScenEdit_*` / `VP_*` / `Tool_*` / `World_*` / `Command_*` / `SE_*`
- ✅ `--stdin` path works (`echo ... | node parse-cmo-event-export.mjs --stdin`)
- ✅ Auto-detection works for all 3 input types
- ✅ Force-type override works (`--type` flag)
- ✅ ESM `import { parse }` form works
- ❓ Real-CMO `Tool_DumpEvents()` output unverified (no live access to game)
- ❓ Edge cases (multi-event Lua-table dumps, nested escaped strings) unverified

---

## Suggested next steps for codex

1. **Review** the contract (`backend-event-import-contract.md`) and confirm:
   - JSON shape matches what the UI expects to consume.
   - Field optionality decisions (e.g. `description` is omitted vs explicit `null`).
   - Whether `objectContext` should split GUID vs name.

2. **Provide a real `Tool_DumpEvents()` sample** when convenient. The current XML fixture is plausible but unverified. With one real sample, I can tighten the XML branch.

3. **Decide integration path**:
   - Option A: pull `parse-cmo-event-export.mjs` into `cmo-lua-ui/tools/` and wire into UI's "Lua 분석" tab as an alternative parser.
   - Option B: keep it as a CLI helper that the user runs manually, output piped into the UI's existing JSON-import flow.
   - Option C: leave it standalone in Claude workspace as a Claude-side helper, codex doesn't integrate.

4. **Open Task 2** when ready (scenario folder scanner). Spec already exists at `~/.codex/cmo-lua-ui/docs/backend-scenario-scan-contract.md`.

---

## Workspace boundaries observed

- ✅ All implementation in `~/.claude/cmo-lua-scripts/`
- ✅ All deliverables in `handoff/to-codex/Task-1/` (codex pulls when ready)
- ✅ No edits to `~/.codex/cmo-lua-ui/` (your workspace)
- ✅ No edits to `LuaAssistant.jsx`, `App.jsx`, `index.css`
- ✅ No network calls, no API keys, no `.scen` decoding
- ✅ JSON contract document published alongside code

---

## Revision marker

| Rev | Date | Change |
|---|---|---|
| 1 | 2026-05-02 | Initial draft. Parser + 3 fixtures + contract + smoke tests passing. |
