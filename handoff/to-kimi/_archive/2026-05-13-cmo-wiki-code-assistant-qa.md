# Kimi QA 보고서 - CMO Wiki / Lua Reference Helper

날짜: 2026-05-13
대상:
- `4f70332 Add CMO wiki entry helper`
- `30801bc Share CMO wiki utility helpers`
- `32250e5 Add CMO Lua encyclopedia panel`
- `11d6bcf Add Lua editor reference helper`

## 범위

CMO Wiki / Lua 참조 도우미 구현 체인. 템플릿注釈 기반 wiki 항목 생성, 백과사전 패널, Lua 편집기 참조 도우미, AI 채팅창 초안 라우팅.

변경 파일:

```text
package.json                                      |  수정 (smoke 추가, verify:release 확장)
src/App.jsx                                       |  수정 (CmoWikiPanel lazy-load, draft 이벤트 라우팅)
src/components/AiInterpreterChatPanel.jsx         |  수정 (wiki draft 이벤트 수신)
src/components/CmoWikiPanel.css                   |  신규
src/components/CmoWikiPanel.jsx                   |  신규
src/components/LuaAssistant.jsx                   |  수정 (LuaEditorReferenceHelper lazy-load)
src/components/LuaEditorReferenceHelper.css       |  신규
src/components/LuaEditorReferenceHelper.jsx       |  신규
src/components/TemplateLibrary.jsx                |  수정 (cmoWikiEntries shared helper 사용)
src/lib/cmoWikiDataClient.js                      |  신규
src/lib/cmoWikiEntries.js                         |  신규
tools/verify-ai-chat-entrypoint-contract.mjs      |  수정
tools/verify-cmo-wiki-code-assistant-contract.mjs |  신규
```

미변경 영역 확인:

- `server/**`, `public/**`, `docs/**`, `package-lock.json` — 모두 변경 없음.
- `git diff --check` — whitespace 오류 없음.

## 파이프라인 결과

```text
git status --short --branch: main...origin/main [ahead 8]
npm run smoke:cmo-wiki-code-assistant: PASS
npm run smoke:ai-chat-entrypoint: PASS
npm run verify:release: PASS (17단계 확장 체인)
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
  15. smoke:cmo-wiki-code-assistant: PASS (신규)
  16. smoke:ai-client-parser: PASS
  17. smoke:ai-adapter: PASS — Bearer / sk-key 누출 없음
```

`verify:release`에 `smoke:cmo-wiki-code-assistant`가 `smoke:ai-client-parser` 이전에 추가됨을 확인.

## 번들 기준선

```text
Main JS: 253.81 kB (< 400 kB)
Main CSS: 59.45 kB (< 60 kB)
aiContextPruning: 8.56 kB (< 9 kB)
CmoWikiPanel lazy JS: 7.59 kB
CmoWikiPanel lazy CSS: 3.61 kB
LuaEditorReferenceHelper lazy JS: 2.12 kB
LuaEditorReferenceHelper CSS: 0.84 kB
LuaAssistant lazy JS: 136.86 kB
```

## 정적 체크포인트 결과

### Wiki 헬퍼 계약 (1-5)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 1 | `src/lib/cmoWikiEntries.js`가 존재하고 wiki 헬퍼 함수 export | PASS | 파일 존재, `buildCmoWikiEntries`, `formatWikiQuestionDraft`, `matchCmoWikiEntriesForLua`, `redactWikiDraftText`, `resourceSearchText`, `buildResourceBadges`, `matchesQuickFilter` 등 export |
| 2 | 헬퍼가 51 / 51 템플릿注釈에서 최소 51개 wiki 항목 생성 | PASS | `buildCmoWikiEntries` smoke: `entries.length >= 51` PASS, `annotationsPayload.templates` 길이 51 확인 |
| 3 | 헬퍼가 `event_regular_time.tpl.lua`를 제목, 요약, 필요 값, 안전 패턴, 검사, 배지, 검색 텍스트로 라운드트립 | PASS | smoke: `regularTime.title`, `summary.includes('반복 실행')`, `requiredValues.length > 0`, `safePattern.includes('KeyValue')`, `engineChecks.length > 0`, `searchText.includes('regular time event guide')` |
| 4 | 헬퍼 초안 포매터가 `Bearer`, `sk-`, 로컬 경로 형식 문자열을 리덕션 | PASS | `redactWikiDraftText` smoke: `redactWikiDraftText('Bearer abc.def sk-proj-example C:/Users/name/file.lua')`에서 원문 패턴 제거 확인 |
| 5 | 헬퍼 초안 포매터가 CMO 엔진 검증 문구 포함 및 bounded 유지 | PASS | `formatWikiQuestionDraft` smoke: `draft.includes('CMO 엔진 검증')`, `draft.length < 5000` |

