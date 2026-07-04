# Scenario Batch Report - 2026-05-03

## Purpose

Validate the new parallel sidecar workflow:

```powershell
npm run prepare:scenario-batch -- --all --limit 5 --concurrency 2
```

The web UI does not directly decompress every `.scen`. It reads scenario metadata first, then auto-links generated sidecars created by `prepare:scenario` or `prepare:scenario-batch`.

## Result

- selected: 5
- concurrency: 2
- succeeded: 3
- failed: 2
- final loader verdict: pass
- final counts:
  - `readyWithInternalSidecar`: 12
  - `metadataOnlyNeedsDecoder`: 1923
  - `readError`: 0

## Successful Scenarios

- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\800808.scen`
- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴더 1\231.scen`
- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴더 1\232.scen`

## Failed Scenarios

- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴더 1\9. Deja Vu.scen`
- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴더 1\새 폴더\Deja Vu, 1990.scen`

Common failure:

```text
CMO internal loader did not return Scenario XML.
```

## Interpretation

The batch runner works. The first real sample shows that some `.scen` files can still fail at the CMO decoder stage even when metadata scanning succeeds.

This initially looked like a decoder-result classification problem, but the root cause was identified and patched:

- CMO returned decoded XML rooted at `<ContentScenario>` instead of `<Scenario>`.
- `extract-cmo-scenario-xml.ps1` rejected that root and reported `CMO internal loader did not return Scenario XML.`
- `summarize-cmo-scenario-xml.mjs` also only treated `<Scenario>` as the root for direct metadata harvesting.
- Duplicate file names such as `9. Deja Vu.scen` could collide on the same sidecar slug.
- Duplicate file names could also collide in `.scenario-extract-cache` during parallel extraction.

Patches applied:

- Allow `<ContentScenario>` as a supported decoded XML root.
- Harvest root metadata from `<Scenario>` or `<ContentScenario>`.
- Add path-hash suffixes for duplicate scenario file slugs.
- Pass the audited slug into `prepare:scenario` from batch mode.
- Add path-hash suffixes to cached scenario copies to avoid parallel file locks.

Follow-up verification:

- `npm run prepare:scenario-batch -- --match "9. Deja Vu" --concurrency 2`
- result: `2/2` succeeded
- both rows now use unique sidecars:
  - `9.-deja-vu-1b335d6b.*`
  - `9.-deja-vu-f6f53aba.*`
- final counts:
  - `readyWithInternalSidecar`: 14
  - `metadataOnlyNeedsDecoder`: 1921
  - `readError`: 0
- `npm run verify:scenario-loader`: pass
- `npm run lint`: pass
- `npm run build`: pass
- `npm run smoke:ai-adapter`: pass

## Recommended Agent Split

- Codex: primary implementation, final integration, and batch command hardening.
- Kimi: repeatable QA report, status deltas, command safety, commit classification.
- Claude: standby for future true decoder failures; this specific failure class is resolved.
- Gemini: user-facing explanation, small sample extraction review, beginner guidance for failed decoder cases.

## Safe Batch Policy

- Use `--dry-run` first.
- Use `--concurrency 2` by default.
- Use `--limit` for `--all`.
- Do not mass-extract all metadata-only scenarios without explicit approval.

## User Workspace Exclusions

The following local folders are user editing/experiment workspaces and are excluded from the default scenario openability audit and batch index:

- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴더`
- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴더 1`
- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴더 2`
- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\새 폴더 backup`
- `C:\Program Files (x86)\Steam\steamapps\common\Command - Modern Operations\Scenarios\시뮬레이션`

Reason:

- These folders may contain partially edited files, DB-substitution tests, unit-only stubs, or empty event shells.
- They should not be treated as official/library scenario quality problems.
- To include them intentionally, run the audit with `--include-user-workspaces`.

Verification after exclusion:

- total scenarios: `1899`
- excluded folder hits in the index: `0`
- `readyWithInternalSidecar`: `8`
- `metadataOnlyNeedsDecoder`: `1891`
- `readError`: `0`
- `npm run verify:scenario-loader`: pass
- `npm run prepare:scenario-batch -- --match "Deja Vu" --concurrency 2 --dry-run`: selected `0` metadata-only rows, because the remaining official `Red Tide\9. Deja Vu.scen` is already ready.

## Follow-Up Official/Workshop Batch Validation

Codex ran two controlled batches after user workspace exclusions:

### Official Red Tide sample

Command:

```powershell
npm run prepare:scenario-batch -- --path-contains "Scenarios\Red Tide" --limit 5 --concurrency 2
```

Result:

- selected: 5
- succeeded: 5
- failed: 0
- all 5 decoded as `ContentScenario`
- sampled scenarios:
  - `1. The Bedford Incident.scen`
  - `10. Midway.scen`
  - `11. Hells Highway.scen`
  - `12. End Game.scen`
  - `2. Kobayashi Maru.scen`

### Workshop sample

Command:

```powershell
npm run prepare:scenario-batch -- --path-contains "workshop\content\1076160" --limit 5 --concurrency 2
```

Result:

- selected: 5
- succeeded: 5
- failed: 0
- all 5 decoded as `Scenario`
- sampled scenarios:
  - `United Kingdom and Ireland.scen`
  - `Greece Airbase and Naval Base.scen`
  - `Germany Air Base and AD.scen`
  - `Turkey Naval Base.scen`
  - `ANZAC.scen`

Final post-validation counts:

- total scenarios: `1899`
- `readyWithInternalSidecar`: `18`
- `metadataOnlyNeedsDecoder`: `1881`
- `readError`: `0`

Final verification:

- `npm run verify:scenario-loader`: pass
- `npm run lint`: pass
- `npm run build`: pass
- `npm run smoke:ai-adapter`: pass

Interpretation:

- The `ContentScenario` fix is validated on official Red Tide scenarios.
- Standard `Scenario` extraction is validated on Workshop scenarios.
- No true decoder failure appeared after excluding user experiment folders.
