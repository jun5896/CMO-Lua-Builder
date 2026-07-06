# Kimi QA Directive - Template Inspector Annotation Batch 5

Status: ACTIVE

## Target

QA target commit:

```text
a80b9ea Add template inspector annotation batch 5
```

Planning commit:

```text
d99e45c Document template inspector batch 5 plan
```

Product/data change:

- `public/template-annotations.json`

Do not modify files and do not commit.

## Required Checks

Run:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits sandbox `spawn EPERM`, report it as an environment permission issue and rerun only if Codex/user grants spawn permission.

## JSON / Coverage Check

Run:

```powershell
@'
const fs=require('fs');
function readJson(path){return JSON.parse(fs.readFileSync(path,'utf8').replace(/^\uFEFF/,''));}
const data=readJson('public/template-annotations.json');
const manifest=readJson('public/cmo-dev-work/manifest.json');
const required=['event_unit_destroyed.tpl.lua','event_unit_damaged.tpl.lua','event_missions_toggle.tpl.lua','event_escalation.tpl.lua','weather_random.tpl.lua','event_dynamic_weather.tpl.lua'];
const fields=['title','summary','beginnerNotes','prerequisites','safePattern','aiHint','checks'];
for (const key of required) {
  if (!data.templates?.[key]) throw new Error(`missing: ${key}`);
  const absent=fields.filter((field)=>!(field in data.templates[key]));
  if (absent.length) throw new Error(`${key} missing fields: ${absent.join(', ')}`);
}
const total=(manifest.templates||[]).length + (manifest.presets||[]).length;
const annotated=Object.keys(data.templates||{}).length;
console.log(JSON.stringify({ annotated, total, missing: total-annotated, added: required.map((key)=>Boolean(data.templates[key])) }, null, 2));
'@ | node -
```

Expected:

```json
{ "annotated": 36, "total": 51, "missing": 15, "added": [true, true, true, true, true, true] }
```

## Static Checkpoints

Confirm:

1. Target commit changes only `public/template-annotations.json`.
2. JSON parses successfully.
3. Annotation coverage increased from `30 / 51` to `36 / 51`.
4. Missing count is `15` or lower.
5. Six new annotation keys all exist:
   - `event_unit_destroyed.tpl.lua`
   - `event_unit_damaged.tpl.lua`
   - `event_missions_toggle.tpl.lua`
   - `event_escalation.tpl.lua`
   - `weather_random.tpl.lua`
   - `event_dynamic_weather.tpl.lua`
6. All six new annotations include `title`, `summary`, `beginnerNotes`, `prerequisites`, `safePattern`, `aiHint`, and `checks`.
7. `event_unit_destroyed.tpl.lua` guidance requires real TargetFilter values, DBID/type IDs, Side names, and repeated scoring review.
8. `event_unit_damaged.tpl.lua` guidance requires real TargetFilter values, damage threshold review, and repeatable action review.
9. `event_missions_toggle.tpl.lua` guidance requires real Mission names, Side names, trigger options, and separate activate/deactivate lists.
10. `event_escalation.tpl.lua` guidance warns posture direction matters and requires real Side/posture/doctrine values.
11. `weather_random.tpl.lua` guidance requires bounded random weather ranges and discourages invented extreme values.
12. `event_dynamic_weather.tpl.lua` guidance requires explicit baseline/range values, RegularTime interval review, and CMO engine verification.
13. `src/**`, `server/**`, `tools/**`, `package.json`, and `package-lock.json` are unchanged by the target commit.
14. `npm run lint` passes.
15. `npm run build` passes and watch lines remain below Main JS `400 kB`, Main CSS `60 kB`, and `aiContextPruning` `9 kB`.
16. `npm run smoke:ai-adapter` passes with no raw `Bearer`, `Authorization`, or `sk-` leakage.
17. Parser, adapter, pruning, sidecar, prompt-copy, and Lua apply gates are unchanged.

## Expected Verdict

If all checkpoints pass:

```text
APPROVED - template inspector annotation batch 5 holds.
```
