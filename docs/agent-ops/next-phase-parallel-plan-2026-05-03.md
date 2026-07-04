# Next Phase Parallel Plan - 2026-05-03

## Goal

Move from UI stabilization into the AI assistant / interpreter phase without reopening solved scenario-decoder work.

## Current Stable Base

- Scenario loading uses prepared sidecars.
- Normal scenario coverage is complete locally: `1857 ready`, `0 metadataOnly`, `42 decoderFailed`.
- `Event/Lua Assistant`, `Preset Guide`, and `Settings` now have clearer responsibilities.
- Template / preset insertion is available from the assistant side pane.
- Builder Forms are scoped to Preset Guide.
- Preset Guide and AI Settings are lazy-loaded, with Preset Guide-only CSS out of the main stylesheet.
- Current accepted bundle baseline: Main JS `366.05 kB`, Main CSS `58.27 kB`, `aiContextPruning` `8.56 kB`.

## Workstream Assignments

### Codex

Primary implementer and final reviewer.

- Keep React implementation local to Codex.
- Keep the AI interpreter chat UI and provider profile workflow stable in small steps.
- Preserve manual prompt-copy fallback.
- Keep template / preset insertion behavior append-only unless the user explicitly chooses replacement.
- Watch bundle growth and keep large route-specific UI/CSS in lazy chunks when needed.

### Claude

Backend / parser / decoder precision standby.

- Review AI chat / parser safety contracts.
- Check provider profile proposals for API-key safety.
- Review parser defects only when concrete failing input exists.
- Do not reopen CMANO decoder limitations.

### Kimi

Regression QA and commit hygiene.

- Run lint/build/smoke after Codex UI changes.
- Verify the current UI regression checklist in `handoff/to-kimi/CURRENT_TASK.md`.
- Report JS/CSS bundle size and critical untracked files.
- Treat Main CSS rising above `60 kB` again as a regression to call out.
- Do not start broad refactors unless Codex opens the task.

### Gemini

User-facing UX wording and beginner guidance.

- Produce compact labels/tooltips/empty-state text.
- Keep wording short enough for UI embedding.
- Review beginner clarity for template insertion, preset modification, and future AI chat.
- Do not assert uncertain API behavior as fact.

## Explicit Non-Goals

- No GLM workflow.
- No broad scenario mass-decode work.
- No React monolith split yet.
- No Vitest introduction until Codex opens a testing/refactor task.
- No backend provider expansion beyond profile design unless Codex opens implementation.

## Next Codex Implementation Candidates

1. Final stability/handoff cleanup and baseline documentation.
2. Template Inspector annotation externalization if bundle grows again.
3. Focused UI click regression pass for template insertion and preset save/modify behavior.
4. Scenario sidecar transient-open UX if users still hit "index unknown" edge cases.
