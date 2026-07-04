# Kimi QA Request — AI Chat Loop Polish

## Context

Codex finished a small usability polish pass for the AI response follow-up loop.

Touched files:

- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiInterpreterChatPanel.css`
- `src/components/AiResponseReviewPanel.jsx`
- `src/components/LuaAssistant.jsx`

New behavior:

- `AI 채팅` input now distinguishes three states:
  - `재질문 초안`
  - `사용자 직접 입력`
  - `새 지시 대기`
- `새 지시로 초기화` clears the current AI chat instruction.
- The clear button is disabled while empty or while an AI call is running.
- `AI 응답` follow-up button label changed from `AI 채팅으로 재질문` to `재질문 초안 만들기`.
- Follow-up loop safety is unchanged: `Lua 적용` must still be gated by `isPasteReady === true`.

## Please Run

From `C:\Users\dlwls\.codex\cmo-lua-ui`:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `npm run smoke:ai-adapter` fails with `spawn EPERM`, classify it as sandbox/environment unless adapter output shows an auth leak.

## Expected Current Build From Codex

- `index-*.js`: `397.25 kB`
- `index-*.css`: `63.81 kB`
- `AiResponseReviewPanel-*.js`: `4.12 kB`
- `AiResponseReviewPanel-*.css`: `2.42 kB`
- `AiInterpreterChatPanel-*.js`: `5.34 kB`
- `AiInterpreterChatPanel-*.css`: `3.30 kB`
- `AiAdapterSettings-*.js`: `10.87 kB`
- `AiAdapterSettings-*.css`: `2.05 kB`

Previous baseline before this polish:

- `index-*.js`: `397.22 kB`
- `index-*.css`: `63.81 kB`
- `AiInterpreterChatPanel-*.js`: `4.95 kB`
- `AiInterpreterChatPanel-*.css`: `3.03 kB`

## Functional Checks

1. Confirm `AI 채팅` lazy-loads without crash.
2. Confirm input state labels show correctly: `재질문 초안`, `사용자 직접 입력`, `새 지시 대기`.
3. Confirm `새 지시로 초기화` clears only the chat instruction text and is disabled when empty/calling.
4. Confirm the structured review follow-up button is now labeled `재질문 초안 만들기`.
5. Confirm the follow-up button still appears only when the response is not paste-ready.
6. Confirm `Lua 적용` remains disabled unless `isPasteReady === true`.
7. Confirm manual prompt-copy and request-copy fallbacks remain available.
8. Confirm no raw API key/auth leak in smoke output.
9. Report if `index-*.js` crosses the `400 kB` watch line.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not install packages.
- Report only actionable regressions, bundle deltas, and security smoke changes.
