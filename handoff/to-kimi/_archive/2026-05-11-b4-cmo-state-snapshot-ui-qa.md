# Kimi QA 보고서 - B4.3 CMO State Snapshot UI

날짜: 2026-05-11
대상: `5d3b06d Add B4 CMO state snapshot UI`

## 범위

B4.3 UI state snapshot import 슬라이스 클라이언트 헬퍼 + UI 컨트롤 + 클라이언트 스모크 계약.

변경 파일:

```text
package.json                                       |   1 +
src/components/LuaAssistant.jsx                    | 238 +++++++++++++++++++++
src/lib/aiAdapterClient.js                         |  21 +++
tools/verify-ai-adapter-client-state-snapshot-contract.mjs | 123 +++++++++++
4 files changed, 383 insertions(+)
```

## 파이프라인 결과

```text
git status --short --branch: main...origin/main, 작업 트리 clean
git diff --check: 공백 오류 없음
npm run smoke:ai-adapter-client-state-snapshot: PASS
npm run smoke:cmo-state-snapshot-endpoint: PASS
npm run smoke:cmo-state-snapshot: PASS
npm run smoke:ai-adapter-client-log-feedback: PASS
npm run lint: PASS
npm run build: PASS
npm run smoke:ai-adapter: PASS — Bearer / sk-key 누출 없음
npm run verify:release: PASS (13단계 전체)
  audit:scenario-sidecars: 1899 인덱스 / 3799 보호 / 24 고아 / 5.6 MB
  verify:scenario-loader: 1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues
  lint: PASS
  build: PASS
  smoke:ai-workflow-state: PASS
  smoke:ai-follow-up-needs: PASS
  smoke:ai-confirmed-context: PASS
  smoke:ai-adapter-client-sidecar: PASS
  smoke:cmo-log-feedback: PASS
  smoke:cmo-log-feedback-endpoint: PASS
  smoke:ai-adapter-client-log-feedback: PASS
  smoke:ai-client-parser: PASS
  smoke:ai-adapter: PASS — Bearer / sk-key 누출 없음
```

## 번들 기준선

```text
Main JS: 391.65 kB (< 400 kB, +7.98 kB from B3 baseline)
Main CSS: 59.14 kB (< 60 kB)
aiContextPruning: 8.56 kB (< 9 kB)
```

## 정적 체크포인트 결과

### 범위 및 스크립트 (1-6)

1. **타겟 커밋이 `5d3b06d Add B4 CMO state snapshot UI`** — PASS.

2. **커밋 범위가 정확히 4개 파일** — PASS.
   `package.json`, `src/lib/aiAdapterClient.js`, `src/components/LuaAssistant.jsx`, `tools/verify-ai-adapter-client-state-snapshot-contract.mjs`.

3. **`package.json`에 `smoke:ai-adapter-client-state-snapshot` 추가** — PASS.
   `node tools/verify-ai-adapter-client-state-snapshot-contract.mjs` 스크립트 항목 1줄 추가.

4. **`package-lock.json` 변경 없음** — PASS.
   `git diff 5d3b06d^..5d3b06d -- package-lock.json` 출력 없음.

5. **새 의존성/개발 의존성 추가 없음** — PASS.

6. **`verify:release`가 아직 B4 state snapshot smokes를 포함하지 않음** — PASS.
   `git diff 5d3b06d^..5d3b06d -- package.json`에서 `verify:release` 변경 없음.

### 클라이언트 헬퍼 (7-14)

7. **`src/lib/aiAdapterClient.js`가 `importCmoStateSnapshot` 익스포트** — PASS.
   client diff: `export async function importCmoStateSnapshot({ text, sourceHint } = {})`.
   스모크 108행: `assert.match(clientSource, /export async function importCmoStateSnapshot/)`.

8. **헬퍼가 `/api/cmo/state-snapshot/import`에 POST** — PASS.
   client diff: `` `${AI_ADAPTER_BASE_URL}/api/cmo/state-snapshot/import` ``.
   스모크 28-29행: URL 및 method 확인.

9. **헬퍼가 `POST` 사용** — PASS.
   위와 동일.

10. **헬퍼가 `text`와 선택적 `sourceHint`를 JSON으로 전송** — PASS.
    client diff: `body: JSON.stringify({ text: String(text || ''), sourceHint: sourceHint || undefined })`.
    스모크 33-36행: body 구조 확인.

11. **헬퍼가 브라우저 제공 파일시스템 root 또는 경로 전송 안 함** — PASS.
    client diff에 root 필드 없음. 스모크 37-42행: 6개 필드 모두 body에 없음 확인.
    스모크 110행: `assert.doesNotMatch(clientSource, /cmoRoot|logsRoot|scenarioRoot|luaRoot|filePath|scriptPath/)`.

