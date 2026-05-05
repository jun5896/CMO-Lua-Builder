# Template Inspector Guide Seed

> **상태:** v0.1.0 시드 — 10개 주요 카테고리, 대표 템플릿, 주요 API, 안전한 패턴, CMO UI 사전 조건을 다룹니다. 실제 시나리오 Lua를 더 수집하면 점진적으로 확장합니다.

## 이 가이드 사용법

1. **자동화 목표를 확인하라** (예: "패트롤 임무를 교대로 활성화/비활성화" → 임무 제어).
2. 해당 카테고리 아래 **대표 템플릿**을 `public/cmo-dev-work/templates/`에서 열어라.
3. **CMO UI 사전 조건**을 확인하라 — 시나리오에 이 조건이 없으면 Lua는 조용히 실패하거나 CMO 엔진 에러를 낸다.
4. **안전한 코딩 패턴**을 복사하고 상황에 맞게 수정하라. DBID나 GUID를 임의로 만들지 마라.
5. **CMO에서 검증하라** — "특수행동(Special Action) → Run Lua"로 실행하거나, 이벤트 행동에 스크립트를 붙여서 테스트하라.

---

## 1. 임무 제어 (Mission Control)

**목표:** Patrol, Strike, Support, Ferry, Mine 등의 임무를 생성·수정하거나 유닛을 배정한다.

**대표 템플릿:**
- `mission_patrol.tpl.lua`
- `mission_strike.tpl.lua`
- `mission_support.tpl.lua`
- `mission_generic.tpl.lua`

**주요 API:**
- `ScenEdit_AddMission(sideName, missionName, missionType, optionsTable)`
- `ScenEdit_SetMission(sideName, missionName, optionsTable)`
- `ScenEdit_AssignUnitToMission(unitNameOrGUID, missionName)`
- `ScenEdit_RemoveUnitFromMission(unitNameOrGUID, missionName)`
- `VP_GetSide(sideName)` (낮은 수준의 introspection용)

**CMO UI 사전 조건:**
- 대상 **진영(Side)**이 시나리오에 미리 존재해야 한다.
- 기준점을 사용하는 임무를 생성할 때, 해당 기준점은 **그 진영 아래**에 있어야 한다.
- XML에서는 Patrol/Strike/SupportMission 등 다형성 태그를 사용한다. 평범한 `<Mission>` 노드는 존재하지 않는다.

**안전한 코딩 패턴:**
```lua
local side = 'Iran'
local msn  = 'Patrol-Alpha'
-- 1. 방어적 존재 확인
local existing = ScenEdit_GetMission(side, msn)
if not existing then
  ScenEdit_AddMission(side, msn, 'patrol', {type='area'})
end
-- 2. 멱등 배정
ScenEdit_AssignUnitToMission('Unit-1', msn)
```

**이벤트 연동 힌트:**
- `event_missions_toggle.tpl.lua`를 사용해 타이머나 트리거로 임무 활성화를 뒤집어라.
- 트리거가 발사할 때마다 임무를 새로 만들지 마라 — 존재 확인으로 보호하라.

**위험 노트:**
- `missionType` 문자열은 대소문자를 구분하며 엔진이 검증한다 (`'patrol'`, `'strike'`, `'support'` 등).
- 유닛의 진영을 먼저 확인하지 않고 임무에 배정하면 교차 진영 배정 에러가 난다.

---

## 2. 유닛 생성/편집 (Unit Spawn/Edit)

**목표:** 시나리오 실행 중에 동적으로 유닛을 추가·수정·제거한다.

**대표 템플릿:**
- `unit_spawn.tpl.lua`
- `unit_spawn_random.tpl.lua`
- `loadout_set.tpl.lua`
- `loadout_scramble.tpl.lua`

**주요 API:**
- `ScenEdit_AddUnit({type='Ship', unitname='U-1', side='Iran', dbid=...})`
- `ScenEdit_SetUnit({unitname='U-1', heading=90})`
- `ScenEdit_GetUnit({name='U-1'})`
- `ScenEdit_DeleteUnit({name='U-1'})`
- `ScenEdit_SetLoadout({unitname='U-1', loadoutid=...})`

**CMO UI 사전 조건:**
- **진영(Side)**이 존재해야 한다.
- **DBID**는 CMO 데이터베이스에 실제로 있는 값이어야 한다. 임의로 만들지 마라.
- 생성 좌표는 시나리오 맵 범위 내의 유효한 경위도여야 한다.

