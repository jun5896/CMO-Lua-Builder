# Final Protection Staging Plan - 2026-05-05

## Purpose

Convert the approved final protection groups into a safe commit/staging strategy.

This plan does not stage or commit anything by itself. It records the recommended order, exact path groups, and verification commands for the next step.

## Current Verified State

Final protection groups `1-5` are approved.

Latest full-pipeline verification:

```powershell
git status --short
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-adapter
```

Result: PASS.

Baseline:

- Main JS: `366.05 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`
- Sidecar root: `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
- Kimi archive: `42` files
- Claude archive: `5` files

## Why Not Five File-Level Commits

The conceptual protection groups remain:

1. Scenario sidecar storage and loader tooling.
2. AI provider adapter and model profiles.
3. AI assistant chat, review, and context pruning.
4. Preset Guide, template data, and CSS lazy split.
5. Docs and agent handoff evidence.

However, some files carry changes across more than one conceptual group:

- `src/App.jsx`: settings lazy split, sidecar settings, assistant insertion palette, and Preset Guide lazy split.
- `src/components/LuaAssistant.jsx`: AI provider profile selection, chat/review panels, context pruning, prompt-copy/apply gates, and insertion append behavior.
- `src/index.css`: CSS removals and remaining always-visible styles for settings, assistant, insertion palette, and Preset Guide split.
- `package.json`: scenario sidecar scripts plus smoke tooling.

Clean five-commit history would require patch-level staging. Because this environment avoids interactive git workflows, the safer practical plan is four file-level commits.

## Recommended Commit Plan

### Commit 1 - Scenario Sidecar Storage And Loader Tooling

Message:

```text
Externalize CMO scenario sidecars and loader tooling
```

Stage:

```powershell
git add -- .gitignore package.json vite.config.js `
  tools/sidecar-paths.mjs `
  tools/audit-cmo-scenario-openability.mjs `
  tools/prepare-cmo-scenario-sidecar.mjs `
  tools/prepare-cmo-scenario-batch.mjs `
  tools/scan-cmo-scenario-folder.mjs `
  tools/verify-cmo-scenario-loader.mjs `
  tools/extract-cmo-scenario-xml.ps1 `
  tools/move-cmo-scenario-sidecar-root.mjs `
  tools/prune-cmo-scenario-sidecar-cache.mjs `
  tools/prune-cmo-scenario-xml-sidecars.mjs `
  server/verify-transient-scenario-open.mjs `
  docs/references/scenario-sidecar-cache-policy.md `
  docs/agent-ops/scenario-sidecar-migration-closeout-2026-05-05.md
```

Verify after staging:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run build
```

Optional:

```powershell
npm run smoke:scenario-transient
```

### Commit 2 - AI Provider And Assistant Safety Layer

Message:

```text
Add AI provider profiles and assistant safety workflow
```

Stage:

```powershell
git add -- server/.env.example `
  server/ai-provider-adapter.mjs `
  server/providers.mjs `
  public/cmo-ai-system-prompt.txt `
  src/lib/aiAdapterClient.js `
  src/lib/aiProviderProfiles.js `
  src/lib/aiContextPruning.js `
  src/components/AiAdapterSettings.jsx `
  src/components/AiAdapterSettings.css `
  src/components/AiProviderProfileSelector.jsx `
  src/components/AiProviderProfileSelector.css `
  src/components/AiInterpreterChatPanel.jsx `
  src/components/AiInterpreterChatPanel.css `
  src/components/AiResponseReviewPanel.jsx `
  src/components/AiResponseReviewPanel.css `
  src/components/IntentPlannerPanel.jsx `
  src/components/LuaAssistant.jsx `
  docs/agent-ops/context-pruning-phase-3-closeout-2026-05-05.md
```

Verify after staging:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Safety checks:

- Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.
- Prompt-copy fallback remains present.
- `aiContextPruning-*.js` remains under `9 kB`.
- Provider profile overrides do not carry raw API keys.

### Commit 3 - Preset Guide Lazy Split And Template Assets

Message:

```text
Lazy split Preset Guide and template assets
```

Stage:

```powershell
git add -- src/App.jsx `
  src/index.css `
  src/components/CodeExporter.jsx `
  src/components/EventEditor.jsx `
  src/components/FeaturePalette.jsx `
  src/components/PresetGuide.jsx `
  src/components/PresetGuide.css `
  src/components/TemplateLibrary.jsx `
  src/lib/presetLua.js `
  public/template-annotations.json
```

Verify after staging:

```powershell
npm run lint
npm run build
```

Regression checks:

- Main CSS remains below `60 kB`.
- `PresetGuide-*.js` and `PresetGuide-*.css` are emitted.
- Template insertion appends below existing Lua text.
- Preset Guide saves only the selected/displayed form.

### Commit 4 - Docs And Agent Handoff Evidence

Message:

```text
Record final protection QA and agent handoff evidence
```

Stage:

```powershell
git add -- handoff/README.md `
  handoff/to-kimi/CURRENT_TASK.md `
  handoff/to-claude/CURRENT_TASK.md `
  handoff/to-gemini/CURRENT_TASK.md `
  handoff/to-kimi/_archive `
  handoff/to-claude/_archive `
  docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md `
  docs/agent-ops/final-protection-staging-plan-2026-05-05.md `
  docs/agent-ops/next-phase-parallel-plan-2026-05-03.md
```

Verify after staging:

```powershell
git status --short
```

## Final Verification Before Push Or Release

Run once after all commits are made:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` fails with `spawn EPERM`, rerun the same command with approval because the harness starts a local mock server.

## Do Not Stage

Do not stage generated or local product data:

- `dist/`
- `.scenario-extract-cache/`
- project-local `scenario-sidecars/`
- external `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
- real scenario bulk JSON/XML sidecars
- local `.env` files

## Alternative If Exact Five Commits Are Required

Exact conceptual five-commit history is possible only with patch-level staging for:

- `src/App.jsx`
- `src/components/LuaAssistant.jsx`
- `src/index.css`
- `package.json`

Use that route only if the user explicitly requests patch-level commit splitting. Otherwise prefer the four file-level commits above.
