# Kimi QA Request — Context Pruning Phase 3.2c-1 Headroom Recovery

## Scope

Codex completed a no-feature-expansion headroom pass after Phase 3.2c-1.

Goal: keep geometry omission behavior unchanged while moving `aiContextPruning` farther below the 9 kB watch line before any Phase 3.2c-2 work.

Changed file:

- `src/lib/aiContextPruning.js`

## What Changed

1. Replaced `plannedOmissions()` array values with compact comma-separated labels.

2. Removed the API/Event/Trigger audit-label lookup object and derived the audit label directly from the matched label.

3. Replaced ask-back intent arrays with compact regular-expression checks.

4. Converted object-list rule objects from `{ limit, label }` to compact tuple form `[limit, label]`.

5. Shortened Lua bundle summary wording:
   - `Lua file` fallback became `Lua`
   - per-file rows use `L` and `C` counters
   - `### Per-file analysis` became `### Files`

6. No pruning scope expansion.

7. No changes to:
   - geometry omission conditions
   - `referencePointZone` geometry preservation
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
aiContextPruning-*.js           8.49 kB
AiResponseReviewPanel-*.js      5.15 kB
AiInterpreterChatPanel-*.js     8.75 kB
```

Improvement:

```text
aiContextPruning-*.js  8.86 kB -> 8.49 kB
Headroom vs 9 kB       0.14 kB -> 0.51 kB
```

Synthetic smoke:

- A mission-assignment prompt with summarized units, long RP coordinates, long Zone polygons, and long API list still produced:
  - `omitted=["objects.rp.coords","objects.zones.polygons"]`
  - `summarized=["analysis.apiCalls.top10","objects.units.list"]`
  - `askBackHints=["Unit name disambiguation","Side name"]`
  - final audit includes `plannedOmit=rpZones,templates,otherSides`
  - no hardBlock

- The same prompt with `referencePointZone` intent still preserved geometry:
  - no `objects.rp.coords` omission
  - no `objects.zones.polygons` omission

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
4. Confirm behavior is unchanged from Phase 3.2c-1:
   - non-`referencePointZone` long RP coordinate lines emit `objects.rp.coords`
   - non-`referencePointZone` long Zone polygon lines emit `objects.zones.polygons`
   - `referencePointZone` preserves geometry lines
5. Confirm ask-back behavior still works:
   - `Unit name disambiguation`
   - `Side name`
   - matched references still suppress unnecessary disambiguation
6. Confirm DBID/GUID preservation and `confirmedIdentifiersStripped` hard-block are unchanged.
7. Confirm Lua apply is still gated only by `aiParsedResponse.isPasteReady`.
8. Confirm provider profile override and manual prompt-copy fallback are unchanged.
9. Confirm no raw API key / Bearer / localStorage / sessionStorage path was added.

## Regression Criteria

Treat as regression if any of these occur:

- `aiContextPruning-*.js` is 9 kB or larger.
- Main JS exceeds 400 kB.
- `referencePointZone` prunes RP/Zone geometry.
- Geometry omission labels are missing.
- Ask-back hints stop reaching the final audit text.
- Any prompt path bypasses the `isPasteReady` Lua apply gate.
- Smoke output leaks raw `Bearer` or `sk-` values.