**안전한 코딩 패턴:**
```lua
local u = ScenEdit_GetUnit({name='Reinforcement-1'})
if not u then
  ScenEdit_AddUnit({
    type='Ship',
    unitname='Reinforcement-1',
    side='Iran',
    dbid=1572, -- DB 뷰어에서 반드시 확인
    latitude=25.5,
    longitude=57.2
  })
end
```

**이벤트 연동 힌트:**
- 생성 이벤트는 보통 `ScenLoaded`나 `RegularTime` 트리거에 붙인다.
- 증파 웨이브를 다룰 때는 KV 저장소 카운터(`StoreIntegerValue`)로 웨이브 번호를 추적하라.

**위험 노트:**
- 유닛을 빠르게 많이 생성하면 시뮬레이션 성능이 저하된다. 10기 이상이면 여러 프레임에 걸쳐 배치 생성하라.
- `heading`은 도(degree) 단위이며, 0 = 북쪽, 시계 방향이다.

---

## 3. 기준점/구역 (Reference Points/Zones)

**목표:** 기준점과 금지/비항해 구역을 추가·이동·조회한다.

**대표 템플릿:**
- `reference_point_add.tpl.lua`
- `zone_add.tpl.lua`
- `event_unit_enters_area.tpl.lua`

**주요 API:**
- `ScenEdit_AddReferencePoint({side='Iran', name='RP-A', lat=..., lon=...})`
- `ScenEdit_GetReferencePoint({side='Iran', name='RP-A'})`
- `ScenEdit_SetReferencePoint({side='Iran', name='RP-A', lat=..., lon=...})`
- `ScenEdit_DeleteReferencePoint({side='Iran', name='RP-A'})`

**CMO UI 사전 조건:**
- 기준점은 CMO XML에서 **진영(Side)에 소속**된다 (`Sides/Side/ReferencePoints`).
- 구역 다각형 꼭짓점은 항해 기준점과 별개다 (`NoNavZone/Area/RPoint`). 둘을 혼동하지 마라.
- 이벤트 트리거용 구역(예: "Unit Enters Area")은 이벤트가 무장되기 전에 정의되어 있어야 한다.

**안전한 코딩 패턴:**
```lua
local function ensureRP(side, name, lat, lon)
  local rp = ScenEdit_GetReferencePoint({side=side, name=name})
  if not rp then
    ScenEdit_AddReferencePoint({side=side, name=name, lat=lat, lon=lon})
  end
end
ensureRP('Iran', 'Entry-Gate', 25.5, 57.2)
```

**이벤트 연동 힌트:**
- 동적 기준점은 FEBA 표시나 후퇴선 표시에 유용하다. `RegularTime` 루프에서 업데이트하라.

**위험 노트:**
- 같은 진영 아래에서 기준점 이름을 중복 사용하면 정의되지 않은 동작이 발생한다. 항상 존재를 확인하라.
- 활성 임무에 묶인 기준점을 삭제하면 임무 로직이 깨질 수 있다.

---

## 4. 접촉/탐지 (Contacts/Detection)

**목표:** 탐지 이벤트에 반응하거나 접촉 가시성/방사통제(EMCON)를 조작한다.

**대표 템플릿:**
- `event_unit_detected.tpl.lua`
- `event_contact_emcon.tpl.lua`
- `event_unit_destroyed.tpl.lua`

**주요 API:**
- `ScenEdit_UnitX()` (이벤트 스코프 안의 문맥 유닛)
- `ScenEdit_GetContact({side='Iran', name='Contact-1'})`
- `ScenEdit_SetEMCON({side='Iran', name='Contact-1', ...})`

**CMO UI 사전 조건:**
- 탐지 이벤트는 시나리오 설정에서 탐지자/피탐지자 관계가 이미 성립되어야 트리거된다.
- "Unit Detected" 트리거는 접촉 생성 시마다 발사된다. 스크립트가 무거우면 디바운스(debounce)를 고려하라.

**안전한 코딩 패턴:**
```lua
local u = ScenEdit_UnitX() -- 이벤트 행동 내부에서만 유효하다
if u then
  local contact = ScenEdit_GetContact({side='Iran', name=u.name})
  if contact then
    -- 탐지에 반응
  end
end
```

**이벤트 연동 힌트:**
- 접촉 스크립트를 "Unit Detected" 트리거에 붙여라.
- 격파 시 점수 갱신에는 `event_unit_destroyed.tpl.lua`를 사용하라.

