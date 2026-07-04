# CMO Lua Load Check Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add B0.1 tooling that prepares a harmless disposable-scenario Lua load check without assuming CMO auto-load behavior.

**Architecture:** Add a small Node CLI that generates a fixed `AiAssist_B0LoadCheck.lua` probe, defaults to dry-run, and writes only when `--cmo-lua-root`, `--write`, and `--yes` are all provided. Add a fixture smoke to prove no default write, strict write gating, safe path handling, no overwrite by default, generated Lua content, and `ScenEdit_RunScript(...)` loader snippet output.

**Tech Stack:** Node ESM, `node:fs/promises`, `node:path`, existing npm script pattern, markdown handoff docs.

---

### Task 1: Contract Smoke First

**Files:**
- Create: `tools/verify-cmo-lua-load-check-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Write the failing contract smoke**

Create a smoke that imports `buildLuaLoadCheck`, `parseLoadCheckArgs`, and `runLuaLoadCheck` from `tools/prepare-cmo-lua-load-check.mjs`.

The smoke must verify:

- Default run is dry-run and writes no files.
- Generated file name is `AiAssist_B0LoadCheck.lua`.
- Generated Lua only prints a marker and does not call `ScenEdit_SetKeyValue`, file APIs, `os.*`, `io.*`, or `require`.
- Loader snippet uses `ScenEdit_RunScript('/AiAssist_B0/...')`.
- `--write --yes --cmo-lua-root <fixture>` writes exactly one file under `AiAssist_B0`.
- Re-running write without `--overwrite` fails.
- Missing `--yes` keeps write blocked.
- Unsafe file names are rejected.

- [ ] **Step 2: Add npm script**

Add:

```json
"smoke:cmo-lua-load-check": "node tools/verify-cmo-lua-load-check-contract.mjs"
```

- [ ] **Step 3: Run RED**

Run:

```powershell
npm run smoke:cmo-lua-load-check
```

Expected: FAIL because `tools/prepare-cmo-lua-load-check.mjs` does not exist yet.

### Task 2: Load Check CLI

**Files:**
- Create: `tools/prepare-cmo-lua-load-check.mjs`
- Modify: `package.json`

- [ ] **Step 1: Add CLI script**

Add:

```json
"probe:cmo-lua-load-check": "node tools/prepare-cmo-lua-load-check.mjs"
```

- [ ] **Step 2: Implement dry-run default**

Support:

```text
--cmo-lua-root <path>
--file-name <name>
--marker <text>
--write
--yes
--overwrite
--json
```

Default file name:

```text
AiAssist_B0LoadCheck.lua
```

- [ ] **Step 3: Implement write gate**

Only write when all are true:

```text
cmoLuaRoot provided
write === true
yes === true
fileName matches /^AiAssist_B0[A-Za-z0-9_-]*\.lua$/
```

No overwrite unless `--overwrite`.

- [ ] **Step 4: Implement safe report**

Report:

```text
targetFile
marker
mode: dry-run or write
loaderSnippet
manualSteps
```

- [ ] **Step 5: Run GREEN**

Run:

```powershell
npm run smoke:cmo-lua-load-check
```

Expected: PASS.

### Task 3: Docs and Handoff

**Files:**
- Create: `docs/agent-ops/cmo-lua-load-check-b0-1-2026-05-10.md`
- Modify: `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`
- Create: `handoff/to-kimi/2026-05-10-b0-1-cmo-lua-load-check-qa.md`

- [ ] **Step 1: Document B0.1 as preparation, not proof**

Record that B0.1 prepares the disposable check, but auto-load remains unproven until the user runs CMO manually.

- [ ] **Step 2: Open Kimi QA**

Ask Kimi to verify smoke, dry-run boundaries, write gating, no unsafe Lua, no backend endpoint, no source UI changes, and watch lines.

### Task 4: Verification and Commit

**Files:**
- All changed files

- [ ] **Step 1: Run targeted checks**

```powershell
npm run smoke:cmo-lua-load-check
npm run probe:cmo-lua-load-check -- --json
```

- [ ] **Step 2: Run standard checks**

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

- [ ] **Step 3: Commit and push**

```powershell
git add package.json tools/prepare-cmo-lua-load-check.mjs tools/verify-cmo-lua-load-check-contract.mjs docs/superpowers/plans/2026-05-10-cmo-lua-load-check.md docs/agent-ops/cmo-lua-load-check-b0-1-2026-05-10.md docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md handoff/to-kimi/2026-05-10-b0-1-cmo-lua-load-check-qa.md
git commit -m "Add B0.1 CMO Lua load check"
git push
```
