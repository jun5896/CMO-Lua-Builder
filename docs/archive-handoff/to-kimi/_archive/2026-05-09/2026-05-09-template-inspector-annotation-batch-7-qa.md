# Kimi QA Directive - Template Inspector Annotation Batch 7

Status: ACTIVE QA REQUEST

## Target

QA target commit:

```text
80a003a Complete template inspector annotations
```

Planning commit:

```text
28b0875 Document template inspector batch 7 plan
```

Scope:

- Product/data file: `public/template-annotations.json`
- No expected changes to `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json`
- Current expected coverage after target commit: `51 / 51` annotated resources, `0` missing

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits sandbox `spawn EPERM`, report it as environment/sandbox and use Codex-provided approved rerun evidence if present.

## Expected Bundle Watch Lines

- Main JS: about `366.67 kB`, must remain `< 400 kB`
- Main CSS: about `58.27 kB`, must remain `< 60 kB`
- `aiContextPruning-*.js`: about `8.56 kB`, must remain `< 9 kB`

## JSON Coverage Check

Verify:

- `public/template-annotations.json` parses successfully.
- `manifest.templates + manifest.presets = 51`.
- `Object.keys(templateAnnotations.templates).length = 51`.
- Missing count is `0`.
- These nine Batch 7 keys exist:
  - `event_random_start_weather.tpl.lua`
  - `loadout_scramble.tpl.lua`
  - `mission_generic.tpl.lua`
  - `advanced_ops.lua`
  - `airbase_scramble.lua`
  - `cap_patrol.lua`
  - `multi_file_pack.lua`
  - `quickbattle.lua`
  - `strike_alpha.lua`

Each new annotation must include:

- `title`
- `summary`
- `beginnerNotes`
- `prerequisites`
- `safePattern`
- `aiHint`
- `checks`

## Static Checkpoints

1. Target commit changes `public/template-annotations.json` only.
2. JSON parses successfully.
3. Coverage increases from `42 / 51` to `51 / 51`.
4. Missing count decreases from `9` to `0`.
5. All nine Batch 7 keys exist.
6. All nine Batch 7 annotations include the seven required fields.
7. `event_random_start_weather.tpl.lua` warns about one-shot RegularTime startup behavior, KeyValue guard, bounded weather ranges, and player-side message target.
8. `loadout_scramble.tpl.lua` requires real aircraft DBID, Loadout ID, host base, optional mission, and launch behavior validation.
9. `mission_generic.tpl.lua` warns that generic mission kind/subtype values must be CMO-valid and may need follow-up mission-specific settings.
10. `advanced_ops.lua` warns that demo Side, RP, unit DBID, weapon DBID, coordinates, and event values must be replaced with scenario-specific values.
11. `airbase_scramble.lua` warns about UnitDetected trigger values, interceptor DBID/loadout/base checks, repeated scramble risk, and immediate launch validation.
12. `cap_patrol.lua` warns about RP box coordinates, CAP aircraft DBID, patrol zone RP names, and one-third rule validation.
13. `multi_file_pack.lua` warns about multi-file output deployment, side-file naming, and `ScenEdit_RunScript` path validation.
14. `quickbattle.lua` warns about DB3K_516 example DBIDs, randomized force generation, coordinate boxes, and replay variability.
15. `strike_alpha.lua` warns about bundled strike / KV / UnitX / DBID score / escalation / contact EMCON / scramble / weather / INST import assumptions.
16. `src/**`, `server/**`, `tools/**`, `package.json`, and `package-lock.json` are unchanged by the target commit.
17. `npm run lint` passes.
18. `npm run build` passes and bundle watch lines remain under limits.
19. `npm run smoke:ai-adapter` passes with no raw `Bearer`, `Authorization`, or `sk-` leakage.
20. Parser, adapter, context pruning, sidecar, prompt-copy fallback, and Lua apply gate behavior remain unchanged.

## Reporting

Report:

- Pipeline results
- Bundle sizes
- JSON coverage result
- Static checkpoint table
- Regression summary
- Final verdict
