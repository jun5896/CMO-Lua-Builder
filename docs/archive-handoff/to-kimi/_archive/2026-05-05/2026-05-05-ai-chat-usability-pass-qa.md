# Kimi QA Request — AI Chat Usability Pass

## Context

Codex made a small usability pass on the lazy AI Interpreter Chat panel:

- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiInterpreterChatPanel.css`
- `src/components/LuaAssistant.jsx`

The goal is to make the first chat loop clearer:

1. Send a short interpreter instruction.
2. See whether the AI response is:
   - waiting / no response
   - ask-back / missing context
   - hold / blocked review
   - ready / paste-ready Lua
3. Move to `AI 응답` tab for structured review.
4. Apply Lua only through the existing `isPasteReady === true` gate.

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

- `index-*.js`: `397.00 kB`
- `index-*.css`: `63.81 kB`
- `AiInterpreterChatPanel-*.js`: `4.95 kB`
- `AiInterpreterChatPanel-*.css`: `3.03 kB`
- `AiResponseReviewPanel-*.js`: `3.01 kB`
- `AiResponseReviewPanel-*.css`: `2.32 kB`
- `AiAdapterSettings-*.js`: `10.87 kB`
- `AiAdapterSettings-*.css`: `2.05 kB`

Previous baseline before this usability pass:

- `index-*.js`: `396.98 kB`
- `index-*.css`: `63.81 kB`
- `AiInterpreterChatPanel-*.js`: `3.52 kB`
- `AiInterpreterChatPanel-*.css`: `2.29 kB`

## Functional Checks

1. Confirm `Output & Validation > AI 채팅` still lazy-loads without crash.
2. Confirm the chat panel now shows a response mode card:
   - `대기`
   - `되묻기`
   - `검토 필요`
   - `Lua 준비`
3. Confirm `AI 응답 탭에서 구조화 검토` switches to the `AI 응답` tab and is disabled when no AI response exists.
4. Confirm `Lua 적용` remains disabled unless `isPasteReady === true`.
5. Confirm manual prompt-copy fallback remains available:
   - original `Prompt 복사`
   - chat-scoped `요청문 복사`
6. Confirm no raw API key/auth leak in smoke output.
7. Report if `index-*.js` crosses the `400 kB` watch line.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not install packages.
- Report only actionable regressions, bundle deltas, and security smoke changes.
