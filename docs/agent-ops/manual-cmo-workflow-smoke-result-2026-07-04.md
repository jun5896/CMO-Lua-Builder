# Manual CMO Workflow Smoke - RESULT - 2026-07-04

Status: **PASS** (user-run evidence below)

2026-05-12 런북(`b4-manual-cmo-workflow-smoke-2026-05-12.md`)이 요구하던 실기 E2E 검증을
새 PC(D:\works\CMO-Lua-Builder) + AI 브리지 CLI 경로로 완료. 기존 B2/B3에 더해 신규
inbox 폴러 자동 실행까지 검증됨.

## 환경

- CMO: Bv1.10 Beta - Build 1892, DB3K/CWDB 517
- CMO root: D:\SteamLibrary\steamapps\common\Command - Modern Operations (locator 자동 감지)
- 브리지: tools/cmo-ai-bridge.mjs (커밋 979a684)

## 증거

### B2 - apply → 인게임 RunScript (수동 로더)

```text
>> ScenEdit_RunScript('/AiAssist/AiAssist_20260704_175309_e2e-marker.lua')
AiAssist_E2E_20260704 marker OK
```

### B3 - 로그 피드백 (브리지 → LuaHistory 회수)

`npm run bridge -- logs --kind lua-history`가 위 콘솔 실행 라인과 마커 출력을
그대로 반환함 (LuaHistory_2026-07-04.txt, 리댁션 정상 동작).

### 신규 - inbox 폴러 자동 실행

```text
>> ScenEdit_RunScript('/AiAssist/AiAssist_20260704_175309_install-poller.lua')
AiAssist inbox poller installed. Inbox: /AiAssist/AiAssist_inbox.lua
>> print(ScenEdit_GetKeyValue('aiassist_inbox_result'))
ok 20260704_180347_9e1c2991
```

- 폴러 이벤트(RegularTime interval=0) 설치 성공, 시나리오 시계 진행 후 inbox 페이로드
  자동 실행 확인 (KeyValue 가드 스탬프 일치).
- 확정: Build 1892에서도 콘솔 샌드박스에 dofile 없음 / Lua-root RunScript 경로 유효
  (B0.1 결론이 1868 → 1892까지 연장 검증됨).

## 결론

- B2 저장 → 인게임 실행 → B3 로그 회수 → (신규) 폴러 자동 실행 루프 전부 PASS.
- 잔여 항목: B4 상태 스냅샷 임포트는 UI 경로 그대로이며 이번 스모크 범위에서 제외
  (브리지에는 해당 서브커맨드 없음 — 필요 시 `Tool_DumpEvents()` 출력 수동 전달로 대체).
