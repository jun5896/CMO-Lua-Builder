# Kimi QA 보고서 - AI Interpreter UI Regression

날짜: 2026-05-12
대상: `83df882 Fix AI interpreter UI regression states`

## 범위

AI 인터프리터 UI 회귀 수정. 데스크톱 레이아웃 붕괴, AI Adapter API key 설명, 최신 AI 응답 미리보기 가시성 수정.

변경 파일:

```text
package.json                                       |  1 +
src/components/AiAdapterSettings.jsx               |  5 +++
src/components/AiInterpreterChatPanel.css          | 15 +++++++++++
src/components/AiInterpreterChatPanel.jsx          | 11 ++++++--
src/index.css                                      | 10 +++----
tools/verify-ai-interpreter-ui-regression-contract.mjs | 59 ++++++++++++++++++++++
6 files changed, 94 insertions(+), 7 deletions(-)
```

미변경 영역 확인:

- `server/**`, `public/**`, `docs/**`, `package-lock.json` — 모두 변경 없음.
- `handoff/**`는 현재 지시어와 `CURRENT_TASK.md` 외 변경 없음.
- `git diff --check` — whitespace 오류 없음.

## 파이프라인 결과

```text
git status --short --branch: main...origin/main [ahead 2]
npm run smoke:ai-interpreter-ui: PASS
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
Main JS: 391.65 kB (< 400 kB)
Main CSS: 59.13 kB (< 60 kB)  ← 이전 59.14 kB에서 소폭 감소
aiContextPruning: 8.56 kB (< 9 kB)
AiInterpreterChatPanel CSS: 7.00 kB (신규/갱신)
```

## 정적 체크포인트 결과

### 파일 및 의존성 (1-4)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 1 | 타겟 커밋이 예상 UI 및 스모크 계약 파일만 변경 | PASS | 6 files: package.json, src/index.css, AiAdapterSettings.jsx, AiInterpreterChatPanel.jsx/css, tools/verify-ai-interpreter-ui-regression-contract.mjs |
| 2 | `package.json`에 `smoke:ai-interpreter-ui` 추가 | PASS | diff 확인 |
| 3 | `package-lock.json` 변경 없음 | PASS | diff 출력 없음 |
| 4 | 새 의존성/개발 의존성 추가 없음 | PASS | package.json diff는 script 항목 1줄 추가만 |

### 데스크톱 레이아웃 붕괴 수정 (5-7)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 5 | 데스크톱 레이아웃 붕괴 브레이크포인트가 1280px 아님, 1120px 이하 | PASS | src/index.css: `@media (max-width: 1120px)` |
| 6 | `.ai-readiness-panel`이 `grid-template-columns: minmax(0, 1fr) auto auto` 사용 안 함 | PASS | src/index.css: `grid-template-columns: minmax(0, 1fr)`로 변경 |
| 7 | AI Adapter readiness 텍스트가 near-zero 첫 번째 열에 강제 배치되지 않음 | PASS | grid가 단일 열로 변경, `align-items: stretch`, meta/controls `justify-content: flex-start`로 변경 |

### AI Adapter 설정 보안 (8-10)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 8 | 설정 AI Adapter API key 필드가 브라우저 저장소에 raw key 영속화 안 함 | PASS | normalizeSettings() 변경 없음, 기존 동작 유지 |
| 9 | 설정 UI가 API key 입력칸이 보안상 비워지고 adapter 메모리에만 유지됨 설명 | PASS | AiAdapterSettings.jsx: "API key 입력칸은 보안상 비웁니다. 적용된 key는 adapter 메모리에만 유지되며 브라우저 저장소에는 저장하지 않습니다." |
| 10 | `normalizeSettings()` 동작 unchanged: raw `apiKey`가 UI로 노출 안 됨 | PASS | AiAdapterSettings.jsx diff에서 normalizeSettings 관련 변경 없음 |

### AI 채팅 패널 미리보기 (11-15)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 11 | AI 채팅 패널에 보이는 최신 응답 미리보기 표시 | PASS | AiInterpreterChatPanel.jsx: `responsePreviewText` 추가, `ai-chat-response-preview` pre 태그 렌더링 |
| 12 | 긴 AI 응답 미리보기가 렌더링 전에 bounded | PASS | 1200자 slice 제한 + CSS `max-height: 18rem; overflow: auto` |
| 13 | AI 채팅 패널이 전체 구조화 검토를 위해 `AI 응답` 탭으로 안내 | PASS | "AI 응답 탭에서 전체 구조화 검토"로 변경, "구조화 검토는 AI 응답 탭에서 확인할 수 있습니다" 유지 |
| 14 | 주 `AI 호출`이 기본적으로 AI 응답 탭으로 라우트 | PASS | LuaAssistant.jsx smoke 계약: `nextPreviewTab = 'ai'` 기본값 확인 |
| 15 | AI 채팅 재시도 호출이 채팅 패널에 머물되 최신 응답 미리보기 표시 | PASS | 재시도 동작 변경 없음, 미리보기 추가만 |

