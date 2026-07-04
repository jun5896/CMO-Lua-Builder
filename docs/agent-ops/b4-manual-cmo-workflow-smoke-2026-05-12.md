# B4 Manual CMO Workflow Smoke - 2026-05-12

Status: READY / USER-RUN

This runbook is the first end-to-end manual CMO workflow smoke after the B4 State Snapshot Import release and post-release operating recheck.

It verifies the real user handoff path:

```text
B2 save -> user ScenEdit_RunScript('/AiAssist/<file>.lua') in CMO -> B3 log feedback -> B4 state snapshot import -> text-only AI follow-up draft
```

## Preconditions

- Current public release: `release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- Latest operating recheck: `eca6c13 Record B4 post-release operating recheck`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-12-b4-post-release-operating-recheck-qa.md`.
- `npm run verify:release` is recorded as PASS after approved rerun from Windows sandbox `spawn EPERM`.
- B0.1 proved that CMO Build 1868 does not expose `dofile(...)` in the console sandbox.
- B0.1 proved that explicit CMO Lua-root `ScenEdit_RunScript('/AiAssist_B0/AiAssist_B0LoadCheck.lua')` printed marker `AiAssist_B0RunScript_20260510_0448` and returned `Yes`.
- Use a disposable/test scenario first.
- Do not mutate `.scen` files as part of this smoke.
- Do not rely on automatic scenario-folder `.lua` loading.

## Local Setup

From `C:\Users\dlwls\.codex\cmo-lua-ui`, start the adapter and UI in separate terminals:

```powershell
npm run start:ai-adapter
```

```powershell
npm run dev
```

Open the Vite URL shown by `npm run dev`.

## Step 1 - Generate A Harmless AI Lua Draft

Use the AI interpreter with a harmless marker-only request. Suggested prompt:

```text
CMO Lua 테스트용 초안을 작성해 주세요.
시나리오 상태를 바꾸지 말고 다음 마커만 출력하세요: AiAssist_E2E_YYYYMMDD_HHMM.
print만 사용하고 os/io/require/dofile/loadfile/package/debug/ScenEdit_RunScript는 사용하지 마세요.
CMO 엔진 검증 필요를 명시하고 paste-ready 형식으로 작성하세요.
```

Expected UI result:

- The response is paste-ready.
- Lua apply/save controls remain gated by `isPasteReady`.
- Existing manual prompt-copy fallback remains available.

Evidence to capture:

```text
Marker:
Paste-ready status:
Any BLOCKER / ask-back state:
```

## Step 2 - B2 Save To CMO Lua Root

In the UI:

1. Click `CMO 파일 준비`.
2. Verify the dry-run target and loader snippet.
3. Click `CMO Lua 폴더 저장` only after confirming the draft.

Expected result:

- Loader snippet shape is `ScenEdit_RunScript('/AiAssist/<file>.lua')`.
- Browser does not supply `cmoLuaRoot`.
- Saved content is an AI Lua draft; execution remains manual.
- CMO engine verification remains required.

Evidence to capture:

```text
Saved file:
Loader snippet:
Dry-run message:
Write message:
```

## Step 3 - User Runs The Draft In CMO

In CMO Lua Console or the internal Lua editor, run the exact loader snippet shown by the UI.

If the UI shows:

```lua
ScenEdit_RunScript('/AiAssist/AiAssist_example.lua')
```

then run:

```lua
print(ScenEdit_RunScript('/AiAssist/AiAssist_example.lua'))
```

Expected result:

- The marker prints in CMO.
- `ScenEdit_RunScript(...)` returns a positive result such as `Yes` or equivalent CMO success output.
- No `dofile(...)` is used.

Evidence to capture:

```text
CMO console output:
RunScript return value:
Observed marker:
Any CMO error:
```

## Step 4 - B3 Read-Only Log Feedback

After the CMO run, return to the UI and click `CMO 로그 확인`.

Expected result:

- The UI shows a bounded CMO log snapshot.
- Recent `ExceptionLog_*.txt` / `LuaHistory_*.txt` content is read-only.
- Paths and secrets are redacted.
- `후속 질문 초안` is created as text only.
- AI is not called automatically.

Evidence to capture:

```text
Log feedback state:
Recent log count / timestamp:
Was marker or RunScript path visible:
Was any path/secret redacted:
Was follow-up draft inserted without auto-send:
```

## Step 5 - B4 User-Triggered State Snapshot Import

Copy CMO event/state export text from CMO.

Preferred sources:

```lua
Tool_DumpEvents()
```

or:

```lua
ScenEdit_GetEvent('<event name>')
```

In the UI:

1. Paste the copied text into `CMO 상태 스냅샷 가져오기`.
2. Choose the closest source hint, or leave auto classify if unsure.
3. Click `스냅샷 가져오기`.

Expected result:

- The UI labels the result as an imported snapshot, not live state.
- `source.live === false` remains true.
- Raw Lua bodies are stripped; bounded previews only are shown.
- Event/special-action counts and truncation signals are visible when applicable.
- No polling, watcher, automatic CMO execution, or AI auto-send occurs.

Evidence to capture:

```text
Snapshot source type:
Imported event count:
Imported special action count:
source.live value shown or implied:
Any parse warning:
Any truncation signal:
```

## Step 6 - Text-Only Follow-Up Draft

Click `후속 질문 초안 만들기`.

Expected result:

- A follow-up draft is inserted into the AI chat input.
- The draft references the imported snapshot/log context.
- The user must review and explicitly send it.
- No automatic AI call is made.

Evidence to capture:

```text
Draft inserted into chat input:
Auto-send occurred? (expected: no)
Confirmed Context promotion used? (optional):
```

## Pass Criteria

- B2 writes a user-approved AiAssist Lua draft and returns a `ScenEdit_RunScript('/AiAssist/<file>.lua')` snippet.
- The user can manually run the snippet in CMO and observe the marker.
- B3 reads recent CMO log feedback without writing files or auto-sending AI requests.
- B4 imports user-pasted CMO event/state text as a bounded, redacted snapshot with `source.live === false`.
- Follow-up drafts remain text-only and user-reviewed.
- Prompt-copy fallback and `isPasteReady` gates remain available.

## Fail Branches

- B2 write fails: inspect the adapter process, CMO Lua root configuration, and existing-file collision message.
- CMO RunScript fails: capture the exact loader snippet, CMO console output, and saved AiAssist path.
- B3 log feedback is empty: verify CMO wrote `ExceptionLog_*.txt` / `LuaHistory_*.txt` after the manual run.
- B4 snapshot parse fails: capture a redacted `Tool_DumpEvents()` / `ScenEdit_GetEvent(...)` sample for parser refinement.
- Any automatic AI send or automatic CMO execution occurs: treat as a blocker regression.

## User Evidence Template

```text
Manual CMO Workflow Smoke Evidence - 2026-05-12

Scenario:
CMO build:
Marker:

B2 saved file:
B2 loader snippet:
B2 write result:

CMO RunScript console output:
CMO RunScript return:
CMO error, if any:

B3 log feedback result:
B3 redaction observed:
B3 follow-up draft text-only:

B4 snapshot source:
B4 imported event count:
B4 imported special action count:
B4 source.live:
B4 warning/truncation:

Follow-up draft inserted:
Auto-send observed:
Confirmed Context promotion:

Verdict:
Notes:
```

## Next Gate

After user-run evidence is available:

- If the smoke passes, create a manual smoke result closeout and focused Kimi QA directive.
- If the smoke fails, open the smallest focused fix slice for the failing layer: B2 save, CMO RunScript, B3 log feedback, or B4 snapshot import.
