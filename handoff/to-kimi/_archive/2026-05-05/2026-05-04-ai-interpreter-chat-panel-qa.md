# Kimi QA Request — AI Interpreter Chat Panel Lazy Split

## Context

Codex added the first minimal AI Interpreter Chat UI as a lazy-loaded panel:

- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiInterpreterChatPanel.css`

It appears under:

- `Event / Lua Assistant`
- `Output & Validation`
- `AI 채팅` tab

The chat panel composes the current generated AI request with a short user instruction, then sends that composed prompt through the existing local AI adapter. It does not own parser state or Lua application state; `LuaAssistant.jsx` still owns `aiResponse`, `parseAiInterpreterResponse`, blockers/warnings, and `isPasteReady` gating.

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

- `index-*.js`: `396.98 kB`
- `index-*.css`: `63.81 kB`
- `AiInterpreterChatPanel-*.js`: `3.52 kB`
- `AiInterpreterChatPanel-*.css`: `2.29 kB`
- `AiResponseReviewPanel-*.js`: `3.01 kB`
- `AiResponseReviewPanel-*.css`: `2.32 kB`
- `AiAdapterSettings-*.js`: `10.87 kB`
- `AiAdapterSettings-*.css`: `2.05 kB`

Previous baseline before this chat panel:

- `index-*.js`: `396.14 kB`
- `index-*.css`: `63.81 kB`

## Functional Checks

1. Confirm `AiInterpreterChatPanel-*.js` and `AiInterpreterChatPanel-*.css` are separate lazy chunks.
2. Confirm `Output & Validation > AI 채팅` can render without crashing.
3. Confirm the chat send button calls the existing AI adapter flow and keeps the user on the AI chat tab while calling.
4. Confirm manual prompt-copy fallback remains available:
   - existing `Prompt 복사`
   - new `요청문 복사` inside the chat panel
5. Confirm `Lua 적용` remains gated by `isPasteReady === true`; the chat panel must not bypass `LuaAssistant.jsx`.
6. Confirm no raw API key/auth leak in smoke output.
7. Report if `index-*.js` crosses the `400 kB` watch line.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not install packages.
- Report only actionable regressions, bundle deltas, and security smoke changes.
