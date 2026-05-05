# CMO Scenario Folder Scan Contract

## Purpose

`tools/scan-cmo-scenario-folder.mjs` reads a `.scen` file or a workshop scenario folder and extracts only the information that is safe and useful for the Lua/Event Assistant.

It does not decode the internal `Scenario_Compressed` payload. That payload is treated as a CMO engine-owned container, so embedded events, missions, units, reference points, and Lua should be imported from CMO engine exports.

## Command

```powershell
npm run scan:scenario -- "C:\path\to\Scenario.scen" --out "public\scenario-scan-samples\scenario.json"
```

You can also pass a folder. If the folder contains a `.scen`, the scanner uses the first `.scen` by name and reads sidecar `.ini`, `.html`, and `.lua` files next to it.

## Output Shape

```json
{
  "scenario": {
    "title": "Iran Strike, 2020-2030",
    "description": "...",
    "loadDocs": ["IranStrike_Description.html"],
    "date": "2022",
    "dbVersion": "DB3K_516.db3"
  },
  "compressed": {
    "present": true,
    "status": "metadataOnly",
    "base64Chars": 1589640,
    "decodedBytes": 1192228,
    "firstBytesHex": "10 00 00 00 ..."
  },
  "sidecars": [],
  "editContext": {
    "database": {
      "family": "DB3K",
      "version": "v516"
    },
    "candidateSidesFromBriefingFiles": [],
    "supportingEvidence": [],
    "limitations": [],
    "recommendedCmoExport": []
  }
}
```

## Integration Notes

- Use `editContext` for AI request/prompt grounding.
- Treat `candidateSidesFromBriefingFiles` as hints only, not authoritative CMO side names.
- Treat `.ini` unit/mount data as supporting evidence only.
- For authoritative event/Lua editing, ask the user to export or copy from CMO Event Editor/Lua Console and combine that text with this scan JSON.
