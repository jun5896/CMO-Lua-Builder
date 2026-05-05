# Collaboration Log

## Current Role Split

- Codex: primary worker, UI/UX owner, React integration, final validation.
- Claude Code: backend/helper worker, parser/scanner/API relay prototypes.

## Active Safety Rule

Claude should avoid direct edits to `src/components/LuaAssistant.jsx`, `src/App.jsx`, and `src/index.css` while Codex is actively shaping the UI.

## Claude Reported Status

- Hourly cron sync is active at `:17`.
- `codex_watch` can be called immediately when the user asks or when new changes are suspected.
- The read-only promise is mutual and is now also recorded in Codex handoff guidance.
- Backend implementation is paused until Codex review/assignment.
- Claude may use its watch/digest helper to summarize newly detected Codex work.

## Suggested Claude Work Queue

1. Event export parser for CMO Lua Console/Event Editor dumps.
2. Scenario folder scanner for `.scen`, `.ini`, `.lua`, and workshop metadata.
3. Backend JSON contract for feeding parsed scenario/event data into Object Context and AI request prompts.
4. Optional local API relay design for OpenAI/OpenRouter-compatible providers, without storing secrets.

