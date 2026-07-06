# Kimi QA Directive - Local Confirmed Context Workspace

## Target

Track A3 product commits:

```text
953317a Add confirmed context helper contract
864e36b Wire confirmed context into assistant state
72cca75 Add confirmed context workspace UI
3772866 Use confirmed context in follow-up drafts
```

## Scope

- Local AI editor only.
- Adds source-labeled confirmed CMO values to the local Context tab.
- Reuses confirmed values in prompts and follow-up drafts.
- Persists confirmed values only through the existing temp session/autosave payload.
- Track B remains deferred: no CMO filesystem writes, no log tailing, no live read-back, no new backend endpoint.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:ai-confirmed-context
npm run smoke:ai-follow-up-needs
npm run smoke:ai-workflow-state
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

If Windows sandbox blocks `npm run build` or `npm run smoke:ai-adapter` with `spawn EPERM`, rerun the same command with approved elevated execution and report the sandbox note.

## Codex Pre-QA Result

- `npm run smoke:ai-confirmed-context`: PASS.
- `npm run smoke:ai-follow-up-needs`: PASS.
- `npm run smoke:ai-workflow-state`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS after sandbox `spawn EPERM` elevated rerun.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS after sandbox `spawn EPERM` elevated rerun; no Bearer / Authorization / sk-key leakage.

Observed bundle:

- Main JS: `377.99 kB`, below `400 kB`.
- Main CSS: `59.14 kB`, below `60 kB`.
- `aiContextPruning`: `8.56 kB`, below `9 kB`.
- `AiResponseReviewPanel`: `10.15 kB JS / 5.23 kB CSS`.
- `AiInterpreterChatPanel`: `10.38 kB JS / 6.73 kB CSS`.

## Static Checkpoints

1. `src/lib/aiConfirmedContext.js` exists and exports pure helpers.
2. `tools/verify-ai-confirmed-context-contract.mjs` exists.
3. `package.json` includes `smoke:ai-confirmed-context`.
4. `package-lock.json` is unchanged.
5. `confirmedContext` is included in `tempSessionPayload.state`.
6. `applyAssistantState()` restores `confirmedContext`.
7. `hasMeaningfulAssistantState()` accounts for `confirmedContext`.
8. `buildAssistantPrompt()` includes `## User-confirmed CMO values` only when entries exist.
9. Prompt language says not to replace confirmed values with guessed alternatives.
10. Duplicate confirmed entries collapse deterministically.
11. Confirmed entries expose source labels.
12. Context tab renders confirmed context values.
13. Removing a confirmed value does not clear `objectContext` or `databaseContext`.
14. Database quick promote buttons add Unit GUID, Platform DBID, Loadout ID, and memo entries.
15. Follow-up draft includes already-confirmed values when present.
16. Follow-up remains text-only and user-triggered.
17. `AiResponseReviewPanel` apply button remains controlled by parent `canApplyLua`.
18. `aiParsedResponse.isPasteReady` remains the only Lua apply gate.
19. `src/lib/aiContextPruning.js` hard blocks are not weakened.
20. Prompt-copy fallback remains available.
21. No new backend endpoint.
22. No CMO filesystem read/write, log tailing, or sidecar writer behavior.
23. No new `localStorage` or `sessionStorage` channel for confirmed context beyond the existing temp session/autosave path.
24. No raw `apiKey`, `Authorization`, `Bearer`, or `sk-` persistence.
25. `src/index.css` unchanged.
26. Main JS remains below `400 kB`.
27. Main CSS remains below `60 kB`.
28. `aiContextPruning` remains below `9 kB`.
29. AI adapter smoke reports no raw auth leakage.

## Expected Verdict

Approve only if all pipeline steps and static checkpoints pass. Report any CSS watch-line drift immediately because Main CSS has limited remaining headroom.
