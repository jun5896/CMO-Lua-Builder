# Claude Review Directive - B4 User-Triggered State Export

## Status

ACTIVE

## Scope

Review the B4 design and implementation plan only. Do not edit Codex workspace files.

## Read First

```text
docs/superpowers/specs/2026-05-11-b4-user-triggered-state-export-design.md
docs/superpowers/plans/2026-05-11-b4-user-triggered-state-export.md
docs/agent-ops/b4-user-triggered-state-export-planning-2026-05-11.md
docs/contracts/backend-event-import-contract.md
tools/parse-cmo-event-export.mjs
```

## Review Questions

Please answer these questions in a single memo under your Claude workspace handoff area:

1. Is the B4 "user-triggered snapshot import" framing correct after B2 and B3?
2. Is reusing `tools/parse-cmo-event-export.mjs` safe for B4.1, or should Codex add a narrower wrapper contract first?
3. Is the raw/Lua body policy strict enough: strip parser `raw`, return bounded Lua previews only, and never auto-run imported Lua?
4. Are the proposed bounds appropriate for first slice: `256 KiB` input, `50` events, `50` special actions, `600` chars per Lua preview, `20` warnings?
5. Does the endpoint shape `POST /api/cmo/state-snapshot/import` avoid browser-provided filesystem roots and live read-back claims?
6. Does the UI wording avoid implying "live state" while still being useful to a beginner?
7. Which Kimi QA checkpoints should be added or strengthened before B4.1?
8. Should B2-generated export helper snippets be deferred until after manual paste import works?

## Boundaries

Do not recommend any first-slice behavior that adds:

- automatic AI send
- automatic CMO execution
- polling loops
- filesystem watchers
- live daemon claims
- browser-provided CMO/log/scenario/Lua roots
- CMO file writes/deletes
- `.scen` mutation

## Expected Output

Write one concise but evidence-backed review memo and report:

- verdict
- blocking issues, if any
- non-blocking refinements
- recommended Kimi QA additions

Codex will wait for this review before starting B4.1 implementation.
