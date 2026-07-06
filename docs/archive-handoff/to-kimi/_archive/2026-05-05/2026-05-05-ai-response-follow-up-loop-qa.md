# Kimi QA Request — AI Response Follow-up Loop

## Context

Codex added a follow-up loop from the structured AI response review panel back into the AI chat panel.

Touched files:

- `src/components/AiResponseReviewPanel.jsx`
- `src/components/AiResponseReviewPanel.css`
- `src/components/LuaAssistant.jsx`

New behavior:

- When `AI 응답` is not paste-ready, the structured review panel shows `AI 채팅으로 재질문`.
- Clicking it drafts a follow-up instruction from:
  - blockers
  - warnings
  - follow-up questions
  - missing required sections
  - CMO UI prerequisites
- The UI switches to `AI 채팅` and places the generated follow-up into the chat input.
- Lua application remains controlled by the existing `isPasteReady === true` gate in `LuaAssistant.jsx`.

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

- `index-*.js`: `397.22 kB`
- `index-*.css`: `63.81 kB`
- `AiResponseReviewPanel-*.js`: `4.12 kB`
- `AiResponseReviewPanel-*.css`: `2.42 kB`
- `AiInterpreterChatPanel-*.js`: `4.95 kB`
- `AiInterpreterChatPanel-*.css`: `3.03 kB`
- `AiAdapterSettings-*.js`: `10.87 kB`
- `AiAdapterSettings-*.css`: `2.05 kB`

Previous baseline before this pass:

- `index-*.js`: `397.00 kB`
- `index-*.css`: `63.81 kB`
- `AiResponseReviewPanel-*.js`: `3.01 kB`
- `AiResponseReviewPanel-*.css`: `2.32 kB`

## Functional Checks

1. Confirm `AI 응답` structured review still lazy-loads without crash.
2. Confirm `AI 채팅으로 재질문` appears only in the not-paste-ready review state.
3. Confirm clicking it switches to the `AI 채팅` tab.
4. Confirm the chat input is populated with blockers/warnings/follow-up/missing-section context.
5. Confirm `Lua 적용` remains disabled unless `isPasteReady === true`.
6. Confirm manual prompt-copy fallback remains available.
7. Confirm no raw API key/auth leak in smoke output.
8. Report if `index-*.js` crosses the `400 kB` watch line.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not install packages.
- Report only actionable regressions, bundle deltas, and security smoke changes.
