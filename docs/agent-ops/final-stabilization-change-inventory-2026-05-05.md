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

## Post-Release QA Workflow Closeout - 2026-05-07

Codex closed the QA workflow release as the current public operating baseline.

Release:

- Tag: `release-2026-05-06-cmo-lua-builder-qa-workflow`.
- Tagged commit: `e5cd403 Mark QA workflow release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-06-cmo-lua-builder-qa-workflow`.
- Release title: `CMO Lua Builder QA Workflow Release`.
- Kimi release-tag QA: APPROVED, no regression.

Current final verification entrypoint:

```powershell
npm run verify:release
```

Current closeout reference:

```text
docs/agent-ops/qa-workflow-release-closeout-2026-05-07.md
```

Post-release baseline:

- Main JS: `366.29 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `sk-` leakage.

Post-release status: closed and documented.

## Post-Release AI Follow-Up Needs Review Closeout - 2026-05-09

Codex closed Track A2-2 as an approved local AI interpreter/editor operating slice.

Current public release remains:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Tagged commit: `004325d Mark template inspector search filter release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.

A2-2 commits:

- Design commit: `f587645 Add AI follow-up needs design`.
- Implementation plan commit: `688b611 Add AI follow-up needs implementation plan`.
- Contract/helper commit: `64683a0 Add AI follow-up needs contract`.
- Product commit: `b32c780 Add AI follow-up needs review`.
- Kimi QA directive commit: `064fcae Add AI follow-up needs QA directive`.
- Kimi QA archive commit: `33aec2f Archive AI follow-up needs QA`.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-follow-up-needs-qa.md`.

Current closeout reference:

```text
docs/agent-ops/ai-follow-up-needs-review-closeout-2026-05-09.md
```

Kimi QA result:

- `npm run smoke:ai-follow-up-needs`: PASS.
- `npm run smoke:ai-workflow-state`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, no auth leakage.
- Sandbox escalation: not needed.
- Static checkpoints: `34 / 34` PASS.
- Regression: none.

A2-2 baseline:

- Main JS: `371.44 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- `AiResponseReviewPanel` lazy JS / CSS: `10.08 kB` / `5.23 kB`.

A2-2 status:

- Review panel now groups CMO confirmation needs under `CMO에서 확인할 값`.
- Detection covers Side, Mission, Unit GUID, DBID, Loadout, RP / Zone, Posture / Doctrine / EMCON, Coordinates, Weather, Response Format, and Unsafe Lua.
- Visible categories are limited to 6 and evidence stays behind `<details>`.
- Follow-up draft includes grouped needs and no-invention wording.
- Follow-up drafting remains text-only; no automatic send was introduced.
- Lua apply remains gated by parent `canApplyLua` / `aiParsedResponse.isPasteReady`.
- Parser, adapter, context pruning, scenario-loader, sidecar, backend, package-lock, dependency, credential, and storage boundaries remain unchanged.
- Track B remains deferred.
- Main CSS is below but close to the `60 kB` soft line with about `0.86 kB` headroom.

Post-A2-2 status: closed and ready for docs/handoff-only QA.

## Post-Release AI Drafting Workflow A2 Completion Checklist - 2026-05-09

Codex documented A2 completion as a local AI interpreter workflow baseline.

Current public release remains:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Tagged commit: `004325d Mark template inspector search filter release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.

Current checklist reference:

```text
docs/agent-ops/ai-drafting-workflow-a2-completion-checklist-2026-05-09.md
```

A2 included:

- A2-1 workflow state: `eb689df Align AI drafting workflow state`.
- A2-2 follow-up needs: `b32c780 Add AI follow-up needs review`.

A2 completion verdict:

- Local AI drafting workflow baseline is complete.
- The UI can move from intent/template context to AI request, parser state, ready/ask-back/blocker/error handling, grouped confirmation needs, text-only follow-up draft, paste-ready-only Working Draft application, and CMO engine verification reminder.
- Track B remains deferred.
- Track A is not fully closed yet; recommended next step is A3 Local Confirmed Context Workspace.

Codex verification:

- `npm run verify:release`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- Sidecar audit: `1899` scenarios in index, `3799` protected files, `24` orphans / about `5.6 MB`, dry-run only.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS, no raw auth leakage.

Current A2 baseline:

- Main JS: `371.44 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- `AiInterpreterChatPanel` lazy JS / CSS: `10.38 kB` / `6.73 kB`.
- `AiResponseReviewPanel` lazy JS / CSS: `10.08 kB` / `5.23 kB`.

Watch note:

- Main CSS remains under `60 kB` but has only about `0.86 kB` headroom.

## Post-Release Local Confirmed Context Workspace Closeout - 2026-05-09

Codex closed Track A3 as a local AI editor workspace improvement.

Closeout reference:

```text
docs/agent-ops/local-confirmed-context-workspace-closeout-2026-05-09.md
```

Product commits:

- `953317a Add confirmed context helper contract`.
- `864e36b Wire confirmed context into assistant state`.
- `72cca75 Add confirmed context workspace UI`.
- `3772866 Use confirmed context in follow-up drafts`.

Kimi QA:

- APPROVED / ARCHIVED.
- Static checkpoints: `29 / 29` PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-workspace-qa.md`.
- Regression: none.

Delivered:

- Source-labeled confirmed CMO values.
- Prompt section `## User-confirmed CMO values`.
- Existing temp session/autosave persistence only.
- Context tab Confirmed Context Workspace UI.
- Text-only follow-up draft reuse of confirmed values.

Verification:

- `npm run smoke:ai-confirmed-context`: PASS.
- `npm run smoke:ai-follow-up-needs`: PASS.
- `npm run smoke:ai-workflow-state`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage.

Bundle baseline:

- Main JS: `377.99 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- `AiResponseReviewPanel`: `10.15 kB JS / 5.23 kB CSS`.
- `AiInterpreterChatPanel`: `10.38 kB JS / 6.73 kB CSS`.

Invariants:

- Track B remains deferred.
- No backend endpoint, CMO filesystem read/write, log tailing, sidecar writer, live read-back, dependency, lockfile, or `src/index.css` change.
- `aiParsedResponse.isPasteReady` remains the only Lua apply gate.
- Prompt-copy fallback remains available.

## Post-Release Local Confirmed Context Release Closeout - 2026-05-09

Codex promoted Track A3 Local Confirmed Context Workspace to the current public release.

Release:

- Tag: `release-2026-05-09-cmo-lua-builder-local-confirmed-context`.
- Tagged commit: `85ccada Mark local confirmed context release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-local-confirmed-context`.
- Release title: `CMO Lua Builder Local Confirmed Context Workspace`.

Closeout reference:

```text
docs/agent-ops/local-confirmed-context-release-closeout-2026-05-09.md
```

Kimi release QA:

- APPROVED / ARCHIVED.
- Static checkpoints: `28 / 28` PASS.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-local-confirmed-context-release-tag-qa.md`.
- Regression: none.

Verification:

- `npm run verify:release`: PASS with expanded 9-step chain.
- Sidecar audit: `3799` protected / `24` orphans / `5.6 MB`, dry-run only.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- AI workflow state smoke: PASS.
- AI follow-up needs smoke: PASS.
- AI confirmed context smoke: PASS.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS, no raw auth leakage.

Bundle baseline:

