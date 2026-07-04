# Kimi QA 보고서 - B2 RunScript Sidecar Writer Release Tag

날짜: 2026-05-10
대상: `release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer`

## 태그 / GitHub Release 메타데이터

```text
태그: release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer
태그 대상: 8c7a18e62d2bc041f9bcd1c6d31906c227b33540
커밋 메시지: 8c7a18e Mark B2 RunScript sidecar writer release in README
GitHub Release 제목: CMO Lua Builder RunScript Sidecar Writer
draft: false
prerelease: false
```

## 파이프라인 결과

```text
git status --short --branch: main...origin/main, 작업 트리 clean
npm run verify:release: PASS (전체 체인)
  audit:scenario-sidecars: 1899 인덱스 / 3799 보호 / 24 고아 / 5.6 MB
  verify:scenario-loader: 1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues
  lint: PASS
  build: PASS
  smoke:ai-workflow-state: PASS
  smoke:ai-follow-up-needs: PASS
  smoke:ai-confirmed-context: PASS
  smoke:ai-adapter-client-sidecar: PASS
  smoke:ai-client-parser: PASS
  smoke:ai-adapter: PASS — Bearer / sk-key 누출 없음
```

## 번들 기준선

```text
Main JS: 380.45 kB (< 400 kB)
Main CSS: 59.14 kB (< 60 kB)
aiContextPruning: 8.56 kB (< 9 kB)
```

## 정적 체크포인트 결과

### 태그 및 Release 메타데이터 (1-6)

1. **릴리스 태그 존재** — PASS.

2. **태그가 `8c7a18e`를 가리킴** — PASS.
   `8c7a18e62d2bc041f9bcd1c6d31906c227b33540`.

3. **태그된 커밋 메시지가 `Mark B2 RunScript sidecar writer release in README`** — PASS.

4. **GitHub Release 제목이 `CMO Lua Builder RunScript Sidecar Writer`** — PASS.

5. **GitHub Release가 draft가 아님** — PASS. `draft: false`.

6. **GitHub Release가 prerelease가 아님** — PASS. `prerelease: false`.

### 릴리스 노트 내용 (7-22)

7. **릴리스 노트에 B2 RunScript sidecar writer 언급** — PASS.
   "Adds the B2 RunScript sidecar writer path for CMO Lua drafts."

8. **릴리스 노트에 `CMO 파일 준비` dry-run preview 언급** — PASS.
   "previewed with `CMO 파일 준비`".

9. **릴리스 노트에 `CMO Lua 폴더 저장` confirmed write 언급** — PASS.
   "saved with `CMO Lua 폴더 저장`".

10. **릴리스 노트에 `ScenEdit_RunScript('/AiAssist/<file>.lua')` 언급** — PASS.
    "The UI displays `ScenEdit_RunScript('/AiAssist/<file>.lua')` for manual execution in CMO."

11. **`dofile(...)` 및 시나리오 폴더 자동 로드 미주장 명시** — PASS.
    "`dofile(...)` and scenario-folder auto-load are not claimed."

12. **브라우저 클라이언트가 `cmoLuaRoot`를 제공하지 않음 명시** — PASS.
    "Browser clients do not supply `cmoLuaRoot`."

13. **저장 컨트롤이 `aiParsedResponse.isPasteReady`로 게이트됨 명시** — PASS.
    "Save controls remain gated by `aiParsedResponse.isPasteReady`."

14. **자동 CMO 실행, 폴링, 로그 테일링, 실시간 리드백, AI 자동 전송 없음 명시** — PASS.
    "No automatic CMO execution, polling, log tailing, live read-back, or AI auto-send is introduced."

15. **CMO 엔진 검증 필요 명시** — PASS.
    "CMO engine verification remains required before operational use."

16. **`npm run verify:release` PASS 언급** — PASS.
    "`npm run verify:release` PASS, including `npm run smoke:ai-adapter-client-sidecar`."

17. **`npm run smoke:ai-adapter-client-sidecar` PASS 언급** — PASS.
    릴리스 노트에 명시적 언급.

18. **B2 writer 및 endpoint 스모크 언급** — PASS.
    "`npm run smoke:cmo-lua-sidecar-writer` PASS.", "`npm run smoke:cmo-lua-sidecar-endpoint` PASS."

19. **AI 어댑터 스모크 인증 누출 없음 언급** — PASS.
    "AI adapter smoke PASS with no raw Bearer/Authorization/sk- leakage."

20. **시나리오 로더 기준선 언급** — PASS.
    "1899 total / 1857 readyWithInternalSidecar / 42 decoderFailed / 0 issues."

21. **사이드카 감사 기준선 언급** — PASS.
    "3799 protected / 24 orphans / 5.6 MB, dry-run only."

22. **번들 기준선 `380.45 kB / 59.14 kB / 8.56 kB` 언급** — PASS.
    "Main JS 380.45 kB / Main CSS 59.14 kB / aiContextPruning 8.56 kB."

### README / package.json (23-24)

23. **README 공개 릴리스 참조가 태그와 일치** — PASS.
    이전 release marker QA에서 확인.

24. **`package.json` `verify:release`에 `smoke:ai-adapter-client-sidecar` 포함** — PASS.
    이전 release marker QA에서 확인.

### 파이프라인 및 기준선 (25-29)

25. **`npm run verify:release` PASS** — PASS.

26. **Main JS 400 kB 미만** — PASS. 380.45 kB.

27. **Main CSS 60 kB 미만** — PASS. 59.14 kB.

28. **`aiContextPruning` 9 kB 미만** — PASS. 8.56 kB.

29. **AI 어댑터 스모크 인증 누출 없음** — PASS.

### 범위 및 태그 위치 (30-32)

30. **태그된 커밋 범위가 `README.md` + `package.json`만** — PASS.
    `git show --name-only`에서 2개 파일만 확인.

31. **`src/**`, `server/**`, `tools/**`, `public/**`, 의존성, lockfile 드리프트 없음** — PASS.

32. **태그가 `8c7a18e`에 있고 HEAD가 아님** — PASS.
    HEAD: `4f05424`, 태그: `8c7a18e`.

## 최종 평결

```text
정적 체크포인트: 32 / 32 PASS
태그: release-2026-05-10-cmo-lua-builder-runscript-sidecar-writer → 8c7a18e
GitHub Release: CMO Lua Builder RunScript Sidecar Writer, not draft, not prerelease
파이프라인: verify:release 전체 PASS
번들: Main JS 380.45 kB / Main CSS 59.14 kB / aiContextPruning 8.56 kB
회귀: 없음
평결: APPROVED
```
