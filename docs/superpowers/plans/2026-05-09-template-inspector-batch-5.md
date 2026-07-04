# Template Inspector Annotation Batch 5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add six event / weather Template Inspector annotations without changing React, server, tool, package, or build logic.

**Architecture:** This is a static data-only update. `TemplateLibrary.jsx` already loads `public/template-annotations.json`, so the implementation only extends the `templates` map with six new entries matching the existing annotation schema.

**Tech Stack:** JSON, Vite build, existing npm scripts, inline Node validation.

---

### Task 1: Prove Batch 5 Is Currently Missing

**Files:**
- Read: `public/template-annotations.json`

- [ ] **Step 1: Run the failing coverage check**

```powershell
@'
const fs=require('fs');
const data=JSON.parse(fs.readFileSync('public/template-annotations.json','utf8'));
const required=['event_unit_destroyed.tpl.lua','event_unit_damaged.tpl.lua','event_missions_toggle.tpl.lua','event_escalation.tpl.lua','weather_random.tpl.lua','event_dynamic_weather.tpl.lua'];
const missing=required.filter((key)=>!data.templates?.[key]);
if (missing.length) {
  console.error(`missing batch5 annotations: ${missing.join(', ')}`);
  process.exit(1);
}
console.log('batch5 annotations present');
'@ | node -
```

Expected: FAIL with the six missing keys listed.

### Task 2: Add Batch 5 Annotations

**Files:**
- Modify: `public/template-annotations.json`

- [ ] **Step 1: Add six annotation objects**

Insert the six new keys before the closing `templates` object brace:

- `event_unit_destroyed.tpl.lua`: explain UnitDestroyed scoring, target filters, DBIDs, target type IDs, and repeatable score risk.
- `event_unit_damaged.tpl.lua`: explain UnitDamaged thresholds, target filters, optional Lua action, and repeatable damage events.
- `event_missions_toggle.tpl.lua`: explain event trigger options, mission activation/deactivation lists, and real Mission names.
- `event_escalation.tpl.lua`: explain posture/doctrine escalation, real Side names, posture direction, and doctrine field checks.
- `weather_random.tpl.lua`: explain random weather ranges, rain/sea/cloud values, and safe bounds.
- `event_dynamic_weather.tpl.lua`: explain recurring weather drift, baseline/range values, clamping, and RegularTime trigger interval.

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
const required=['event_unit_destroyed.tpl.lua','event_unit_damaged.tpl.lua','event_missions_toggle.tpl.lua','event_escalation.tpl.lua','weather_random.tpl.lua','event_dynamic_weather.tpl.lua'];
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

Expected: PASS with `annotated` at least `36`, `total` `51`, `missing` `15`, and all `added` values `true`.

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
- Create: `handoff/to-kimi/2026-05-09-template-inspector-annotation-batch-5-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`

- [ ] **Step 1: Write the directive**

The directive must ask Kimi to verify:

- `public/template-annotations.json` only changed for the product/data commit.
- JSON parses and coverage increases to `36 / 51`.
- All six new keys exist and include the seven required fields.
- UnitDestroyed / UnitDamaged annotations require real target filters, DBIDs, damage thresholds, and Side names.
- Mission toggle / escalation annotations require real trigger options, Mission names, Side names, posture values, and doctrine fields.
- Weather annotations require explicit safe ranges and CMO engine verification.
- `npm run lint`, `npm run build`, and `npm run smoke:ai-adapter` pass.
- Bundle watch lines remain below `400 kB`, `60 kB`, and `9 kB`.

- [ ] **Step 2: Update Kimi current task**

Mark the Batch 5 QA directive as the active Kimi QA item and keep Claude/Gemini in standby unless Codex later opens a focused review request.
