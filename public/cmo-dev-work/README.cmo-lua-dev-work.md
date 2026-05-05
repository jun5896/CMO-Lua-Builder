# cmo-lua-dev

Command: Modern Operations 내부 Lua 콘솔용 시나리오 스크립트 생성기.

## 빠른 시작 (CMO 콘솔)

```lua
dofile("C:/Users/dlwls/.antigravity/cmo-lua-dev-work/init.lua")
cmo.help()
cmo.find("F-35")
cmo.build("strike_alpha")    -- presets/strike_alpha.lua → output/strike_alpha.lua
```

## 폴더

| 폴더 | 역할 |
|------|------|
| `core/` | bootstrap, 경로/문자열/표/에러/로그 유틸 |
| `db/` | tracker, cache, component_index, validator, exporter |
| `render/` | 템플릿 엔진 + 헬퍼 + 공유 partials |
| `builders/` | config → 도메인별 스니펫 합성 (`build_scenario`) |
| `templates/` | `.tpl.lua` 템플릿 모음 (unit/mission/event/doctrine/loadout/weather/zone/kvstore/...) |
| `presets/` | 바로 빌드 가능한 시나리오 config 예시 |
| `samples/helpers/` | CMO 번들 스크립트에서 추출한 재사용 유틸 (RandomPosition 등) |
| `db_cache/` | DB 인덱스/컴포넌트 인덱스 + export 결과물 |
| `tools/` | DB 인덱스 PowerShell 헬퍼 + 구문 검사 |
| `output/` | 빌드 산출물 |
| `docs/` | architecture, api cheatsheet, 번들 분석 노트 |

## 핵심 설계

- **자동 루트 검출**: `init.lua` 가 `debug.getinfo` 로 자기 위치를 찾아냄. 폴더를 옮기거나 포크해도 PROJECT_ROOT 수정 불필요.
- **모듈 책임 분리**: core / db / render / builders / templates 5계층.
- **DBID 3중 검증**: ScenEdit_QueryDB → db_cache → 최신 `.db3` 기반 component_index 순. 기본값은 실패 시 빌드 중단이며, 임시 완화가 필요할 때만 `allow_invalid_dbids=true`를 사용.
- **공통 partials**: `errmsg_guard`, `rp_lookup`, `header` 가 템플릿에 인클루드되어 보일러플레이트 제거.
- **번들 패턴 통합**: 357개 번들 Lua 스크립트의 빈도 1-20위 API 모두 템플릿 또는 헬퍼로 커버.

자세한 내용은 [docs/architecture.md](docs/architecture.md), [docs/api_cheatsheet.md](docs/api_cheatsheet.md) 참고.

## DB 인덱스 갱신

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\update_db_index.ps1
powershell -ExecutionPolicy Bypass -File .\tools\update_component_index.ps1
```

`update_component_index.ps1`는 Python 표준 `sqlite3`로 CMO 설치 폴더의 최신 `DB3K_*.db3` / `CWDB_*.db3`를 직접 읽어 `db_cache/component_index.lua`를 갱신합니다.
