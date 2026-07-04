# Claude Backend Handoff

## Mission

Support the CMO Lua UI as a backend/helper worker while Codex remains the primary UI and integration owner.

## Current Operating Mode

Claude Code is currently a read-only monitor/helper until Codex completes review and assigns a backend task.

Allowed now:

- keep the hourly sync/watch process active
- run `codex_watch` or the local digest helper when asked by the user or when a new Codex change is suspected
- summarize Codex changes and point to changed files
- prepare implementation notes without editing source files

Hold until Codex approval:

- backend parser implementation
- Node/API relay implementation
- direct edits to shared files
- frontend changes

## Codex Decision: Next Claude Step

Status: Task 1 is approved, but only as an isolated backend handoff. Claude should not write directly into the Codex workspace.

Sync scope decision:

- Add `C:\Users\dlwls\.codex\cmo-lua-ui\docs\` to Claude's read-only sync sources.
- Also mirror the small root coordination files `AGENTS.md` and `CLAUDE.md` if the sync tool supports file-level sources.
- Do not mirror the full `cmo-lua-ui` directory yet.
- Optional later: mirror selected `tools\*.mjs` files if Claude needs exact parser/scanner contracts.

Task 1 decision:

- Start the CMO Event export parser design/implementation as Claude's first backend helper task.
- Keep output in Claude's own workspace or handoff mailbox first.
- Codex will review and integrate the accepted implementation into `tools/` afterward.
- Do not edit React UI files.
- Do not introduce API/network calls.

Language decision:

- Use `.mjs` as the canonical implementation language.
- Reason: this project already uses Node/Vite and existing backend helpers are `.mjs` under `tools/`.
- Python may be used only for Claude-local exploration/digest helpers, not as the primary parser deliverable unless Codex asks for it later.

Context window decision:

- Claude 200k standard-output mode is enough for Task 1.
- Ask the user to switch Claude Opus to 1M only for large corpus synthesis, such as full preset encyclopedia consolidation, all installed Lua examples, or broad scenario/source cross-comparison.

## Recommended First Backend Task

Build an import path for CMO engine-exported event data instead of trying to directly decode compressed `.scen` payloads.

Target inputs:

- `Tool_DumpEvents()` XML output
- copied Lua Console text output from `ScenEdit_GetEvent(...)` or event dump helpers
- optional sidecar `.ini` files from workshop scenario folders

Expected output:

```json
{
  "scenario": {
    "title": "string",
    "dbVersion": "string",
    "build": "string"
  },
  "events": [
    {
      "name": "string",
      "isActive": true,
      "isRepeatable": false,
      "triggers": [],
      "conditions": [],
      "actions": [],
      "luaScripts": []
    }
  ],
  "objectContext": {
    "sides": [],
    "missions": [],
    "units": [],
    "referencePoints": [],
    "zones": []
  },
  "warnings": []
}
```

## Safe Write Scope

Prefer creating or editing:

- `tools/parse-cmo-event-export.mjs`
- `tools/scan-cmo-scenario-folder.mjs`
- `docs/backend-event-import-contract.md`
- `src/lib/cmoEventExportParser.js` only if it is UI-agnostic

Avoid unless explicitly assigned:

- `src/components/LuaAssistant.jsx`
- `src/App.jsx`
- `src/index.css`

## Handoff Back To Codex

End with:

- Files changed
- How to run the parser/scanner
- Example command and output
- JSON contract changes
- Verification status
