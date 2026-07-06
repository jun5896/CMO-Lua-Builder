# Kimi QA 보고서 - AI Advisory Policy + Lazy Workspace

날짜: 2026-05-13
대상:
- `bc922a6 Add AI advisory chat policy contract`
- `8d99a71 Wire advisory policy into AI prompt`
- `7ab75f3 Split advisory guidance helper`
- `53ef0f4 Lazy load Lua assistant workspace`

## 범위

AI 자문 채팅 정책 계약 추가, 프롬프트 배선, 헬퍼 분리, LuaAssistant 레이지 로드.

변경 파일:

```text
package.json                                 |   1 +
src/App.jsx                                  |   5 +-
src/components/LuaAssistant.jsx              |  20 +++-
src/lib/aiAdvisoryChatPolicy.js              |  41 +++++++
src/lib/aiAdvisoryGuidance.js                |  20 +++
tools/verify-ai-advisory-chat-policy.mjs     |  37 +++++++
tools/verify-ai-chat-entrypoint-contract.mjs |   6 +-
7 files changed, 127 insertions(+), 3 deletions(-)
```

미변경 영역 확인:

- `server/**`, `public/**`, `docs/**`, `src/index.css`, `package-lock.json` — 모두 변경 없음.
- `handoff/**` — 현재 지시어와 `CURRENT_TASK.md` 외 변경 없음.

## 파이프라인 결과

```text
git status --short --branch: main...origin/main [ahead 13]
npm run smoke:ai-advisory-chat-policy: PASS
npm run smoke:ai-chat-entrypoint: PASS
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
Main JS: 253.55 kB (< 400 kB)         ← 이전 398.55 kB에서 대폭 감소 (145 kB↓)
LuaAssistant lazy chunk: 135.22 kB    ← 신규 레이지 청크
Main CSS: 59.32 kB (< 60 kB)
aiContextPruning: 8.56 kB (< 9 kB)
```

Main JS가 398.55 kB에서 253.55 kB로 감소하여 400 kB 선에서 크게 벗어났습니다. LuaAssistant가 레이지 로드로 분리되면서 메인 번들이 가벼워졌습니다.

## 정적 체크포인트 결과

### package.json 및 의존성 (1-2)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 1 | `package.json`에 `smoke:ai-advisory-chat-policy` 포함 | PASS | diff 확인 |
| 2 | `package-lock.json` 변경 없음 | PASS | diff 출력 없음 |

### AI 자문 정책 계약 (3-10)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 3 | `aiAdvisoryChatPolicy.js`가 `classifyAdvisoryTopic`, `formatOffTopicRedirect` export 및 `buildAdvisorySystemGuidance` re-export | PASS | 파일 내용 확인 |
| 4 | `aiAdvisoryGuidance.js`가 `buildAdvisorySystemGuidance` export | PASS | 파일 내용 확인 |
| 5 | 자문 가이드가 AI를 CMO 미션 스크립팅 어드바이저로, 원샷 코드 생성기가 아님 명시 | PASS | `aiAdvisoryGuidance.js`: "You are a CMO mission scripting advisor, not a one-shot code generator." |
| 6 | 자문 가이드가 광범위한 요청에 Lua 생성 전 하나의 집중 후속 질문을 하라고 명시 | PASS | `aiAdvisoryGuidance.js`: "For broad requests, ask one focused follow-up question before producing Lua." |
| 7 | 자문 가이드가 실시간 CMO 상태를 주장하지 말라고 명시 | PASS | `aiAdvisoryGuidance.js`: "Do not claim live CMO state." |
| 8 | 자문 가이드가 CMO 엔진 검증이 필요함 명시 | PASS | `aiAdvisoryGuidance.js`: "CMO engine verification is required." |
| 9 | 주제 외 리다이렉트가 CMO/시나리오 용어를 포함하고 적대적 하드 실패 문구 사용 안 함 | PASS | `formatOffTopicRedirect`: "이 도구는 CMO 미션/시나리오 Lua 작업에 맞춰져 있어요." — "꺼져|불가|지원하지 않" 패턴 없음 (smoke 계약 확인) |
| 10 | `verify-ai-advisory-chat-policy.mjs`가 헬퍼 및 프롬프트 배선 검사 | PASS | 파일 내용: `buildAdvisorySystemGuidance`, `classifyAdvisoryTopic`, `formatOffTopicRedirect` 검사 + LuaAssistant.jsx import/assertion |

### LuaAssistant 프롬프트 배선 (11-14)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 11 | `LuaAssistant.jsx`가 `aiAdvisoryGuidance`에서 가이드를 import | PASS | LuaAssistant.jsx line 40: `import { buildAdvisorySystemGuidance } from '../lib/aiAdvisoryGuidance';` |
| 12 | `buildAssistantPrompt()`에 `## Advisory Chat Mode` 포함 | PASS | LuaAssistant.jsx line 2307: `'## Advisory Chat Mode',` |
| 13 | `buildAssistantPrompt()`가 `confirmedContext.length` 전달 | PASS | LuaAssistant.jsx line 2300: `confirmedContextCount: confirmedContext.length,` |
| 14 | `buildAssistantPrompt()`가 `hasImportedStateSnapshot: Boolean(cmoStateSnapshot.snapshot)` 전달 | PASS | LuaAssistant.jsx line 2532: `hasImportedStateSnapshot: Boolean(cmoStateSnapshot.snapshot),` |

