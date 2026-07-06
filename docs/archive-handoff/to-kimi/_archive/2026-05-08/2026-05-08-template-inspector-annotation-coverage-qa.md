# Kimi QA Directive - Template Inspector Annotation Coverage

Status: APPROVED / ARCHIVED

## Target

Verify the Template Inspector annotation coverage micro-slice.

Target commit:

```text
05fd836 Add core template inspector annotations
```

## Scope

Read-only QA for the static annotation JSON update.

Expected product file:

- `public/template-annotations.json`

The target commit should add user-facing guide annotations for:

- `doctrine_emcon.tpl.lua`
- `mission_strike.tpl.lua`
- `reference_point_add.tpl.lua`
- `unit_spawn.tpl.lua`

## Hard Boundaries

- Do not edit files.
- Do not commit.
- Do not create tags or GitHub releases.
- Do not change dependencies.
- Do not run sidecar prune/move commands.
- Do not run broad scenario extraction or mass decoding.

## Required Commands

Run:

```powershell
git status --short --branch
git show --stat --oneline 05fd836
git show --name-only --oneline 05fd836
npm run lint
npm run build
npm run smoke:ai-adapter
```

Also run this JSON/coverage check:

```powershell
node -e "const fs=require('fs'); const read=p=>fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''); const manifest=JSON.parse(read('public/cmo-dev-work/manifest.json')); const payload=JSON.parse(read('public/template-annotations.json')); const annotations=payload.templates||{}; const resources=[...(manifest.templates||[]),...(manifest.presets||[])]; const missing=resources.filter(r=>!annotations[r.file]); console.log(JSON.stringify({guideRules:(payload.guideRules||[]).length,total:resources.length,annotated:resources.length-missing.length,missing:missing.length,added:['doctrine_emcon.tpl.lua','mission_strike.tpl.lua','reference_point_add.tpl.lua','unit_spawn.tpl.lua'].map(k=>Boolean(annotations[k]))},null,2));"
```

If `smoke:ai-adapter` or `build` hits sandbox `spawn EPERM`, report it and rerun with approved permissions before treating it as a product regression.

## Static Checkpoints

1. Target commit changes only `public/template-annotations.json`.
2. JSON parses successfully.
3. Annotation coverage is `12 / 51` or better.
4. Missing annotation count is `39` or lower.
5. All four new annotation keys exist.
6. Each new annotation has `title`, `summary`, `beginnerNotes`, `prerequisites`, `safePattern`, `aiHint`, and `checks`.
7. `doctrine_emcon.tpl.lua` guidance preserves EMCON value no-guessing and CMO engine verification.
8. `mission_strike.tpl.lua` guidance warns about target disambiguation and `ScenEdit_AssignUnitAsTarget` verification.
9. `reference_point_add.tpl.lua` guidance warns against inventing coordinates.
10. `unit_spawn.tpl.lua` guidance preserves DBID / Loadout ID source checking.
11. No `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json` changes.
12. Main JS remains below `400 kB`.
13. Main CSS remains below `60 kB`.
14. `aiContextPruning` remains below `9 kB`.
15. AI adapter smoke reports no raw `Bearer`, `Authorization`, or `sk-` leakage.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - template inspector annotation coverage holds.
```

Report any blocker or drift explicitly.

## Kimi QA Result

Final verdict:

```text
APPROVED - template inspector annotation coverage holds.
```

Summary:

- Target commit: `05fd836 Add core template inspector annotations`.
- Scope: `public/template-annotations.json` only, 80 lines added.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- Bundle: Main JS `366.67 kB`, Main CSS `58.27 kB`, `aiContextPruning` `8.56 kB`.
- JSON coverage: `12 / 51` annotated resources, `39` missing, four new annotation keys present.
- Static checkpoints: 15 / 15 PASS.
- Regression: none.
