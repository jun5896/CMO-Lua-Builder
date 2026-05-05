# Batch QA Report - 2026-05-03

> **Date:** 2026-05-03
> **Auditor:** Kimi
> **Codex State:** Task 3C preparation + batch scenario processing

> **Codex reconciliation note (2026-05-03):** This report reflects the first
> batch test before later Codex fixes. The two `CMO internal loader did not
> return Scenario XML` failures are now resolved. The verified cause was not
> Korean paths or a generic decoder failure. CMO returned `<ContentScenario>`
> XML, which the extractor rejected, and duplicate file names also collided on
> sidecar/cache names during parallel extraction.

---

## 1. QA Pipeline Results

| Step | Command | Result | Notes |
|------|---------|--------|-------|
| DB Asset Audit | 
pm run audit:cmo-db | PASS | DB3K_516.db3, CWDB_516.db3. Delta: +0/~0/-0 |
| Scenario Audit | 
pm run audit:scenario-openability | PASS | 1935 total. Delta: +0/~0/-0 |
| Scenario Loader Verify | 
pm run verify:scenario-loader | PASS | Verdict: All classifiable. Issues: 0 |
| Lint | 
pm run lint | PASS | 0 errors |
| Build | 
pm run build | PASS | 699ms, JS 387KB, CSS 60.32KB |
| Smoke #10 | 
pm run smoke:ai-adapter | PASS | No leak |

---

## 2. Scenario Delta (Batch Impact)

| Metric | Previous | Current | Delta |
|--------|----------|---------|-------|
| Total .scen | 1935 | 1935 | 0 |
| readyWithInternalSidecar | 5 | **12** | **+7** |
| metadataOnlyNeedsDecoder | 1930 | **1923** | **-7** |
| readError | 0 | 0 | 0 |

### readyWithInternalSidecar (12)

1. I´m still standing
2. Iran Strike, 2020-2030
3. Iran Strike, 2020-2030 (duplicate root)
4. Operation Epic Fury: The First 24 Hours
5. Achilles Shield 2035
6. 800808
7. 231
8. 232
9. (3 additional from prior batch processing)

### readError

None.

---

## 3. Codex Batch Test Results

| Metric | Value |
|--------|-------|
| Command | 
pm run prepare:scenario-batch -- --all --limit 5 --concurrency 2 |
| Selected | 5 |
| Succeeded | 3 |
| Failed | 2 |

### Successful (3)

- 800808.scen
- 231.scen
- 232.scen

### Failed (2)

| # | Path | Failure Message | Classification |
|---|------|-----------------|----------------|
| 1 | C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴 더 1\9. Deja Vu.scen | CMO internal loader did not return Scenario XML. | **CMO decoder failure** (not tool code) |
| 2 | C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴 더 1\새 폴 더\Deja Vu, 1990.scen | CMO internal loader did not return Scenario XML. | **CMO decoder failure** (not tool code) |

### Failure Analysis

- **Original assessment:** CMO internal XML decoder appeared to fail.
- **Corrected root cause:** The decoder returned `<ContentScenario>` XML, but the extractor only accepted `<Scenario>`.
- **Additional corrected root cause:** duplicate file names could collide on sidecar slugs and `.scenario-extract-cache` paths during parallel runs.
- **Tool code status:** fixed by Codex.
- **Follow-up verification:** `npm run prepare:scenario-batch -- --match "9. Deja Vu" --concurrency 2` succeeded `2/2`.
- **Current default audit:** user editing folders are excluded, so the official/default index is `1899` total, `8` ready, `1891` metadata-only, `0` readError.

---

## 4. Build Alert

| Asset | Size | Threshold | Status |
|-------|------|-----------|--------|
| JS | 387.25 KB | 400 KB | OK |
| CSS | 60.32 KB | 60 KB | **Alert** (+0.32 KB) |

CSS remains 0.32 KB over threshold. JS increased by ~3 KB from prior run (384 → 387).

---

## 5. Commands Check

| Command | Available | Notes |
|---------|-----------|-------|
| 
pm run prepare:scenario -- <path> | Yes | Canonical single-scenario workflow |
| 
pm run prepare:scenario-batch -- ... | Yes | Batch workflow with --match, --all, --limit, --concurrency, --dry-run |
| 
pm run scan:scenario -- <path> | Yes | Individual step |
| 
pm run extract:scenario-xml -- <path> | Yes | Individual step |
| 
pm run summarize:scenario -- <path> | Yes | Individual step |
| 
pm run audit:scenario-openability | Yes | Batch audit |
| 
pm run verify:scenario-loader | Yes | Loader verification |

All commands functional.

---

## 6. Commit Classification Table

| Category | Files | Action |
|----------|-------|--------|
| **Source code** | src/**, server/**, 	ools/**, package.json, eslint.config.js, .gitignore | Commit |
| **Docs/contracts** | docs/**, AGENTS.md, README.md | Commit |
| **Generated sidecars** | public/scenario-scan-samples/*.summary.json, *.json, ixtures/** | Keep local / do not commit unless small |
| **Large raw XML** | public/scenario-scan-samples/*.scenario.xml (5-40 MB each) | **Exclude** unless explicitly approved |
| **Absolute paths** | scenario-openability-index.json (contains C:\Program Files...) | Review before commit |

---

## 7. Notes

- spawn EPERM not observed.
- Batch --dry-run flag available and recommended before full batch execution.
- --concurrency 2 is the safe default; do not increase without Codex approval.
- 2 failed scenarios remain metadataOnlyNeedsDecoder after batch failure.
