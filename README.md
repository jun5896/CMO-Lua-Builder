# CMO Lua Builder

Vite + React 기반의 Command: Modern Operations Lua template / preset / scenario sidecar / AI assistant 작업 UI입니다.

현재 공개 제품 릴리스는 `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`입니다. `main` 브랜치에는 릴리스 이후 handoff/QA 문서 정리와 작은 운영 UI polish가 이어질 수 있습니다.

2026-07-04부터 로컬 작업 사본은 `D:\works\CMO-Lua-Builder`입니다 (구 PC의 `~/.codex/cmo-lua-ui`는 폐기). CMO 설치 경로는 `tools/cmo-install-locator.mjs`가 Steam 라이브러리(`libraryfolders.vdf`)를 스캔해 자동 감지하며, `CMO_ROOT` / `CMO_LUA_ROOT` / `CMO_LOGS_ROOT` / `CMO_SCENARIOS_ROOT` 환경 변수로 오버라이드할 수 있습니다.

## AI Bridge (GUI 없이 CLI로 직접 사용)

AI 코딩 에이전트(Claude Code 등)가 React UI 없이 터미널에서 CMO Lua 루프를 직접 돌리는 브리지입니다. 모든 AI 페이로드는 UI와 동일한 unsafe-Lua 게이트를 통과합니다.

```powershell
npm run bridge -- status                                    # 경로/AiAssist/로그 상태
npm run bridge -- apply --file draft.lua --slug name --write  # 1회성 초안 저장 (기본 dry-run)
npm run bridge -- install-poller --write                    # 인게임 inbox 폴러 설치 Lua 생성
npm run bridge -- inbox --file draft.lua --write            # 폴링되는 inbox에 페이로드 발행
npm run bridge -- logs --kind exception --limit 10          # CMO 로그 read-only 회수
```

폴러 설치 Lua를 CMO Lua 콘솔에서 1회 실행하면, 이후 `inbox` 발행분은 게임이 RegularTime 이벤트로 자동 실행합니다(KeyValue 가드로 중복 실행 방지, 결과는 `aiassist_inbox_result` KeyValue). 폴러 없이도 `apply` + 콘솔 1줄 실행으로 동작합니다.

### AI 백엔드 선택 (구독 CLI + BYOK)

로컬의 Claude Code 프로필 / Codex 계정 / Cursor CLI와 BYOK 프리셋(Kimi·GLM·Grok)을 자동 스캔해 골라 쓸 수 있습니다.

```powershell
npm run backends                                   # 목록 (계정 이메일·키 감지 상태 표시)
npm run backends -- --use claude:default           # 기본 백엔드 지정
npm run ask -- --backend codex:pro2 --prompt "..." # 일회성 호출/교차검수 위임
```

BYOK 키는 환경변수로만 읽으며 디스크에 저장하지 않습니다. Cursor Composer는 BYOK HTTP가 차단되어 있어 구독 CLI(`cursor-agent`) 경유로만 동작합니다.

## 실행 (GUI)

`index.html`을 더블클릭해서 직접 실행하는 방식이 아닙니다. Vite 개발 서버가 React, ES module import, `/public` 정적 파일 경로를 처리해야 합니다.

```powershell
cd "D:\works\CMO-Lua-Builder"
npm install
npm run dev -- --host 127.0.0.1
```

터미널에 표시되는 주소를 브라우저에서 엽니다. 기본은 보통 다음 주소입니다.

```text
http://127.0.0.1:5173/
```

운영 형태로 확인하려면 다음을 사용합니다.

```powershell
npm run build
npm run preview -- --host 127.0.0.1
```

## 주요 기능

- Event / Lua Assistant: CMO Lua draft 작성, template / preset 삽입, AI 응답 검토
- Preset Guide: template 설명, builder form, 사용자 지정 preset 관리
- Scenario Sidecar Cache: 압축 `.scen`을 위한 로컬 분석 sidecar 연결
- AI Provider Settings: OpenAI-compatible / LM Studio / Ollama adapter 설정과 model profile 선택
- AI Context Pruning: 대형 scenario context를 줄이되 DBID/GUID/active Lua 안전 불변식은 보존

## Sidecar Storage

Scenario sidecar는 원본 `.scen` 파일을 수정하지 않는 로컬 분석 파일입니다. 기본 외부 캐시 root는 다음 경로입니다.

```text
D:\works\cmo-scenario-sidecars
```

환경 변수가 없으면 도구는 clone 폴더의 부모 아래 `cmo-scenario-sidecars`를 먼저 찾고, 없으면 project-local legacy root를 확인합니다.

