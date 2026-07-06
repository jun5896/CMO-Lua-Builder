# Kimi QA 보고서 - B2 RunScript Sidecar UI Save Controls

날짜: 2026-05-10
대상: `2df8e57 Add B2 sidecar save controls`

## 범위

B2.3 UI 저장 컨트롤 슬라이스.

변경 파일:

```text
package.json                                       |  1 +
src/components/LuaAssistant.jsx                    | 91 ++++++++++++++++++++++
src/lib/aiAdapterClient.js                         | 18 +++++
tools/verify-ai-adapter-client-sidecar-contract.mjs | 84 ++++++++++++++++++++
4 files changed, 194 insertions(+)
```

## 파이프라인 결과

```text
git status --short --branch: main...origin/main [ahead 8], 작업 트리 clean
npm run smoke:ai-adapter-client-sidecar: PASS
npm run smoke:cmo-lua-sidecar-endpoint: PASS
npm run smoke:cmo-lua-sidecar-writer: PASS
npm run smoke:cmo-lua-load-check: PASS
npm run lint: PASS
npm run build: PASS
npm run smoke:ai-adapter: PASS — Bearer / sk-key 누출 없음
npm run verify:release: PASS (전체 체인)
  audit:scenario-sidecars: 1899 인덱스 / 3799 보호 / 24 고아 / 5.6 MB
  verify:scenario-loader: 1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues
  smoke:ai-workflow-state: PASS
  smoke:ai-follow-up-needs: PASS
  smoke:ai-confirmed-context: PASS
  smoke:ai-client-parser: PASS
```

## 번들 기준선

```text
Main JS: 380.45 kB (< 400 kB) — +2.46 kB (B2.3 UI 컨트롤 추가)
Main CSS: 59.14 kB (< 60 kB) — 변경 없음
aiContextPruning: 8.56 kB (< 9 kB) — 변경 없음
PresetGuide lazy chunk: 33.99 kB JS / 7.49 kB CSS — 변경 없음
```

## 정적 체크포인트 결과

### 파일 범위 (1-4)

1. **타겟 커밋이 예상된 4개 파일만 변경** — PASS.
   `package.json`, `src/components/LuaAssistant.jsx`, `src/lib/aiAdapterClient.js`, `tools/verify-ai-adapter-client-sidecar-contract.mjs`.

2. **`package.json`에 `smoke:ai-adapter-client-sidecar` 추가** — PASS.
   스크립트 항목 1줄 추가 확인.

3. **`package-lock.json` 변경 없음** — PASS.
   `git diff` 출력 없음.

4. **새 의존성/개발 의존성 추가 없음** — PASS.

### 클라이언트 스모크 (5-10)

5. **`tools/verify-ai-adapter-client-sidecar-contract.mjs` 존재** — PASS.
   84행.

6. **클라이언트 스모크가 `fetch`를 스텁하고 `POST http://127.0.0.1:8765/api/cmo/lua-sidecar` 확인** — PASS.
   27행: `assert.equal(url, 'http://127.0.0.1:8765/api/cmo/lua-sidecar')`.

7. **클라이언트 스모크가 JSON 본문 전달 확인** — PASS.
   30행: `assert.deepEqual(JSON.parse(options.body), {...})`.

8. **클라이언트 스모크가 성공 응답에서 `fileName`과 `loaderSnippet` 확인** — PASS.
   49-51행: `result.fileName`, `result.loaderSnippet` 검증.

9. **클라이언트 스모크가 HTTP 실패 시 `status`와 `body` 포함 에러 throw 확인** — PASS.
   58-66행: 400 에러 시 `error.status`, `error.body` 확인.

10. **클라이언트 스모크가 HTTP 200이지만 `body.ok === false`인 경우 에러 throw 확인** — PASS.
    69-82행: 200 + `ok: false` 시 거부 확인.

### 클라이언트 헬퍼 (11-13)

11. **`src/lib/aiAdapterClient.js`가 `saveCmoLuaSidecar` 익스포트** — PASS.
    `export async function saveCmoLuaSidecar(payload)` 확인.

12. **`saveCmoLuaSidecar`가 JSON으로 `/api/cmo/lua-sidecar` 전송** — PASS.
    `fetch(\`${AI_ADAPTER_BASE_URL}/api/cmo/lua-sidecar\`)` + `POST` + `Content-Type: application/json`.

13. **`saveCmoLuaSidecar`에 provider 설정, API key, `cmoLuaRoot` 추가 없음** — PASS.
    함수가 `payload`만 직접 전달, 추가 필드 없음.

### LuaAssistant 임포트 및 상태 (14-16)

14. **`LuaAssistant.jsx`가 `saveCmoLuaSidecar` 임포트** — PASS.
    diff: `saveCmoLuaSidecar`가 임포트 목록에 추가됨.

15. **사이드카 저장 UI 상태가 로컬 React 상태만 사용** — PASS.
    `useState({ state: 'idle', message: '', loaderSnippet: '', fileName: '' })` 로컬 상태.

16. **새 AI 호출 시 기존 사이드카 저장 상태/스니펫 초기화** — PASS.
    diff: `setIsAiCalling(true)` 직후 `setLuaSidecarSave({ state: 'idle', ... })` 호출.

