# Final Stabilization Change Inventory - 2026-05-05

## Purpose

Record the current dirty worktree scope after the UI, AI assistant, context pruning, sidecar migration, and handoff cleanup work. This is an inventory for final protection/commit planning, not a request to commit.

## Current Verified Baseline

- Latest Kimi-approved pipeline: `git status --short`, `npm run lint`, `npm run build`, `npm run smoke:ai-adapter` all passed.
- Bundle baseline:
  - Main JS: `366.05 kB`
  - Main CSS: `58.27 kB`
  - `aiContextPruning`: `8.56 kB`
  - `PresetGuide`: `30.05 kB JS / 5.86 kB CSS`
- Scenario loader baseline:
  - `1857 ready`
  - `0 metadata`
  - `42 decoderFailed`
  - `verify:scenario-loader`: PASS, issues `0`
- Handoff top-level inboxes are clean:
  - `handoff/to-kimi/CURRENT_TASK.md`
  - `handoff/to-claude/CURRENT_TASK.md`
  - `handoff/to-gemini/CURRENT_TASK.md`

## Worktree Scope Snapshot

- Modified tracked files: `24`
- Untracked files/directories visible to Git: `29`
- Kimi archived QA files: `42`
- Claude archived directive files: `5`
- Current diff stat: `2444 insertions`, `1757 deletions`

## Recommended Protection Groups

### 1. Scenario Sidecar Storage And Loader Tooling

Purpose: keep generated sidecars out of Vite build output and move the active cache to the external local sidecar root.

Files:

- `.gitignore`
- `package.json`
- `vite.config.js`
- `tools/sidecar-paths.mjs`
- `tools/audit-cmo-scenario-openability.mjs`
- `tools/prepare-cmo-scenario-sidecar.mjs`
- `tools/prepare-cmo-scenario-batch.mjs`
- `tools/scan-cmo-scenario-folder.mjs`
- `tools/verify-cmo-scenario-loader.mjs`
- `tools/extract-cmo-scenario-xml.ps1`
- `tools/move-cmo-scenario-sidecar-root.mjs`
- `tools/prune-cmo-scenario-sidecar-cache.mjs`
- `tools/prune-cmo-scenario-xml-sidecars.mjs`
- `server/verify-transient-scenario-open.mjs`
- `docs/references/scenario-sidecar-cache-policy.md`
- `docs/agent-ops/scenario-sidecar-migration-closeout-2026-05-05.md`

Validation before protection:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run build
```

Optional if transient open is being protected in the same group:

```powershell
npm run smoke:scenario-transient
```

### 2. AI Provider Adapter And Model Profiles

Purpose: support provider model listing, provider-default generation settings, saved profile selection, and no frontend API-key persistence.

Files:

- `server/.env.example`
- `server/ai-provider-adapter.mjs`
- `server/providers.mjs`
- `src/lib/aiAdapterClient.js`
- `src/lib/aiProviderProfiles.js`
- `src/components/AiAdapterSettings.jsx`
- `src/components/AiAdapterSettings.css`
- `src/components/AiProviderProfileSelector.jsx`
- `src/components/AiProviderProfileSelector.css`

Validation before protection:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Safety checks:

- Saved profiles must not contain raw `apiKey`.
- Provider override sent from assistant must omit API keys.
- Provider model list endpoint must not leak `Authorization`, `Bearer`, or `sk-` values.

### 3. AI Assistant Chat, Review, And Context Pruning

Purpose: preserve the interpreter chat loop, structured response review, paste-ready gate, prompt-copy fallback, and context pruning safety layer.

Files:

- `public/cmo-ai-system-prompt.txt`
- `src/components/LuaAssistant.jsx`
- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiInterpreterChatPanel.css`
- `src/components/AiResponseReviewPanel.jsx`
- `src/components/AiResponseReviewPanel.css`
- `src/components/IntentPlannerPanel.jsx`
- `src/lib/aiContextPruning.js`

Validation before protection:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Safety checks:

- Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.
- Prompt-copy fallback remains visible.
- `aiContextPruning-*.js` stays under `9 kB`.
- DBID/GUID hints and confirmed identifiers are never pruned.

### 4. Preset Guide, Template Data, And CSS Lazy Split

Purpose: keep Preset Guide route-specific UI and CSS out of the main bundle, while preserving template insertion and selected-form-only preset save behavior.

Files:

- `src/App.jsx`
- `src/components/PresetGuide.jsx`
- `src/components/PresetGuide.css`
- `src/components/TemplateLibrary.jsx`
- `src/components/FeaturePalette.jsx`
- `src/components/EventEditor.jsx`
- `src/components/CodeExporter.jsx`
- `src/lib/presetLua.js`
- `src/index.css`
- `public/template-annotations.json`

