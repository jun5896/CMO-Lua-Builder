# CURRENT TASK - Kimi

Status: QA / regression monitor / commit-hygiene watcher

## Active State

- No date-stamped Kimi QA directive is currently open.
- Wait for a Codex-created handoff before running focused QA.
- Do not edit files and do not commit.
- Treat archived files under `_archive/` as evidence only, not active instructions.

## Latest Protected Baseline

Latest local protected HEAD:

```text
6272ab9 Polish AI assistant and sidecar UX wording
```

Recent protection commits:

- `c668206` Externalize CMO scenario sidecars and loader tooling
- `4698bde` Add AI provider profiles and assistant safety workflow
- `6d57cae` Lazy split Preset Guide and template assets
- `e34132a` Record final protection QA and agent handoff evidence
- `f3eec7c` Refresh agent CURRENT_TASK baselines
- `6272ab9` Polish AI assistant and sidecar UX wording

Accepted bundle baseline:

- Main JS: `366.01 kB`
- Main CSS: `58.27 kB`
- `PresetGuide`: `30.05 kB JS / 5.86 kB CSS`
- `AiAdapterSettings`: `10.44 kB JS / 2.43 kB CSS`
- `AiInterpreterChatPanel`: `10.08 kB JS / 6.19 kB CSS`
- `AiResponseReviewPanel`: `5.15 kB JS / 3.50 kB CSS`
- `IntentPlannerPanel`: `5.03 kB JS`
- `aiContextPruning`: `8.56 kB`

Latest post-commit verification (`6272ab9`):

- `npm run audit:scenario-sidecars`: PASS (`1899` in index, `3799` protected, `24` orphans / `5.6 MB`)
- `npm run verify:scenario-loader`: PASS (`1857` ready / `42` decoderFailed, issues `0`)
- `npm run lint`: PASS
- `npm run build`: PASS (`366.01 kB JS / 58.27 kB CSS`)
- `npm run smoke:ai-adapter`: PASS after approved spawn permissions; no `Bearer` / `sk-` leak

Watch lines:

- Main JS must stay under `400 kB`.
- Main CSS should stay below `60 kB`; report any rise above `60 kB` as regression.
- `aiContextPruning` must stay under `9 kB`; no pruning expansion unless Codex opens a task.

## Scenario / Sidecar Baseline

Current local verification baseline:

- Total `.scen`: `1899`
- `readyWithInternalSidecar`: `1857`
- `metadataOnlyNeedsDecoder`: `0`
- `decoderFailed`: `42`
- `verify:scenario-loader`: PASS, issues `0`

External sidecar root:

```text
C:\Users\dlwls\.codex\cmo-scenario-sidecars
```

Sidecar rules:

- Generated sidecars are local/regenerable.
- Do not delete sidecars or orphans unless Codex/user explicitly asks.
- Do not run broad `--all` extraction. Prefer Codex-selected official folders or explicit targets.
- `decoderLegacyCmano` is a known legacy limitation, not a fresh blocker.

## Standard QA Pipelines

Default code/UI/AI change:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

Scenario/sidecar/tooling change:

```powershell
git status --short
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run build
```

Full final verification:

```powershell
git status --short
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits `spawn EPERM`, report it as sandbox/environment unless code evidence says otherwise. Codex can rerun with approved spawn permissions.

## Safety Contracts To Watch

- Lua apply is enabled only when `aiParsedResponse.isPasteReady === true`.
- Manual prompt-copy fallback must remain visible.
- AI adapter smoke must not leak raw `Bearer`, `Authorization`, or `sk-` values.
- Saved provider profiles must not persist raw `apiKey`.
- Context pruning must preserve DBID/GUID hints and hard-block stripping.
- Preset Guide custom save stores only the currently displayed form.
- Assistant template insertion appends below existing Lua text; it must not replace user content.

## Reporting Format

Keep reports compact:

- pipeline pass/fail
- bundle sizes
- scenario counts if relevant
- exact regression if any
- no broad refactor proposals unless Codex opens that task

## Boundaries

- Do not modify `src/**`, `server/**`, `tools/**`, `package.json`, docs, or handoff files.
- Do not commit.
- Do not install Vitest or introduce new test frameworks.
- Do not mass-decode scenario folders.
- Do not classify excluded user workspace files as official scenario defects.
