# B4 User-Triggered State Export Planning - 2026-05-11

## Status

OPEN FOR REVIEW / QA

## Purpose

B4 is the next Track B step after the B3 Log Feedback Loop release.

B2 solved the AI draft to CMO Lua root handoff. B3 solved the read-only log feedback loop after manual CMO execution. B4 should start the read-back path by importing user-triggered CMO state exports into the local assistant.

This planning gate intentionally keeps B4 manual, bounded, and user-reviewed.

## References

Design:

```text
docs/superpowers/specs/2026-05-11-b4-user-triggered-state-export-design.md
```

Implementation plan:

```text
docs/superpowers/plans/2026-05-11-b4-user-triggered-state-export.md
```

Current B3 release closeout:

```text
docs/agent-ops/b3-log-feedback-loop-release-closeout-2026-05-11.md
```

Existing parser contract:

```text
docs/contracts/backend-event-import-contract.md
tools/parse-cmo-event-export.mjs
```

## Locked Direction

B4 starts with:

- User-pasted `Tool_DumpEvents()` / `ScenEdit_GetEvent(...)` text.
- Parser reuse through `tools/parse-cmo-event-export.mjs`.
- Sanitized state snapshot objects.
- Timestamped source metadata.
- `source.live === false`.
- Text-only follow-up draft.
- Optional user-selected promotion into Confirmed Context.

B4 explicitly excludes:

- automatic AI send
- automatic CMO execution
- polling loops
- filesystem watchers
- silent real-time daemon behavior
- browser-provided CMO/log/scenario/Lua roots
- CMO file writes / deletes
- `.scen` mutation
- claims of live unit position read-back

## Planned Slices

### B4.1 Snapshot Import Helper

Files:

- `server/cmo-state-snapshot-importer.mjs`
- `tools/verify-cmo-state-snapshot-contract.mjs`
- `package.json`

Expected smoke:

```powershell
npm run smoke:cmo-state-snapshot
```

### B4.2 Adapter Endpoint

Files:

- `server/ai-provider-adapter.mjs`
- `tools/verify-cmo-state-snapshot-endpoint.mjs`
- `package.json`

Expected endpoint:

```text
POST /api/cmo/state-snapshot/import
```

Expected smoke:

```powershell
npm run smoke:cmo-state-snapshot-endpoint
```

### B4.3 UI Import Panel

Files:

- `src/lib/aiAdapterClient.js`
- `src/components/LuaAssistant.jsx`
- `tools/verify-ai-adapter-client-state-snapshot-contract.mjs`
- `package.json`

Expected UI behavior:

- User pastes a CMO export.
- User clicks `스냅샷 가져오기`.
- UI displays a sanitized `가져온 CMO 스냅샷`.
- UI can create a `후속 질문 초안`.
- UI does not call AI automatically.

Expected smoke:

```powershell
npm run smoke:ai-adapter-client-state-snapshot
```

## Verification Baseline To Preserve

Current B3 release baseline:

- Main JS: `383.67 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.
- `npm run verify:release`: PASS with the 13-step expanded chain.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

Watch lines:

- Main JS < `400 kB`.
- Main CSS < `60 kB`.
- `aiContextPruning` < `9 kB`.

## Agent Roles

- Codex owns implementation.
- Claude should review B4 parser reuse, raw/Lua body handling, endpoint shape, and wording around live read-back before B4.1 begins.
- Gemini remains standby until B4.3 UI wording exists.
- Kimi should run focused planning QA and implementation QA after each slice.

## Planning QA / Design Review Gate

Expected changed files for this planning gate:

- `docs/superpowers/specs/2026-05-11-b4-user-triggered-state-export-design.md`
- `docs/superpowers/plans/2026-05-11-b4-user-triggered-state-export.md`
- `docs/agent-ops/b4-user-triggered-state-export-planning-2026-05-11.md`
- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `handoff/to-kimi/CURRENT_TASK.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`
- `handoff/to-kimi/2026-05-11-b4-user-triggered-state-export-planning-qa.md`
- `handoff/to-claude/2026-05-11-b4-user-triggered-state-export-design-review.md`

Planning QA should confirm this is docs / handoff only and that no product code, backend route, parser code, package script, dependency, lockfile, release tag, or GitHub Release is introduced yet.

## Current Gate

B4 is open for design review and planning QA only.

Implementation begins only after:

- Kimi approves the planning gate.
- Claude answers the B4 design review.
