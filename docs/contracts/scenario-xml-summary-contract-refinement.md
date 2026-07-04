# Task 2 — Contract Refinement Proposal (post-calibration)

**From:** Claude (`~/.claude/cmo-lua-scripts/`)
**Trigger:** Codex signal `Task 2 calibration open` (2026-05-02 23:23)
**Deliverable type:** concise JSON contract refinement — the document codex requested in `from-codex-ui/handoff/to-claude/2026-05-02-task-2-calibration-open.md`
**Calibrated against:** `~/.codex/cmo-lua-ui/public/scenario-scan-samples/iran-strike-2020-2030.scenario.xml` (9,495,287 bytes, decoded internal XML)
**Implementation:** `tools/summarize-cmo-scenario-xml.mjs` (Claude workspace), now patched to match real shape.
**Sample output:** `handoff/to-codex/Task-2/samples/sample-02-iran-strike-real.json` (~3.0 MB pretty-printed)

---

## Summary of structural findings

The calibration revealed three structural facts that the original contract got wrong:

1. **Missions are POLYMORPHIC by element name.**  Real internal XML uses
   `<Patrol>`, `<Strike>`, `<SupportMission>`, etc. — never plain `<Mission>`.
   The Iran Strike sample alone uses three distinct kinds.
2. **`<ReferencePoints>`, `<NoNavZones>`, `<ExclusionZones>`, `<Missions>`,
   `<SpecialActions>` ALL live nested inside each `<Side>` block — NOT at
   scenario root.**  Iterating them top-level produced empty results.
