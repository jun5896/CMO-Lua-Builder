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

## Completed work: October 14, 2026

Implemented in [commit `a9054db`](https://github.com/jun5896/CMO-Lua-Builder/commit/a9054db1b09ca85e1eb8272e883119116abdf7b2),
with Windows test-path compatibility in
[`ec2784b`](https://github.com/jun5896/CMO-Lua-Builder/commit/ec2784bba5e73ba65fd80b68aad77c2db3fd8ea9).

Dependency review against baseline
`3b37b1cbb9891ff2cba37d7b5f68dcec0c27ac76` found eight affected npm packages
(six high, one moderate, one low). All were development dependencies;
`npm audit --omit=dev` reported zero. Development tooling still processes local
HTTP requests, source, CSS, source maps, and configuration, so these findings
were addressed rather than excluded on that basis.

| Package | Previous lock | Updated lock | Dependency path |
| --- | --- | --- | --- |
| `vite` | 8.0.10 | 8.0.16 | Web dev server and build |
| `postcss` | 8.5.13 | 8.5.30 | Vite |
| `nanoid` | 3.3.12 | 3.3.20 | PostCSS |
| `source-map-js` | 1.2.1 | 1.2.2 | PostCSS |
| `@babel/core` | 7.29.0 | 7.29.7 | ESLint React Hooks plugin |
| `browserslist` | 4.28.2 | 4.29.3 | Babel compilation targets |
| `baseline-browser-mapping` | 2.10.25 | 2.11.28 | Browserslist |
| `brace-expansion` | 5.0.5 | 5.0.12 | ESLint / minimatch |

The direct Vite requirement now starts at `^8.0.16`. Its upstream dependencies
and the remaining affected transitive packages were updated within compatible
dependency ranges, without `npm audit fix --force`. Runtime application
dependencies and the desktop's OMP protocol were not changed.

### Reproduction and limits

For the upstream [Vite Windows file-access advisory](https://github.com/vitejs/vite/security/advisories/GHSA-fx2h-pf6j-xcff),
an isolated loopback server used temporary synthetic `.env` and `tls.pem` files.
Vite 8.0.10 returned their marker through NTFS default-data-stream paths with
HTTP 200, although the direct `.env` path returned 403. With 8.0.16, both
default-data-stream requests returned 403; a percent-encoded variant returned
404. Normal public GET and HEAD requests remained supported. No real secrets,
remote SMB server, or provider credentials were involved.

The [regression test](../tools/verify-vite-security.mjs) now exercises those file
paths with synthetic input in Linux and Windows CI. The Windows job exercises
the affected filesystem behavior. It tests Vite's built-in file boundary;
this project's custom public/sidecar middleware remains a separate surface.
The other dependency findings were checked through resolved versions and npm's
advisory data, not individual exploit reproductions. No NTLM credential-capture
test was performed for the separate launch-editor advisory.

### Validation evidence

On Windows with Node.js 24.16.0 and npm 11.13.0, a disposable copy of the
candidate passed clean `npm ci`, lint, the production build, the Vite regression,
and full/production-only npm audits with zero findings. The new Vite test and
23 existing smoke suites covered the adapter, Lua paths, desktop contracts,
command boundaries, and native WPF build/render/interaction behavior.
The Vite fixture resolves temporary directories to real paths so Windows 8.3
aliases in `TEMP` do not invalidate the normal-file control; a synthetic short
`TEMP` path was also checked without disabling Vite's file protections.

The state-snapshot endpoint fixture initially failed to start because an
unrelated local Python service occupied its fixed port 8769. The service was
preserved. A temporary harness changed only the fixture port to an available
loopback port; the original assertions then passed. This is distinct from an
unmodified local run of that one test.

For `ec2784b`, the [published CI run](https://github.com/jun5896/CMO-Lua-Builder/actions/runs/38532206763)
passed both Linux verification and Windows command/native-UI verification.
Linux CI passed the unmodified state-snapshot endpoint test on its original
fixture port; Windows CI passed the Vite regression and native GUI smoke.

Additional synthetic HTTP checks confirmed dev/preview HTML, JS/CSS, a public
asset, and both sidecar URL aliases with GET/HEAD. The build output contained
no `scenario-scan-samples` directory. These checks do not establish complete
browser interaction coverage or a full custom-middleware security review.
Live provider inference and game execution were not exercised.

### Ongoing dependency checks

```powershell
npm ci
npm run audit:dependencies
npm audit --omit=dev
npm run smoke:vite-security
```

[CI](../.github/workflows/ci.yml) now checks all npm dependencies at low severity
or above on pushes to `main` and pull requests. Registry/audit failures fail the step;
there is no suppressed-advisory list. [Dependabot](../.github/dependabot.yml)
checks npm and GitHub Actions versions weekly and proposes updates for review.
This configuration does not enable automatic merging or establish that every
third-party vulnerability is known. Audit results are a dated dependency
snapshot, not a complete security assessment or a CVP eligibility decision.

## Completed work: October 11, 2026

The native Windows workbench was introduced in
[commit `3b37b1c`](https://github.com/jun5896/CMO-Lua-Builder/commit/3b37b1cbb9891ff2cba37d7b5f68dcec0c27ac76).
Its [published CI run](https://github.com/jun5896/CMO-Lua-Builder/actions/runs/38140597173)
passed the Linux verification job and the Windows command/native-UI job for
that exact revision. The central security policy was extended on October 14
to include these existing desktop boundaries.

| Boundary | Implemented control | Inspectable evidence |
| --- | --- | --- |
| Scenario/side conversations | Immutable mode/scenario/side binding; requests contain only the selected session's context, history, and applicable draft. | [Session construction and persistence](../desktop/core/workspace.mjs), [offline regressions](../tools/verify-desktop.mjs) |
| Imported play observations | Exact `cmo-side-observation/v1` fields, matching scenario/side, bounded values; reject whole-scenario and unknown-field input. | [Observation validator](../desktop/core/observations.mjs) |
| OMP integration | Argument-based child spawning with no shell; only model-list/chat routes; per-request child, ID matching, response limit, timeout, cancellation, and controlled errors. | [OMP gateway](../desktop/core/omp-gateway.mjs) |
| Resource use and storage | At most two active chats, per-session attempt counters, bounded context/history/state, serialized atomic replacement, and preservation of invalid stored files. | [Workspace](../desktop/core/workspace.mjs), [worker protocol](../desktop/worker.mjs) |
| Lua drafts | Shared textual screening before model-draft adoption and UI export; advice never adopts executable output and the worker exposes no game-execution method. | [Workspace](../desktop/core/workspace.mjs), [native export handler](../desktop/CmoWorkbench/MainWindow.xaml.cs), [shared screen](../src/lib/luaSafety.js) |

Run `npm run smoke:desktop` for offline contracts, or
`npm run smoke:desktop-ui` on Windows for the native build/render/interaction
smoke. The tests cover cross-side data rejection, independent cancellation,
request counters, corrupt-state recovery, subprocess arguments, synthetic
upstream errors, and Lua screening. They use mock providers, not paid inference
or live game execution. The desktop package uses Node built-ins and local
modules; it does not ship the Vite/React dependency tree.

These controls do not isolate a session from the machine owner or a shared
provider. The stored workspace is plaintext. Observation validation cannot
prove that user-written prose obeys fog of war, and OMP's credential storage,
account selection, and fallback behavior remain OMP's responsibility. Request
limits count attempts rather than dollars, and cancellation cannot undo
provider billing. The [desktop guide](desktop-workbench.md) documents these
limits and the current authoring/advice scope.

## Completed work: October 10, 2026

At baseline `4bc0717eb097eaedf1d3f4c641996db849a456a7`, the browser marked
`ScenEdit_RunScript('/x.lua')` and `require 'socket'` ready while the server
writer rejected them. Both paths accepted `local files = io; files.open('x')`.
These differences were reproduced through the parser and writer without
executing Lua or contacting a model provider.

The [shared Lua safety module](../src/lib/luaSafety.js) now supplies one
versioned policy to the [browser response parser](../src/lib/aiAdapterClient.js)
and [server writer](../server/cmo-lua-sidecar-writer.mjs). The terminal bridge
continues to reach that same writer validation for apply, inbox and query.
Complete forbidden identifier references are rejected, covering aliases,
bracket access, alternate call forms, global environment access and dynamic
loaders. Ordinary longer identifiers such as `requirements` and `workload`
remain permitted. Non-string input, NUL characters and sources over 320,000
UTF-16 code units are rejected before a file write. Successful writes preserve
the existing trailing-whitespace normalization and final newline.

The [cross-entry regression suite](../tools/verify-lua-safety-contract.mjs)
includes 27 adversarial drafts and nine normal drafts. It compares browser,
writer and inbox decisions; exercises real CLI dispatch against temporary
directories; checks size/type boundaries and unchanged inbox contents after a
rejection; and preserves fixed telemetry, query and poller templates. The
[HTTP endpoint suite](../tools/verify-cmo-lua-sidecar-endpoint.mjs) verifies that
forged readiness/write-confirmation flags cannot create forbidden files.
Local lint, the production build and 21 distinct smoke suites passed on
Windows with Node.js 24.16.0. The new shared-policy suite is also included in
both Linux and Windows CI jobs. CI results for each published revision are
available in [GitHub Actions](https://github.com/jun5896/CMO-Lua-Builder/actions/workflows/ci.yml).

Reproduce these game-independent checks:

```powershell
npm run smoke:lua-safety
npm run smoke:ai-client-parser
npm run smoke:cmo-lua-sidecar-writer
npm run smoke:cmo-lua-sidecar-endpoint
npm run smoke:cmo-ai-bridge
```

### Scope and compatibility

This is conservative textual screening. Reserved names can also cause rejection
inside comments or strings; strings are inspected because CMO can later execute
`ScriptText` values. Encoded or concatenated embedded Lua is not resolved, valid
syntax is not established, and permitted game APIs can still change or damage
scenario state. Passing the screen is not approval to execute a draft.

Response sections and placeholders remain browser-only completeness checks.
For example, the bridge's generated telemetry comments contain explanatory
`<side>` text, which must not be treated as a user-supplied missing value. The
fixed poller installer uses its existing trusted-template path; no untrusted
HTTP or CLI input flag was added to bypass the policy. This work does not add
target-bound approval, expiry or a replay ledger to the inbox.

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

- Evaluate syntax-aware and embedded-code validation beyond the shared textual
  screen, including encoded/constructed `ScriptText` and permitted API effects.
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
