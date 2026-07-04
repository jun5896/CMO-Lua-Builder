# Kimi QA Directive - Template Inspector Annotation Batch 4

Status: ACTIVE

## Target

QA target commit:

```text
ac8949f Add template inspector annotation batch 4
```

Planning commit:

```text
f2a2254 Document template inspector batch 4 plan
```

Scope:

- Product/data change: `public/template-annotations.json`
- Planning docs: `docs/superpowers/specs/2026-05-09-template-inspector-batch-4-design.md`
- Planning docs: `docs/superpowers/plans/2026-05-09-template-inspector-batch-4.md`

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
const required=['mission_support.tpl.lua','mission_cargo.tpl.lua','mission_ferry.tpl.lua','mission_mine.tpl.lua','kvstore_set.tpl.lua','event_kv_flag.tpl.lua'];
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

- `annotated`: `30`
- `total`: `51`
- `missing`: `21`
- all six `added` values: `true`

## Static Checkpoints

Confirm:

1. Target commit `ac8949f` adds the six Batch 4 annotations.
2. `public/template-annotations.json` parses as valid JSON.
3. Coverage increases from `24 / 51` to `30 / 51`.
4. `mission_support.tpl.lua` requires real Side names and CMO-created support area RP names.
5. `mission_cargo.tpl.lua` requires real pickup/dropoff RP names and cargo item DBID/GUID sources.
6. `mission_ferry.tpl.lua` requires embarkation/destination RP names and warns about one-way direction.
7. `mission_mine.tpl.lua` requires real minefield RP area names and verified density/mine count.
8. `kvstore_set.tpl.lua` explains explicit KeyValue key naming and collision risk.
9. `event_kv_flag.tpl.lua` explains one-shot guard semantics, repeatable event behavior, and retry risk.
10. All six annotations include `title`, `summary`, `beginnerNotes`, `prerequisites`, `safePattern`, `aiHint`, and `checks`.
11. No `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json` product-code drift in target commit.
12. `npm run lint` PASS.
13. `npm run build` PASS with watch lines under limits.
14. `npm run smoke:ai-adapter` PASS with no raw `Bearer`, `Authorization`, or `sk-` leakage.

## Regression Watch

- Do not treat CMO engine verification notes as proof of engine-tested behavior.
- Do not accept invented Side, Mission, RP, cargo DBID/GUID, KeyValue key, or trigger option values in guidance.
- Confirm annotations remain static public data and do not inflate React source chunks.

## Expected Verdict

If all checkpoints pass:

```text
APPROVED - template inspector annotation batch 4 holds.
```
