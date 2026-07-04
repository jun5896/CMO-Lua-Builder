# CMO Integration Probe Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Track B0 as a read-only CMO environment probe that reports local integration capabilities before any in-game automation is implemented.

**Architecture:** Add a small Node CLI under `tools/` with exported pure helpers so a fixture-based smoke can verify behavior without depending on a real CMO install. Keep the probe dry-run only: it checks root existence, write permission via `fs.access`, log file patterns, and explicit Lua auto-load uncertainty, but does not write files or touch CMO state.

**Tech Stack:** Node ESM, `node:fs/promises`, `node:path`, existing `package.json` npm scripts, docs/handoff markdown.

---

### Task 1: Contract Smoke First

**Files:**
- Create: `tools/verify-cmo-integration-probe-contract.mjs`
- Modify: `package.json`

- [ ] **Step 1: Write a failing contract smoke**

Create a fixture-based smoke that imports `runCmoIntegrationProbe`, `formatProbeReport`, and `parseProbeArgs` from `tools/probe-cmo-integration.mjs`. The test should create temporary CMO-like roots, verify PASS/WARN capability rows, verify no probe files are written, verify `LuaHistory_*` and `ExceptionLog_*` patterns, verify manual Lua auto-load status, and verify argument parsing.

- [ ] **Step 2: Add npm script**

Add:

```json
"smoke:cmo-integration-probe": "node tools/verify-cmo-integration-probe-contract.mjs"
```

- [ ] **Step 3: Run RED**

Run:

```powershell
npm run smoke:cmo-integration-probe
```

Expected: FAIL because `tools/probe-cmo-integration.mjs` does not exist yet.

### Task 2: Probe CLI

**Files:**
- Create: `tools/probe-cmo-integration.mjs`

- [ ] **Step 1: Implement options and argument parsing**

Support:

```text
--cmo-root <path>
--scenarios-root <path>
--logs-root <path>
--scenario-folder <path>
--json
--strict
```

Environment fallbacks:

```text
CMO_ROOT
CMO_SCENARIOS_ROOT
CMO_LOGS_ROOT
```

- [ ] **Step 2: Implement dry-run capability checks**

Report:

```text
cmoRoot
scenariosRoot
logsRoot
scenarioFolder
scenarioWriteAccess
exceptionLogPattern
luaHistoryPattern
luaAutoLoad
safePathPrefixes
```

The probe must never create, modify, or delete files.

- [ ] **Step 3: Implement text and JSON output**

Text output should be readable in PowerShell and include the follow-up fact that `.lua` scenario-folder auto-load remains unproven, `dofile(...)` is unavailable in the CMO Build 1868 console sandbox, and Track B2 should use explicit `ScenEdit_RunScript(...)` from the CMO Lua root.

- [ ] **Step 4: Run GREEN**

Run:

```powershell
npm run smoke:cmo-integration-probe
```

Expected: PASS.

### Task 3: Docs and Handoff

**Files:**
- Modify: `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- Modify: `handoff/to-kimi/CURRENT_TASK.md`
- Modify: `handoff/to-claude/CURRENT_TASK.md`
- Modify: `handoff/to-gemini/CURRENT_TASK.md`
- Create: `handoff/to-kimi/2026-05-09-b0-cmo-integration-probe-qa.md`

- [ ] **Step 1: Record B0 active state**

Document that B0 is a dry-run probe only and does not add backend endpoints, scenario writes, log tailing, live read-back, or in-game mutation.

- [ ] **Step 2: Open Kimi QA directive**

Ask Kimi to verify script scope, dry-run boundaries, fixture smoke, no package lock drift, no product source changes, and watch lines.

### Task 4: Verification and Commit

**Files:**
- All changed files

- [ ] **Step 1: Run targeted smoke**

```powershell
npm run smoke:cmo-integration-probe
```

- [ ] **Step 2: Run standard checks**

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

- [ ] **Step 3: Commit and push**

```powershell
git add package.json tools/probe-cmo-integration.mjs tools/verify-cmo-integration-probe-contract.mjs docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md handoff/to-kimi/CURRENT_TASK.md handoff/to-claude/CURRENT_TASK.md handoff/to-gemini/CURRENT_TASK.md handoff/to-kimi/2026-05-09-b0-cmo-integration-probe-qa.md docs/superpowers/plans/2026-05-09-cmo-integration-probe.md
git commit -m "Add B0 CMO integration probe"
git push
```

Expected: clean tree and active Kimi QA directive for B0.
