# CMO Scenario XML Extraction

## Purpose

Some `.scen` files expose only top-level XML plus a high-entropy `Scenario_Compressed` block. That block is not a plain gzip/zlib/deflate stream. CMO itself can decode it through its internal `Command_Core.ScenContainer` loader.

`tools/extract-cmo-scenario-xml.ps1` uses that local CMO loader in read-only mode to export the internal `<Scenario>` XML for downstream analysis.

## Command

```powershell
npm run extract:scenario-xml -- "C:\path\to\Scenario.scen" --OutXml "C:\Codex\scenario.xml"
```

Direct PowerShell form:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\extract-cmo-scenario-xml.ps1 `
  "C:\path\to\Scenario.scen" `
  -OutXml "C:\Codex\scenario.xml"
```

## Safety Model

- The original `.scen` is not modified.
- The tool copies the scenario into `.scenario-extract-cache` first because CMO's internal loader can be denied direct access to Steam Workshop paths under sandboxing.
- The tool loads `Command.exe` and required local DLLs from the installed CMO folder.
- No network calls are made.

## Current Verification

Verified against:

`C:\Program Files (x86)\Steam\steamapps\workshop\content\1076160\2855653232\Iran Strike, 2020-2030.scen`

Result:

- internal XML extracted successfully
- title: `Iran Strike, 2020-2030`
- extracted XML length: `9,495,172` characters

## Notes

This is not a general-purpose decryption implementation. It delegates decoding to the locally installed CMO engine, which is safer and version-compatible with the user's installed build.
