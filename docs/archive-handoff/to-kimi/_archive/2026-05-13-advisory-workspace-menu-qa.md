# Kimi QA 보고서 - Advisory Workspace Menu

날짜: 2026-05-13
대상: `292bdef Rework advisory workspace menu`

## 범위

AI 자문 워크스페이스 메뉴 재구성. 4개 탭을 3개 주요 영역으로 단순화.

변경 파일:

```text
src/App.jsx                                  | 95 +++++++++++++++----------
src/index.css                                | 19 +++++-
tools/verify-ai-chat-entrypoint-contract.mjs | 53 ++++++++++++----
3 files changed, 116 insertions(+), 51 deletions(-)
```

미변경 영역 확인:

- `server/**`, `public/**`, `docs/**`, `package.json`, `package-lock.json` — 모두 변경 없음.
- `handoff/**` — 현재 지시어와 `CURRENT_TASK.md` 외 변경 없음.
- `git diff --check` — whitespace 오류 없음.

## 파이프라인 결과

```text
git status --short --branch: main...origin/main [ahead 16]
npm run smoke:ai-chat-entrypoint: PASS
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
Main JS: 254.00 kB (< 400 kB)
Main CSS: 59.45 kB (< 60 kB)
aiContextPruning: 8.56 kB (< 9 kB)
LuaAssistant lazy chunk: 135.22 kB
```

## 정적 체크포인트 결과

### 메뉴 구조 (1-7)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 1 | 최상위 메뉴가 정확히 3개 주요 영역 | PASS | WORKSPACE_TABS 배열 길이 3: agent, encyclopedia, settings |
| 2 | 가장 왼쪽 최상위 메뉴가 `Lua 편집 에이전트` | PASS | App.jsx: `{ id: 'agent', label: 'Lua 편집 에이전트' }`가 첫 번째 |
| 3 | 두 번째 최상위 메뉴가 `백과사전` | PASS | App.jsx: `{ id: 'encyclopedia', label: '백과사전' }`가 두 번째 |
| 4 | 세 번째 최상위 메뉴가 `설정` | PASS | App.jsx: `{ id: 'settings', label: '설정' }`가 세 번째 |
| 5 | `Lua 편집 에이전트`가 정확히 2개 하위 모드 노출 | PASS | AGENT_MODE_TABS 배열 길이 2: chat, editor |
| 6 | 첫 번째 하위 모드가 `AI 에이전트 대화` | PASS | App.jsx: `{ id: 'chat', label: 'AI 에이전트 대화' }` |
| 7 | 두 번째 하위 모드가 `Lua 편집기` | PASS | App.jsx: `{ id: 'editor', label: 'Lua 편집기' }` |

### 기본값 및 마이그레이션 (8-12)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 8 | 새 워크스페이스 기본값이 `activeTab: 'agent'` | PASS | App.jsx: `getDefaultWorkspaceState`에서 `activeTab: 'agent'` |
| 9 | 새 워크스페이스 기본값이 `agentMode: 'chat'` | PASS | App.jsx: `getDefaultWorkspaceState`에서 `agentMode: 'chat'` |
| 10 | 레거시 `ai-chat` 탭 상태가 `agent`로 마이그레이션 | PASS | App.jsx: `legacyTabMap: { 'ai-chat': 'agent' }` |
| 11 | 레거시 `assistant` / `output` 상태가 `agent` editor 모드로 마이그레이션 | PASS | App.jsx: `legacyAgentMode = savedState.activeTab === 'assistant' || savedState.activeTab === 'output' ? 'editor' : 'chat'` |
| 12 | 레거시 guide/builder/reference 상태가 `encyclopedia`로 마이그레이션 | PASS | App.jsx: `legacyTabMap: { builder: 'encyclopedia', reference: 'encyclopedia', guide: 'encyclopedia' }` |

### 모드 동작 (13-18)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 13 | AI chat 모드가 `focusOutputPreviewTab`을 통해 simple chat 진입점에 포커스 | PASS | App.jsx: `focusOutputPreviewTab={agentMode === 'chat' ? 'chat' : ''}` |
| 14 | Lua editor 모드가 전체 수동 Lua assistant 워크플로우 유지 | PASS | App.jsx: `agentMode === 'editor'`일 때 전체 LuaAssistant 렌더링, 모든 컨트롤 노출 |
| 15 | `requestLuaInsert()`가 `agent` + `editor` 모드로 전환 | PASS | App.jsx: `requestLuaInsert`에서 `setActiveTab('agent'); setAgentMode('editor');` |
| 16 | 사이드바 insert palette가 `agentMode === 'editor'`일 때만 나타남 | PASS | App.jsx: `SidePane`에서 `{agentMode === 'editor' && (<AssistantInsertPalette ... />)}` |
| 17 | 백과사전 뷰가 guide/checklist 컨텍스트 유지, 새 템플릿 생성 경로 전면 배치 안 함 | PASS | App.jsx: `SidePane` encyclopedia 분기에서 `PresetSettings` 및 기존 가이드 컴포넌트 유지 |
| 18 | 설정 뷰가 여전히 사용 가능하고 기존 settings workspace 사용 | PASS | App.jsx: `activeTab === 'settings'` 분기에서 기존 설정 UI 그대로 렌더링 |

