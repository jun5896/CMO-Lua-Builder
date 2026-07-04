# Backend Scenario XML Summary Contract

**Task:** Claude Task 2 — Scenario internal-XML summarizer ("보조 요약기")
**Source spec:** Codex's relayed direction 2026-05-02 — ".scen 내부 XML에서 이벤트/특수액션 덤프를 만들 수 있는 보조 요약기"
**Implementation:** `tools/summarize-cmo-scenario-xml.mjs` (Claude workspace)
**Companion tools:** codex-built `tools/extract-cmo-scenario-xml.ps1` (decoder), `tools/scan-cmo-scenario-folder.mjs` (folder scan)
**Status:** ✅ **CALIBRATED 2026-05-02** — verified against real Iran Strike, 2020-2030 internal XML (9.5 MB).
**Refinement notes:** see `contract-refinement-proposal.md` for full schema + selector specifics post-calibration.

---

## Pipeline position

```
.scen file
  │
  └─[ extract-cmo-scenario-xml.ps1 (codex) ]──▶  decoded internal <Scenario> XML
                                                        │
                                                        └─[ summarize-cmo-scenario-xml.mjs (Claude) ]──▶  summary JSON
                                                                                                                │
                                                                                                                ▼
                                                                                          UI: Scenario Inventory + Object Context Registry
```

The summarizer **does not decode `.scen`** — it consumes the XML codex's PS1 tool already produced. This keeps Claude's deliverable in the contract-only / UI-agnostic safe scope.

---

## Why this exists (gap analysis)

`scan-cmo-scenario-folder.mjs` (codex) produces:
- `scenario.{title, description, dbVersion, complexity, ...}`
- `compressed.{present, base64Chars, decodedBytes, firstBytesHex}` (no decode)
- `sidecars[]` (.ini units, .html briefings)
- `editContext.{database, candidateSidesFromBriefingFiles, ...}`

That output **lacks events, specialActions, missions, sides, RPs, zones**. They live inside the `Scenario_Compressed` blob.

The `extract-cmo-scenario-xml.ps1` (codex) unwraps the blob using CMO's own DLLs. Output is the decoded `<Scenario>` XML — large (e.g. 9.5M chars for "Iran Strike, 2020-2030").

The **summarizer (this tool)** turns that large XML into the missing pieces, in a JSON shape compatible with Task 1's parser.

---

## Output schema (JSON, post-calibration 2026-05-02)

See **`contract-refinement-proposal.md`** for the full per-field selector table and stability guarantees. Top-level keys (every key documented as stable for UI consumption):

```jsonc
{
  "source":          { ... },                  // diagnostic
  "scenario":        { title, description, setting, fileName, fileNamePath,
                       startTime, zeroHour, duration, currentSide, complexity,
                       difficulty, dbVersion, gameVersion, weatherModel,
                       timeCompression, campaignId },
  "sides": [
    {
      "id":         "Z8XE7U-0HME15HRR724M",     // CMO GUID
      "name":       "Israel",
      "nature":     false,
      "operation":  { id, hHourMissionTime, lHourMissionTime,
                      hHourEffectiveStartTime, lHourEffectiveStartTime,
                      hLHourAreRelative },
      "postures":   { "<otherSideID>": 0|1|2|3, ... },   // 0=Friendly..3=Hostile
      "counts":     { missions, referencePoints, zones, specialActions }
    }
  ],
  "missions": [
    {
      "id":           "...",
      "name":         "Israeli Air Defense - North",
      "kind":         "Patrol" | "Strike" | "SupportMission" | ...,  // POLYMORPHIC element name
      "category":     "...",
      "type":         "...",
      "phase":        "...",
      "completion":   "...",
      "operationName": null | "...",
      "priorityWeight": 1,
      "estimatedExecutionTime": "...",
      "startTriggerEnabled":     bool,
      "completedTriggerEnabled": bool,
      "sideId":   "Z8XE7U-...",                 // resolved by summarizer
      "sideName": "Israel"                      // resolved by summarizer
    }
  ],
  "referencePoints": [                          // navigation RPs ONLY (zone vertices excluded)
    {
      "id":        "...",
      "name":      "Iran ADIZ",
      "lat":       25.19761,
      "lon":       61.611074,
      "isVisible": true,
      "isLocked":  true,
      "color":     { r: 255, g: 255, b: 255 },
      "rgroup":    0,
      "sideId":    "...",
      "sideName":  "Iran"
    }
  ],
  "zones": [
    {
      "kind":        "NoNavZone" | "ExclusionZone",
      "id":          "...",
      "name":        "Egypt NFZ",               // FROM <Description>, NOT <Name>
      "isActive":    bool,                      // typically only on ExclusionZone
      "vertexCount": 10,                        // <Area><RPoint> count, informational
      "sideId":      "...",
      "sideName":    "Israel"
    }
  ],
  "activeUnits": [                              // top-level <ActiveUnits>
    {
      "id":          "...",
      "kind":        "Aircraft" | "Ship" | "Submarine" | "Facility" | "Group",
      "name":        "TEXACO 20",
      "side":        "United States",           // STRING NAME — NOT a GUID
      "dbid":        "7704",
      "lat":         32.0, "lon": 34.0,
      "heading":     180.0,
      "speed":       250.0,
      "altitude":    25000,
      "flightRole":  "..."                      // Aircraft only
    }
  ],
  "unitCounts":     { Aircraft, Facility, Ship, Submarine, Group, total },  // ALWAYS full totals
  "events":         [ /* unchanged Task 1 parser shape */ ],
  "specialActions": [ /* Task 1 parser shape + sideId/sideName cross-ref */ ],
  "objectContext":  { sides[], missions[], units[], referencePoints[],
                      zones[], specialActions[], luaFiles[] },
  "detectedApis":   [...],
  "warnings":       [...]
}
```

