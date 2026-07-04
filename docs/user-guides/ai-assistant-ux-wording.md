# AI Assistant UX Wording & Prompt Flow

> **Owner:** Gemini
> **Target Audience:** Codex (for UI implementation), Non-programmer Users (final UI readers)

This document contains the finalized Korean UX copy for the Scenario Loader, AI Assistant prompt flow rules, and a classification of common user goals. Codex should use these texts when implementing UI components.

---

## 1. Scenario Loading States UX Copy

### `readyWithInternalSidecar` (정상 연동 및 분석 완료)
*   **배지 라벨:** `[분석 완료]`
*   **한 줄 설명:** 시나리오 데이터를 성공적으로 불러왔습니다.
*   **툴팁/도움말:** 로컬에서 생성된 사이드카(요약본)를 통해 이벤트, Lua 스크립트, 진영 정보 등을 안전하게 확인할 수 있습니다. 원본 `.scen` 파일은 변경되지 않습니다.
*   **버튼 라벨:** `열기`

### `metadataOnlyNeedsDecoder` (압축 해제 필요 / 메타데이터 모드)
*   **배지 라벨:** `[압축 해제 필요]`
*   **한 줄 설명:** 시나리오의 기본 정보만 읽었습니다. 내부 스크립트와 이벤트를 보려면 디코더 실행이 필요합니다.
*   **툴팁/도움말:** 이 시나리오는 압축되어 있어 현재 제목과 설명만 표시됩니다. 상세한 이벤트와 유닛 정보를 불러오려면 `prepare:scenario` 파이프라인을 실행해 주세요.
*   **버튼 라벨:** `시나리오 준비(Prepare) 안내`
*   **경고 문구:** **안내:** 현재는 기본 메타데이터만 확인 가능합니다. 이벤트나 유닛 목록을 보시려면 `prepare:scenario` 명령을 실행한 뒤 요약본(.summary.json)을 다시 불러와 주세요.

### `decoderFailure` (압축 해제 실패 / 수동 추출 필요)
*   **배지 라벨:** `[수동 추출 필요]`
*   **한 줄 설명:** 로컬 디코더가 파일에서 시나리오 데이터를 추출하지 못했습니다.
*   **툴팁/도움말:** 파일이 손상된 것은 아닙니다. `ContentScenario` 계열은 현재 지원됩니다. 이 상태가 계속 나오면 구버전 DB, 특수 컨테이너, 손상된 sidecar, 또는 수동 익스포트가 필요한 예외 케이스(예: CMANO 레거시 시나리오)일 수 있습니다.
*   **버튼 라벨:** `해결 방법 보기`
*   **경고 문구:** **안내:** 내부 데이터를 추출하지 못했습니다. 시나리오를 CMO 엔진에서 직접 열어 저장(Resave)하여 최신 버전으로 업데이트하거나, CMO 콘솔(Lua Console) 기능을 통해 수동으로 데이터를 내보내(Export) 주세요.

### `plainXmlReadable` (XML 직접 읽기)
*   **배지 라벨:** `[XML 모드]`
*   **한 줄 설명:** 원본 XML 구조를 직접 탐색합니다.
*   **툴팁/도움말:** 가공되지 않은 전체 XML 데이터를 엽니다. 파일 크기에 따라 브라우저가 느려질 수 있습니다.
*   **버튼 라벨:** `요약본 만들기`
*   **경고 문구:** **주의:** 방대한 원본 데이터를 직접 읽고 있어 성능 저하가 발생할 수 있습니다. 쾌적한 사용을 위해 요약본(.json) 생성을 권장합니다.

### `readError` (파일 읽기 불가)
*   **배지 라벨:** `[읽기 불가]`
*   **한 줄 설명:** 시나리오 파일 형식을 해석할 수 없습니다.
*   **툴팁/도움말:** 지원하지 않는 버전이거나 손상된 파일일 수 있습니다. CMO 에디터에서 다시 저장해 보세요.
*   **버튼 라벨:** `다른 파일 선택`