**위험 노트:**
- `ScenEdit_UnitX()`는 이벤트 문맥 밖에서 `nil`을 반환한다. 콘솔이나 단독 실행에서 절대 호출하지 마라.
- 접촉 이름은 일시적이다. 지속적인 로직이 필요하면 GUID를 우선적으로 사용하라.

---

## 5. 교전수칙/방사통제 (Doctrine/EMCON)

**목표:** 교전수칙(ROE), 무기 사용, 방사통제를 변경한다.

**대표 템플릿:**
- `doctrine_emcon.tpl.lua`
- `doctrine_set.tpl.lua`

**주요 API:**
- `ScenEdit_SetDoctrine({side='Iran', name='Group-A', doctrine='weapon_state', option=1})`
- `ScenEdit_SetEMCON({side='Iran', name='Group-A', emcon='Radar=Active'})`

**CMO UI 사전 조건:**
- 대상 유닛/그룹/임무가 존재해야 한다.
- 교전수칙 설정은 진영(Side), 그룹, 유닛 수준에서 적용할 수 있다. 좁은 범위가 넓은 범위를 덮어쓴다.

**안전한 코딩 패턴:**
```lua
local function setGroupDoctrine(side, groupName)
  local g = ScenEdit_GetUnit({side=side, name=groupName})
  if g then
    ScenEdit_SetDoctrine({side=side, name=groupName, doctrine='weapon_state', option=1})
  end
end
```

**이벤트 연동 힌트:**
- 에스컬레이션 이벤트(`event_escalation.tpl.lua`)는 종종 교전수칙 변경과 짝을 이룬다.
- KV 플래그를 사용해 교전수칙 변경이 한 번만 일어나도록 보장하라.

**위험 노트:**
- EMCON 문자열은 파서에 민감하다. CMO UI나 공식 문서의 정확한 토큰을 복사해서 사용하라.
- 무기 상태 코드는 플랫폼별로 다르다. 정확한 DB 엔트리에서 테스트하라.

---

## 6. 기상 (Weather)

**목표:** 해상도, 풍속, 구름, 기온 등 시나리오 기상을 동적으로 수정한다.

**대표 템플릿:**
- `weather_random.tpl.lua`
- `event_dynamic_weather.tpl.lua`
- `event_random_start_weather.tpl.lua`

**주요 API:**
- `ScenEdit_SetWeather({sea_state=4, wind_speed=15, wind_dir=270})`
- `World_GetLatitude()` / `World_GetLongitude()` (지리 기반 기상용)

**CMO UI 사전 조건:**
- 기상은 전역 설정이다. 진영 확인이 필요 없다.
- 일부 센서(예: IR, 가시광선)는 기상에 민감하다. 플레이어에게 부작용을 문서화하라.

**안전한 코딩 패턴:**
```lua
math.randomseed(os.time())
ScenEdit_SetWeather({
  sea_state = math.random(0, 6),
  wind_speed = math.random(0, 30),
  wind_dir = math.random(0, 359)
})
```

**이벤트 연동 힌트:**
- 초기 무작위화는 `ScenLoaded`에, 점진적 악화는 `RegularTime`에 붙여라.

**위험 노트:**
- 기상을 너무 빠르게 전환하면 센서 모델링이 혼란스러워진다. 변경 간격을 5분 이상 유지하라.

---

## 7. 점수/승리조건 (Scoring/Victory)

**목표:** 점수를 갱신하고, 승리 메시지를 표시하거나 시나리오를 종료한다.

**대표 템플릿:**
- `event_dbid_score.tpl.lua`
- `event_victory_cond.tpl.lua`
- `event_escalation.tpl.lua`

**주요 API:**
- `ChangeScore(side, delta, reasonText)`
- `ScenEdit_SpecialMessage(side, messageText, messageType)`
- `ScenEdit_EndScenario()`

**CMO UI 사전 조건:**
- `ChangeScore`는 지정된 진영의 점수판을 즉시 변경한다.
- 승리 조건은 보통 `RegularTime` 이벤트의 Lua 조건으로 검사한다.

**안전한 코딩 패턴:**
```lua
local threshold = 500
local score = VP_GetSide('Iran').score
if score >= threshold then
  ChangeScore('Iran', 0, 'Victory threshold reached')
  ScenEdit_SpecialMessage('All', 'Iran achieves victory!', 'score')
  ScenEdit_EndScenario()
end
```

**이벤트 연동 힌트:**
- 격파 이벤트(`event_unit_destroyed.tpl.lua`)에서 흔히 `ChangeScore`를 호출한다.
- 조기 승리 선언을 방지하려면 Lua 조건을 사용하라.