### 안전 경계 보존 (15-16)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 15 | 기존 `isPasteReady` / `canApplyAiLua` 게이트가 약화되지 않음 | PASS | LuaAssistant.jsx: `canApplyAiLua` 및 `isPasteReady` 사용 여전히 동일, 10개 이상 참조 확인 |
| 16 | 기존 prompt-copy / request-copy fallback 여전히 사용 가능 | PASS | "요청문 복사" 버튼 및 복사 로직 변경 없음 |

### 레이지 로드 (17-20)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 17 | `App.jsx`가 `lazy(() => import('./components/LuaAssistant'))`로 LuaAssistant 레이지 로드 | PASS | App.jsx line 12: `const LuaAssistant = lazy(() => import('./components/LuaAssistant'));` |
| 18 | `App.jsx`가 더 이상 LuaAssistant를 정적으로 import하지 않음 | PASS | App.jsx에 `import LuaAssistant from` 없음, grep 결과 없음 |
| 19 | `App.jsx`가 `LuaAssistant`를 `Suspense`로 감쌈 | PASS | App.jsx line 824: `<Suspense fallback={...}><LuaAssistant ... /></Suspense>` |
| 20 | `verify-ai-chat-entrypoint-contract.mjs`가 레이지 로드 계약 assertion | PASS | tools/verify-ai-chat-entrypoint-contract.mjs line 46: `const LuaAssistant = lazy\(\(\) => import\('\./components/LuaAssistant'\)\)` 및 line 51: `import LuaAssistant from` negative assertion |

### 번들 및 미변경 (21-30)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 21 | Build 출력이 Main JS 400 kB 미만 | PASS | 253.55 kB |
| 22 | Build 출력이 Main CSS 60 kB 미만 | PASS | 59.32 kB |
| 23 | Build 출력이 `aiContextPruning` 9 kB 미만 | PASS | 8.56 kB |
| 24 | Build 출력이 별도 `LuaAssistant-*.js` 레이지 청크 포함 | PASS | `LuaAssistant-nMJE8GaM.js 135.22 kB` |
| 25 | `server/**` 변경 없음 | PASS | diff 출력 없음 |
| 26 | `public/**` 변경 없음 | PASS | diff 출력 없음 |
| 27 | 새 의존성/개발 의존성 없음 | PASS | package.json diff는 script 항목 1줄 추가만 |
| 28 | 새 백엔드 엔드포인트, CMO 폴, 와처, 파일 쓰기/삭제, 실시간 리드백 주장 없음 | PASS | server/** 변경 없음, 제품 소스에 해당 패턴 없음 |
| 29 | `npm run verify:release` 여전히 PASS | PASS | 16단계 전체 PASS |
| 30 | AI adapter smoke가 raw Bearer / Authorization / sk- 누출 없음 보고 | PASS | adapter smoke: "no Bearer / sk-key fingerprint" |

## 회귀 감시

- Main JS가 400 kB를 초과했는가? — 아니오. 253.55 kB로 대폭 감소.
- Main CSS가 60 kB를 초과했는가? — 아니오. 59.32 kB.
- 자문 프롬프트가 실시간 CMO 상태를 주장하는가? — 아니오. "Do not claim live CMO state" 명시.
- 레이지 로드가 AI Chat 진입점을 제거했는가? — 아니오. `ai-chat-entrypoint` smoke PASS.
- `isPasteReady` 게이트가 약화되었는가? — 아니오. 동일한 검증 로직 유지.
- B2/B3/B4 스모크가 실패했는가? — 아니오. 모두 PASS.
- AI adapter 보안 계약이 깨졌는가? — 아니오. PASS.
- 주제 외 리다이렉트가 적대적인가? — 아니오. "이 도구는 CMO 미션/시나리오 Lua 작업에 맞춰져 있어요"로 부드럽게 안내.

## 최종 평결

```text
정적 체크포인트: 30 / 30 PASS
파이프라인: smoke:ai-advisory-chat-policy PASS, smoke:ai-chat-entrypoint PASS, lint PASS, build PASS, verify:release 16단계 전체 PASS
번들: Main JS 253.55 kB / LuaAssistant lazy 135.22 kB / Main CSS 59.32 kB / aiContextPruning 8.56 kB
드리프트: server/public/docs/index.css/package-lock 변경 없음
회귀: 없음
평결: APPROVED - AI advisory policy + lazy workspace hold.
```

AI 자문 정책은 CMO 미션 스크립팅 어드바이저로서의 역할, 광범위 요청에 대한 집중 후속 질문, 실시간 CMO 상태 비주장, CMO 엔진 검증 필요성을 명확히 지시합니다. 주제 외 리다이렉트는 부드럽고 CMO 관련 용어를 사용합니다. LuaAssistant의 레이지 로드로 Main JS가 398.55 kB에서 253.55 kB로 대폭 감소하여 번들 크기 문제를 해결했습니다. 모든 기존 안전 경계와 B2/B3/B4 기능이 보존되었습니다.
