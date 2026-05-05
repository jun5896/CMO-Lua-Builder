# CMO Domain Beginner Guide & Glossary

> **Owner:** Gemini
> **Target Audience:** Codex (for prompt slots/warnings), First-time Users

This document translates CMO engine concepts into beginner-friendly checklists, glossaries, and warnings. It ensures that UI instructions and AI-generated text remain accurate to CMO's mechanics.

---

## 1. Compact Korean Glossary

UI 라벨, 툴팁, AI 어시스턴트 프롬프트에 일관되게 적용할 공식 용어표입니다.

*   **Side:** 진영
*   **Mission:** 임무
*   **Reference Point:** 기준점 (RP)
*   **Zone:** 구역 (비항해구역, 금지구역 등)
*   **Event:** 이벤트
*   **Trigger:** 트리거
*   **Condition:** 조건
*   **Action:** 행동
*   **Special Action:** 특수행동
*   **DBID:** DBID (데이터베이스 ID - 고유 기종 번호)
*   **Loadout ID:** Loadout ID (무장 ID)
*   **Unit GUID:** 유닛 GUID (맵에 배치된 특정 유닛의 고유 식별자)
*   **Scenario_Compressed:** 압축된 시나리오 데이터

*추가 권장 용어 (Prompt Slots 용):*
*   **Platform:** 기체 / 플랫폼
*   **Sensor:** 센서 (레이더, 소나 등)
*   **Mount:** 마운트 / 무장 장착대
*   **Weapon:** 무기
*   **Doctrine:** 교전수칙
*   **EMCON:** 방사통제

---

## 2. DB Orientation (DB3K vs CWDB / DBID vs GUID)

초보자가 가장 많이 혼동하는 데이터베이스 버전과 식별자에 대한 가이드입니다.

### DB3K vs CWDB
*   **개념:** CMO는 1980년대 이후의 현대전(DB3K)과 1946~1979년의 냉전(CWDB) 두 가지 데이터베이스를 사용합니다.
*   **주의사항:** 한 시나리오 안에서 두 시대를 섞어 쓸 수는 없습니다. 추가할 유닛이 현재 시나리오의 DB 연도에 맞는지 확인해야 합니다.
*   **UI 경고 문구 제안:** `[DB 버전 주의]` "시나리오의 DB 버전이 현재 엔진과 다를 수 있습니다. CMO 에디터에서 시나리오를 다시 저장해 버전을 맞춰주세요."

### 식별자 차이 (DBID vs GUID)
*   **DBID / Loadout ID:** 카탈로그의 '상품 번호'입니다. (예: F-35A 기종 자체의 고유 번호). **유닛을 새로 생성할 때** 필요합니다.
*   **Unit GUID:** 맵 위에 이미 배치된 '실제 유닛의 주민번호'입니다. **이미 존재하는 유닛을 조작할 때** 사용합니다.
*   **UI 경고 문구 제안:** `[식별자 확인 필요]` "특정 기체 종류(DBID)를 새로 생성하려는지, 이미 배치된 유닛(GUID)을 조작하려는지 구분해서 입력해 주세요."

---

## 3. Beginner Checklist: Web Assistant vs CMO Engine

스크립트를 적용하기 전, CMO 에디터에서 직접 세팅해야 하는 것과 웹 어시스턴트가 해줄 수 있는 것을 명확히 구분합니다.

### 📝 AI에게 요청하기 전 확인사항 (CMO 에디터 작업)
*   [ ] **고유 이름(Name) 복사:** 스크립트의 대상이 될 진영(Side), 유닛, 임무(Mission)의 이름을 CMO 에디터에서 정확히 복사하셨나요? (오타가 있으면 에러가 발생합니다)
*   [ ] **기준점 및 구역(Zone) 배치:** 이벤트가 일어날 장소를 지도에 미리 그려 두셨나요?
*   [ ] **트리거 생성:** 이벤트를 작동시킬 트리거(예: '적기 탐지 시')를 만들어 두셨나요?
*   [ ] **DBID 확인:** 새로운 유닛을 생성하려는 경우, Database Viewer에서 해당 기체의 정확한 DBID를 확인하셨나요?

### 💻 웹 어시스턴트의 역할
*   복잡한 로직이 들어간 **Lua 행동(Action)** 스크립트를 작성합니다.
*   이벤트의 반복 방지, 변수 활용 등 **조건(Condition)** 스크립트를 설계합니다.

> **⚠️ 안전 경고:** 웹 어시스턴트는 스크립트를 작성해 주지만, 최종적인 문법 검증과 실행 결과는 반드시 CMO 엔진 내부에서 테스트해야 합니다.

---

## 4. CMO Lua Pitfalls & Safety Guidelines (from Forum / Manual)

스크립트 작성 시 빈번하게 발생하는 에러 및 한계점입니다. AI 어시스턴트가 코드를 생성할 때 이를 방어(Defensive coding)해야 합니다.

1.  **`ScenEdit_UnitX()`의 한계:** 이 함수는 오직 '이벤트 행동' 내부에서 특정 트리거(예: 유닛 파괴/탐지)와 연결되었을 때만 컨텍스트 유닛을 반환합니다. 콘솔에서 단독으로 테스트하면 항상 `nil`을 반환하므로 테스트 코드를 분리할 때 주의가 필요합니다.
2.  **생성 시 필수 파라미터:** `ScenEdit_AddUnit` 사용 시 DBID뿐만 아니라 유효한 좌표(위도/경도)가 누락되면 엔진에서 조용히 실패합니다.
3.  **비공식 파라미터 조작 금지:** 손상 모델(Damage)이나 남은 연료를 직접 할당하는 해킹성 로직 대신, 공식적으로 문서화된 `ScenEdit_*` API 래퍼를 우선적으로 사용하도록 강제해야 합니다.