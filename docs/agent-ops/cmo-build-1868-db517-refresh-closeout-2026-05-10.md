# CMO Build 1868 / DB517 Refresh Closeout - 2026-05-10

## Status

APPROVED / ARCHIVED

## Target

```text
f7a696a Refresh CMO DB517 references
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-refresh-qa.md
```

Official source:

```text
https://forums.matrixgames.com/viewtopic.php?t=417070
```

## Kimi Verdict

```text
APPROVED - CMO Build 1868 / DB517 refresh holds.
Regression: none.
```

Kimi static checkpoints:

```text
32 / 32 PASS
```

## Purpose

Close the urgent CMO Build 1868 / DB517 local reference refresh before returning to Track B0.1 manual CMO `.lua` load-check work.

The upstream update is primarily a CMO public-beta bugfix update, but it also adds v517 database support. This closeout records that local UI references, template inspector data, generated DB assets, and CMO Lua dev scan outputs now point at DB517 where they represent the current local baseline.

## Refreshed Baseline

Local CMO install:

```text
C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations
```

Observed DB files:

```text
DB3K_517.db3
CWDB_517.db3
```

`cmo-lua-ui` current DB summary:

```text
DB3K: DB3K_517.db3
CWDB: CWDB_517.db3
Component entries: 101078
DB3K references: 72796
CWDB references: 28282
```

`cmo-lua-dev` scan:

```text
Forum latest seen: CMO v1.09 Build 1868 (Public Beta)
Latest DB3K: DB3K_517.db3
Latest CWDB: CWDB_517.db3
```

## Changed Surfaces

Tracked `cmo-lua-ui` files:

```text
README.md
handoff/to-kimi/CURRENT_TASK.md
handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-refresh-qa.md
public/cmo-dev-work/db_cache/db_index.lua
public/cmo-dev-work/manifest.json
public/cmo-dev-work/presets/quickbattle.lua
public/template-annotations.json
```

Local generated artifact, intentionally gitignored:

```text
public/cmo-db-assets-index.json
```

Local `cmo-lua-dev` refreshed artifacts:

```text
C:\Users\dlwls\.codex\cmo-lua-dev\db_cache\db_index.lua
C:\Users\dlwls\.codex\cmo-lua-dev\db_cache\component_index.lua
C:\Users\dlwls\.codex\cmo-lua-dev\presets\quickbattle.lua
C:\Users\dlwls\.codex\cmo-lua-dev\reference\API_v1.09_delta.md
C:\Users\dlwls\.codex\cmo-lua-dev\reference\source_paths.json
C:\Users\dlwls\.codex\cmo-lua-dev\tools\scan_cmo_sources.ps1
C:\Users\dlwls\.codex\cmo-lua-dev\scans\latest.md
C:\Users\dlwls\.codex\cmo-lua-dev\scans\scan_20260510_035047.json
```

## Verification

Codex pre-QA:

```text
npm run lint: PASS
npm run build: PASS
npm run smoke:ai-adapter: PASS
```

Kimi QA:

```text
git status --short --branch: clean main...origin/main, expected modified/untracked before commit
npm run lint: PASS
npm run build: PASS
npm run smoke:ai-adapter: PASS, no auth leakage
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

Generated DB asset index:

```text
Latest DB3K: DB3K_517.db3
Latest CWDB: CWDB_517.db3
Delta: +2 / ~0 / -0
```

## Preserved Boundaries

Unchanged:

- No `src/**` change.
- No `server/**` change.
- No backend endpoint.
- No CMO polling.
- No log tailing.
- No sidecar writer.
- No live read-back.
- No dependency or lockfile change.
- Manual prompt-copy fallback remains unchanged.
- Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.

## Notes

Historical references to DB516 remain valid where they document older snapshots or scenario samples, for example archived 2026-05-03 QA docs and old scenario sidecar sample records.

Current user-facing DB summary, Template Inspector quickbattle guidance, and dev-work manifest now use DB517.

## Next Gate

After DB517 closeout docs QA is archived, return to the previous Track B0.1 gate:

```text
User-approved disposable CMO scenario manual check.
```

The manual check subsequently found that `dofile([[...]])` is unavailable in the CMO Build 1868 console sandbox, while explicit `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` from the CMO Lua root succeeds.