Validation before protection:

```powershell
npm run lint
npm run build
```

Regression checks:

- Main CSS remains below `60 kB`.
- `PresetGuide-*.js` and `PresetGuide-*.css` are emitted as lazy chunks.
- Event/Lua Assistant does not depend on Preset Guide CSS.
- Preset Guide still saves only the currently displayed form.

### 5. Docs And Agent Handoff Evidence

Purpose: preserve the operational trail and keep active agent inboxes clean.

Files:

- `handoff/README.md`
- `handoff/to-kimi/CURRENT_TASK.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`
- `handoff/to-kimi/_archive/2026-05-05/*`
- `handoff/to-claude/_archive/2026-05-05/*`
- `docs/agent-ops/context-pruning-phase-3-closeout-2026-05-05.md`
- `docs/agent-ops/next-phase-parallel-plan-2026-05-03.md`
- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `docs/agent-ops/final-protection-staging-plan-2026-05-05.md`

Validation before protection:

```powershell
git status --short
```

Docs-only changes do not need the full pipeline unless active instructions change in a way that affects agent behavior.

## Do Not Commit As Product Data

These remain generated/local/regenerable unless Codex explicitly changes policy:

- `dist/`
- `.scenario-extract-cache/`
- project-local `scenario-sidecars/`
- external `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
- real scenario bulk sidecar JSON/XML outputs
- local `.env` files

## Recommended Final Verification Before Any Commit

```powershell
git status --short
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `npm run smoke:ai-adapter` reports `spawn EPERM`, rerun the same command with approval because the smoke harness starts a local mock server.

## Suggested Commit Order

1. Sidecar storage and loader tooling.
2. AI provider adapter and model profile support.
3. AI assistant chat/review/context-pruning safety layer.
4. Preset Guide/template/CSS lazy split.
5. Docs and handoff evidence cleanup.

This order keeps infrastructure, backend, assistant behavior, UI slimming, and evidence trail reviewable as separate conceptual units.

## Group 1 Self-Verification - 2026-05-05

Codex ran the sidecar storage and loader tooling verification pass.

Commands:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run build
npm run smoke:scenario-transient
```

Results:

- `audit:scenario-sidecars`: PASS
  - root: `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
  - index: `C:\Users\dlwls\.codex\cmo-scenario-sidecars\scenario-openability-index.json`
  - scenariosInIndex: `1899`
  - protectedByIndex: `3799` files / `3.055 GB`
  - orphans: `24` files / `5.6 MB`
- `verify:scenario-loader`: PASS
  - total: `1899`
  - counts: `1857 readyWithInternalSidecar / 42 decoderFailed`
  - issues: `0`
- `build`: PASS
  - main JS: `366.05 kB`
  - main CSS: `58.27 kB`
  - `dist` size: `2.49 MB`
  - `dist/scenario-scan-samples`: missing
  - `dist/scenario-sidecars`: missing
- `smoke:scenario-transient`: PASS after sandbox `spawn EPERM` rerun with approval
  - returned HTTP `200`
  - title: `MDSP Tutorial 4 - Attack Methods & Basic Flightplan Management`
  - temp cache before/after: `0 / 0`

Group 1 status: ready for independent Kimi read-only QA or protection staging.

## Group 1 Kimi Approval - 2026-05-05

Kimi independently verified final protection group 1 in read-only mode.

Kimi pipeline:

- `git status --short`: PASS, no deletions.
- `npm run audit:scenario-sidecars`: PASS.
- `npm run verify:scenario-loader`: PASS, issues `0`, counts `1857/42`.
- `npm run build`: PASS.
- `npm run smoke:scenario-transient`: PASS, HTTP `200`, cache `0/0`.

Kimi confirmed:

- External root and index match baseline.
- `scenariosInIndex`: `1899`.
- `protectedByIndex`: `3799` files / `3.055 GB`.
- `orphans`: `24` files / `5.6 MB`, dry-run only.
- `dist` size: `2.49 MB`.
- `dist/scenario-scan-samples`: missing.
- `dist/scenario-sidecars`: missing.
- Project-local `scenario-sidecars`: missing.
- No transient temp files left behind.

Group 1 status: approved for protection staging.

## Group 2 Self-Verification - 2026-05-05

Codex ran the AI provider adapter and model profile verification pass.

Commands:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Results:

