# Handoff Folder Policy

## Active Files

Each agent folder should keep only the current live instruction file at the top level:

- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`
- `handoff/to-kimi/CURRENT_TASK.md`

Date-stamped one-off review, QA, or directive files should be archived after the user reports completion or Codex records the result.

## Archive Layout

Use per-agent archive folders:

```text
handoff/to-kimi/_archive/YYYY-MM-DD/
handoff/to-claude/_archive/YYYY-MM-DD/
handoff/to-gemini/_archive/YYYY-MM-DD/
```

Do not delete completed handoff files by default. Move them into `_archive` so the evidence trail remains available.

## Current Cleanup

2026-05-05 cleanup:

- Moved `36` completed Kimi QA handoff files into `handoff/to-kimi/_archive/2026-05-05/`.
- Moved `5` completed Claude review handoff files into `handoff/to-claude/_archive/2026-05-05/`.
- Left all `CURRENT_TASK.md` files in place.
- `to-gemini` had only `CURRENT_TASK.md`, so no archive move was needed.
- Later the same day, archived the completed CSS Slim / Preset Guide lazy split QA handoff after Kimi approved it.
- Archived the completed final protection group 1 sidecar QA handoff after Kimi approved it.
- Archived the completed final protection group 2 AI provider QA handoff after Kimi approved it.
- Archived the completed final protection group 3 AI assistant QA handoff after Kimi approved it.
- Archived the completed final protection group 4 Preset Guide QA handoff after Kimi approved it.
- Archived the completed final protection group 5 docs/handoff QA handoff after Kimi approved it.
- Archived the completed Gemini AI assistant / sidecar compact UX wording handoff after Codex incorporated the safe wording subset.

## Agent Rule

- Codex creates a date-stamped handoff only when a concrete review or QA task is ready.
- Kimi reports QA results, then the completed handoff can be archived.
- Claude review directives can be archived after the design or contract answer has been delivered.
- Gemini wording tasks can be archived after Codex incorporates or declines the text.
