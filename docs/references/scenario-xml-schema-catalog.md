# CMO Scenario XML Schema Catalog

Source: `public/scenario-scan-samples/iran-strike-2020-2030.scenario.xml`  
Scenario: *Iran Strike, 2020–2030* (Steam Workshop 2855653232)  
Analyzed: 2026-05-02  
Analyzer: `fixtures/iran-strike-xml-node-index.json` (auto-generated)

---

## XML Overview

| Metric | Value |
|--------|-------|
| Root element | `<Scenario>` |
| Distinct tag names | 2,699 |
| Max nesting depth | 10 |
| File size | ~9.5 MB |

> Note: The decoded XML is extremely dense because it contains full unit-level sensor/weapon/mount/contact trees. Most of the 2,699 distinct tags live under individual unit or contact nodes and are not relevant for high-level scenario summarization.

---

## Top-Level Sections

The following tables describe the *high-level* nodes that Codex UI and Claude Task 2 summarizer care about.

### Sides

| Fact | Detail |
|------|--------|
| Container | `<Scenario>/<Sides>` |
| Side nodes | `<Side>` (3 major sides in this scenario) |
| Side name location | `<Side>/<Name>` child element (not an attribute) |
| Nested under Side | `Contacts`, `Missions`, `ReferencePoints`, `NoNavZones`, `ExclusionZones`, `SpecialActions` |

Observed side names: `Israel`, `Iran`, `Task Force 50`, `United States-Israel`, `United States`, `Syria`, `Civilian`, `Decoys-False Contacts`, `Survivors`, `Nature`.

**Per-side counts (independent enumeration)**

| Side | Missions | NoNavZones | ExclusionZones | SpecialActions |
|------|----------|------------|----------------|----------------|
| Israel | 0 | 4 | 0 | 9 |
| Iran | 10 | 1 | 1 | 0 |
| Task Force 50 | 1 | 0 | 0 | 0 |
| United States-Israel | 3 | 4 | 0 | 4 |
| United States | 3 | 1 | 0 | 4 |
| Syria | 1 | 0 | 0 | 0 |
| Civilian | 0 | 0 | 0 | 0 |
| Decoys-False Contacts | 1 | 0 | 0 | 0 |
| Survivors | 0 | 0 | 0 | 0 |
| Nature | 0 | 0 | 0 | 0 |
| **Total** | **19** | **11** | **1** | **17** |

### Missions

| Fact | Detail |
|------|--------|
| Container | `<Scenario>/<Sides>/<Side>/<Missions>` |
| Depth | 3 |
| Count per side | varies ( Israel has 6 `<Missions>` blocks ) |
| Mission items | **Polymorphic by element name.** Observed: `<Patrol>` (14), `<Strike>` (2), `<SupportMission>` (3). No plain `<Mission>` tag exists. |
| Mission name | `<Name>` child element |

> **Important:** Missions are **NOT** under `<Scenario>/<Missions>` directly. They live inside each `<Side>`.

### Reference Points

| Fact | Detail |
|------|--------|
| Container (side-owned) | `<Scenario>/<Sides>/<Side>/<ReferencePoints>` |
| Container (zone-owned) | `<Scenario>/<Sides>/<Side>/<NoNavZones>/<NoNavZone>/<Area>/<RPoint>` |
| Point nodes | `<RPoint>` |
| Name | `<Name>` child element |

Observed: `RPoint` count = 401. Most appear inside NoNavZone Areas, not under standalone ReferencePoints.

### No-Navigation Zones

| Fact | Detail |
|------|--------|
| Container | `<Scenario>/<Sides>/<Side>/<NoNavZones>` |
| Zone nodes | `<NoNavZone>` |
| Count | 10 |
| Name/Description | `<Description>` or `<Name>` child |
| Area polygon | `<NoNavZone>/<Area>/<RPoint>...` |

### Exclusion Zones

| Fact | Detail |
|------|--------|
| Container | `<Scenario>/<Sides>/<Side>/<ExclusionZones>` |
| Zone nodes | `<ExclusionZone>` |
| Count | 1 in this scenario |
| Name/Description | `<Description>` or `<Name>` child |

### Active Units

| Fact | Detail |
|------|--------|
| Container | `<Scenario>/<ActiveUnits>` (root-level) |
| Unit nodes | Each unit is an element whose tag name = the **unit name itself** (e.g. `<USS Vermont (SSN-792)>`, `<101 Sqd. #1>`, `<Building (Small)>`) |
| Unit type | Inferred from internal child tags (e.g. presence of `<Aircraft>`, `<Ship>`, `<Facility>`, `<Submarine>` children) — **not** from the wrapper element name |
| Common children | `<DBID>`, `<ID>`, `<Side>`, `<Name>`, `<Lat>`, `<Lon>`, `<Type>`, etc. |

