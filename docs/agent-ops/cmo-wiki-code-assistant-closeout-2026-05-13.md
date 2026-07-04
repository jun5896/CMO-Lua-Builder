# CMO Wiki / Lua Reference Helper Closeout - 2026-05-13

## Status

APPROVED / CLOSED

## Public Release Context

- Current public release remains `release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- No CMO Wiki / Lua Reference Helper release tag has been created yet.
- Recommended next gate: release marker / README update for `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`, or a short post-implementation operating recheck before tagging.

## Purpose

This work turns the existing 51 / 51 Template Inspector annotation baseline into a beginner-facing CMO Lua wiki and a deterministic Lua editor reference helper.

The core user-facing direction is:

```text
AI chat stays conversational.
Lua editor stays a manual scratchpad.
The wiki and right-side reference helper provide harnessed, known-good CMO Lua guidance without acting as a second AI.
```

## Included Implementation Chain

- Advisory workspace design: `88779c3 Design CMO wiki code assistant`.
- Review directives opened: `7266c12 Open CMO wiki code assistant reviews`.
- Implementation plan: `e699301 Plan CMO wiki code assistant implementation`.
- Wiki entry helper: `4f70332 Add CMO wiki entry helper`.
- Shared utility helpers: `30801bc Share CMO wiki utility helpers`.
- Encyclopedia panel: `32250e5 Add CMO Lua encyclopedia panel`.
- Lua editor reference helper: `11d6bcf Add Lua editor reference helper`.
- QA activation / handoff: `7ce5a38 Open CMO wiki code assistant QA`.

## Review Evidence

Claude architecture review:

- Directive archive: `handoff/to-claude/_archive/2026-05-13/2026-05-13-cmo-wiki-code-assistant-architecture-review.md`.
- Review memo: `C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-CMO-Wiki-Code-Assistant\cmo-wiki-code-assistant-architecture-review.md`.
- Verdict: `APPROVED with refinements`.
- Applied direction: helper-first extraction, no LuaAssistant monolith growth for wiki logic, deterministic helper boundaries, and lazy UI slices.

Gemini UX / wording review:

- Directive archive: `handoff/to-gemini/_archive/2026-05-13/2026-05-13-cmo-wiki-code-assistant-ux-review.md`.
- Verdict: `APPROVED WITH CHANGES`.
- Applied direction: beginner-facing wiki wording, de-emphasized template creation, non-AI naming for the editor-side helper, and text-only AI draft labels.

## QA Evidence

Kimi QA archive:

```text
handoff/to-kimi/_archive/2026-05-13-cmo-wiki-code-assistant-qa.md
```

Kimi QA result:

- Verdict: `APPROVED - CMO Wiki / Lua Reference Helper holds`.
- Static checkpoints: `38 / 38 PASS`.
- Pipeline: `smoke:cmo-wiki-code-assistant` PASS.
- Pipeline: `smoke:ai-chat-entrypoint` PASS.
- Pipeline: `npm run verify:release` PASS, `17` steps.
- Regression: none.

## Implemented Behavior

- `src/lib/cmoWikiEntries.js` builds deterministic wiki entries from the 51 template annotations.
- `src/lib/cmoWikiDataClient.js` provides lazy data loading for the editor helper path.
- `src/components/CmoWikiPanel.jsx` adds the CMO Lua encyclopedia with search, quick filters, examples, required values, and a text-only AI chat draft action.
- `src/components/LuaEditorReferenceHelper.jsx` adds the right-side Lua reference helper for the manual editor.
- `src/components/TemplateLibrary.jsx` now shares wiki utility helpers instead of maintaining local duplicate filtering / badge logic.
- `src/components/AiInterpreterChatPanel.jsx` accepts the `cmo-ai-chat-draft-request` event and fills the chat input only.

The UI wording intentionally says drafts are not sent automatically.

## Verification Baseline

Observed final QA baseline:

- Main JS: `253.81 kB`.
- Main CSS: `59.45 kB`.
- `aiContextPruning`: `8.56 kB`.
- `CmoWikiPanel` lazy chunk: `7.59 kB JS / 3.61 kB CSS`.
- `LuaEditorReferenceHelper` lazy chunk: `2.12 kB JS / 0.84 kB CSS`.
- `LuaAssistant` lazy chunk: `136.86 kB`.

Existing scenario / sidecar baseline remains unchanged:

- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: dry-run only, `3799` protected, `24` orphans / about `5.6 MB`.

## Preserved Boundaries

This closeout preserves:

- No automatic AI send.
- No automatic CMO execution.
- No CMO file writes, deletes, polling, watcher, or live-state claim.
- No browser-provided filesystem roots.
- No backend endpoint changes.
- No `server/**`, `public/**`, `docs/**`, `package-lock.json`, or dependency drift in the product implementation.
- Manual prompt-copy fallback remains available.
- Lua apply / sidecar save remains gated by `aiParsedResponse.isPasteReady`.
- CMO engine verification remains required for generated or example Lua.

## User-Facing Outcome

The local workspace now supports the simplified advisory structure:

1. Use AI chat as the primary conversational entry point.
2. Use the Lua editor as a manual scratchpad and validation surface.
3. Use the CMO Lua encyclopedia to understand known CMO Lua functions, required CMO values, and related examples.
4. Use the right-side Lua reference helper to identify known patterns in pasted Lua.
5. Push wiki/helper context into AI chat only as a user-reviewed text draft.

## Next Recommended Gate

Recommended next gate:

```text
CMO Wiki / Lua Reference Helper release marker and tag
```

Optional pre-release recheck:

```powershell
npm run verify:release
```