### 공유 헬퍼 및 템플릿 라이브러리 (6-7)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 6 | `TemplateLibrary.jsx`가 `../lib/cmoWikiEntries`에서 공유 헬퍼 유틸리티 import | PASS | TemplateLibrary.jsx line 8: `from '../lib/cmoWikiEntries'` |
| 7 | `TemplateLibrary.jsx`가 더 이상 `annotationTextParts`, `normalizeSearchText`, `annotationText`, `buildResourceBadges`의 로컬 복사본을 가지지 않음 | PASS | grep 결과: 해당 함수 정의 패턴 0개, smoke negative assertion PASS |

### CMO Wiki 패널 (8-15)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 8 | `src/components/CmoWikiPanel.jsx`가 존재하고 `App.jsx`가 레이지 로드 | PASS | App.jsx line 13: `const CmoWikiPanel = lazy(() => import('./components/CmoWikiPanel'));` |
| 9 | Wiki 패널 제목이 `CMO Lua 백과사전` 포함 | PASS | CmoWikiPanel.jsx: 상태 텍스트 및 UI에 "CMO Lua 백과사전" |
| 10 | Wiki 패널에 `언제 쓰나요?`, `CMO에서 직접 확인할 값`, `참고용 템플릿 예제` 포함 | PASS | CmoWikiPanel.jsx: 해당 한글 레이블 모두 존재 (smoke assertion PASS) |
| 11 | Wiki 패널에 검색 및 결정적 빠른 필터 | PASS | CmoWikiPanel.jsx: `QUICK_FILTERS` 배열 (Event, Mission, Unit, DBID/Loadout, RP/Zone, Doctrine/EMCON, KeyValue), `query` 상태 및 `useDeferredValue` |
| 12 | Wiki 패널 텍스트 전용 버튼이 `AI 채팅창에 질문 초안 넣기` | PASS | CmoWikiPanel.jsx: 해당 버튼 레이블 존재 (smoke assertion PASS) |
| 13 | Wiki 패널이 초안이 자동 전송되지 않음을 명시 | PASS | CmoWikiPanel.jsx: `자동 전송되지 않습니다` 문구 존재 (smoke assertion PASS) |
| 14 | Wiki 패널이 사용자 정의 템플릿 생성이나 빌더 폼 삽입을 전면에 배치하지 않음 | PASS | smoke negative assertion: `/onAddTemplate|템플릿 추가|제작 폼에 추가/` 패턴 0개 |
| 15 | Wiki 패널이 AI 호출, CMO 파일 저장, 로그 가져오기, 상태 스냅샷 가져오기를 수행하지 않음 | PASS | smoke negative assertion: `/sendCmoAiPrompt|saveCmoLuaSidecar|fetchCmoLogFeedback|importCmoStateSnapshot/` 패턴 0개 |

### Lua Editor 참조 도우미 (16-24)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 16 | `src/components/LuaEditorReferenceHelper.jsx`가 존재 | PASS | 파일 존재 |
| 17 | Editor helper 레이블이 `Lua 참조 도우미` 사용, 두 번째 AI 에이전트 정체성 아님 | PASS | LuaEditorReferenceHelper.jsx line 42: "Lua 참조 도우미" (smoke assertion PASS) |
| 18 | Editor helper 빈 상태가 알려진 패턴을 찾을 수 없음을 표시 | PASS | LuaEditorReferenceHelper.jsx line 69: "알려진 패턴을 찾을 수 없습니다" (smoke assertion PASS) |
| 19 | Editor helper 텍스트 전용 버튼이 `AI 채팅창에 검토 질문 넣기` | PASS | LuaEditorReferenceHelper.jsx line 61: 해당 버튼 레이블 존재 (smoke assertion PASS) |
| 20 | Editor helper가 초안이 자동 전송되지 않음을 명시 | PASS | LuaEditorReferenceHelper.jsx line 77: "자동 전송되지 않습니다" 문구 존재 (smoke assertion PASS) |
| 21 | Editor helper 소스가 `sendCmoAiPrompt`, `fetch(`, `ScenEdit_RunScript`, `writeFile`, `appendFile`을 직접 호출하지 않음 | PASS | smoke negative assertion: 해당 패턴 0개 |
| 22 | Editor helper가 `LuaAssistant.jsx`에 의해 레이지 로드 | PASS | LuaAssistant.jsx line 47: `const LuaEditorReferenceHelper = lazy(() => import('./LuaEditorReferenceHelper'));` |
| 23 | Editor helper가 현재 Lua 텍스트를 `matchCmoWikiEntriesForLua`로 매칭 | PASS | LuaEditorReferenceHelper.jsx line 14: `matchCmoWikiEntriesForLua(luaText, wikiEntries, { limit: 4 })` |
| 24 | Editor helper 질문 초안이 `formatWikiQuestionDraft` 사용 | PASS | LuaEditorReferenceHelper.jsx line 35: `formatWikiQuestionDraft(entry, { luaText })` |

