# B2 RunScript Sidecar Writer Planning - 2026-05-10

## Status

APPROVED / READY FOR B2.1

## Purpose

Track A is complete as a local AI interpreter UI baseline. Track B0 and B0.1 established the local CMO integration facts needed before writing any Lua files.

B2 planning now starts from the proven execution path:

```lua
ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')
```

The B0.1 manual check proved this CMO Lua-root execution path and disproved `dofile(...)` for CMO Build 1868 console sandbox.

## Design References

```text
docs/superpowers/specs/2026-05-10-b2-runscript-sidecar-writer-design.md
docs/superpowers/plans/2026-05-10-b2-runscript-sidecar-writer.md
```

## Review / QA Result

Kimi planning QA:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-plan-qa.md
```

- Verdict: APPROVED.
- Static checkpoints: 34 / 34 PASS.
- Scope: docs / handoff only; no `src/**`, `server/**`, `tools/**`, `public/**`, package, or lockfile drift.

Claude design review:

```text
handoff/to-claude/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-design-review.md
C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B2-RunScript-Sidecar-Writer\b2-runscript-sidecar-writer-review.md
```

- Verdict: APPROVED with minor refinements.
- Codex may proceed to B2.1 writer-helper implementation.
- Non-blocking refinements folded into the spec / plan: server-confirmed `confirmedDryRun` / `confirmedWrite`, response omits Lua body, malicious request-body `cmoLuaRoot` ignored, existing-file UX copy, `AiAssist_B0` sibling namespace note, and conservative nested `ScenEdit_RunScript` handling.

## Locked B2 Direction

- Use CMO `Lua` root, not scenario folders.
- Use fixed `AiAssist` namespace.
- Use explicit `ScenEdit_RunScript('/AiAssist/<file>.lua')` snippets.
- Keep CMO execution manual.
- Keep UI save gated by `aiParsedResponse.isPasteReady === true`.
- Require dry-run preview before confirmed write.
- Do not let the browser send arbitrary filesystem roots.
- Do not introduce log tailing, polling, live read-back, or AI auto-send.

## Planned Slices

1. Writer helper and smoke contract.
2. Adapter endpoint and endpoint smoke.
3. UI save controls and loader-snippet display.
4. Kimi QA and agent handoff update.

## Expected Watch Lines

Current protected baseline:

```text
Main JS: 377.99 kB
Main CSS: 59.14 kB
aiContextPruning: 8.56 kB
```

Main CSS is close to the `60 kB` line. B2 UI should reuse existing classes and avoid `src/index.css` growth where possible.

## Completed Review Requests

Claude reviewed:

- CMO runtime assumptions.
- Path safety.
- Fixed `AiAssist` namespace.
- Endpoint boundary and root source.
- Whether blocking nested `ScenEdit_RunScript` inside saved content is too strict or appropriate for the first writer slice.

Kimi verified:

- Docs / plan consistency.
- No source implementation happened yet.
- The next implementation plan preserves B0.1 facts.
- Watch-line and safety invariants are still documented.

Gemini remains standby until user-facing Korean UI wording is implemented.

## Next Gate

Proceed to B2.1: writer helper plus smoke contract only. Keep the first implementation slice backend-helper focused; do not add the adapter endpoint, UI controls, log tailing, polling, live read-back, or AI auto-send in the same slice.