> **Important:** Unit wrapper elements do **not** use generic tags like `<Unit>` or `<Aircraft>`. They use the actual in-scenario name as the tag name. This is a CMO internal XML quirk.

### Events

CMO stores events split across three root-level siblings (no single `<Events>` wrapper):

#### EventTriggers

| Fact | Detail |
|------|--------|
| Container | `<Scenario>/<EventTriggers>` |
| Trigger types observed | `EventTrigger_RegularTime` (6), `EventTrigger_UnitDestroyed` (5), `EventTrigger_UnitDetected` (5), `EventTrigger_UnitEntersArea` (4), `EventTrigger_UnitDamaged` (2), `EventTrigger_ScenLoaded` (1) |
| Name/Description | `<Description>` or `<Name>` child |
| Target filter | `<TargetFilter>` with `<ID>`, `<TargetSide>`, `<TargetType>`, `<TargetSubType>` |
| Raw trigger count | 23 |
| Parsed event count (Task 1) | 21 — some events aggregate multiple triggers (e.g. "Iran Identifies False Missile Contacts" has 5 triggers) |

#### EventConditions

| Fact | Detail |
|------|--------|
| Container | `<Scenario>/<EventConditions>` |
| Status | **Empty** in this scenario (0 children) |

#### EventActions

| Fact | Detail |
|------|--------|
| Container | `<Scenario>/<EventActions>` |
| Action types observed | `EventAction_LuaScript` (26) — **only LuaScript actions present** in this scenario |
| Script body | `<ScriptText>` child (CDATA-like text node) |
| Script metadata | `<ScriptFor>` child |

### Special Actions

| Fact | Detail |
|------|--------|
| Container | `<Scenario>/<Sides>/<Side>/<SpecialActions>` |
| Depth | 3 |
| Action nodes | `<SpecialAction>` (wrapper name confirmed via child tags, not via tag frequency because names vary) |
| Name | `<Name>` child |
| Active state | `<IsActive>` child (`True` / `False`) |

> **Important:** SpecialActions are **NOT** under `<Scenario>/<SpecialActions>` directly. They live inside each `<Side>`.

---

## UI Field Mapping Summary

Compared against `src/components/LuaAssistant.jsx` extractor expectations (line 687–758).

| UI Field | XML Evidence | Status | Notes |
|----------|--------------|--------|-------|
| `sides` | `<Scenario>/<Sides>/<Side>` | **present** | Direct child of root `Sides`. Codex queries `Sides > Side` — matches. |
| `missions` | `<Scenario>/<Sides>/<Side>/<Missions>` | **uncertain** | Codex queries `Missions` as root-level (or uses `collectDirectChildren(doc, 'Missions')`). Actual XML nests missions under each Side. May return empty unless selector is updated to `Sides Side Missions` or XPath is used. |
| `referencePoints` | `<Scenario>/<Sides>/<Side>/<ReferencePoints>/<RPoint>` and `<Scenario>/<Sides>/<Side>/<NoNavZones>/<NoNavZone>/<Area>/<RPoint>` | **uncertain** | Codex queries `ReferencePoints > RPoint`. Most RPoints live inside zone Areas, not under standalone `ReferencePoints`. Side-level ReferencePoints exist but were not in the first 3 example paths sampled. |
| `noNavZones` | `<Scenario>/<Sides>/<Side>/<NoNavZones>/<NoNavZone>` | **uncertain** | Codex queries `NoNavZones > NoNavZone` (root-level). Actual XML nests under each Side. |
| `exclusionZones` | `<Scenario>/<Sides>/<Side>/<ExclusionZones>/<ExclusionZone>` | **uncertain** | Codex queries `ExclusionZones > ExclusionZone` (root-level). Actual XML nests under each Side. |
| `activeUnits` | `<Scenario>/<ActiveUnits>` | **present** | Root-level container matches Codex expectation. Unit wrapper tag names are scenario-specific (not generic `<Aircraft>` etc.). |
| `eventTriggers` | `<Scenario>/<EventTriggers>/<EventTrigger_*>` | **present** | Root-level container matches. |
| `eventActions` | `<Scenario>/<EventActions>/<EventAction_*>` | **present** | Root-level container matches. |
| `eventConditions` | `<Scenario>/<EventConditions>` | **present** | Root-level container exists but is empty in this scenario. |
| `specialActions` | `<Scenario>/<Sides>/<Side>/<SpecialActions>` | **uncertain** | Codex queries `SpecialActions` as root-level (or `collectDirectChildren(doc, 'SpecialActions')`). Actual XML nests under each Side. |