- `lint`: PASS.
- `build`: PASS.
  - main JS: `366.05 kB`
  - main CSS: `58.27 kB`
  - `AiAdapterSettings`: `10.44 kB JS / 2.43 kB CSS`
  - `AiProviderProfileSelector`: `1.72 kB JS / 0.75 kB CSS`
  - `aiProviderProfiles`: `1.36 kB`
- `smoke:ai-adapter`: PASS after sandbox `spawn EPERM` rerun with approval.
  - forwarded upstream `401` as expected.
  - no `Bearer` or `sk-` fingerprint in adapter response or logs.

Static checks:

- `server/ai-provider-adapter.mjs` exposes `POST /api/ai/models`.
- Model list responses are passed through `deepScrubSecrets`.
- `server/providers.mjs` maps:
  - OpenAI-compatible / LM Studio: `/v1/models`
  - Ollama: `/api/tags`
- `generationMode=provider-default` suppresses temperature/max token payload fields.
- `src/lib/aiProviderProfiles.js` normalizes saved profiles without an `apiKey` field.
- `AiProviderProfileSelector` builds `providerOverride` without `apiKey`.
- `aiAdapterClient.settingsPayload()` may include `apiKey` only for Settings save/test/model-list form payloads; profile override objects do not contain a key.

Group 2 status: ready for independent Kimi read-only QA.

## Group 2 Kimi Approval - 2026-05-05

Kimi independently verified final protection group 2 in read-only mode.

Kimi pipeline:

- `git status --short`: PASS, no deletions.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS, no auth leak.

Kimi confirmed:

- Main JS/CSS match baseline: `366.05 kB / 58.27 kB`.
- `AiAdapterSettings`: `10.44 kB JS / 2.43 kB CSS`.
- `AiProviderProfileSelector`: `1.72 kB JS / 0.75 kB CSS`.
- `aiProviderProfiles`: `1.36 kB`.
- `POST /api/ai/models` routes to `handleListModels`.
- Model list responses use `deepScrubSecrets`.
- OpenAI-compatible / LM Studio use `/v1/models`; Ollama uses `/api/tags`.
- Provider-default generation mode omits temperature/max tokens.
- Manual generation mode sends temperature/max tokens.
- Saved profiles do not persist raw `apiKey`.
- Provider override from selected profiles omits raw `apiKey`.
- `apiKey` references in Settings form are expected because typed keys must be sent to the local adapter.
- Prompt-copy fallback and `isPasteReady` Lua apply gate remain intact.

Group 2 status: approved for protection staging.

## Group 3 Self-Verification - 2026-05-05

Codex ran the AI assistant chat/review/context-pruning safety verification pass.

Commands:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Results:

- `lint`: PASS.
- `build`: PASS.
  - main JS: `366.05 kB`
  - main CSS: `58.27 kB`
  - `AiInterpreterChatPanel`: `10.06 kB JS / 6.19 kB CSS`
  - `AiResponseReviewPanel`: `5.15 kB JS / 3.50 kB CSS`
  - `IntentPlannerPanel`: `5.03 kB JS`
  - `aiContextPruning`: `8.56 kB`
- `smoke:ai-adapter`: PASS after sandbox `spawn EPERM` rerun with approval.
  - no `Bearer` or `sk-` fingerprint in adapter response or logs.

Static checks:

- `public/cmo-ai-system-prompt.txt` contains the hard rules, unsafe Lua restrictions, required response headings, and ask-back requirement.
- `LuaAssistant.jsx` derives `canApplyAiLua` only from `aiParsedResponse.isPasteReady`.
- Main output toolbar, AI response toolbar, `AiResponseReviewPanel`, and `AiInterpreterChatPanel` all use the parent-owned `applyAiLuaBlock` / `canApplyAiLua` gate.
- `callAiAdapter()` blocks before AI call if the prompt lacks `## Context Pack / Pruning Audit`.
- `callAiAdapter()` dynamically imports `applyContextPruning` and `applyContextPruningAudit`.
- Context pruning hard blocks and audit failures set error status and return before `sendCmoAiPrompt`.
- `aiContextPruning.js` protects DBID/GUID hints through `confirmedIdentifiersStripped` and related hard-block paths.
- `AiResponseReviewPanel` can draft follow-up questions only when Lua is not paste-ready; it does not apply Lua directly.
- `AiInterpreterChatPanel` builds a composed prompt that reiterates required headings, ask-back behavior, and paste-ready-only Lua.
- Chat history is in module memory only and capped at `5`; no local/session storage is used.

Group 3 status: ready for independent Kimi read-only QA.

## Group 3 Kimi Approval - 2026-05-05

Kimi independently verified final protection group 3 in read-only mode.

Kimi pipeline:

