# Kimi QA Request — Context Pruning Phase 3.2c-1 Geometry Omission

## Scope

Codex implemented the smallest Phase 3.2c step after Claude's detail/geometry review.

Goal: safely omit long RP coordinate / Zone polygon lines for non-geometry intents, while preserving them for `referencePointZone`.

Changed file:

- `src/lib/aiContextPruning.js`

## What Changed

1. Added `compactGeometryLines()`.

2. It detects long single-line geometry records:
   - `Reference point coordinates`
   - `RP coordinates`
   - `Zone polygons`
   - `Zone polygon points`

3. For non-`referencePointZone` intents:
   - Long RP coordinate lines become:
     - `objects.rp.coords`
   - Long Zone polygon lines become:
     - `objects.zones.polygons`
   - Labels are added to `decisions.omitted`.

4. For `referencePointZone` intent:
   - Geometry lines are preserved exactly.
   - No omission label is emitted.

5. No changes to:
   - object list pruning scope
   - ask-back hint conditions
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
aiContextPruning-*.js           8.86 kB
AiResponseReviewPanel-*.js      5.15 kB
AiInterpreterChatPanel-*.js     8.75 kB
```

Watch lines:

- Main JS remains under 400 kB.
- `aiContextPruning-*.js` remains under the Phase 3.2c-1 9 kB watch line.
- Main CSS remains unchanged.

Synthetic smoke:

- A `luaRepair` prompt with long `Reference point coordinates` and `Zone polygons` lines produced:
  - `omitted=["objects.rp.coords","objects.zones.polygons"]`
  - no hardBlock
- The same prompt with `referencePointZone` intent produced:
  - no geometry omission
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
3. Confirm `aiContextPruning-*.js < 9 kB`.
4. Confirm long RP coordinate lines are omitted only for non-`referencePointZone` intents.
5. Confirm long Zone polygon lines are omitted only for non-`referencePointZone` intents.
6. Confirm `referencePointZone` preserves geometry lines exactly.
7. Confirm omission labels:
   - `objects.rp.coords`
   - `objects.zones.polygons`
8. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block are unchanged.
9. Confirm Lua apply is still gated only by `aiParsedResponse.isPasteReady`.
10. Confirm provider profile override and manual prompt-copy fallback are unchanged.
11. Confirm no raw API key / Bearer / localStorage / sessionStorage path was added.

## Regression Criteria

Treat as regression if any of these occur:

- `aiContextPruning-*.js` is 9 kB or larger.
- Main JS exceeds 400 kB.
- `referencePointZone` prunes RP/Zone geometry.
- Geometry omission labels are missing from audit visibility.
- Any prompt path bypasses the `isPasteReady` Lua apply gate.
- Smoke output leaks raw `Bearer` or `sk-` values.
