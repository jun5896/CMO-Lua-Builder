# CMO Lua UI — Agent Guide

Command: Modern Operations (CMO) Lua/Event 작성 보조 UI. Vite + React 프론트엔드, Node.js AI 어댑터 서버, PowerShell/Node 툴체인으로 구성.

## 실행 명령

```powershell
cd "C:\Users\dlwls\.codex\cmo-lua-ui"

npm install                       # 의존성 설치
npm run dev -- --host 127.0.0.1   # Vite 개발 서버 (기본 http://127.0.0.1:5173)
npm run build                     # 프로덕션 빌드
npm run preview -- --host 127.0.0.1  # 빌드 결과 미리보기 (http://127.0.0.1:4173)
npm run lint                      # ESLint
```

AI 어댑터 서버 (별도 터미널):
```powershell
node server/ai-provider-adapter.mjs          # http://127.0.0.1:8765
PORT=9999 node server/ai-provider-adapter.mjs  # 포트 오버라이드
```

시나리오/에셋 도구:
```powershell
npm run sync:cmo-examples          # CMO 설치 경로에서 Lua 예제 동기화
npm run scan:scenario              # 시나리오 폴더 스캔
npm run prepare:scenario           # .scen → sidecar(JSON/XML) 생성
npm run prepare:scenario-batch     # 전수조사 배치
npm run audit:scenario-openability # 시나리오 열기 가능성 감사
npm run verify:scenario-loader     # 로더 검증
npm run audit:cmo-db               # DB 에셋 감사
npm run refresh:cmo-assets         # DB + 시나리오 감사 통합 실행
npm run extract:scenario-xml       # .scen에서 XML 추출 (PowerShell)
npm run summarize:scenario         # 시나리오 XML → summary JSON
npm run start:ai-adapter           # AI 어댑터 시작 (server/와 동일)
npm run smoke:ai-adapter           # 업스트림 리덕션 검증
```

## 프로젝트 아키텍처

```
src/
  App.jsx                  # 최상위 앱 — 탭 라우팅, 테마, 폰트, 워크스페이스 상태
  main.jsx                 # React 진입점
  index.css                # 전역 스타일 (glass-panel, 테마 변수)
  components/
    LuaAssistant.jsx        # ★ 핵심 — Lua 분석/편집, 시나리오 파서, AI 프롬프트 빌더 (~2700줄)
    PresetGuide.jsx         # 프리셋 빌더 탭 — EventEditor + CodeExporter + TemplateLibrary 통합
    EventEditor.jsx         # 템플릿 폼 기반 이벤트 편집 (지도 좌표 임포트 지원)
    CodeExporter.jsx        # 이벤트 → Lua 직렬화 / 다운로드
    FeaturePalette.jsx      # 카테고리별 빌더 폼 선택 팔레트
    TemplateLibrary.jsx     # 설치된 Lua 예제/프리셋 탐색기
  data/
    templateCatalog.js      # 이벤트 템플릿 정의 (~30종) + 폼 필드 스키마
  lib/
    aiAdapterClient.js      # AI 어댑터 HTTP 클라이언트 + 응답 파서/검증

server/
  ai-provider-adapter.mjs   # 로컬 Node HTTP 서버 (127.0.0.1:8765)
  providers.mjs             # OpenAI/Ollama/LM Studio 프로바이더 구현
  verify-upstream-redaction.mjs  # 보안 검증 스크립트
  .env.example              # 환경변수 템플릿

tools/
  *.mjs                     # Node CLI 도구 (시나리오 스캔/파싱/배치/감사)
  *.ps1                     # PowerShell 도구 (.scen XML 추출)

public/
  cmo-dev-work/templates/   # .tpl.lua 템플릿 원본 (~45개)
  cmo-dev-work/presets/     # 완성형 Lua 프리셋
  cmo-dev-work/db_cache/    # DB 인덱스 캐시
  cmo-installed-lua/        # CMO 설치 경로에서 동기화한 Lua 예제
  scenario-scan-samples/    # 전수조사 산출물 (JSON/XML/summary)

docs/                       # 계약서, 가이드, 에이전트 운영 기록
fixtures/                   # 테스트 픽스처, 파서 검증 스펙
handoff/                    # 다중 에이전트 간 작업 전달 우편함
```

## 핵심 데이터 흐름