### 안전 경계 보존 (16-21)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 16 | Prompt-copy fallback 유지 | PASS | 변경 없음 |
| 17 | `aiParsedResponse.isPasteReady`가 유일한 Lua 적용 게이트 유지 | PASS | 변경 없음 |
| 18 | `sendCmoAiPrompt` 자동 send 동작 도입 안 됨 | PASS | 변경 없음 |
| 19 | B2/B3/B4 백엔드 엔드포인트 동작 변경 없음 | PASS | server/** 변경 없음 |
| 20 | CMO 파일시스템 쓰기, 폴, 와처, 실시간 리드백 동작 도입 안 됨 | PASS | 변경 없음 |
| 21 | 변경된 UI 표면에 raw credential 문자열(Bearer, Authorization, sk-) 도입 안 됨 | PASS | diff 검사 시 해당 패턴 없음 |

### 파이프라인 및 번들 (22-26)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 22 | `npm run smoke:ai-interpreter-ui` 통과 | PASS | "PASS - AI interpreter UI regression contract holds." |
| 23 | `npm run verify:release` 통과 | PASS | 16단계 전체 PASS |
| 24 | Main JS 400 kB 미만 | PASS | 391.65 kB |
| 25 | Main CSS 60 kB 미만 | PASS | 59.13 kB |
| 26 | `aiContextPruning` 9 kB 미만 | PASS | 8.56 kB |

## 스모크 계약 세부 검증

`tools/verify-ai-interpreter-ui-regression-contract.mjs`가 검증한 추가 항목:

1. 반응형 브레이크포인트 미디어 쿼리 존재 및 `<= 1120px` — PASS.
2. `.ai-readiness-panel`이 `minmax(0, 1fr) auto auto`를 사용하지 않음 — PASS.
3. 설정 UI에 "API key 입력칸은 보안상 비웁니다" 문구 존재 — PASS.
4. 설정 UI에 "adapter 메모리" 문구 존재 — PASS.
5. AI 채팅 패널에 `ai-chat-response-preview` 클래스 존재 — PASS.
6. AI 채팅 패널에 "최근 AI 응답 미리보기" 레이블 존재 — PASS.
7. AI 채팅 패널에 "AI 응답 탭에서 전체 구조화 검토" 안내 존재 — PASS.
8. 주 AI 호출이 기본적으로 AI 응답 탭(`nextPreviewTab = 'ai'`)으로 라우트 — PASS (LuaAssistant.jsx).
9. AI 호출이 응답 도착 전에 대상 프리뷰 탭으로 전환 — PASS (LuaAssistant.jsx: `setOutputPreviewTab(nextPreviewTab)`).

## 회귀 감시

- Main CSS가 60 kB 선을 넘었는가? — 아니오. 59.13 kB로 유지.
- AiInterpreterChatPanel CSS가 Main CSS에 병합되어 크기가 급증했는가? — 아니오. 별도 lazy chunk(7.00 kB)로 유지.
- index.css 변경이 다른 컴포넌트 레이아웃을 망가뜨렸는가? — 아니오. `.ai-readiness-panel` 및 `@media` 브레이크포인트만 수정.
- API key 보안 설명이 기존 동작을 변경했는가? — 아니오. 순수 UI 텍스트 추가만.
- AI 응답 미리보기가 AI 응답 탭의 기능을 대체했는가? — 아니오. "전체 구조화 검토"는 여전히 AI 응답 탭으로 안내.
- B2/B3/B4 스모크가 실패했는가? — 아니오. 모두 PASS.

## 최종 평결

```text
정적 체크포인트: 26 / 26 PASS
파이프라인: smoke:ai-interpreter-ui PASS, verify:release 16단계 전체 PASS
번들: Main JS 391.65 kB / Main CSS 59.13 kB / aiContextPruning 8.56 kB
드리프트: src/server/tools/public/docs/handoff/package-lock 변경 없음 (예상 범위 내)
회귀: 없음
평결: APPROVED
```

AI 인터프리터 UI 회귀 수정은 데스크톱 레이아웃 브레이크포인트를 1120px로 낮추어 1280px에서의 붕괴를 해결하고, AI Adapter 준비도 카드의 텍스트 가독성을 개선하며, API key 보안 설명을 추가하고, AI 채팅 패널에 최신 응답 미리보기를 추가합니다. 모든 기존 안전 경계와 B2/B3/B4 기능이 보존되었습니다.
