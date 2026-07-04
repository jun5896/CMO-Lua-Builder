# AI Interpreter Chat Contract — Task 3B Workstream B

**From:** Claude (`~/.claude/cmo-lua-scripts/`)
**Trigger:** Codex signal `2026-05-03-task-3b-ai-interpreter-bridge-prep.md` Workstream B
**Purpose:** Define how the UI builds prompts for `POST /api/ai/chat` and how the AI must shape its response so Codex can mechanically parse it into Lua draft / checklist / assumptions / follow-up questions.
**Status:** proposal — Codex picks final shape; this file lives in Claude workspace until pulled.

---

## 1. Overall request shape

The UI sends to `POST /api/ai/chat`:

```jsonc
{
  "messages": [
    { "role": "system", "content": "<ASSEMBLED_SYSTEM_PROMPT>" },
    { "role": "user",   "content": "<ASSEMBLED_USER_PROMPT>" }
  ],
  "temperature": 0.3,         // default for interpreter mode (lower = more literal)
  "maxTokens":   2048,        // upper cap; UI may raise for big Lua bodies
  "providerOverride": null    // omit unless user is testing a non-default provider
}
```

**Why role split:**
- `system` carries fixed CMO interpreter rules + response-format mandate (rarely changes per request).
- `user` carries the request-specific context (scenario summary, Lua bundle, user question).

This split lets providers cache the system prompt across turns when they support prompt-caching.

---

## 2. System prompt sections (UI assembles in this order)

Each section is a labeled block delimited by `===`. Treat any field that is unknown as `null` — never invent values. The ordering matters because LLMs anchor on early text.

```
=== ROLE ===
You are an interpreter assistant for the player of Command: Modern Operations
(CMO) Lua scripting. Your job is to help the user write Lua that runs inside
CMO's Event Editor / Lua Console / Special Action / Mission Trigger.

=== HARD RULES ===
1. NEVER invent DBID, GUID, Loadout ID, or unit-name strings. If a value is
   missing, ASK the user to copy it from CMO Database Viewer or "Copy unit ID
   to clipboard". Treat missing IDs as a blocker, not a guess opportunity.
2. NEVER reference Lua APIs that are not in the CMO Lua surface
   (ScenEdit_*, Get*, Set*, Tool_*, math/string/table stdlib).
3. NEVER assume the user can edit external map files. CMO scripts run inside
   CMO; map state is read/modified through ScenEdit_* APIs.
4. NEVER recommend file system access, HTTP calls, os.execute, or anything
   that requires CMO's Lua sandbox to be unlocked.
5. ALWAYS produce paste-ready Lua with no <PLACEHOLDER> tokens. If a value is
   missing, surface a follow-up question instead of placeholder Lua.
6. ALWAYS specify WHERE in CMO UI the Lua should be attached (Event Editor →
   Action → Lua Script; Lua Console; Mission → Trigger; Special Action; etc.).

=== RESPONSE FORMAT (REQUIRED, EXACT HEADER NAMES) ===
You MUST respond using these markdown sections in this order. Sections may be
empty but must be present. Do not add other top-level headings.

## Summary
One-paragraph plain-language description of what the script will do.

## Assumptions
- Bullet list of facts you assumed from context.
- Each bullet is one assumption; if the user disagrees, the script may break.

## CMO UI prerequisites
- Where to attach the Lua (Event Editor / Lua Console / Mission Trigger /
  Special Action / etc.)
- Any required preconditions (mission must exist, side must own unit, etc.)

## Paste-ready Lua
```lua
-- A complete, compileable Lua block. No <PLACEHOLDERS>. No truncation.
```

## Validation checklist
- [ ] Step the user runs in CMO to verify the script ran.
- [ ] Specific output / state change to look for.
- [ ] Where to read errors (Message Log / Lua Console output).

## Follow-up questions or blockers
- Question 1 — only if information is missing. Each item is one specific ask.
- "BLOCKER: <reason>" if the request cannot be fulfilled until the user
  provides X.

If you cannot produce a paste-ready Lua because of missing data, leave the
"Paste-ready Lua" block empty (just a fenced empty lua block) and put the
unblock conditions in "Follow-up questions or blockers".
```

---

## 3. User prompt sections (UI assembles in this order)

Each block is labeled. Sections are optional but must appear in this order when present:

