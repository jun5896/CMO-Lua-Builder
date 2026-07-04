# Kimi QA Request — AI Chat Session History

## Context

Codex added a minimal session-only AI chat history inside the lazy `AiInterpreterChatPanel` chunk.

Touched files in this pass:

- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiInterpreterChatPanel.css`

No parent `LuaAssistant.jsx` state was added in this pass.

## New Behavior

- `AI 채팅` now shows `세션 대화 기록`.
- The history keeps the latest 5 AI chat responses in module memory only.
- It does not use localStorage, sessionStorage, IndexedDB, or disk persistence.
- Each item records:
  - time
  - compact instruction label
  - response line count
  - Lua ready / review needed state
  - Lua line count
  - blockers/warnings count
- Each item supports:
  - `재사용`: drafts a follow-up instruction back into the chat input.
  - `응답 복사`: copies that response text to clipboard.
- `Lua 적용` safety remains controlled only by parent `canApplyLua` / `isPasteReady === true`.

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

- `index-*.js`: `398.17 kB`
- `index-*.css`: `64.08 kB`
- `AiInterpreterChatPanel-*.js`: `7.72 kB`
- `AiInterpreterChatPanel-*.css`: `4.64 kB`
- `AiProviderProfileSelector-*.js`: `1.64 kB`
- `AiProviderProfileSelector-*.css`: `0.30 kB`
- `AiAdapterSettings-*.js`: `10.87 kB`
- `AiAdapterSettings-*.css`: `2.05 kB`
- `AiResponseReviewPanel-*.js`: `4.12 kB`
- `AiResponseReviewPanel-*.css`: `2.42 kB`

Previous baseline before this pass:

- `index-*.js`: `398.17 kB`
- `index-*.css`: `64.08 kB`
- `AiInterpreterChatPanel-*.js`: `5.34 kB`
- `AiInterpreterChatPanel-*.css`: `3.30 kB`

Expected effect:

- Main JS/CSS should remain unchanged.
- Only `AiInterpreterChatPanel` lazy JS/CSS should grow.

## Functional Checks

1. Confirm `AI 채팅` lazy-loads without crash.
2. Confirm `세션 대화 기록` appears inside the chat panel.
3. Confirm history is capped to 5 items.
4. Confirm history is not persisted in localStorage/sessionStorage.
5. Confirm `재사용` fills the chat input with a follow-up instruction, but does not auto-send.
6. Confirm `응답 복사` copies only the selected response text.
7. Confirm `Lua 적용` remains disabled unless `isPasteReady === true`.
8. Confirm manual prompt/request copy fallbacks remain available.
9. Confirm smoke output does not leak raw `Bearer` or `sk-` tokens.
10. Report if `index-*.js` crosses the `400 kB` watch line.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not install packages.
- Report only actionable regressions, bundle deltas, and security smoke changes.
