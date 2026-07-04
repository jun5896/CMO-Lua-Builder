# CMO Public Beta 변경 요약 (Build 1852 → 1892, 2026-04 ~ 2026-06)

프로젝트의 마지막 검증 기준(Build 1868, DB517, 2026-05)과 현재 설치본 사이의 공식 베타 변경분 중
이 리포(Lua/Event/Doctrine 작업)에 영향 있는 항목만 발췌한 다이제스트.

현재 로컬 설치 확인값 (2026-07-04, LuaHistory 헤더 실측):

```text
Bv1.10 Beta - Build 1892 / DB3K 517 + CWDB 517 (audit:cmo-db 동일 확인)
```

Build 1892 이후 공개 베타는 없음 (2026-07-04 포럼 확인 기준).

## 타임라인

| Build | 날짜 | 이 리포 관점의 핵심 |
|---|---|---|
| 1852 | 2026-04-22 | Lua: `side:contactsBy` 추가, `SE_AttackContact` 발사 예약시간 파라미터, `ScenEdit_SetDoctrine` ThreatMaxDist 수정, `SetScenarioMessageLogpath` 상대경로 지원. Doctrine 신규 옵션 4종(아래) |
| 1859 | 2026-04-30 | 성능/안정화 중심. Lua/Event 변경 없음 |
| 1868 | 2026-05-09 | **DB v517 지원** (프로젝트 마지막 검증 기준 빌드). 항공 미션 교전/윙맨/RTB 로직 수정 |
| 1876 | 2026-05-30 | 내부 결함으로 철회됨 — 건너뜀 |
| 1877 | 2026-06-02 | **Lua: `ScenEdit_CustomUI` 신규** (Special Message의 "raise pop up" 설정 제약 우회, 커스텀 UI 표시). 컴포넌트 피해 판정 전면 재작업, 잠수함 화물 작업 지원 |
| 1892 | 2026-06-26 | 해상 편대 에디터, Vector OSM 지도, 소노부이 재고 메커니즘. Lua Console Rate Limiter는 CMO-Civ 전용 (Steam 상용판 무관) |

## Doctrine 신규 옵션 (Build 1852)

AI 초안에서 doctrine을 다룰 때 존재를 알아야 하는 옵션들. **Lua 키 이름은 공식 Lua 문서/인게임에서
확인 전까지 추정 금지** — 이름을 지어내지 말고 사용자에게 Doctrine 창 확인을 요청할 것.

- AAW Rearward Fire: 발사 플랫폼에서 멀어지는 표적 드랍
- AAW WRA Qty: 살보 수량을 무기별이 아니라 총 할당 기준으로 계산 (다함정 살보 중첩 완화)
- AAW Guidance: 요격 불가능해지면 유도 포기
- Only specific targets: 타격 유닛이 비미션 표적 무시

## 이 리포에 대한 영향

- **API 분석기/게이트**: `ScenEdit_CustomUI`는 `ScenEdit_*` 패턴이라 analyzeLua API 추출과 unsafe 게이트에
  변경 불필요 (자동 인식/허용됨).
- **DB 캐시**: 설치본이 여전히 DB517이므로 `public/cmo-dev-work/db_cache` 및 DBID 참조 유효.
  향후 DB518+ 감지 시 `npm run refresh:cmo-assets` 재실행.
- **AI 브리지**: Build 1892에서 Lua-root `ScenEdit_RunScript` 로더, RegularTime 폴러(interval=0 ≈ 매초),
  KeyValue 가드 전부 인게임 검증 완료 — `docs/agent-ops/manual-cmo-workflow-smoke-result-2026-07-04.md` 참조.
- **Special Message 계열 템플릿**: 팝업 강제가 필요한 시나리오에서는 1877+의 `ScenEdit_CustomUI`가 대안.

## 출처

- Build 1852: https://forums.matrixgames.com/viewtopic.php?t=416771
- Build 1859: https://forums.matrixgames.com/viewtopic.php?t=416942
- Build 1868: https://forums.matrixgames.com/viewtopic.php?t=417070
- Build 1876 (철회): https://forums.matrixgames.com/viewtopic.php?t=417336
- Build 1877: https://forums.matrixgames.com/viewtopic.php?t=417367
- Build 1892: https://forums.matrixgames.com/viewtopic.php?t=417635
