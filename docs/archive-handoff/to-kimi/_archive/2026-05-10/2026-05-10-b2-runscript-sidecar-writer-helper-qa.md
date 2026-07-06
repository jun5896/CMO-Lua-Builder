# Kimi QA 보고서 - B2 RunScript Sidecar Writer Helper

날짜: 2026-05-10
대상: `b1fce05 Add B2 RunScript sidecar writer helper`

## 범위

B2.1 writer-helper 슬라이스 순수 서버 사이드 헬퍼 + 스모크 계약.

변경 파일:

```text
package.json                                     |   1 +
server/cmo-lua-sidecar-writer.mjs                | 137 +++++++++++++++++++++++
tools/verify-cmo-lua-sidecar-writer-contract.mjs | 118 +++++++++++++++++++
3 files changed, 256 insertions(+)
```

## 파이프라인 결과

```text
git status --short --branch: main...origin/main [ahead 2], 작업 트리 clean
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

### 패키지 및 파일 존재 (1-5)

1. **`package.json`에 `smoke:cmo-lua-sidecar-writer` 추가** — PASS.
   스크립트 항목 1줄 추가만 확인.

2. **`package-lock.json` 변경 없음** — PASS.
   `git diff` 출력 없음.

3. **새 의존성/개발 의존성 추가 없음** — PASS.
   스크립트 항목만 추가, `dependencies`/`devDependencies` 변경 없음.

4. **`server/cmo-lua-sidecar-writer.mjs` 존재** — PASS.
   137행, 헬퍼 모듈 확인.

5. **`tools/verify-cmo-lua-sidecar-writer-contract.mjs` 존재** — PASS.
   118행, 스모크 계약 확인.

### 익스포트 및 기본값 (6-8)

6. **헬퍼가 `DEFAULT_CMO_LUA_ROOT`, `DEFAULT_SCRIPT_FOLDER`, `sanitizeLuaSidecarFileName`, `validateLuaSidecarContent`, `buildLuaSidecarReport`, `createLuaSidecar` 익스포트** — PASS.
   소스 4-5행(상수), 42/50/110/114행(함수)에서 6개 export 확인.

7. **기본 스크립트 폴더가 정확히 `AiAssist`** — PASS.
   5행: `export const DEFAULT_SCRIPT_FOLDER = 'AiAssist';`

8. **기본 루트가 `Command - Modern Operations\Lua`로 끝남** — PASS.
   4행: `'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Command - Modern Operations\\Lua'`

### 파일명 규칙 (9-11)

9. **생성된 파일명이 `AiAssist_<timestamp>_<slug>.lua` 사용** — PASS.
   43행: `` `AiAssist_${timestampForFile(now)}_${slugify(slug)}.lua` ``.
   스모크 51행: 정규식 `/^AiAssist_\d{8}_\d{6}_strike-alpha\.lua$/` 확인.

10. **명시적 파일명이 `AiAssist_*.lua`에 매치** — PASS.
    7행: `const FILE_NAME_RE = /^AiAssist_[A-Za-z0-9_-]{1,96}\.lua$/;`

11. **순회, 경로 구분자, `LuaInit.lua` 거부** — PASS.
    44행: `..`, `/`, `\` 포함 시 거부. 69-71행: `path.relative` 경로 이탈 검사.
    스모크 26-27행: `../AiAssist_bad.lua`, `LuaInit.lua` 거부 확인.

### Lua 콘텐츠 검증 (12-13)

12. **`print(...)`, `ScenEdit_SpecialMessage(...)` 등 안전한 Lua 허용** — PASS.
    스모크 29행: 예외 없이 통과 확인.

13. **안전하지 않은 Lua 표면 거부** — PASS.
    `UNSAFE_LUA_PATTERNS`에 `os.*`, `io.*`, `require`, `dofile`, `loadfile`, `package.*`, `debug.*`, `ScenEdit_RunScript` 포함.
    스모크 30-37행: 8개 패턴 모두 거부 확인.

### 게이트 및 모드 (14-17)

14. **`isPasteReady !== true` 시 report/write 전 거부** — PASS.
    77-79행: `isPasteReady !== true` 시 `Error('isPasteReady must be true...')`.
    스모크 54-57행 확인.

15. **기본 호출이 dry-run이며 파일을 쓰지 않음** — PASS.
    90행: `options.dryRun === false ? 'write' : 'dry-run'`.
    116행: dry-run 시 즉시 return, 파일 쓰기 없음.

16. **dry-run 응답에 `confirmedDryRun: true`, `confirmedWrite: false`, `lua` 필드 없음** — PASS.
    92-93행. 스모크 47-50행: `assert.equal(Object.hasOwn(dryRun, 'lua'), false)` 확인.

17. **실제 쓰기에 `dryRun: false` 및 `confirmWrite: true` 필요** — PASS.
    118-120행: `confirmWrite !== true` 시 에러. 스모크 59-69행 확인.

### 쓰기 동작 (18-21)

18. **확인된 쓰기가 `<root>\AiAssist\` 아래에 파일 생성** — PASS.
    65행: `path.resolve(root, DEFAULT_SCRIPT_FOLDER)`.
    스모크 87행: `<tmp>/AiAssist/AiAssist_...lua` 경로 확인.

19. **쓰여진 Lua가 후행 개행으로 정규화** — PASS.
    60행: `return \`${text}\n\`;`.
    스모크 88행: `assert.equal(written, 'print("write ok")\n');`

