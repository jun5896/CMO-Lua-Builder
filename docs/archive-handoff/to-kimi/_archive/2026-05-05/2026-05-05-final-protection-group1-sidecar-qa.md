# Kimi QA Request - Final Protection Group 1 Sidecar Storage

## Scope

Read-only QA for final protection group 1: Scenario Sidecar Storage And Loader Tooling.

Codex already ran a self-verification pass. Please independently verify the sidecar storage/tooling baseline and report only concrete regressions. Do not modify files and do not prune/delete sidecars.

## Files In Scope

- `.gitignore`
- `package.json`
- `vite.config.js`
- `tools/sidecar-paths.mjs`
- `tools/audit-cmo-scenario-openability.mjs`
- `tools/prepare-cmo-scenario-sidecar.mjs`
- `tools/prepare-cmo-scenario-batch.mjs`
- `tools/scan-cmo-scenario-folder.mjs`
- `tools/verify-cmo-scenario-loader.mjs`
- `tools/extract-cmo-scenario-xml.ps1`
- `tools/move-cmo-scenario-sidecar-root.mjs`
- `tools/prune-cmo-scenario-sidecar-cache.mjs`
- `tools/prune-cmo-scenario-xml-sidecars.mjs`
- `server/verify-transient-scenario-open.mjs`
- `docs/references/scenario-sidecar-cache-policy.md`
- `docs/agent-ops/scenario-sidecar-migration-closeout-2026-05-05.md`
- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`

## Required Pipeline

Run:

```powershell
git status --short
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run build
npm run smoke:scenario-transient
```

If `npm run smoke:scenario-transient` reports `spawn EPERM`, report it as a sandbox spawn restriction and ask Codex/user to rerun with approval. Do not work around it with source changes.

## Expected Baseline

Sidecar audit:

- root: `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
- index: `C:\Users\dlwls\.codex\cmo-scenario-sidecars\scenario-openability-index.json`
- scenariosInIndex: `1899`
- protectedByIndex: about `3799` files / `3.055 GB`
- orphans: about `24` files / `5.6 MB`
- mode must be dry-run

Scenario loader:

- total: `1899`
- `readyWithInternalSidecar`: `1857`
- `decoderFailed`: `42`
- issues: `0`

Build:

- PASS
- main JS: about `366.05 kB`
- main CSS: about `58.27 kB`
- `dist` size: about `2.49 MB`
- `dist/scenario-scan-samples`: missing
- `dist/scenario-sidecars`: missing
- project-local `scenario-sidecars`: missing unless Codex/user intentionally created it

Transient smoke:

- PASS
- HTTP status `200`
- returns an in-memory summary
- temp cache before/after should remain `0 / 0`

## Regression Watch

- Do not allow `dist` to include scenario sidecar bulk data.
- Do not classify external sidecar root as product data to commit.
- Do not delete orphan files during this QA.
- Report if `verify:scenario-loader` deviates from `1857/42`.
- Report if `smoke:scenario-transient` leaves temp files behind.

## Report Format

Please report:

- Pipeline table
- Sidecar storage table
- Loader counts
- Build/dist check
- Transient smoke result
- Regressions, or `none`

Kimi should remain read-only for this pass.
