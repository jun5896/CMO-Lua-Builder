# Native desktop workbench

The Windows WPF application provides three workspaces: scenario authoring, Lua
assistance, and side-specific play advice. It uses native controls; no browser,
WebView, local HTTP server, or React server is needed. The existing browser UI
and bridge remain separate tools.

## Run and build

Requirements: Windows, Node.js 24, .NET 8 SDK for building, and a configured OMP
installation exposing `auth-gateway stdio` (developed against 18.9.0). Provider
login, API keys, subscription accounts, account rotation, and fallback settings
remain in OMP. This application does not register providers or copy their keys.

```powershell
npm run desktop           # Build and open the native window
npm run desktop:build     # Build without opening a window
```

The runnable output is `desktop-dist/CmoWorkbench.exe`. Keep its accompanying
files and `runtime` directory together. This is a framework-dependent build:
another Windows PC needs Node.js 24 and the .NET 8 Desktop Runtime. Set
`CMO_DESKTOP_NODE` to an absolute Node executable path if it is not on PATH.
The desktop output is separate from Vite's `dist` so a web build cannot erase it.

Choose **모델 불러오기** to read the authenticated OMP model catalog, select a
model for each workspace, and send a prompt. Catalog retrieval does not send a
generation request. Only chat models are offered for drafting; judge-only Jev
models use a different API and are not implemented in this first milestone.
Catalog presence does not prove that a provider's credentials or quota work.

OMP's stdio gateway buffers responses, so this version displays completed
responses rather than token streaming. Each request owns a separate child
gateway process. Up to two sessions may request concurrently, and cancellation
terminates only the selected request. Already incurred provider charges may
remain. The app sends no retry; OMP's own configured fallback policy may apply.
The returned model and reported token usage are recorded in the conversation.

## Workflow and persistence

- **Scenario authoring:** record objectives, sides, missions, events, scoring,
  and confirmed identifiers; ask for a design or Lua draft.
- **Lua assistance:** open or edit Lua, ask for an explanation or revision,
  inspect generated Lua, and export a reviewed draft to a chosen file.
- **Play advice:** import a dated observation for one side and ask for options
  and explanations. There is no game execution, polling, live-state acquisition,
  automatic order queue, or RTMP bot connection in this app.

The app saves each workspace's model, materials, draft, request limits, and
conversation when saving, switching workspaces, sending, or closing. Unsent
prompt-box text is retained between workspaces in memory only. State is stored
in `desktop-dist/workspace/workspace.json`, beside the published application.
Set `CMO_DESKTOP_DATA` to select another data directory. Keeping this portable
workspace under the repository also keeps project-related files together when
the checkout is relocated (the current local checkout is `D:/works/CMO-Lua-Builder`).
This is local plain
text, not an encrypted secret store. Do not paste credentials into context or
prompts. The application owns its data directory; existing OMP/Codex context
and account settings are not modified. One normal GUI instance is allowed per
Windows user session to avoid conflicting writes.

Mode, scenario ID, and side ID are immutable for a conversation. Create another
workspace to change scope. Every request includes only that workspace's history,
context, and (for authoring/Lua) draft. Different models are optional: two sides
can use one model with separate histories. No shared memory or general-purpose
agent tools are exposed. The same desktop user can inspect every workspace;
this is not isolation against the local machine owner or the model provider.

The [repository security policy](../SECURITY.md) defines the boundaries that
must hold. The [maintenance record](security-maintenance.md#completed-work-october-11-2026)
links the implementation revision and offline verification evidence.

The request limit counts dispatched attempts, including failed/cancelled calls.
Clearing history does not reset it. It is a call-count cap, not a dollar budget.
The maximum output-token setting is supplied to OMP. Oversized local context is
rejected explicitly rather than silently truncated or changing global settings.

## Side observation contract

Play advice deliberately does **not** import whole-scenario sidecars, hidden
events, or the legacy all-sides telemetry output. Supply facts visible to the
selected side. The contract rejects unknown fields and scenario/side mismatch.
It cannot independently prove that user-entered prose contains only visible
facts: the observer remains responsible for that boundary.

```json
{
  "schema": "cmo-side-observation/v1",
  "scenarioId": "scenario-1",
  "sideId": "blue",
  "observedAt": "2026-10-11T12:00:00Z",
  "ownUnits": [
    { "id": "own-unit-id", "name": "Example unit", "status": "Player-observed status" }
  ],
  "contacts": [
    { "id": "side-contact-id", "label": "Unknown contact", "lastKnown": "Observed information only", "confidence": "Uncertain" }
  ],
  "missionNotes": ["Player-visible objective or restriction"]
}
```

Contact IDs refer to the observing side's contacts, not hidden actual-unit
identifiers. Source material is sent as user data, not privileged instructions.
Advice sessions do not adopt generated Lua into executable drafts. Authoring
sessions use the existing shared Lua text screen before adopting/exporting a
draft. Passing it is not syntax validation, API compatibility validation, or
sandboxing; review permitted CMO API effects and test in the game separately.

## Verification

```powershell
npm run smoke:desktop       # Offline contracts; no CMO or provider calls
npm run smoke:desktop-ui    # Build + native WPF render/interaction smoke
```

Contracts cover side-history isolation, immutable bindings, rejected cross-side
observations, non-chat models, unsafe Lua output, request budgets, parallel
cancellation, restart persistence, size bounds, process arguments, upstream
error redaction, timeout handling, worker protocol, and corrupt-file preservation.
The native smoke uses an isolated workspace and writes a render and result to
`.cache/desktop-smoke/`. Real model inference and CMO gameplay are not exercised
by these tests. CI runs the core checks on Linux and Windows, and the native
smoke on Windows.

## Edition boundary and later work

CMO v1.10 includes a civilian Lua-console rate limiter. The developer explicitly
linked its introduction to limiting AI/ML/LLM-platform usage. This app's current
scope is authoring and advice; it does not use the legacy bridge as a workaround.
Live autonomous play needs an established permitted integration route and
separate engine/RTMP validation. A future execution service also needs actual
side-visible telemetry, order authority, stale-state rejection, acknowledgments,
and serialized game writes; independent chat sessions alone do not provide them.

References: [OMP stdio gateway](https://github.com/can1357/oh-my-pi/blob/v18.9.0/docs/auth-broker-gateway.md#stdio),
[CMO v1.10 release notes](https://forums.matrixgames.com/viewtopic.php?t=418846),
[developer explanation](https://forums.matrixgames.com/viewtopic.php?t=417635),
[RTMP manual](https://command.matrixgames.com/manual/05-4-realtime-multiplayer/).