- `git status --short`: PASS, no deletions.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS, no auth leak.

Kimi confirmed:

- Main JS/CSS match baseline: `366.05 kB / 58.27 kB`.
- `AiInterpreterChatPanel`: `10.06 kB JS / 6.19 kB CSS`.
- `AiResponseReviewPanel`: `5.15 kB JS / 3.50 kB CSS`.
- `IntentPlannerPanel`: `5.03 kB JS`.
- `aiContextPruning`: `8.56 kB`, below the `9 kB` hard line.
- System prompt includes no-invention, ask-back, unsafe Lua restrictions, and required headings.
- `canApplyAiLua` is derived from `isPasteReady`.
- Apply paths return/disable when `canApplyAiLua` is false.
- Review/chat panels receive parent-owned `canApplyLua` and `onApplyLua`.
- Prompt-copy fallback remains present.
- Context Pack missing, pruning hardBlock, and audit failures stop before `sendCmoAiPrompt`.
- `confirmedIdentifiersStripped` and token overflow hard blocks remain active.
- Chat history remains module-memory only and capped at `5`.

Group 3 status: approved for protection staging.

## Group 4 Self-Verification - 2026-05-05

Codex ran the Preset Guide/template/CSS lazy-split verification pass.

Commands:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Results:

- `lint`: PASS.
- `build`: PASS.
  - main JS: `366.05 kB`
  - main CSS: `58.27 kB`
  - `PresetGuide`: `30.05 kB JS / 5.86 kB CSS`
  - `AiAdapterSettings`: `10.44 kB JS / 2.43 kB CSS`
  - `AiInterpreterChatPanel`: `10.06 kB JS / 6.19 kB CSS`
  - `aiContextPruning`: `8.56 kB`
- `smoke:ai-adapter`: PASS after sandbox `spawn EPERM` rerun with approval.
  - forwarded upstream `401` as expected.
  - no `Bearer` or `sk-` fingerprint in adapter response or logs.

Static checks:

- `PresetGuide` is lazy-loaded from `App.jsx` and rendered under `Suspense` only for the guide workspace panel.
- `PresetGuide.jsx` imports `PresetGuide.css`, keeping Preset Guide route-specific styles out of `src/index.css`.
- The build emits both `PresetGuide-*.js` and `PresetGuide-*.css`.
- Main CSS is below the `60 kB` watch line.
- `public/template-annotations.json` exists and is loaded by `TemplateLibrary.jsx`.
- Preset Guide custom save uses only `selectedEvent` for the saved preset `events` array.
- Assistant template insertion appends generated Lua after existing assistant text instead of replacing it.
- Shared group descriptions still come from `FEATURE_FORM_GROUPS`.

Group 4 status: ready for independent Kimi read-only QA.

## Group 4 Kimi Approval - 2026-05-05

Kimi independently verified final protection group 4 in read-only mode.

Kimi pipeline:

- `git status --short`: PASS, no deletions.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS, no auth leak.

Kimi confirmed:

- Main JS/CSS match baseline: `366.05 kB / 58.27 kB`.
- `PresetGuide`: `30.05 kB JS / 5.86 kB CSS`.
- `AiAdapterSettings`: `10.44 kB JS / 2.43 kB CSS`.
- `AiInterpreterChatPanel`: `10.06 kB JS / 6.19 kB CSS`.
- `aiContextPruning`: `8.56 kB`, below the `9 kB` hard line.
- `PresetGuide` lazy-loads from `App.jsx` and renders under `Suspense` in the guide panel.
- `PresetGuide.jsx` imports `./PresetGuide.css`.
- Preset Guide CSS remains in a separate lazy chunk and main CSS stays below the `60 kB` watch line.
- `public/template-annotations.json` exists and `TemplateLibrary.jsx` loads it with fallback behavior.
- Custom preset save stores only the selected/displayed form.
- Custom preset button label remains `수정`.
- Assistant template insertion appends below existing text.
- Insertion palette and Builder Forms share `FEATURE_FORM_GROUPS` descriptions.
- Prompt-copy fallback and `isPasteReady` Lua apply gate remain intact.

Group 4 status: approved for protection staging.

## Group 5 Self-Verification - 2026-05-05

Codex ran the docs and agent handoff evidence verification pass.

Commands:

```powershell
git status --short
Get-ChildItem -Path handoff\to-kimi,handoff\to-claude,handoff\to-gemini -Force
Get-ChildItem -Path handoff\to-kimi\_archive\2026-05-05,handoff\to-claude\_archive\2026-05-05 -File
Select-String -Path handoff\README.md,docs\agent-ops\final-stabilization-change-inventory-2026-05-05.md -Pattern "CURRENT_TASK|archive|approved for protection staging"
```

