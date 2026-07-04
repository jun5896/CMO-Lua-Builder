# Kimi QA Directive - Template Inspector Search / Filter UX

Status: ACTIVE

## Target

Target commit:

```text
5dd1da1 Add template inspector search filter UX
```

Scope:

- `src/components/TemplateLibrary.jsx`
- `src/components/PresetGuide.css`

Do not edit files and do not commit. Treat this as a read-only QA pass.

## Context

Track A1 implements the Template Inspector search/filter UX after Template Inspector annotation coverage reached `51 / 51`.

Claude taxonomy review answered the first-slice taxonomy:

- Quick filters: `Event`, `Mission`, `Unit`, `DBID / Loadout`, `RP / Zone`, `Doctrine / EMCON`, `KeyValue`
- Requirement badges: `engine test required`, `needs Side`, `needs Mission`, `needs Unit GUID`, `needs DBID`, `needs Loadout`, `needs RP / Zone`, `affects Side-wide`
- Excluded first-slice quick filters: standalone `GUID`, standalone `Side`, `Engine Test Required`, `demo values`
- Filter state is session-only.
- Multiple active filters use OR / union semantics.
- Every detailed source view keeps an AI draft warning footer.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run lint
npm run build
npm run smoke:ai-client-parser
npm run smoke:ai-adapter
```

If `npm run build` or `npm run smoke:ai-adapter` hits Windows sandbox `spawn EPERM`, rerun the same command with approved elevated execution and report that the first failure was sandbox-related.

## Expected Bundle Baseline

The Codex pre-QA build observed:

```text
Main JS:              366.67 kB  (< 400 kB)
Main CSS:              58.27 kB  (< 60 kB)
aiContextPruning:       8.56 kB  (< 9 kB)
PresetGuide JS:        33.99 kB  (lazy chunk, expected A1 growth)
PresetGuide CSS:        7.49 kB  (lazy chunk, expected A1 growth)
```

Main JS/CSS and `aiContextPruning` watch lines must remain under limit.

## Static Checkpoints

1. Target commit changes only `src/components/TemplateLibrary.jsx` and `src/components/PresetGuide.css`.
2. `QUICK_FILTERS` has exactly 7 first-slice filters.
3. Quick filters include `Event`, `Mission`, `Unit`, `DBID / Loadout`, `RP / Zone`, `Doctrine / EMCON`, and `KeyValue`.
4. Standalone `GUID` is not a quick filter.
5. Standalone `Side` is not a quick filter.
6. `Engine Test Required` / `engine test required` is not a quick filter.
7. `demo values` is not a quick filter or primary badge.
8. Multiple active filters use OR logic via `activeFilters.some(...)`.
9. Search query and active filters combine safely without bypassing either condition.
10. Search indexing includes annotation title, summary, beginner notes, prerequisites, safe pattern, AI hint, and checks.
11. Preset resources are filter-disabled in the first slice.
12. Resource rows show at most 2 safety badges.
13. The selected source detail card shows the full badge set.
14. Badge definitions include exactly 8 labels: `engine test required`, `needs Side`, `needs Mission`, `needs Unit GUID`, `needs DBID`, `needs Loadout`, `needs RP / Zone`, `affects Side-wide`.
15. `engine test required` uses warning styling and does not imply verified, safe, complete, tested, or production-ready status.
16. The universal footer text exists: `AI draft. CMO engine verification is still required before execution.`
17. Empty result state offers a reset action for both search and filters.
18. New styles live in `src/components/PresetGuide.css`; `src/index.css` is unchanged by the target commit.
19. No `apiKey`, `Authorization`, `Bearer`, `sk-`, `localStorage`, or `sessionStorage` strings are introduced in the changed files.
20. No filesystem write/delete behavior or sidecar root behavior is introduced in this UI-only change.
21. Manual prompt-copy fallback remains present in the assistant surfaces.
22. Lua apply remains gated by `aiParsedResponse.isPasteReady`.
23. Template Inspector annotations remain `51 / 51`, `0` missing.
24. `npm run smoke:ai-client-parser` remains PASS.
25. `npm run smoke:ai-adapter` reports no raw `Bearer` / `Authorization` / `sk-` leakage.
26. `package.json`, `package-lock.json`, `server/**`, `tools/**`, `public/**`, and docs are not changed by the target product commit.
27. No release tag is expected for this slice until QA is complete and Codex opens a release step.

## Codex Pre-QA Evidence

Codex already ran:

- A1 RED static verifier before implementation: FAIL as expected.
- `npm run lint`: PASS after implementation.
- A1 GREEN static verifier: PASS, coverage `51`.
- `npm run build`: PASS after approved rerun for sandbox `spawn EPERM`.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS after approved rerun for sandbox `spawn EPERM`; no raw `Bearer` / `sk-` leakage.
- Credential / storage / filesystem-write string scan on changed files: no matches.

## Final Report Format

Please report:

- Pipeline table
- Bundle table
- Static checkpoint table
- Any drift/blocker
- Final verdict

