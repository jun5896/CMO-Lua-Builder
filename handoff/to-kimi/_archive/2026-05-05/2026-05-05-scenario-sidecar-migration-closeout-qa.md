# Kimi QA Request - Scenario Sidecar Migration Closeout

## Context

Codex verified that scenario sidecars are now served from the external cache root. The missing project-local `scenario-sidecars/` folder should no longer be treated as a pending migration if the external root and index exist.

## Files Updated

- `docs/references/scenario-sidecar-cache-policy.md`
- `docs/agent-ops/scenario-sidecar-migration-closeout-2026-05-05.md`

## Expected State

- External root exists:
  - `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
- External index exists:
  - `C:\Users\dlwls\.codex\cmo-scenario-sidecars\scenario-openability-index.json`
- Project-local sidecar folders are absent and that is expected:
  - `C:\Users\dlwls\.codex\cmo-lua-ui\scenario-sidecars`
  - `C:\Users\dlwls\.codex\cmo-lua-ui\public\scenario-scan-samples`
  - `C:\Users\dlwls\.codex\cmo-lua-ui\dist\scenario-scan-samples`
- `.scenario-extract-cache/` is empty.

## QA Pipeline

Run:

```powershell
git status --short
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run build
```

Full lint/smoke is optional because this is a docs/storage-verification closeout, but run them if a source file changed after this handoff.

## Checkpoints

1. `audit:scenario-sidecars` reports root `C:\Users\dlwls\.codex\cmo-scenario-sidecars`.
2. `audit:scenario-sidecars` reports `scenariosInIndex: 1899`.
3. Protected-by-index files remain near `3799`.
4. Orphans remain small; Codex baseline was `24 files / 5.6 MB`.
5. `verify:scenario-loader` reports `1857 readyWithInternalSidecar`, `42 decoderFailed`, issues `0`.
6. `dist/scenario-scan-samples` does not exist.
7. Project-local `scenario-sidecars` absence is reported as expected, not as a failure.
8. Build still emits no sidecar sample directory into `dist`.

## Expected Local Baseline From Codex

Codex local verification before handoff:

- `npm run audit:scenario-sidecars`: PASS dry-run.
- Active root: `C:\Users\dlwls\.codex\cmo-scenario-sidecars`.
- Sidecar cache: `3823 files`, `3.06 GB`.
- Protected by index: `3799 files`, `3.055 GB`.
- Orphans: `24 files`, `5.6 MB`.
- `.scenario-extract-cache`: `0 files`, `0 MB`.
- `npm run verify:scenario-loader`: PASS, issues `0`, counts `1857/42`.
- `npm run build`: PASS.
- Main JS: `395.60 kB`.
- Main CSS: `64.08 kB`.

## Report Format

Report only:

- Pass/fail for each pipeline step.
- Active sidecar root and index existence.
- Dist/project-local duplication status.
- Scenario loader counts.
- Any actionable regression.

Do not recommend deleting orphan sidecars unless Codex or the user explicitly opens a cleanup task.
