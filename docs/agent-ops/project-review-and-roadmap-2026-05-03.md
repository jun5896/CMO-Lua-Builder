# CMO Lua UI Project Review & Roadmap

> **Date:** 2026-05-03
> **Reviewer:** Kimi
> **Scope:** Full project retrospective after Codex Task 3 completion

---

## 1. Current State Summary

### 1.1 Git Hygiene

| Metric | Status |
|--------|--------|
| Commits on main | 3 (Initial + 2 docs) |
| Uncommitted changes | +2,592 / -1,281 lines across 23 files |
| Risk | **High** — all Codex UI integration work is uncommitted |

**Recommendation:** Codex should commit the current working tree before starting the next feature phase. Kimi can help split the changes into logical commits (UI, adapter, docs, tools).

### 1.2 Source Structure (src/)

| File | Size | Lines | Concern |
|------|------|-------|---------|
| LuaAssistant.jsx | 161 KB | ~3,930 | **Monolith** — mixes UI, state, AI prompt assembly, temp-session I/O, syntax highlighting |
| App.jsx | 28 KB | ~761 | **Overloaded** — tab routing, theme, fonts, localStorage, resize, settings forms |
| index.css | 79 KB | — | Single global stylesheet; maintenance risk |
| TemplateLibrary.jsx | 20 KB | ~490 | Acceptable |
| PresetGuide.jsx | 21 KB | ~520 | Acceptable |
| iAdapterClient.js | 5.5 KB | ~185 | Clean, well-structured |

**Structural Risk:** LuaAssistant.jsx at 161 KB is unmaintainable. A single file change triggers rebuild of the entire component tree and complicates code review.

### 1.3 Backend (server/)

| File | Size | Purpose |
|------|------|---------|
| i-provider-adapter.mjs | 12.5 KB | HTTP proxy + settings management |
| providers.mjs | 6.1 KB | Provider implementations |
| erify-upstream-redaction.mjs | 6.5 KB | Smoke harness |

**Security Posture:** Good. Multiple layers of redaction (wrapUpstreamResponse, deepScrubSecrets), local-only bind (127.0.0.1), restricted CORS, in-memory settings.

### 1.4 Tools (	ools/)

| File | Size | Purpose |
|------|------|---------|
| summarize-cmo-scenario-xml.mjs | 24.6 KB | XML summarizer |
| parse-cmo-event-export.mjs | 28.6 KB | Event/Lua parser |
| scan-cmo-scenario-folder.mjs | 15.8 KB | Scenario scanner |
| udit-cmo-scenario-openability.mjs | 11.1 KB | Batch auditor |
| extract-cmo-scenario-xml.ps1 | 3.7 KB | CMO DLL decoder |
| Others | — | Sync, prepare, DB asset audit |

**Quality Issues:**
- Regex-based XML parsing (acknowledged as intentional, but fragile)
- Utility functions (decodeXml, slug, 
eadJsonIfExists) duplicated across files
- No shared 	ools/lib/ module

### 1.5 Documentation (docs/)

Reorganized into 5 subdirectories (agent-ops, contracts, references, user-guides, samples). Well-structured.

### 1.6 Test Coverage

| Metric | Status |
|--------|--------|
| Unit tests | **Zero** |
| Component tests | **Zero** |
| Integration tests | **Zero** |
| Smoke tests | 1 (erify-upstream-redaction.mjs) |
| Test runner | **None** (no Jest, Vitest, node:test) |

---

## 2. Critical Issues (Red)

### 2.1 Uncommitted Work
All Codex UI integration (Task 3) is in the working tree but not committed. A single accidental git reset or disk issue would lose everything.

