# Context Pruning Phase 3 Closeout - 2026-05-05

## Purpose

Close Context Pruning Phase 3 as the current stable baseline for the AI Assistant phase.

The pruning layer is now allowed to reduce prompt bloat for Lua bundles, object lists, API/event/trigger lists, geometry, mission/unit details, and optional DB catalog fields. It must not weaken the AI response parser contract, Lua apply gate, manual prompt-copy fallback, or DBID/GUID safety anchors.

## Stable Baseline

- Scenario loader: `1857 ready`, `0 metadataOnly`, `42 decoderFailed`.
- Decoder failures are classified and skipped by default.
- `verify:scenario-loader`: `PASS`, issues `0`.
- Main bundle baseline after the later CSS slim / Preset Guide lazy split:
  - JS: `366.05 kB`.
  - CSS: `58.27 kB`.
  - `aiContextPruning` lazy chunk: `8.56 kB`.
  - `PresetGuide` lazy chunk: `30.05 kB JS / 5.86 kB CSS`.
- Current watch lines:
  - Main JS: keep under `400 kB`.
  - Main CSS: `60 kB` soft watch, currently below the line; treat a rise above `60 kB` as a regression to inspect.
  - `aiContextPruning`: keep under `9 kB` unless Codex explicitly raises the watch line.

## Completed Scope

- Phase 1: Context Pack / Pruning Audit stub.
- Phase 2: Judge-only pruning audit.
- Phase 3: Actual pruning transform before audit.
- Phase 3.1: Pruning visibility in AI response and chat panels.
- Phase 3.2a: API, event, and trigger hint top-10 caps plus briefing omission.
- Phase 3.2b-1: Object list summaries with matched-reference preservation.
- Phase 3.2b-2: Ask-back stabilization from pruning decisions.
- Phase 3.2c-1: RP coordinate and zone polygon omission for non-geometry intents.
- Phase 3.2c-2a: Mission detail omission outside mission-assignment intents.
- Phase 3.2c-2b: Unit detail omission outside unit-critical intents.
- Phase 3.2c-3a: Optional DB catalog field pruning for non-DB-critical intents.
- Phase 3.2c-3a recovery: Audit and helper compaction to restore chunk headroom.

## Safety Contract

These invariants are non-negotiable:

- Lua application remains gated only by `aiParsedResponse.isPasteReady === true`.
- DBID, loadout, GUID, and user-confirmed identifier hints must not be pruned.
- `confirmedIdentifiersStripped` remains a hard-block condition.
- Prompt-copy and request-copy fallbacks stay available even when AI calls fail.
- Pruning must run before audit, and audit failures must block the AI call.
- Raw `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, and `sessionStorage` must not be introduced into pruning output.
- Follow-up retry flows must ask back when required context is missing; they must not bypass the paste-ready gate.

## Blocked Scope

Phase `3.2c-3b` side posture pruning is blocked.

Do not implement side posture, doctrine, EMCON, or posture-code pruning until prompt assembly exposes a stable data shape for:

- Side posture matrix.
- Doctrine fields.
- EMCON settings.
- Posture code mapping.

Current prompt context only exposes enough signal to detect Doctrine / EMCON risk language. That is not enough to safely prune or summarize side posture data. Any implementation before the shape exists would either be a no-op or an unsafe guess.

## Next Implementation Candidates

1. Final stability/handoff cleanup and baseline documentation.
2. Template annotation externalization if bundle growth resumes.
3. Scenario sidecar transient-open UX if sidecar storage remains confusing.
4. Side posture data-shape design only after prompt assembly exposes stable posture/doctrine/EMCON fields.
5. Focused click/visual smoke for Preset Guide lazy loading if a browser pass is opened.

## Agent Assignment Baseline

- Codex: Primary implementer, bundle owner, final integration reviewer.
- Claude: Technical contract review, pruning safety review, project/environment planning review when Codex opens a focused signal.
- Kimi: QA, regression monitor, bundle watch, smoke test, and commit-hygiene watcher.
- Gemini: Korean UX wording, beginner-facing UI text, compact tooltip/help review.
- GLM: Removed from the active workflow.

## QA Handoff Rule

For code changes after this closeout, ask Kimi to run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

Kimi should report:

- Pass/fail for lint, build, and smoke.
- Main JS/CSS bundle size.
- `aiContextPruning` chunk size when pruning code changes.
- Any safety-contract regression.
- Critical untracked source files.

Docs-only updates do not require the full QA pipeline unless they change handoff instructions that affect active agents.
