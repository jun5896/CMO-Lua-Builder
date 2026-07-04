# Kimi QA 보고서 - CMO Wiki / Lua Reference Helper Release Tag

날짜: 2026-05-13
대상 릴리스: `release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper`
태그된 커밋: `d09b0d7 Mark CMO wiki reference helper release in README`

## 태그 / 커밋 매핑

```text
git rev-list -n 1 release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper
→ d09b0d7ebebbefe0896f28dab4cc954b6a1470ed

git show -s --oneline release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper
→ tag release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper
  CMO Lua Builder CMO Wiki Reference Helper
  d09b0d7 Mark CMO wiki reference helper release in README
```

태그가 정확히 릴리스 마커 커밋 `d09b0d7`를 가리킵니다.

## GitHub Release 메타데이터

```json
{
  "tagName": "release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper",
  "name": "CMO Lua Builder CMO Wiki Reference Helper",
  "isDraft": false,
  "isPrerelease": false,
  "url": "https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper"
}
```

- **제목:** `CMO Lua Builder CMO Wiki Reference Helper` — 지시어 기대값과 일치.
- **Draft:** `false` — 확인.
- **Prerelease:** `false` — 확인.

## 릴리스 노트 커버리지

릴리스 노트(body)에서 다음 항목을 모두 확인했습니다:

**Highlights:**
- CMO Lua encyclopedia built from 51 / 51 template annotation baseline — 포함.
- Deterministic search and quick filters — 포함.
- Lua editor reference helper — 포함.
- Text-only AI chat drafts, user must review and send manually — 포함.
- Shared wiki utility helpers with Template Library — 포함.

**Safety Boundaries:**
- no automatic AI send — 포함.
- no automatic CMO execution — 포함.
- no CMO file writes / deletes / polling / watcher / live-state claim — 포함.
- no browser-provided filesystem roots — 포함.
- no backend endpoint changes — 포함.
- no dependency or lockfile drift — 포함.
- manual prompt-copy fallback remains — 포함.
- `aiParsedResponse.isPasteReady` gate remains — 포함.
- CMO engine verification remains required — 포함.

**Verification:**
- `npm run verify:release` passed the 17-step chain — 포함.
- sidecar audit baseline: `1899` in index, `3799` protected, `24` orphans / about `5.6 MB` — 포함.
- scenario loader baseline: `1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues` — 포함.
- B2 RunScript sidecar client smoke PASS — 포함.
- B3 log feedback smokes PASS — 포함.
- B4 state snapshot smokes PASS — 포함.
- CMO Wiki / Lua Reference Helper smoke PASS — 포함.
- AI client parser smoke PASS — 포함.
- AI adapter smoke PASS, no raw Bearer / Authorization / sk- leakage — 포함.

**Bundle Baseline:**
- Main JS `253.81 kB` — 포함.
- Main CSS `59.45 kB` — 포함.
- `aiContextPruning` `8.56 kB` — 포함.
- `CmoWikiPanel` `7.59 kB JS / 3.61 kB CSS` — 포함.
- `LuaEditorReferenceHelper` `2.12 kB JS / 0.84 kB CSS` — 포함.
- `LuaAssistant` `136.86 kB JS` — 포함.

**QA Evidence:**
- CMO Wiki / Lua Reference Helper QA: `38 / 38 PASS` — 포함.
- Release marker QA: `25 / 25 PASS` — 포함.
- Claude architecture review: APPROVED with refinements — 포함.
- Gemini UX review: APPROVED WITH CHANGES — 포함.

## 파이프라인 결과

```text
git status --short --branch: main...origin/main, 작업 트리 clean
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
CmoWikiPanel lazy JS: 7.59 kB / CSS: 3.61 kB
LuaEditorReferenceHelper lazy JS: 2.12 kB / CSS: 0.84 kB
LuaAssistant lazy JS: 136.86 kB
```

## 정적 체크포인트 결과