### Selector rules (post-calibration)

1. **`<Scenario>` is the document root.** Walk only DIRECT children for scenario-level metadata to avoid same-name collisions inside Side / unit / zone blocks (e.g., `<Description>` is also used inside zones).
2. **`<Sides>` is the only top-level multi-entity container** for scenario data. Almost everything else lives nested inside each `<Side>` block.
3. **Inside each `<Side>`:** `<ReferencePoints>`, `<NoNavZones>`, `<ExclusionZones>` (some), `<Missions>`, `<SpecialActions>`. The summarizer resolves `sideId`/`sideName` for every nested item.
4. **`<Missions>` children are polymorphic** by element name: `Patrol`, `Strike`, `SupportMission`, etc. Use a regex predicate, not a fixed `<Mission>` match.
5. **Zone display name is `<Description>`** (not `<Name>`).
6. **`<ActiveUnits>` is top-level** with mixed-kind children. Unit blocks use `<Side>StringName</Side>`, NOT a GUID. Cross-reference via `sides[*].name`, not `sides[*].id`.
7. **`<Postures>` uses GUID-suffixed element names**: `<Posture_<otherSideID>>N</Posture_<otherSideID>>`. Decode N as integer 0-3.
8. **`<RPoint>` is reused** for both navigation reference points (under `<Side><ReferencePoints>`) AND zone polygon vertices (under `<Zone><Area>`). Scope your harvest to the navigation path only.

### Stability guarantees

- Total parser: never throws. Bad input → empty arrays + warnings.
- Lua bodies are byte-identical to the source (no rewriting), with `&lt;` etc. decoded.
- All tag matching is case-insensitive for top-level containers.
- Field names listed above are stable; future scenarios may add NEW fields but won't rename existing ones.

### Sample-size limits (env-tunable)

| Env var | Default | Hit on Iran Strike? |
|---|--:|---|
| `CMO_SUM_MAX_UNITS` | 500 | YES (1189 total) |
| `CMO_SUM_MAX_REFPOINTS` | 500 | YES (~600 total) |
| `CMO_SUM_MAX_ZONES` | 200 | no (11) |
| `CMO_SUM_MAX_MISSIONS` | 200 | no (19) |
| `CMO_SUM_MAX_UNIT_NAMES_CTX` | 200 | YES (1189) |

When a cap is hit, a `warnings[]` entry is appended. `unitCounts.total` always reflects the true scenario-wide total.

---

## CLI

```bash
node tools/summarize-cmo-scenario-xml.mjs <internal-xml-file> [--out <out.json>]
node tools/summarize-cmo-scenario-xml.mjs --stdin
cat scenario.xml | node tools/summarize-cmo-scenario-xml.mjs --stdin
```