```powershell
$env:CMO_SCENARIO_SIDECAR_ROOT = "D:\works\cmo-scenario-sidecars"
```

검증 기준선 (2026-07-04, 새 PC / Build 1892 / DB517):

- Total scenarios: `1155`
- Ready with internal sidecar: `1155`
- Legacy decoder failed: `0`
- Loader issues: `0`

(구 PC 2026-05 기준선: 1899 / 1857 / 42 / 0 — CMANO 레거시 42건은 새 PC에 미존재)

관련 명령:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
```

고아 sidecar 삭제는 기본적으로 dry-run 확인 후 진행하세요. 참조 중인 sidecar는 삭제 대상이 아니며, `.scenario-extract-cache`는 임시 추출 공간입니다.

매칭되는 summary sidecar가 없을 때는 AI adapter가 `.scen`을 임시 메모리 summary로 열어 컨텍스트를 보강할 수 있습니다. 이 경로도 원본 `.scen`을 수정하지 않으며, 임시 파일은 정리됩니다.

## AI Adapter Safety

AI adapter는 로컬에서 provider 요청을 중계합니다. 저장된 provider profile에는 raw API key를 넣지 않으며, smoke test는 `Bearer` / `sk-` 누출이 없는지 확인합니다.

```powershell
npm run smoke:ai-adapter
```

AI가 생성한 Lua는 paste-ready gate를 통과해야 UI에서 Working Draft로 적용할 수 있습니다. UI에서는 이를 검증 완료 코드가 아닌 `Lua 초안`으로 안내하며, 적용 후에도 반드시 CMO 엔진에서 직접 실행 검증하세요.

## QA Baseline

최종 확인에 사용한 표준 파이프라인입니다.

```powershell
npm run verify:release
```

동일한 파이프라인을 수동으로 나누어 실행할 경우:

```powershell
npm run audit:scenario-sidecars
npm run verify:scenario-loader
npm run lint
npm run build
npm run smoke:ai-workflow-state
npm run smoke:ai-follow-up-needs
npm run smoke:ai-confirmed-context
npm run smoke:ai-adapter-client-sidecar
npm run smoke:cmo-log-feedback
npm run smoke:cmo-log-feedback-endpoint
npm run smoke:ai-adapter-client-log-feedback
npm run smoke:cmo-state-snapshot
npm run smoke:cmo-state-snapshot-endpoint
npm run smoke:ai-adapter-client-state-snapshot
npm run smoke:cmo-wiki-code-assistant
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

현재 bundle 기준선:

- Main JS: `253.81 kB`
- Main CSS: `59.45 kB`
- `aiContextPruning`: `8.56 kB`
- Template Inspector annotations: `51 / 51`
- `PresetGuide`: `33.99 kB JS / 7.49 kB CSS`
- `AiInterpreterChatPanel`: `10.38 kB JS / 6.73 kB CSS`
- `AiResponseReviewPanel`: `10.15 kB JS / 5.23 kB CSS`
- Confirmed Context Workspace: `smoke:ai-confirmed-context` PASS baseline
- RunScript Sidecar Writer: `smoke:cmo-lua-sidecar-writer`, `smoke:cmo-lua-sidecar-endpoint`, `smoke:ai-adapter-client-sidecar` PASS baseline
- Log Feedback Loop: `smoke:cmo-log-feedback`, `smoke:cmo-log-feedback-endpoint`, `smoke:ai-adapter-client-log-feedback` PASS baseline
- State Snapshot Import: `smoke:cmo-state-snapshot`, `smoke:cmo-state-snapshot-endpoint`, `smoke:ai-adapter-client-state-snapshot` PASS baseline
- CMO Wiki / Lua Reference Helper: `smoke:cmo-wiki-code-assistant` PASS baseline
- `CmoWikiPanel`: `7.59 kB JS / 3.61 kB CSS`
- `LuaEditorReferenceHelper`: `2.12 kB JS / 0.84 kB CSS`
- `LuaAssistant`: `136.86 kB JS`

## 동기화된 CMO Assets

- Templates: `public/cmo-dev-work/templates/*.tpl.lua`
- Presets: `public/cmo-dev-work/presets/*.lua`
- Manifest: `public/cmo-dev-work/manifest.json`
- DB summary: `DB3K_517.db3`, `CWDB_517.db3`, component entries `101078`
- Installed Lua examples: `public/cmo-installed-lua/`

`cmo-lua-dev-work`의 template/preset을 다시 수정했다면 `public/cmo-dev-work`를 다시 동기화해야 UI Inspector에도 최신 내용이 반영됩니다.