12. **non-OK HTTP 응답 시 `Error` throw, `status` 및 `body` 보존** — PASS.
    client diff: `error.status = response.status; error.body = body; throw error;`.
    스모크 81-89행: 503 에러 시 `error.status === 503`, `error.body.errorMessage` 보존 확인.

13. **HTTP 200이어도 `body.ok === false` 시 에러** — PASS.
    client diff: `!response.ok || body?.ok === false`.
    스모크 95-104행: HTTP 200 + `ok: false` 시 거부, `error.status === 200` 보존 확인.

14. **헬퍼가 AI chat/프로바이더 함수 미호출** — PASS.
    스모크 111행: `assert.doesNotMatch(clientSource, /sendCmoAiPrompt\([^)]*stateSnapshot/i)`.

### UI 임포트 패널 (15-28)

15. **`LuaAssistant.jsx`가 `importCmoStateSnapshot` 임포트** — PASS.
    LuaAssistant diff 25행: `importCmoStateSnapshot` 추가.
    스모크 114행: `assert.match(luaAssistantSource, /importCmoStateSnapshot/)`.

16. **UI에 `CMO 상태 스냅샷 가져오기` 라벨** — PASS.
    LuaAssistant diff 4476행: `<h3>CMO 상태 스냅샷 가져오기</h3>`.
    스모크 115행: `assert.match(luaAssistantSource, /CMO 상태 스냅샷 가져오기/)`.

17. **UI에 `스냅샷 가져오기` 버튼 텍스트** — PASS.
    LuaAssistant diff 4507-4510행.

18. **UI에 `가져온 CMO 스냅샷` 결과 헤딩** — PASS.
    LuaAssistant diff 4523행: `<h3>가져온 CMO 스냅샷</h3>`.
    스모크 117행: `assert.match(luaAssistantSource, /가져온 CMO 스냅샷/)`.

19. **UI에 `후속 질문 초안 만들기` 버튼 텍스트** — PASS.
    LuaAssistant diff 4554-4557행.
    스모크 118행: `assert.match(luaAssistantSource, /후속 질문 초안 만들기/)`.

20. **UI가 명시적으로 `실시간 연결이 아닙니다` 표시** — PASS.
    LuaAssistant diff 4478-4479행: "가져온 스냅샷은 실시간 연결이 아닙니다."
    스모크 116행: `assert.match(luaAssistantSource, /실시간 연결이 아닙니다/)`.

21. **UI에 붙여넣은 CMO 난괘 텍스트를 위한 수동 텍스트 영역 제공** — PASS.
    LuaAssistant diff 4497-4503행: `<textarea ... placeholder="CMO Lua Console에서 Tool_DumpEvents() 또는 ScenEdit_GetEvent(...) 출력 텍스트를 복사해 붙여넣으세요." />`.

22. **UI에 `Tool_DumpEvents()` 및 `ScenEdit_GetEvent(...)` source hint 제공** — PASS.
    LuaAssistant diff 44-48행: `CMO_STATE_SNAPSHOT_SOURCE_HINTS` 배열에 두 항목 포함.

23. **UI 임포트 액션이 버튼 클릭으로 사용자 트리거** — PASS.
    LuaAssistant diff 4504행: `onClick={importCmoStateSnapshotFromText}`.

24. **UI가 렌더링이나 타이머에서 자동 임포트 안 함** — PASS.
    `useEffect`나 `setInterval`로 자동 임포트 없음.

25. **UI가 폴, 와치, 테일 파일 안 함** — PASS.
    순수 버튼 클릭 핸들러.

26. **UI가 CMO Lua 실행 안 함** — PASS.
    `ScenEdit_*` 호출 없음.

27. **UI가 CMO 파일 쓰기/삭제 안 함** — PASS.
    파일 변이 코드 없음.

28. **UI가 `.scen` 변이 안 함** — PASS.
    `.scen` 관련 코드 없음.

### 스냅샷 렌더링 (29-38)

29. **UI가 가져온 타임스탬프 표시** — PASS.
    LuaAssistant diff 4524행: `{cmoStateSnapshot.snapshot.importedAt || '시간 정보 없음'}`.

30. **UI가 source type 표시** — PASS.
    LuaAssistant diff 4524행: `source {cmoStateSnapshot.snapshot.source?.type || 'unknown'}`.

31. **UI가 `live=false` 표시, 실시간 상태 문구 미사용** — PASS.
    LuaAssistant diff 4524행: `live=false`.

32. **UI가 이벤트 수 표시** — PASS.
    LuaAssistant diff 4527행: `Events: {snapshot.summary?.eventCount ?? 0}`.

33. **UI가 스페셜 액션 수 표시** — PASS.
    LuaAssistant diff 4528행: `Special Actions: {snapshot.summary?.specialActionCount ?? 0}`.