1. **템플릿 선택**: FeaturePalette → templateCatalog에서 kind로 조회 → EventEditor 폼 렌더
2. **폼 → Lua**: CodeExporter가 templateCatalog 필드 정의 + 폼 값 → 직렬화된 Lua
3. **Lua 분석**: LuaAssistant.analyzeLua()가 ScenEdit/VP/World API, DBID, GUID, 트리거 힌트 추출 + 위험 신호 생성
4. **시나리오 로딩**: .scen → parseScenarioContainer() (DOMParser) → sidecar 자동 탐색(fetchScenarioSidecar) → Object/Lua 컨텍스트 병합
5. **AI 프롬프트**: LuaAssistant가 context + objective + intent + DB 정보를 조합 → aiAdapterClient.sendCmoAiPrompt() → 어댑터 서버가 OpenAI 호환 API로 중계
6. **AI 응답 처리**: parseAiInterpreterResponse()가 필수 섹션 검증, placeholder/unsafe Lua 차단, Lua 추출

## CMO 도메인 지식

- **환경 스냅샷 (2026-07-04 실측)**: Build 1892 (v1.10 Beta), DB3K/CWDB 517. Build 1852→1892 베타 변경 다이제스트는 `docs/references/cmo-beta-builds-2026-04-to-06.md` 참조
- **CMO Lua 샌드박스**: `os.*`, `io.*`, `require`, `dofile`, `loadfile`, `package.*`, `debug.*` 사용 불가 (Build 1892에서 재확인)
- **주요 API 접두어**: `ScenEdit_*`, `VP_*`, `Tool_*`, `World_*`, `Unit_*`, `Mission_*`, `Side_*`
- **Build 1877+**: `ScenEdit_CustomUI`로 Special Message의 "raise pop up" 설정 제약 없이 커스텀 UI 표시 가능
- **DBID/Loadout ID**: DB3000(=DB3K)과 CWDB는 같은 숫자 ID라도 의미가 다름. 반드시 현재 시나리오 DB 버전 기준으로 Database Viewer에서 확인
- **GUID**: 배치 유닛은 우클릭 → Scenario Editor → Copy unit ID to clipboard로 확보. 이름보다 GUID 우선
- **Event 구조**: Trigger + Condition + Action. Trigger/Condition은 CMO UI에서 만들고, Action만 Lua Script로 연결하는 패턴이 권장
- **KeyValue**: ScenEdit_SetKeyValue/GetKeyValue로 반복 실행 방지. 1회성 이벤트에 필수
- **RegularTime 트리거**: `interval=0` ≈ 매 게임초 (IKE 방식, Build 1892 인게임 검증). 게임 시계가 정지 상태면 발화하지 않음

## 코드 패턴과 규칙

### 상태 관리
- 모든 상태는 `localStorage`에 JSON으로 저장 (`cmo-lua-ui-*` 키)
- App.jsx가 theme, editorSettings, workspaceState를 관리
- LuaAssistant는 자체 상태(소스 Lua, 컨텍스트, 인텐트, AI 응답)를 독립 관리 + Origin Private FS에 임시 세션 백업

### 템플릿 시스템
- `templateCatalog.js`에서 `EVENT_TEMPLATES` 배열 + `registerBuilderForm()`으로 템플릿 등록
- 각 템플릿: `{ kind, title, sourceFile, defaultName, fields[], notes[] }`
- 필드 타입: `text`, `number`, `select`, `checkbox`, `lua`, `textarea`
- `visibleWhen` 콜백으로 조건부 필드 표시
- `mapImport: true` 필드는 지도 클릭 좌표 연동

### Lua 분석 (analyzeLua)
- API 호출, 이벤트 헬퍼, 트리거 힌트, DBID/GUID/이름 참조 추출
- 위험 신호 자동 감지: nil 체크 누락, 시나리오 종료 API, KeyValue, math.random, DBID 의존, Loadout, EMCON/Doctrine
- 대규모 Lua 처리: `LUA_ANALYSIS_CHAR_LIMIT`(320K) 초과 시 샘플링, `LUA_HIGHLIGHT_CHAR_LIMIT`(180K) 초과 시 문법 강조 일시 정지

### AI 어댑터 보안
- API key는 브라우저 저장소에 저장하지 않고 어댑터 메모리에만 전달
- `deepScrubSecrets()`로 응답 내 Bearer/sk-key 패턴 제거
- `PLACEHOLDER_PATTERNS`(`<UNIT_GUID>`, `TODO`, `REPLACE_ME` 등)가 AI 응답 Lua에 있으면 차단
- `UNSAFE_LUA_PATTERNS`(os., io., require 등)가 있으면 차단

