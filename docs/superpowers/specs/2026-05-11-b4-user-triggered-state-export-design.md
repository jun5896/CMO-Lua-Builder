# B4 User-Triggered State Export Design

## Status

OPEN FOR REVIEW / QA

## Purpose

B4 is the next Track B step after the B3 Log Feedback Loop release.

B2 lets the app save paste-ready Lua drafts into the CMO Lua root, and B3 lets the app read recent CMO log feedback after the user manually runs that Lua. B4 should add the first read-back layer without pretending that CMO offers silent live synchronization.

The B4 target is a user-triggered state snapshot: the user explicitly exports or copies CMO event/state text, the app imports and sanitizes it, and AI drafting can refer to that imported snapshot only when the timestamp and source are clear.

## Design Position

B4 is not a real-time daemon. It is a bounded, user-reviewed snapshot import path.

This direction follows the roadmap decision that CMO sandbox constraints are design facts. The app should help the user bring state back from CMO, but it should not poll CMO, watch files, auto-run Lua, or auto-send AI requests.

## Inputs

The first implementation should support manual text input only:

- `Tool_DumpEvents()` XML-shaped output.
- `ScenEdit_GetEvent(...)` Lua table-style output.
- Mixed CMO Lua Console text that the existing event parser can classify.

The app may later generate or save helper snippets through the B2 RunScript Sidecar Writer, but B4.1 should not depend on that. First prove that imported text can become a safe UI snapshot.

## Existing Assets

B4 should reuse these existing assets:

- `tools/parse-cmo-event-export.mjs`
- `docs/contracts/backend-event-import-contract.md`
- `docs/contracts/claude-task-1-event-parser-review.md`
- `fixtures/event-export-samples/`
- Track A3 confirmed context helpers
- B3 redaction and text-only follow-up patterns

The existing parser already exports `parse(text, opts = {})`. The design should wrap it rather than rewrite event parsing from scratch.

## Snapshot Data Model

The helper should produce a sanitized object shaped like this:

```jsonc
{
  "snapshotId": "cmo-state-2026-05-11T12-00-00-000Z",
  "importedAt": "2026-05-11T12:00:00.000Z",
  "source": {
    "type": "toolDumpEvents | scenEditGetEvent | pastedLuaConsole | mixed | unknown",
    "label": "User pasted CMO export",
    "live": false
  },
  "summary": {
    "eventCount": 2,
    "specialActionCount": 1,
    "detectedApiCount": 5,
    "warningCount": 0
  },
  "events": [],
  "specialActions": [],
  "objectContext": {
    "sides": [],
    "missions": [],
    "units": [],
    "referencePoints": [],
    "zones": [],
    "specialActions": [],
    "luaFiles": []
  },
  "detectedApis": [],
  "warnings": [],
  "redaction": {
    "applied": true,
    "count": 0
  }
}
```

`source.live` must always be `false` for B4. The UI may call the result "latest imported snapshot", but not "live state".

## Raw / Lua Body Policy

The parser can extract raw blocks and Lua script bodies. B4 should not expose full raw blocks by default.

The server helper should:

- Strip parser `raw` fields from the response.
- Replace long Lua script bodies with bounded previews.
- Preserve enough metadata for the user to identify the relevant event or special action.
- Redact local paths, API-key-like strings, and bearer-token-like strings before returning any text.

This keeps B4 useful for understanding CMO event state without accidentally turning the import endpoint into a script exfiltration or replay channel.

## UI Behavior

The first UI slice should be explicit and text-only:

- User opens a "CMO 상태 스냅샷 가져오기" area.
- User pastes copied CMO export text.
- User clicks an import button.
- UI shows imported timestamp, source type, counts, warnings, events, special actions, detected APIs, and object-context hints.
- UI can draft a follow-up prompt that references the snapshot.
- UI can promote selected names or IDs into the existing Confirmed Context workspace.

The UI must not:

- Call AI automatically.
- Execute CMO Lua automatically.
- Poll logs or files.
- Claim that imported data is live.
- Treat parser object-context hints as authoritative.

## Backend Behavior

B4 should add a bounded import helper first, then an adapter endpoint.

Expected endpoint for B4.2:

```text
POST /api/cmo/state-snapshot/import
```

Expected body:

```json
{
  "text": "<pasted CMO export text>",
  "sourceHint": "toolDumpEvents"
}
```

Rejected body fields:

- `cmoRoot`
- `logsRoot`
- `scenarioRoot`
- `scriptPath`
- `filePath`

The browser must not provide filesystem roots for B4.

## Bounds

The helper and endpoint should enforce:

- Maximum input text size: `256 KiB` for the first slice.
- Maximum event list returned to UI: `50`.
- Maximum special action list returned to UI: `50`.
- Maximum text preview per Lua body: `600` characters.
- Maximum warnings returned: `20`.

The endpoint should reject oversize imports with a user-readable error instead of truncating before parse. Silent truncation would make state interpretation misleading.

## Safety Invariants

B4 must preserve:

- No automatic AI send.
- No automatic CMO execution.
- No polling loop.
- No filesystem watcher.
- No browser-provided CMO root, logs root, scenario root, or Lua root.
- No CMO file writes or deletes.
- No `.scen` mutation.
- No live read-back claim.
- No raw credential persistence.
- Manual prompt-copy and request-copy fallbacks.
- `isPasteReady === true` remains the only apply/save gate for Lua drafts.

## Planned Slices

### B4.1 Snapshot Import Helper

Create a server-side pure helper around `parse-cmo-event-export.mjs`.

Expected files:

- `server/cmo-state-snapshot-importer.mjs`
- `tools/verify-cmo-state-snapshot-contract.mjs`
- `package.json`

Expected smoke:

```powershell
npm run smoke:cmo-state-snapshot
```

### B4.2 Adapter Endpoint

Add a POST endpoint that calls the B4.1 helper.

Expected files:

- `server/ai-provider-adapter.mjs`
- `tools/verify-cmo-state-snapshot-endpoint.mjs`
- `package.json`

Expected smoke:

```powershell
npm run smoke:cmo-state-snapshot-endpoint
```

### B4.3 UI Import Panel

Add a user-triggered import panel in the existing AI assistant flow.

Expected files:

- `src/lib/aiAdapterClient.js`
- `src/components/LuaAssistant.jsx`
- `tools/verify-ai-adapter-client-state-snapshot-contract.mjs`
- `package.json`

Expected smoke:

```powershell
npm run smoke:ai-adapter-client-state-snapshot
```

### B4.4 Closeout / Release

Document and release only after B4.1 to B4.3 pass Kimi QA.

## Agent Roles

- Codex owns implementation.
- Claude should review the B4 design before B4.1 begins, focusing on parser assumptions, raw/Lua body handling, and avoiding live read-back claims.
- Gemini remains standby until B4.3 UI wording exists.
- Kimi should QA the planning gate and every implementation slice.

## Success Criteria

B4 is successful when:

- The user can paste a CMO event/state export into the UI.
- The UI shows a sanitized, timestamped snapshot with events and special actions.
- The UI can draft a follow-up prompt from that snapshot without sending it automatically.
- Confirmed Context can receive user-selected snapshot facts.
- All verification smokes pass.
- Watch lines remain inside limits.

## Explicit Non-Claims

B4 does not prove:

- Full live scenario read-back.
- Live unit positions.
- Silent CMO daemon behavior.
- Automatic event export from CMO.
- Automatic AI correction after import.

Those require later gates after the snapshot import path is proven.
