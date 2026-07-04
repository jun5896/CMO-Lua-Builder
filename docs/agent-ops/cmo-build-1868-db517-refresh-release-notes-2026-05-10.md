# CMO Build 1868 / DB517 Refresh Release Notes Draft - 2026-05-10

## Proposed Release

```text
release-2026-05-10-cmo-lua-builder-db517-refresh
```

Proposed title:

```text
CMO Lua Builder DB517 Reference Refresh
```

Status:

```text
Draft notes only. No release tag has been created yet.
```

## Summary

This maintenance release refreshes local CMO database references after the CMO v1.09 Build 1868 public beta added support for v517 databases.

The UI and local dev reference data now point at:

```text
DB3K_517.db3
CWDB_517.db3
```

It does not add new AI automation, backend endpoints, CMO polling, scenario writes, log tailing, or live read-back behavior.

## User-Facing Changes

- Template Inspector dev-work manifest now reports DB517 as the current local DB baseline.
- Quick Battle preset guidance now says its example DBIDs are DB3K_517 examples.
- README DB summary now reports `DB3K_517.db3`, `CWDB_517.db3`, and `101078` component entries.
- Local `cmo-lua-dev` scan reports `CMO v1.09 Build 1868 (Public Beta)`.

## Refreshed Local Artifacts

Generated or refreshed locally:

```text
public/cmo-db-assets-index.json
C:\Users\dlwls\.codex\cmo-lua-dev\db_cache\db_index.lua
C:\Users\dlwls\.codex\cmo-lua-dev\db_cache\component_index.lua
C:\Users\dlwls\.codex\cmo-lua-dev\scans\latest.md
C:\Users\dlwls\.codex\cmo-lua-dev\scans\scan_20260510_035047.json
```

Component index:

```text
Total entries: 101078
DB3K references: 72796
CWDB references: 28282
```

Generated DB asset index:

```text
Total DB files indexed: 103
Delta from previous local index: +2 / ~0 / -0
Added: DB3K_517.db3, CWDB_517.db3
```

## Verification

Pre-release verification already observed:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Observed result:

```text
lint: PASS
build: PASS
smoke:ai-adapter: PASS, no raw Bearer / Authorization / sk- leakage
```

Bundle baseline:

```text
Main JS: 377.99 kB
Main CSS: 59.14 kB
aiContextPruning: 8.56 kB
```

Template Inspector:

```text
51 / 51 resources annotated
0 missing
```

Kimi QA:

```text
APPROVED - CMO Build 1868 / DB517 refresh holds.
Static checkpoints: 32 / 32 PASS.
Regression: none.
```

## Unchanged Safety Boundaries

- No product `src/**` behavior change.
- No `server/**` change.
- No new backend endpoint.
- No CMO polling.
- No log tailing.
- No sidecar writer.
- No live CMO read-back.
- No dependency or lockfile change.
- Manual prompt-copy fallback remains available.
- Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.
- DB517 refresh does not prove CMO `.lua` scenario-folder auto-load.

## Release Checklist

Before creating the release tag:

- [ ] Docs closeout QA is approved and archived.
- [ ] `npm run verify:release` passes, or the current focused DB refresh pipeline is accepted as sufficient for this maintenance release.
- [ ] README current public release line is updated to the DB517 release tag if this becomes a public release.
- [ ] GitHub Release notes include the DB517 baseline and unchanged automation boundaries.
- [ ] B0.1 manual CMO load-check remains the next Track B gate after release closure.
