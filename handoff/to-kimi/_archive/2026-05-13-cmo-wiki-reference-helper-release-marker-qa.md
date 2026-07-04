# Kimi QA 보고서 - CMO Wiki / Lua Reference Helper Release Marker

날짜: 2026-05-13
대상: `d09b0d7 Mark CMO wiki reference helper release in README`
제안 릴리스 태그: `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`

## 타겟 커밋

```text
d09b0d7 Mark CMO wiki reference helper release in README
```

범위: `README.md`만 변경 (8 insertions, 3 deletions)

미변경 영역: `src/**`, `server/**`, `tools/**`, `public/**`, `docs/**`, `handoff/**`, `package.json`, `package-lock.json` — 모두 변경 없음

## 파이프라인 결과

```text
git status --short --branch: main...origin/main [ahead 13]
git show --stat --oneline d09b0d7: README.md | 11 ++++++++---
git show --name-only --oneline d09b0d7: README.md
npm run verify:release: PASS (17단계 전체 확장 체인)
  1. audit:scenario-sidecars: 1899 인덱스 / 3799 보호 / 24 고아 / 5.6 MB
  2. verify:scenario-loader: 1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues
  3. lint: PASS
  4. build: PASS
  5. smoke:ai-workflow-state: PASS
  6. smoke:ai-follow-up-needs: PASS
  7. smoke:ai-confirmed-context: PASS
  8. smoke:ai-adapter-client-sidecar: PASS (B2)
  9. smoke:cmo-log-feedback: PASS (B3)
  10. smoke:cmo-log-feedback-endpoint: PASS (B3)
  11. smoke:ai-adapter-client-log-feedback: PASS (B3)
  12. smoke:cmo-state-snapshot: PASS (B4)
  13. smoke:cmo-state-snapshot-endpoint: PASS (B4)
  14. smoke:ai-adapter-client-state-snapshot: PASS (B4)
  15. smoke:cmo-wiki-code-assistant: PASS (신규)
  16. smoke:ai-client-parser: PASS
  17. smoke:ai-adapter: PASS — Bearer / sk-key 누출 없음
```

## 번들 / 청크 기준선

```text
Main JS: 253.81 kB (< 400 kB)
Main CSS: 59.45 kB (< 60 kB)
aiContextPruning: 8.56 kB (< 9 kB)
CmoWikiPanel: 7.59 kB JS / 3.61 kB CSS
LuaEditorReferenceHelper: 2.12 kB JS / 0.84 kB CSS
LuaAssistant: 136.86 kB JS
```

시나리오 / 사이드카 기준선:

```text
Scenario loader: 1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues
Sidecar audit: 1899 in index / 3799 protected / 24 orphans / about 5.6 MB / dry-run only
```

## 정적 체크포인트 결과

| # | 항목 | 결과 | 증거 |
|---|------|------|------|
| 1 | 타겟 커밋이 존재하고 메시지가 `Mark CMO wiki reference helper release in README` | PASS | `git show -s --oneline` |
| 2 | 타겟 커밋이 `README.md`만 변경 | PASS | `git show --name-only` |
| 3 | `package.json`이 타겟 커밋에서 변경 없음 | PASS | diff 출력 없음 |
| 4 | `package-lock.json`이 타겟 커밋에서 변경 없음 | PASS | diff 출력 없음 |
| 5 | `src/**`, `server/**`, `tools/**`, `public/**`, `docs/**`, `handoff/**`에 드리프트 없음 | PASS | diff 출력 없음 |
| 6 | README 현재 공개 릴리스 줄이 `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper` 참조 | PASS | README diff 확인 |
| 7 | README 수동 분할 파이프라인에 `npm run smoke:cmo-wiki-code-assistant` 포함 | PASS | README diff 확인 |
| 8 | README 번들 기준선이 Main JS `253.81 kB` 기록 | PASS | README diff 확인 |
| 9 | README 번들 기준선이 Main CSS `59.45 kB` 기록 | PASS | README diff 확인 |
| 10 | README 번들 기준선이 `aiContextPruning` `8.56 kB` 기록 | PASS | README diff 확인 |
| 11 | README가 여전히 Template Inspector annotations `51 / 51` 기록 | PASS | README diff 확인 |
| 12 | README가 CMO Wiki / Lua Reference Helper 스모크 기준선 기록 | PASS | README diff 확인 |
| 13 | README가 `CmoWikiPanel` lazy chunk `7.59 kB JS / 3.61 kB CSS` 기록 | PASS | README diff 확인 |
| 14 | README가 `LuaEditorReferenceHelper` lazy chunk `2.12 kB JS / 0.84 kB CSS` 기록 | PASS | README diff 확인 |
| 15 | README가 `LuaAssistant` lazy chunk `136.86 kB JS` 기록 | PASS | README diff 확인 |
| 16 | 기존 B2 RunScript Sidecar Writer 기준선이 여전히 문서화됨 | PASS | README diff 확인 (유지) |
| 17 | 기존 B3 Log Feedback Loop 기준선이 여전히 문서화됨 | PASS | README diff 확인 (유지) |
| 18 | 기존 B4 State Snapshot Import 기준선이 여전히 문서화됨 | PASS | README diff 확인 (유지) |
| 19 | `npm run verify:release` 통과 | PASS | 17단계 전체 PASS |
| 20 | Main JS 400 kB 미만 | PASS | 253.81 kB |
| 21 | Main CSS 60 kB 미만 | PASS | 59.45 kB |
| 22 | `aiContextPruning` 9 kB 미만 | PASS | 8.56 kB |
| 23 | AI adapter smoke가 raw Bearer / Authorization / sk- 누출 없음 보고 | PASS | adapter smoke: "no Bearer / sk-key fingerprint" |
| 24 | `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper` 태그 아직 없음 | PASS | `git tag -l` 출력 없음 |
| 25 | 해당 태그의 GitHub Release 아직 없음 | PASS | `gh release view` — "release not found" |

## 회귀 평결

- B4 릴리스가 README에서 완전히 제거되었는가? — 아니오. B4 스모크 기준선은 여전히 기록됨 (이전 릴리스로).
- CMO Wiki 릴리스가 자동 AI send를 암시하는가? — 아니오.
- CMO Wiki 릴리스가 자동 CMO 실행을 암시하는가? — 아니오.
- CMO Wiki 릴리스가 실시간 리드백을 암시하는가? — 아니오.
- 제품 소스가 변경되었는가? — 아니오. README만 변경.
- 번들 기준선이 이전 B4 릴리스와 다른가? — 예. Main JS가 391.65 kB에서 253.81 kB로 감소 (LuaAssistant 레이지 로드로 인한 개선).

## 최종 평결

```text
정적 체크포인트: 25 / 25 PASS
파이프라인: verify:release 17단계 전체 PASS
번들: Main JS 253.81 kB / Main CSS 59.45 kB / aiContextPruning 8.56 kB
태그: 미생성 확인
드리프트: src/server/tools/public/docs/handoff/package/package-lock 변경 없음
회귀: 없음
평결: APPROVED
```

CMO Wiki / Lua Reference Helper 릴리스 마커는 README public release line을 새 태그로 업데이트하고 `verify:release`를 17단계로 확장하며, B2/B3/B4 스모크 기준선을 모두 보존합니다. 새로운 번들 기준선(LuaAssistant 레이지 로드로 인한 Main JS 감소)과 CMO Wiki / Lua Reference Helper lazy chunk 기준선이 추가되었습니다. 태그 및 GitHub Release는 이 마커 커밋에서 생성되지 않았으며 다음 게이트에서 처리할 수 있습니다.
