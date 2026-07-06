# Kimi QA Request - AI Chat Next Actions Polish

## Context

Codex made a small Output & Validation > AI Chat UX polish pass.

Changed files:

- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiInterpreterChatPanel.css`

## What Changed

- Added a `다음 동작` card below the AI chat response-mode card.
- The card changes guidance by response mode:
  - `idle`: send, copy prompt fallback, parser gate reminder.
  - `ready`: review assumptions/checklist, apply Lua, verify in CMO.
  - `ask`: fill Side/Mission/GUID/DBID/RP/Zone values, ask back instead of inventing.
  - `hold`: inspect blockers/warnings, draft follow-up, do not paste into CMO until gated.
- No automatic AI call, Lua apply, prompt mutation, or backend behavior was added.
- New CSS lives inside the lazy `AiInterpreterChatPanel` chunk.

## QA Pipeline

Run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits sandbox `spawn EPERM`, rerun it outside sandbox as usual.

## Checkpoints

1. `lint`, `build`, and `smoke:ai-adapter` pass.
2. Main `index-*.js` remains under `400 kB`.
3. Main `index-*.css` stays near the current `64.08 kB` baseline.
4. `aiContextPruning-*.js` remains unchanged near the current `8.56 kB` baseline.
5. `AiInterpreterChatPanel-*.js` and `AiInterpreterChatPanel-*.css` may grow because this is chat-only lazy UI.
6. The `다음 동작` card renders for all response modes without requiring an AI response.
7. `ready` guidance does not enable Lua apply by itself; apply remains controlled by parent `canApplyLua`.
8. `ask` and `hold` guidance reinforce ask-back and no-paste-before-gate behavior.
9. Manual prompt-copy fallback remains present.
10. Lua apply remains gated by `aiParsedResponse.isPasteReady === true` in `LuaAssistant.jsx`.
11. No raw `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, or `sessionStorage` is newly introduced.

## Expected Local Baseline From Codex

Codex local QA before handoff:

- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS after sandbox escalation.
- Main JS: `395.60 kB`.
- Main CSS: `64.08 kB`.
- `aiContextPruning`: `8.56 kB`.
- `AiInterpreterChatPanel` lazy chunk: `10.06 kB JS`, `6.19 kB CSS`.
- `AiAdapterSettings` lazy chunk: `10.45 kB JS`, `2.33 kB CSS`.

## Report Format

Report only:

- Pass/fail for each pipeline step.
- Bundle sizes and watch-line status.
- Any actionable regression.
- Any critical untracked source file note.

No broad refactor recommendations unless a regression is found.