34. **UI가 감지된 API 수 표시** — PASS.
    LuaAssistant diff 4529행: `Detected APIs: {snapshot.summary?.detectedApiCount ?? 0}`.

35. **UI가 경고 수 표시** — PASS.
    LuaAssistant diff 4530행: `Warnings: {snapshot.summary?.warningCount ?? 0}`.

36. **UI가 바운딩된 이벤트 리스트 미리보기 표시** — PASS.
    LuaAssistant diff 4533-4543행: `.slice(0, 5)`로 5개까지만 렌더링.

37. **UI가 Lua 미리보기를 count로 표시, 전체 Lua 본문 재생 안 함** — PASS.
    LuaAssistant diff 4538행: `Lua preview {event.luaScriptPreviews.length}개`.

38. **UI가 raw/Lua body 정책을 엔드포인트/헬퍼 출력에 의존, raw 본문 텍스트 재구성 안 함** — PASS.
    UI가 `luaScriptPreviews`만 사용, `luaScript`/`luaScripts`/`raw` 접근 없음.

### 후속 질문 초안 (39-48)

39. **UI가 가져온 스냅샷에서 텍스트 전용 후속 질문 초안 작성** — PASS.
    LuaAssistant diff 3189-3215행: `buildCmoStateSnapshotFollowUp` 함수가 문자열 배열을 `join('\n')`.

40. **초안이 스냅샷이 임포트되었고 실시간이 아니라고 명시** — PASS.
    LuaAssistant diff 3193행: "이 스냅샷은 사용자가 수동으로 붙여넣은 가져온 스냅샷이며, 실시간 연결이 아닙니다."

41. **초안에 snapshot ID 및 가져온 타임스탬프 포함** — PASS.
    LuaAssistant diff 3194-3195행: `Snapshot ID`, `Imported at`.

42. **초안에 source type 및 `live=false` 포함** — PASS.
    LuaAssistant diff 3196행: `Source: ... / live=false`.

43. **초안에 이벤트/스페셜액션/경고 수 포함** — PASS.
    LuaAssistant diff 3197행: `Counts: events ..., special actions ..., warnings ...`.

44. **초안이 AI에게 누락 Side/Mission/Unit GUID/DBID/RP/Zone 값 발명 금지** — PASS.
    LuaAssistant diff 3203행: "부족한 Side, Mission, Unit GUID, DBID, RP/Zone 값은 추측하지 말고 되물어주세요."

45. **초안이 CMO 엔진 검증 여전히 필요함을 알림** — PASS.
    LuaAssistant diff 3204행: "AI 응답은 초안이며 CMO 엔진 검증은 별도로 필요합니다."

46. **`후속 질문 초안 만들기`가 AI 채팅 입력에만 텍스트 삽입** — PASS.
    LuaAssistant diff 3260행: `setAiChatInstruction(cmoStateSnapshot.followUpDraft)`.
    스모크 119행: `assert.match(luaAssistantSource, /setAiChatInstruction\(cmoStateSnapshot\.followUpDraft\)/)`.

47. **UI가 `sendCmoAiPrompt`를 스냅샷 후속 경로에서 호출 안 함** — PASS.
    `draftCmoStateSnapshotFollowUp`에 `sendCmoAiPrompt` 없음.
    스모크 120행: `assert.doesNotMatch(luaAssistantSource, /sendCmoAiPrompt\([^)]*cmoStateSnapshot/i)`.

48. **UI가 여전히 AI 호출 전 사용자 액션 필요** — PASS.
    초안은 `setAiChatInstruction`으로만 삽입, 자동 전송 없음.

### Confirmed Context (49-53)

49. **UI가 사용자 선택한 스냅샷 object-context 값을 Confirmed Context로 프로모트 가능** — PASS.
    LuaAssistant diff 4545-4559행: 각 candidate마다 "확정" 버튼.

50. **프로모션이 기존 `addConfirmedContextEntry` / confirmed-context 정규화 경로 사용** — PASS.
    LuaAssistant diff 3761-3777행: `promoteStateSnapshotContextValue`가 `addConfirmedContextEntry` 호출.

51. **프로모션이 per-value 사용자 클릭, accept-all 아님** — PASS.
    각 값마다 개별 버튼. LuaAssistant diff 4549행: `onClick={() => promoteStateSnapshotContextValue(candidate)}`.

52. **프로모션 source가 로컬/사용자 검토, 권위적인 실시간 상태로 취급 안 함** — PASS.
    LuaAssistant diff 3774행: `notes: 'User-selected value from imported CMO snapshot. Verify in CMO before treating it as authoritative.'`.

53. **스냅샷 프로모트된 값 제거가 기존 Confirmed Context 제거 경로로 처리** — PASS.
    기존 `addConfirmedContextEntry`/`removeConfirmedContextEntry` 사용, 별도 제거 로직 없음.

