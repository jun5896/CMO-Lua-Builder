# Kimi QA Request — Context Pruning Phase 3.2c-2a Mission Detail Omission

## Scope

Codex implemented the smallest mission-detail step after Phase 3.2c-1.

Goal: omit only long single-line mission detail / mission roster dumps for non-`missionAssignment` intents, while preserving them exactly for `missionAssignment`.

Changed file:

- `src/lib/aiContextPruning.js`

## What Changed

1. Added `compactMissionDetailLines()`.

2. It detects long single-line mission detail records:
   - `Mission detail`
   - `Mission details`
   - `Mission full detail`
   - `Mission full details`
   - `Mission roster`

3. For non-`missionAssignment` intents:
   - Long mission detail lines become:
     - `objects.missions.detail`
   - Label is added to `decisions.omitted`.

4. For `missionAssignment` intent:
   - Mission detail lines are preserved exactly.
   - No omission label is emitted.

5. No changes to:
   - geometry omission behavior
   - `referencePointZone` geometry preservation
   - object list pruning scope
   - ask-back hint semantics
   - DBID/GUID preservation
   - `confirmedIdentifiersStripped`
   - `isPasteReady` Lua apply gate
   - provider profile override path
   - prompt-copy fallback

## Codex Verification Already Run

Commands:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
```

Notes:

- First smoke run hit sandbox `spawn EPERM`.
- Escalated rerun passed with no Bearer / `sk-` leak.

Fresh build sizes:

```text
index-*.js                    395.56 kB
index-*.css                    64.08 kB
aiContextPruning-*.js           8.75 kB
AiResponseReviewPanel-*.js      5.15 kB
AiInterpreterChatPanel-*.js     8.75 kB
```

Watch lines:

- Main JS remains under 400 kB.
- `aiContextPruning-*.js` remains under the 9 kB watch line.
- Main CSS remains unchanged.

Synthetic smoke:

- A `luaRepair` prompt with long `Mission full detail` line produced:
  - `omitted=["objects.missions.detail"]`
  - final audit includes `objects.missions.detail`
  - no hardBlock

- The same prompt with `missionAssignment` intent produced:
  - no `objects.missions.detail` omission
  - no hardBlock

## Kimi Checks Requested

Please run:

```powershell
git status --short
npm run lint
npm run build
npm run smoke:ai-adapter
```

Report:

1. Pass/fail for lint/build/smoke.
2. Fresh bundle sizes:
   - `index-*.js`
   - `index-*.css`
   - `aiContextPruning-*.js`
3. Confirm `aiContextPruning-*.js < 9 kB` and report headroom.
4. Confirm long mission detail / roster lines are omitted only for non-`missionAssignment` intents.
5. Confirm `missionAssignment` preserves mission detail lines exactly.
6. Confirm omission label:
   - `objects.missions.detail`
7. Confirm Phase 3.2c-1 behavior is unchanged:
   - non-`referencePointZone` long RP coordinate lines emit `objects.rp.coords`
   - non-`referencePointZone` long Zone polygon lines emit `objects.zones.polygons`
   - `referencePointZone` preserves geometry lines
8. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block are unchanged.
9. Confirm Lua apply is still gated only by `aiParsedResponse.isPasteReady`.
10. Confirm provider profile override and manual prompt-copy fallback are unchanged.
11. Confirm no raw API key / Bearer / localStorage / sessionStorage path was added.

## Regression Criteria

Treat as regression if any of these occur:

- `aiContextPruning-*.js` is 9 kB or larger.
- Main JS exceeds 400 kB.
- `missionAssignment` prunes mission detail.
- Mission detail omission label is missing.
- `referencePointZone` prunes RP/Zone geometry.
- Any prompt path bypasses the `isPasteReady` Lua apply gate.
- Smoke output leaks raw `Bearer` or `sk-` values.
