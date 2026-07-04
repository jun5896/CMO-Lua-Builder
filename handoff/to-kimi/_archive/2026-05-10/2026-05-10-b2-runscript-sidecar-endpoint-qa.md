# Kimi QA 보고서 - B2 RunScript Sidecar Endpoint

날짜: 2026-05-10
대상: `203b9d7 Add B2 RunScript sidecar endpoint`

## 범위

B2.2 어댑터 엔드포인트 슬라이스.

변경 파일:

```text
package.json                              |   1 +
server/ai-provider-adapter.mjs            |  26 +++++++
tools/verify-cmo-lua-sidecar-endpoint.mjs | 121 ++++++++++++++++++++++++++++++
3 files changed, 148 insertions(+)
```

## 파이프라인 결과

```text
git status --short --branch: main...origin/main [ahead 5], 작업 트리 clean
npm run smoke:cmo-lua-sidecar-endpoint: PASS
npm run smoke:cmo-lua-sidecar-writer: PASS
npm run smoke:cmo-lua-load-check: PASS
npm run verify:release: PASS (전체 체인)
  audit:scenario-sidecars: 1899 인덱스 / 3799 보호 / 24 고아 / 5.6 MB
  verify:scenario-loader: 1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues
  lint: PASS
  build: PASS
  smoke:ai-workflow-state: PASS
  smoke:ai-follow-up-needs: PASS
  smoke:ai-confirmed-context: PASS
  smoke:ai-client-parser: PASS
  smoke:ai-adapter: PASS — Bearer / sk-key 누출 없음
```

## 번들 기준선

```text
Main JS: 377.99 kB (< 400 kB)
Main CSS: 59.14 kB (< 60 kB)
aiContextPruning: 8.56 kB (< 9 kB)
```

## 정적 체크포인트 결과

### 패키지 및 파일 존재 (1-4)

1. **`package.json`에 `smoke:cmo-lua-sidecar-endpoint` 추가** — PASS.
   스크립트 항목 1줄 추가만 확인.

2. **`package-lock.json` 변경 없음** — PASS.
   `git diff` 출력 없음.

3. **새 의존성/개발 의존성 추가 없음** — PASS.
   스크립트 항목만 추가, dependencies 변경 없음.

4. **`tools/verify-cmo-lua-sidecar-endpoint.mjs` 존재** — PASS.
   121행, 엔드포인트 스모크 계약 확인.

### 어댑터 임포트 및 라우트 (5-6)

5. **어댑터가 `createLuaSidecar` 임포트** — PASS.
   `import { createLuaSidecar } from './cmo-lua-sidecar-writer.mjs';` 확인.

6. **어댑터에 `POST /api/cmo/lua-sidecar` 라우트 노출** — PASS.
   `if (method === 'POST' && path === '/api/cmo/lua-sidecar') return handleCmoLuaSidecar(req, res);` 확인.

### 핸들러 구현 (7-9)

7. **핸들러가 `readJsonOrEmpty(req)` 호출** — PASS.
   `const body = await readJsonOrEmpty(req);` 확인.

8. **핸들러가 `content`, `slug`, `fileName`, `isPasteReady`, `dryRun`, `confirmWrite`만 전달** — PASS.
   `createLuaSidecar` 호출에 정확히 6개 필드만 전달. `cmoLuaRoot` 미전달.

9. **`body.cmoLuaRoot`가 `createLuaSidecar`에 전달되지 않음** — PASS.
   핸들러 호출에 `cmoLuaRoot` 필드 없음.

### Dry-run 동작 (10-15)

10. **엔드포인트 dry-run이 200 + `mode: dry-run` 반환** — PASS.
    스모크 62-63행: `assert.equal(dryRun.status, 200)`, `assert.equal(dryRun.json.mode, 'dry-run')`.

11. **엔드포인트 dry-run에 `wroteFile: false`** — PASS.
    스모크 64행 확인.

12. **엔드포인트 dry-run에 `confirmedDryRun: true`, `confirmedWrite: false`** — PASS.
    스모크 65-66행 확인.

13. **엔드포인트 dry-run 응답에 `lua` 필드 없음** — PASS.
    핸들러: `deepScrubSecrets({ ...result, lua: undefined })`.
    스모크 67행: `assert.equal(Object.hasOwn(dryRun.json, 'lua'), false)`.

14. **엔드포인트 dry-run 타겟 경로가 환경 변수 `CMO_LUA_ROOT\AiAssist` 아래** — PASS.
    스모크 68행: `assert.equal(dryRun.json.targetFile.startsWith(path.join(tmp, 'AiAssist')), true)`.
    어댑터 실행 시 `CMO_LUA_ROOT: tmp` 환경 변수 설정.

15. **악의적 `cmoLuaRoot` 요청 본문이 무시되고 `targetFile`에 나타나지 않음** — PASS.
    스모크 60행: `cmoLuaRoot: path.join(tmp, 'malicious-root-ignored')`.
    스모크 69행: `assert.equal(dryRun.json.targetFile.includes('malicious-root-ignored'), false)`.

