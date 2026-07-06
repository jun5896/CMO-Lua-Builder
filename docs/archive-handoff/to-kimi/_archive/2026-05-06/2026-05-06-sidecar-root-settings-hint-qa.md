# Kimi QA Directive - Sidecar Root Settings Hint

Date: 2026-05-06
Requested by: Codex
Mode: read-only QA / focused UI wording and regression monitor

## Purpose

Verify the small Settings > Storage UI hint added in:

```text
cf77386 Add sidecar root settings hint
```

This change is intentionally tiny: it only adds user-facing guidance for the default external sidecar cache and the `CMO_SCENARIO_SIDECAR_ROOT` override.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not archive this directive; Codex will archive it after your report.
- Do not run broad scenario extraction or sidecar pruning.
- Do not change release tags.
- Treat `cf77386` as an operating UI polish commit, not a product release tag.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits `spawn EPERM`, report it as sandbox/environment unless code evidence says otherwise. Codex can rerun with approved spawn permissions.

## Expected Bundle Watch

- Main JS should remain comfortably under `400 kB` (Codex observed `366.29 kB`).
- Main CSS should remain below `60 kB` (Codex observed `58.27 kB`).
- `aiContextPruning` should remain `8.56 kB` and under the `9 kB` hard line.

## Static Checkpoints

Verify:

1. `src/App.jsx` contains the new `Scenario Sidecar Cache` hint under Settings > Storage.
2. The hint says the default external cache is `%USERPROFILE%\.codex\cmo-scenario-sidecars`.
3. The hint mentions `CMO_SCENARIO_SIDECAR_ROOT` as the override mechanism.
4. The existing sentence that original `.scen` files are not modified remains visible.
5. The command rows for audit, orphan check, orphan delete, move dry-run, and move remain unchanged.
6. No raw credential strings (`apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, `sessionStorage`) were introduced by this UI hint.
7. Manual prompt-copy fallback remains visible in the assistant.
8. Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.

## Optional Visual / Manual Check

If a browser pass is practical:

1. Open Settings.
2. Switch to the Storage section.
3. Confirm the `Scenario Sidecar Cache` card shows the new root/override hint.
4. Confirm the hint is compact and does not crowd the command list.

Static verification plus pipeline is acceptable if browser interaction is unavailable.

## Report Format

Return a compact QA report with:

- pipeline results
- bundle sizes
- static checkpoint table
- optional visual/manual result or not-run note
- any regression
- final verdict

Expected final verdict if all checks pass:

```text
APPROVED - sidecar root settings hint holds.
```
