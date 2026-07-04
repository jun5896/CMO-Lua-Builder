# Kimi QA Directive - AI Lua Apply Safety Wording

Status: APPROVED / ARCHIVED

Target commit:

```text
1260e33 Clarify AI Lua apply safety wording
```

QA was executed at:

```text
6856a8a Add AI Lua apply safety wording QA directive
```

## Purpose

Verify that the AI Lua apply UI now communicates "gated draft, CMO engine verification still required" without changing parser behavior, apply gates, prompt-copy fallback, provider security, or release watch lines.

This was a focused wording/safety regression pass.

## Required Pipeline

```powershell
git status --short --branch
npm run verify:release
```

## QA Result

Final verdict:

```text
APPROVED - AI Lua apply safety wording holds.
```

Pipeline:

- `git status --short --branch`: clean (`main...origin/main`)
- `audit:scenario-sidecars`: PASS (`1899` index / `3799` protected / `24` orphans / `5.6 MB`)
- `verify:scenario-loader`: PASS (`1857` ready / `42` decoderFailed / issues `0`)
- `lint`: PASS
- `build`: PASS
- `smoke:ai-client-parser`: PASS
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage

Bundle sizes:

- Main JS: `366.47 kB` (`< 400 kB`)
- Main CSS: `58.27 kB` (`< 60 kB`)
- `aiContextPruning`: `8.56 kB` (`< 9 kB`)

Static checkpoints:

1. `src/components/AiInterpreterChatPanel.jsx` uses `초안 준비` and `CMO 검증 필요`.
2. `src/components/AiResponseReviewPanel.jsx` uses `Lua 초안 적용 가능 · CMO 검증 필요`.
3. `src/components/LuaAssistant.jsx` apply tooltips describe `검증 게이트를 통과한 Lua 초안` and `CMO 엔진 검증은 별도 필요합니다`.
4. Working Lua placeholder no longer implies final paste-ready safety.
5. `canApplyAiLua` remains derived from `aiParsedResponse.isPasteReady`.
6. Apply buttons remain disabled when `canApplyAiLua` is false.
7. Manual prompt-copy fallback remains visible.
8. No raw credential strings were introduced in changed UI surfaces.
9. `aiContextPruning` remains under `9 kB`.
10. Main JS and CSS remain under watch lines.

Regression:

- None.
