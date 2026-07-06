# Kimi QA 보고서 - B4.1 CMO State Snapshot Helper

날짜: 2026-05-11
대상: `876903f Add B4 CMO state snapshot helper`

## 범위

B4.1 state snapshot import helper 슬라이스 순수 서버 사이드 헬퍼 + 스모크 계약.

변경 파일:

```text
package.json                                 |   1 +
server/cmo-state-snapshot-importer.mjs       | 176 ++++++++++++++++++++++++++++
tools/verify-cmo-state-snapshot-contract.mjs | 140 +++++++++++++++++++++++
3 files changed, 317 insertions(+)
```

## 파이프라인 결과

```text
git status --short --branch: main...origin/main, 작업 트리 clean
git diff --check: 공백 오류 없음
npm run smoke:cmo-state-snapshot: PASS
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
Main JS: 383.67 kB (< 400 kB)
Main CSS: 59.14 kB (< 60 kB)
aiContextPruning: 8.56 kB (< 9 kB)
```

## 정적 체크포인트 결과

### 타겟 및 파일 존재 (1-7)

1. **타겟 커밋이 `876903f Add B4 CMO state snapshot helper`** — PASS.

2. **타겟 범위가 정확히 3개 파일** — PASS.
   `package.json`, `server/cmo-state-snapshot-importer.mjs`, `tools/verify-cmo-state-snapshot-contract.mjs`.

3. **`package-lock.json` 변경 없음** — PASS.
   `git diff 876903f^..876903f -- package-lock.json` 출력 없음.

4. **새 의존성/개발 의존성 추가 없음** — PASS.

5. **`package.json`에 `smoke:cmo-state-snapshot` 포함** — PASS.
   `node tools/verify-cmo-state-snapshot-contract.mjs` 스크립트 항목 1줄 추가.

6. **`verify:release`가 아직 B4 smoke를 포함하지 않음** — PASS.
   `git diff 876903f^..876903f -- package.json`에서 `verify:release` 변경 없음.

7. **`server/cmo-state-snapshot-importer.mjs` 존재** — PASS.
   176행.

### 상수 익스포트 (8-13)

8. **`MAX_CMO_STATE_IMPORT_BYTES` 익스포트** — PASS.
   3행: `256 * 1024`.

9. **`MAX_STATE_EVENTS` 익스포트** — PASS.
   4행: `50`.

10. **`MAX_STATE_SPECIAL_ACTIONS` 익스포트** — PASS.
    5행: `50`.

11. **`MAX_STATE_WARNINGS` 익스포트** — PASS.
    6행: `20`.

12. **`MAX_LUA_PREVIEW_CHARS` 익스포트** — PASS.
    7행: `600`.

13. **`LUA_PREVIEW_CHAR_UNIT` 익스포트** — PASS.
    8행: `'utf16-code-units'`.

### 함수 익스포트 및 파서 연동 (14-22)

14. **`redactCmoStateText` 익스포트** — PASS.
    27-44행.

15. **`buildCmoStateSnapshot` 익스포트** — PASS.
    115-176행.

16. **`MAX_CMO_STATE_IMPORT_BYTES`가 `256 * 1024`** — PASS.
    3행.

17. **`MAX_STATE_EVENTS`가 `50`** — PASS.
    4행.

18. **`MAX_STATE_SPECIAL_ACTIONS`가 `50`** — PASS.
    5행.

19. **`MAX_STATE_WARNINGS`가 `20`** — PASS.
    6행.

20. **`MAX_LUA_PREVIEW_CHARS`가 `600`** — PASS.
    7행.

21. **`LUA_PREVIEW_CHAR_UNIT`가 `utf16-code-units`** — PASS.
    8행.

22. **헬퍼가 `../tools/parse-cmo-event-export.mjs`에서 `parse` 임포트** — PASS.
    1행.

### 입력 검증 (23-24)

23. **헬퍼가 빈 입력 거부** — PASS.
    117-119행: `!input.trim()` 시 `Error('CMO state snapshot import is empty.')`.
    스모크 131-133행: `assert.throws(() => buildCmoStateSnapshot('   '), /empty/i)`.

24. **헬퍼가 초과 크기 입력 거부** — PASS.
    121-124행: `byteLength > MAX_CMO_STATE_IMPORT_BYTES` 시 `Error`.
    스모크 126-129행: `MAX_CMO_STATE_IMPORT_BYTES + 1`에 대해 `/too large/i` throws 확인.

### Redaction (25-33)

25. **헬퍼가 파싱 전 redaction 수행, 설명 주석 포함** — PASS.
    129-131행 주석: "Redact before parse so parser output cannot retain local paths or secrets."
    스모크 138행: `assert.match(helperSource, /Redact before parse/i)`.

