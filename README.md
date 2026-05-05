# CMO Lua UI

Vite + React 기반의 Command: Modern Operations Lua preset 확인/작성 UI입니다.

이 UI는 `C:\Users\dlwls\.antigravity\cmo-lua-dev-work`에서 동기화한 현재 템플릿을 `public/cmo-dev-work` 아래에 정적 자원으로 포함합니다. 오른쪽 Template Inspector에서 `.tpl.lua` 원본, preset 파일, 최신 DB 요약을 바로 확인할 수 있습니다.

## 실행

`index.html`을 더블클릭해서 직접 실행하는 방식이 아닙니다. Vite 개발 서버가 React, ES module import, `/public` 정적 파일 경로를 처리해야 합니다.

```powershell
cd "C:\Users\dlwls\.antigravity\cmo-lua-ui"
npm install
npm run dev -- --host 127.0.0.1
```

터미널에 표시되는 주소를 브라우저에서 엽니다. 기본은 보통 다음 주소입니다.

```text
http://127.0.0.1:5173/
```

운영 형태로 확인하려면 다음을 사용합니다.

```powershell
cd "C:\Users\dlwls\.antigravity\cmo-lua-ui"
npm run build
npm run preview -- --host 127.0.0.1
```

## 현재 동기화된 항목

- 템플릿: `public/cmo-dev-work/templates/*.tpl.lua`
- 프리셋: `public/cmo-dev-work/presets/*.lua`
- 매니페스트: `public/cmo-dev-work/manifest.json`
- DB 요약: `DB3K_516.db3`, `CWDB_516.db3`, component entries `100598`

`cmo-lua-dev-work`의 템플릿을 다시 수정했다면 `public/cmo-dev-work`를 다시 동기화해야 UI Inspector에도 최신 내용이 반영됩니다.
