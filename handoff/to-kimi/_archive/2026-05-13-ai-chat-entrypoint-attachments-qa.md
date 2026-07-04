# Kimi QA 보고서 - AI Chat Entrypoint Attachments

날짜: 2026-05-13
대상: `ab8b94a Simplify AI chat entrypoint`

## 범위

AI 채팅 진입점 단순화. 신규 사용자를 위한 AI Chat 탭 추가, 첨부 파일 지원, simpleMode 도입.

변경 파일:

```text
package.json                                 |   1 +
src/App.jsx                                  |  20 +-
src/components/AiInterpreterChatPanel.css    |  82 ++++++++
src/components/AiInterpreterChatPanel.jsx    |  34 +--
src/components/LuaAssistant.jsx              | 299 +++++++++++++++++++++++++--
src/index.css                                |  14 +-
tools/verify-ai-chat-entrypoint-contract.mjs | 152 +++++++++++++
7 files changed, 563 insertions(+), 39 deletions(-)
```

미변경 영역 확인:

- `server/**`, `public/**`, `docs/**` — 모두 변경 없음.
- `package-lock.json` — 변경 없음.
- `handoff/**` — 현재 지시어와 `CURRENT_TASK.md` 외 변경 없음.

## 파이프라인 결과

```text
git status --short --branch: main...origin/main [ahead 5]
npm run smoke:ai-chat-entrypoint: PASS
npm run smoke:ai-interpreter-ui: PASS
npm run lint: PASS
npm run build: PASS
npm run verify:release: PASS (16단계 전체 확장 체인)
  1. audit:scenario-sidecars: 1899 인덱스 / 3799 보호 / 24 고아 / 5.6 MB
  2. verify:scenario-loader: 1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues
  3. lint: PASS
  4. build: PASS
  5. smoke:ai-workflow-state: PASS
  6. smoke:ai-follow-up-needs: PASS
  7. smoke:ai-confirmed-context: PASS
  8. smoke:ai-adapter-client-sidecar: PASS (B2)
  9. smoke:cmo-log-feedback: PASS (B3)
  10. smoke:cmo-log-feedback-endpoint: PASS (B3)
  11. smoke:ai-adapter-client-log-feedback: PASS (B3)
  12. smoke:cmo-state-snapshot: PASS (B4)
  13. smoke:cmo-state-snapshot-endpoint: PASS (B4)
  14. smoke:ai-adapter-client-state-snapshot: PASS (B4)
  15. smoke:ai-client-parser: PASS
  16. smoke:ai-adapter: PASS — Bearer / sk-key 누출 없음
```

## 번들 기준선

```text
Main JS: 398.55 kB (< 400 kB)  ← 400 kB 선에 매우 근접 (1.45 kB 여유)
Main CSS: 59.32 kB (< 60 kB)
aiContextPruning: 8.56 kB (< 9 kB)
AiInterpreterChatPanel lazy CSS: 8.26 kB
AiInterpreterChatPanel lazy JS: 10.76 kB
```

⚠️ **번들 감시:** Main JS가 398.55 kB로 400 kB 선에 매우 근접합니다. 이후 추가 기능에서는 Main JS가 400 kB를 초과하지 않도록 주의가 필요합니다.

## 정적 체크포인트 결과

### AI Chat 탭 구조 (1-7)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 1 | `AI Chat`이 최상위 워크스페이스 탭의 가장 왼쪽 | PASS | App.jsx: `WORKSPACE_TABS` 배열 첫 번째 요소가 `{ id: 'ai-chat', label: 'AI Chat' }` |
| 2 | 새 워크스페이스 기본값이 `activeTab: 'ai-chat'` | PASS | App.jsx: `getDefaultWorkspaceState`에서 `activeTab: 'ai-chat'` |
| 3 | `AI Chat`과 `Event/Lua Assistant`가 하나의 `LuaAssistant` 인스턴스 공유 | PASS | App.jsx: `hidden={activeTab !== 'assistant' && activeTab !== 'ai-chat'}`, `focusOutputPreviewTab={activeTab === 'ai-chat' ? 'chat' : ''}` |
| 4 | `AI Chat`이 전용 `renderSimpleAiChatPane` 렌더링 | PASS | LuaAssistant.jsx: `renderSimpleAiChatPane` 함수 존재, `simple-ai-chat-pane` 클래스 |
| 5 | `AI Chat`에서 전문가 툴 바 버튼(`.lua 열기`, 폴터 열기, `.scen/XML/JSON 읽기`, 저장) 숨김 | PASS | LuaAssistant.jsx: `!focusOutputPreviewTab && (` 조건으로 숨김 |
| 6 | `AI Chat`에서 전문가 파일 상태 스트립 / 임시 세션 액션 행 숨김 | PASS | LuaAssistant.jsx: `!focusOutputPreviewTab && (` 조건으로 숨김 |
| 7 | `Event/Lua Assistant` 탭이 이전 수동 편집기 워크플로우 여전히 노출 | PASS | App.jsx: `assistant` 탭은 `focusOutputPreviewTab=''`로 LuaAssistant 렌더링, 모든 컨트롤 표시 |