```
=== USER REQUEST ===
<verbatim user-typed prompt>

=== SCENARIO CONTEXT (from Task 2 summarizer JSON) ===
Title:       <scenario.title or "(unknown)">
Setting:     <scenario.setting or "(unknown)">
Build:       <scenario.gameVersion>
DB version:  <scenario.dbVersion>
Player side: <scenario.currentSide>
Sides:       <comma-joined sides[*].name>     (cap at 12; trail with "...")
Missions:    <count> total — by kind: <Patrol=N, Strike=N, ...>
Units:       <unitCounts.total> total — Aircraft=N, Facility=N, Ship=N, ...
Zones:       <count> NoNav + <count> Exclusion
Reference points: <count> (truncated to <N> for context)

=== ACTIVE OBJECT CONTEXT (from objectContext, capped) ===
Sides:           <objectContext.sides joined>
Missions:        <objectContext.missions joined, cap 30>
Reference points:<objectContext.referencePoints joined, cap 30>
Zones:           <objectContext.zones joined, cap 20>
Special actions: <objectContext.specialActions joined, cap 30>
Lua files:       <objectContext.luaFiles joined>

=== LOADED LUA BUNDLE (if user has a draft open in the editor) ===
File: <filename>
```lua
<entire current contents — no truncation unless > 50 KB>
```

=== TEMPLATE INSPECTOR NOTES (if a template is selected) ===
Template: <template.name>
Category: <template.category>
Notes:
<plain-text notes from Template Library guide>

=== ENGINE FEEDBACK (if user already ran a previous attempt) ===
Last attempt status: <success | error | "not yet run">
Lua Console / Message Log output:
<verbatim text the user pasted back, max 8 KB>

=== USER QUESTION (echoed for emphasis) ===
<same as USER REQUEST, last so the model anchors on it for the response>
```

