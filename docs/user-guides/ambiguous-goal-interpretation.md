# AI Assistant: Ambiguous Goal Interpretation Table

> **Owner:** Gemini
> **Target Audience:** Codex (for prompt engineering), Claude (for backend logic)

초보 사용자는 종종 구체적인 CMO 시스템 용어 대신 모호하고 일상적인 자연어로 목표를 제시합니다. AI 어시스턴트는 이러한 모호한 요청을 정확한 CMO Event/Lua 구조로 해석하고, 부족한 정보를 사용자에게 되묻는(Ask-back) 능력이 필요합니다.

---

## 모호한 사용자 목표 해석 및 되묻기 가이드

| 모호한 사용자 입력 (Ambiguous Goal) | AI의 CMO 구조 해석 (Interpretation) | AI가 반드시 되물어야 할 질문 (Must Ask Back) |
| :--- | :--- | :--- |
| **"적들이 공격하게 해줘."**<br>("Make the enemy attack.") | `Mission` 할당 (Strike/Patrol) 또는 `Doctrine` (무기 자유 사격) 변경 | 1. 공격할 적 유닛의 이름이나 GUID는 무엇인가요?<br>2. 공격 대상(Target)이나 목표 구역(Zone)이 지정되어 있나요? |
| **"내 배가 부서지면 게임을 끝내줘."**<br>("End the game if they sink my ship.") | `Trigger`: UnitDestroyed<br>`Action`: EndScenario | 1. 파괴를 감지할 '내 배'의 정확한 이름이나 GUID를 알려주세요.<br>2. 승리/패배 메시지를 함께 띄울까요? |
| **"시간이 지나면 지원군을 보내줘."**<br>("Send reinforcements after some time.") | `Trigger`: Time / RegularTime<br>`Action`: AddUnit / TeleportUnit | 1. 어느 진영(Side)에 지원군을 생성할까요?<br>2. 생성할 기종의 DBID나 무장(Loadout ID)은 무엇인가요?<br>3. 어느 위치(좌표/기준점)에 생성해야 하나요? |
| **"아군 기지가 발각되면 경고를 띄워."**<br>("Show a warning if our base is spotted.") | `Trigger`: UnitDetected<br>`Action`: SpecialMessage | 1. 아군 기지의 정확한 이름이나 GUID는 무엇인가요?<br>2. 적 진영(탐지 주체)의 이름은 무엇인가요? |
| **"미사일을 다 쓰면 기지로 돌아가게 해."**<br>("Make them RTB when out of missiles.") | `Doctrine`: Weapon State RTB 설정 변경 또는 `Action`: SetUnit(RTB) | 1. 기지로 귀환시킬 유닛이나 편대의 이름/GUID를 알려주세요. (또는 특정 임무 전체에 적용할까요?) |
| **"특정 구역에 들어가면 점수를 줘."**<br>("Give points when entering the area.") | `Trigger`: UnitEntersArea<br>`Action`: ChangeScore | 1. 어느 진영(Side)이 점수를 받나요? 몇 점을 줄까요?<br>2. 진입을 감지할 구역(Zone)이나 기준점(RP)이 지도에 그려져 있나요? 이름이 무엇인가요? |

## AI Assistant 동작 원칙 (Prompt Guardrails)
1. **절대 지어내지 말 것 (No Hallucination):** 사용자가 위와 같이 뭉뚱그려 말했을 때, AI는 임의의 DBID, GUID, 구역 이름을 생성해서 Lua 스크립트를 완성해버리면 안 됩니다.
2. **구체적인 행동 지침 제공:** 단순히 "정보가 부족합니다"라고 하는 대신, "CMO 에디터에서 해당 유닛을 우클릭하여 'Copy Unit ID'를 누른 뒤 저에게 붙여넣어 주세요"와 같이 초보자가 따라할 수 있는 명확한 CMO 에디터 조작법을 함께 안내해야 합니다.