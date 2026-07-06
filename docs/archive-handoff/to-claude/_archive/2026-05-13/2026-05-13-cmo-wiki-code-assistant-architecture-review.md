# Claude Directive - CMO Wiki / Code Assistant Architecture Review

Status: ACTIVE

## Goal

Review the proposed CMO Wiki and Lua editor code-assistant design before Codex starts implementation.

This is a technical architecture and code-boundary review. Do not implement code.

## Read These Files

Required:

- `docs/superpowers/specs/2026-05-13-cmo-wiki-code-assistant-design.md`
- `src/App.jsx`
- `src/components/PresetGuide.jsx`
- `src/components/TemplateLibrary.jsx`
- `src/components/LuaAssistant.jsx`
- `public/template-annotations.json`

Useful context:

- `docs/superpowers/specs/2026-05-13-cmo-ai-advisory-workspace-design.md`
- `docs/superpowers/plans/2026-05-13-cmo-ai-advisory-workspace.md`
- `docs/agent-ops/b4-state-snapshot-import-release-closeout-2026-05-11.md`

## Constraints

- Read-only review.
- Do not edit files.
- Do not create commits.
- Do not install dependencies.
- Do not run destructive commands.
- Do not propose automatic AI send, automatic CMO execution, polling, watchers, live-state claims, or browser-supplied privileged roots.
- Keep B2/B3/B4 safety boundaries intact.

## Current Known Facts

- Current top-level app menu is `Lua 편집 에이전트`, `백과사전`, `설정`.
- `Lua 편집 에이전트` has `AI 에이전트 대화` and `Lua 편집기`.
- Current verified bundle baseline: Main JS `254.00 kB`, Main CSS `59.45 kB`, LuaAssistant lazy chunk `135.22 kB`, `aiContextPruning` `8.56 kB`.
- `public/template-annotations.json` has 51 / 51 coverage.
- `PresetGuide.jsx` and `TemplateLibrary.jsx` already load template/annotation/example data.
- `LuaAssistant.jsx` remains large; avoid making it larger.
- CSS watch line is tight: Main CSS must stay below `60 kB`.

## Review Questions

Please answer directly:

1. Is the proposed split (`CmoWikiPanel`, `LuaEditorCodeAssistant`, `src/lib/cmoWikiEntries.js`) the right boundary?
2. Should the first implementation be wiki-first, editor-assistant-first, or a smaller helper-only slice?
3. What logic must be kept out of `LuaAssistant.jsx` to prevent further monolith growth?
4. How should `TemplateLibrary.jsx` and `PresetGuide.jsx` be reused without turning either into another god component?
5. Is the proposed pure helper enough to normalize `template-annotations`, `templateCatalog`, and installed example manifest data?
6. Are there security/safety gaps around AI draft generation, prompt draft insertion, B2/B3/B4 boundaries, or CMO file operations?
7. Are there bundle/CSS risks in the proposed component split?
8. What should Kimi QA check for the first implementation slice?

## Desired Output

Write a concise review memo with:

- Verdict: APPROVED / APPROVED WITH CHANGES / BLOCKED.
- Blocking issues, if any.
- Important refinements before implementation.
- Recommended first implementation slice.
- Suggested static smoke checkpoints.

Preferred memo path in Claude workspace:

```text
C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-CMO-Wiki-Code-Assistant\cmo-wiki-code-assistant-architecture-review.md
```

If you cannot write the memo file, return the review in your final response.
