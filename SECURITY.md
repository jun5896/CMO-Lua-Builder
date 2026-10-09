# Security Policy

## Maintainer and supported development line

**Junyoung Lim (GitHub: [@jun5896](https://github.com/jun5896))** is the project owner and designated security maintainer of CMO-Lua-Builder. The maintainer receives reports, investigates and reproduces issues, develops fixes, and reviews regression tests.

Security reports are reviewed against the current `main` branch. Older snapshots can be reported with their commit IDs so the maintainer can determine whether the issue remains present. This is an early personal project; maintenance is best effort, without a guaranteed response or remediation deadline.

## Reporting a vulnerability

Use GitHub's [private vulnerability reporting form](https://github.com/jun5896/CMO-Lua-Builder/security/advisories/new). Keep unpublished vulnerability details and credentials out of public issues.

Please include:

- Affected commit, component, and relevant environment.
- The input and steps needed to reproduce the issue using synthetic data.
- Expected behavior, observed behavior, and realistic security impact.
- A minimal reproduction or regression test, if available.

Redact API keys, account/session tokens, personal file paths, and private scenario data. Coordinate public disclosure through the private report. Test only systems and data you own or have permission to assess.

## System and trust boundaries

CMO-Lua-Builder is a local Lua authoring and scenario-analysis tool for Command: Modern Operations. Its security-relevant surfaces include the Vite/React interface (`src/`), the loopback Node.js adapter (`server/`), local file/CLI operations (`tools/`), and generated Lua passed to the game.

Assets include provider credentials, local files, original scenario files, and the integrity of generated scripts. Provider responses, AI-generated text and Lua, imported scenario/XML/JSON data, filenames, and browser-origin requests cross trust boundaries. The selected external AI provider receives the context sent to it; the user controls that selection and what data is supplied.

The adapter is designed to bind to `127.0.0.1`, with a limited browser-origin list. Loopback binding and CORS are not substitutes for authorization, nor proof that browser-origin or imported input is safe. The deployment model is local use; it has not been established as suitable for shared or public hosting.

## Security properties to preserve

- Raw credentials must not be persisted in browser storage or committed to the repository, and must not be exposed in returned responses or logs. Key previews must not expose the complete credential.
- Upstream error bodies must not be forwarded in a way that reveals credentials. Response scrubbing is defense in depth and is not proof that every secret format is recognized.
- AI-generated Lua must pass the unsafe-code and placeholder checks before being offered for application. These checks are not a complete Lua sandbox. Fixed bridge-generated loader/poller code is a separate path from untrusted AI output.
- Scenario analysis must preserve the original `.scen` file. Game-script writes must remain within the intended `Lua/AiAssist` workspace, and other file operations must respect their selected output paths.
- Imported data, filenames, and generated content must not gain unintended access to local files or command execution.

## Assessment context and limitations

Reports should explain the reachable input path, required user interaction or permissions, and resulting access to credentials, files, commands, or game state. Evaluate local browser and imported-file attack paths on their actual impact rather than dismissing them solely because the service runs on localhost. No blanket exclusions or accepted vulnerabilities are declared by this policy.

The game engine, third-party model providers, and installed CLI tools have their own security boundaries. Report issues in this project's integration with them here; vulnerabilities solely within those products should also reach their respective maintainers.

Historical test results are not a complete security audit. The project had no established external adoption when the repository was made public on 2026-10-07, and makes no independent-audit or CVE claim.

## Existing security work

- [Defensive security maintenance record (2026-10-09)](docs/security-maintenance.md): Four completed fixes covering local HTTP authorization and provider-key destination binding, CLI prompt handling, scenario command generation, and malformed JSON requests. Includes implementation links, synthetic regression evidence, validation limitations, and separately labeled follow-up work.
- [Game-independent CI](.github/workflows/ci.yml) and [published run results](https://github.com/jun5896/CMO-Lua-Builder/actions/workflows/ci.yml). Focused checks: `smoke:adapter-security`, `smoke:adapter-transport`, and `smoke:command-boundaries`.
- [Internal upstream-error redaction fix and verification record (2026-05-03)](docs/contracts/ai-provider-calibration-resolution-2026-05-03.md).
- [Local regression harness](server/verify-upstream-redaction.mjs), run with `npm run smoke:ai-adapter`. It uses a fake key and local ports `8766` and `8899` to check the HTTP 401 echo scenario; it does not cover every credential or execution path.