| # | 항목 | 결과 |
|---|------|------|
| 1 | 릴리스 태그 존재 | PASS |
| 2 | 태그가 `d09b0d7` 가리킴 | PASS |
| 3 | 태그된 커밋 메시지가 `Mark CMO wiki reference helper release in README` | PASS |
| 4 | GitHub Release 제목이 `CMO Lua Builder CMO Wiki Reference Helper` | PASS |
| 5 | GitHub Release가 draft 아님 | PASS |
| 6 | GitHub Release가 prerelease 아님 | PASS |
| 7 | 릴리스 노트가 CMO Lua encyclopedia 언급 | PASS |
| 8 | 릴리스 노트가 51 / 51 template annotation baseline 언급 | PASS |
| 9 | 릴리스 노트가 deterministic search / quick filters 언급 | PASS |
| 10 | 릴리스 노트가 Lua editor reference helper 언급 | PASS |
| 11 | 릴리스 노트가 text-only AI chat drafts 언급 | PASS |
| 12 | 릴리스 노트가 no automatic AI send 언급 | PASS |
| 13 | 릴리스 노트가 no automatic CMO execution 언급 | PASS |
| 14 | 릴리스 노트가 no CMO file writes/deletes/polling/watcher/live-state claim 언급 | PASS |
| 15 | 릴리스 노트가 no backend endpoint changes 언급 | PASS |
| 16 | 릴리스 노트가 no dependency or lockfile drift 언급 | PASS |
| 17 | 릴리스 노트가 CMO engine verification remains required 언급 | PASS |
| 18 | 릴리스 노트가 `npm run verify:release` PASS / 17-step verification chain 언급 | PASS |
| 19 | 릴리스 노트가 sidecar audit baseline 언급 | PASS |
| 20 | 릴리스 노트가 scenario loader baseline 언급 | PASS |
| 21 | 릴리스 노트가 `smoke:cmo-wiki-code-assistant` PASS 언급 | PASS |
| 22 | 릴리스 노트가 AI adapter no raw Bearer/Authorization/sk- leakage 언급 | PASS |
| 23 | 릴리스 노트가 Main JS `253.81 kB` 언급 | PASS |
| 24 | 릴리스 노트가 Main CSS `59.45 kB` 언급 | PASS |
| 25 | 릴리스 노트가 `aiContextPruning` `8.56 kB` 언급 | PASS |
| 26 | 릴리스 노트가 CmoWikiPanel lazy chunk `7.59 kB JS / 3.61 kB CSS` 언급 | PASS |
| 27 | 릴리스 노트가 LuaEditorReferenceHelper lazy chunk `2.12 kB JS / 0.84 kB CSS` 언급 | PASS |
| 28 | 릴리스 노트가 CMO Wiki QA `38 / 38 PASS` 언급 | PASS |
| 29 | 릴리스 노트가 release marker QA `25 / 25 PASS` 언급 | PASS |
| 30 | README 현재 공개 릴리스 줄이 해당 태그 참조 | PASS (release marker QA에서 확인) |
| 31 | `npm run verify:release` 통과 | PASS |
| 32 | Main JS 400 kB 미만 | PASS (253.81 kB) |
| 33 | Main CSS 60 kB 미만 | PASS (59.45 kB) |
| 34 | `aiContextPruning` 9 kB 미만 | PASS (8.56 kB) |
| 35 | AI adapter smoke가 raw Bearer / Authorization / sk- 누출 없음 보고 | PASS |

## 회귀 평결

- 태그가 잘못된 커밋을 가리키는가? — 아니오. `d09b0d7` 확인.
- GitHub Release가 draft 또는 prerelease로 생성되었는가? — 아니오. 둘 다 `false`.
- 릴리스 노트에 안전 경계가 누락되었는가? — 아니오. 9개 경계 전부 포함.
- B2/B3/B4 스모크 기준선이 릴리스 노트에서 누락되었는가? — 아니오. 모두 포함.
- QA 증거 숫자가 실제와 다른가? — 아니오. CMO Wiki 38/38, release marker 25/25 — 모두 일치.
- 번들 기준선이 실제와 다른가? — 아니오. 모든 숫자 일치.

## 최종 평결

```text
정적 체크포인트: 35 / 35 PASS
파이프라인: verify:release 17단계 전체 PASS
번들: Main JS 253.81 kB / Main CSS 59.45 kB / aiContextPruning 8.56 kB
태그: release-2026-05-13-cmo-lua-builder-cmo-wiki-reference-helper → d09b0d7
GitHub Release: CMO Lua Builder CMO Wiki Reference Helper (draft=false, prerelease=false)
드리프트: 없음 (git status clean)
회귀: 없음
평결: APPROVED - CMO Wiki / Lua Reference Helper release tag holds.
```

CMO Wiki / Lua Reference Helper 릴리스 태그 및 GitHub Release는 모든 기준을 충족합니다. 릴리스 노트는 기능 하이라이트, 안전 경계, 검증 기준선, 번들 기준선, QA 증거를 모두 포함하고 있으며, 태그는 올바른 커밋을 가리킵니다.
