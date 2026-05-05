# Scenario Sidecar Cache Policy

## Purpose

`scenario-sidecars/` or the external sidecar root is a local, regenerable cache for CMO scenario summaries. The web UI uses these JSON sidecars to open compressed `.scen` files without loading large internal XML into the browser.

The original `.scen` files are not modified by this cache.

## Current Rule

- Keep files referenced by `scenario-openability-index.json`.
- Prefer the external root once it exists: `C:\Users\dlwls\.codex\cmo-scenario-sidecars`.
- Override the root with `CMO_SCENARIO_SIDECAR_ROOT` when a different drive is needed.
- Treat unreferenced files as orphan sidecars.
- Do not delete the active sidecar folder unless the user accepts losing automatic sidecar linking and relying on transient open or regeneration.
- Keep `.scenario-extract-cache/` temporary. It should remain empty after transient open or prepare jobs finish.

## Commands

Audit the sidecar cache:

```powershell
npm run audit:scenario-sidecars
```

Dry-run orphan cleanup:

```powershell
npm run prune:scenario-sidecars
```

Delete only orphan sidecars after reviewing the dry-run output:

```powershell
npm run prune:scenario-sidecars -- --yes
```

Delete only large XML sidecars that already have summary JSON:

```powershell
npm run prune:scenario-xml -- --yes
```

Preview moving the cache out of the project folder:

```powershell
npm run move:scenario-sidecars
```

Move the cache after reviewing the dry-run output:

```powershell
npm run move:scenario-sidecars -- --move --yes
```

## Safety Notes

- `audit:scenario-sidecars` never deletes files.
- `prune:scenario-sidecars` is dry-run by default.
- `--yes` deletes only orphan files not referenced by the current openability index.
- `move:scenario-sidecars` is dry-run by default. It refuses nested roots and conflicting files.
- Summary JSON is the primary browser sidecar. XML sidecars are optional and can be regenerated.
- If the sidecar cache is removed, `.scen` files can still be opened through transient decode when the local AI adapter server is running, but automatic library-wide matching will be slower and less complete until sidecars are regenerated.

## Migration Closeout - 2026-05-05

The active sidecar root is now the external cache:

```text
C:\Users\dlwls\.codex\cmo-scenario-sidecars
```

Expected local state:

- `C:\Users\dlwls\.codex\cmo-scenario-sidecars\scenario-openability-index.json` exists.
- `C:\Users\dlwls\.codex\cmo-lua-ui\scenario-sidecars` does not need to exist.
- `C:\Users\dlwls\.codex\cmo-lua-ui\public\scenario-scan-samples` should not exist after the migration.
- `C:\Users\dlwls\.codex\cmo-lua-ui\dist\scenario-scan-samples` should not exist after the migration.
- `.scenario-extract-cache/` should remain empty after transient-open or prepare jobs finish.

Current audit baseline:

- `audit:scenario-sidecars` root: `C:\Users\dlwls\.codex\cmo-scenario-sidecars`.
- Scenarios in index: `1899`.
- Sidecar files: `3823`.
- Total sidecar cache size: `3.06 GB`.
- Protected by index: `3799` files / `3.055 GB`.
- Orphans: `24` files / `5.6 MB`.
- `verify:scenario-loader`: `1857 ready`, `42 decoderFailed`, issues `0`.

Do not flag the missing project-local `scenario-sidecars/` folder as a migration failure if the external root and index exist. That absence is the desired no-duplication state.
