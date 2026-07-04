# Template Inspector Annotation Batch 6 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add six complex-event and import Template Inspector annotations without changing React, server, tool, package, or build logic.

**Architecture:** This is a static data-only update. `TemplateLibrary.jsx` already loads `public/template-annotations.json`, so the implementation only extends the `templates` map with six new entries matching the existing annotation schema.

**Tech Stack:** JSON, Vite build, existing npm scripts, inline Node validation.

---

### Task 1: Prove Batch 6 Is Currently Missing

**Files:**
- Read: `public/template-annotations.json`

- [ ] **Step 1: Run the failing coverage check**

```powershell
@'
const fs=require('fs');
const data=JSON.parse(fs.readFileSync('public/template-annotations.json','utf8'));
const required=['event_complex.tpl.lua','event_split_merge.tpl.lua','event_ambient_traffic.tpl.lua','event_scen_loaded.tpl.lua','event_unit_x.tpl.lua','inst_import.tpl.lua'];
const missing=required.filter((key)=>!data.templates?.[key]);
if (missing.length) {
  console.error(`missing batch6 annotations: ${missing.join(', ')}`);
  process.exit(1);
}
console.log('batch6 annotations present');
'@ | node -
```

Expected: FAIL with the six missing keys listed.

### Task 2: Add Batch 6 Annotations

**Files:**
- Modify: `public/template-annotations.json`

- [ ] **Step 1: Add six annotation objects**

Insert the six new keys before the closing `templates` object brace:

- `event_complex.tpl.lua`: explain multi-trigger/condition/action wiring, LuaScript side-file behavior, and real Event Editor option names.
- `event_split_merge.tpl.lua`: explain GUID-first unit lookup, split/merge irreversibility risk, selected-unit behavior, and single-use testing.
- `event_ambient_traffic.tpl.lua`: explain Civilian ship DBID list, coordinate bounds, water-only spawn filter, and spawn-count limits.
- `event_scen_loaded.tpl.lua`: explain scenario-load startup behavior, idempotence, KeyValue guards, and no destructive boot actions.
- `event_unit_x.tpl.lua`: explain `ScenEdit_UnitX()` context, trigger-specific payload assumptions, and nil guard.
- `inst_import.tpl.lua`: explain `.inst` filename/source, Side import target, DB compatibility, and path trust.

Each object must include `title`, `summary`, `beginnerNotes`, `prerequisites`, `safePattern`, `aiHint`, and `checks`.

### Task 3: Validate JSON Shape and Coverage

**Files:**
- Read: `public/template-annotations.json`
- Read: `public/cmo-dev-work/manifest.json`

- [ ] **Step 1: Run the passing coverage check**

```powershell
@'
const fs=require('fs');
function readJson(path){return JSON.parse(fs.readFileSync(path,'utf8').replace(/^\uFEFF/,''));}
const data=readJson('public/template-annotations.json');
const manifest=readJson('public/cmo-dev-work/manifest.json');
const required=['event_complex.tpl.lua','event_split_merge.tpl.lua','event_ambient_traffic.tpl.lua','event_scen_loaded.tpl.lua','event_unit_x.tpl.lua','inst_import.tpl.lua'];
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

Expected: PASS with `annotated` at least `42`, `total` `51`, `missing` `9`, and all `added` values `true`.

### Task 4: Run Product Verification

**Files:**
- No source edits.

- [ ] **Step 1: Run lint**

```powershell
npm run lint
```

Expected: PASS.

- [ ] **Step 2: Run build**

```powershell
npm run build
```

Expected: PASS. Main JS under `400 kB`, Main CSS under `60 kB`, `aiContextPruning` under `9 kB`.

- [ ] **Step 3: Run AI adapter smoke**

```powershell
npm run smoke:ai-adapter
```

Expected: PASS with no raw `Bearer`, `Authorization`, or `sk-` leakage. If sandbox `spawn EPERM` appears, rerun with approved process-spawn permissions.

### Task 5: Create Kimi QA Directive

**Files:**
- Create: `handoff/to-kimi/2026-05-09-template-inspector-annotation-batch-6-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`

- [ ] **Step 1: Write the directive**

The directive must ask Kimi to verify:

- `public/template-annotations.json` only changed for the product/data commit.
- JSON parses and coverage increases to `42 / 51`.
- All six new keys exist and include the seven required fields.
- Complex event annotations require real trigger, condition, action, and LuaScript option names.
- Split/merge annotations require GUID-first lookup, selected-unit caution, and CMO engine testing.
- Ambient traffic annotations require real Civilian ship DBIDs, coordinate bounds, water filter, and spawn-count limits.
- Scenario-loaded annotations require idempotent startup behavior and no destructive boot actions.
- UnitX annotations require trigger-specific context and nil guard handling.
- INST import annotations require trusted filenames, Side target, DB compatibility, and CMO engine validation.
- `npm run lint`, `npm run build`, and `npm run smoke:ai-adapter` pass.
- Bundle watch lines remain below `400 kB`, `60 kB`, and `9 kB`.

- [ ] **Step 2: Update Kimi current task**

Mark the Batch 6 QA directive as the active Kimi QA item and keep Claude/Gemini in standby unless Codex later opens a focused review request.