26. **Redaction 교체 토큰이 XML 괄호/따옴표/중괄호 문자 회피** — PASS.
    토큰: `REDACTED_USER_PATH`, `REDACTED_PATH`, `REDACTED_SECRET` — XML/Lua 구조물 미포함.

27. **역슬래시 사용자 경로 redaction** — PASS.
    36행 정규식. 스모크 74행/106행: `dlwls` 미포함.

28. **정슬래시 사용자 경로 redaction** — PASS.
    36행 `/gi` 플래그. 스모크 73행/106행 확인.

29. **소문자 드라이브 경로 redaction** — PASS.
    36행 `/gi` 대소문자 무시. 스모크 74행/106행 확인.

30. **UNC 경로 redaction** — PASS.
    37행 정규식. 스모크 75행/107행: `server\share` 미포함.

31. **`Authorization` 헤더 redaction** — PASS.
    39행. 스모크 76행/108행 확인.

32. **`Bearer` 토큰 redaction** — PASS.
    40행. 스모크 76행/108행 확인.

33. **`sk-` 스타일 시크릿 redaction** — PASS.
    41행. 스모크 77행/109행 확인.

### 스냅샷 구조 (34-44)

34. **스냅샷에 `ok: true`** — PASS.
    142행.

35. **스냅샷에 파일시스템 안전한 `snapshotId`** — PASS.
    143행: `snapshotIdFromTimestamp`가 `:` 및 `.`을 `-`로 대체.
    스모크 86행: `'cmo-state-2026-05-11T00-00-00-000Z'`.

36. **스냅샷에 `importedAt`** — PASS.
    144행.

37. **스냅샷 `source.live === false`** — PASS.
    148행. 스모크 89행, 122행 확인.

38. **스냅샷 source type이 파서 기반** — PASS.
    146행: `parsed.source?.type || 'unknown'`.

39. **Summary에 `totalEventCount` 포함** — PASS.
    151행.

40. **Summary에 `eventsTruncated` 포함** — PASS.
    153행.

41. **Summary에 `totalSpecialActionCount` 포함** — PASS.
    154행.

42. **Summary에 `specialActionsTruncated` 포함** — PASS.
    156행.

43. **Summary에 `warningsTruncated` 포함** — PASS.
    160행.

44. **Summary에 `luaPreviewCharUnit` 포함** — PASS.
    163행.

### 바운딩 (45-47)

45. **이벤트 리스트가 50개로 제한** — PASS.
    134행: `boundArray(parsed.events, MAX_STATE_EVENTS)`.
    스모크 90-92행: 55개 입력 → `eventCount: 50`, `eventsTruncated: true`.

46. **스페셜 액션 리스트가 50개로 제한** — PASS.
    135행. 스모크 93-95행: 55개 입력 → `specialActionCount: 50`, `specialActionsTruncated: true`.

47. **경고 리스트가 20개로 제한** — PASS.
    136행: `boundArray(parsed.warnings, MAX_STATE_WARNINGS)`.

### Raw/Lua 노출 제거 (48-53)

48. **파서 `raw` 필드가 중첩 이벤트/트리거/조건/액션/스페셜액션에서 제거** — PASS.
    `sanitizeChild`(62행), `sanitizeEvent`(72행)에서 `delete child.raw`.
    스모크 54-68행: `assertNoRawOrLuaBody`가 전체 스냅샷을 재귀적으로 검사.

49. **전체 `luaScript` 값 미노출** — PASS.
    `sanitizeChild`(63-65행): `luaScriptPreview` 생성 후 `delete child.luaScript`.
    스모크 57행: `Object.hasOwn(value, 'luaScript')` 거부.

50. **전체 `luaScripts` 배열 미노출** — PASS.
    `sanitizeEvent`(75행): `delete sanitized.luaScripts`.
    스모크 58행: `Object.hasOwn(value, 'luaScripts')` 거부.

51. **Lua 스크립트 본문이 바운딩된 미리보기로 표현** — PASS.
    `toLuaPreview`(50-58행): `text.slice(0, MAX_LUA_PREVIEW_CHARS)`.

52. **미리보기 객체에 `truncated`, `originalLength`, `charUnit` 포함** — PASS.
    54-56행. 스모크 101-102행 확인.

53. **Object-context 힌트가 복사되지만 확인된 값으로 승격되지 않음** — PASS.
    168행: `sanitizeObjectContext`가 단순 배열 복사만 수행.

### 보안 및 드리프트 (54-62)

54. **헬퍼에 파일시스템 변이 API 없음** — PASS.
    스모크 136행: `assert.doesNotMatch(helperSource, /\b(?:writeFile|appendFile|truncate|unlink|rename|rm|watch)\b/)`.

55. **헬퍼에 프로세스 실행 API 없음** — PASS.
    스모크 137행: `assert.doesNotMatch(helperSource, /\b(?:spawn|exec|execFile|fork)\b/)`.

