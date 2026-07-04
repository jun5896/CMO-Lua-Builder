# CMO Lua UI — Test Fixtures

This directory contains **verified sample data** for parser testing, UI development, and regression checks.

## Directory Layout

```
fixtures/
├── README.md                          # This file
├── scenario-scan-samples/             # Scenario metadata & sidecar scan results
│   ├── README.md
│   └── iran-strike-2020-2030.meta.json  # Extracted from public/scenario-scan-samples/
├── event-export-samples/              # CMO event/Lua export text inputs
│   ├── README.md
│   ├── tool-dump-events-sample.txt    # Synthetic sample (reference-only / non-smoke)
│   ├── scenedit-getevent-sample.txt   # Synthetic sample (reference-only / non-smoke)
│   └── mixed-console-paste-sample.txt # Synthetic sample (reference-only / non-smoke)
├── parser-validation-spec.md          # Expected input→output contract for Claude parser
├── iran-strike-xml-node-index.json    # Auto-generated tag frequency catalog from real XML
└── cmo-scenario-mini.xml              # Real XML-shaped mini fixture for parser smoke tests
```

## Real vs. Synthetic Data Policy

| File | Type | Source |
|------|------|--------|
| `iran-strike-2020-2030.*` | **Real** | Actual CMO Steam Workshop scenario (Iran Strike, 2020–2030) scanned by `tools/scan-cmo-scenario-folder.mjs` |
| `*.scenario.xml` | **Real** | Extracted from `.scen` via `tools/extract-cmo-scenario-xml.ps1` |
| `event-export-samples/*.txt` | **Synthetic** | Hand-written to mimic real CMO Lua Console/Event Editor output formats. Labelled `[SYNTHETIC]` inside each file. |

> **Rule:** Any synthetic fixture must contain a header comment/file marker stating it is synthetic and which real CMO output format it mimics.
