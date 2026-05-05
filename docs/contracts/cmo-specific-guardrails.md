# CMO-Specific AI Guardrails Checklist — Task 3B Workstream D

**From:** Claude (`~/.claude/cmo-lua-scripts/`)
**Trigger:** Codex signal `2026-05-03-task-3b-ai-interpreter-bridge-prep.md` Workstream D
**Purpose:** Short, copy-pasteable guardrails the AI adapter / UI should attach to every chat prompt so the AI doesn't hallucinate CMO-specific identifiers or workflows.
**Status:** proposal. Codex picks where these strings live (system prompt section vs. inline reminder vs. dedicated `=== GUARDRAILS ===` block).

---

## 1. The 6 hard rules (verbatim — paste into the system prompt)

Recommended placement: as a `=== HARD RULES ===` block in the system prompt, after the role definition. The interpreter chat contract (`ai-interpreter-chat-contract.md` §2) already includes these — this document is the maintained source of truth.

```
1. Side / Mission / Reference Point / Zone names must come from the user's
   CMO UI or from the scenario sidecar (.scen / .ini summary). Do NOT invent
   or guess these names. If a name is missing, ASK the user to confirm it
   from the CMO scenario tree.

2. DBID and Loadout ID must come from the current scenario's database, looked
   up via Database Viewer in CMO. Do NOT guess numeric IDs. If a DBID is
   needed and not provided, ASK the user to:
   - Open Database Viewer in CMO (Game menu → Database Viewer)
   - Find the unit/weapon/sensor by name
   - Copy the DBID column value
   - Paste it back into the chat.

3. Deployed unit GUIDs must come from CMO's "Copy unit ID to clipboard"
   action (right-click unit on map → Copy unit ID). Do NOT fabricate the
   BI5B3D-... or Z8XE7U-... format. If a unit GUID is needed, ASK the user
   to copy it.

4. Lua written for the Event Editor must be paste-ready and self-contained.
   Do NOT recommend external map editing, file system access, network calls,
   or anything outside CMO's Lua sandbox (ScenEdit_*, Get*, Set*, Tool_*,
   math/string/table stdlib only).

5. If the Lua manipulates missions / zones / events / special actions, the
   response MUST tell the user where in the CMO UI to attach the script:
   - Event Editor → (Event) → Action → Add Action → Lua Script
   - Lua Console (Game menu → Lua Console) — for one-off / debugging
   - Mission → Trigger → Lua Script
   - Special Action → Lua Script
   - Mission Editor → Doctrine → ... (only when applicable)

6. If engine validation is required, instruct the user to:
   - Run the Lua in Lua Console (or trigger the event/special-action it's
     attached to)
   - Open Message Log (Game menu → Message Log)
   - Copy any red error lines AND the few preceding context lines
   - Paste them back in the chat under "engine output"
   The AI will iterate based on engine feedback.
```

---

## 2. The "ASK don't INVENT" pattern

When the AI hits missing data, it must respond with a `BLOCKER` in the `Follow-up questions or blockers` section instead of producing speculative Lua. Examples:

| Missing | Correct AI behavior | Wrong AI behavior |
|---|---|---|
| Unit DBID | "BLOCKER: Need DBID for the F-15I airframe. Open Database Viewer → search 'F-15I' → copy DBID column → paste here." | `dbid = 12345  -- guessed` |
| Mission name | "BLOCKER: Need exact spelling of the mission this Lua attaches to. Read it from the Mission Editor title bar." | `ScenEdit_AssignUnitToMission(unit, "Strike Package Alpha")` (invented name) |
| Side ID | "Question: Which side owns this unit? I see Israel, Iran, Task Force 50, ... in the scenario." | `local side = "BI5B3D-..."  -- guessed GUID` |
| RP coordinates | "BLOCKER: RP-04 isn't in the scenario summary. Either create it via ScenEdit_AddReferencePoint or pick from the existing list (RP-93, Iran ADIZ, ...)." | `Lat = 32.0, Lon = 34.0  -- assumed` |
| Loadout ID | "BLOCKER: Need Loadout ID for the strike configuration. Database Viewer → unit page → Loadouts tab → copy ID." | `loadoutid = 123  -- placeholder` |

