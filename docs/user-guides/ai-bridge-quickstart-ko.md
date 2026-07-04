# AI Bridge 퀵스타트 (한국어)

CMO 시나리오의 AI를 대화로 고치는 최단 경로. GUI 불필요.

## 준비 (PC당 1회)

이미 완료된 상태입니다. 리포는 `D:\works\CMO-Lua-Builder`, CMO 설치는 자동 감지됩니다.

## 사용 (매번)

1. 바탕화면 **"CMO AI Bridge"** 바로가기 더블클릭 (= `start-cmo-ai.cmd`, CMO 아이콘) → **드라이버 선택 메뉴**가 뜸 (Claude 프로필 3종 / Codex 계정 3종 / Cursor / Grok — 엔터만 누르면 기본값). 선택한 CLI가 리포 컨텍스트로 열림
2. CMO는 따로 실행 (순서 무관 — 브리지가 설치·로그를 자동 감지)
3. AI에게 한국어로 원하는 것을 말한다. 예:
   - "이 시나리오 적 CAP이 미사일을 최대사거리에서 낭비하지 않게 WRA 조여줘"
   - "적 잠수함이 탐지되면 30분 뒤 증원 타격 미션이 생기게 해줘"
   - "OPFOR 전체 숙련도를 Veteran으로 올리고 EMCON 통제 걸어줘"
4. Claude가 Lua를 작성해 게임에 전달한다. 두 가지 모드:

### 모드 A — 수동 1줄 (기본, 폴러 설치 불필요)

Claude가 `apply`로 저장하고 로더 스니펫을 알려줌 → CMO Lua 콘솔(`Ctrl+Shift+L` 또는
Editor 메뉴 > Lua Script Console)에 붙여넣기 1회 실행.

### 모드 B — 완전 자동 (시나리오당 폴러 1회 설치)

1. Claude에게 "폴러 설치 파일 만들어줘" → 로더 스니펫 1회 실행 (시나리오 저장 시 이벤트가
   시나리오에 함께 저장되므로 그 시나리오에선 재설치 불필요)
2. 이후 Claude가 `inbox`로 발행하면 **게임 시계가 도는 동안 몇 초 내 자동 적용**
3. 결과 확인은 Claude가 알아서 함 (`logs` + KeyValue). 수동 확인은:
   ```lua
   print(ScenEdit_GetKeyValue('aiassist_inbox_result'))
   ```

## 문제가 생기면

- 에러가 나도 그대로 Claude에게 말하면 됨 — `npm run bridge -- logs`로 게임 로그를 직접 읽고 수정함
- 폴러가 안 도는 것 같으면: 게임 시계가 일시정지 상태인지 확인 (RegularTime 트리거는 게임 시간 기준)
- 폴러 제거: Claude에게 "폴러 제거해줘" (`install-poller --uninstall`)

## 안전 원칙 (자동 적용이어도 유지됨)

- 모든 AI Lua는 unsafe 게이트 통과 (os/io/require/dofile 등 차단)
- 게임 폴더 쓰기는 `Lua\AiAssist\`에 한정, `.scen` 원본은 절대 수정하지 않음
- 같은 페이로드는 KeyValue 가드로 1회만 실행됨
- 시나리오를 덮어쓰기 전에 별도 저장(Save As) 습관 권장