20. **확인된 쓰기 응답에 `confirmedDryRun: false`, `confirmedWrite: true`, `lua` 필드 없음** — PASS.
    스모크 81-83행 확인.

21. **기존 파일 덮어쓰기 불가, 에러 메시지에 새 타임스탬프 파일명 준비 안내** — PASS.
    125행: `open('wx')` 배타 모드. 128-130행: EEXIST 시 `already exists` + `fresh timestamp file name` 안내.
    스모크 90-100행 확인.

### 로더 스니펫 (22-23)

22. **로더 스니펫이 `ScenEdit_RunScript('/AiAssist/<file>.lua')` 사용** — PASS.
    100행. 스모크 52/85행 확인.

23. **`runScriptPath`가 `/AiAssist/<file>.lua` 사용** — PASS.
    84행: `` `/${DEFAULT_SCRIPT_FOLDER}/${fileName}` ``. 스모크 84행 확인.

### 드리프트 없음 (24-28)

24. **`server/ai-provider-adapter.mjs`에 어댑터 라우트 추가 없음** — PASS.
    `git diff` 출력 없음.

25. **`src/**` UI 파일 변경 없음** — PASS.
    `git diff --name-only`에 src 파일 없음.

26. **public 데이터 파일 변경 없음** — PASS.
    `git diff --name-only`에 public 파일 없음.

27. **CMO 폴링, 로그 테일링, 실시간 리드백, AI 자동 전송, 자동 CMO 실행 도입 없음** — PASS.
    헬퍼는 순수 함수 + 파일 쓰기만, 네트워크/폴링/타이머 코드 없음.

28. **자격 증명 문자열 또는 스토리지 표면 없음** — PASS.
    `Select-String` 결과 없음 (`apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, `sessionStorage`).

### 회귀 없음 (29-34)

29. **B0.1 load-check smoke 여전히 통과** — PASS.

30. **`npm run verify:release` 여전히 통과** — PASS.

31. **Main JS 400 kB 미만 유지** — PASS. 377.99 kB.

32. **Main CSS 60 kB 미만 유지** — PASS. 59.14 kB.

33. **`aiContextPruning` 9 kB 미만 유지** — PASS. 8.56 kB.

34. **AI 어댑터 smoke에서 인증 누출 없음** — PASS.

## 회귀 감시

- B2.2 전에 어댑터 엔드포인트가 나타났는가? — 아니오. 어댑터 변경 없음.
- B2.3 전에 UI 저장 컨트롤이 나타났는가? — 아니오. src 변경 없음.
- 브라우저/클라이언트 제공 파일시스템 root가 허용되는가? — 아니오. 서버 측 root만 사용.
- 헬퍼가 기본적으로 파일을 쓰는가? — 아니오. 기본 dry-run.
- 헬퍼가 `AiAssist` namespace 외부에 쓰는가? — 아니오. `path.relative` 검증.
- 헬퍼가 응답 객체에 Lua 본문을 반환하는가? — 아니오. `lua` 필드 없음.
- 기존 파일이 덮어쓰기되는가? — 아니오. `open('wx')` 배타 모드.
- `dofile(...)`이 권장 로더로 재도입되었는가? — 아니오. 차단됨.
- 시나리오 폴더 자동 로드가 증명된 것으로 주장되는가? — 아니오. 언급 없음.

## 최종 평결

```text
정적 체크포인트: 34 / 34 PASS
파이프라인: 전체 PASS
번들: Main JS 377.99 kB / Main CSS 59.14 kB / aiContextPruning 8.56 kB
드리프트: src/server/adapter/public/package-lock 변경 없음
회귀: 없음
평결: APPROVED
```

B2.1 writer-helper 슬라이스는 순수 서버 사이드 헬퍼이며 어댑터 라우트나 UI 컨트롤을 포함하지 않습니다. Codex는 B2.2 어댑터 엔드포인트 슬라이스를 진행할 수 있습니다.
