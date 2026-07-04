# Scenario Scan Samples

## iran-strike-2020-2030

- **Type:** Real CMO scenario
- **Source:** Steam Workshop `2855653232` — *Iran Strike, 2020-2030*
- **Scanner:** `tools/scan-cmo-scenario-folder.mjs` (safe-metadata-and-sidecars mode)
- **Scan Date:** 2026-05-02
- **Files:**
  - `iran-strike-2020-2030.json` — Full scanner output (metadata, sidecars, edit context)
  - `iran-strike-2020-2030.scenario.xml` — XML extracted from `.scen` (9.5 MB)
  - `.scenario-extract-cache/Iran_Strike_2020-2030.scen` — Original binary (1.6 MB)

### Key Metadata

| Field | Value |
|-------|-------|
| Title | Iran Strike, 2020-2030 |
| DB | DB3K_516.db3 |
| Complexity | 3 |
| Difficulty | 3 |
| Inferred Sides | Israel, USA |

### Limitations (from scanner)

- `Scenario_Compressed` is present; internal events/units/Lua require CMO engine export.
- Side names are inferred from briefing filenames, not guaranteed exact CMO side names.
- `.ini` sidecars expose unit/mount hints only.

### Usage

- Codex UI: scenario selector, object context seeding, briefing preview
- Claude parser: optional `scenarioScanJson` input for cross-referencing sides/units