### 첨부 파일 컨트롤 (8-17)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 8 | Simple chat pane에 시나리오 첨부 컨트롤 포함 | PASS | LuaAssistant.jsx: `chatScenarioFileInputRef`, `시나리오 첨부` 버튼 |
| 9 | Simple chat pane에 Lua/배경 파일 첨부 컨트롤 포함 | PASS | LuaAssistant.jsx: `chatAttachmentInputRef`, `Lua/문서 첨부` 버튼 |
| 10 | Simple chat pane에 폴터 스캔 컨트롤 포함 | PASS | LuaAssistant.jsx: `chatAttachmentFolderInputRef`, `폴터 스캔` 버튼 |
| 11 | 지원 텍스트 첨부 타입: `.lua`, `.css`, `.html`, `.txt`, `.md`, `.json`, `.xml` | PASS | LuaAssistant.jsx: 상태 메시지에 명시적 나열 |
| 12 | 첨부 파일은 프롬프트 컨텍스트만, `source`나 `workingLua` 자동 덮어쓰기 안 함 | PASS | LuaAssistant.jsx: `preserveEditors: true`, "Do not overwrite the manual editor draft from attachments" 주석 |
| 13 | 시나리오 첨부 경로가 `preserveEditors: true` 사용 | PASS | LuaAssistant.jsx: `preserveEditors: true` 확인 |
| 14 | 시나리오 첨부가 `.scen`, `.xml`, `.json` / `.summary.json` 여전히 로드 | PASS | LuaAssistant.jsx: 시나리오 첨부 로직에 세 가지 타입 모두 처리 |
| 15 | `.scen` 브라우저 메타데이터 한도가 `1.25 MB`로 표시 | PASS | `SCENARIO_SCEN_METADATA_READ_LIMIT = 1_250_000`, UI에 `formatBytes`로 `1.25 MB` 표시 |
| 16 | XML/JSON sidecar/summary 한도가 `2,500,000`자로 표시 | PASS | `SCENARIO_XML_SIDECAR_CHAR_LIMIT = 2_500_000`, UI에 `toLocaleString()`로 표시 |
| 17 | Lua/CSS/HTML/text 첨부 한도가 파일당 `300 KB`, `40`개 파일, 총 `1.00 MB`로 표시 | PASS | `CHAT_ATTACHMENT_TEXT_READ_LIMIT = 300_000`, `CHAT_ATTACHMENT_MAX_FILES = 40`, `CHAT_ATTACHMENT_TOTAL_READ_LIMIT = 1_000_000`, UI에 `formatBytes`로 표시 |

### SimpleMode 및 UI 상태 (18-23)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 18 | `AiInterpreterChatPanel`이 `simpleMode` 지원 | PASS | AiInterpreterChatPanel.jsx: `simpleMode = false` prop 기본값 |
| 19 | `simpleMode` 제목이 `CMO AI Chat` | PASS | AiInterpreterChatPanel.jsx: `simpleMode ? 'CMO AI Chat' : 'AI Interpreter Chat'` |
| 20 | `simpleMode`가 고급 검토/적용 컨트롤 숨김 | PASS | AiInterpreterChatPanel.jsx: `!simpleMode && (` 조건으로 버튼 숨김 |
| 21 | `simpleMode`가 고급 상태 그리드 및 프롬프트 미리보기 패널 숨김 | PASS | AiInterpreterChatPanel.jsx: `hidden={simpleMode}` |
| 22 | 유휴 채팅 상태가 응답 대기 / AI 응답 없음 표시, Lua 누락 아님 | PASS | AiInterpreterChatPanel.jsx: `!hasAiResponse ? '응답 대기...'`, `hasAiResponse`로 AI 응답 존재 여부 구분 |
| 23 | 기존 `smoke:ai-interpreter-ui` 회귀 계약이 여전히 PASS | PASS | `npm run smoke:ai-interpreter-ui` PASS |

