# CMO Lua Builder

[![CI](https://github.com/jun5896/CMO-Lua-Builder/actions/workflows/ci.yml/badge.svg)](https://github.com/jun5896/CMO-Lua-Builder/actions/workflows/ci.yml)

A Vite + React workspace for authoring Command: Modern Operations (CMO) Lua scripts, managing templates and presets, inspecting scenario sidecars, and reviewing AI-assisted drafts.

## Defensive Security Maintenance

Security maintenance focuses on the project's own code and local integration
boundaries: untrusted browser requests, provider credentials, CLI invocation,
imported scenario data, and AI-generated output.

The [October 9, 2026 maintenance record](docs/security-maintenance.md) connects
four completed security fixes to their implementation and regression tests.
It covers local request authorization and key destination binding, CLI command
injection prevention, safe PowerShell command generation, and malformed-request
handling. Local lint, build, focused security checks, and existing smoke checks
passed; published revisions have inspectable [CI runs](https://github.com/jun5896/CMO-Lua-Builder/actions/workflows/ci.yml).

See the [security policy and reporting channel](SECURITY.md) for maintainer
responsibilities, scope, and how to report a vulnerability. The maintenance record
also separates [planned defensive review](docs/security-maintenance.md#planned-defensive-review)
from completed work.

## Project Status and Maintenance

This personal project was made public on October 7, 2026. As of that date, no releases or packages had been published on GitHub, and external adoption or dependent projects had not been established. The `main` branch contains the development baseline. Release names and verification results in older documents refer to historical development work.

- Project and security maintainer: **Junyoung Lim ([@jun5896](https://github.com/jun5896))**.
- The maintainer handles security reports, reproduction, fixes, and regression verification. See the [security policy](SECURITY.md) and use [private vulnerability reporting](https://github.com/jun5896/CMO-Lua-Builder/security/advisories/new).
- Original project code and documentation are covered by the [MIT License](LICENSE). See [third-party notices](THIRD_PARTY_NOTICES.md) for the scope and exclusions affecting bundled assets and dependencies.

`tools/cmo-install-locator.mjs` detects the CMO installation by scanning Steam libraries through `libraryfolders.vdf`. You can override the detected paths with the `CMO_ROOT`, `CMO_LUA_ROOT`, `CMO_LOGS_ROOT`, and `CMO_SCENARIOS_ROOT` environment variables.

## AI Bridge (CLI Workflow)

The bridge lets AI coding agents, such as Claude Code, work with CMO Lua directly from a terminal without the React UI. AI-generated payloads pass through the same unsafe-Lua checks used by the UI.

```powershell
npm run bridge -- status                                    # Inspect paths, AiAssist, and logs
npm run bridge -- apply --file draft.lua --slug name --write  # Write a one-shot draft; dry-run without --write
npm run bridge -- install-poller --write                     # Generate Lua to install the in-game inbox poller
npm run bridge -- inbox --file draft.lua --write             # Publish a payload to the polled inbox
npm run bridge -- logs --kind exception --limit 10           # Read CMO logs without modifying them
```

Run the poller installation Lua once in the CMO Lua console. The game then executes subsequent `inbox` payloads through a RegularTime event. A KeyValue guard prevents duplicate execution, and results are stored in the `aiassist_inbox_result` KeyValue. Without the poller, use `apply` and run the generated one-line loader in the console.

### AI Backend Selection (Subscription CLIs and BYOK)

The backend scanner discovers local Claude Code profiles, Codex accounts, Cursor CLI, and bring-your-own-key (BYOK) presets for Kimi, GLM, and Grok.

```powershell
npm run backends                                  # List backends, account emails, and key availability
npm run backends -- --use claude:default           # Select the default backend
npm run ask -- --backend codex:pro2 --prompt "..." # Send a one-shot request or request a cross-review
```

BYOK keys are read from environment variables and are not stored on disk by the backend selector. The Cursor Composer integration uses the subscription CLI (`cursor-agent`); BYOK HTTP access is not supported by this integration.

## Running the UI

Run the UI through Vite rather than opening `index.html` directly. The development server handles React, ES module imports, and static assets under `/public`.

```powershell
git clone https://github.com/jun5896/CMO-Lua-Builder.git
cd CMO-Lua-Builder
npm install
npm run dev -- --host 127.0.0.1
```

Open the URL printed in the terminal, typically:

```text
http://127.0.0.1:5173/
```

To build and preview the production bundle locally:

```powershell
npm run build
npm run preview -- --host 127.0.0.1
```

## Features

- **Event / Lua Assistant:** Draft CMO Lua, insert templates and presets, and review AI responses.
- **Preset Guide:** Browse template descriptions, use builder forms, and manage custom presets.
- **Scenario Sidecar Cache:** Attach local analysis sidecars to compressed `.scen` files.
- **AI Provider Settings:** Configure OpenAI-compatible, LM Studio, and Ollama adapters and select model profiles.
- **AI Context Pruning:** Reduce large scenario contexts while preserving DBID, GUID, and active-Lua safety invariants.

## Sidecar Storage

Scenario sidecars are local analysis files that leave the original `.scen` file unchanged. The external cache location used in the development setup is:

```text
D:\works\cmo-scenario-sidecars
```

Without an environment override, the tools first look for `cmo-scenario-sidecars` beside the cloned repository, then fall back to the legacy cache root inside the project. Set an explicit location with:

```powershell
$env:CMO_SCENARIO_SIDECAR_ROOT = "D:\works\cmo-scenario-sidecars"
```

Recorded verification baseline (July 4, 2026; replacement development PC, Build 1892, DB517):

- Total scenarios: `1155`
- Ready with internal sidecar: `1155`
- Legacy decoder failed: `0`
- Loader issues: `0`

The May 2026 baseline on the previous PC was 1899 / 1857 / 42 / 0 for the same metrics. The 42 legacy CMANO scenarios were not present on the replacement PC.

Related commands:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
```

Review the dry-run output before deleting orphaned sidecars. Referenced sidecars are not deletion candidates. `.scenario-extract-cache` is temporary extraction storage.

When no matching summary sidecar exists, the AI adapter can open a `.scen` file as a temporary in-memory summary to supplement the context. This path also preserves the original `.scen` file and cleans up temporary files.

## AI Adapter Safety

Start the local adapter in a separate terminal with `npm run start:ai-adapter`.
Use the UI at `http://127.0.0.1:5173` or `http://localhost:5173` (preview: port
`4173`). Other browser origins and non-loopback Host headers are rejected.
The UI obtains a per-start session token automatically, keeps it only in memory,
and reconnects after an adapter restart.

Custom local HTTP clients must first send `GET /api/session` with
`X-CMO-Bootstrap: 1`, then send the returned token as `X-CMO-Session` on API
requests. `GET /api/health` provides public readiness metadata only. JSON POSTs
require `Content-Type: application/json`; scenario uploads use
`application/octet-stream`. This protects against browser-origin requests; it
does not isolate the adapter from other processes running as the same local user.

An omitted API key is retained only for the same provider destination. Saving a
different destination without a new key clears the stored key. When switching to
a keyless local provider, save its settings before testing. Per-request destination
overrides must supply a new key explicitly (or `apiKey: ""` for keyless use).
HTTP redirects are rejected; configure the provider's final API URL directly.
Grok prompt calls require a native executable: Windows `.cmd`/`.bat` shims are
rejected before launch. CLIs that accept prompts on stdin keep that workflow.

Scenario decoder commands are regenerated from paths, with literal PowerShell
arguments, including apostrophes and typographic quotes. Cached command strings
from older indexes or sessions are ignored. Regenerate an old openability index
with `npm run audit:scenario-openability` before running its command validation.

Focused regression checks use synthetic keys and local mock providers:

```powershell
npm run smoke:adapter-security
npm run smoke:adapter-transport
npm run smoke:command-boundaries  # Windows PowerShell; pwsh on other platforms
```

The AI adapter forwards provider requests locally. Saved provider profiles do not contain raw API keys. The smoke test checks for leakage of its synthetic test key and Bearer-token patterns:

```powershell
npm run smoke:ai-adapter
```

Security maintenance records:

- [Defensive security maintenance (October 9, 2026)](docs/security-maintenance.md): Four fixes with implementation links, reproducible regression checks, validation scope, and planned follow-up review.
- [Upstream error-response credential redaction record (May 3, 2026)](docs/contracts/ai-provider-calibration-resolution-2026-05-03.md): An internal development record covering removal of upstream error bodies, response sanitization, and regression verification.
- [Regression harness](server/verify-upstream-redaction.mjs): A local mock server includes a fake credential in an HTTP 401 response. The harness checks the adapter response and logs for the test key and Bearer-token patterns. It uses local ports `8766` and `8899`.

These are internal development and verification records produced with AI assistance, not evidence of an independent external audit or an assigned CVE. The test covers the specified error-response path and does not establish the security of the entire project.

AI-generated Lua must pass the paste-ready checks before the UI can apply it to the Working Draft. The UI presents it as a Lua draft, not fully verified code. Validate its behavior in the CMO engine before relying on it.

## QA Baseline

The following pipeline was used for development verification. The results and bundle sizes below are historical baselines, not fresh results for the current commit. Scenario-related steps require a separate CMO installation and local data.

```powershell
npm run verify:release
```

Individual verification commands include:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-workflow-state
npm run smoke:ai-follow-up-needs
npm run smoke:ai-confirmed-context
npm run smoke:ai-adapter-client-sidecar
npm run smoke:cmo-log-feedback
npm run smoke:cmo-log-feedback-endpoint
npm run smoke:ai-adapter-client-log-feedback
npm run smoke:cmo-state-snapshot
npm run smoke:cmo-state-snapshot-endpoint
npm run smoke:ai-adapter-client-state-snapshot
npm run smoke:cmo-wiki-code-assistant
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

Recorded bundle baseline:

- Main JS: `253.81 kB`
- Main CSS: `59.45 kB`
- `aiContextPruning`: `8.56 kB`
- Template Inspector annotations: `51 / 51`
- `PresetGuide`: `33.99 kB JS / 7.49 kB CSS`
- `AiInterpreterChatPanel`: `10.38 kB JS / 6.73 kB CSS`
- `AiResponseReviewPanel`: `10.15 kB JS / 5.23 kB CSS`
- Confirmed Context Workspace: `smoke:ai-confirmed-context` PASS baseline
- RunScript Sidecar Writer: `smoke:cmo-lua-sidecar-writer`, `smoke:cmo-lua-sidecar-endpoint`, `smoke:ai-adapter-client-sidecar` PASS baseline
- Log Feedback Loop: `smoke:cmo-log-feedback`, `smoke:cmo-log-feedback-endpoint`, `smoke:ai-adapter-client-log-feedback` PASS baseline
- State Snapshot Import: `smoke:cmo-state-snapshot`, `smoke:cmo-state-snapshot-endpoint`, `smoke:ai-adapter-client-state-snapshot` PASS baseline
- CMO Wiki / Lua Reference Helper: `smoke:cmo-wiki-code-assistant` PASS baseline
- `CmoWikiPanel`: `7.59 kB JS / 3.61 kB CSS`
- `LuaEditorReferenceHelper`: `2.12 kB JS / 0.84 kB CSS`
- `LuaAssistant`: `136.86 kB JS`

## Synchronized CMO Assets

- Templates: `public/cmo-dev-work/templates/*.tpl.lua`
- Presets: `public/cmo-dev-work/presets/*.lua`
- Manifest: `public/cmo-dev-work/manifest.json`
- DB summary: `DB3K_517.db3`, `CWDB_517.db3`, component entries `101078`
- Installed Lua examples: `public/cmo-installed-lua/`

After editing templates or presets in `cmo-lua-dev-work`, synchronize them to `public/cmo-dev-work` so the UI Inspector reflects the changes.

Materials under `public/**` and `fixtures/**` are excluded from the blanket MIT grant for the project code. See [third-party notices](THIRD_PARTY_NOTICES.md) for provenance and redistribution conditions.