**Section selection rules:**
- If a section has no data, OMIT it entirely (don't send empty headers).
- The `USER REQUEST` and `USER QUESTION` are the same text duplicated at top and bottom — empirically helps the model stay on-task in long contexts.
- Cap each list at the documented count to keep prompts under ~16K tokens for typical scenarios.

---

## 4. Including the `.scen` sidecar summary

The UI already has Task 2's summarizer output (the JSON Codex pulled from `tools/summarize-cmo-scenario-xml.mjs`). Don't include the entire JSON — that's wasteful. Instead extract:

```js
// Pseudocode for UI assembling SCENARIO CONTEXT block
const s = summary;
const ctx = [
  `Title:       ${s.scenario.title ?? '(unknown)'}`,
  `Setting:     ${s.scenario.setting ?? '(unknown)'}`,
  `Build:       ${s.scenario.gameVersion ?? '(unknown)'}`,
  `DB version:  ${s.scenario.dbVersion ?? '(unknown)'}`,
  `Player side: ${s.scenario.currentSide ?? '(unknown)'}`,
  `Sides:       ${s.sides.map(x => x.name).slice(0,12).join(', ')}` +
                  (s.sides.length > 12 ? ` ... (${s.sides.length} total)` : ''),
  `Missions:    ${s.missions.length} total — ` +
                  countBy(s.missions, 'kind').join(', '),
  `Units:       ${s.unitCounts.total} total — ` +
                  Object.entries(s.unitCounts).filter(([k]) => k !== 'total')
                    .map(([k,v]) => `${k}=${v}`).join(', '),
  `Zones:       ${s.zones.filter(z=>z.kind==='NoNavZone').length} NoNav + ` +
                 `${s.zones.filter(z=>z.kind==='ExclusionZone').length} Exclusion`,
  `Reference points: ${s.referencePoints.length}`,
].join('\n');
```

**Sidecar (`.ini`, `.html`) inclusion rules:**
- If `summary.source.fileName` indicates a sidecar `.ini` was scanned (codex's `scan-cmo-scenario-folder.mjs` populates this), and the user's request mentions the unit names found in it, include those names in the `ACTIVE OBJECT CONTEXT > Units` line.
- Don't dump the raw `.ini` body into the prompt — token-expensive and the unit names already covered.

---

## 5. Including a loaded Lua bundle

When the user has Lua open in the editor:

- Include verbatim under `=== LOADED LUA BUNDLE ===`.
- If > 50 KB: emit a 2-line summary `<filename — N lines, M bytes>` plus the first ~100 lines and last ~30 lines, with a `[…N lines elided…]` marker. Real CMO scripts rarely hit 50 KB; this is a safety cap.
- Include the file's INTENT comment block (any leading `--` comments) verbatim — it's the AI's clearest signal of what the user already documented.

If the user has multiple files open (e.g. event-action Lua + a separate utility module), concatenate them with `=== LOADED LUA BUNDLE: <filename> ===` headers per file.

---

## 6. Including Template Inspector guide notes

When a template is selected from the Template Library:

```
=== TEMPLATE INSPECTOR NOTES ===
Template: Strike Mission Trigger
Category: Mission > Strike
Notes:
- Attached to: Mission → Trigger → Lua Script
- Required context: side ID, mission name
- Common pitfalls: <from template's documented notes field>
```

These notes already live in the Template Library's metadata — the UI just slots them in. The AI uses them as authoritative "this is how this template is normally used" hints.

---

## 7. Engine feedback loop

After the user tests Lua in CMO and pastes back the Lua Console / Message Log output:

- Include verbatim under `=== ENGINE FEEDBACK ===`.
- Cap at 8 KB; if longer, prefer the last 8 KB (errors typically come at the end).
- The AI is expected to:
  - Read the error
  - Refer to its previous `Paste-ready Lua` block
  - Produce a corrected version following the same response format
  - Reference the specific line/pattern in the error in the `Assumptions` block

This is the "interpreter loop" — UI → AI → user runs in CMO → user pastes back → AI iterates.

---

## 8. Response parsing on the UI side (Codex implements)

```js
// Pseudo-parser for the markdown response
function parseInterpreterResponse(text) {
  const sections = {};
  const sectionHeaders = ['Summary','Assumptions','CMO UI prerequisites',
                          'Paste-ready Lua','Validation checklist',
                          'Follow-up questions or blockers'];
  // split on lines matching /^## (one of the sectionHeaders)$/
  // for each section, capture lines until the next heading or end
  // For "Paste-ready Lua", extract the inner ```lua ... ``` block
  return {
    summary:        sections['Summary']                   ?? '',
    assumptions:    parseBullets(sections['Assumptions']) ?? [],
    prerequisites:  parseBullets(sections['CMO UI prerequisites']) ?? [],
    lua:            extractLuaBlock(sections['Paste-ready Lua']) ?? '',
    validation:     parseChecklist(sections['Validation checklist']) ?? [],
    followups:      parseBullets(sections['Follow-up questions or blockers']) ?? [],
    isBlocker:      /BLOCKER:/.test(sections['Follow-up questions or blockers'] ?? ''),
  };
}
```

The UI then renders these as separate panels:
- **Summary** → top of the AI panel
- **Lua** → an "Apply / Copy / Test in CMO" code block with syntax highlighting
- **Assumptions** → collapsible badge ("AI assumed N things — review")
- **Prerequisites** → checklist with "Mark done" toggles
- **Validation** → post-paste checklist
- **Follow-ups** → if non-empty, render as the primary CTA ("Answer these to unblock")

---

## 9. Why this contract is robust

1. **Section names are exact and stable** — Codex's parser keys on literal `## Summary` etc. If the AI deviates (e.g. `## summary`, `### Summary`), parsing fails loudly rather than silently mis-categorizing.
2. **Empty-section is a valid state** — when the AI is blocked, the Lua block can be empty `lua\n\n` and that's fine. The UI shows "AI is waiting for X" instead of an empty Lua panel.
3. **No invented values** — the HARD RULES forbid IDs the AI doesn't have. If a Strike mission template says "use the player side's first carrier group", the AI must ASK the user which carrier group; it can't invent `Z8XE7U-...`.
4. **Engine feedback is first-class** — the `ENGINE FEEDBACK` section makes the iterate loop explicit. The AI is encouraged to revise rather than restart.
5. **Manual fallback preserved** — even if the adapter is down, the UI can still copy `<USER REQUEST>` + `<SCENARIO CONTEXT>` + `<LOADED LUA BUNDLE>` to clipboard and the user pastes into Chatbox / their own AI.

---

## 10. Sample request body (full example, ready to feed `/api/ai/chat`)

```jsonc
{
  "messages": [
    {
      "role": "system",
      "content": "=== ROLE ===\nYou are an interpreter assistant for the player of Command: Modern Operations (CMO) Lua scripting...\n=== HARD RULES ===\n1. NEVER invent DBID...\n=== RESPONSE FORMAT (REQUIRED) ===\nYou MUST respond using these markdown sections..."
    },
    {
      "role": "user",
      "content": "=== USER REQUEST ===\nMake a Strike mission for the F-15s vs the Iranian radar at RP-04.\n\n=== SCENARIO CONTEXT ===\nTitle:       Iran Strike, 2020-2030\nSetting:     (unknown)\nBuild:       Command: Modern Operations Build 1852\nDB version:  4331ad536d5e41fd0c3dfae5752d100c8c43ceac\nPlayer side: Israel\nSides:       Israel, Iran, Task Force 50, United States-Israel, ...\nMissions:    19 total — Patrol=14, Strike=2, SupportMission=3\nUnits:       1189 total — Aircraft=568, Facility=606, Ship=5, Submarine=2, Group=8\nZones:       10 NoNav + 1 Exclusion\nReference points: 524\n\n=== ACTIVE OBJECT CONTEXT ===\nSides:           Israel, Iran, ...\nMissions:        Iran-Israel Border Patrol, ...\nReference points:RP-04, RP-93, Iran ADIZ, ...\nZones:           Egypt NFZ, Jordan NFZ, ...\nSpecial actions: Ready All Aircraft, Cyber Operations Center, ...\n\n=== LOADED LUA BUNDLE ===\n(none — user is starting fresh)\n\n=== TEMPLATE INSPECTOR NOTES ===\nTemplate: Strike Mission Trigger\nCategory: Mission > Strike\nNotes:\n- Attached to: Mission → Trigger → Lua Script\n- Required context: side ID, mission name\n- Common pitfalls: ScenEdit_AssignUnitToMission silently fails if mission name is misspelled\n\n=== USER QUESTION ===\nMake a Strike mission for the F-15s vs the Iranian radar at RP-04."
    }
  ],
  "temperature": 0.3,
  "maxTokens":   2048
}
```

The AI's response (after the adapter forwards the upstream JSON) is parsed by §8 above.

---

## Boundaries observed

- ❌ No edits to `~/.codex/`, `src/`, `package.json`, `.gitignore`
- ❌ No disk persistence
- ❌ No browser automation
- ❌ No Chatbox config import
- ✅ Contract-only artifact in Claude workspace
- ✅ Codex pulls when ready
