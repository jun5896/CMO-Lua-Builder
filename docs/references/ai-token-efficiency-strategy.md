# AI Assistant Token Efficiency & Architecture Strategy

> **Owner:** Gemini
> **Date:** 2026-05-03
> **Purpose:** Outline architectural strategies to minimize token consumption, reduce latency, and improve the reliability of the AI Assistant when interacting with LLMs (e.g., Claude, Codex, or local models).

이 문서는 CMO Lua UI의 AI 어시스턴트가 사용자 요청을 처리할 때 발생할 수 있는 토큰 낭비와 환각(Hallucination)을 방지하기 위한 프롬프트 및 아키텍처 설계 지침입니다. 코덱스(Codex)가 백엔드/프론트엔드 연동을 구현할 때 이 가이드라인을 참고하여 설계합니다.

---

## 1. 템플릿 기반 파라미터 매핑 (Template-Driven Parameter JSON)
LLM이 매번 전체 Lua 코드를 처음부터 끝까지 생(Raw)으로 작성하게 하는 것은 비효율적이며 문법 오류를 유발할 확률이 높습니다.

*   **설계 방향:** 시스템은 이미 검증된 Lua 템플릿(`template-inspector-guide-seed.md` 등)을 보유하고 있습니다. AI는 자연어 입력을 분석하여 **"사용할 템플릿 ID"**와 **"빈칸(변수)에 채울 파라미터 값"**만 추출하여 JSON으로 응답해야 합니다.
*   **기대 효과:** 출력 토큰 대폭 감소, 100% 안전한 문법(Syntax) 보장.
*   **출력 예시:**
    ```json
    {
      "templateId": "mission_patrol_toggle",
      "params": {
        "side": "Blue",
        "missionName": "CAP-North"
      }
    }
    ```
    *(UI/백엔드가 이 JSON을 받아 실제 Lua 코드로 조립합니다.)*

## 2. 동적 컨텍스트 가지치기 (Dynamic Context Pruning)
시나리오 요약본(`.summary.json`) 전체를 프롬프트에 주입하면 입력 토큰이 심각하게 낭비되며(유닛이 수백 개일 경우), AI가 엉뚱한 유닛을 참조할 위험이 커집니다.

*   **설계 방향:** 사용자의 첫 질문에서 의도(Intent)와 핵심 타겟 진영(Side)을 먼저 파악한 후, 백엔드에서 **필요한 하위 트리(예: 특정 진영의 임무 목록과 관련 유닛만)만 필터링**하여 메인 프롬프트 컨텍스트에 주입합니다.
*   **기대 효과:** 불필요한 데이터(타 진영 정보, 무관한 이벤트 등)를 제거(Prune)하여 입력 토큰 비용 절감 및 답변 정확도 상승.

## 3. 기계 소비용 응답의 잡담 금지 (No Conversational Filler)
LLM 특유의 인사말("네, 도와드리겠습니다!", "요청하신 코드는 다음과 같습니다.")은 프로그램이 파싱할 때 에러를 일으키는 주범이며 토큰 낭비입니다.

*   **설계 방향:** 시스템 프롬프트에 매우 강력한 출력 제약 조건을 추가합니다.
    *   `Respond ONLY with valid JSON. Do not include markdown formatting, greetings, or explanations outside the JSON object.`
*   **기대 효과:** 빠른 파싱, UI 컴포넌트의 안정성 확보. 사용자에게 보여줄 친절한 안내 문구는 UI 컴포넌트(Frontend)가 담당합니다.

## 4. 프롬프트 캐싱 (Prompt Caching) 최적화
*   **설계 방향:** 불변하는 API 규칙(`ScenEdit_*`), CMO 전용 가이드라인, 그리고 해당 시나리오의 핵심 메타데이터는 프롬프트의 최상단에 배치하여 최신 LLM(Claude 3 등)의 프롬프트 캐싱 기능을 적극 활용하도록 설계합니다.
*   **기대 효과:** 동일 시나리오 내에서 여러 번 대화가 오갈 때 시스템 프롬프트 토큰 비용을 극적으로 낮출 수 있습니다.

## 5. 조기 되묻기 (Early Ask-Back / Fail Fast)
정보가 부족한 상태에서 AI가 추측성 코드를 길게 작성하는 것은 위험합니다.

*   **설계 방향:** AI가 목표 달성에 필수적인 CMO 컨텍스트(예: 대상 진영, 정확한 유닛 GUID, 무장 DBID 등)가 없다고 판단하면, **즉시 코드 생성을 중단하고 누락된 정보를 요청하는 짧은 상태(State)**로 전환(Early Ask-Back)해야 합니다.
*   **기대 효과:** 무의미한 Lua 생성 시도 차단, 토큰 낭비 방지, 사용자에게 명확한 가이던스 제공.