### 안전 경계 (24-30)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 24 | 기존 B2/B3/B4 계약이 `verify:release`에서 여전히 PASS | PASS | 16단계 전체 PASS |
| 25 | 새 백엔드 엔드포인트, 폴, 와처, CMO 자동 실행, 실시간 리드백 도입 안 됨 | PASS | `server/**` 변경 없음 |
| 26 | `LuaAssistant.jsx`에 브라우저 제공 루트 경로 필드(`cmoRoot`, `logsRoot`, `scenarioRoot`, `luaRoot`, `filePath`, `scriptPath`) 없음 | PASS | grep 결과: 해당 패턴 0개 |
| 27 | raw credential 영속화 또는 새 `apiKey` / `Authorization` / `Bearer` / `sk-` UI 표면 도입 안 됨 | PASS | diff에 해당 패턴 없음, adapter 보안 계약 PASS |
| 28 | `package-lock.json` 변경 없음 | PASS | diff 출력 없음 |
| 29 | `server/**`, `public/**`, `docs/**` 제품 커밋에서 변경 없음 | PASS | `git diff --name-only` 출력 없음 |
| 30 | `verify:release`가 raw Bearer / Authorization / sk-key 누출 없음 보고 | PASS | adapter smoke: "no Bearer / sk-key fingerprint" |

## 회귀 감시

- Main JS가 400 kB를 초과했는가? — 아니오. 398.55 kB로 400 kB 선에 근접하지만 미만.
- Main CSS가 60 kB를 초과했는가? — 아니오. 59.32 kB.
- `Event/Lua Assistant` 수동 편집기 워크플로우가 제거되었는가? — 아니오. `assistant` 탭은 그대로 유지.
- 첨부 파일이 CMO 파일이나 `.scen` 파일을 변이시켰는가? — 아니오. 브라우저 내 읽기 전용, `preserveEditors: true`.
- 첨부 파일이 사용자가 `AI에게 보내기` 누르지 않고 AI로 자동 전송되었는가? — 아니오. 첨부는 프롬프트 컨텍스트만, 명시적 AI 호출 필요.
- 폴터 스캔이 로컬 브라우저 파일 선택만 사용했는가? — 아니오. `<input type="file" webkitdirectory>` 사용, 파일시스템 폴/와처 아님.
- B2/B3/B4 스모크가 실패했는가? — 아니오. 모두 PASS.
- AI 인터프리터 UI 회귀 계약이 깨졌는가? — 아니오. PASS.

## 브라우저 스모크 (선택 사항, 미실행)

Playwright 접근성 스냅샷으로 관찰된 항목 (Codex 제공):

- 최상위 내비게이션 왼쪽 첫 번째 탭: `AI Chat 대화형 Lua 생성`.
- AI Chat 패널에만 포함: `시나리오 첨부`, `Lua/문서 첨부`, `폴터 스캔`, 채팅 텍스트 영역, `AI에게 보내기`, `새 지시로 초기화`, `요청문 복사`, 최신 응답 미리보기, 세션 채팅 기록.
- 전문가 출력/적용/상태 패널이 AI Chat 진입점에 표시되지 않음.

수동 브라우저 클릭 테스트는 선택 사항이며, 정적 검증 + 필수 파이프라인으로 충분합니다.

## 최종 평결

```text
정적 체크포인트: 30 / 30 PASS
파이프라인: smoke:ai-chat-entrypoint PASS, smoke:ai-interpreter-ui PASS, lint PASS, build PASS, verify:release 16단계 전체 PASS
번들: Main JS 398.55 kB / Main CSS 59.32 kB / aiContextPruning 8.56 kB
드리프트: server/public/docs/handoff/package-lock 변경 없음
회귀: 없음
평결: APPROVED - AI chat entrypoint attachments hold.
```

AI 채팅 진입점은 신규 사용자를 위한 `AI Chat` 탭을 최좌측에 배치하고, 시나리오/Lua/폴터 첨부 파일을 지원하며, `simpleMode`로 고급 컨트롤을 숨기고, 기존 `Event/Lua Assistant` 수동 워크플로우를 완전히 보존합니다. 첨부 파일은 프롬프트 컨텍스트만 제공하며 자동 AI 전송이나 CMO 파일 변이를 유발하지 않습니다. 모든 B2/B3/B4 계약과 기존 UI 회귀 계약이 유지되었습니다.
