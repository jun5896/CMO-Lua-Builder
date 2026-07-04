# Template Inspector Annotation Batch 7 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete Template Inspector annotation coverage at `51 / 51` without changing React, server, tool, package, or build logic.

**Architecture:** This is a static data-only update. `TemplateLibrary.jsx` already loads `public/template-annotations.json`, so the implementation only extends the `templates` map with nine new entries matching the existing annotation schema.

**Tech Stack:** JSON, Vite build, existing npm scripts, inline Node validation.

---

### Task 1: Prove Batch 7 Is Currently Missing

**Files:**
- Read: `public/template-annotations.json`

- [ ] **Step 1: Run the failing coverage check**

```powershell
@'
const fs=require('fs');
const data=JSON.parse(fs.readFileSync('public/template-annotations.json','utf8'));
const required=['event_random_start_weather.tpl.lua','loadout_scramble.tpl.lua','mission_generic.tpl.lua','advanced_ops.lua','airbase_scramble.lua','cap_patrol.lua','multi_file_pack.lua','quickbattle.lua','strike_alpha.lua'];
const missing=required.filter((key)=>!data.templates?.[key]);
if (missing.length) {
  console.error(`missing batch7 annotations: ${missing.join(', ')}`);
  process.exit(1);
}
console.log('batch7 annotations present');
'@ | node -
```

Expected: FAIL with the nine missing keys listed.

### Task 2: Add Batch 7 Annotations

**Files:**
- Modify: `public/template-annotations.json`

- [ ] **Step 1: Add nine annotation objects**

Insert the nine new keys before the closing `templates` object brace:

- `event_random_start_weather.tpl.lua`: explain one-shot RegularTime startup weather, KeyValue guard, bounded weather ranges, and player-side message target.
- `loadout_scramble.tpl.lua`: explain aircraft DBID / Loadout ID / host base source checks, optional mission assignment, and launch behavior.
- `mission_generic.tpl.lua`: explain generic mission kind/subtype fallback, real Side/Mission names, and mission-specific option gaps.
- `advanced_ops.lua`: explain demo preset assumptions across sides, RPs, units, IADS, CSAR, logistics, weather, traffic, and radio.
- `airbase_scramble.lua`: explain UnitDetected trigger values, interceptor DBID/loadout/base checks, and immediate launch caution.
- `cap_patrol.lua`: explain RP box, CAP aircraft DBID, patrol zone RP names, and one-third rule.
- `multi_file_pack.lua`: explain side-file output behavior, event/action naming, and external LuaScript path checks.
- `quickbattle.lua`: explain randomized force generation, DB3K_516 DBID assumptions, random coordinate boxes, and replay variability.
- `strike_alpha.lua`: explain bundled strike / KV / UnitX / DBID score / escalation / contact EMCON / scramble / weather / inst import assumptions.

Each object must include `title`, `summary`, `beginnerNotes`, `prerequisites`, `safePattern`, `aiHint`, and `checks`.

### Task 3: Validate JSON Shape and Complete Coverage

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
const required=['event_random_start_weather.tpl.lua','loadout_scramble.tpl.lua','mission_generic.tpl.lua','advanced_ops.lua','airbase_scramble.lua','cap_patrol.lua','multi_file_pack.lua','quickbattle.lua','strike_alpha.lua'];
const fields=['title','summary','beginnerNotes','prerequisites','safePattern','aiHint','checks'];
const resources=[...(manifest.templates||[]),...(manifest.presets||[])];
const missing=resources.filter((r)=>!data.templates?.[r.file]).map((r)=>r.file);
if (missing.length) throw new Error(`missing annotations: ${missing.join(', ')}`);
for (const key of required) {
  const entry=data.templates[key];
  const absent=fields.filter((field)=>!(field in entry));
  if (absent.length) throw new Error(`${key} missing fields: ${absent.join(', ')}`);
  if (!entry.beginnerNotes.length || !entry.prerequisites.length || !entry.checks.length) {
    throw new Error(`${key} requires non-empty note arrays`);
  }
}
const total=resources.length;
const annotated=Object.keys(data.templates||{}).length;
console.log(JSON.stringify({ annotated, total, missing: total-annotated, added: required.map((key)=>Boolean(data.templates[key])) }, null, 2));
'@ | node -
```

Expected: PASS with `annotated` `51`, `total` `51`, `missing` `0`, and all `added` values `true`.

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
- Create: `handoff/to-kimi/2026-05-09-template-inspector-annotation-batch-7-qa.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`

- [ ] **Step 1: Write the directive**

The directive must ask Kimi to verify:

- `public/template-annotations.json` only changed for the product/data commit.
- JSON parses and coverage reaches `51 / 51`.
- All nine new keys exist and include the seven required fields.
- Startup weather, loadout scramble, and generic mission annotations require real source values and CMO engine testing.
- Preset annotations clearly warn that demo DBIDs, Side names, RP names, coordinates, event options, and `.inst` filenames are examples.
- `npm run lint`, `npm run build`, and `npm run smoke:ai-adapter` pass.
- Bundle watch lines remain below `400 kB`, `60 kB`, and `9 kB`.

- [ ] **Step 2: Update Kimi current task**

Mark the Batch 7 QA directive as the active Kimi QA item and keep Claude/Gemini in standby unless Codex later opens a focused review request.
