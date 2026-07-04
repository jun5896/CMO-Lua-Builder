# Kimi QA Directive - Sidecar Cache Wording Closeout Docs

Status: APPROVED / ARCHIVED

## Target

Verify the sidecar cache wording release closeout documentation and agent handoff baselines.

Target commit:

```text
af84723 Document sidecar cache wording release closeout
```

## Scope

Read-only documentation / handoff consistency QA only.

Expected files:

- `docs/agent-ops/sidecar-cache-wording-release-closeout-2026-05-08.md`
- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `handoff/to-kimi/CURRENT_TASK.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`

## Hard Boundaries

- Do not edit files.
- Do not commit.
- Do not create tags or GitHub releases.
- Do not change dependencies.
- Do not run sidecar prune/move commands.
- Do not run broad scenario extraction or mass decoding.
- Treat `_archive/` files as evidence only.

## Required Commands

Run:

```powershell
git status --short --branch
git show --stat --oneline af84723
git show --name-only --oneline af84723
git diff --check af84723^ af84723
```

Only run `npm run verify:release` if you find a concrete baseline inconsistency that needs live verification.

## Static Checkpoints

1. Closeout doc exists at `docs/agent-ops/sidecar-cache-wording-release-closeout-2026-05-08.md`.
2. Closeout doc references `release-2026-05-08-cmo-lua-builder-sidecar-cache-wording`.
3. Closeout doc references tagged commit `f3539f5 Mark sidecar cache wording release in README`.
4. Closeout doc references GitHub Release URL and title `CMO Lua Builder Sidecar Cache Wording Update`.
5. Closeout doc records release state as not draft and not prerelease.
6. Closeout doc records product wording commit `2ba77a8 Polish sidecar cache settings wording`.
7. Closeout doc records product QA directive `f8f5dc2` and product QA closeout `564da22`.
8. Closeout doc records release QA directive `ed3b760` and release QA closeout `43d9287`.
9. Closeout doc records `npm run verify:release` and the expanded pipeline.
10. Closeout doc records bundle baseline `366.67 kB` JS / `58.27 kB` CSS / `8.56 kB` `aiContextPruning`.
11. Closeout doc records scenario baseline `1899` index / `1857` ready / `42` decoderFailed / `0` issues.
12. Closeout doc records unchanged invariants: sidecar root hint, `CMO_SCENARIO_SIDECAR_ROOT`, `.scen` not modified wording, sidecar command rows, prompt-copy fallback, and `isPasteReady` gate.
13. `final-stabilization-change-inventory-2026-05-05.md` includes the sidecar cache wording release closeout after transient sidecar UX closeout.
14. Kimi / Claude / Gemini `CURRENT_TASK.md` files reference the latest sidecar cache wording release and closeout where appropriate.
15. Handoff inboxes are clean: top-level `CURRENT_TASK.md` plus `_archive/` only, except this active Kimi directive.
16. Target commit does not modify `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json`.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - sidecar cache wording closeout docs hold.
```

Report any blocker or drift explicitly.

## Kimi QA Result

Final verdict:

```text
APPROVED - sidecar cache wording closeout docs hold.
```

Summary:

- Target commit: `af84723 Document sidecar cache wording release closeout`.
- `git status --short --branch`: clean (`main...origin/main`).
- `git show --stat --oneline af84723`: 5 files changed, 182 insertions, 8 deletions.
- `git show --name-only --oneline af84723`: 2 docs files and 3 handoff files only.
- `git diff --check af84723^ af84723`: no whitespace or syntax issues.
- Static checkpoints: 16 / 16 PASS.
- Scope check: no `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json` changes.
- Regression: none.
