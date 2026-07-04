# Kimi QA Directive - Transient Sidecar UX Closeout Docs

Status: APPROVED / ARCHIVED

## Purpose

Verify that the transient sidecar UX release closeout documentation and agent handoff baselines are internally consistent after Codex commit `1192379 Document transient sidecar UX release closeout`.

This is a read-only docs / handoff consistency pass. It is not a product-code QA pass.

## Target Commit

```text
1192379 Document transient sidecar UX release closeout
```

## Expected Scope

The target commit should only affect docs and handoff state:

- `docs/agent-ops/transient-sidecar-ux-release-closeout-2026-05-07.md`
- `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md`
- `handoff/to-kimi/CURRENT_TASK.md`
- `handoff/to-claude/CURRENT_TASK.md`
- `handoff/to-gemini/CURRENT_TASK.md`

## Boundaries

- Do not edit files.
- Do not commit.
- Do not create, delete, move, or retag Git tags.
- Do not edit GitHub Releases.
- Do not install dependencies.
- Do not prune or delete sidecars.
- Do not run broad scenario extraction.
- Treat `_archive/` as evidence only, not active instruction.

## Required Commands

```powershell
git status --short --branch
git show --stat --oneline 1192379
git show --name-only --oneline 1192379
```

Optional if you want a lightweight syntax/scope guard:

```powershell
git diff --check 1192379^ 1192379
```

Do not run `npm run verify:release` unless you detect a concrete docs/baseline inconsistency that needs full release re-verification.

## Static Checkpoints

1. `docs/agent-ops/transient-sidecar-ux-release-closeout-2026-05-07.md` exists.
2. Closeout doc references release tag `release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`.
3. Closeout doc references tagged commit `ffbd86e Refresh README for transient sidecar UX release`.
4. Closeout doc references GitHub Release URL and title `CMO Lua Builder Transient Sidecar UX Update`.
5. Closeout doc records release state as not draft and not prerelease.
6. Closeout doc records product UX commit `8f9641e`.
7. Closeout doc records release QA directive commit `386bf12` and closeout commit `175b17a`.
8. Closeout doc records `npm run verify:release` and `npm run smoke:scenario-transient`.
9. Closeout doc records bundle baseline `366.60 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
10. Closeout doc records scenario baseline `1899 / 1857 ready / 42 decoderFailed / issues 0`.
11. Closeout doc preserves invariants: `.scen` not modified, temp cache cleaned, `isPasteReady` gate unchanged.
12. `final-stabilization-change-inventory` includes a matching transient sidecar UX closeout section after the AI Lua safety wording closeout.
13. Kimi / Claude / Gemini `CURRENT_TASK.md` files reference the transient sidecar UX release as the latest published release / operating reference where appropriate.
14. Top-level handoff inboxes remain clean: each agent folder should contain only `_archive/` and `CURRENT_TASK.md`, except this active Kimi directive.
15. Target commit does not modify `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json`.

## Expected Baseline

- Latest public release: `release-2026-05-07-cmo-lua-builder-transient-sidecar-ux`
- Latest release docs commit: `1192379`
- Main JS: `366.60 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Scenario baseline: `1899 total / 1857 ready / 42 decoderFailed / issues 0`
- Sidecar audit baseline: dry-run, `24` orphans / about `5.6 MB`
- Release-tag QA: APPROVED, no regression

## Expected Final Verdict

```text
APPROVED - transient sidecar UX closeout docs hold.
```