### 핸들러 게이트 (17-18)

17. **`saveAiLuaSidecar`가 `!canApplyAiLua` 시 차단** — PASS.
    `if (!canApplyAiLua || !aiExtractedLua.trim())` 가드.

18. **`saveAiLuaSidecar`가 추출된 AI Lua 없을 때 차단** — PASS.
    `!aiExtractedLua.trim()` 가드.

### 요청 페이로드 (19-21)

19. **요청 페이로드가 `aiExtractedLua`를 `content`로 사용** — PASS.
    `content: aiExtractedLua`.

20. **요청 페이로드가 `intent.actionType || 'ai-draft'`를 slug로 사용** — PASS.
    `slug: intent.actionType || 'ai-draft'`.

21. **요청 페이로드가 `aiParsedResponse.isPasteReady` 전송** — PASS.
    `isPasteReady: aiParsedResponse.isPasteReady`.

### 버튼 동작 (22-24)

22. **Dry-run 버튼이 `dryRun: true`, `confirmWrite: false` 전송** — PASS.
    `saveAiLuaSidecar({ dryRun: true })` → 핸들러 내 `confirmWrite: !dryRun` → `false`.

23. **Write 버튼이 `dryRun: false`, `confirmWrite: true` 전송** — PASS.
    `saveAiLuaSidecar({ dryRun: false })` → 핸들러 내 `confirmWrite: !dryRun` → `true`.

24. **버튼이 `!canApplyAiLua` 또는 로딩 중일 때 비활성화** — PASS.
    `disabled={!canApplyAiLua || luaSidecarSave.state === 'loading'}`.

### UI 레이블 및 문구 (25-27)

25. **UI 레이블이 dry-run과 write 액션 분리: `CMO 파일 준비`, `CMO Lua 폴더 저장`** — PASS.
    버튼 텍스트 확인.

26. **UI 문구가 CMO 실행 수동 및 엔진 검증 필요 명시** — PASS.
    dry-run 성공: `CMO 실행은 수동으로 확인하세요.`
    write 성공: `CMO에서 loader snippet을 직접 실행하세요.`
    버튼 title: `CMO 엔진 검증과 실행은 수동으로 해야 합니다.`

27. **Loader snippet이 어댑터 응답에서만 표시** — PASS.
    `luaSidecarSave.loaderSnippet`이 `result.loaderSnippet || ''`에서만 설정.

### 기존 기능 유지 (28-30)

28. **기존 `Prompt 복사` 폴백 유지** — PASS.
    4192행: `Prompt 복사` 버튼 존재, diff에서 제거되지 않음.

29. **Lua 적용이 `canApplyAiLua`를 통해 `isPasteReady`로 게이트 유지** — PASS.
    `canApplyAiLua = aiWorkflowState.canApplyLua` → `isPasteReady` 기반.

30. **`src/index.css` 또는 새 CSS 파일 변경 없음, 기존 클래스 재사용** — PASS.
    diff에 CSS 파일 변경 없음. `btn btn-secondary`, `ai-adapter-status`, `working-draft-preview` 기존 클래스 사용.

### 드리프트 없음 (31-35)

31. **서버 엔드포인트, writer 헬퍼, public 데이터, docs, 의존성, lockfile 드리프트 없음** — PASS.
    타겟 커밋에 해당 파일 변경 없음.

32. **CMO 폴링, 로그 테일링, 실시간 리드백, 자동 실행, AI 자동 전송 도입 없음** — PASS.
    UI 컨트롤은 요청/응답만, 타이머/폴링 없음.

33. **새 `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, `sessionStorage` 지속성 표면 없음** — PASS.
    `saveCmoLuaSidecar` 함수에 해당 문자열 없음. 기존 `apiKey` 참조는 사전 존재 코드.

34. **번들 watch line 한계 내 유지** — PASS.
    Main JS 380.45 kB < 400 kB, Main CSS 59.14 kB < 60 kB, aiContextPruning 8.56 kB < 9 kB.

35. **AI 어댑터 스모크에서 인증 누출 없음** — PASS.

## 번들 변화 주의사항

Main JS가 377.99 kB → 380.45 kB로 +2.46 kB 증가했습니다. B2.3 UI 컨트롤(+91행 JSX + 18행 클라이언트)의 정상적 증가이며 400 kB 한계까지 19.55 kB 여유가 있습니다.

Main CSS는 59.14 kB로 변경 없으며 기존 클래스 재사용이 확인됩니다.

## 최종 평결

```text
정적 체크포인트: 35 / 35 PASS
파이프라인: 전체 PASS
번들: Main JS 380.45 kB / Main CSS 59.14 kB / aiContextPruning 8.56 kB
드리프트: server/public/docs/css/package-lock 변경 없음
회귀: 없음
평결: APPROVED
```

B2.3 UI 저장 컨트롤은 기존 CSS 클래스를 재사용하고 `canApplyAiLua`/`isPasteReady` 게이트를 유지하며, 프롬프트 복사 폴백이 그대로 보존됩니다. B2.1 헬퍼, B2.2 엔드포인트, B0.1 load-check 스모크 모두 기준선 유지.