56. **헬퍼가 어댑터 라우트 추가 안 함** — PASS.
    `server/ai-provider-adapter.mjs` diff 없음.

57. **헬퍼가 UI 컨트롤 추가 안 함** — PASS.
    `src/**` diff 없음.

58. **헬퍼가 브라우저 제공 root 읽지 않음** — PASS.
    `buildCmoStateSnapshot` 시그니처에 root 파라미터 없음.

59. **헬퍼가 AI 호출 안 함** — PASS.
    `fetch`, `http`, `send` 등 네트워크 코드 없음.

60. **헬퍼가 CMO Lua 실행 안 함** — PASS.
    `spawn`, `exec`, `ScenEdit_*` 호출 없음.

61. **헬퍼가 폴링 또는 파일 와치 안 함** — PASS.
    `setInterval`, `watch`, `addEventListener` 없음.

62. **스모크가 중첩 raw 제거 검증** — PASS.
    스모크 54-68행: `assertNoRawOrLuaBody` 재귀 검사.

### 스모크 계약 (63-68)

63. **스모크가 redaction 검증** — PASS.
    스모크 112-116행: `redactCmoStateText` 직접 검증.

64. **스모크가 truncation 신호 검증** — PASS.
    스모크 90-95행: `eventsTruncated`, `specialActionsTruncated`.

65. **스모크가 UTF-16 char-unit 라벨링 검증** — PASS.
    스모크 96행, 101-102행: `luaPreviewCharUnit === 'utf16-code-units'`.

66. **스모크가 초과 크기 거부 검증** — PASS.
    스모크 126-129행.

67. **스모크가 빈 입력 거부 검증** — PASS.
    스모크 131-133행.

68. **스모크가 알 수 없는 입력이 throw되지 않음을 검증** — PASS.
    스모크 118-124행: 비CMO 텍스트 입력 시 `ok: true`, `eventCount: 0`, 경고 있음.

### 파이프라인 및 기준선 (69-80)

69. **`npm run smoke:cmo-state-snapshot` 통과** — PASS.

70. **`npm run lint` 통과** — PASS.

71. **`npm run build` 통과, watch line 준수** — PASS.
    Main JS 383.67 kB, Main CSS 59.14 kB, aiContextPruning 8.56 kB.

72. **`npm run smoke:ai-adapter` 통과, raw auth 누출 없음** — PASS.

73. **`npm run verify:release` 통과** — PASS.

74. **Main JS 400 kB 미만 유지** — PASS. 383.67 kB.

75. **Main CSS 60 kB 미만 유지** — PASS. 59.14 kB.

76. **`aiContextPruning` 9 kB 미만 유지** — PASS. 8.56 kB.

77. **`src/**` 변경 없음** — PASS.
    `git diff` 출력 없음.

78. **`server/ai-provider-adapter.mjs` 변경 없음** — PASS.
    `git diff` 출력 없음.

79. **`public/**` 변경 없음** — PASS.
    `git diff` 출력 없음.

80. **README / 릴리스 마커 / 태그 / GitHub Release 변경 없음** — PASS.
    `git diff` 출력 없음.

## 회귀 감시

- 헬퍼가 파서 `raw`, 전체 `luaScript`, 전체 `luaScripts`를 노출하는가? — 아니오. `assertNoRawOrLuaBody` 전체 통과.
- 헬퍼가 초과 크기 텍스트를 조용히 수용하는가? — 아니오. 명시적 throw.
- 헬퍼가 이벤트를 summary 신호 없이 자르는가? — 아니오. `eventsTruncated` 명시.
- 헬퍼가 파싱 전 XML-bracket redaction 토큰을 사용하는가? — 아니오. `REDACTED_USER_PATH` 등 안전한 토큰.
- 헬퍼가 어댑터 엔드포인트, UI, 폴링, 와처, CMO 실행, AI 자동 전송, 브라우저 root를 도입하는가? — 아니오.

## 최종 평결

```text
정적 체크포인트: 80 / 80 PASS
파이프라인: 전체 PASS
번들: Main JS 383.67 kB / Main CSS 59.14 kB / aiContextPruning 8.56 kB
드리프트: src/adapter/public/README/package-lock 변경 없음
회귀: 없음
평결: APPROVED
```

B4.1 state snapshot helper 슬라이스는 순수 서버 사이드 헬퍼이며 어댑터 라우트나 UI 컨트롤을 포함하지 않습니다. 파서 `raw` 필드와 전체 Lua 스크립트 본문을 제거하고 바운딩된 미리보기만 노출하며, 입력 크기와 이벤트/스페셜액션/경고 수를 모두 제한합니다. Redaction은 파싱 전에 수행되며 XML/Lua 구조물을 생성하지 않는 안전한 토큰을 사용합니다. Codex는 B4.2 어댑터 엔드포인트 슬라이스를 진행할 수 있습니다.
