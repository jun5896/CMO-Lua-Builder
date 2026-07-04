# Kimi QA Directive - Template Inspector Annotation Batch 2

Status: APPROVED / ARCHIVED

## Target

Verify the second Template Inspector annotation coverage micro-slice.

Target commit:

```text
246c175 Add event template inspector annotations
```

## Scope

Read-only QA for the static annotation JSON update.

Expected product file:

- `public/template-annotations.json`

The target commit should add user-facing guide annotations for:

- `event_simple.tpl.lua`
- `event_regular_time.tpl.lua`
- `event_unit_detected.tpl.lua`
- `event_unit_enters_area.tpl.lua`
- `loadout_set.tpl.lua`
- `zone_add.tpl.lua`

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
git show --stat --oneline 246c175
git show --name-only --oneline 246c175
npm run lint
npm run build
npm run smoke:ai-adapter
```

Also run this JSON/coverage check:

```powershell
node -e "const fs=require('fs'); const read=p=>fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''); const manifest=JSON.parse(read('public/cmo-dev-work/manifest.json')); const payload=JSON.parse(read('public/template-annotations.json')); const annotations=payload.templates||{}; const resources=[...(manifest.templates||[]),...(manifest.presets||[])]; const missing=resources.filter(r=>!annotations[r.file]); console.log(JSON.stringify({guideRules:(payload.guideRules||[]).length,total:resources.length,annotated:resources.length-missing.length,missing:missing.length,added:['event_simple.tpl.lua','event_regular_time.tpl.lua','event_unit_detected.tpl.lua','event_unit_enters_area.tpl.lua','loadout_set.tpl.lua','zone_add.tpl.lua'].map(k=>Boolean(annotations[k]))},null,2));"
```

If `smoke:ai-adapter` or `build` hits sandbox `spawn EPERM`, report it and rerun with approved permissions before treating it as a product regression.

## Static Checkpoints

1. Target commit changes only `public/template-annotations.json`.
2. JSON parses successfully.
3. Annotation coverage is `18 / 51` or better.
4. Missing annotation count is `33` or lower.
5. All six new annotation keys exist.
6. Each new annotation has `title`, `summary`, `beginnerNotes`, `prerequisites`, `safePattern`, `aiHint`, and `checks`.
7. `event_simple.tpl.lua` guidance separates Trigger and LuaScript Action and preserves paste-ready / CMO engine verification.
8. `event_regular_time.tpl.lua` guidance warns about repeated execution and duplicate-action guards.
9. `event_unit_detected.tpl.lua` guidance warns about DetectorSideID, TargetFilter, TargetType, and MCL uncertainty.
10. `event_unit_enters_area.tpl.lua` guidance warns against inventing RP coordinates and requires user-provided RP names.
11. `loadout_set.tpl.lua` guidance preserves GUID preference and Loadout ID source checking.
12. `zone_add.tpl.lua` guidance distinguishes No-Nav vs Exclusion zones and requires RP names from CMO.
13. No `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json` changes.
14. Main JS remains below `400 kB`.
15. Main CSS remains below `60 kB`.
16. `aiContextPruning` remains below `9 kB`.
17. AI adapter smoke reports no raw `Bearer`, `Authorization`, or `sk-` leakage.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - template inspector annotation batch 2 holds.
```

Report any blocker or drift explicitly.

## Kimi QA Result

Final verdict:

```text
APPROVED - template inspector annotation batch 2 holds.
```

Summary:

- Target commit: `246c175 Add event template inspector annotations`.
- Scope: `public/template-annotations.json` only, 120 lines inserted.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- Bundle: Main JS `366.67 kB`, Main CSS `58.27 kB`, `aiContextPruning` `8.56 kB`.
- JSON coverage: `18 / 51` annotated resources, `33` missing, six new annotation keys present.
- Static checkpoints: 17 / 17 PASS.
- Regression: none.