### 에러 및 쓰기 동작 (16-22)

16. **`dryRun: false` + `confirmWrite` 없이 400 반환** — PASS.
    스모크 72-79행: 400 + `/confirmWrite must be true/`.

17. **확인된 쓰기가 200 + `wroteFile: true` 반환** — PASS.
    스모크 88-89행 확인.

18. **확인된 쓰기가 `<root>\AiAssist\<file>.lua` 생성** — PASS.
    스모크 91-92행: `<tmp>/AiAssist/AiAssist_20260510_060002_write.lua`에 `print("write")\n` 확인.

19. **확인된 쓰기 응답에 `lua` 필드 없음** — PASS.
    스모크 90행: `assert.equal(Object.hasOwn(write.json, 'lua'), false)`.

20. **안전하지 않은 Lua가 400 + unsafe-surface 에러 반환** — PASS.
    스모크 94-100행: `os.execute("calc")` → 400 + `/Unsafe Lua surface/`.

21. **`isPasteReady: false`가 400 반환** — PASS.
    스모크 102-108행: 400 + `/isPasteReady must be true/`.

22. **에러 응답이 `errorMessage` 사용 및 시크릿 스크러빙** — PASS.
    핸들러: `deepScrubSecrets` + `trimForResponse` 적용. 에러 응답에 `ok: false`, `error`, `errorMessage` 구조.

### 로그 및 기존 스모크 (23-26)

23. **엔드포인트 스모크가 로그와 응답에서 `Bearer` / `sk-` 누출 검사** — PASS.
    스모크 110-112행: `assert.doesNotMatch(logs, /sk-[A-Za-z0-9]/)`, 응답 JSON에 `Bearer`/`sk-` 없음.

24. **기존 AI 어댑터 스모크 여전히 통과** — PASS.
    `verify:release` 체인에서 확인.

25. **B2.1 writer 스모크 여전히 통과** — PASS.
    `npm run smoke:cmo-lua-sidecar-writer` → PASS.

26. **B0.1 load-check 스모크 여전히 통과** — PASS.
    `npm run smoke:cmo-lua-load-check` → PASS.

### 드리프트 없음 (27-30)

27. **`src/**` UI 파일 변경 없음** — PASS.
    `git diff --name-only`에 src 파일 없음.

28. **public 데이터 파일 변경 없음** — PASS.
    `git diff --name-only`에 public 파일 없음.

29. **CMO 폴링, 로그 테일링, 실시간 리드백, AI 자동 전송, 자동 CMO 실행 도입 없음** — PASS.
    핸들러는 요청/응답만 처리, 네트워크/폴링/타이머 코드 없음.

30. **시나리오 폴더 쓰기 또는 `.scen` 변경 없음** — PASS.
    B2.1 헬퍼가 CMO Lua root + `AiAssist` namespace만 사용.

### 번들 및 파이프라인 (31-34)

31. **Main JS 400 kB 미만 유지** — PASS. 377.99 kB.

32. **Main CSS 60 kB 미만 유지** — PASS. 59.14 kB.

33. **`aiContextPruning` 9 kB 미만 유지** — PASS. 8.56 kB.

34. **`npm run verify:release` 여전히 통과** — PASS.

## 회귀 감시

- 브라우저/클라이언트 제공 파일시스템 root가 허용되는가? — 아니오. `cmoLuaRoot` 미전달, 스모크로 무시 확인.
- 엔드포인트가 Lua 본문을 반환하는가? — 아니오. `lua: undefined` 명시적 제거.
- 엔드포인트가 기본적으로 파일을 쓰는가? — 아니오. `dryRun: body.dryRun !== false` 기본 dry-run.
- `confirmWrite: true` 없이 쓰는가? — 아니오. 400 에러.
- `AiAssist` namespace 외부에 쓰는가? — 아니오. B2.1 헬퍼 경로 검증 유지.
- 기존 파일을 덮어쓰는가? — 아니오. B2.1 `open('wx')` 배타 모드 유지.
- B2.3 전에 UI 저장 컨트롤이 나타났는가? — 아니오. src 변경 없음.
- `dofile(...)`이 재도입되었는가? — 아니오.
- 시나리오 폴더 자동 로드가 증명된 것으로 주장되는가? — 아니오.
- 로그 테일링/폴링/실시간 리드백/자동 실행/AI 자동 전송이 도입되었는가? — 아니오.

## 최종 평결

```text
정적 체크포인트: 34 / 34 PASS
파이프라인: 전체 PASS
번들: Main JS 377.99 kB / Main CSS 59.14 kB / aiContextPruning 8.56 kB
드리프트: src/public/package-lock 변경 없음
회귀: 없음
평결: APPROVED
```

B2.2 엔드포인트 슬라이스는 B2.1 헬퍼를 재사용하며 `cmoLuaRoot`를 무시하고 Lua 본문을 응답에서 제거합니다. Codex는 B2.3 UI 저장 컨트롤 슬라이스를 진행할 수 있습니다.
