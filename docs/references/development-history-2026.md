# 개발 히스토리 (2026-04 ~ 2026-07)

2026-07-04에 git 히스토리를 통합 단일 커밋으로 교체하면서, 이전 개발 방식을 기록으로 남긴다.
구현은 완결 상태이며 이 문서는 "어떻게 만들어졌나"의 참고용이다.

## 1기 — 멀티에이전트 개발 (2026-04-17 ~ 2026-05-13, 288 커밋)

구 PC(`~/.codex/cmo-lua-ui`)에서 4개 AI 에이전트 분업으로 개발. 파일 소유권과 핸드오프
우편함(`docs/archive-handoff/to-{claude,kimi,gemini}/CURRENT_TASK.md` — 2026-07-06 아카이브 위치로 이동)으로 조정했다.

| 에이전트 | 역할 | 소유 파일 |
|---|---|---|
| Codex | 주 작업자 — UI, 컴포넌트, 통합, 릴리스 | `src/App.jsx`, `src/components/**`, `src/index.css` |
| Claude Code | 백엔드/헬퍼 — 파서, 스캐너, 어댑터, 설계 리뷰 | `tools/**`, `server/**`, `src/lib/**` |
| Kimi | QA — 스모크/빌드/린트 모니터링, git 위생 | `docs/*.md`, `fixtures/**`, `.gitignore` |
| Gemini | 언어 품질 — 한국어/영문 용어 일관성 | `docs/**` (기능 코드 불가) |

작업 단위마다 "설계 리뷰(Claude) → 구현(Codex) → QA(Kimi) → 릴리스 태그"의 게이트를 돌렸고,
그 산출물이 `docs/agent-ops/`, `docs/superpowers/`, `docs/archive-handoff/*/_archive/`에 남아 있다.

### 릴리스 타임라인 (태그 17개)

| 날짜 | 릴리스 | 내용 |
|---|---|---|
| 05-05 | stable (+baseline 2종) | AI Assistant 안정판 기준선 |
| 05-06 | docs-refresh / qa-workflow / sidecar-onboarding | 문서·QA 파이프라인·sidecar 온보딩 정비 |
| 05-07 | ai-lua-safety-wording / transient-sidecar-ux | AI Lua 안전 문구, 임시 시나리오 열기 UX |
| 05-08 | sidecar-cache-wording | 캐시 안내 정리 |
| 05-09 | local-confirmed-context / template-inspector-annotations / -completion / -search-filter | 확정 컨텍스트 워크스페이스, 템플릿 인스펙터 주석 51종 완성 |
| 05-10 | runscript-sidecar-writer | **B2**: AiAssist Lua 저장 + RunScript 로더 |
| 05-11 | log-feedback-loop / state-snapshot-import | **B3**: 로그 회수, **B4**: 상태 스냅샷 임포트 |
| 05-13 | cmo-wiki-reference-helper | 위키/Lua 레퍼런스 헬퍼 (1기 최종 릴리스) |

### 1기 종료 시점의 미결

- 실기 E2E 스모크(`b4-manual-cmo-workflow-smoke-2026-05-12.md`)가 USER-RUN 대기 상태로 중단
- 이후 구 PC 폐기로 로컬 사본·sidecar 캐시 소실, GitHub 리포만 잔존

## 2기 — 복구·통합 (2026-07-04, 단독 유지보수)

새 PC `D:\works\CMO-Lua-Builder`로 복구하며 Claude Code 단독 유지보수로 전환.

- CMO 설치 자동 감지(`tools/cmo-install-locator.mjs`)로 구 PC 하드코딩 제거
- **AI 브리지 CLI**(`tools/cmo-ai-bridge.mjs`) 추가 — GUI 없이 apply/inbox/poller/logs 루프
- 14개월 미결이던 E2E 스모크를 Build 1892에서 PASS
  (`docs/agent-ops/manual-cmo-workflow-smoke-result-2026-07-04.md`)
- 시나리오 sidecar 1155/1155 재생성, verify:release 전체 PASS
- 베타 1852→1892 변경 다이제스트: `docs/references/cmo-beta-builds-2026-04-to-06.md`

1기의 멀티에이전트 규칙(AGENTS.md의 역할 분담·핸드오프 절차)은 히스토리 참고용으로만 유지한다.
