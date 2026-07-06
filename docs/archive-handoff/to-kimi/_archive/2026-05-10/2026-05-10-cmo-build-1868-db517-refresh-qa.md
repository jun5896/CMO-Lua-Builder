# Kimi QA Directive - CMO Build 1868 / DB517 Refresh

## Target

```text
CMO Build 1868 / DB517 local reference refresh
```

Target files and local artifacts:

```text
README.md
public/cmo-dev-work/db_cache/db_index.lua
public/cmo-dev-work/manifest.json
public/cmo-dev-work/presets/quickbattle.lua
public/template-annotations.json
public/cmo-db-assets-index.json (gitignored generated local artifact)

C:\Users\dlwls\.codex\cmo-lua-dev\db_cache\db_index.lua
C:\Users\dlwls\.codex\cmo-lua-dev\db_cache\component_index.lua
C:\Users\dlwls\.codex\cmo-lua-dev\presets\quickbattle.lua
C:\Users\dlwls\.codex\cmo-lua-dev\reference\API_v1.09_delta.md
C:\Users\dlwls\.codex\cmo-lua-dev\reference\source_paths.json
C:\Users\dlwls\.codex\cmo-lua-dev\tools\scan_cmo_sources.ps1
C:\Users\dlwls\.codex\cmo-lua-dev\scans\latest.md
C:\Users\dlwls\.codex\cmo-lua-dev\scans\scan_20260510_035047.json
```

## Scope

Verify that Codex reflected the urgent CMO Build 1868 public beta DB update locally without changing AI automation, sidecar behavior, backend endpoints, or Lua apply safety gates.

Official source:

```text
https://forums.matrixgames.com/viewtopic.php?t=417070
```

Expected upstream facts:

- Latest public beta observed by scanner: `CMO v1.09 Build 1868 (Public Beta)`.
- Release notes add support for v517 DBs.
- Local Steam install contains `DB3K_517.db3` and `CWDB_517.db3`.
- DB changelog URLs are recorded for `DB3K_517` and `CWDB_517`.

## Required Pipeline