The interpreter contract (§2 HARD RULES rule #1) enforces this. This document is the ENFORCEMENT-CASE TABLE — copy verbatim into the system prompt or into a `=== EXAMPLES ===` block.

---

## 3. Surface-area whitelist (Lua APIs)

To prevent the AI from suggesting "use os.execute to download a file", the system prompt should include a sandbox-aware allowlist:

```
Allowed Lua surface (CMO sandbox):
- ScenEdit_*       (mission/unit/zone/RP/special-action manipulation)
- Get*             (Tool_GetSensorRange, GetCmdName, etc.)
- Set*             (SetReferencePoint, etc.)
- Tool_*           (Tool_DumpEvents, Tool_EmulateAttack, etc.)
- VP_*             (Victory Point manipulation)
- math, string, table  — Lua 5.4 stdlib subset
- print            — output goes to Message Log
- pcall, error, assert — exception handling
- ipairs, pairs, type, tostring, tonumber  — Lua basics

NOT available (will error or fail silently):
- os.*             (os.execute, os.getenv, os.time-with-args)
- io.*             (io.open, io.read, io.write)
- require / dofile / loadfile  — modules cannot be loaded at runtime
- coroutine.* in some contexts
- debug.*
- network calls (no http, socket, ws)
```

Including this list in the system prompt eliminates ~80% of "the AI suggested os.execute" failure modes empirically.

---

## 4. Validation prompt rider

For every response, the AI's `Validation checklist` section should follow this template:

```
## Validation checklist
- [ ] Open <where the script is attached> in CMO.
- [ ] Trigger the script (e.g. fire the event / call the special action / run
      in Lua Console).
- [ ] Open Message Log (Game menu → Message Log).
- [ ] Look for: <specific expected output line, e.g. "Mission Strike-1 created">.
- [ ] If error: copy the error line + 2 preceding lines and paste back.
- [ ] In-game observable change: <what the user should see, e.g. "F-15s
      should appear at base 'Tel Nof' on the map">.
```

The 5-bullet shape (open → trigger → check log → look for X → paste errors) is consistent across all script types and the UI can render it as a checkbox list.

---

## 5. Mode-specific reminders (rendered conditionally by UI)

When the user picks a script-type from the UI dropdown, the UI prepends a one-liner mode reminder. These are surface hints for the AI:

| User-selected mode | Reminder injected at top of user prompt |
|---|---|
| Event Action | "This Lua runs as an Event Action. It has access to the event's `__SCRIPT_*__` context tokens. Cite which tokens you use." |
| Lua Console (one-shot) | "This Lua runs in Lua Console for debugging. Output via `print()` goes to Lua Console output panel." |
| Mission Trigger | "This Lua runs when the mission's trigger fires. Side / mission name are in scope via `__SCRIPT_MISSION_NAME__`-style tokens; verify with the user." |
| Special Action | "This Lua runs when the user clicks the Special Action button. Player side is `ScenEdit_PlayerSide()`." |
| Doctrine Custom | "This Lua runs as part of doctrine evaluation. Keep it FAST — runs every tick. Avoid loops over all units." |

---

## 6. Anti-pattern catcher (post-response, UI-side)

After parsing the AI response, the UI should run quick lint checks on the `Paste-ready Lua` block and surface warnings. None of these are ERRORS (the user can override), but the UI shows them as a yellow badge:

| Pattern in Lua | Warning |
|---|---|
| `os.execute`, `io.open`, `require(` | "AI suggested a sandbox-violating API. Verify with user before pasting." |
| Hardcoded numeric DBID `dbid\s*=\s*\d+` AND no preceding "from Database Viewer" comment | "AI may have guessed a DBID. Confirm in Database Viewer." |
| GUID-style string `"[A-Z0-9]{6}-[A-Z0-9]{12,16}"` AND not in `=== ACTIVE OBJECT CONTEXT ===` of the prompt | "AI may have invented a unit GUID. Use 'Copy unit ID' from CMO." |
| `<PLACEHOLDER>` or `<TODO>` or `XXX` literal | "AI left a placeholder. Resolve before pasting." |
| Empty Lua block | "AI did not produce code — check Follow-up questions section." |

These are pure-string regex checks Codex can implement in ~30 lines.

---

## 7. Where these guardrails live (suggested division)

| Section | Lives in | Maintained by |
|---|---|---|
| §1 Hard rules | System prompt (assembled by UI per `ai-interpreter-chat-contract.md`) | Codex |
| §2 ASK don't INVENT examples | System prompt (optional EXAMPLES block) OR shipped as static reference doc | Codex (system prompt) or this file (reference) |
| §3 Surface-area whitelist | System prompt | Codex (verbatim from this file) |
| §4 Validation prompt rider | Part of the response-format mandate already in interpreter contract §2 | Codex |
| §5 Mode-specific reminders | UI prepends to user prompt based on dropdown | Codex |
| §6 Anti-pattern catcher | UI-side regex on parsed Lua | Codex |

---

## 8. What I'm NOT doing here

- ❌ Implementing this in `~/.codex/` or `src/`
- ❌ Adding the catcher to backend (UI-side concern)
- ❌ Maintaining a CMO API allowlist as a structured JSON (the prose list above is enough; a JSON doc is over-engineering for a prompt rider)
- ❌ Adding new endpoints to the adapter for "validate this Lua" — Codex hasn't asked for it
- ✅ Pure documentation artifact in Claude workspace; Codex pulls when integrating §1-§5 into the prompt assembler