### AI 응답 파싱
- 필수 섹션: Summary, Assumptions, CMO UI prerequisites, Paste-ready Lua, Validation checklist, Follow-up questions or blockers
- `parseAiInterpreterResponse()`가 마크다운 섹션 분리 → Lua 펜스 추출 → placeholder/unsafe 검증

### 시나리오 파서
- 브라우저 내 DOMParser로 XML 파싱 (압축 본문은 디코딩 안 함)
- `.summary.json` sidecar를 우선 탐색 → 없으면 `.scenario.xml` sidecar → 둘 다 없으면 메타데이터만
- 추출된 Object 컨텍스트(sides, units, missions, RPs, zones, events, specialActions)를 LuaAssistant Object Registry에 병합

### ESLint 규칙
- `no-unused-vars`: `^[A-Z]` 패턴 변수는 무시 (컴포넌트 등), `^_` 접두 인자는 무시
- react-hooks, react-refresh 권장 규칙 적용
- `dist` 디렉토리 무시

## 주의사항

- **index.html 직접 열기 불가**: Vite 개발 서버 필요 (ES module import, /public 정적 파일 경로)
- **대규모 Lua**: LuaCodeEditor는 텍스트 길이에 따라 자동으로 large-lua-mode 전환 (문법 강조 비활성화)
- **.scen 디코딩 제한**: 브라우저에서 압축 본문을 풀지 않음. 반드시 `npm run prepare:scenario`로 sidecar 생성 후 사용
- **CMANO 레거시**: 구형 CMANO 시나리오는 현대 CMO 디코더가 내부 XML 복원 불가. openability status가 `decoderFailed`인 항목은 재시도해도 소용없음
- **server/.env**: 절대 git에 커밋하지 않음. `.gitignore`에 등록됨
- **CORS**: 어댑터 서버는 `127.0.0.1:5173`, `localhost:5173`, `127.0.0.1:4173`, `localhost:4173`만 허용
- **public/cmo-dev-work 동기화**: `C:\Users\dlwls\.antigravity\cmo-lua-dev-work`에서 원본을 수정하면 public/으로 다시 동기화해야 UI에 반영

## 멀티 에이전트 조정

### 역할 분담

| 에이전트 | 역할 |
|----------|------|
| **Codex** | 주 작업자 — UI, 컴포넌트, 통합, 사용자 대면 동작, 릴리즈 |
| **Claude Code** | 백엔드/헬퍼 — tools/, server/, src/lib/ 중 UI 비의존 유틸, 파서, 스캐너 |
| **Kimi** | QA — docs/, fixtures/, git 위생, 빌드/린트 모니터링 |
| **Gemini** | 언어 품질 리뷰 — 한국어/영문 혼용 표현, 용어 일관성, docs/ 직접 편집 가능 (기능 코드 불가) |

### 파일 소유권

| 소유자 | 파일 |
|--------|------|
| Codex | `src/App.jsx`, `src/components/*.jsx`, `src/index.css` |
| Claude Code | `tools/**`, `server/**`, `src/lib/**` (UI 비의존만) |
| Kimi | `docs/*.md` (backend-*.md 제외), `fixtures/**`, `.gitignore` |
| 공유 (조정 필요) | `package.json`, `README.md`, `public/**` |

### 규칙

- 동일 세션에서 다른 에이전트가 편집한 파일을 덮어쓰지 않음
- 프론트엔드 컴포넌트에 직접 네트워크/API 호출을 넣지 않음 (어댑터 경유)
- API key를 repo 파일, localStorage, 로그에 저장하지 않음
- `.scen` 압축 페이로드를 직접 디코딩하려 하지 않음 (CMO 엔진 export 경로 우선)
- 백엔드 출력은 항상 JSON 형태 (UI 연동 용이)

### 핸드오프

- `handoff/to-{claude,kimi,gemini}/CURRENT_TASK.md`로 작업 전달
- 핸드오프 내용: 변경 파일, 새 명령, 입출력 계약, 예제 출력, 제한사항, 검증 결과
- Claude ↔ Codex 간 `~/.claude/`와 `~/.codex/` 크로스 쓰기 금지