### CSS 및 스타일 (19-20)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 19 | 상단 낵 CSS가 3열 레이아웃 사용 | PASS | index.css: `grid-template-columns: repeat(3, minmax(0, 1fr))` (2곳) |
| 20 | 주요 에이전트 탭이 별도 시각적 스타일링 | PASS | index.css: `.workspace-tab.primary-agent-tab`, App.jsx: `tab.id === 'agent' ? 'primary-agent-tab'` |

### 안전 경계 (21-24)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 21 | 새 서버 라우트, 백엔드 엔드포인트, 폴, 와처, 실시간 리드백 도입 안 됨 | PASS | `server/**` 변경 없음 |
| 22 | 패키지 의존성이나 락파일 드리프트 없음 | PASS | `package.json`, `package-lock.json` 변경 없음 |
| 23 | 기존 prompt-copy fallback 여전히 사용 가능 | PASS | "요청문 복사" 버튼 및 로직 변경 없음 |
| 24 | 기존 `isPasteReady` / `canApplyAiLua` 게이트 약화되지 않음 | PASS | LuaAssistant.jsx: `canApplyAiLua` 및 `isPasteReady` 사용 여전히 동일 |

### 스모크 및 번들 (25-30)

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 25 | `smoke:ai-chat-entrypoint`가 새 메뉴 레이블 및 기본값 커버 | PASS | verify-ai-chat-entrypoint-contract.mjs: `WORKSPACE_TABS`가 `agent`, `encyclopedia`, `settings`로 업데이트됨 |
| 26 | `verify:release` 여전히 PASS | PASS | 16단계 전체 PASS |
| 27 | Main JS 400 kB 미만 | PASS | 254.00 kB |
| 28 | Main CSS 60 kB 미만 | PASS | 59.45 kB |
| 29 | `aiContextPruning` 9 kB 미만 | PASS | 8.56 kB |
| 30 | AI adapter smoke가 raw Bearer / Authorization / sk- 누출 없음 보고 | PASS | adapter smoke: "no Bearer / sk-key fingerprint" |

## 회귀 감시

- 최상위 메뉴가 여전히 4개 탭을 노출하는가? — 아니오. 3개로 단순화됨.
- AI chat이 Lua 편집 에이전트 하위에서 기본으로 열리지 않는가? — 아니오. `agentMode: 'chat'`이 기본값.
- Lua editor가 수동 사용자 입력 워크플로우를 잃었는가? — 아니오. editor 모드에서 전체 워크플로우 유지.
- 백과사전이 눈에 띄는 "새 템플릿 생성" 경로를 재도입했는가? — 아니오. 기존 가이드/빌더 컨텍스트 유지.
- CSS가 60 kB 선을 초과했는가? — 아니오. 59.45 kB.
- Track B 백엔드/로그/스냅샷 동작이 변경되었는가? — 아니오. `server/**` 변경 없음.

## 최종 평결

```text
정적 체크포인트: 30 / 30 PASS
파이프라인: smoke:ai-chat-entrypoint PASS, verify:release 16단계 전체 PASS
번들: Main JS 254.00 kB / Main CSS 59.45 kB / aiContextPruning 8.56 kB / LuaAssistant lazy 135.22 kB
드리프트: server/public/docs/package/package-lock 변경 없음
회귀: 없음
평결: APPROVED - Advisory workspace menu hold.
```

Advisory Workspace Menu는 4개 탭을 3개 주요 영역(Lua 편집 에이전트, 백과사전, 설정)으로 단순화합니다. Lua 편집 에이전트는 AI 에이전트 대화와 Lua 편집기 2개 하위 모드를 가지며, 새 워크스페이스는 AI 대화 모드를 기본으로 합니다. 레거시 탭 상태는 자동으로 새 구조로 마이그레이션됩니다. 모든 기존 안전 경계와 B2/B3/B4 기능이 보존되었습니다.