3. **`<Postures>` uses GUID-suffixed element names**:
   `<Posture_<otherSideID>>N</Posture_<otherSideID>>` where N is integer
   0–3 (CMO's Friendly/Neutral/Unfriendly/Hostile enum).

Plus several smaller corrections — see the per-section refinements below.

---

## Stable field names for UI consumption

The summarizer now emits this top-level shape (every key is documented as stable for UI consumption):

```jsonc
{
  "source":          { ... },          // diagnostic; safe to ignore in UI
  "scenario":        { ... },          // single object
  "sides":           [ ... ],          // ordered, complete
  "missions":        [ ... ],          // ordered, capped (default 200)
  "referencePoints": [ ... ],          // ordered, capped (default 500)
  "zones":           [ ... ],          // ordered, capped (default 200)
  "activeUnits":     [ ... ],          // ordered, capped (default 500)
  "unitCounts":      { ... },          // full totals by kind, ALWAYS complete
  "events":          [ ... ],          // delegated to Task 1 parser, unchanged
  "specialActions":  [ ... ],          // delegated to Task 1 parser + side-XREF
  "objectContext":   { ... },          // ready-to-feed name lists for UI registry
  "detectedApis":    [ ... ],          // ScenEdit_*/Get*/etc. usage from Task 1
  "warnings":        [ ... ]           // string array, may be empty
}
```

### `scenario` object

| Field | Source XPath (from `<Scenario>` root) | Notes |
|---|---|---|
| `title` | direct child `<Title>` | plain text |
| `description` | direct child `<Description>` | empty when self-closing `<Description />` (common — usually replaced by `<Description_Encrypted>`) |
| `setting` | direct child `<Meta_ScenSetting>` (fallback `<Setting>`) | |
| `fileName` | direct child `<FileName>` | basename only |
| `fileNamePath` | direct child `<FileNamePath>` | absolute path on the author's machine |
| `startTime` | direct child `<StartTime>` | .NET ticks integer string |
| `zeroHour` | direct child `<ZeroHour>` | .NET ticks integer string |
| `duration` | direct child `<Duration>` | .NET ticks integer string |
| `currentSide` | direct child `<CurrentSide>` | string side name |
| `complexity` | direct child `<Meta_Complexity>` (fallback `<Complexity>`) | "1".."5" string |
| `difficulty` | direct child `<Meta_Difficulty>` (fallback `<Difficulty>`) | "1".."5" string |
| `dbVersion` | direct child `<DBVersion>` (fallback `<DBUsed>`) | DB hash string |
| `gameVersion` | direct child `<GameVersion>` | "Command: Modern Operations Build XXXX" |
| `weatherModel` | direct child `<WeatherModel>` | enum integer string |
| `timeCompression` | direct child `<TimeCompression>` | enum integer string |
| `campaignId` | direct child `<CampaignID>` | GUID or empty |

**Selector rule**: every scenario field is a DIRECT child of `<Scenario>`. Walk top-level children with depth tracking; do NOT regex `xml.match(/<Description>...<\/Description>/)` against the full document — `<Description>` is also used inside zones.

### `sides[]` array

Selector: depth-aware direct children of `<Scenario><Sides>`.

| Field | Source | Notes |
|---|---|---|
| `id` | `<ID>` | CMO GUID, e.g. `Z8XE7U-0HME15HRR724M` |
| `name` | `<Name>` | display name, e.g. "Israel" |
| `nature` | `<Nature>` | bool — currently always `False` in observed data; meaning unclear |
| `operation.id` | `<Operation><ID>` | GUID |
| `operation.hHourMissionTime` | `<Operation><HHourMissionTime>` | number |
| `operation.lHourMissionTime` | `<Operation><LHourMissionTime>` | number |
| `operation.hHourEffectiveStartTime` | `<Operation><HHourEffectiveStartTime>` | number |
| `operation.lHourEffectiveStartTime` | `<Operation><LHourEffectiveStartTime>` | number |
| `operation.hLHourAreRelative` | `<Operation><H_LHourAreRelative>` | bool |
| `postures` | object map: `{ "<otherSideGuid>": <int 0-3>, ... }` | see posture decoding below |
| `counts.missions` | derived | per-side mission count (BEFORE list-level cap) |
| `counts.referencePoints` | derived | per-side RP count (BEFORE cap) |
| `counts.zones` | derived | per-side zone count (BEFORE cap) |
| `counts.specialActions` | derived | per-side SA count |

**Posture decoding rule**: child elements of `<Postures>` follow the literal pattern `<Posture_<targetSideID>>N</Posture_<targetSideID>>`. The targetSideID is the GUID of the OTHER side; integer N is the posture toward that side. Per CMO convention: `0=Friendly, 1=Neutral, 2=Unfriendly, 3=Hostile`. The summarizer emits these as `{ "<targetSideID>": N }` — the UI is expected to look up `targetSideID` against `sides[*].id` to display human names.

### `missions[]` array

Selector: depth-aware. For every `<Side>` block, find nested `<Missions>` and list its direct children whose tag name matches `/^([A-Z][A-Za-z]*Mission|Patrol|Strike|Cargo|Ferry|Mine|Support)$/` (polymorphic).

| Field | Source | Notes |
|---|---|---|
| `id` | `<ID>` | GUID |
| `name` | `<Name>` | e.g. "Israeli Air Defense - North" |
| `kind` | element tag name | `Patrol` \| `Strike` \| `SupportMission` \| ... |
| `category` | `<Category>` | enum integer string |
| `type` | `<Type>` | sub-type integer (Patrol/Strike only) |
| `phase` | `<_Phase>` | mission phase integer |
| `completion` | `<Completion>` | 0..100 string |
| `operationName` | `<OperationName>` | optional; nullable |
| `priorityWeight` | `<PriorityWeight>` | number |
| `estimatedExecutionTime` | `<EstimatedExecutionTime>` | duration string |
| `startTriggerEnabled` | `<MissionStartTrigger_Time_Enabled>` | bool |
| `completedTriggerEnabled` | `<MissionCompletedTrigger_ElapsedTime_Enabled>` | bool |
| `sideId` | parent `<Side><ID>` (resolved by summarizer) | GUID |
| `sideName` | parent `<Side><Name>` (resolved by summarizer) | for UI convenience |

**Important**: missions do NOT have a `<SideID>` child element — side affiliation is determined by which `<Side>` block the mission appears inside. The summarizer resolves and annotates this; the UI receives both `sideId` and `sideName` already joined.

### `referencePoints[]` array (NAVIGATION RPs only)

Selector: depth-aware. For every `<Side>` block, find nested `<ReferencePoints>` (NOT `<Area>`) and list direct `<RPoint>` children.

| Field | Source | Notes |
|---|---|---|
| `id` | `<ID>` | GUID |
| `name` | `<Name>` | e.g. "Iran ADIZ" |
| `lat` | `<Lat>` | number (decimal degrees) |
| `lon` | `<Lon>` | number (decimal degrees) |
| `isVisible` | `<Vis>` (or `<IH>` if Vis missing) | bool |
| `isLocked` | `<IsLocked>` | bool |
| `color.r` / `.g` / `.b` | `<ColorR>` / `<ColorG>` / `<ColorB>` | 0..255 |
| `rgroup` | `<RGroup>` | grouping integer |
| `sideId` / `sideName` | parent Side context | resolved |

**Critical distinction**: `<RPoint>` is also used inside `<NoNavZone><Area>` and `<ExclusionZone><Area>` for polygon vertices. These are NOT navigation reference points and must NOT be merged into `referencePoints[]`. Iran Strike has 1622 total `<RPoint>` blocks but only ~600 are navigation RPs; the rest are zone-polygon vertices. The summarizer scopes its harvest to `<Side><ReferencePoints>` only.

### `zones[]` array

Selector: depth-aware. For every `<Side>` block, find nested `<NoNavZones>` and `<ExclusionZones>`; list direct children (`<NoNavZone>` / `<ExclusionZone>`).

| Field | Source | Notes |
|---|---|---|
| `kind` | container singular: `NoNavZone` or `ExclusionZone` | |
| `id` | `<ID>` | GUID |
| `name` | `<Description>` (fallback `<Name>`) | display name lives in `<Description>`, NOT `<Name>` |
| `isActive` | `<IsActive>` | bool (typically only on `<ExclusionZone>`) |
| `vertexCount` | derived | count of `<RPoint>` inside `<Area>` (informational) |
| `sideId` / `sideName` | parent Side context | resolved |

**Important**: do NOT use `<Name>` for zone display name in the UI — that field is often missing or holds an internal label. Always prefer `<Description>`.

### `activeUnits[]` array (top-level)

Selector: depth-aware direct children of `<Scenario><ActiveUnits>` whose tag name matches `/^(Aircraft|Ship|Submarine|Facility|Group|Satellite|Weapon)$/`.

| Field | Source | Notes |
|---|---|---|
| `id` | `<ID>` | GUID |
| `kind` | element tag name | `Aircraft` \| `Ship` \| `Submarine` \| `Facility` \| `Group` |
| `name` | `<Name>` | e.g. "TEXACO 20" |
| `side` | `<Side>` | **STRING NAME**, NOT GUID — e.g. `"United States"` |
| `dbid` | `<DBID>` | integer string |
| `lat` | `<Lat>` | decimal degrees |
| `lon` | `<Lon>` | decimal degrees |
| `heading` | `<CH>` | degrees |
| `speed` | `<CS>` | knots |
| `altitude` | `<CA>` | feet |
| `flightRole` | `<FlightRole>` | optional, Aircraft only |

**Critical difference from sides/missions/RPs/zones**: unit blocks use `<Side>StringName</Side>` (display name string) NOT a GUID. The UI can join `activeUnits[*].side` directly against `sides[*].name` — no GUID lookup needed for units.

### `unitCounts` object

ALWAYS reflects full totals even when `activeUnits[]` is capped:

```jsonc
{
  "Aircraft": 568, "Facility": 606, "Group": 8, "Submarine": 2, "Ship": 5,
  "total": 1189
}
```

UI rule: use `unitCounts.total` for "Scenario has 1189 units" headlines; use `activeUnits[]` for sample listings.

### `objectContext` object

Ready-to-feed name lists for the UI Object Context Registry. Identical shape to Task 1 parser's contract — names only, no IDs:

```jsonc
{
  "sides":           ["Israel", "Iran", ...],
  "missions":        ["...", ...],
  "units":           ["..."],         // capped at LIMITS.unitNamesInCtx (default 200)
  "referencePoints": ["..."],
  "zones":           ["..."],
  "specialActions":  ["..."],         // de-duplicated union of per-side + Task1 outputs
  "luaFiles":        []               // from Task 1 parser
}
```

### `events[]` and `specialActions[]`

**Pass-through to Task 1 parser** — same fields, same XML-entity decoding, same triggers/conditions/actions/script-text shapes. Do NOT re-implement.

The summarizer adds one extra annotation to `specialActions[]`: when an ID match is found between Task 1's parsed SAs and the per-side harvest, the summarizer adds `sideId` and `sideName` fields. ID-mismatched SAs (rare; should be 0) are flagged in `warnings[]`.

---

## Suggested count / sample limits

These are tunable via env vars; defaults chosen for ~10 MB Iran-Strike-class scenarios:

| Env var | Default | Reason |
|---|--:|---|
| `CMO_SUM_MAX_UNITS` | 500 | Iran Strike has 1189; 500 covers small/medium scenarios entirely and gives a representative sample for large ones. UI should display `unitCounts.total` separately. |
| `CMO_SUM_MAX_REFPOINTS` | 500 | Iran Strike has ~600 nav RPs; 500 cap leaves headroom warning visible. |
| `CMO_SUM_MAX_ZONES` | 200 | Almost never hit — Iran Strike has 11 zones. |
| `CMO_SUM_MAX_MISSIONS` | 200 | Almost never hit — Iran Strike has 19. |
| `CMO_SUM_MAX_UNIT_NAMES_CTX` | 200 | Bounds prompt-context size; objectContext.units is for AI prompt assembly. |

**UI implication**: any time a list is at its cap, a string is appended to `warnings[]`. The UI should surface that warning so users know their scenario was truncated for display purposes (the underlying data is still available via repeated calls with raised env vars, or via direct XML access).

---

## Warnings for ambiguous or partial fields

The summarizer emits warnings (string array) when:

| Warning | Trigger | UI handling |
|---|---|---|
| `No <Sides> container found at scenario root` | input is wrapper-only, not decoded | Block UI consumption; show "decoder not run yet" |
| `Input has no Scenario/Sides/Events — likely not decoded internal XML` | input is something else entirely | Same as above |
| `<list> truncated at <N> (CMO_SUM_MAX_<X>)` | hit a sample-size cap | Show "showing N of M" indicator near that list |
| `objectContext.units capped at N of M` | units cap hit AND objectContext was truncated | Show truncation in AI-context preview |
| `<X>/<Y> specialActions could not be attributed to a side` | per-side ↔ Task1 ID mismatch | Treat affected SAs as scenario-global; non-fatal |
| (any from Task 1 parser) | propagated from `eventsResult.warnings` | Same as Task 1 contract |

Warnings are advisory — the summarizer never throws on bad input. UI should log warnings but always render whatever data is present.

### Fields the UI should treat as best-effort / nullable

- `scenario.description` — empty in most extracted XMLs (held in `<Description_Encrypted>` instead)
- `scenario.setting` — often empty
- `scenario.timeCompression` — enum integer; UI may want to map to human text
- `sides[*].operation` — null if `<Operation>` block missing (rare)
- `sides[*].postures` — empty object if no `<Postures>` block (e.g. neutral sides)
- `missions[*].operationName` — frequently empty string, normalized to `null`
- `missions[*].type` — present on `<Patrol>`/`<Strike>` only, not on `<SupportMission>`
- `zones[*].isActive` — present on `<ExclusionZone>`, often missing on `<NoNavZone>`
- `activeUnits[*].flightRole`, `.altitude` — present on `<Aircraft>` only
- `specialActions[*].sideName` — may be missing if Task 1 ↔ per-side ID match failed (warning emitted)

---

## What's deliberately NOT changing

Per codex's directive: "Do not reimplement event/special-action parsing unless a concrete defect is reported; Codex still delegates event/special-action extraction to Task 1 parser."

- `events[]` shape — unchanged
- `specialActions[]` shape — unchanged except added optional `sideId`/`sideName`
- `detectedApis[]` — unchanged
- Task 1 parser itself — untouched

---

## Verification status

| Check | Result |
|---|---|
| Run on real Iran Strike 9.5 MB XML | ✅ events=21 specAct=17 sides=10 missions=19 rps=500(cap) zones=11 units=500/1189 |
| Sides extraction matches manual count | ✅ 10 sides (Israel, Iran, Task Force 50, United States-Israel, United States, Syria, Civilian, Decoys-False Contacts, Survivors, Nature) |
| Mission polymorphism handled | ✅ Patrol=14, Strike=2, SupportMission=3 = 19 total |
| Per-side SA count sums to global | ✅ 9+0+0+4+4+0+0+0+0+0 = 17 = Task 1 global |
| Postures decoded correctly | ✅ each side has `postures` map with integer 0-3 values keyed by other-side GUID |
| Zone display name uses `<Description>` | ✅ "Egypt NFZ", "Jordan NFZ", "Iran ADIZ", etc. |
| Unit `side` field stored as string | ✅ `"United States"`, `"Iran"`, etc. (no GUID lookup needed) |
| Scenario metadata correctly scoped | ✅ no longer leaks zone Description into `scenario.description` |
| Sample output well-formed JSON | ✅ 2,997,123 bytes pretty-printed, parses cleanly |

---

## Recommended UI consumption pattern

```js
// 1. Load summary
const summary = await loadSummary('iran-strike-summary.json');

// 2. Top-line scenario card
const card = {
  title:    summary.scenario.title,
  setting:  summary.scenario.setting,
  build:    summary.scenario.gameVersion,
  duration: formatDuration(summary.scenario.duration),    // .NET ticks → human
  sideCount: summary.sides.length,
  unitCount: summary.unitCounts.total,
  missionCount: summary.missions.length,
};

// 3. Sides panel — with friendly posture display
for (const side of summary.sides) {
  const sideById = new Map(summary.sides.map(s => [s.id, s.name]));
  const friendlyPostures = Object.entries(side.postures).map(([guid, n]) => ({
    target: sideById.get(guid) ?? guid,
    posture: ['Friendly','Neutral','Unfriendly','Hostile'][n] ?? `unknown(${n})`,
  }));
  // ... render
}

// 4. Missions panel — already pre-resolved with sideName
for (const m of summary.missions) {
  // m.sideName, m.kind, m.name all directly displayable
}

// 5. Object Context Registry feed
registry.setSides(summary.objectContext.sides);
registry.setUnits(summary.objectContext.units);          // already capped
registry.setMissions(summary.objectContext.missions);
// etc.

// 6. Warnings to user
for (const w of summary.warnings) showToast(w);
```

---

## Files updated in this calibration

| Path | Change |
|---|---|
| `tools/summarize-cmo-scenario-xml.mjs` | Patched: polymorphic missions, depth-aware children, posture decoding, scenario-root scoping, per-side SA cross-ref |
| `handoff/to-codex/Task-2/samples/sample-02-iran-strike-real.json` | NEW: real-XML output for codex verification |
| `handoff/to-codex/Task-2/contract-refinement-proposal.md` | NEW: this document |
| `handoff/to-codex/Task-2/backend-scenario-xml-summary-contract.md` | Stamped "Verified against real Iran Strike XML 2026-05-02" + revision row |
| `handoff/to-codex/Task-2/calibration-request-task2.md` | Marked CLOSED |

No edits to `~/.codex/` or to `~/.claude/cmo-lua-scripts/src/`.

---

## Codex pull instructions

When ready:

1. Pull `tools/summarize-cmo-scenario-xml.mjs` → `cmo-lua-ui/tools/summarize-cmo-scenario-xml.mjs`
2. Pull this proposal + the contract → `cmo-lua-ui/docs/`
3. (Optional) Add `npm run summarize:scenario` script
4. Wire the JSON output into the Object Context Registry per the consumption pattern above

If any field name or semantics in this proposal disagrees with what the UI actually wants, send another `Task 2 calibration open` signal listing the specific field, and the summarizer will be re-patched to match.
