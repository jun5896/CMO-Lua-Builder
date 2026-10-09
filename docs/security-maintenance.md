# Defensive Security Maintenance

CMO-Lua-Builder is a personally maintained open-source tool for authoring Lua
scripts and inspecting Command: Modern Operations scenarios with optional LLM
assistance. Its defensive security work protects the tool's own software and
local integrations: provider credentials, local HTTP operations, imported
scenario data, generated commands, and files written for the game.

**Junyoung Lim ([@jun5896](https://github.com/jun5896))** is the project owner and
designated security maintainer. Responsibilities include receiving reports,
triaging and reproducing issues, implementing fixes, and maintaining regression
coverage. Reports can be submitted through the
[private reporting channel](../SECURITY.md#reporting-a-vulnerability).

## Completed work: October 9, 2026

Four security issues were investigated and patched against development baseline
`2ec8646e17c566a9bd2aa9a6dca3b3ecba7a2055`. The work used source review,
synthetic reproductions, implementation changes, and regression checks. The
maintainer used AI-assisted investigation and a separate AI-assisted review of
the candidate changes.

| Area | Defensive change | Inspectable evidence |
| --- | --- | --- |
| Local HTTP authorization and provider credentials | Check loopback Host and allowed Origin before dispatch; require a per-start session capability for sensitive routes; bind retained keys to the actual provider destination; reject redirects. | [Request checks](../server/adapter-security.mjs), [credential binding](../server/provider-config.mjs), [HTTP regression suite](../tools/verify-adapter-security.mjs) |
| CLI prompt handling | Reject Grok batch shims before launch when the prompt would otherwise become a shell argument; preserve native argument passing and stdin-based CLI workflows. | [CLI implementation](../server/cli-providers.mjs), [command boundary tests](../tools/verify-command-boundaries.mjs) |
| Scenario command generation | Regenerate commands from structured paths; quote PowerShell arguments literally, including typographic apostrophes; ignore cached executable command text. | [Shared command builder](../src/lib/scenarioCommands.js), [index generation](../tools/audit-cmo-scenario-openability.mjs), [command boundary tests](../tools/verify-command-boundaries.mjs) |
| Malformed request handling | Validate JSON objects, nested settings, and messages; catch asynchronous dispatch failures so malformed input returns a controlled error. | [HTTP adapter](../server/ai-provider-adapter.mjs), [malformed-input regressions](../tools/verify-adapter-security.mjs) |

Review also identified two edge cases that were corrected before publication:
provider URL normalization had to match the actual endpoint assembly order, and
a malformed startup URL had to remain repairable through settings without
carrying its old key to a new destination.

### Validation evidence

Local verification used Node.js 24.16.0 on Windows, synthetic provider keys,
loopback mock servers, temporary files, and mock CLI spawning.

- The original unauthorized credential-forwarding and JSON-null termination
  cases were reproduced before the patch. The patched paths reject those inputs
  and continue serving valid requests.
- Three focused regression suites passed, including session restart recovery,
  single-flight token bootstrap, retained-key destination checks, and atomic
  settings replacement.
- PowerShell parsing covered 46 command cases with exact literal argument
  round trips. Synthetic index generation preserved distinct slugs for duplicate
  scenario filenames, and index verification rejected altered command strings.
- ESLint, the production build, and 17 existing smoke suites passed. Controls
  included normal provider requests, Lua sidecar writes, log feedback, state
  imports, and existing upstream-error credential redaction.

The [CI workflow](../.github/workflows/ci.yml) runs the game-independent checks
on pushes and pull requests. The command-boundary job uses Windows.
[GitHub Actions](https://github.com/jun5896/CMO-Lua-Builder/actions/workflows/ci.yml)
provides the run status and logs for each published revision.

### Reproduce the focused checks

```powershell
npm ci
npm run lint
npm run build
npm run smoke:adapter-security
npm run smoke:adapter-transport
npm run smoke:command-boundaries
npm run smoke:ai-adapter
```

The command-boundary suite requires Windows PowerShell, or `pwsh` on other
platforms. These focused suites use mock providers and synthetic scenario
wrappers; they do not require provider credentials, a live provider CLI, or a
running CMO installation.

Actual provider calls, live game execution, full scenario decoding, and manual
browser end-to-end testing were outside this verification. The Lua unsafe-code
filter remains a screening control rather than a complete sandbox. Local
adapter authentication protects the browser boundary; it does not isolate
processes already running as the same OS user.

## Earlier maintenance

The [May 3, 2026 upstream-error redaction record](contracts/ai-provider-calibration-resolution-2026-05-03.md)
documents an earlier fix that removed upstream error bodies from returned
responses. Its [mock-provider harness](../server/verify-upstream-redaction.mjs)
remains part of the regression checks.

## Planned defensive review

The following items are follow-up work, not completed security guarantees:

- Review consistency of Lua validation across the UI, adapter, and terminal
  bridge, including alternate syntax and generated-output handling.
- Review scenario identity, user approval, and replay handling around the
  file-based inbox and game-script application workflow.
- Expand malformed-file and path-boundary cases for imported XML/JSON, scenario
  sidecars, and file operations.
- Maintain a build-aware CMO Lua compatibility reference so unverified or
  unsupported commands are not presented as confirmed APIs.

This is an early personal project. External adoption or dependent projects had
not been established when it was made public on October 7, 2026. These records
document maintenance of the owner's own project; they do not claim an external
independent audit, an assigned CVE, or approval by a security access program.