**위험 노트:**
- `ScenEdit_EndScenario()`는 되돌릴 수 없다. 명시적 조건 검사로 보호하라.
- 점수 사유는 로그에 표시된다. UI 가독성을 위해 50자 이내로 짧게 유지하라.

---

## 8. 이벤트 자동화 (Event Automation)

**목표:** CMO 이벤트(트리거, 조건, 행동)를 프로그래밍 방식으로 생성·활성화·비활성화·조회한다.

**대표 템플릿:**
- `event_simple.tpl.lua`
- `event_complex.tpl.lua`
- `event_regular_time.tpl.lua`
- `event_scen_loaded.tpl.lua`
- `event_missions_toggle.tpl.lua`
- `event_unit_enters_area.tpl.lua`
- `event_unit_destroyed.tpl.lua`
- `event_unit_damaged.tpl.lua`
- `event_split_merge.tpl.lua`
- `event_teleport.tpl.lua`
- `event_scramble.tpl.lua`
- `event_iads_ambush.tpl.lua`
- `event_ambient_traffic.tpl.lua`
- `event_cargo_drop.tpl.lua`
- `event_csar.tpl.lua`
- `event_kv_flag.tpl.lua`
- `event_logistics.tpl.lua`
- `event_radio_message.tpl.lua`

**주요 API:**
- `ScenEdit_GetEvent(eventName)`
- `ScenEdit_SetEvent(eventName, {mode='toggle', isActive=true})`
- `ScenEdit_AddEvent(eventName, {...})` (지원 범위가 제한적이다. UI 생성 + Lua 토글을 우선 사용하라)
- `Tool_DumpEvents()` (디버그 전용)

**CMO UI 사전 조건:**
- CMO 이벤트는 **트리거 → 조건 → 행동**으로 구성된다.
- Lua 스크립트는 일반적으로 행동(Action)으로 삽입되며, 트리거(Trigger)로 사용하지 않는다.
- 이벤트가 구역이나 유닛을 참조하면, 이벤트가 무장되기 전에 해당 객체가 존재해야 한다.

**안전한 코딩 패턴:**
```lua
local ev = ScenEdit_GetEvent('Wave-2-Spawner')
if ev and not ev.isActive then
  ScenEdit_SetEvent('Wave-2-Spawner', {mode='toggle', isActive=true})
end
```

**이벤트 연동 힌트:**
- 복잡한 시나리오는 KV 플래그(`StoreBooleanValue`)로 이벤트 순서를 제어한다.
- `event_kv_flag.tpl.lua`는 사용자 부울로 이벤트를 게이팅하는 방법을 보여준다.

**위험 노트:**
- `ScenEdit_AddEvent`는 CMO에서 스키마 지원이 제한적이다. 이벤트는 UI에서 생성하고 Lua로 토글하는 것이 더 안전하다.
- 재귀적 이벤트 트리거(이벤트 A가 이벤트 B를 활성화하고, 이벤트 B가 다시 이벤트 A를 발사)는 무한 루프를 일으킬 수 있다. 플래그로 사이클을 끊어라.

---

## 9. 화물/물류 (Cargo/Logistics)

**목표:** 화물 적재, 수송 임무, 물류 체인을 관리한다.

**대표 템플릿:**
- `mission_cargo.tpl.lua`
- `mission_ferry.tpl.lua`
- `event_cargo_drop.tpl.lua`
- `event_logistics.tpl.lua`

**주요 API:**
- `ScenEdit_AddCargo({unitname='C-130', cargo='Supplies', amount=10})`
- `ScenEdit_SetCargo({unitname='C-130', cargo='Supplies', amount=20})`
- `ScenEdit_UnloadCargo({unitname='C-130'})`

**CMO UI 사전 조건:**
- 수송 유닛은 DB 항목에 화물 용량이 있어야 한다.
- 수송(Ferry) 임무는 유효한 탑승/하차 지점(공항, 항구, 또는 기준점)이 필요하다.

**안전한 코딩 패턴:**
```lua
local transport = ScenEdit_GetUnit({name='Logi-Truck-1'})
if transport then
  ScenEdit_AddCargo({unitname='Logi-Truck-1', cargo='Ammo', amount=5})
end
```

**이벤트 연동 힌트:**
- 화물 투하는 보통 보급 구역 근처 "Unit Enters Area"에서 트리거된다.
- 보급 부대 모델링에는 `event_logistics.tpl.lua`를 사용하라.

