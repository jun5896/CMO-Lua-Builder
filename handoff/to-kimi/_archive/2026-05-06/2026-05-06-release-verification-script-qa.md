# Kimi QA Directive - Release Verification Script

Date: 2026-05-06
Requested by: Codex
Mode: read-only QA / release-pipeline regression monitor

## Purpose

Verify the convenience release QA script added in:

```text
d7afc39 Add release verification script
```

This is a small package/README workflow change. It should not affect product source, dependencies, bundle content, or sidecar data.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not archive this directive; Codex will archive it after your report.
- Do not install dependencies or add test frameworks.
- Do not prune sidecars or delete orphans.
- Do not run broad scenario extraction.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run verify:release
```

If `npm run verify:release` hits `spawn EPERM`, report it as sandbox/environment unless code evidence says otherwise. Codex already validated the same command after approved spawn permissions.

## Expected Script Expansion

Confirm `npm run verify:release` expands to:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

## Expected Baseline

- Scenario index: `1899`
- Loader counts: `1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`
- Sidecar audit: dry-run only, `24` orphans / about `5.6 MB`
- Main JS: about `366.29 kB`, under `400 kB`
- Main CSS: `58.27 kB`, under `60 kB`
- `aiContextPruning`: `8.56 kB`, under `9 kB`
- `smoke:ai-client-parser`: PASS
- `smoke:ai-adapter`: PASS with no raw `Bearer` / `sk-` leakage

## Static Checkpoints

Verify:

1. `package.json` contains `verify:release`.
2. `verify:release` includes the six commands listed above and preserves their order.
3. `README.md` documents `npm run verify:release` in the QA Baseline section.
4. The manual split pipeline remains documented below the shortcut.
5. `package-lock.json` is unchanged.
6. No dependency or devDependency was added.
7. No `src/**`, `server/**`, or `tools/**` product file changed in commit `d7afc39`.

## Report Format

Return a compact QA report with:

- pipeline result
- bundle sizes
- scenario / sidecar counts
- static checkpoint table
- dependency/package-lock status
- any regression
- final verdict

Expected final verdict if all checks pass:

```text
APPROVED - release verification script holds.
```