- Main JS: `377.99 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.

Invariants:

- Tagged commit changes `README.md` and `package.json` only.
- `package-lock.json`, `src/**`, `server/**`, `public/**`, and `tools/**` unchanged in the tagged commit.
- Release notes record no backend endpoint, no CMO filesystem writes, no log tailing, no live read-back, and no raw Bearer / Authorization / `sk-` leakage.

## Post-Release Track A Local AI Interpreter Completion Checklist - 2026-05-09

Codex documented Track A completion as a local AI interpreter UI baseline.

Checklist reference:

```text
docs/agent-ops/track-a-local-ai-interpreter-completion-checklist-2026-05-09.md
```

Current public release:

- Tag: `release-2026-05-09-cmo-lua-builder-local-confirmed-context`.
- Tagged commit: `85ccada Mark local confirmed context release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-local-confirmed-context`.

Completion scope:

- A1 Template Inspector Search / Filter UX.
- A2 AI Drafting Workflow.
- A3 Local Confirmed Context Workspace.

Verdict:

- Track A is complete as a local AI interpreter UI baseline.
- Completion does not claim CMO Lua execution, live read-back, scenario folder writes, log tailing, or sidecar Lua deployment.
- Track B should start with B0 CMO Integration Probe.

Verification:

- `npm run verify:release`: PASS.
- Expanded 9-step chain includes sidecar audit, scenario loader, lint, build, workflow-state smoke, follow-up-needs smoke, confirmed-context smoke, AI client parser smoke, and AI adapter smoke.
- Bundle baseline: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scenario baseline: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected / `24` orphans / `5.6 MB`, dry-run only.

## Post-Release Track A Local AI Interpreter Completion Closeout - 2026-05-09

Codex archived the Track A completion checklist QA and recorded the local interpreter closeout.

Closeout reference:

```text
docs/agent-ops/track-a-local-ai-interpreter-completion-closeout-2026-05-09.md
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-track-a-completion-checklist-qa.md
```

Kimi result:

- Target commit: `0266f33 Document Track A local interpreter completion`.
- Verdict: APPROVED, no regression.
- Static checkpoints: `25 / 25 PASS`.
- Scope: docs / handoff only.

Closeout status:

- Track A is closed as a local AI interpreter UI baseline.
- Completed slices: A1 Template Inspector Search / Filter UX, A2 AI Drafting Workflow, and A3 Local Confirmed Context Workspace.
- This closeout does not claim CMO Lua execution, live CMO read-back, scenario folder writes, log tailing, sidecar Lua deployment, or automatic AI follow-up sending.
- Recommended next step: Track B0 CMO Integration Probe.

Protected baseline remains:

- Current public release: `release-2026-05-09-cmo-lua-builder-local-confirmed-context`.
- Main JS: `377.99 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario baseline: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected / `24` orphans / `5.6 MB`, dry-run only.

## Track B0 CMO Integration Probe - 2026-05-09

Codex opened Track B with a dry-run local CMO environment probe.

Reference:

```text
docs/agent-ops/cmo-integration-probe-b0-2026-05-09.md
```

Plan:

```text
docs/superpowers/plans/2026-05-09-cmo-integration-probe.md
```

New commands:

```powershell
npm run probe:cmo-integration
npm run smoke:cmo-integration-probe
```

Scope:

- `tools/probe-cmo-integration.mjs` detects CMO root, Scenarios root, Logs root, write-access capability, log file patterns, safe path prefixes, and the manual `.lua` auto-load verification gap.
- `tools/verify-cmo-integration-probe-contract.mjs` provides a fixture-based smoke test.
- No backend endpoint, scenario write, log tail, live read-back, AI send, or CMO mutation is introduced.

Local probe result:

- CMO root: PASS.
- Scenarios root: PASS.
- Logs root: PASS.
- Scenario folder write access: PASS by `fs.access` only; no file written.
- `ExceptionLog_*.txt`: PASS, 9 files observed.
- `LuaHistory_*.txt`: WARN, no files observed yet.
- Scenario-folder `.lua` auto-load: MANUAL verification still required.
- Safe path prefixes: PASS.
- Summary: `6 pass / 1 warn / 0 fail / 1 manual / 0 unknown`.

TDD evidence:

- RED: `npm run smoke:cmo-integration-probe` failed with missing `tools/probe-cmo-integration.mjs`.
- GREEN: `npm run smoke:cmo-integration-probe` passed after implementation.
- `npm run lint`: PASS.
- `npm run build`: PASS, Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- `npm run smoke:ai-adapter`: PASS, no raw Bearer / Authorization / `sk-` leakage.

Next gate:

- Kimi QA should verify dry-run boundaries and confirm B1/B2 remain blocked on the manual `.lua` auto-load check.

## Track B0 CMO Integration Probe Closeout - 2026-05-10

Codex archived the B0 probe QA and recorded the approved capability matrix.

Closeout reference:

```text
docs/agent-ops/cmo-integration-probe-b0-closeout-2026-05-10.md
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-09/2026-05-09-b0-cmo-integration-probe-qa.md
```

Kimi result:

- Target commit: `c950ecd Add B0 CMO integration probe`.
- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Pipeline: `smoke:cmo-integration-probe`, lint, build, and AI adapter smoke all PASS.

Approved B0 capability matrix:

- CMO root: PASS.
- Scenarios root: PASS.
- Logs root: PASS.
- Scenario folder write access: PASS by `fs.access` only.
- `ExceptionLog_*.txt`: PASS.
- `LuaHistory_*.txt`: WARN, no matching files observed yet.
- Scenario-folder `.lua` auto-load: MANUAL, not proven.
- Safe path prefixes: PASS.
- Summary: `6 pass / 1 warn / 0 fail / 1 manual / 0 unknown`.

Preserved boundaries:

- No file write/delete.
- No `.scen` mutation.
- No backend endpoint.
- No log tailing or CMO polling.
- No AI request.
- No claim that `.lua` auto-load is proven.

Next recommended slice:

- B0.1 disposable Lua-root load check, or keep B2 on an explicit `ScenEdit_RunScript(...)` loader-snippet model.

## Track B0.1 CMO Lua Load Check Prep - 2026-05-10

Codex opened B0.1 as a safe preparation slice for verifying CMO scenario-folder `.lua` load behavior.

Reference:

```text
docs/agent-ops/cmo-lua-load-check-b0-1-2026-05-10.md
```

Plan:

```text
docs/superpowers/plans/2026-05-10-cmo-lua-load-check.md
```

New commands:

```powershell
npm run probe:cmo-lua-load-check
npm run smoke:cmo-lua-load-check
```

Scope:

- `tools/prepare-cmo-lua-load-check.mjs` generates a harmless `AiAssist_B0LoadCheck.lua` file and manual `ScenEdit_RunScript('/AiAssist_B0/...')` loader snippet.
- Default mode is dry-run and writes no file.
- Actual write now requires `--cmo-lua-root`, `--write`, and `--yes`.
- File name is restricted to `AiAssist_B0*.lua`.
- No backend endpoint, CMO polling, log tailing, AI send, or automatic execution is introduced.

TDD evidence:

- RED: `npm run smoke:cmo-lua-load-check` failed with missing `tools/prepare-cmo-lua-load-check.mjs`.
- GREEN: `npm run smoke:cmo-lua-load-check` passed after implementation.
- Dry-run: `npm run probe:cmo-lua-load-check -- --json` returned `mode: dry-run` and `wroteFile: false`.
- `npm run lint`: PASS.
- `npm run build`: PASS, Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- `npm run smoke:ai-adapter`: PASS, no raw Bearer / Authorization / `sk-` leakage.

Generated Lua safety:

- Prints a marker only.
- Does not call `ScenEdit_SetKeyValue`, `os.*`, `io.*`, `require`, or file mutation APIs.
- Does not claim `.lua` auto-load is proven.

Next gate:

- Kimi QA should verify B0.1 boundaries before any disposable scenario write is attempted.

## Track B0.1 CMO Lua Load Check Closeout - 2026-05-10

Codex archived the B0.1 QA directive and recorded the approved load-check preparation boundary.

Closeout reference:

```text
docs/agent-ops/cmo-lua-load-check-b0-1-closeout-2026-05-10.md
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b0-1-cmo-lua-load-check-qa.md
```

Kimi result:

- Target commit: `67043ca Add B0.1 CMO Lua load check`.
- Verdict: APPROVED, no regression.
- Static checkpoints: `40 / 40 PASS`.
- Pipeline: `smoke:cmo-lua-load-check`, lint, build, and AI adapter smoke all PASS.

Approved B0.1 boundary:

- Default mode is dry-run.
- Default dry-run writes no files.
- Revised actual write requires `--cmo-lua-root`, `--write`, and `--yes`.
- File namespace is restricted to `AiAssist_B0*.lua`.
- Generated Lua contains marker + `print(marker)` only.
- Loader snippet uses `ScenEdit_RunScript('/AiAssist_B0/...')`.
- No `src/**`, `server/**`, dependency, lockfile, backend endpoint, polling, log tailing, live read-back, or AI auto-send change.

Protected baseline:

- Main JS: `377.99 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- AI adapter smoke: no raw Bearer / Authorization / `sk-` leakage.

Next gate:

- User-approved CMO manual check found `dofile(...)` is nil in the Build 1868 console sandbox.
- Explicit `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` from the CMO Lua root returned `Yes` and printed the marker `AiAssist_B0RunScript_20260510_0448`.
- Scenario-folder auto-load remains unproven; B2 must use the explicit `ScenEdit_RunScript(...)` model as the safe default.

RunScript correction QA:

- QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b0-1-runscript-loader-correction-qa.md`.
- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Pipeline: `smoke:cmo-lua-load-check`, `smoke:cmo-integration-probe`, lint, build, and AI adapter smoke all PASS.
- Bundle baseline: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Source / package / public drift: none.
- Backend endpoint, polling, tailing, sidecar writer, and read-back remain absent.

## CMO Build 1868 / DB517 Refresh Closeout - 2026-05-10

Codex closed the urgent CMO Build 1868 / DB517 local reference refresh before returning to B0.1 manual CMO load-check work.

Closeout reference:

```text
docs/agent-ops/cmo-build-1868-db517-refresh-closeout-2026-05-10.md
```

Release-notes draft:

```text
docs/agent-ops/cmo-build-1868-db517-refresh-release-notes-2026-05-10.md
```

QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-refresh-qa.md
```

Closeout docs QA archive:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-cmo-build-1868-db517-closeout-docs-qa.md
```

Kimi result:

- Target commit: `f7a696a Refresh CMO DB517 references`.
- Verdict: APPROVED, no regression.
- Static checkpoints: `32 / 32 PASS`.
- Pipeline: lint, build, and AI adapter smoke all PASS.
- Closeout docs QA: APPROVED / ARCHIVED, `34 / 34` static checkpoints PASS; docs / handoff only, no source or package drift.

Refreshed DB baseline:

- Official source: `https://forums.matrixgames.com/viewtopic.php?t=417070`.
- Scanner latest: `CMO v1.09 Build 1868 (Public Beta)`.
- Latest DB3K: `DB3K_517.db3`.
- Latest CWDB: `CWDB_517.db3`.
- Component entries: `101078`.
- DB3K references: `72796`.
- CWDB references: `28282`.
- Generated DB asset delta: `+2 / ~0 / -0`.

Preserved boundaries:

- No `src/**` or `server/**` behavior change.
- No backend endpoint, CMO polling, log tailing, sidecar writer, live read-back, dependency, or lockfile change.
- Manual prompt-copy fallback and `aiParsedResponse.isPasteReady` Lua apply gate remain unchanged.
- Template Inspector coverage remains `51 / 51`, `0 missing`.

Next gate:

- DB517 closeout docs QA is complete and archived.
- After archive/commit, return to B2 planning around the proven CMO Lua-root `ScenEdit_RunScript(...)` execution path.

## B2 RunScript Sidecar Writer Planning - 2026-05-10

Codex opened the B2 planning gate after B0.1 proved CMO Lua-root `ScenEdit_RunScript(...)` and disproved `dofile(...)`.

Design / plan references:

```text
docs/superpowers/specs/2026-05-10-b2-runscript-sidecar-writer-design.md
docs/superpowers/plans/2026-05-10-b2-runscript-sidecar-writer.md
docs/agent-ops/b2-runscript-sidecar-writer-planning-2026-05-10.md
```

Completed review / QA:

```text
handoff/to-claude/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-design-review.md
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-plan-qa.md
```

Review / QA result:

- Kimi planning QA: APPROVED, `34 / 34` static checkpoints PASS; docs / handoff only, no source or package drift.
- Claude design review: APPROVED with minor refinements; Codex may proceed to B2.1 writer-helper implementation.
- Claude review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B2-RunScript-Sidecar-Writer\b2-runscript-sidecar-writer-review.md`.
- Accepted refinements folded into the spec / plan: server-confirmed `confirmedDryRun` / `confirmedWrite`, response omits Lua body, malicious request-body `cmoLuaRoot` ignored, existing-file UX copy, `AiAssist_B0` sibling namespace note, and conservative nested `ScenEdit_RunScript` handling.

Locked B2 direction:

- Use CMO `Lua` root, not scenario folders.
- Use fixed `AiAssist` namespace.
- Use explicit `ScenEdit_RunScript('/AiAssist/<file>.lua')` snippets.
- Keep CMO execution manual.
- Keep UI save gated by `aiParsedResponse.isPasteReady === true`.
- Require dry-run preview before confirmed write.
- Do not let the browser send arbitrary filesystem roots.
- Do not introduce log tailing, polling, live read-back, or AI auto-send.

Planned implementation slices:

- B2.1 writer helper and smoke contract.
- B2.2 adapter endpoint and endpoint smoke.
- B2.3 UI save controls and loader-snippet display.
- B2 QA and agent handoff update.

Protected baseline:

- Main JS: `377.99 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Main CSS remains close to the `60 kB` watch line; B2 UI should reuse existing styles.

Next gate:

- B2.1 writer helper and smoke contract only.
- Do not add adapter endpoint, UI controls, log tailing, polling, live read-back, or AI auto-send in the first implementation slice.

## B2.1 RunScript Sidecar Writer Helper - 2026-05-10

Codex implemented the first B2 writer slice as a pure helper plus smoke contract.

Target commit:

```text
b1fce05 Add B2 RunScript sidecar writer helper
```

Changed files:

```text
package.json
server/cmo-lua-sidecar-writer.mjs
tools/verify-cmo-lua-sidecar-writer-contract.mjs
```

Added script:

```powershell
npm run smoke:cmo-lua-sidecar-writer
```

Behavior:

- Default mode is dry-run and writes no file.
- Actual write requires `isPasteReady: true`, `dryRun: false`, and `confirmWrite: true`.
- Target path is `<CMO Lua root>\AiAssist\AiAssist_<timestamp>_<slug>.lua`.
- Existing files are not overwritten.
- Response/report fields include server-confirmed `confirmedDryRun` and `confirmedWrite`.
- Response/report fields do not include the Lua body.
- Loader snippet uses `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
- Unsafe Lua surfaces are rejected, including `os.*`, `io.*`, `require`, `dofile`, `loadfile`, `package.*`, `debug.*`, and nested `ScenEdit_RunScript`.

Boundaries preserved:

- No adapter endpoint yet.
- No UI controls yet.
- No `.scen` mutation.
- No scenario-folder write.
- No CMO polling, log tailing, live read-back, automatic CMO execution, or AI auto-send.
- No new dependency or lockfile drift.

Codex pre-QA:

- TDD RED: `npm run smoke:cmo-lua-sidecar-writer` failed with missing `server/cmo-lua-sidecar-writer.mjs`.
- TDD GREEN: `npm run smoke:cmo-lua-sidecar-writer` PASS.
- `npm run smoke:cmo-lua-load-check`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:ai-adapter`: PASS after approved rerun, no raw auth leakage.
- `npm run verify:release`: PASS.

Protected baseline:

- Main JS: `377.99 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `1899` index entries, `3799` protected files, `24` orphans / `5.6 MB`, dry-run only.

Completed QA:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-helper-qa.md
```

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Pipeline: `smoke:cmo-lua-sidecar-writer`, `smoke:cmo-lua-load-check`, and `verify:release` PASS.
- Bundle: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scope: helper-only; no adapter route, UI, public data, dependency, or lockfile drift.
- Security: unsafe Lua surfaces blocked, `open('wx')` prevents overwrite, dry-run default, and response/report does not include Lua body.

Next gate after Kimi approval:

- Proceed to B2.2 adapter endpoint and endpoint smoke.

## B2.2 RunScript Sidecar Adapter Endpoint - 2026-05-10

Codex implemented the second B2 writer slice as a local adapter endpoint plus endpoint smoke.

Target commit:

```text
203b9d7 Add B2 RunScript sidecar endpoint
```

Changed files:

```text
package.json
server/ai-provider-adapter.mjs
tools/verify-cmo-lua-sidecar-endpoint.mjs
```

Added script:

```powershell
npm run smoke:cmo-lua-sidecar-endpoint
```

Endpoint:

```text
POST /api/cmo/lua-sidecar
```

Behavior:

- Reuses the B2.1 `createLuaSidecar` helper.
- Ignores request-body `cmoLuaRoot`; the CMO Lua root comes from server-side `CMO_LUA_ROOT` / helper default.
- Supports dry-run and confirmed write.
- Actual write still requires `isPasteReady: true`, `dryRun: false`, and `confirmWrite: true`.
- Returns path/snippet/report metadata and does not include the Lua body.
- Writes remain under `<CMO Lua root>\AiAssist\`.
- Loader snippet remains `ScenEdit_RunScript('/AiAssist/<file>.lua')`.

Boundaries preserved:

- No UI controls yet.
- No `.scen` mutation.
- No scenario-folder write.
- No CMO polling, log tailing, live read-back, automatic CMO execution, or AI auto-send.
- No new dependency or lockfile drift.

Codex pre-QA:

- TDD RED: initial endpoint smoke hit sandbox `spawn EPERM`; approved rerun failed with `404 != 200` because `/api/cmo/lua-sidecar` was not routed yet.
- TDD GREEN: `npm run smoke:cmo-lua-sidecar-endpoint` PASS.
- `npm run smoke:cmo-lua-sidecar-writer`: PASS.
- `npm run smoke:cmo-lua-load-check`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:ai-adapter`: PASS after approved rerun, no raw auth leakage.
- `npm run verify:release`: PASS.

Protected baseline:

- Main JS: `377.99 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `1899` index entries, `3799` protected files, `24` orphans / `5.6 MB`, dry-run only.

Completed QA:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-endpoint-qa.md
```

Kimi QA result:

- Verdict: APPROVED, no regression.
- Static checkpoints: `34 / 34 PASS`.
- Pipeline: `smoke:cmo-lua-sidecar-endpoint`, B2.1/B0.1 smokes, and `verify:release` PASS.
- Bundle: Main JS `377.99 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scope: endpoint-only; no UI or public data drift.
- Security: request-body `cmoLuaRoot` ignored, no Lua body in response, `deepScrubSecrets` applied, and no auth leakage in logs/responses.

Next gate:

- Superseded by the accepted B2.3 UI save-controls slice below.

## B2.3 RunScript Sidecar UI Save Controls - 2026-05-10

Codex implemented the third B2 writer slice as UI controls plus a client-helper smoke contract.

Target commit:

```text
2df8e57 Add B2 sidecar save controls
```

Scope:

- `package.json`
- `tools/verify-ai-adapter-client-sidecar-contract.mjs`
- `src/lib/aiAdapterClient.js`
- `src/components/LuaAssistant.jsx`

Behavior:

- `saveCmoLuaSidecar()` posts JSON to `POST /api/cmo/lua-sidecar`.
- `LuaAssistant` exposes dry-run and confirmed-write controls beside the existing AI Lua apply controls.
- Dry-run label: `CMO 파일 준비`.
- Write label: `CMO Lua 폴더 저장`.
- The UI displays the adapter-returned `ScenEdit_RunScript('/AiAssist/<file>.lua')` loader snippet.
- The browser never sends `cmoLuaRoot`; B2.2 remains responsible for server-side root selection.
- Save controls are disabled unless `canApplyAiLua` is true, preserving the `aiParsedResponse.isPasteReady` gate.
- New AI calls clear stale sidecar-save status/snippets.

Codex pre-QA:

- TDD RED: `npm run smoke:ai-adapter-client-sidecar` failed on missing `saveCmoLuaSidecar` export.
- TDD GREEN: `npm run smoke:ai-adapter-client-sidecar` PASS.
- `npm run smoke:cmo-lua-sidecar-endpoint`: PASS after approved sandbox-spawn rerun.
- `npm run smoke:cmo-lua-sidecar-writer`: PASS.
- `npm run smoke:cmo-lua-load-check`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved sandbox-spawn rerun.
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage.
- `npm run verify:release`: PASS.

Build baseline:

- Main JS: `380.45 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.

Invariant boundaries:

- No new CSS or `src/index.css` change.
- No server endpoint, writer helper, public data, dependency, lockfile, CMO polling, log tailing, live read-back, automatic CMO execution, or AI auto-send change in this target commit.
- Manual prompt-copy fallback remains available.
- CMO execution remains explicit and manual through the displayed RunScript snippet.

QA:

- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-ui-save-controls-qa.md`.
- Kimi QA result: APPROVED, `35 / 35 PASS`, no regression.
- Pipeline: client smoke, endpoint/helper/B0.1 smokes, lint, build, adapter smoke, and `verify:release` PASS.
- Bundle: Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- Scope confirmed: expected four files only.
- Security confirmed: `canApplyAiLua` / `isPasteReady` gate maintained, browser does not send `cmoLuaRoot`, prompt-copy fallback preserved, and existing CSS classes reused.

## B2 RunScript Sidecar Writer Closeout - 2026-05-10

Codex closed B2 as an approved local, user-triggered CMO Lua sidecar writer path.

Closeout reference:

```text
docs/agent-ops/b2-runscript-sidecar-writer-closeout-2026-05-10.md
```

Closeout target:

```text
fc7a291 Document B2 RunScript sidecar writer closeout
```

Included slices:

- Planning: `3931a95 Plan B2 RunScript sidecar writer`.
- B2.1 writer helper: `b1fce05 Add B2 RunScript sidecar writer helper`.
- B2.2 adapter endpoint: `203b9d7 Add B2 RunScript sidecar endpoint`.
- B2.3 UI controls: `2df8e57 Add B2 sidecar save controls`.

QA archives:

- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-plan-qa.md`.
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-helper-qa.md`.
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-endpoint-qa.md`.
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-ui-save-controls-qa.md`.

Approved operating path:

- AI paste-ready draft only.
- `CMO 파일 준비` dry-run preview first.
- `CMO Lua 폴더 저장` confirmed write second.
- User manually runs `ScenEdit_RunScript('/AiAssist/<file>.lua')` inside CMO.
- User performs CMO engine verification.

Protected boundaries:

- No scenario-folder auto-load claim.
- No automatic CMO execution.
- No CMO polling, log tailing, live read-back, or AI auto-send.
- No browser-provided filesystem root.
- No dependency or lockfile drift.
- No `src/index.css` growth.

Current B2 baseline:

- Main JS: `380.45 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected files, `24` orphans / `5.6 MB`.

Recommended next gate:

- B2 release marker / README update after closeout-docs QA is archived.

Closeout-docs QA:

- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-closeout-docs-qa.md`.
- Kimi QA result: APPROVED, `35 / 35 PASS`, no regression.
- Scope confirmed: docs / handoff only.
- Confirmed records: B0.1 prior facts, B2 slice commits, QA archives, Claude review, operating path, UI labels, preserved boundaries, bundle/scenario baselines, and next-gate recommendation.

## B2 RunScript Sidecar Writer Release Marker - 2026-05-10

Codex marked the B2 RunScript sidecar writer release baseline in README and expanded the release verification chain.

Target commit:

```text
8c7a18e Mark B2 RunScript sidecar writer release in README
```

Scope:

- `README.md`
- `package.json`

Changes:

- README current release marker now references `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- README manual QA pipeline includes `npm run smoke:ai-adapter-client-sidecar`.
- README bundle baseline records Main JS `380.45 kB`, Main CSS `59.14 kB`, and `aiContextPruning` `8.56 kB`.
- README records RunScript Sidecar Writer smoke baseline.
- `package.json` `verify:release` now includes `npm run smoke:ai-adapter-client-sidecar` before parser/adapter smoke.

Codex pre-QA:

- `npm run smoke:ai-adapter-client-sidecar`: PASS.
- `npm run verify:release`: PASS after approved sandbox-spawn rerun.
- Sidecar audit: `1899` in index, `3799` protected, `24` orphans / `5.6 MB`, dry-run only.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Build: Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.
- AI adapter smoke: PASS, no raw auth leakage.

Active QA:

- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-marker-qa.md`.
- Kimi QA result: APPROVED, `22 / 22 PASS`, no regression.
- Scope confirmed: `README.md` and `package.json` only.
- Confirmed: README release marker, extended `verify:release`, bundle baseline, sidecar/scenario baseline, AI adapter no-auth-leak smoke, and no release tag/GitHub Release created yet.

Next gate:

- B2 release tag / GitHub Release after marker QA and push approval.

## B2 RunScript Sidecar Writer Release Tag - 2026-05-10

Codex created the B2 RunScript sidecar writer release tag and GitHub Release after release-marker QA and push approval.

Release:

- Tag: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Tagged commit: `8c7a18e Mark B2 RunScript sidecar writer release in README`.
- Tagged commit full SHA: `8c7a18e62d2bc041f9bcd1c6d31906c227b33540`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Release title: `CMO Lua Builder RunScript Sidecar Writer`.
- Release state: not draft, not prerelease.

Release notes record:

- B2 RunScript sidecar writer path for CMO Lua drafts.
- `CMO 파일 준비` dry-run preview.
- `CMO Lua 폴더 저장` confirmed write.
- Manual `ScenEdit_RunScript('/AiAssist/<file>.lua')` execution in CMO.
- `dofile(...)` and scenario-folder auto-load are not claimed.
- Browser clients do not supply `cmoLuaRoot`.
- Save controls remain gated by `aiParsedResponse.isPasteReady`.
- No automatic CMO execution, polling, log tailing, live read-back, or AI auto-send.
- CMO engine verification remains required.

Verification recorded in the release notes:

- `npm run verify:release`: PASS, including `npm run smoke:ai-adapter-client-sidecar`.
- `npm run smoke:cmo-lua-sidecar-writer`: PASS.
- `npm run smoke:cmo-lua-sidecar-endpoint`: PASS.
- `npm run smoke:ai-adapter-client-sidecar`: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.
- Scenario loader baseline: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit baseline: `3799` protected, `24` orphans / `5.6 MB`, dry-run only.
- Bundle baseline: Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.

Active QA:

- Kimi directive: `handoff/to-kimi/2026-05-10-b2-runscript-sidecar-writer-release-tag-qa.md`.
- QA focus: verify tag mapping, GitHub Release metadata, release notes, `npm run verify:release`, watch lines, and preserved B2 safety boundaries.

Release-tag QA result:

- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-tag-qa.md`.
- Verdict: APPROVED, `32 / 32 PASS`, no regression.
- Tag verified: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer -> 8c7a18e`.
- GitHub Release verified: `CMO Lua Builder RunScript Sidecar Writer`, not draft, not prerelease.
- `npm run verify:release`: PASS.
- Build: Main JS `380.45 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.

## Post-Release B2 RunScript Sidecar Writer Closeout - 2026-05-10

Codex closed the B2 RunScript sidecar writer release as the current public operating baseline.

Release:

- Tag: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Tagged commit: `8c7a18e Mark B2 RunScript sidecar writer release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`.
- Release title: `CMO Lua Builder RunScript Sidecar Writer`.
- Kimi release-tag QA: APPROVED, no regression.

Current closeout reference:

```text
docs/agent-ops/b2-runscript-sidecar-writer-release-closeout-2026-05-10.md
```

Post-release baseline:

- Main JS: `380.45 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.
- B2 sidecar writer smoke: PASS.
- B2 sidecar endpoint smoke: PASS.
- AI adapter client sidecar smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

B2 release status:

- User-triggered RunScript sidecar writer is the public baseline.
- AI Lua drafts can be prepared and saved under the CMO Lua root `AiAssist` namespace.
- User manually runs `ScenEdit_RunScript('/AiAssist/<file>.lua')` in CMO.
- `dofile(...)` remains disproven for the CMO Build 1868 console sandbox.
- Scenario-folder auto-load remains unproven.
- No automatic CMO execution, CMO polling, log tailing, live read-back, or AI auto-send is introduced.
- CMO engine verification remains required.

Recommended next gate:

```text
B3 log feedback loop planning
```

Closeout-docs QA:

- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-release-closeout-docs-qa.md`.
- Kimi QA result: APPROVED, `34 / 34 PASS`, no regression.
- Scope confirmed: docs / handoff only.
- Confirmed records: release tag, tagged commit, GitHub Release metadata, B0.1 prior facts, B2 slice commits, QA archive paths, verification baseline, preserved boundaries, and B3 recommendation.
- Handoff inboxes are clean and B2 is fully released / closed.

## B3 Log Feedback Loop Planning - 2026-05-10

Codex opened the B3 planning gate after B2 release closeout.

Purpose:

- Read recent CMO log feedback after the user manually runs `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
- Convert sanitized log snippets into a user-reviewed follow-up draft.
- Preserve manual control: no automatic AI send and no automatic CMO execution.

Design / plan references:

```text
docs/superpowers/specs/2026-05-10-b3-log-feedback-loop-design.md
docs/superpowers/plans/2026-05-10-b3-log-feedback-loop.md
docs/agent-ops/b3-log-feedback-loop-planning-2026-05-10.md
```

Locked direction:

- Read-only `ExceptionLog_*.txt` and `LuaHistory_*.txt` support.
- Server-side logs root only: `CMO_LOGS_ROOT` or default CMO Logs folder.
- Browser cannot provide `logsRoot`.
- Redact user paths, CMO paths, drive paths, `Bearer`, `Authorization`, and `sk-` patterns.
- Bound responses with `limit` and `maxBytes`.
- Return file names only, not absolute paths.
- Draft follow-up text only; user must review and send manually.
- No polling loops, filesystem watchers, live read-back claims, automatic AI send, or automatic CMO execution.

Planned slices:

- B3.1 helper: `server/cmo-log-feedback-reader.mjs` + `npm run smoke:cmo-log-feedback`.
- B3.2 endpoint: `GET /api/cmo/log-feedback` + `npm run smoke:cmo-log-feedback-endpoint`.
- B3.3 client/UI: `fetchCmoLogFeedback()` + `CMO 로그 확인` + `후속 질문 초안`, no auto-send.

Active review / QA:

- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b3-log-feedback-loop-planning-qa.md`.
- Kimi QA result: APPROVED, `36 / 36 PASS`, no regression.
- Claude review archive: `handoff/to-claude/_archive/2026-05-10/2026-05-10-b3-log-feedback-loop-design-review.md`.
- Claude review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B3-Log-Feedback-Loop\b3-log-feedback-loop-review.md`.
- Claude verdict: `APPROVED with refinements`.
- Gemini remains standby until B3 UI wording exists.

Refinements locked for B3.1:

- Use positioned tail reads instead of full-file `readFile()` for CMO log content.
- Implement the `since` helper contract.
- Expand redaction to cover forward-slash Windows paths, lowercase drive paths, and UNC paths.
- Add smoke guards against accidental execution, file writes, and full-log reads in the helper.

Planning scope:

- Docs / handoff only.
- No product source, server route, tool script, package, lockfile, public data, CMO file, sidecar, tag, or release change in this planning gate.

## B3.1 CMO Log Feedback Helper - 2026-05-11

Codex implemented the first B3 helper slice after B3 planning QA and Claude design review.

Target commit:

```text
407e822 Add B3 CMO log feedback helper
```

Scope:

```text
package.json
server/cmo-log-feedback-reader.mjs
tools/verify-cmo-log-feedback-contract.mjs
```

Implemented:

- `smoke:cmo-log-feedback` script.
- Pure helper for CMO log-root resolution, file discovery, bounded tail reads, redaction, entry extraction, and follow-up draft formatting.
- Smoke contract for helper exports, redaction coverage, `since` behavior, large-log tail behavior, missing-root behavior, and source-level no-write/no-exec/no-full-read guards.

Claude review refinements addressed:

- Positioned tail reads replace full-file log reads.
- `since` is implemented for timestamped lines.
- Redaction covers backslash user paths, forward-slash user paths, lowercase drive paths, UNC paths, CMO paths, `Authorization`, `Bearer`, and `sk-` values.

Codex pre-QA:

- `npm run smoke:cmo-log-feedback`: PASS.
- `npm run smoke:cmo-lua-load-check`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS after approved rerun for Windows sandbox `spawn EPERM`; no raw auth leakage.
- `npm run verify:release`: PASS.

Verification baseline:

- Main JS: `380.45 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Preserved boundaries:

- No endpoint yet.
- No UI yet.
- No browser-provided log root.
- No log writes, deletes, truncation, polling loops, filesystem watchers, live read-back, automatic CMO execution, or AI auto-send.

Active QA directive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-helper-qa.md
```

Kimi QA result:

- Verdict: APPROVED.
- Static checkpoints: `47 / 47 PASS`.
- Pipeline: `smoke:cmo-log-feedback`, `smoke:cmo-lua-load-check`, `lint`, `build`, `smoke:ai-adapter`, and `verify:release` all PASS.
- Regression: none.
- Current next gate: B3.2 adapter endpoint and endpoint smoke.

## B3.2 CMO Log Feedback Endpoint - 2026-05-11

Codex implemented the second B3 slice after B3.1 helper QA approval.

Target commit:

```text
7f8943c Add B3 CMO log feedback endpoint
```

Scope:

```text
package.json
server/ai-provider-adapter.mjs
tools/verify-cmo-log-feedback-endpoint.mjs
```

Implemented:

- `smoke:cmo-log-feedback-endpoint` script.
- `GET /api/cmo/log-feedback` adapter endpoint.
- Endpoint handler that forwards only `kind`, `since`, `limit`, and `maxBytes` to `buildCmoLogFeedback`.
- Endpoint smoke that starts the adapter with fixture `CMO_LOGS_ROOT`, passes a malicious `logsRoot` query, and confirms the browser-provided root is ignored.

Codex pre-QA:

- `npm run smoke:cmo-log-feedback-endpoint`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:cmo-log-feedback`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage.
- `npm run verify:release`: PASS.

Verification baseline:

- Main JS: `380.45 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Preserved boundaries:

- No UI yet.
- No browser-provided log root.
- No log writes, deletes, truncation, polling loops, filesystem watchers, live read-back, automatic CMO execution, or AI auto-send.
- No `src/**` or `public/**` changes.

Active QA directive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-endpoint-qa.md
```

Kimi QA result:

- Verdict: APPROVED.
- Static checkpoints: `45 / 45 PASS`.
- Pipeline: `smoke:cmo-log-feedback-endpoint`, `smoke:cmo-log-feedback`, `lint`, `build`, `smoke:ai-adapter`, and `verify:release` all PASS.
- Confirmed: `GET /api/cmo/log-feedback`, ignored browser `logsRoot`, `deepScrubSecrets` response sanitization, and no AI/process/file-mutation behavior.
- Regression: none.
- Current next gate: B3.3 UI log feedback fetch and text-only follow-up draft.

## B3.3 CMO Log Feedback UI - 2026-05-11

Codex implemented the third B3 slice after B3.2 endpoint QA approval.

Target commit:

```text
3800fdf Add B3 CMO log feedback UI
```

Scope:

```text
package.json
src/components/LuaAssistant.jsx
src/lib/aiAdapterClient.js
tools/verify-ai-adapter-client-log-feedback-contract.mjs
```

Implemented:

- `smoke:ai-adapter-client-log-feedback` script.
- `fetchCmoLogFeedback()` client helper for `GET /api/cmo/log-feedback`.
- LuaAssistant output-pane controls for `CMO 로그 확인`.
- Bounded `CMO 로그 스냅샷` rendering.
- User-reviewed `후속 질문 초안` with `AI 채팅에 넣기` and copy fallback.

Codex pre-QA:

- TDD RED: `npm run smoke:ai-adapter-client-log-feedback` failed on missing `fetchCmoLogFeedback` export.
- TDD GREEN: `npm run smoke:ai-adapter-client-log-feedback` PASS after implementation.
- `npm run smoke:cmo-log-feedback-endpoint`: PASS after approved rerun for Windows sandbox `spawn EPERM`.
- `npm run smoke:cmo-log-feedback`: PASS.
- `npm run smoke:ai-adapter-client-sidecar`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage.
- `npm run verify:release`: PASS.

Verification baseline:

- Main JS: `383.67 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Preserved boundaries:

- UI does not supply a browser filesystem/log root.
- Follow-up draft is text-only and user-reviewed.
- No automatic AI send.
- No automatic CMO execution.
- No polling loop, filesystem watcher, live read-back claim, or backend endpoint added in this slice.
- Existing B2 sidecar controls, prompt-copy fallback, and `isPasteReady` gate remain intact.
- No `server/**` or `public/**` changes.

QA archive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-cmo-log-feedback-ui-qa.md
```

Kimi QA result:

- Verdict: APPROVED.
- Static checkpoints: `45 / 45 PASS`.
- Pipeline: `smoke:ai-adapter-client-log-feedback`, `smoke:cmo-log-feedback-endpoint`, `smoke:cmo-log-feedback`, `smoke:ai-adapter-client-sidecar`, `lint`, `build`, `smoke:ai-adapter`, and `verify:release` all PASS.
- Confirmed: Main JS `383.67 kB`, no browser `logsRoot`, no `sendCmoAiPrompt` automatic call, and `후속 질문 초안` is inserted as text only.
- Regression: none.
- Current next gate: B3 log feedback closeout docs.

## B3 Log Feedback Loop Closeout - 2026-05-11

Codex documented the completed B3 helper -> endpoint -> UI log feedback loop.

Closeout reference:

```text
docs/agent-ops/b3-log-feedback-loop-closeout-2026-05-11.md
```

Closeout status:

```text
APPROVED / CLOSED
```

B3 slice chain:

- Planning: `9ff84ac Plan B3 log feedback loop`.
- Planning refinements: `bbe95ae Record B3 planning review refinements`.
- B3.1 helper: `407e822 Add B3 CMO log feedback helper`.
- B3.2 endpoint: `7f8943c Add B3 CMO log feedback endpoint`.
- B3.3 UI: `3800fdf Add B3 CMO log feedback UI`.
- B3.3 QA archive: `6f7821b Archive B3 log feedback UI QA`.

QA evidence:

- Planning QA: APPROVED, `36 / 36 PASS`.
- B3.1 helper QA: APPROVED, `47 / 47 PASS`.
- B3.2 endpoint QA: APPROVED, `45 / 45 PASS`.
- B3.3 UI QA: APPROVED, `45 / 45 PASS`.
- Regression: none.

Capability closed:

- Read-only `ExceptionLog_*.txt` and `LuaHistory_*.txt` snapshots.
- Server-side logs root only.
- `GET /api/cmo/log-feedback`.
- UI `CMO 로그 확인`, `CMO 로그 스냅샷`, and `후속 질문 초안`.
- User-reviewed text-only follow-up draft.

Verification baseline:

- `npm run verify:release`: PASS.
- B3 smokes: `smoke:cmo-log-feedback`, `smoke:cmo-log-feedback-endpoint`, `smoke:ai-adapter-client-log-feedback` PASS.
- Main JS: `383.67 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Preserved boundaries:

- No automatic AI send.
- No automatic CMO execution.
- No polling loop, watcher, live read-back claim, browser-provided root, log mutation, dependency, lockfile, or credential persistence.
- Prompt-copy fallback, B2 RunScript sidecar controls, and `isPasteReady` gate remain intact.

Recommended next gate:

- B3 release marker / README update.
- Proposed tag: `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.

Closeout-docs QA:

- Archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-closeout-docs-qa.md`.
- Verdict: APPROVED.
- Static checkpoints: `40 / 40 PASS`.
- Scope: docs/handoff only.
- Confirmed: B3 planning -> helper -> endpoint -> UI chain, QA evidence, verification baseline, and preserved boundaries are accurately recorded.
- Regression: none.
- Current next gate: B3 release marker / README update.

## B3 Log Feedback Loop Release Marker - 2026-05-11

Codex marked the B3 log feedback loop as the next proposed public release in README and expanded the release verification chain.

Target commit:

```text
c50975e Mark B3 log feedback release in README
```

Scope:

```text
README.md
package.json
```

Release marker:

- Proposed tag: `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- No tag created yet.
- No GitHub Release created yet.

Changed verification:

- `verify:release` now includes:
  - `npm run smoke:cmo-log-feedback`
  - `npm run smoke:cmo-log-feedback-endpoint`
  - `npm run smoke:ai-adapter-client-log-feedback`

Codex pre-QA:

- `npm run smoke:cmo-log-feedback`: PASS.
- `npm run smoke:cmo-log-feedback-endpoint`: PASS.
- `npm run smoke:ai-adapter-client-log-feedback`: PASS.
- `npm run verify:release`: PASS with expanded chain.

Verification baseline:

- Main JS: `383.67 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Active QA directive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-marker-qa.md
```

Kimi QA result:

- Verdict: APPROVED.
- Static checkpoints: `30 / 30 PASS`.
- `npm run verify:release`: PASS with the 13-step expanded chain.
- Confirmed README public release marker, B2 smoke baseline preservation, no tag, and no GitHub Release yet.
- Regression: none.
- Current next gate: B3 release tag / GitHub Release.

## B3 Log Feedback Loop Release Tag - 2026-05-11

Codex created the B3 public release tag and GitHub Release.

Release:

- Tag: `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Tagged commit: `c50975e Mark B3 log feedback release in README`.
- Tagged commit full SHA: `c50975e0276950c5d18a24d45f6e2c353a6ed9ca`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Release title: `CMO Lua Builder Log Feedback Loop`.
- Release state: not draft, not prerelease.

Release notes include:

- B3 CMO Log Feedback Loop on top of B2 RunScript Sidecar Writer.
- Manual `ScenEdit_RunScript('/AiAssist/<file>.lua')` CMO execution.
- `ExceptionLog_*.txt` and `LuaHistory_*.txt`.
- Bounded and redacted snippets.
- `CMO 로그 확인` and `후속 질문 초안`.
- Read-only log snapshots, server-side logs root only, no browser `logsRoot`.
- No automatic AI send, automatic CMO execution, polling loop, filesystem watcher, live read-back claim, or log mutation.
- `npm run verify:release` PASS and the three B3 smoke checks.
- Bundle, scenario, sidecar, and AI adapter redaction baselines.
- B3 QA evidence from planning through release marker.

Active QA directive:

```text
handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-tag-qa.md
```

Kimi release-tag QA result:

- Verdict: APPROVED.
- Static checkpoints: `40 / 40 PASS`.
- `npm run verify:release`: PASS with the 13-step expanded chain.
- Confirmed tag `release-2026-05-11-cmo-lua-builder-log-feedback-loop -> c50975e`.
- Confirmed GitHub Release `CMO Lua Builder Log Feedback Loop`, not draft, not prerelease.
- Confirmed release notes include B3 capability, safety boundaries, baselines, and QA evidence.
- Regression: none.
- Current next gate: B3 release closeout docs.

## B3 Log Feedback Loop Release Closeout - 2026-05-11

Codex documented the completed B3 public release.

Release closeout reference:

```text
docs/agent-ops/b3-log-feedback-loop-release-closeout-2026-05-11.md
```

Release:

- Tag: `release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Tagged commit: `c50975e Mark B3 log feedback release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-11-cmo-lua-builder-log-feedback-loop`.
- Release title: `CMO Lua Builder Log Feedback Loop`.
- Release state: not draft, not prerelease.

Closed chain:

- Planning: `9ff84ac`.
- Refinements: `bbe95ae`.
- Helper: `407e822`.
- Endpoint: `7f8943c`.
- UI: `3800fdf`.
- Closeout docs: `dffc296`.
- Release marker: `c50975e`.
- Release tag QA archive: `d12cefa`.

QA evidence:

- Planning QA: APPROVED, `36 / 36 PASS`.
- Helper QA: APPROVED, `47 / 47 PASS`.
- Endpoint QA: APPROVED, `45 / 45 PASS`.
- UI QA: APPROVED, `45 / 45 PASS`.
- Closeout docs QA: APPROVED, `40 / 40 PASS`.
- Release marker QA: APPROVED, `30 / 30 PASS`.
- Release tag QA: APPROVED, `40 / 40 PASS`.
- Regression: none.

Release baseline:

- `npm run verify:release`: PASS.
- Main JS: `383.67 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Preserved boundaries:

- No automatic AI send, automatic CMO execution, live read-back claim, polling loop, filesystem watcher, browser-provided logs root, log mutation, dependency/lockfile drift, credential persistence, or raw auth leakage.

Next recommended development gate:

- B4 user-triggered state export / read-back probe.

Release closeout-docs QA:

- Archive: `handoff/to-kimi/_archive/2026-05-11-b3-log-feedback-loop-release-closeout-docs-qa.md`.
- Verdict: APPROVED.
- Static checkpoints: `45 / 45 PASS`.
- Scope: docs/handoff only.
- Confirmed: B3 full release chain is complete from planning through release closeout.
- Confirmed: 12 commits, 7 Kimi QA archives, Claude design review, and 13-step verification baseline are recorded.
- Regression: none.
- Current next recommended development gate: B4 user-triggered state export / read-back probe.

## B4 User-Triggered State Export Planning - 2026-05-11

Codex opened the B4 planning gate after the B3 Log Feedback Loop release closeout.

Planning references:

- Design: `docs/superpowers/specs/2026-05-11-b4-user-triggered-state-export-design.md`.
- Plan: `docs/superpowers/plans/2026-05-11-b4-user-triggered-state-export.md`.
- Agent-ops: `docs/agent-ops/b4-user-triggered-state-export-planning-2026-05-11.md`.
- Kimi planning QA directive: `handoff/to-kimi/2026-05-11-b4-user-triggered-state-export-planning-qa.md`.
- Claude design review directive: `handoff/to-claude/2026-05-11-b4-user-triggered-state-export-design-review.md`.

Locked direction:

- User-triggered imported CMO state snapshots.
- Manual pasted `Tool_DumpEvents()` / `ScenEdit_GetEvent(...)` text first.
- Reuse `tools/parse-cmo-event-export.mjs` through a bounded wrapper.
- `source.live === false` for B4 snapshots.
- Strip parser `raw` fields from endpoint/UI responses.
- Return bounded Lua previews only.
- Redact local paths and secret-like strings.
- Text-only follow-up drafts.
- Optional user-selected Confirmed Context promotion.

Explicit exclusions:

- No automatic AI send.
- No automatic CMO execution.
- No polling loop.
- No filesystem watcher.
- No silent real-time daemon behavior.
- No browser-provided CMO/log/scenario/Lua roots.
- No CMO file writes/deletes.
- No `.scen` mutation.
- No live unit position claim.

Planned slices:

- B4.1 helper: `server/cmo-state-snapshot-importer.mjs`, `tools/verify-cmo-state-snapshot-contract.mjs`, `smoke:cmo-state-snapshot`.
- B4.2 endpoint: `POST /api/cmo/state-snapshot/import`, `tools/verify-cmo-state-snapshot-endpoint.mjs`, `smoke:cmo-state-snapshot-endpoint`.
- B4.3 UI: `src/lib/aiAdapterClient.js`, `src/components/LuaAssistant.jsx`, `tools/verify-ai-adapter-client-state-snapshot-contract.mjs`, `smoke:ai-adapter-client-state-snapshot`.
- B4.4 closeout / release after Kimi QA approves implementation slices.

Verification baseline to preserve:

- Main JS: `383.67 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.
- `npm run verify:release`: PASS with the 13-step expanded chain.

Current gate:

- Kimi planning QA approved.
- Claude design review approved with refinements.
- Gemini standby until B4 UI wording exists.
- Implementation may proceed to B4.1 CMO state snapshot helper.

Planning QA / review result:

- Kimi planning QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-user-triggered-state-export-planning-qa.md`.
- Kimi verdict: APPROVED, `55 / 55 PASS`.
- Claude review directive archive: `handoff/to-claude/_archive/2026-05-11/2026-05-11-b4-user-triggered-state-export-design-review.md`.
- Claude review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B4-User-Triggered-State-Export\b4-user-triggered-state-export-review.md`.
- Claude verdict: APPROVED with refinements.
- B4.1 required refinements: nested raw assertions, redaction-before-parse comment, truncation signals, and UTF-16 char-unit label.

## B4.1 CMO State Snapshot Helper - 2026-05-11

Codex implemented the first B4 helper slice.

Product commit:

```text
876903f Add B4 CMO state snapshot helper
```

Changed files:

- `package.json`
- `server/cmo-state-snapshot-importer.mjs`
- `tools/verify-cmo-state-snapshot-contract.mjs`

Implemented behavior:

- Adds `smoke:cmo-state-snapshot`.
- Adds `buildCmoStateSnapshot(text, options)`.
- Reuses `parse` from `tools/parse-cmo-event-export.mjs`.
- Enforces `256 KiB` maximum input size.
- Caps events to `50`.
- Caps special actions to `50`.
- Caps warnings to `20`.
- Caps Lua previews to `600` UTF-16 code units.
- Hardcodes `source.live === false`.
- Redacts before parse with parser-safe replacement tokens.
- Strips nested parser `raw` fields.
- Removes full `luaScript` values and full `luaScripts` arrays.
- Adds truncation signals: `totalEventCount`, `eventsTruncated`, `totalSpecialActionCount`, `specialActionsTruncated`, and `warningsTruncated`.

Codex TDD / verification:

- RED: `npm run smoke:cmo-state-snapshot` failed with missing `server/cmo-state-snapshot-importer.mjs`.
- GREEN: `npm run smoke:cmo-state-snapshot` PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved rerun for sandbox `spawn EPERM`.
- `npm run smoke:ai-adapter`: PASS after approved rerun for sandbox `spawn EPERM`; no raw auth leakage.
- `npm run verify:release`: PASS after approved rerun for sandbox `spawn EPERM`.

Build / baseline:

- Main JS: `383.67 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Preserved boundaries:

- No adapter endpoint.
- No UI controls.
- No browser-provided filesystem root.
- No CMO polling, watcher, execution, file mutation, `.scen` mutation, live read-back claim, or AI auto-send.
- No dependency or lockfile drift.

Current gate:

- Kimi B4.1 helper QA approved.
- QA archive: `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-helper-qa.md`.
- Static checkpoints: `80 / 80 PASS`.
- Regression: none.
- `verify:release` does not include the B4 smoke yet; extension is expected after B4.2 endpoint.
- Current next gate: B4.2 adapter endpoint.

## B4.2 CMO State Snapshot Endpoint - 2026-05-11

Codex implemented the B4 adapter endpoint slice.

Product commit:

```text
92a5ca6 Add B4 CMO state snapshot endpoint
```

Changed files:

- `package.json`
- `server/ai-provider-adapter.mjs`
- `tools/verify-cmo-state-snapshot-endpoint.mjs`

Implemented behavior:

- Adds `smoke:cmo-state-snapshot-endpoint`.
- Adds `POST /api/cmo/state-snapshot/import`.
- Calls `buildCmoStateSnapshot(String(body.text ?? ''), { sourceHint: body.sourceHint })`.
- Ignores browser-provided root/path fields.
- Wraps success and error responses with `deepScrubSecrets`.
- Logs only summary event counts.

Codex TDD / verification:

- RED: endpoint smoke first hit sandbox `spawn EPERM`; approved rerun failed with `404 !== 200`.
- GREEN: `npm run smoke:cmo-state-snapshot-endpoint` PASS after route wiring.
- `npm run smoke:cmo-state-snapshot`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after approved rerun for sandbox `spawn EPERM`.
- `npm run smoke:ai-adapter`: PASS after approved rerun; no raw auth leakage.
- `npm run verify:release`: PASS after approved rerun.

Build / baseline:

- Main JS: `383.67 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Preserved boundaries:

- No UI controls.
- No browser-provided filesystem root.
- No CMO file write/delete.
- No `.scen` mutation.
- No CMO polling, watcher, execution, live read-back claim, or AI auto-send.
- No dependency or lockfile drift.

Kimi QA:

- Archive: `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-endpoint-qa.md`.
- Static checkpoints: `70 / 70 PASS`.
- Verdict: APPROVED.

Current gate:

- B4.3 UI state snapshot import panel.

## B4.3 CMO State Snapshot UI - 2026-05-11

Codex implemented the B4 UI import slice.

Product commit:

```text
5d3b06d Add B4 CMO state snapshot UI
```

Changed files:

- `package.json`
- `src/lib/aiAdapterClient.js`
- `src/components/LuaAssistant.jsx`
- `tools/verify-ai-adapter-client-state-snapshot-contract.mjs`

Implemented behavior:

- Adds `smoke:ai-adapter-client-state-snapshot`.
- Adds `importCmoStateSnapshot({ text, sourceHint })` client helper.
- Adds manual UI panel `CMO 상태 스냅샷 가져오기`.
- User pastes `Tool_DumpEvents()` / `ScenEdit_GetEvent(...)` output manually.
- UI calls `/api/cmo/state-snapshot/import` only after user clicks `스냅샷 가져오기`.
- UI displays `가져온 CMO 스냅샷` counts and bounded event preview.
- UI states that the snapshot is imported and `실시간 연결이 아닙니다`.
- UI builds a text-only follow-up draft through `후속 질문 초안 만들기`.
- User-selected snapshot object-context hints can be promoted into Confirmed Context one value at a time.

Codex TDD / verification:

- RED: `npm run smoke:ai-adapter-client-state-snapshot` failed because `importCmoStateSnapshot` was not exported.
- GREEN: `npm run smoke:ai-adapter-client-state-snapshot` PASS after client/UI wiring.
- `npm run smoke:cmo-state-snapshot-endpoint`: PASS after approved rerun for sandbox `spawn EPERM`.
- `npm run smoke:cmo-state-snapshot`: PASS.
- `npm run smoke:ai-adapter-client-log-feedback`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS; no raw auth leakage.
- `npm run verify:release`: PASS.

Build / baseline:

- Main JS: `391.65 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Preserved boundaries:

- No automatic AI send.
- No automatic CMO execution.
- No polling or watcher.
- No live read-back claim.
- No browser-provided filesystem root.
- No CMO file write/delete.
- No `.scen` mutation.
- No dependency or lockfile drift.
- No CSS drift; `src/index.css` unchanged.

Kimi QA:

- Archive: `handoff/to-kimi/_archive/2026-05-11-b4-cmo-state-snapshot-ui-qa.md`.
- Static checkpoints: `74 / 74 PASS`.
- Verdict: APPROVED.

Kimi closeout-docs QA:

- Archive: `handoff/to-kimi/_archive/2026-05-11-b4-user-triggered-state-export-closeout-docs-qa.md`.
- Static checkpoints: `60 / 60 PASS`.
- Verdict: APPROVED.

Current gate:

- B4 release marker / README update.

## B4 State Snapshot Import Release Marker - 2026-05-11

Codex marked the B4 state snapshot import release in README and expanded the release verification chain.

Release marker commit:

```text
b1fac3d Mark B4 state snapshot import release in README
```

Changed files:

- `README.md`
- `package.json`

Release marker:

- Proposed tag / current public release line: `release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- No Git tag created yet.
- No GitHub Release created yet.

Verification:

- `npm run verify:release`: PASS.
- Chain now includes B4 smokes:
  - `smoke:cmo-state-snapshot`
  - `smoke:cmo-state-snapshot-endpoint`
  - `smoke:ai-adapter-client-state-snapshot`

Baseline:

- Main JS: `391.65 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Preserved boundaries:

- No product source changes.
- No server/tool/public data changes.
- No docs/handoff changes in the target release marker commit.
- No dependency or lockfile drift.
- No release tag or GitHub Release yet.

Current gate:

- Kimi B4 release marker QA active at `handoff/to-kimi/2026-05-11-b4-state-snapshot-import-release-marker-qa.md`.

## B4 State Snapshot Import Release Tag - 2026-05-11

Codex created the B4 state snapshot import release tag and GitHub Release.

Release tag:

```text
release-2026-05-11-cmo-lua-builder-state-snapshot-import
```

Tagged commit:

```text
b1fac3d Mark B4 state snapshot import release in README
```

GitHub Release:

```text
Title: CMO Lua Builder State Snapshot Import
URL: https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-11-cmo-lua-builder-state-snapshot-import
Draft: false
Prerelease: false
```

Release notes cover:

- User-triggered CMO state snapshot import.
- `CMO 상태 스냅샷 가져오기`.
- `Tool_DumpEvents()` / `ScenEdit_GetEvent(...)`.
- `가져온 CMO 스냅샷`, `live=false`, event/special-action/warning counts, and bounded previews.
- Text-only `후속 질문 초안 만들기`.
- Confirmed Context one-value-at-a-time promotion.
- Safety boundaries: not live read-back, no automatic AI send, no automatic CMO execution, no polling/watcher, no browser roots, no CMO file write/delete, no `.scen` mutation.
- Verification: `npm run verify:release` PASS with B2/B3/B4 smokes.
- Bundle baseline: Main JS `391.65 kB`, Main CSS `59.14 kB`, `aiContextPruning` `8.56 kB`.

Kimi release-tag QA:

- Archive: `handoff/to-kimi/_archive/2026-05-11-b4-state-snapshot-import-release-tag-qa.md`.
- Verdict: APPROVED, `48 / 48 PASS`.
- Pipeline: `npm run verify:release` PASS with the expanded 16-step release chain.
- Confirmed: tag maps to `b1fac3d`, GitHub Release title is `CMO Lua Builder State Snapshot Import`, draft=false, prerelease=false.
- Confirmed: release notes include B4 highlights, safety boundaries, verification baseline, bundle baseline, and QA evidence.
- Regression: none.

Current gate:

- B4 release closeout docs.

## B4 State Snapshot Import Release Closeout - 2026-05-11

Codex documented the completed B4 public release.

Release closeout reference:

```text
docs/agent-ops/b4-state-snapshot-import-release-closeout-2026-05-11.md
```

Release:

- Tag: `release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- Tagged commit: `b1fac3d Mark B4 state snapshot import release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- Release title: `CMO Lua Builder State Snapshot Import`.
- Release state: not draft, not prerelease.

Closed B4 chain:

- Planning: `2639944`.
- Planning QA / review archive: `dcffbc2`.
- Helper: `876903f`.
- Helper QA archive: `af52916`.
- Endpoint: `92a5ca6`.
- Endpoint QA archive: `bcdfd1c`.
- UI: `5d3b06d`.
- UI QA activation: `de0439a`.
- Closeout docs: `69040d3`.
- Closeout docs QA archive: `9114739`.
- Release marker: `b1fac3d`.
- Release marker QA archive: `3d698b8`.
- Release tag QA activation: `98ee5ae`.
- Release tag QA archive: `a9457db`.

QA evidence:

- Planning QA: APPROVED, `55 / 55 PASS`.
- B4.1 helper QA: APPROVED, `80 / 80 PASS`.
- B4.2 endpoint QA: APPROVED, `70 / 70 PASS`.
- B4.3 UI QA: APPROVED, `74 / 74 PASS`.
- B4 closeout docs QA: APPROVED, `60 / 60 PASS`.
- B4 release marker QA: APPROVED, `48 / 48 PASS`.
- B4 release tag QA: APPROVED, `48 / 48 PASS`.
- Regression: none.

Release baseline:

- `npm run verify:release`: PASS with 16-step chain.
- Main JS: `391.65 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `1899` in index, `3799` protected, `24` orphans / about `5.6 MB`.
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.

Preserved boundaries:

- Imported snapshots only; no live read-back claim.
- Text-only follow-up drafts only; no automatic AI send.
- No automatic CMO execution.
- No polling loop or filesystem watcher.
- No browser-provided filesystem roots.
- No CMO file write/delete and no `.scen` mutation.

Next recommended development gate:

- B4 post-release operating recheck / end-to-end manual CMO workflow smoke.

Release closeout-docs QA:

- Archive: `handoff/to-kimi/_archive/2026-05-11-b4-state-snapshot-import-release-closeout-docs-qa.md`.
- Verdict: APPROVED - B4 state snapshot import release closeout docs hold.
- Static checkpoints: `54 / 54 PASS`.
- Scope: docs/handoff only.
- Confirmed: B4 full release chain is complete from planning through release closeout.
- Confirmed: no product source, server, tool, public data, dependency, or lockfile drift.
- Regression: none.
- Current next recommended gate: B4 post-release operating recheck / end-to-end manual CMO workflow smoke.

## B4 Post-Release Operating Recheck - 2026-05-12

Codex re-ran the full release verification chain after the B4 State Snapshot Import release closeout docs and closeout-docs QA were archived.

Current public release:

```text
release-2026-05-11-cmo-lua-builder-state-snapshot-import
```

Verification command:

```powershell
npm run verify:release
```

Verification note:

- Initial sandbox run reached `npm run build` and failed with Windows `spawn EPERM` while loading Vite config.
- Approved rerun of the same command completed successfully.
- This matches the known Windows sandbox subprocess behavior; no product regression was indicated.

Verification result:

- `audit:scenario-sidecars`: PASS, dry-run only.
- `verify:scenario-loader`: PASS.
- `lint`: PASS.
- `build`: PASS.
- `smoke:ai-workflow-state`: PASS.
- `smoke:ai-follow-up-needs`: PASS.
- `smoke:ai-confirmed-context`: PASS.
- `smoke:ai-adapter-client-sidecar`: PASS.
- `smoke:cmo-log-feedback`: PASS.
- `smoke:cmo-log-feedback-endpoint`: PASS.
- `smoke:ai-adapter-client-log-feedback`: PASS.
- `smoke:cmo-state-snapshot`: PASS.
- `smoke:cmo-state-snapshot-endpoint`: PASS.
- `smoke:ai-adapter-client-state-snapshot`: PASS.
- `smoke:ai-client-parser`: PASS.
- `smoke:ai-adapter`: PASS, sanitized HTTP 401 forwarding and no raw `Bearer` / `Authorization` / `sk-` leakage.

Observed baseline:

- Main JS: `391.65 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `1899` in index, `3799` protected, `24` orphans / about `5.6 MB`.

Invariant status:

- B4 State Snapshot Import remains the current public release baseline.
- B2 RunScript sidecar writer, B3 log feedback, and B4 state snapshot import smokes all remain part of `verify:release`.
- Prompt-copy fallback, `isPasteReady` gate, text-only follow-up drafts, redaction, and bounded snapshot contracts remain unchanged.
- No source, server, tool, public data, package, dependency, lockfile, tag, or GitHub Release change was part of this recheck.
- No automatic AI send, automatic CMO execution, polling, watcher, live read-back claim, browser-provided root, CMO file write/delete, or `.scen` mutation was introduced.

Manual CMO smoke status:

- Not run by Codex in this automated recheck.
- Recommended next manual gate: user-run end-to-end CMO workflow smoke.

Manual smoke checklist:

```text
B2 save -> user ScenEdit_RunScript('/AiAssist/<file>.lua') in CMO -> B3 log feedback -> B4 state snapshot import -> text-only AI follow-up draft
```

Post-recheck status: ready for focused Kimi QA.

Post-recheck QA:

- Archive: `handoff/to-kimi/_archive/2026-05-12-b4-post-release-operating-recheck-qa.md`.
- Verdict: APPROVED - B4 post-release operating recheck holds.
- Static checkpoints: `39 / 39 PASS`.
- Scope: docs/handoff only.
- Confirmed: B4 operating baseline remains stable after release closeout.
- Confirmed: B2/B3/B4 smokes remain in the 16-step release verification chain.
- Confirmed: manual CMO smoke was not run by Codex and remains the next user-run gate.
- Regression: none.
- Current next gate: user-run end-to-end CMO workflow smoke.

## B4 Manual CMO Workflow Smoke Runbook - 2026-05-12

Codex documented the user-run end-to-end CMO workflow smoke after the B4 post-release operating recheck.

Runbook:

```text
docs/agent-ops/b4-manual-cmo-workflow-smoke-2026-05-12.md
```

Status:

- READY / USER-RUN.
- No product source, server, tool, public data, package, lockfile, tag, or GitHub Release change is part of this runbook.
- No Kimi QA directive is open until user-run CMO evidence exists.

Manual smoke path:

```text
B2 save -> user ScenEdit_RunScript('/AiAssist/<file>.lua') in CMO -> B3 log feedback -> B4 state snapshot import -> text-only AI follow-up draft
```

Runbook coverage:

- Preconditions record the current public release `release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- Preconditions record the B4 operating recheck and Kimi QA archive.
- Preconditions preserve B0.1 facts: `dofile(...)` is unavailable in CMO Build 1868, while explicit CMO Lua-root `ScenEdit_RunScript(...)` succeeded.
- Local setup records `npm run start:ai-adapter` and `npm run dev`.
- B2 steps cover `CMO 파일 준비`, `CMO Lua 폴더 저장`, user-approved AiAssist Lua draft writing, and exact loader-snippet evidence.
- CMO step requires the user to run the adapter-returned `ScenEdit_RunScript('/AiAssist/<file>.lua')` manually.
- B3 step covers `CMO 로그 확인`, read-only `ExceptionLog_*.txt` / `LuaHistory_*.txt` feedback, redaction, bounded preview, and text-only follow-up draft.
- B4 step covers pasted `Tool_DumpEvents()` / `ScenEdit_GetEvent(...)` text, imported snapshot wording, `source.live === false`, raw Lua stripping, and bounded previews.
- Evidence template records the exact artifacts needed to close the manual smoke or open a focused fix slice.

Preserved boundaries:

- Codex does not run CMO in-game steps directly.
- No automatic AI send.
- No automatic CMO execution.
- No polling, watcher, or live read-back claim.
- No browser-provided filesystem roots.
- No `.scen` mutation.
- Existing prompt-copy fallback, `isPasteReady` gate, and text-only draft controls remain the required user controls.

Next gate:

- User provides manual smoke evidence.
- If pass, Codex opens a manual smoke result closeout plus focused Kimi QA directive.
- If fail, Codex opens the smallest focused fix slice for B2 save, CMO RunScript, B3 log feedback, or B4 snapshot import.

## B4 User-Triggered State Export Closeout - 2026-05-11

Codex documented B4 closeout after all implementation slices were Kimi-approved.

Closeout doc:

```text
docs/agent-ops/b4-user-triggered-state-export-closeout-2026-05-11.md
```

Recorded B4 chain:

- Planning: `2639944 Plan B4 user-triggered state export`.
- Planning QA / review archive: `dcffbc2 Archive B4 planning QA and review`.
- B4.1 helper: `876903f Add B4 CMO state snapshot helper`.
- B4.1 QA archive: `af52916 Archive B4 state snapshot helper QA`.
- B4.2 endpoint: `92a5ca6 Add B4 CMO state snapshot endpoint`.
- B4.2 QA archive: `bcdfd1c Archive B4 state snapshot endpoint QA`.
- B4.3 UI: `5d3b06d Add B4 CMO state snapshot UI`.
- B4.3 QA activation: `de0439a Mark B4 state snapshot UI QA active`.

Recorded QA results:

- Planning QA: APPROVED, `55 / 55 PASS`.
- B4.1 helper QA: APPROVED, `80 / 80 PASS`.
- B4.2 endpoint QA: APPROVED, `70 / 70 PASS`.
- B4.3 UI QA: APPROVED, `74 / 74 PASS`.

Recorded baseline:

- Main JS: `391.65 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.

Recorded preserved boundaries:

- No automatic AI send.
- No automatic CMO execution.
- No polling or watcher.
- No live read-back claim.
- No browser-provided filesystem root.
- No CMO file write/delete.
- No `.scen` mutation.
- No dependency or lockfile drift.
- No CSS drift in `src/index.css`.

Current gate:

- B4 closeout docs QA.

## Post-Release Template Inspector Annotations Closeout - 2026-05-09

Codex closed the Template Inspector annotation release as the current public operating baseline.

Release:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Tagged commit: `f46385b Mark template inspector annotation release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Release title: `CMO Lua Builder Template Inspector Annotation Update`.
- Kimi release-tag QA: APPROVED, no regression.

Current final verification entrypoint:

```powershell
npm run verify:release
```

Current closeout reference:

```text
docs/agent-ops/template-inspector-annotations-release-closeout-2026-05-09.md
```

Post-release baseline:

- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Template annotations: `18 / 51` resources annotated, `33` missing.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

Template Inspector annotation status:

- `public/template-annotations.json` now covers 10 additional core/event templates across the two accepted batches.
- Guidance reinforces source-anchored DBID, Loadout ID, GUID, Side, Mission, RP, and Zone values.
- Event Trigger and LuaScript Action concepts remain separated in beginner notes.
- CMO engine validation remains required; annotations do not claim engine-tested behavior.
- Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.

Post-release status: closed and documented.

## Post-Release Template Inspector Annotations Operating Recheck - 2026-05-09

Codex re-ran the full release verification chain after the Template Inspector annotations closeout docs and closeout-docs QA were archived.

Verification command:

```powershell
npm run verify:release
```

Verification result:

- `npm run audit:scenario-sidecars`: PASS.
- `npm run verify:scenario-loader`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.

Observed baseline:

- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with sanitized HTTP 401 forwarding and no raw auth leakage.

Invariant status:

- Template Inspector annotation release remains the current public release baseline.
- Template annotations remain in `public/template-annotations.json`; no React source inflation occurred.
- Parser, adapter, context pruning, scenario-loader, and Lua apply safety contracts remain unchanged.
- No source, server, tool, package, dependency, or release-tag change was part of this recheck.

Post-recheck status: ready for focused Kimi QA.

## Post-Release Template Inspector Annotation Batch 3 Closeout - 2026-05-09

Codex closed Template Inspector Annotation Batch 3 as the latest post-release operating baseline.

Current public release remains:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Tagged commit: `f46385b Mark template inspector annotation release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.

Batch 3 commits:

- Planning commit: `031ad02 Document template inspector batch 3 plan`.
- Product/data commit: `4d7208a Add template inspector annotation batch 3`.
- QA directive commit: `08a96bb Add template inspector batch 3 QA directive`.
- QA archive / agent refresh commit: `18689c6 Archive template inspector batch 3 QA`.

Current closeout reference:

```text
docs/agent-ops/template-inspector-batch-3-closeout-2026-05-09.md
```

Batch 3 annotation status:

- Added `side_posture.tpl.lua`, `event_contact_emcon.tpl.lua`, `unit_spawn_random.tpl.lua`, `event_teleport.tpl.lua`, `event_dbid_score.tpl.lua`, and `event_cargo_drop.tpl.lua`.
- Template annotations increased from `18 / 51` to `24 / 51`.
- Remaining missing resources: `27`.
- Guidance reinforces real Side/posture values, no invented EMCON/contact values, map-confirmed coordinate bounds, GUID-first lookup, Database Viewer sourced DBIDs, and existing RP names.

Kimi QA result:

- `npm run lint`: PASS.
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- JSON coverage check: `{ "annotated": 24, "total": 51, "missing": 27, "added": [true,true,true,true,true,true] }`.
- Regression: none.

Invariant status:

- Batch 3 product change remained `public/template-annotations.json` only.
- Parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts remain unchanged.
- Current public release tag remains unchanged.

Post-Batch-3 status: closed and ready for docs/handoff-only QA.

## Post-Release Template Inspector Annotation Batch 4 Closeout - 2026-05-09

Codex closed Template Inspector Annotation Batch 4 as the latest post-release operating baseline.

Current public release remains:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Tagged commit: `f46385b Mark template inspector annotation release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.

Batch 4 commits:

- Planning commit: `f2a2254 Document template inspector batch 4 plan`.
- Product/data commit: `ac8949f Add template inspector annotation batch 4`.
- QA directive commit: `306a9d6 Add template inspector batch 4 QA directive`.
- QA archive / agent refresh commit: `d711c63 Archive template inspector batch 4 QA`.

Current closeout reference:

```text
docs/agent-ops/template-inspector-batch-4-closeout-2026-05-09.md
```

Batch 4 annotation status:

- Added `mission_support.tpl.lua`, `mission_cargo.tpl.lua`, `mission_ferry.tpl.lua`, `mission_mine.tpl.lua`, `kvstore_set.tpl.lua`, and `event_kv_flag.tpl.lua`.
- Template annotations increased from `24 / 51` to `30 / 51`.
- Remaining missing resources: `21`.
- Guidance reinforces real Side/RP/Mission/cargo values, KeyValue key naming, one-shot guard behavior, repeatable event risk, and no invented mission/RP/cargo/trigger values.

Kimi QA result:

- `npm run lint`: PASS.
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- JSON coverage check: `{ "annotated": 30, "total": 51, "missing": 21, "added": [true,true,true,true,true,true] }`.
- Regression: none.

Invariant status:

- Batch 4 product change remained `public/template-annotations.json` only.
- Parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts remain unchanged.
- Current public release tag remains unchanged.

Post-Batch-4 status: closed and ready for docs/handoff-only QA.

## Post-Release Template Inspector Completion Release Closeout - 2026-05-09

Codex closed the Template Inspector `51 / 51` completion release as the current public operating baseline.

Release:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
- Tagged commit: `59bdab9 Mark template inspector completion release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
- Release title: `CMO Lua Builder Template Inspector Completion`.
- Release state: not draft, not prerelease.

Completion / release commits:

- Product/data commit: `80a003a Complete template inspector annotations`.
- Completion closeout commit: `77e5393 Document template inspector annotation completion closeout`.
- Completion closeout QA archive commit: `eb9c9b0 Archive template inspector completion closeout QA`.
- Release marker commit: `59bdab9 Mark template inspector completion release in README`.
- Release QA directive commit: `da57221 Add template inspector completion release QA directive`.
- Release QA archive commit: `dbf3f9b Archive template inspector completion release QA`.

Current closeout reference:

```text
docs/agent-ops/template-inspector-completion-release-closeout-2026-05-09.md
```

Release QA result:

- Kimi QA: APPROVED / ARCHIVED.
- `npm run verify:release`: PASS.
- Static checkpoints: 20 / 20 PASS.
- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Template Inspector annotations: `51 / 51`, `0` missing.
- Scenario baseline: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.
- AI adapter smoke: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.
- Regression: none.
- Closeout docs QA: APPROVED / ARCHIVED, 23 / 23 static checkpoints PASS.

Invariant status:

- Parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts remain unchanged.
- Product source, package, lockfile, and dependency scope remain unchanged by the release marker.
- Template Inspector annotations remain data-driven in `public/template-annotations.json`.

Post-release status: closed and documented.

## Post-Release Template Inspector Completion Operating Recheck - 2026-05-09

Codex re-ran the full release verification chain after the Template Inspector completion release closeout docs and closeout-docs QA were archived.

Verification:

- `npm run verify:release`: PASS.
- Chain PASS: sidecar audit, scenario loader verification, lint, build, AI client parser smoke, and AI adapter smoke.
- Build output: `366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- Scenario baseline: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with sanitized HTTP 401 forwarding and no raw `Bearer` / `Authorization` / `sk-` leakage.

Invariant status:

- Current public release remains `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
- Template Inspector annotations remain complete at `51 / 51`, `0` missing.
- Parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts remain unchanged.
- No product source, server, tool, package, dependency, or release-tag change was part of this recheck.
- Kimi QA: APPROVED / ARCHIVED, 23 / 23 static checkpoints PASS.

Post-recheck status: closed and in standby.

## Post-Release Template Inspector Search / Filter UX Closeout - 2026-05-09

Codex closed Track A1 Template Inspector Search / Filter UX as an approved post-release operating slice.

Current public release remains:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
- Tagged commit: `59bdab9 Mark template inspector completion release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-completion`.

A1 commits:

- Plan commit: `898e35b Add template inspector search filter plan`.
- Claude review directive commit: `1cdbcf4 Add Claude template inspector taxonomy review directive`.
- Product commit: `5dd1da1 Add template inspector search filter UX`.
- Kimi QA directive commit: `f84bdf2 Open template inspector search filter QA directive`.
- Kimi / Claude archive commit: `9768910 Archive template inspector search filter QA`.

Current closeout reference:

```text
docs/agent-ops/template-inspector-search-filter-ux-closeout-2026-05-09.md
```

Kimi QA result:

- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage.
- Static checkpoints: 27 / 27 PASS.
- Regression: none.

Post-A1 baseline:

- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- `PresetGuide` lazy JS: `33.99 kB`.
- `PresetGuide` lazy CSS: `7.49 kB`.
- Template Inspector annotations: `51 / 51`, `0` missing.

A1 status:

- Quick filters added: Event, Mission, Unit, DBID / Loadout, RP / Zone, Doctrine / EMCON, KeyValue.
- Safety badges added: engine test required, needs Side, needs Mission, needs Unit GUID, needs DBID, needs Loadout, needs RP / Zone, affects Side-wide.
- Standalone GUID, standalone Side, Engine Test Required, and demo-values filters were intentionally excluded.
- Universal AI draft / CMO engine verification footer added.
- Parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts remain unchanged.
- No release tag was created for this slice.

Post-A1 status: closed and ready for docs/handoff-only QA.

## Post-Release Template Inspector Search / Filter Release Closeout - 2026-05-09

Codex closed the Template Inspector Search / Filter UX release as the current public operating baseline.

Release:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Tagged commit: `004325d Mark template inspector search filter release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Release title: `CMO Lua Builder Template Inspector Search Filter UX`.
- Release state: not draft, not prerelease.

Release / QA commits:

- Product UX commit: `5dd1da1 Add template inspector search filter UX`.
- Product QA archive commit: `9768910 Archive template inspector search filter QA`.
- Product closeout commit: `bd3a5c5 Document template inspector search filter closeout`.
- Product closeout QA archive commit: `52dfe94 Archive template inspector search filter closeout QA`.
- Release marker commit: `004325d Mark template inspector search filter release in README`.
- Release QA directive commit: `be448f8 Add template inspector search filter release QA directive`.
- Release QA archive commit: `b90d1b9 Archive template inspector search filter release QA`.

Current closeout reference:

```text
docs/agent-ops/template-inspector-search-filter-release-closeout-2026-05-09.md
```

Kimi release QA result:

- `npm run verify:release`: PASS.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer`, `Authorization`, or `sk-` leakage.
- Static checkpoints: 27 / 27 PASS.
- Regression: none.

Release baseline:

- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- `PresetGuide` lazy JS: `33.99 kB`.
- `PresetGuide` lazy CSS: `7.49 kB`.
- Template Inspector annotations: `51 / 51`, `0` missing.

Search / Filter status:

- Quick filters: Event, Mission, Unit, DBID / Loadout, RP / Zone, Doctrine / EMCON, KeyValue.
- Safety badges: engine test required, needs Side, needs Mission, needs Unit GUID, needs DBID, needs Loadout, needs RP / Zone, affects Side-wide.
- AI draft / CMO engine verification footer remains visible in source detail.
- Parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts remain unchanged.

Post-release status: closed and ready for docs/handoff-only QA.

## Post-Release AI Drafting Workflow State - 2026-05-09

Codex closed Track A2-1 as an approved local AI interpreter workflow-state slice.

Current public release remains:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.
- Tagged commit: `004325d Mark template inspector search filter release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-search-filter`.

A2-1 commits:

- Design commit: `e8e9c9e Add AI drafting workflow tightening design`.
- Implementation plan commit: `81b77a9 Add AI drafting workflow implementation plan`.
- Product commit: `eb689df Align AI drafting workflow state`.
- Kimi QA directive commit: `853349b Add AI drafting workflow state QA directive`.

Kimi QA result:

- `npm run smoke:ai-workflow-state`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw auth leakage.
- Static checkpoints: 38 / 38 PASS.
- Regression: none.
- QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-ai-drafting-workflow-state-qa.md`.

A2-1 baseline:

- Main JS: `371.44 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- `AiInterpreterChatPanel` lazy JS / CSS: `10.38 kB` / `6.73 kB`.
- `AiResponseReviewPanel` lazy JS / CSS: `5.25 kB` / `3.69 kB`.

A2-1 status:

- Shared workflow states are now `idle`, `calling`, `ready`, `askBack`, `blocked`, and `error`.
- `ready` is the only apply-enabled state and remains tied to `aiParsedResponse.isPasteReady`.
- `calling`, pruning hard-block/failure, and current call/setup errors defeat stale ready responses.
- Main Output, AI Response Review, and AI Interpreter Chat surfaces consume the same workflow state.
- Follow-up drafting remains text-only; no automatic send was introduced.
- Prompt-copy fallback remains available.
- Parser, adapter, context pruning, scenario-loader, and Track B boundaries remain unchanged.
- No backend endpoint, scenario folder write, log tail, live read-back, dependency, package-lock, or credential/storage drift was introduced.
- Main CSS is below but close to the `60 kB` soft line with about `0.86 kB` headroom.

Post-A2-1 status: closed and ready for the next Track A slice.

## Post-Release Template Inspector Annotation Completion Closeout - 2026-05-09

Codex closed Template Inspector annotation expansion as a complete `51 / 51` operating baseline.

Current public release remains:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Tagged commit: `f46385b Mark template inspector annotation release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.

Batch 7 completion commits:

- Planning commit: `28b0875 Document template inspector batch 7 plan`.
- Product/data commit: `80a003a Complete template inspector annotations`.
- QA directive commit: `ce0ef6d Add template inspector batch 7 QA directive`.
- QA archive / agent refresh commit: `af0ed01 Archive template inspector batch 7 QA`.

Current completion closeout reference:

```text
docs/agent-ops/template-inspector-annotation-completion-closeout-2026-05-09.md
```

Completion annotation status:

- Added `event_random_start_weather.tpl.lua`, `loadout_scramble.tpl.lua`, `mission_generic.tpl.lua`, `advanced_ops.lua`, `airbase_scramble.lua`, `cap_patrol.lua`, `multi_file_pack.lua`, `quickbattle.lua`, and `strike_alpha.lua`.
- Template annotations increased from `42 / 51` to `51 / 51`.
- Remaining missing resources: `0`.
- Guidance reinforces startup weather one-shot guards, DBID/Loadout/base source checks, generic Mission kind/subtype validity, demo preset replacement rules, UnitDetected trigger validation, CAP RP zone validation, multi-file path checks, randomized quick battle DBID/coordinate caution, and strike preset bundled-event assumptions.

Kimi QA result:

- `npm run lint`: PASS.
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- JSON coverage check: `{ "annotated": 51, "total": 51, "missing": 0, "added": [true,true,true,true,true,true,true,true,true] }`.
- Regression: none.

Invariant status:

- Batch 7 product change remained `public/template-annotations.json` only.
- Parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts remain unchanged.
- Current public release tag remains unchanged.

Post-completion status: closed and ready for docs/handoff-only QA.

## Post-Release Template Inspector Annotation Batch 6 Closeout - 2026-05-09

Codex closed Template Inspector Annotation Batch 6 as the latest post-release operating baseline.

Current public release remains:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Tagged commit: `f46385b Mark template inspector annotation release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.

Batch 6 commits:

- Planning commit: `7bfc27c Document template inspector batch 6 plan`.
- Product/data commit: `81d5b66 Add template inspector annotation batch 6`.
- QA directive commit: `e89b75e Add template inspector batch 6 QA directive`.
- QA archive / agent refresh commit: `aec194c Archive template inspector batch 6 QA`.

Current closeout reference:

```text
docs/agent-ops/template-inspector-batch-6-closeout-2026-05-09.md
```

Batch 6 annotation status:

- Added `event_complex.tpl.lua`, `event_split_merge.tpl.lua`, `event_ambient_traffic.tpl.lua`, `event_scen_loaded.tpl.lua`, `event_unit_x.tpl.lua`, and `inst_import.tpl.lua`.
- Template annotations increased from `36 / 51` to `42 / 51`.
- Remaining missing resources: `9`.
- Guidance reinforces real Event Editor options, GUID-first split/merge caution, Civilian ship DBIDs, coordinate bounds, ScenLoaded idempotence, UnitX payload validation, trusted `.inst` filenames, Side names, and DB compatibility checks.

Kimi QA result:

- `npm run lint`: PASS.
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- JSON coverage check: `{ "annotated": 42, "total": 51, "missing": 9, "added": [true,true,true,true,true,true] }`.
- Regression: none.

Invariant status:

- Batch 6 product change remained `public/template-annotations.json` only.
- Parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts remain unchanged.
- Current public release tag remains unchanged.

Post-Batch-6 status: closed and ready for docs/handoff-only QA.

## Post-Release Template Inspector Annotation Batch 5 Closeout - 2026-05-09

Codex closed Template Inspector Annotation Batch 5 as the latest post-release operating baseline.

Current public release remains:

- Tag: `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
- Tagged commit: `f46385b Mark template inspector annotation release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.

Batch 5 commits:

- Planning commit: `d99e45c Document template inspector batch 5 plan`.
- Product/data commit: `a80b9ea Add template inspector annotation batch 5`.
- QA directive commit: `4c40061 Add template inspector batch 5 QA directive`.
- QA archive / agent refresh commit: `d911ebb Archive template inspector batch 5 QA`.

Current closeout reference:

```text
docs/agent-ops/template-inspector-batch-5-closeout-2026-05-09.md
```

Batch 5 annotation status:

- Added `event_unit_destroyed.tpl.lua`, `event_unit_damaged.tpl.lua`, `event_missions_toggle.tpl.lua`, `event_escalation.tpl.lua`, `weather_random.tpl.lua`, and `event_dynamic_weather.tpl.lua`.
- Template annotations increased from `30 / 51` to `36 / 51`.
- Remaining missing resources: `15`.
- Guidance reinforces real TargetFilter/DBID/type IDs, damage thresholds, Mission/Side names, trigger options, posture/doctrine values, bounded weather ranges, and no invented event/weather values.

Kimi QA result:

- `npm run lint`: PASS.
- `npm run build`: PASS (`366.67 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`).
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.
- JSON coverage check: `{ "annotated": 36, "total": 51, "missing": 15, "added": [true,true,true,true,true,true] }`.
- Regression: none.

Invariant status:

- Batch 5 product change remained `public/template-annotations.json` only.
- Parser, adapter, context pruning, scenario-loader, prompt-copy, and Lua apply contracts remain unchanged.
- Current public release tag remains unchanged.

Post-Batch-5 status: closed and ready for docs/handoff-only QA.

## Post-Release AI Lua Safety Wording Closeout - 2026-05-07

Codex closed the AI Lua safety wording patch release as the current public operating baseline.

Release:

- Tag: `release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`.
- Tagged commit: `a8e9b66 Refresh README after AI Lua safety wording QA`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`.
- Release title: `CMO Lua Builder AI Lua Safety Wording Update`.
- Kimi release-tag QA: APPROVED, no regression.

Current final verification entrypoint:

```powershell
npm run verify:release
```

Current closeout reference:

```text
docs/agent-ops/ai-lua-safety-wording-release-closeout-2026-05-07.md
```

Post-release baseline:

- Main JS: `366.47 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `sk-` leakage.

Safety wording status:

- AI-generated Lua is presented as a gated draft, not engine-verified final code.
- CMO engine verification remains explicitly required after applying AI Lua to Working Draft.
- Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.

Post-release status: closed and documented.

## Post-Release Transient Sidecar UX Closeout - 2026-05-07

Codex closed the transient sidecar UX patch release as the current public operating baseline.

Release:

- Tag: `release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`.
- Tagged commit: `ffbd86e Refresh README for transient sidecar UX release`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`.
- Release title: `CMO Lua Builder Transient Sidecar UX Update`.
- Kimi release-tag QA: APPROVED, no regression.

Current final verification entrypoint:

```powershell
npm run verify:release
```

Transient behavior verification:

```powershell
npm run smoke:scenario-transient
```

Current closeout reference:

```text
docs/agent-ops/transient-sidecar-ux-release-closeout-2026-05-07.md
```

Post-release baseline:

- Main JS: `366.60 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `24` orphans / about `5.6 MB`.
- Transient smoke: PASS, in-memory summary returned and `.scenario-extract-cache` remained empty.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

Transient UX status:

- Missing-sidecar wording now describes adapter temporary in-memory summary behavior.
- Original `.scen` files are not modified.
- Temporary extraction files must be cleaned after transient open.
- Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.

Post-release status: closed and documented.

## Post-Release Sidecar Cache Wording Closeout - 2026-05-08

Codex closed the sidecar cache settings wording patch release as the current public operating baseline.

Release:

- Tag: `release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`.
- Tagged commit: `f3539f5 Mark sidecar cache wording release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`.
- Release title: `CMO Lua Builder Sidecar Cache Wording Update`.
- Kimi release-tag QA: APPROVED, no regression.

Current final verification entrypoint:

```powershell
npm run verify:release
```

Current closeout reference:

```text
docs/agent-ops/sidecar-cache-wording-release-closeout-2026-05-08.md
```

Post-release baseline:

- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.
- AI client parser smoke: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

Sidecar cache wording status:

- Settings > Storage > Scenario Sidecar Cache now uses Korean index/status/count labels.
- Sidecar root, override hint, `.scen` not modified guidance, and sidecar command rows remain unchanged.
- Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.

Post-release status: closed and documented.

## CMO Wiki / Lua Reference Helper Closeout - 2026-05-13

Codex closed the CMO Wiki / Lua Reference Helper implementation after Kimi QA approval.

Closeout reference:

```text
docs/agent-ops/cmo-wiki-code-assistant-closeout-2026-05-13.md
```

Implementation chain:

- `88779c3 Design CMO wiki code assistant`.
- `7266c12 Open CMO wiki code assistant reviews`.
- `e699301 Plan CMO wiki code assistant implementation`.
- `4f70332 Add CMO wiki entry helper`.
- `30801bc Share CMO wiki utility helpers`.
- `32250e5 Add CMO Lua encyclopedia panel`.
- `11d6bcf Add Lua editor reference helper`.
- `7ce5a38 Open CMO wiki code assistant QA`.

Kimi QA:

- Archive: `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-code-assistant-qa.md`.
- Verdict: APPROVED, `38 / 38 PASS`.
- Pipeline: `smoke:cmo-wiki-code-assistant` PASS, `smoke:ai-chat-entrypoint` PASS, `npm run verify:release` PASS with the 17-step chain.
- Regression: none.

Review evidence:

- Claude architecture review archived at `handoff/to-claude/_archive/2026-05-13/2026-05-13-cmo-wiki-code-assistant-architecture-review.md`.
- Gemini UX review archived at `handoff/to-gemini/_archive/2026-05-13/2026-05-13-cmo-wiki-code-assistant-ux-review.md`.

Implemented behavior:

- `src/lib/cmoWikiEntries.js` builds deterministic wiki entries from the 51 / 51 template annotations.
- `src/components/CmoWikiPanel.jsx` provides the CMO Lua encyclopedia with search, quick filters, related examples, and text-only AI chat draft routing.
- `src/components/LuaEditorReferenceHelper.jsx` provides the manual Lua editor's right-side reference helper.
- `src/components/TemplateLibrary.jsx` shares the wiki helper utilities instead of keeping local duplicate filter / badge logic.

Verification baseline:

- Main JS: `253.81 kB`.
- Main CSS: `59.45 kB`.
- `aiContextPruning`: `8.56 kB`.
- `CmoWikiPanel`: `7.59 kB JS / 3.61 kB CSS`.
- `LuaEditorReferenceHelper`: `2.12 kB JS / 0.84 kB CSS`.
- `LuaAssistant`: `136.86 kB`.

Preserved boundaries:

- No automatic AI send.
- No automatic CMO execution.
- No CMO file writes, deletes, polling, watcher, or live-state claim.
- No browser-provided filesystem roots.
- No backend endpoint changes.
- No dependency or lockfile drift.
- Manual prompt-copy fallback and `aiParsedResponse.isPasteReady` gate remain unchanged.

Next gate:

```text
CMO Wiki / Lua Reference Helper release marker / README update
```

## CMO Wiki / Lua Reference Helper Release Closeout - 2026-05-13

Codex closed the CMO Wiki / Lua Reference Helper public release.

Release:

- Tag: `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`.
- Tagged commit: `d09b0d7 Mark CMO wiki reference helper release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`.
- Release title: `CMO Lua Builder CMO Wiki Reference Helper`.
- Release state: not draft, not prerelease.

Current release closeout reference:

```text
docs/agent-ops/cmo-wiki-reference-helper-release-closeout-2026-05-13.md
```

Release QA:

- Product QA archive: `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-code-assistant-qa.md`, APPROVED, `38 / 38 PASS`.
- Release marker QA archive: `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-marker-qa.md`, APPROVED, `25 / 25 PASS`.
- Release tag QA archive: `handoff/to-kimi/_archive/2026-05-13-cmo-wiki-reference-helper-release-tag-qa.md`, APPROVED, `35 / 35 PASS`.
- Regression: none.

Release notes coverage:

- CMO Lua encyclopedia.
- 51 / 51 template annotation baseline.
- Deterministic search and quick filters.
- Lua editor reference helper.
- Text-only AI chat drafts.
- Safety boundaries: no automatic AI send, no automatic CMO execution, no CMO file writes/deletes/polling/watcher/live-state claim, no backend changes, no dependency drift, CMO engine verification required.

Verification baseline:

- `npm run verify:release`: PASS with 17-step chain.
- Main JS: `253.81 kB`.
- Main CSS: `59.45 kB`.
- `aiContextPruning`: `8.56 kB`.
- `CmoWikiPanel`: `7.59 kB JS / 3.61 kB CSS`.
- `LuaEditorReferenceHelper`: `2.12 kB JS / 0.84 kB CSS`.
- `LuaAssistant`: `136.86 kB JS`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

Preserved boundaries:

- Manual prompt-copy fallback remains available.
- Text-only draft insertion remains user-reviewed.
- B2/B3/B4 support paths remain manual / bounded / redacted.
- `aiParsedResponse.isPasteReady` gate remains unchanged.

Next gate:

```text
CMO Wiki / Lua Reference Helper post-release operating recheck
```

## CMO Wiki / Lua Reference Helper Post-Release Operating Recheck - 2026-05-13

Codex rechecked the current public release after the CMO Wiki / Lua Reference Helper release closeout.

Current public release:

- Tag: `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`.
- Tagged commit: `d09b0d7 Mark CMO wiki reference helper release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`.

Verification command:

```powershell
npm run verify:release
```

Environment note:

- First sandbox run reproduced Vite build `spawn EPERM` while loading `vite.config.js`.
- Approved rerun completed successfully.
- This matches the known Windows sandbox behavior already documented in prior operating rechecks.

Approved rerun result:

- `audit:scenario-sidecars`: PASS, `1899` in index, `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.
- `verify:scenario-loader`: PASS, `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- `lint`: PASS.
- `build`: PASS.
- `smoke:ai-workflow-state`: PASS.
- `smoke:ai-follow-up-needs`: PASS.
- `smoke:ai-confirmed-context`: PASS.
- `smoke:ai-adapter-client-sidecar`: PASS.
- `smoke:cmo-log-feedback`: PASS.
- `smoke:cmo-log-feedback-endpoint`: PASS.
- `smoke:ai-adapter-client-log-feedback`: PASS.
- `smoke:cmo-state-snapshot`: PASS.
- `smoke:cmo-state-snapshot-endpoint`: PASS.
- `smoke:ai-adapter-client-state-snapshot`: PASS.
- `smoke:cmo-wiki-code-assistant`: PASS.
- `smoke:ai-client-parser`: PASS.
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `Authorization` / `sk-` leakage.

Bundle baseline:

- Main JS: `253.81 kB`.
- Main CSS: `59.45 kB`.
- `aiContextPruning`: `8.56 kB`.
- `CmoWikiPanel`: `7.59 kB JS / 3.61 kB CSS`.
- `LuaEditorReferenceHelper`: `2.12 kB JS / 0.84 kB CSS`.
- `LuaAssistant`: `136.86 kB JS`.

Invariant status:

- CMO Wiki / Lua Reference Helper remains released.
- B2, B3, and B4 smoke baselines remain included in `verify:release`.
- Manual prompt-copy fallback remains available.
- Text-only AI draft insertion remains user-reviewed.
- No automatic AI send, automatic CMO execution, polling, watcher, live-state claim, browser-provided filesystem root, or CMO file mutation is introduced.
- `aiParsedResponse.isPasteReady` gate remains unchanged.

Next gate:

```text
End-to-end advisory workflow smoke when the user is ready:
AI chat question -> wiki lookup -> Lua editor helper -> B2 save -> CMO RunScript -> B3 log feedback -> B4 snapshot import -> text-only follow-up draft
```
