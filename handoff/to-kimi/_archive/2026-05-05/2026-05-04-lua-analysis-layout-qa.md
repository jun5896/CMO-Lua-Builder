# Kimi QA Task - Lua Analysis Layout Stabilization

## Status
Codex completed a layout stabilization pass for `Event / Lua Assistant > Lua 분석`.

## Goal
Verify that the Lua analysis workspace remains usable when a scenario bundle loads many Lua files and API hints.

## Commands
Run these from `C:\Users\dlwls\.codex\cmo-lua-ui`:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

## UI Checks
- `Event / Lua Assistant > Lua 분석` opens without broken overlap in the right analysis column.
- The right column uses one stable card-level scroll instead of nested sections visually spilling over each other.
- `Bundle API Summary` is visible when collapsed and expands without covering `Detected APIs`, hints, or helper sections.
- The Lua file bundle list stays compact while collapsed and does not reduce the main Lua editor unnecessarily.
- The main Lua editor keeps a large usable editing area with scenario Lua bundles loaded.
- `Scenario Inspector / Loader` remains compact in ready state and does not push the Lua editor excessively downward.

## Report Format
Report only:
- pass/fail for lint, build, smoke
- JS/CSS bundle size
- actionable UI regressions, if any
- untracked critical files, if any

## Do Not
- Do not edit `src/**`, `server/**`, or `tools/**`.
- Do not commit.
- Do not propose broad refactors unless the UI is actually broken.

## User Handoff Command
Kimi에게 아래처럼 전달하면 됩니다:

```text
handoff/to-kimi/2026-05-04-lua-analysis-layout-qa.md 지침대로 Lua 분석 레이아웃 QA를 수행하고 결과만 보고해줘.
```
