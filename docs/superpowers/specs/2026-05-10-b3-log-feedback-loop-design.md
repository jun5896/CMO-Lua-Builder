# B3 Log Feedback Loop Design

## Goal

Design Track B3 as a read-only CMO log feedback bridge after the B2 RunScript sidecar writer release.

B3 should help the user bring CMO execution errors back into the local AI interpreter without manual copy/paste from log files, while preserving user review before any AI follow-up is sent.

## Current Baseline

B2 is fully released:

- Current release: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- CMO execution model: user manually runs `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
- `dofile(...)` is unavailable in the CMO Build 1868 console sandbox.
- Scenario-folder `.lua` auto-load remains unproven.
- No automatic CMO execution, polling, log tailing, live read-back, or AI auto-send exists.

B3 builds on that baseline by reading logs only after the user requests or reviews the result.

## Claude Review Refinements

Claude reviewed the B3 design in read-only mode and returned `APPROVED with refinements`.

These refinements are locked into B3.1:

- Large log files must be read with a positioned tail read (`fs.open` + `fd.read`) rather than full-file `readFile()` followed by `slice(-maxBytes)`.
- `since` must have an implemented helper contract in B3.1, not a silent no-op.
- Redaction must cover backslash and forward-slash Windows paths, uppercase and lowercase drive letters, UNC paths, CMO install paths, user profile paths, and secret-like tokens.
- Helper arguments such as `logsRoot` are server-internal only. Browser requests must never supply or override a filesystem root.

## Scope

In scope for B3:

- Read CMO log files from a server-side configured logs root.
- Support `ExceptionLog_*.txt`.
- Support `LuaHistory_*.txt`.
- Return recent sanitized log snippets and file metadata.
- Draft a follow-up instruction from selected log entries.
- Require user action before sending any AI follow-up.
- Add smoke contracts for helper, endpoint, and client/UI behavior.

Out of scope for B3:

- Automatic AI send.
- Automatic CMO execution.
- CMO polling loops that run without user action.
- Live state read-back.
- Modifying log files.
- Modifying `.scen` files.
- Writing into CMO install folders.
- Reading arbitrary browser-supplied filesystem roots.
- Adding generated public/dist artifacts.

## Log Sources

Default CMO root:

```text
C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations
```

Default logs root:

```text
C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Logs
```

Environment override:

```text
CMO_LOGS_ROOT
```

The browser must not provide `logsRoot`. B3 endpoints resolve logs root server-side, just as B2 resolves `cmoLuaRoot` server-side.

Supported file patterns:

```text
ExceptionLog_*.txt
LuaHistory_*.txt
```

The reader should sort matching files by `mtime` descending and inspect only the newest files needed for a bounded response.

## Endpoint Shape

Route:

```text
GET /api/cmo/log-feedback
```

Query parameters:

- `kind`: `all`, `exception`, or `lua-history`; default `all`.
- `since`: optional ISO timestamp. If present, timestamped lines older than the marker are filtered out. Untimestamped lines are retained only from files that are otherwise in the bounded recent scan.
- `limit`: optional integer, clamped to `1..50`, default `20`.
- `maxBytes`: optional integer, clamped to `4096..65536`, default `24000`.

Response:

```json
{
  "ok": true,
  "logsRootConfigured": true,
  "kind": "all",
  "files": [
    {
      "kind": "exception",
      "fileName": "ExceptionLog_2026_05_10.txt",
      "lastWriteTime": "2026-05-10T05:20:00.000Z",
      "sizeBytes": 2048,
      "entries": [
        {
          "lineNumber": 42,
          "text": "Lua execution failed: <REDACTED_PATH>"
        }
      ]
    }
  ],
  "summary": {
    "filesScanned": 2,
    "entriesReturned": 5,
    "redactionsApplied": 3
  },
  "followUpDraft": "Review these CMO log lines. Do not invent missing Side, Mission, Unit GUID, DBID, Loadout ID, RP, Zone, or coordinates..."
}
```

Response rules:

- Do not return absolute local paths.
- Return file names only.
- Redact user profile paths, CMO install paths, drive-root absolute paths, and likely secrets.
- Keep response bounded by `limit` and `maxBytes`.
- Read only the tail window from each candidate file; do not load an entire CMO log file into memory before bounding it.
- Preserve enough line text for diagnosis.
- Do not call the AI adapter from this endpoint.

## Redaction

Redact these surfaces:

- `C:\Users\<name>\...`
- `C:/Users/<name>/...`
- CMO install root fragments.
- Any absolute drive path like `D:\...`
- Any absolute drive path like `d:/...`
- UNC paths like `\\server\share\...`
- `Bearer <token>`
- `Authorization: ...`
- `sk-...`
- Values that look like provider keys

Use stable placeholders:

```text
<REDACTED_USER_PATH>
<REDACTED_CMO_PATH>
<REDACTED_PATH>
<REDACTED_SECRET>
```

## UI Flow

The UI should add a small B3 log feedback section near the B2 sidecar save status, not as an always-running daemon.

User flow:

1. User saves an AI Lua draft through B2.
2. User runs the displayed `ScenEdit_RunScript(...)` snippet in CMO.
3. User clicks a B3 button such as `CMO 로그 확인`.
4. UI fetches sanitized recent log entries.
5. UI displays the snippets and a generated follow-up draft.
6. User can copy or insert the follow-up draft into the chat.
7. User must explicitly send the AI request.

Required wording:

- Logs are read-only.
- CMO paths and secrets are redacted.
- The follow-up is a draft.
- AI is not called automatically.
- User should verify the relevant CMO log lines before sending.

## Safety Rules

B3 must preserve:

- Adapter binds to `127.0.0.1`.
- Browser cannot provide arbitrary log roots.
- No file writes.
- No file deletion.
- No log truncation.
- No background polling by default.
- No automatic AI send.
- No automatic CMO execution.
- No live read-back claim.
- `aiParsedResponse.isPasteReady` remains the Lua save/apply gate.
- Manual prompt-copy fallback remains visible.

## QA Strategy

B3 implementation QA should require:

- `npm run smoke:cmo-log-feedback`
- `npm run smoke:cmo-log-feedback-endpoint`
- `npm run smoke:ai-workflow-state`
- `npm run smoke:ai-follow-up-needs`
- `npm run smoke:ai-confirmed-context`
- `npm run smoke:ai-adapter-client-sidecar`
- `npm run smoke:ai-client-parser`
- `npm run lint`
- `npm run build`
- `npm run smoke:ai-adapter`

Kimi should statically check:

- No write API in the log reader.
- No browser-supplied root.
- No automatic AI send.
- No polling loop.
- No live read-back claim.
- Redaction covers paths and secret patterns.
- Response is bounded.
- UI follow-up remains text-only until user sends.
- Main JS remains under `400 kB`.
- Main CSS remains under `60 kB`.
- `aiContextPruning` remains under `9 kB`.

## Agent Roles

- Codex owns B3 implementation and release flow.
- Claude should review B3 log-root, redaction, and no-auto-send assumptions before implementation.
- Gemini should review Korean UX wording when B3 UI copy is ready.
- Kimi should perform planning QA first, then focused implementation QA per slice.

## Open Decisions Locked For B3.1

These choices are fixed for the first implementation slice:

- Start with a pure helper and smoke contract.
- Read only `ExceptionLog_*.txt` and `LuaHistory_*.txt`.
- Use server-side `CMO_LOGS_ROOT` or default CMO logs root.
- Return sanitized snippets and a text follow-up draft.
- Do not wire UI or endpoint until the helper smoke passes.
- Do not add polling, watchers, or background tasks.