### `largeLuaSafeMode` (대용량 스크립트 안전 모드)
*   **배지 라벨:** `[안전 모드]`
*   **한 줄 설명:** 브라우저 성능 보호를 위해 대용량 파일에 대한 일부 기능이 제한됩니다.
*   **툴팁/도움말:** 스크립트 용량이 매우 커서 메모리 부족을 방지하기 위해 구문 강조(Syntax Highlighting)와 자동 저장 기능이 일시적으로 꺼져 있습니다.
*   **버튼 라벨:** `기본 편집기로 열기` (또는 `제한 해제`)
*   **경고 문구:** **안내:** 텍스트 로딩 속도를 유지하기 위해 안전 모드로 동작 중입니다. 복잡한 편집은 외부 에디터 사용을 권장합니다.

---

## 2. AI Assistant Prompt Flow (Infer vs. Ask Back)

AI 어시스턴트가 사용자의 자연어 요청을 받고 Lua를 생성하기 전, 자체적으로 유추할 수 있는 정보와 반드시 사용자에게 되물어야 하는 정보를 분류합니다.

### ✅ 유추 가능 (Can be inferred safely)
*   **Lua 문법 및 기본 로직:** 루프, 변수 선언, `math.random` 등 기본 Lua 문법.
*   **CMO API 구조:** `ScenEdit_AddUnit`, `ScenEdit_SetMission` 등 사용할 함수의 올바른 매개변수 양식.
*   **전역(Global) 범위 동작:** 날씨 변경(`ScenEdit_SetWeather`), 전체 메시지 발송(`'All'`) 등 특정 객체에 종속되지 않는 기능.

### ⚠️ 반드시 되묻기 (Must be asked back / objectContextMissing)
*   **정확한 고유 이름 (Exact Names):** 진영(Side), 유닛(Unit), 기준점(RP), 구역(Zone), 임무(Mission)의 정확한 이름이나 GUID.
*   **데이터베이스 식별자 (DBID / Loadout ID):** 기체 종류나 무장 ID. AI가 임의로 창작(Hallucination)해서는 안 됩니다.
*   **이벤트 반복 여부:** 한 번만 작동할지, 조건이 맞을 때마다 반복 작동할지 여부.

---

## 3. 10 Natural Language User Goals & Required CMO Context

초보자가 AI에게 요청할 법한 10가지 자연어 목표와 이를 Lua 스크립트로 구현하기 위해 AI가 확보해야 하는 CMO 문맥(Context)입니다.

| # | 사용자 목표 (자연어) | 필수 CMO 컨텍스트 (Required Context) |
|---|---|---|
| 1 | "적기가 내 영공에 들어오면 요격기를 띄우고 싶어." | **Side**(아군/적군), **Mission**(요격 임무), **Zone**(영공), **Trigger**(UnitEntersArea), **Action**(Scramble) |
| 2 | "특정 시간이 지나면 증원군이 도착하게 해줘." | **Side**, **Unit DBID** & **Loadout ID**, **Trigger**(RegularTime), **Action**(AddUnit) |
| 3 | "아군 함선이 파괴될 때마다 점수를 잃게 만들고 싶어." | **Side**, **Unit GUID/Name** 또는 TargetFilter, **Trigger**(UnitDestroyed), **Action**(ChangeScore) |
| 4 | "시나리오가 시작될 때 무작위로 날씨를 바꾸고 싶어." | **Trigger**(ScenLoaded), **Action**(SetWeather) |
| 5 | "특정 건물이 파괴되면 미션을 끝내고 승리 판정을 내려줘." | **Side**, **Unit GUID/Name**, **Trigger**(UnitDestroyed), **Condition**(유닛 확인), **Action**(EndScenario, SpecialMessage) |
| 6 | "정찰기가 적 레이더를 처음 탐지했을 때 화면에 경고창을 띄워줘." | **Side**, **Trigger**(UnitDetected), **Action**(SpecialMessage) |
| 7 | "플레이어가 원할 때 언제든 보급품을 투하할 수 있는 버튼을 추가할래." | **Side**, **Special Action**(특수행동 생성) |
| 8 | "이란군 비행기의 무기 사용 규칙을 '자유 사격'으로 바꾸고 싶어." | **Side**, **Unit/Mission Name**, **Action**(SetDoctrine) |
| 9 | "기지에 있는 F-16 편대의 무장을 공대공(AAW)으로 변경하고 즉시 출격시켜." | **Side**, **Unit GUID/Name**, **Loadout ID**, **Action**(SetLoadout, Scramble) |
| 10 | "수송기가 목표 기준점에 도달하면 화물을 내리도록 해줘." | **Side**, **Unit GUID/Name**, **Reference Point**, **Trigger**(UnitEntersArea), **Action**(UnloadCargo) |
