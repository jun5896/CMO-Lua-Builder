# Scenario Sidecar Migration Closeout - 2026-05-05

## Verdict

The scenario sidecar migration is closed.

The active sidecar cache is external, and project-local sidecar duplication is absent. This is the desired storage state, not a pending migration.

## Active Root

```text
C:\Users\dlwls\.codex\cmo-scenario-sidecars
```

The active index is:

```text
C:\Users\dlwls\.codex\cmo-scenario-sidecars\scenario-openability-index.json
```

`tools/sidecar-paths.mjs` resolves this external root as preferred when the external index exists.

## Verified State

- External root exists: yes.
- External `scenario-openability-index.json` exists: yes.
- Project-local `scenario-sidecars/`: absent, expected.
- `public/scenario-scan-samples/`: absent, expected.
- `dist/scenario-scan-samples/`: absent, expected.
- `.scenario-extract-cache/`: empty.
- `npm run audit:scenario-sidecars`: PASS in dry-run mode.
- `npm run verify:scenario-loader`: PASS, issues `0`.
- `npm run build`: PASS.

## Audit Baseline

From `npm run audit:scenario-sidecars`:

- Root: `C:\Users\dlwls\.codex\cmo-scenario-sidecars`.
- Scenarios in index: `1899`.
- Total files: `3823`.
- Total size: `3.06 GB`.
- Protected by index: `3799` files / `3.055 GB`.
- Orphans: `24` files / `5.6 MB`.
- By kind:
  - `scan`: `1911`.
  - `summary`: `1869`.
  - `diagnosticError`: `42`.
  - `index`: `1`.

The orphan set is small and does not need immediate deletion. If cleanup is desired, run `npm run prune:scenario-sidecars` first and only use `--yes` after reviewing the dry-run output.

## Loader Baseline

From `npm run verify:scenario-loader`:

- Total: `1899`.
- `readyWithInternalSidecar`: `1857`.
- `decoderFailed`: `42`.
- Issues: `0`.

## Operational Rule

Kimi and other QA agents should no longer treat a missing project-local `scenario-sidecars/` folder as a failure.

The correct check is:

1. External root exists.
2. External `scenario-openability-index.json` exists.
3. `audit:scenario-sidecars` reports the external root.
4. `verify:scenario-loader` reports `issues 0`.
5. `dist/scenario-scan-samples/` remains absent.

## Future Work

- Optional: prune the `24` orphan files after a reviewed dry-run.
- Optional: add a UI status hint for the active sidecar root if users keep asking where sidecars live.
- Do not reintroduce `public/scenario-scan-samples/` or build-time copied sidecars.