### Verification against Claude Task 2 counts

| Metric | Claude Count | Independent Enumeration | Status |
|--------|-------------|------------------------|--------|
| sides | 10 | 10 | ✅ match |
| missions | 19 | 19 | ✅ match |
| zones (NoNav + Excl) | 11 | 11 | ✅ match |
| specialActions | 17 | 17 | ✅ match |
| units total | 1189 | 1189 | ✅ match |
| eventTriggers (raw) | — | 23 | — |
| events (parsed) | 21 | — | delegated to Task 1 |

### Recommendation

Codex UI extractor should consider using descendant selectors or XPath for:
- `Missions`
- `SpecialActions`
- `NoNavZones`
- `ExclusionZones`
- `ReferencePoints` (check both `Sides/Side/ReferencePoints` and `NoNavZones/NoNavZone/Area`)

Or, if CMO XML structure varies by version/scenario, the extractor may need to support both root-level and Side-nested paths.

---

## Fixture Notes

### Real XML-shaped fixture
- `fixtures/cmo-scenario-mini.xml` — derived from the real Iran Strike XML
- Size: ~19 KB (< 100 KB target)
- Contains: Task Force 50 side (with Contacts stripped), 1 active unit, 1 event trigger, 1 event action
- Intended for sub-second parser smoke tests

### Synthetic plain-text/Lua-table fixtures
- `fixtures/event-export-samples/tool-dump-events-sample.txt`
- `fixtures/event-export-samples/scenedit-getevent-sample.txt`
- `fixtures/event-export-samples/mixed-console-paste-sample.txt`
- **Status:** `reference-only / non-smoke`
- These formats do not match the current parser's expected XML-shaped input. Their failures are **fixture/contract drift**, not parser defects.

---

## Appendix: Top 40 Tags by Frequency

| Rank | Tag | Count | Max Depth | Attributes |
|------|-----|-------|-----------|------------|
| 1 | `ID` | 20,215 | 9 | — |
| 2 | `Name` | 13,346 | 9 | — |
| 3 | `DBID` | 10,948 | 9 | — |
| 4 | `Seg` | 7,226 | 10 | — |
| 5 | `Lon` | 6,272 | 7 | — |
| 6 | `Lat` | 6,272 | 7 | — |
| 7 | `Cov` | 4,875 | 9 | — |
| 8 | `CA` | 4,435 | 5 | — |
| 9 | `ISAD` | 4,392 | 5 | — |
| 10 | `EmissionInterval` | 4,361 | 9 | — |
| 11 | `Type` | 3,892 | 5 | — |
| 12 | `Stance` | 3,861 | 7 | — |
| 13 | `ActualUnitID` | 3,860 | 5 | — |
| 14 | `IDStatus` | 3,860 | 5 | — |
| 15 | `A_Known` | 3,860 | 5 | — |
| 16 | `ISS` | 3,860 | 5 | — |
| 17 | `SIK` | 3,860 | 5 | — |
| 18 | `H_Known` | 3,860 | 5 | — |
| 19 | `AInc` | 3,860 | 5 | — |
| 20 | `S_Known` | 3,860 | 5 | — |
| 21 | `DET` | 3,825 | 6 | — |
| 22 | `TSD` | 3,825 | 5 | — |
| 23 | `TS_Recon` | 3,825 | 5 | — |
| 24 | `LastDetections` | 3,825 | 5 | — |
| 25 | `TS_BDA` | 3,825 | 5 | — |
| 26 | `RCTTP` | 3,825 | 5 | — |
| 27 | `RCTT` | 3,825 | 5 | — |
| 28 | `HeldFor` | 3,825 | 5 | — |
| 29 | `Wake_IncludesContactID` | 3,738 | 9 | — |
| 30 | `WakeWhenDetectingThreat` | 3,738 | 9 | — |
| 31 | `UseEmissionInterval` | 3,738 | 9 | — |
| 32 | `Wake_IncludesContactStance` | 3,738 | 9 | — |
| 33 | `EmissionDuration` | 3,738 | 9 | — |
| 34 | `Side` | 3,691 | 5 | — |
| 35 | `ROF` | 3,332 | 9 | — |
| 36 | `WRec` | 2,972 | 8 | — |
| 37 | `WeapID` | 2,972 | 9 | — |
| 38 | `DamageSeverity` | 2,972 | 9 | — |
| 39 | `ML` | 2,972 | 9 | — |
| 40 | `ODS` | 2,950 | 5 | — |

> The top tags are overwhelmingly contact/sensor/weapon leaf nodes inside unit trees. They are relevant only if Codex/Claude later decides to parse unit loadouts or sensor emissions.