**위험 노트:**
- 화물 중량/용량 제한은 DB 수준이다. 초과하면 조용히 상한선으로 잘린다.
- 유효하지 않은 위치(예: 트럭이 깊은 바다 위)에서 하역하면 조용히 실패한다.

---

## 10. 메시지/브리핑 (Messaging/Briefing)

**목표:** 시나리오 내 메시지를 전송하고, 진영 간 관계를 갱신하거나 브리핑을 업데이트한다.

**대표 템플릿:**
- `event_radio_message.tpl.lua`
- `side_posture.tpl.lua`
- `event_escalation.tpl.lua`

**주요 API:**
- `ScenEdit_SpecialMessage(side, text, type)`
- `ScenEdit_AddMessage(side, text)`
- `ScenEdit_SetSidePosture(sideA, sideB, postureCode)` — postureCode: 0=우호, 1=중립, 2=비우호, 3=적대

**CMO UI 사전 조건:**
- `ScenEdit_SpecialMessage`는 특정 진영이나 `'All'`(전체)을 대상으로 한다.
- 관계 변경은 AI 행동에 즉각 영향을 준다. 관계가 악화되면 플레이어에게 경고하라.

**안전한 코딩 패턴:**
```lua
ScenEdit_SpecialMessage('Iran', 'Command: Shift to DEFCON 2', 'warning')
ScenEdit_SetSidePosture('Iran', 'USA', 2) -- 비우호
```

**이벤트 연동 힌트:**
- 무전 메시지는 서사적 리듬을 위해 타이밍이나 트리거 이벤트에 붙인다.
- 진영 관계 변경은 자동 임무 중단으로 이어질 수 있다. AI 반응을 테스트하라.

**위험 노트:**
- 메시지 유형 문자열(`'warning'`, `'score'`, `'info'`)은 UI 색상에 영향을 준다. 일관되게 사용하라.
- 관계 코드 정수는 0~3이어야 한다. 범위를 벗어나면 무시된다.

---

## 부록: 빠른 검색표

| 목표 | 주요 카테고리 | 핵심 API | 템플릿 파일 |
|------|-------------|---------|------------|
| 패트롤 임무 생성 | 임무 제어 | `ScenEdit_AddMission` | `mission_patrol.tpl.lua` |
| 증파 유닛 생성 | 유닛 생성/편집 | `ScenEdit_AddUnit` | `unit_spawn.tpl.lua` |
| 기준점으로 구역 표시 | 기준점/구역 | `ScenEdit_AddReferencePoint` | `reference_point_add.tpl.lua` |
| 탐지 반응 | 접촉/탐지 | `ScenEdit_UnitX` | `event_unit_detected.tpl.lua` |
| 교전규칙 변경 | 교전수칙/방사통제 | `ScenEdit_SetDoctrine` | `doctrine_set.tpl.lua` |
| 기상 무작위화 | 기상 | `ScenEdit_SetWeather` | `weather_random.tpl.lua` |
| 격파 점수 부여 | 점수/승리조건 | `ChangeScore` | `event_dbid_score.tpl.lua` |
| 이벤트 켜기/끄기 | 이벤트 자동화 | `ScenEdit_SetEvent` | `event_missions_toggle.tpl.lua` |
| 화물 적재 | 화물/물류 | `ScenEdit_AddCargo` | `mission_cargo.tpl.lua` |
| 브리핑 메시지 전송 | 메시지/브리핑 | `ScenEdit_SpecialMessage` | `event_radio_message.tpl.lua` |

---

## 적용 규칙 (Guardrails)

1. **DBID나 GUID를 절대 임의로 만들지 마라.** CMO DB 뷰어나 기존 시나리오 XML에서 가져와라.
2. **가능하면 CMO가 생성한 이름을 우선 사용하라.** 하드코딩된 문자열보다 `ScenEdit_GetUnit`으로 동적으로 이름을 해결하라.
3. **Add/Set/Delete 전에 항상 존재를 확인하라.** 스크립트가 멱등적이고 재실행에 안전하게 만들어라.
4. **큰 시나리오에 배포하기 전에 샌드박스 시나리오에서 검증하라.** `cmo-scenario-mini.xml` 등 작은 파일을 사용하라.
5. **Lua 행동은 짧게 유지하라.** (행동당 100줄 이하). 복잡한 로직은 여러 이벤트 행동으로 쪼개거나 외부 스크립트를 `dofile`로 불러와라.
