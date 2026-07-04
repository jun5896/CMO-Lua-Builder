# B3 Log Feedback Loop Planning - 2026-05-10

## Status

APPROVED / REVIEWED

## Purpose

B3 is the next Track B step after the B2 RunScript Sidecar Writer release.

B2 solved the AI draft -> CMO Lua root handoff. B3 should solve the next loop: after the user manually runs `ScenEdit_RunScript('/AiAssist/<file>.lua')` in CMO, the app can help collect recent CMO log feedback and draft a follow-up instruction.

This planning gate intentionally keeps B3 read-only and user-reviewed.

## References

Design:

```text
docs/superpowers/specs/2026-05-10-b3-log-feedback-loop-design.md
```

Implementation plan:

```text
docs/superpowers/plans/2026-05-10-b3-log-feedback-loop.md
```

Current B2 release closeout:

```text
docs/agent-ops/b2-runscript-sidecar-writer-release-closeout-2026-05-10.md
```

## Locked Direction

B3 starts with:

- `ExceptionLog_*.txt` read support.
- `LuaHistory_*.txt` read support.
- Server-side logs root only: `CMO_LOGS_ROOT` or default CMO Logs folder.
- Bounded read response.
- Redacted local paths and secrets.
- Text-only follow-up draft.
- User review before any AI send.

B3 explicitly excludes:

- automatic AI send
- automatic CMO execution
- polling loops
- filesystem watchers
- live read-back claims
- log writes / deletes / truncation
- browser-provided filesystem roots

## Planned Slices

### B3.1 Helper

Files:

- `server/cmo-log-feedback-reader.mjs`
- `tools/verify-cmo-log-feedback-contract.mjs`
- `package.json`

Expected smoke:

```powershell
npm run smoke:cmo-log-feedback
```

### B3.2 Adapter Endpoint

Files:

- `server/ai-provider-adapter.mjs`
- `tools/verify-cmo-log-feedback-endpoint.mjs`
- `package.json`

Expected endpoint:

```text
GET /api/cmo/log-feedback
```

Expected smoke:

```powershell
npm run smoke:cmo-log-feedback-endpoint
```

### B3.3 UI Draft

Files:

- `src/lib/aiAdapterClient.js`
- `src/components/LuaAssistant.jsx`
- `tools/verify-ai-adapter-client-log-feedback-contract.mjs`
- `package.json`

Expected UI behavior:

- User clicks `CMO 로그 확인`.
- UI displays sanitized recent log snippets.
- UI displays `후속 질문 초안`.
- UI does not call AI automatically.

## Verification Baseline To Preserve

Current B2 release baseline:

- Main JS: `380.45 kB`.
- Main CSS: `59.14 kB`.
- `aiContextPruning`: `8.56 kB`.
- Scenario loader: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues`.
- Sidecar audit: `3799` protected, `24` orphans / about `5.6 MB`, dry-run only.
- `npm run verify:release`: PASS.
- AI adapter smoke: PASS with no raw `Bearer` / `Authorization` / `sk-` leakage.

Watch lines:

- Main JS < `400 kB`.
- Main CSS < `60 kB`.
- `aiContextPruning` < `9 kB`.

## Agent Roles

- Codex owns implementation.
- Claude reviewed log-root, redaction, and no-auto-send assumptions before implementation.
- Gemini remains standby until UI wording exists.
- Kimi approved this planning QA and should run focused implementation QA after each slice.

## Planning QA / Design Review Result

Kimi planning QA:

```text
APPROVED - B3 planning gate holds.
36 / 36 static checkpoints passed.
```

Claude design review:

```text
APPROVED with refinements
```

Claude review memo:

```text
C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B3-Log-Feedback-Loop\b3-log-feedback-loop-review.md
```

Refinements locked before or inside B3.1:

- Use positioned tail reads instead of full-file log reads.
- Implement the `since` helper contract rather than leaving it as a no-op.
- Redact forward-slash Windows paths, lowercase drive paths, and UNC paths.
- Add smoke checks that forbid accidental execution, write APIs, or full-log `readFile()` in the helper.

## Current Gate

This planning gate changed docs / handoff only.

Expected changed files:

- `docs/superpowers/specs/2026-05-10-b3-log-feedback-loop-design.md`
- `docs/superpowers/plans/2026-05-10-b3-log-feedback-loop.md`
- `docs/agent-ops/b3-log-feedback-loop-planning-2026-05-10.md`
- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `handoff/to-kimi/CURRENT_TASK.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`
- `handoff/to-kimi/_archive/2026-05-10/2026-05-10-b3-log-feedback-loop-planning-qa.md`
- `handoff/to-claude/_archive/2026-05-10/2026-05-10-b3-log-feedback-loop-design-review.md`
