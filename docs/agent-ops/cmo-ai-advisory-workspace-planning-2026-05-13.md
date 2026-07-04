# CMO AI Advisory Workspace Planning - 2026-05-13

Status: OPEN FOR GEMINI UX / IA REVIEW

## Context

The user approved a direction change after B4:

- Keep AI Chat as the primary product surface.
- Turn the AI into a CMO mission scripting advisor that asks clarifying questions before drafting.
- Reduce the old Event / Lua Assistant into a lightweight manual Lua scratchpad.
- Integrate Preset Guide, feature encyclopedia, and template examples into a wiki-style surface.
- Treat browser `.scen` attachment as a small-file helper only; large scenarios need path-based scans or sidecar summaries.

## New Design Artifacts

- Design: `docs/superpowers/specs/2026-05-13-cmo-ai-advisory-workspace-design.md`
- Plan: `docs/superpowers/plans/2026-05-13-cmo-ai-advisory-workspace.md`
- Gemini review directive: `handoff/to-gemini/2026-05-13-cmo-ai-advisory-workspace-design-review.md`

## Empirical Scenario Size Check

Local CMO scenario folder scan on 2026-05-13:

- `.scen` files: `1058`
- Total size: `641.1 MB`
- Over `1.25 MB`: `149`
- Over decimal `10 MB`: `2`
- Largest: `17.49 MB`, `Red Dragon Descends 2026 v0.scen`

This confirms that the current browser attachment limit is only a temporary helper and cannot be the long-term scenario ingestion model.

## Locked Direction

- Chat-first UI.
- Consultation mode by default.
- Polite off-topic redirection toward CMO scenario design, Lua automation, event/mission setup, and prompt formulation.
- Lua editor becomes manual scratchpad / validation helper.
- Presets move into wiki-like concept + example + explanation flow.
- Scenario context moves toward path-based scan / sidecar summary, not full browser `.scen` upload.

## Preserved Boundaries

- No automatic AI send.
- No automatic CMO execution.
- No polling, watcher, or live-state claim.
- No `.scen` mutation.
- No browser-supplied privileged roots.
- No raw credential persistence.
- B2/B3/B4 remain explicit user actions.
- CMO engine verification remains required for AI Lua drafts.

## Current Risk

The post-AI-chat bundle is close to the watch line:

- Main JS: about `398.55 kB`
- Main CSS: about `59.32 kB`
- aiContextPruning: `8.56 kB`

Implementation must remove, demote, or lazy-load existing heavy UI rather than simply adding new panels.

## Frontend Architecture Review Response

Gemini's broader frontend review was checked against the current codebase:

- `src/components/LuaAssistant.jsx`: about `220 KB`, `4748` lines.
- `src/index.css`: about `81 KB`, `3438` lines.
- The project has strong `npm run smoke:*` contracts but no Vitest / React Testing Library baseline.
- The package has no editor/state-manager dependency such as Monaco, CodeMirror, Redux, or Zustand.

Accepted now:

- Split `LuaAssistant.jsx`.
- Move pure helpers and UI panels out in small commits.
- Avoid adding broad global CSS.

Deferred:

- Monaco / CodeMirror until scratchpad needs exceed simple manual checking and bundle budget is recovered.
- Zustand until hooks/components prove prop drilling is a real issue.
- Vitest / React Testing Library until a dedicated testing/refactor gate is opened.

The first implementation slice should be shell extraction plus advisory policy contract, not adding another heavy panel.

## Next Gate

Gemini should review UX, information architecture, beginner wording, off-topic redirection tone, and wiki/preset organization before Codex starts implementation.