### 계약 스모크 (54-63)

54. **`tools/verify-ai-adapter-client-state-snapshot-contract.mjs` 존재** — PASS.
    123행.

55. **스모크가 fetch URL `/api/cmo/state-snapshot/import` 검증** — PASS.
    스모크 28행.

56. **스모크가 method `POST` 검증** — PASS.
    스모크 29행.

57. **스모크가 body가 `text`와 `sourceHint`만 포함 검증** — PASS.
    스모크 33-36행.

58. **스모크가 body에 `cmoRoot`, `logsRoot`, `scenarioRoot`, `luaRoot`, `filePath`, `scriptPath` 없음 검증** — PASS.
    스모크 37-42행.

59. **스모크가 성공 결과 `source.live === false` 포함 검증** — PASS.
    스모크 48행, 73행.

60. **스모크가 non-OK HTTP 에러 처리 검증** — PASS.
    스모크 77-89행.

61. **스모크가 `body.ok === false` 에러 처리 검증** — PASS.
    스모크 92-105행.

62. **스모크가 UI 라벨 및 비실시간 문구 정적 검사** — PASS.
    스모크 114-118행.

63. **스모크가 스냅샷 경로에서 자동 AI send 없음 정적 검사** — PASS.
    스모크 120행.

### 회귀 감시 (64-74)

64. **`src/index.css` 변경 없음** — PASS.
    `git diff 5d3b06d^..5d3b06d -- src/index.css` 출력 없음.

65. **`src/lib/aiContextPruning.js` 변경 없음** — PASS.
    `git diff 5d3b06d^..5d3b06d -- src/lib/aiContextPruning.js` 출력 없음.

66. **`server/**` 변경 없음** — PASS.
    어댑터 diff 없음.

67. **`public/**` 변경 없음** — PASS.
    `git diff 5d3b06d^..5d3b06d -- public` 출력 없음.

68. **Prompt-copy / 수동 폴백 동작 여전히 존재** — PASS.
    LuaAssistant diff에 기존 `copyText` 핸들러 및 초안 복사 버튼 유지.

69. **Lua apply/save가 기존 B2 경로를 통해 `aiParsedResponse.isPasteReady`로 게이트 유지** — PASS.
    `isPasteReady` 관련 로직 변경 없음.

70. **B3 로그 피드백 UI 여전히 존재하고 스모크 통과** — PASS.
    `npm run smoke:ai-adapter-client-log-feedback` PASS.

71. **Main JS 400 kB 미만 유지** — PASS. 391.65 kB.

72. **Main CSS 60 kB 미만 유지** — PASS. 59.14 kB.

73. **`aiContextPruning` 9 kB 미만 유지** — PASS. 8.56 kB.

74. **AI 어댑터 smoke에서 raw `Bearer` / `Authorization` / `sk-` 누출 없음** — PASS.

## 회귀 감시

- B4 UI가 자동 AI 호출을 수행하는가? — 아니오. `sendCmoAiPrompt` 미호출.
- B4 UI가 자동 CMO 실행을 수행하는가? — 아니오.
- 폴링 루프, 파일시스템 와처, 실시간 리드백이 도입되었는가? — 아니오. 순수 버튼 클릭.
- 브라우저 제공 파일시스템 root가 허용되는가? — 아니오. `cmoRoot` 등 미전송.
- 기존 B3 로그 피드백 컨트롤이 변경되었는가? — 아니오. 불변.
- `isPasteReady` 게이트가 변경되었는가? — 아니오. 불변.
- `aiContextPruning`이 변화했는가? — 아니오. 8.56 kB 유지.
- Main CSS가 60 kB를 초과했는가? — 아니오. 59.14 kB.

## 최종 평결

```text
정적 체크포인트: 74 / 74 PASS
파이프라인: 전체 PASS
번들: Main JS 391.65 kB (+7.98 kB) / Main CSS 59.14 kB / aiContextPruning 8.56 kB
드리프트: server/public/README/package-lock/index.css/aiContextPruning.js 변경 없음
회귀: 없음
평결: APPROVED
```

B4.3 UI state snapshot import 슬라이스는 클라이언트 헬퍼 `importCmoStateSnapshot`와 `CMO 상태 스냅샷 가져오기` UI 패널을 추가하며, 사용자가 직접 붙여넣은 CMO 난괘 텍스트를 어댑터를 통해 정화된 바운딩된 스냅샷으로 변환합니다. UI는 명시적으로 `실시간 연결이 아닙니다`를 표시하고, 후속 질문 초안은 텍스트 전용으로 AI 채팅 입력에만 삽입됩니다. 사용자는 개별 클릭으로 스냅샷에서 Confirmed Context로 값을 프로모트할 수 있습니다. B4 전체 구현(Helper → Endpoint → UI)이 완료되었습니다.
