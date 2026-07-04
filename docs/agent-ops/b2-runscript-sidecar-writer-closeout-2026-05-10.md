# B2 RunScript Sidecar Writer Closeout - 2026-05-10

## Status

APPROVED / READY FOR CLOSEOUT QA

## Purpose

B2 closes the first practical CMO write bridge after Track A local interpreter completion and Track B0/B0.1 integration probing.

The approved model is deliberately conservative:

```lua
ScenEdit_RunScript('/AiAssist/<file>.lua')
```

CMO execution remains manual. The app writes only paste-ready AI Lua drafts into the CMO Lua root `AiAssist` namespace, then displays the loader snippet for the user to run in CMO.

## Prior Facts

B0.1 proved the runtime boundary on CMO Build 1868:

- `dofile([[...]])` is unavailable in the CMO console sandbox.
- `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` succeeded.
- Scenario-folder auto-load remains unproven.

User-observed CMO output:

```text
AiAssist_B0RunScript_20260510_0448
'Yes'
```

Therefore B2 intentionally uses the CMO Lua root and explicit `ScenEdit_RunScript(...)`, not scenario-folder auto-load.

## Completed Slices

### Planning

```text
3931a95 Plan B2 RunScript sidecar writer
```

References:

```text
docs/agent-ops/b2-runscript-sidecar-writer-planning-2026-05-10.md
docs/superpowers/specs/2026-05-10-b2-runscript-sidecar-writer-design.md
docs/superpowers/plans/2026-05-10-b2-runscript-sidecar-writer.md
```

QA:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-plan-qa.md
```

Result:

```text
APPROVED, 34 / 34 PASS, no regression.
```

Claude design review:

```text
handoff/to-claude/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-design-review.md
C:\Users\dlwls\.claude\cmo-lua-scripts\handoff\to-codex\Track-B2-RunScript-Sidecar-Writer\b2-runscript-sidecar-writer-review.md
```

Result:

```text
APPROVED with minor refinements.
```

### B2.1 Writer Helper

```text
b1fce05 Add B2 RunScript sidecar writer helper
```

Scope:

```text
package.json
server/cmo-lua-sidecar-writer.mjs
tools/verify-cmo-lua-sidecar-writer-contract.mjs
```

QA:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-writer-helper-qa.md
```

Result:

```text
APPROVED, 34 / 34 PASS, no regression.
```

Approved behavior:

- Helper defaults to dry-run.
- Confirmed write requires `isPasteReady === true`, `dryRun === false`, and `confirmWrite === true`.
- Writes use the fixed `AiAssist` namespace.
- File creation uses exclusive mode to prevent overwrite.
- Loader snippet uses `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
- Response omits Lua body.
- Unsafe Lua surfaces are blocked, including `os.*`, `io.*`, `require`, `dofile`, `loadfile`, `package.*`, `debug.*`, and nested `ScenEdit_RunScript`.

### B2.2 Adapter Endpoint

```text
203b9d7 Add B2 RunScript sidecar endpoint
```

Scope:

```text
package.json
server/ai-provider-adapter.mjs
tools/verify-cmo-lua-sidecar-endpoint.mjs
```

QA:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-endpoint-qa.md
```

Result:

```text
APPROVED, 34 / 34 PASS, no regression.
```

Approved behavior:

- Endpoint route: `POST /api/cmo/lua-sidecar`.
- Endpoint reuses B2.1 `createLuaSidecar`.
- Request-body `cmoLuaRoot` is ignored.
- Root comes from server environment/default helper only.
- Endpoint supports dry-run and confirmed write gates.
- Endpoint returns no Lua body.
- Responses and logs remain scrubbed by adapter redaction.

### B2.3 UI Save Controls

```text
2df8e57 Add B2 sidecar save controls
```

Scope:

```text
package.json
tools/verify-ai-adapter-client-sidecar-contract.mjs
src/lib/aiAdapterClient.js
src/components/LuaAssistant.jsx
```

QA:

```text
handoff/to-kimi/_archive/2026-05-10/2026-05-10-b2-runscript-sidecar-ui-save-controls-qa.md
```

Result:

```text
APPROVED, 35 / 35 PASS, no regression.
```

Approved behavior:

- `saveCmoLuaSidecar()` posts JSON to `/api/cmo/lua-sidecar`.
- UI dry-run label: `CMO 파일 준비`.
- UI confirmed-write label: `CMO Lua 폴더 저장`.
- Buttons are disabled unless `canApplyAiLua` is true.
- `canApplyAiLua` remains derived from `aiParsedResponse.isPasteReady`.
- Browser does not send `cmoLuaRoot`.
- Loader snippet display uses the adapter response.
- Existing `Prompt 복사` fallback remains visible.
- No new CSS was added; existing classes are reused.

## Verification Baseline

Latest B2.3 QA pipeline:

```text
npm run smoke:ai-adapter-client-sidecar: PASS
npm run smoke:cmo-lua-sidecar-endpoint: PASS
npm run smoke:cmo-lua-sidecar-writer: PASS
npm run smoke:cmo-lua-load-check: PASS
npm run lint: PASS
npm run build: PASS
npm run smoke:ai-adapter: PASS, no raw auth leakage
npm run verify:release: PASS
```

Bundle baseline after B2:

```text
Main JS: 380.45 kB
Main CSS: 59.14 kB
aiContextPruning: 8.56 kB
PresetGuide lazy chunk: 33.99 kB JS / 7.49 kB CSS
```

Scenario / sidecar baseline:

```text
1899 total scenarios
1857 readyWithInternalSidecar
42 decoderFailed
0 issues
3799 protected sidecar files
24 orphans / 5.6 MB
```

## Preserved Boundaries

Unchanged:

- No scenario-folder auto-load claim.
- No automatic CMO execution.
- No CMO polling.
- No log tailing.
- No live read-back.
- No AI auto-send.
- No browser-provided filesystem root.
- No package-lock drift.
- No new dependency.
- No `src/index.css` growth.
- Manual prompt-copy fallback remains available.
- AI Lua apply and sidecar save remain gated by paste-ready state.

## Operating Result

B2 is approved as a local, user-triggered CMO Lua sidecar writer path:

1. AI generates a paste-ready Lua draft.
2. User selects `CMO 파일 준비` to preview the target file and loader snippet.
3. User selects `CMO Lua 폴더 저장` only after accepting the draft.
4. User manually runs the displayed `ScenEdit_RunScript('/AiAssist/<file>.lua')` snippet in CMO.
5. User verifies the result in the CMO engine.

B2 does not claim engine validation. It only reduces the copy/file handoff friction while preserving manual control.

## Recommended Next Gate

Recommended next work after closeout QA:

```text
B2 release marker / README update
```

Alternative next track:

```text
B3 log feedback loop planning
```

B3 should start only after B2 closeout QA is archived, because B3 depends on the proven manual RunScript writer path.
