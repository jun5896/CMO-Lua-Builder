@AGENTS.md

Claude Code role: 2026-07-04부터 이 리포의 단독 유지보수 에이전트 (구 멀티에이전트 분업은 종료; AGENTS.md의 역할 분담 표는 히스토리 참고용).

## AI Bridge — Claude Code가 CMO와 직접 대화하는 표준 경로

GUI를 띄우지 말고 `tools/cmo-ai-bridge.mjs`를 사용한다. CMO 설치 경로는 자동 감지된다 (`tools/cmo-install-locator.mjs`, env `CMO_ROOT` 등으로 오버라이드).

```powershell
npm run bridge -- status                                      # 경로/AiAssist/최신 로그 확인
npm run bridge -- apply --file <draft.lua> --slug <name> --write   # 1회성 초안 → 로더 스니펫 출력
npm run bridge -- inbox --file <draft.lua> --write            # 폴러가 자동 실행하는 inbox 발행
npm run bridge -- install-poller --write                      # 인게임 폴러 (un)installer 생성
npm run bridge -- logs --kind exception --limit 10            # 실행 결과/에러 회수 (read-only)
```

## AI 백엔드 선택 / 교차검수 위임

다른 모델에게 초안·2차 검수를 맡길 때 사용 (Claude 프로필 3종, Codex 계정 3종,
Cursor Composer CLI, BYOK Kimi/GLM/Grok — 전부 자동 스캔):

```powershell
npm run backends                                  # 사용 가능한 백엔드 목록 (계정 이메일 포함)
npm run backends -- --use codex:pro2              # 기본 백엔드 선택 (server/.cmo-ai-backends.json)
npm run ask -- --backend byok:glm --prompt "..."  # 일회성 위임 (선택 무관)
```

API 키는 환경변수로만 전달 (파일에는 env 변수 이름만 저장). CLI 백엔드는 OS 임시
폴더에서 1-shot 실행되므로 리포/게임 파일에 접근하지 않는다. 2026-07-04 실검증:
claude:default, codex:pro2, cursor:default(--trust), byok:glm(glm-5.2) 왕복 OK.
알려진 이슈: claude:work 프로필은 헤드리스 로그인 만료 시 `/login` 필요.

표준 루프: Lua 초안 작성 → `apply`(또는 `inbox`) → 사용자가 CMO에서 로더 스니펫 1회 실행(폴러 설치 후에는 inbox 자동 실행) → `logs`로 에러 회수 → 수정 반복. 결과 KeyValue: `aiassist_inbox_result` (콘솔에서 `print(ScenEdit_GetKeyValue('aiassist_inbox_result'))`).

안전 불변식 (변경 금지):
- AI 페이로드는 항상 `validateLuaSidecarContent` 게이트 통과 (os/io/require/dofile/loadfile/package/debug/ScenEdit_RunScript 차단)
- `ScenEdit_RunScript`는 브리지 소유의 고정 폴러 installer 템플릿에만 존재
- `.scen` 원본 무수정, 게임 쓰기는 `Lua\AiAssist\` 폴더 한정
- CMO 샌드박스에는 dofile이 없음 — Lua-root 상대경로 `ScenEdit_RunScript('/AiAssist/...')`만 동작 (B0.1 검증)

CMO Lua 작성 시 도메인 규칙은 AGENTS.md의 "CMO 도메인 지식" 섹션, API 예제는 `public/cmo-installed-lua/examples/`, 템플릿은 `public/cmo-dev-work/templates/`를 참조한다.