Run from `C:\Users\dlwls\.codex\cmo-lua-ui`:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-adapter
```

Run static checks:

```powershell
node -e "const fs=require('fs'); const read=p=>fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''); const manifest=JSON.parse(read('public/cmo-dev-work/manifest.json')); const ann=JSON.parse(read('public/template-annotations.json')); const resources=[...(manifest.templates||[]),...(manifest.presets||[])]; const missing=resources.filter(r=>!ann.templates?.[r.file]); const dbIndex=read('public/cmo-dev-work/db_cache/db_index.lua'); console.log(JSON.stringify({manifestDb:manifest.db, sourceRoot:manifest.sourceRoot, resourceCount:resources.length, annotated:resources.length-missing.length, missing:missing.length, dbIndex517:dbIndex.includes('DB3K_517.db3')&&dbIndex.includes('CWDB_517.db3')},null,2)); if(missing.length||manifest.db.db3k!=='DB3K_517.db3'||manifest.db.cwdb!=='CWDB_517.db3'||manifest.db.componentEntries!==101078||!dbIndex.includes('DB3K_517.db3')||!dbIndex.includes('CWDB_517.db3')) process.exit(1);"
```

Optional local artifact check:

```powershell
node -e "const fs=require('fs'); const j=JSON.parse(fs.readFileSync('public/cmo-db-assets-index.json','utf8')); console.log(JSON.stringify({latestByFamily:{DB3K:j.latestByFamily.DB3K.name,CWDB:j.latestByFamily.CWDB.name},dbFileCount:j.dbFiles.length,delta:{addedCount:j.delta.addedCount,removedCount:j.delta.removedCount,changedCount:j.delta.changedCount}},null,2)); if(j.latestByFamily.DB3K.name!=='DB3K_517.db3'||j.latestByFamily.CWDB.name!=='CWDB_517.db3'||j.delta.addedCount!==2||j.delta.removedCount!==0||j.delta.changedCount!==0) process.exit(1);"
```

## Expected Codex Evidence

- `npm run audit:cmo-db` regenerated gitignored `public/cmo-db-assets-index.json`.
- `audit:cmo-db` reported `CWDB_517.db3`, `DB3K_517.db3`, and `Delta: +2 / ~0 / -0`.
- `tools/update_db_index.ps1` regenerated `cmo-lua-dev\db_cache\db_index.lua`.
- `tools/update_component_index.ps1` regenerated `cmo-lua-dev\db_cache\component_index.lua`.
- Component index entries: `101078`.
- Component index split: `DB3K 72796`, `CWDB 28282`.
- `tools/scan_cmo_sources.ps1` generated `scans\scan_20260510_035047.json` and refreshed `scans\latest.md`.
- Scan result: `Forum latest seen: CMO v1.09 Build 1868 (Public Beta)`.
- Scan result: `Latest DB3K: DB3K_517.db3`, `Latest CWDB: CWDB_517.db3`.
- Quick Battle example DBIDs were checked against DB3K_517 component index before updating user-facing wording.

## Static Checkpoints

1. `README.md` DB summary now says `DB3K_517.db3`, `CWDB_517.db3`, component entries `101078`.
2. `public/cmo-dev-work/manifest.json` uses source root `C:\Users\dlwls\.codex\cmo-lua-dev`.
3. `public/cmo-dev-work/manifest.json` has `db3k: DB3K_517.db3`.
4. `public/cmo-dev-work/manifest.json` has `cwdb: CWDB_517.db3`.
5. `public/cmo-dev-work/manifest.json` has `componentEntries: 101078`.
6. `public/cmo-dev-work/manifest.json` has `db3kReferences: 72796`.
7. `public/cmo-dev-work/manifest.json` has `cwdbReferences: 28282`.
8. `public/cmo-dev-work/db_cache/db_index.lua` latest DB fields are version `517`.
9. `public/cmo-dev-work/db_cache/db_index.lua` includes both `DB3K_517.db3` and `CWDB_517.db3` in `all` and `files`.
10. `public/template-annotations.json` still parses as JSON.
11. Template Inspector coverage remains `51 / 51`, `0 missing`.
12. `quickbattle.lua` annotation references `DB3K_517`, not `DB3K_516`.
13. `public/cmo-dev-work/presets/quickbattle.lua` comment references `DB3K_517`.
14. Korean comments in `quickbattle.lua` remain readable UTF-8.
15. `public/cmo-db-assets-index.json` generated local artifact latestByFamily points to `DB3K_517.db3` and `CWDB_517.db3`.
16. `public/cmo-db-assets-index.json` delta is `+2 / ~0 / -0`.
17. `cmo-lua-dev\reference\API_v1.09_delta.md` has a Build 1868 section dated 2026-05-09.
18. `cmo-lua-dev\reference\API_v1.09_delta.md` records v517 DB support and no identified new Lua API surface.
19. `cmo-lua-dev\reference\source_paths.json` records Build 1868 and DB517 changelog URLs.
20. `cmo-lua-dev\tools\scan_cmo_sources.ps1` includes the Build 1868 topic URL in `knownBuildUrls`.
21. `cmo-lua-dev\scans\latest.md` reports Build 1868 and DB517.
22. `cmo-lua-dev\scans\scan_20260510_035047.json` reports latest DB versions `517`.
23. No `src/**` changes.
24. No `server/**` changes.
25. No new backend endpoint, CMO polling, log tailing, sidecar writer, or live read-back behavior.
26. No dependency or lockfile change.
27. Manual prompt-copy fallback remains unaffected.
28. Lua apply remains gated by `aiParsedResponse.isPasteReady`.
29. Main JS remains < 400 kB.
30. Main CSS remains < 60 kB.
31. `aiContextPruning` remains < 9 kB.
32. AI adapter smoke reports no raw Bearer / Authorization / `sk-` leakage.

## Regression Watch

Report any of these as blockers:

- Any current DB summary still claiming DB3K/CWDB `516`.
- Template Inspector annotation coverage dropping below `51 / 51`.
- Quick Battle Korean comments becoming mojibake or invalid UTF-8.
- Any product source behavior change beyond public DB/reference data.
- Any backend endpoint, filesystem write automation, log tailing, or live read-back introduced.
- Any credential/storage persistence change.
- Main CSS crossing 60 kB.
