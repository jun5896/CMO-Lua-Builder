# Kimi QA Directive - Template Inspector Annotations Closeout Docs

Status: APPROVED / ARCHIVED

## Target

Verify the Template Inspector annotations release closeout documentation commit.

Target commit:

```text
3ff471e Document template inspector annotations release closeout
```

## Scope

Read-only docs / handoff consistency QA.

Do not edit files, do not commit, do not retag, and do not create another release.

## Required Commands

Run:

```powershell
git status --short --branch
git show --stat --oneline 3ff471e
git show --name-only --oneline 3ff471e
git diff --check 3ff471e^ 3ff471e
```

No product pipeline is required unless static review finds product drift. This commit should only touch docs and handoff files.

## Static Checkpoints

1. Closeout doc exists: `docs/agent-ops/template-inspector-annotations-release-closeout-2026-05-09.md`.
2. Closeout doc references release tag `release-2026-05-09-cmo-lua-builder-template-inspector-annotations`.
3. Closeout doc references tagged commit `f46385b Mark template inspector annotation release in README`.
4. Closeout doc references GitHub Release URL and title `CMO Lua Builder Template Inspector Annotation Update`.
5. Closeout doc records release state as not draft and not prerelease.
6. Closeout doc records Batch 1 product commit `05fd836` and Batch 2 product commit `246c175`.
7. Closeout doc records Batch 1 QA commits `ecc1964` / `350a515`.
8. Closeout doc records Batch 2 QA commits `8618dee` / `6d553b7`.
9. Closeout doc records release QA commits `1c8fd88` / `d85ea78`.
10. Closeout doc records agent baseline refresh commit `1d15092`.
11. Closeout doc lists the 10 newly annotated templates.
12. Closeout doc records annotation coverage `18 / 51` and `33` missing.
13. Closeout doc records `npm run verify:release` and the six-command expanded pipeline.
14. Closeout doc records bundle baseline `366.67 kB` JS / `58.27 kB` CSS / `8.56 kB` `aiContextPruning`.
15. Closeout doc records scenario baseline `1899` index / `1857 readyWithInternalSidecar` / `42 decoderFailed` / `0` issues.
16. Closeout doc records sidecar audit dry-run baseline `3799` protected, `24` orphans / about `5.6 MB`.
17. Closeout doc preserves invariants: no source/package behavior change, source-anchored DBID/Loadout/GUID/Side/Mission/RP/Zone guidance, CMO engine validation required, and `isPasteReady` gate unchanged.
18. `docs/agent-ops/final-stabilization-change-inventory-2026-05-05.md` includes a Template Inspector annotations closeout section after the sidecar cache wording closeout.
19. Kimi / Claude / Gemini `CURRENT_TASK.md` files reference the new closeout document.
20. Target commit changes only docs and handoff files; no `src/**`, `server/**`, `tools/**`, `package.json`, or `package-lock.json` changes.
21. Handoff inbox shape is expected: Kimi has `CURRENT_TASK.md`, `_archive/`, and this active directive; Claude/Gemini have `CURRENT_TASK.md` and `_archive/` only.

## Expected Verdict

If all checks pass, report:

```text
APPROVED - template inspector annotations closeout docs hold.
```

Report any blocker or drift explicitly.

## Kimi QA Result

Final verdict:

```text
APPROVED - template inspector annotations closeout docs hold.
```

Summary:

- Target commit: `3ff471e Document template inspector annotations release closeout`.
- `git status --short --branch`: clean (`main...origin/main`).
- `git show --stat --oneline 3ff471e`: 5 files changed, 197 insertions, 1 deletion.
- `git show --name-only --oneline 3ff471e`: docs 2 files plus handoff 3 files.
- `git diff --check 3ff471e^ 3ff471e`: PASS, no whitespace or syntax issues.
- Static checkpoints: 21 / 21 PASS.
- Closeout doc records release tag, tagged commit, GitHub Release URL/title/state, batch product/QA commits, release QA commits, agent baseline refresh commit, 10 templates, `18 / 51` coverage, `verify:release`, bundle/scenario/sidecar baselines, and safety invariants.
- Kimi / Claude / Gemini `CURRENT_TASK.md` files reference the new closeout document.
- Target commit changes only docs and handoff files; no product/package drift.
- Handoff inbox shape matches expected state.
- Regression: none.