**Action:** Commit immediately, split into:
1. eat: add AI adapter backend (server/
2. eat: integrate AI adapter into UI (src/lib/aiAdapterClient, App.jsx, LuaAssistant.jsx)
3. eat: add scenario audit and extract tools
4. docs: reorganize documentation structure

### 2.2 LuaAssistant.jsx Monolith
At 161 KB / 3,930 lines, this file violates every React best practice:
- Impossible to unit test
- High regression risk on any edit
- Blocks multiple developers from working on different features simultaneously
- Likely contributing to the 376 KB JS bundle

**Action:** Split into:
- hooks/useAiAdapter.js — AI prompt state, adapter calls
- hooks/useTempSession.js — temp-session I/O, OPFS fallback
- components/LuaAssistant/ sub-directory:
  - EditorPanel.jsx
  - AiOutputPanel.jsx
  - ContextPanel.jsx
  - index.jsx (thin wrapper)

### 2.3 Zero Test Coverage
No automated tests for:
- Complex regex XML parsers (summarize, parse, scan)
- AI adapter response normalization
- UI component rendering
- Security redaction logic

**Action:** Add Vitest (fast, Vite-native) and write initial unit tests for:
- extractAssistantText() (all provider shapes)
- classifyError() (all 7 error codes)
- parseCmoEventExport() (mini fixture smoke)
- summarizeScenarioXml() (mini fixture smoke)

---

## 3. Medium Issues (Yellow)

### 3.1 App.jsx Overload
761 lines handling tabs, themes, fonts, localStorage, resize, settings.

**Action:** Extract:
- components/SettingsPanel.jsx — AI settings form
- hooks/useTheme.js — theme/font/localStorage persistence
- hooks/useWorkspaceLayout.js — pane width, resize

### 3.2 index.css Monolith
79 KB global CSS. Risk of unused styles and specificity wars.

**Action:** Migrate to CSS Modules or at least split into:
- styles/base.css
- styles/components.css
- styles/ai-adapter.css

### 3.3 Duplicated Tool Utilities
decodeXml, getTag, slug, 
eadJsonIfExists repeated in 3+ files.

**Action:** Create 	ools/lib/common.mjs and refactor tools to import shared utilities.

### 3.4 dist/ Bloat
cmo-installed-lua/examples/ mirrors hundreds of CMO files into the build output.

**Action:** Verify if these are needed at runtime. If not, add to .gitignore or Vite publicDir exclusions.

---

## 4. Recommendations by Priority

### Immediate (This Week)

1. **Git commit** the current working tree (Kimi can stage and draft messages)
2. **Add Vitest** + 4-5 core unit tests (adapter client, parsers)
3. **Create 	ools/lib/common.mjs** and deduplicate utilities

### Short-term (Next 2 Weeks)

4. **Split LuaAssistant.jsx** into hooks + sub-components (Codex-led, Kimi reviews)
5. **Split App.jsx** settings/workspace logic (Codex-led)
6. **Add parser unit tests** for all 3 XML tools against ixtures/cmo-scenario-mini.xml
7. **Add component smoke tests** for TemplateLibrary and PresetGuide

### Medium-term (Next Month)

8. **CSS modularization** (CSS Modules or split files)
9. **Integration test** for full AI adapter flow (mock provider → adapter → UI)
10. **Scenario stress tests** — automate scan/extract/summarize for top 20 largest scenarios
11. **TypeScript migration** feasibility study (optional, high effort)

---

## 5. Alternative Approaches

### Option A: Conservative (Minimal Risk)
- Keep current structure
- Only add tests for new code going forward
- Refactor LuaAssistant.jsx incrementally as features are added
- **Pros:** No regression risk, fast feature delivery
- **Cons:** Technical debt accumulates; 161 KB file grows larger

### Option B: Aggressive (Maximum Cleanup)
- Immediately split LuaAssistant.jsx and App.jsx
- Full test coverage for all parsers
- CSS Modules migration
- **Pros:** Clean codebase, parallel development enabled
- **Cons:** High regression risk; 1-2 weeks of pure refactoring with no user-visible progress

### Option C: Balanced (Recommended)
- **Week 1:** Kimi adds Vitest + tests for iAdapterClient.js and parsers; extracts 	ools/lib/common.mjs
- **Week 2:** Codex splits App.jsx settings panel (small, safe)
- **Week 3:** Codex splits LuaAssistant.jsx into hooks + sub-components (with test guardrails)
- **Week 4:** CSS split + integration tests
- **Pros:** Steady progress, tests catch regressions, manageable risk
- **Cons:** Requires 4 weeks of focused engineering before next major feature

---

## 6. Kimi Recommended Next Actions

1. **Run git add + git commit** for the current working tree (with Codex approval)
2. **Install Vitest:** 
pm install -D vitest @vitest/ui
3. **Write first 5 unit tests:**
   - src/lib/aiAdapterClient.test.js — extractAssistantText (OpenAI, Ollama, error shapes)
   - 	ools/lib/common.test.js — slug, decodeXml
   - 	ools/parse-cmo-event-export.test.js — mini fixture round-trip
4. **Extract 	ools/lib/common.mjs** from duplicated code
5. **Update README.md** path references and add test instructions

---

## Appendix: Bundle Analysis

| Asset | Size | Gzipped | Trend |
|-------|------|---------|-------|
| JS | 376.98 KB | 114.31 KB | ↑ from 362 KB (+4%) after Task 3 UI |
| CSS | 57.13 KB | 11.33 KB | ↑ from 54 KB (+6%) after Task 3 UI |
| Build time | ~525 ms | — | Stable |

**Alert threshold:** JS > 400 KB triggers investigation; CSS > 60 KB triggers investigation.
