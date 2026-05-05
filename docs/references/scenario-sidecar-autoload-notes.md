# Scenario Sidecar Auto-Load Notes

Generated: 2026-05-03  
Purpose: Bridge prep for Codex `.scen` open behavior and browser-side scenario loading.

---

## What Lives Where

When a user drops or selects a `.scen` file in the CMO Lua UI, the browser cannot read the binary directly (it is a proprietary compressed container). Instead, the app relies on **sidecar artifacts** produced by backend scanners and decoders.

### Artifact Stack (per scenario)

| Layer | File | Size | Fetchable by Browser | Producer |
|-------|------|------|----------------------|----------|
| 1 Original | `.scen` binary | ~1.6 MB | ❌ No | CMO engine / Steam Workshop |
| 2 Extracted XML | `.scenario.xml` | ~9.5 MB | ✅ Yes (`public/`) | `tools/extract-cmo-scenario-xml.ps1` |
| 3 Scan JSON | `.json` (metadata + sidecars) | ~37 KB | ✅ Yes (`public/`) | `tools/scan-cmo-scenario-folder.mjs` |
| 4 Summary JSON | `-summary.json` | ~3 MB | ❌ No (`fixtures/`) | Claude `summarize-cmo-scenario-xml.mjs` (Task 2) |

### Why the split?

- **`public/`** — Vite serves these as static assets; the browser can `fetch()` them directly.
- **`fixtures/`** — Not served to the browser by default; intended for build-time/parser QA and dev reference.
- **`.scenario-extract-cache/`** — Gitignored; holds the original binary and intermediate outputs. Never fetched by the UI.

---

## Indexed Scenario: Iran Strike, 2020-2030

**Slug:** `iran-strike-2020-2030`  
**Workshop ID:** 2855653232  
**DB:** DB3K_516.db3

### Available Artifacts

```
public/scenario-scan-samples/iran-strike-2020-2030.json        (metadata & sidecars)
public/scenario-scan-samples/iran-strike-2020-2030.scenario.xml (decoded XML)
fixtures/scenario-summary-samples/iran-strike-real-summary.json (Task 2 summary)
.scenario-extract-cache/Iran_Strike_2020-2030.scen              (original binary)
```

### Key Counts

| Entity | Count | Notes |
|--------|-------|-------|
| Sides | 10 | Including coalitions (United States-Israel) and special sides (Nature, Decoys-False Contacts) |
| Missions | 19 | Patrol=14, Strike=2, SupportMission=3 |
| Events | 21 | Trigger→Action pairs; 23 raw triggers with some multi-trigger events |
| Special Actions | 17 | Per-side; 9 on Israel side alone |
| Units (total) | 1189 | Aircraft=568, Facility=606, Group=8, Submarine=2, Ship=5 |
| Units (summary cap) | 500 | Claude summarizer default cap |
| Lua Script Actions | 26 | All event actions in this scenario are LuaScript type |

---

## Browser Auto-Load Design Notes for Codex

### Option A — Full XML in Browser
- **Pros:** Complete data, no backend needed after extraction.
- **Cons:** 9.5 MB XML parsed in the main thread can jank the UI.
- **Mitigation:** Use a Web Worker or streaming XML parser if adopting this path.

### Option B — Summary JSON First
- **Pros:** ~3 MB (or smaller with caps), pre-digested, fast parse.
- **Cons:** Requires Claude summarizer to have run ahead of time.
- **Where to fetch:** Currently lives in `fixtures/`. If Codex wants the browser to fetch it directly, move/copy a capped version into `public/`.

### Option C — Scan JSON + Lazy XML
- **Pros:** 37 KB scan JSON loads instantly; user gets immediate metadata.
- **Cons:** Events/units/Lua are not in the scan JSON; XML must be loaded on demand.
- **Recommended:** Use scan JSON for the file picker preview, then stream/load XML only when the user opens the scenario.

---

## Suggested Wire Flow

1. User selects `.scen` file (or picks from a list).
2. UI looks up `scenario-sidecar-index.json` by slug/hash.
3. If `public/*.json` exists → immediate metadata card (title, sides, unit count, complexity).
4. If user clicks "Open" → load `public/*.scenario.xml` in a worker, feed to `parseInternalScenarioObjectContext()`.
5. If Task 2 summary exists → merge it into Object Context for richer AI prompts.

---

## Security / Privacy Notes

- Never expose `.scen` binary paths to the browser (they sit in `.scenario-extract-cache/` and are gitignored).
- If moving summary JSON into `public/`, strip any fields that contain absolute file paths from the author's machine (`fileNamePath`, etc.).
- The scanner JSON already avoids compressed payload decoding; it is safe to serve.

---

## File Ownership

| File | Owner | Editable By |
|------|-------|-------------|
| `public/scenario-scan-samples/*` | Codex / Claude | Codex |
| `fixtures/scenario-summary-samples/*` | Claude | Codex (pull only) |
| `fixtures/scenario-sidecar-index.json` | Kimi | Kimi |
| `docs/scenario-sidecar-autoload-notes.md` | Kimi | Kimi |
