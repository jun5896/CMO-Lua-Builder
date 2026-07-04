# QA Pipeline Report - 2026-05-03

> **Date:** 2026-05-03
> **Auditor:** Kimi
> **Codex State:** Task 3C preparation complete

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
pm run build | PASS | 1.09s, JS 384KB, CSS 60.32KB |
| Smoke #10 | 
pm run smoke:ai-adapter | PASS | No leak |

---

## 2. Scenario Delta

| Metric | Previous | Current | Delta |
|--------|----------|---------|-------|
| Total .scen | 1935 | 1935 | 0 |
| readyWithInternalSidecar | 3 | 5 | +2 |
| metadataOnlyNeedsDecoder | 1932 | 1930 | -2 |
| plainXmlReadable | 0 | 0 | 0 |
| readError | 0 | 0 | 0 |

### readyWithInternalSidecar (5)

1. I´m still standing
2. Iran Strike, 2020-2030
3. Iran Strike, 2020-2030 (duplicate in different root)
4. Operation Epic Fury: The First 24 Hours
5. Achilles Shield 2035

### readError

None.

---

## 3. DB Delta

| DB | Version | Size | Modified |
|----|---------|------|----------|
| DB3K | DB3K_516.db3 | 60,805,120 bytes | 2026-03-20 |
| CWDB | CWDB_516.db3 | 27,049,984 bytes | 2026-03-20 |

Delta: +0 / ~0 / -0. No new DB versions detected.

---

## 4. Build Alert

| Asset | Size | Threshold | Status |
|-------|------|-----------|--------|
| JS | 384.03 KB | 400 KB | OK |
| CSS | 60.32 KB | 60 KB | **Alert** (+0.32 KB) |

CSS is 0.32 KB over the 60 KB alert threshold. Likely caused by new AI adapter settings UI styles in src/index.css.

---

## 5. Commands Check

| Command | Available | Uses prepare:scenario |
|---------|-----------|------------------------|
| 
pm run prepare:scenario -- <path> | Yes | Yes (orchestrates scan + extract + summarize) |
| 
pm run scan:scenario -- <path> | Yes | No (individual step) |
| 
pm run extract:scenario-xml -- <path> | Yes | No (individual step) |
| 
pm run summarize:scenario -- <path> | Yes | No (individual step) |
| 
pm run audit:scenario-openability | Yes | No (batch audit) |
| 
pm run verify:scenario-loader | Yes | No (verification) |

All expected commands are present and functional.

---

## 6. Commit Classification Table

| Category | Files | Action |
|----------|-------|--------|
| **Source code** | src/**, server/**, 	ools/**, package.json, eslint.config.js, .gitignore | Commit |
| **Docs/contracts** | docs/**, AGENTS.md, README.md | Commit |
| **Generated sidecars** | public/scenario-scan-samples/*.summary.json, public/scenario-scan-samples/*.json, ixtures/** | Keep local / do not commit unless small |
| **Large raw XML** | public/scenario-scan-samples/*.scenario.xml (5-40 MB each) | **Exclude** unless explicitly approved |
| **Absolute paths** | public/scenario-scan-samples/scenario-openability-index.json (contains C:\Program Files...) | Review before commit |

---

## 7. Notes

- spawn EPERM not observed during this run.
- prepare:scenario is the canonical one-command workflow for new scenarios.
- No 
eadError scenarios detected.
- Two new scenarios reached 
eadyWithInternalSidecar status (I´m still standing, Operation Epic Fury).