Programmatic:
```js
import { summarize } from './tools/summarize-cmo-scenario-xml.mjs';
const result = summarize(xml, { fileName: 'iran-strike.xml' });
```

---

## Composing with codex's tools

Full pipeline (codex side):
```powershell
# 1. Extract decoded XML (codex's PS1)
npm run extract:scenario-xml -- "C:\...\Iran Strike, 2020-2030.scen" --OutXml "iran-strike.xml"

# 2. Summarize (Claude's MJS)
node tools/summarize-cmo-scenario-xml.mjs "iran-strike.xml" --out "iran-strike-summary.json"

# 3. Merge with the folder-scan output (codex's MJS) for a complete view
node tools/scan-cmo-scenario-folder.mjs "C:\...\Iran Strike, 2020-2030.scen" --out "iran-strike-folder.json"
# Codex's UI then reads BOTH JSONs: folder-scan for sidecar/.ini, summary for events/missions/sides
```

---

## Smoke-test (calibrated against real Iran Strike XML, 2026-05-02)

Real input: `~/.codex/cmo-lua-ui/public/scenario-scan-samples/iran-strike-2020-2030.scenario.xml` (9,495,287 bytes).

| Field           | Result |
|---|---|
| events          | 21 ✅ matches Task 1 verification |
| specialActions  | 17 ✅ matches Task 1 verification (with side cross-ref) |
| sides           | 10 ✅ Israel, Iran, Task Force 50, United States-Israel, United States, Syria, Civilian, Decoys-False Contacts, Survivors, Nature |
| missions        | 19 ✅ Patrol=14, Strike=2, SupportMission=3 |
| referencePoints | 500 (cap; ~600 total — warning emitted) |
| zones           | 11 ✅ NoNavZones + 1 ExclusionZone, with `<Description>`-derived names |
| activeUnits     | 500 (cap; total 1189 in `unitCounts`) |
| unitCounts      | Aircraft=568, Facility=606, Group=8, Submarine=2, Ship=5, total=1189 |
| warnings        | 3 (all sample-cap notices, no errors) |

Earlier proxy smoke-test against Task 1 fixture-04 (still passing): 4 events, 2 SAs, 0 sides, 0 missions, 4 RPs, 0 units, 0 warnings.

---

## Codex review path

When ready:
1. Pull `tools/summarize-cmo-scenario-xml.mjs` to `cmo-lua-ui/tools/`
2. Pull this contract to `cmo-lua-ui/docs/backend-scenario-xml-summary-contract.md`
3. Wire summarize output into UI's scenario-inventory flow

---

## Resolved questions (post-calibration)

1. ✅ Real decoded internal XML reuses `<EventTriggers>`/`<EventActions>`/`<SimEvents>`/`<SpecialActions>` exactly as expected (Task 1 verified 21 events, 17 SAs).
2. ✅ Top-level multi-entity container is `<Sides>` ONLY. `<Missions>`, `<ReferencePoints>`, `<NoNavZones>`, `<ExclusionZones>`, `<SpecialActions>` are all NESTED inside each `<Side>`. `<ActiveUnits>` is its own top-level container.
3. ⚠️ `activeUnits` currently includes Aircraft/Ship/Submarine/Facility/Group. Satellite/Weapon are NOT seen in Iran Strike but are in the harvest predicate; the UI can filter by `kind` if needed.
4. ⚠️ `<KeyValues>` not yet observed in Iran Strike sample — will revisit if/when a scenario uses it.

## Still open

- **Mission `<Category>` enum mapping** — observed values are integer strings ("0","1","2",...). UI may want a labels table mapping to human names. Not critical for Task 2 contract.
- **`<Type>` field** present on `<Patrol>`/`<Strike>` but not `<SupportMission>` — sub-type enum semantics not yet documented.

---

## Revision marker

| Rev | Date | Change |
|---|---|---|
| 1 | 2026-05-02 | Initial draft. Reuses Task 1 parser via ESM import. Proxy-tested. |
| 2 | 2026-05-02 | ✅ **CALIBRATED** against real Iran Strike, 2020-2030 internal XML (9.5 MB). Polymorphic Mission types, nested-in-Side container layout, `<Description>`-based zone names, string-side-name unit refs, posture decoding, scenario-root scoping. See `contract-refinement-proposal.md` for full per-field selectors. |