Results:

- `git status --short`: PASS for inventory purposes.
  - modified tracked files: `24`
  - untracked files/directories visible to Git: `28` before the active Group 5 QA directive was opened.
  - no unexpected deletions observed.
- Active handoff inboxes are clean:
  - `handoff/to-kimi/CURRENT_TASK.md`
  - `handoff/to-claude/CURRENT_TASK.md`
  - `handoff/to-gemini/CURRENT_TASK.md`
- No date-stamped one-off directive remains at the top level of `to-kimi`, `to-claude`, or `to-gemini`.
- Archive counts:
  - Kimi QA handoffs: `41`
  - Claude review directives: `5`
  - Gemini: no archive needed; only `CURRENT_TASK.md` is present.
- Final protection group QA files are archived:
  - `2026-05-05-final-protection-group1-sidecar-qa.md`
  - `2026-05-05-final-protection-group2-ai-provider-qa.md`
  - `2026-05-05-final-protection-group3-ai-assistant-qa.md`
  - `2026-05-05-final-protection-group4-preset-guide-qa.md`
- `handoff/README.md` documents the active-file policy, archive layout, and completed cleanup sequence through group 4.
- `final-stabilization-change-inventory-2026-05-05.md` records groups 1-4 as Kimi-approved and approved for protection staging.
- Evidence docs are present for context pruning closeout, sidecar migration closeout, next-phase plan, and scenario sidecar cache policy.

Group 5 status: ready for independent Kimi read-only QA.

## Group 5 Kimi Approval - 2026-05-05

Kimi independently verified final protection group 5 in read-only mode.

Kimi confirmed:

- `handoff/to-kimi` top-level contained `_archive`, `CURRENT_TASK.md`, and the active Group 5 QA directive during the pass.
- `handoff/to-claude` top-level contained `_archive` and `CURRENT_TASK.md`.
- `handoff/to-gemini` top-level contained only `CURRENT_TASK.md`.
- The only open date-stamped directive during QA was the Group 5 directive itself.
- Kimi archive count: `42`.
- Claude archive count: `5`.
- `handoff/README.md` documents active file policy, archive layout, and final protection group 1-4 archival.
- The inventory records groups 1-4 as `approved for protection staging`.
- The inventory records Group 5 self-verification.
- Evidence docs exist for context pruning closeout, scenario sidecar migration closeout, next-phase plan, and scenario sidecar cache policy.
- Generated product data is not listed for commit:
  - `dist/`
  - `.scenario-extract-cache/`
  - project-local `scenario-sidecars/`
  - external `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
- No commit was created during QA.

Kimi noted one expected count drift:

- Untracked count was `29` during QA because the active Group 5 QA directive itself was present.
- After this approval, Codex archived the Group 5 directive so the agent inbox can return to clean top-level state.

Group 5 status: approved for protection staging.

## Final Full-Pipeline Verification - 2026-05-05

Codex ran the final end-to-end verification pass after final protection groups 1-5 were approved.

Commands:

```powershell
git status --short
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-adapter
```

Results:

- `git status --short`: PASS for expected dirty scope.
  - modified tracked files: `24`
  - no unexpected deletions observed.
- `audit:scenario-sidecars`: PASS.
  - root: `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
  - index: `C:\Users\dlwls\.codex\cmo-scenario-sidecars\scenario-openability-index.json`
  - scenariosInIndex: `1899`
  - protectedByIndex: `3799` files / `3.055 GB`
  - orphans: `24` files / `5.6 MB`
- `verify:scenario-loader`: PASS.
  - total: `1899`
  - counts: `1857 readyWithInternalSidecar / 42 decoderFailed`
  - issues: `0`
- `lint`: PASS.
- `build`: PASS.
  - main JS: `366.05 kB`
  - main CSS: `58.27 kB`
  - `PresetGuide`: `30.05 kB JS / 5.86 kB CSS`
  - `AiAdapterSettings`: `10.44 kB JS / 2.43 kB CSS`
  - `AiInterpreterChatPanel`: `10.06 kB JS / 6.19 kB CSS`
  - `AiResponseReviewPanel`: `5.15 kB JS / 3.50 kB CSS`
  - `IntentPlannerPanel`: `5.03 kB JS`
  - `aiContextPruning`: `8.56 kB`
- `smoke:ai-adapter`: PASS after sandbox `spawn EPERM` rerun with approval.
  - upstream `401` forwarded as expected.
  - no `Bearer` or `sk-` fingerprint in adapter response or logs.

Final verification status: PASS.
