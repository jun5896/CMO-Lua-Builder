# Kimi QA Directive - Template Inspector Annotation Batch 3

Status: ACTIVE

## Target

QA target commit:

```text
4d7208a Add template inspector annotation batch 3
```

Planning commit:

```text
031ad02 Document template inspector batch 3 plan
```

Scope:

- Product/data change: `public/template-annotations.json`
- Planning docs: `docs/superpowers/specs/2026-05-09-template-inspector-batch-3-design.md`
- Planning docs: `docs/superpowers/plans/2026-05-09-template-inspector-batch-3.md`

Do not modify files and do not commit.

## Pipeline

Run:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` fails with sandbox `spawn EPERM`, rerun with approved process-spawn permission and report both the sandbox failure and approved rerun result.

## Expected Bundle Watch Lines

- Main JS: about `366.67 kB`, must remain `< 400 kB`
- Main CSS: about `58.27 kB`, must remain `< 60 kB`
- `aiContextPruning`: about `8.56 kB`, must remain `< 9 kB`

## JSON / Coverage Check

Run or equivalent:

```powershell
@'
const fs=require('fs');
function readJson(path){return JSON.parse(fs.readFileSync(path,'utf8').replace(/^\uFEFF/,''));}
const data=readJson('public/template-annotations.json');
const manifest=readJson('public/cmo-dev-work/manifest.json');
const required=['side_posture.tpl.lua','event_contact_emcon.tpl.lua','unit_spawn_random.tpl.lua','event_teleport.tpl.lua','event_dbid_score.tpl.lua','event_cargo_drop.tpl.lua'];
const fields=['title','summary','beginnerNotes','prerequisites','safePattern','aiHint','checks'];
const missing=required.filter((key)=>!data.templates?.[key]);
if (missing.length) throw new Error(`missing: ${missing.join(', ')}`);
for (const key of required) {
  const entry=data.templates[key];
  const absent=fields.filter((field)=>!(field in entry));
  if (absent.length) throw new Error(`${key} missing fields: ${absent.join(', ')}`);
  if (!entry.beginnerNotes.length || !entry.prerequisites.length || !entry.checks.length) {
    throw new Error(`${key} requires non-empty note arrays`);
  }
}
const total=(manifest.templates||[]).length + (manifest.presets||[]).length;
const annotated=Object.keys(data.templates||{}).length;
console.log(JSON.stringify({ annotated, total, missing: total-annotated, added: required.map((key)=>Boolean(data.templates[key])) }, null, 2));
'@ | node -
```

Expected:

- `annotated`: `24`
- `total`: `51`
- `missing`: `27`
- all six `added` values: `true`

## Static Checkpoints

Confirm:

1. Target commit `4d7208a` adds the six Batch 3 annotations.
2. `public/template-annotations.json` parses as valid JSON.
3. Coverage increases from `18 / 51` to `24 / 51`.
4. `side_posture.tpl.lua` warns that Side posture is directional and must use real Side/posture values.
5. `event_contact_emcon.tpl.lua` warns not to invent contact type/posture or EMCON values.
6. `unit_spawn_random.tpl.lua` warns not to invent coordinate ranges, DBID, or Loadout ID.
7. `event_teleport.tpl.lua` requires GUIDs and map-confirmed coordinate bounds.
8. `event_dbid_score.tpl.lua` requires Database Viewer sourced DBIDs and unit type checks.
9. `event_cargo_drop.tpl.lua` requires existing RP names and GUID-first unit lookup.
10. All six annotations include `title`, `summary`, `beginnerNotes`, `prerequisites`, `safePattern`, `aiHint`, and `checks`.
11. No `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json` product-code drift in target commit.
12. `npm run lint` PASS.
13. `npm run build` PASS with watch lines under limits.
14. `npm run smoke:ai-adapter` PASS with no raw `Bearer`, `Authorization`, or `sk-` leakage.

## Regression Watch

- Do not treat CMO engine verification notes as proof of engine-tested behavior.
- Do not accept invented Side, RP, GUID, DBID, Loadout, posture, or EMCON values in guidance.
- Confirm annotations remain static public data and do not inflate React source chunks.

## Expected Verdict

If all checkpoints pass:

```text
APPROVED - template inspector annotation batch 3 holds.
```