### AI 채팅 라우팅 및 데이터 클라이언트 (25-27)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 25 | `AiInterpreterChatPanel.jsx`가 wiki draft 이벤트를 텍스트 전용 입력으로 수신하고 자동 제출하지 않음 | PASS | AiInterpreterChatPanel.jsx line 159: `window.addEventListener('cmo-ai-chat-draft-request', handleDraftRequest)`, 수신 후 텍스트 영역에 삽입만 수행 |
| 26 | `App.jsx`가 wiki 질문 초안을 AI chat 모드로 라우트 | PASS | App.jsx line 671: `window.dispatchEvent(new CustomEvent('cmo-ai-chat-draft-request', ...))`, `draftWikiQuestionToChat` 함수 존재 |
| 27 | `src/lib/cmoWikiDataClient.js`가 wiki 패널과 editor helper를 위한 wiki 매니페스트 로딩을 중앙화 | PASS | 파일 존재, `loadCmoWikiEntries()`가 `template-annotations.json`, `manifest.json` 로드 및 `buildCmoWikiEntries` 호출, singleton promise 캐싱 |

### 미변경 및 안전 경계 (28-34)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 28 | `server/**` 변경 없음 | PASS | diff 출력 없음 |
| 29 | `public/**` 변경 없음 | PASS | diff 출력 없음 |
| 30 | `package-lock.json` 변경 없음 | PASS | diff 출력 없음 |
| 31 | 새 의존성/개발 의존성 없음 | PASS | package.json diff: script 항목 및 verify:release 체인 확장만 |
| 32 | CMO 파일시스템 쓰기, 폴, 와처, 실시간 상태 주장, 브라우저 제공 루트, 자동 CMO 실행 도입 안 됨 | PASS | server/** 변경 없음, 제품 소스에 해당 패턴 없음 |
| 33 | 기존 prompt-copy fallback 여전히 사용 가능 | PASS | "요청문 복사" 버튼 및 로직 변경 없음 |
| 34 | 기존 `isPasteReady` / `canApplyAiLua` 게이트 약화되지 않음 | PASS | LuaAssistant.jsx: `canApplyAiLua` 및 `isPasteReady` 사용 여전히 동일 |

### 스모크 및 번들 (35-38)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 35 | `npm run smoke:cmo-wiki-code-assistant` 통과 | PASS | "PASS - CMO wiki code assistant helper contract holds." |
| 36 | `npm run smoke:ai-chat-entrypoint` 통과 | PASS | "PASS - AI chat entrypoint contract holds." |
| 37 | `npm run verify:release` 통과 | PASS | 17단계 전체 PASS |
| 38 | 번들 감시 선이 green 유지 | PASS | Main JS 253.81 kB / Main CSS 59.45 kB / aiContextPruning 8.56 kB — 모두 한도 내 |

## 회귀 감시

- Main JS가 400 kB를 초과했는가? — 아니오. 253.81 kB.
- Main CSS가 60 kB를 초과했는가? — 아니오. 59.45 kB.
- 자문 프롬프트가 실시간 CMO 상태를 주장하는가? — 아니오. "Do not claim live CMO state" 유지.
- Wiki 패널이 AI를 자동으로 호출하는가? — 아니오. "자동 전송되지 않습니다" 명시.
- Lua 참조 도우미가 직접 AI를 호출하는가? — 아니오. `sendCmoAiPrompt` 패턴 없음.
- B2/B3/B4 스모크가 실패했는가? — 아니오. 모두 PASS.
- AI adapter 보안 계약이 깨졌는가? — 아니오. PASS.
- 템플릿 라이브러리가 로컬 헬퍼 복사본을 유지하는가? — 아니오. `cmoWikiEntries` 공유 헬퍼 사용.

## 최종 평결

```text
정적 체크포인트: 38 / 38 PASS
파이프라인: smoke:cmo-wiki-code-assistant PASS, smoke:ai-chat-entrypoint PASS, verify:release 17단계 전체 PASS
번들: Main JS 253.81 kB / Main CSS 59.45 kB / aiContextPruning 8.56 kB / CmoWikiPanel lazy 7.59 kB JS + 3.61 kB CSS / LuaEditorReferenceHelper lazy 2.12 kB JS + 0.84 kB CSS
드리프트: server/public/docs/package-lock 변경 없음
회귀: 없음
평결: APPROVED - CMO Wiki / Lua Reference Helper holds.
```

CMO Wiki / Lua Reference Helper 구현 체인은 템플릿注釈에서 결정적 wiki 항목을 생성하고, 백과사전 패널과 Lua 편집기 참조 도우미를 통해 사용자에게 CMO 관련 정보를 제공하며, 텍스트 전용 AI 채팅 초안을 라우트합니다. 모든 기능은 자동 AI 전송, CMO 파일 변이, 실시간 상태 주장 없이 안전하게 구현되었습니다. 공유 헬퍼를 통해 코드 중복을 제거하고 레이지 로드를 통해 번들 크기를 효율적으로 관리합니다.
