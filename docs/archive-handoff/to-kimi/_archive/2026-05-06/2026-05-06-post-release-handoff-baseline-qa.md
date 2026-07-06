# Kimi QA Directive - Post-Release Handoff Baseline

Date: 2026-05-06
Requested by: Codex
Mode: read-only QA / commit-hygiene verification

## Purpose

Verify that the repository is in a clean post-release operating state after the sidecar onboarding release.

The important distinction to confirm:

- Product release tag: `release-2026-05-06-cmo-lua-builder-sidecar-onboarding`
- Product release commit: `d215245 Improve sidecar root onboarding errors`
- Current `main` HEAD: `ba8005c Refresh handoff baselines after onboarding release`
- `ba8005c` is documentation / agent handoff baseline refresh only, not part of the product release tag.

## Boundaries

- Do not modify files.
- Do not commit.
- Do not delete or archive this directive; Codex will archive it after your QA report is delivered.
- Do not run broad scenario extraction or sidecar pruning.
- Do not classify the known `42` `decoderFailed` legacy CMANO items as new regressions.

## Required Checks

Run or statically verify:

```powershell
git status --short --branch
git log -5 --oneline
git tag --points-at d215245
git tag --points-at ba8005c
```

Expected:

- Working tree clean before QA, except this active directive may appear if Codex has not committed it yet.
- `main` tracks `origin/main`.
- `ba8005c` is the latest local HEAD.
- `release-2026-05-06-cmo-lua-builder-sidecar-onboarding` points at `d215245`.
- No release tag points at `ba8005c`.

## Handoff Inbox Checks

Inspect top-level files only:

```powershell
Get-ChildItem -File handoff\to-kimi
Get-ChildItem -File handoff\to-claude
Get-ChildItem -File handoff\to-gemini
```

Expected:

- `handoff/to-kimi/` contains `CURRENT_TASK.md` plus this directive.
- `handoff/to-claude/` contains only `CURRENT_TASK.md`.
- `handoff/to-gemini/` contains only `CURRENT_TASK.md`.
- Archived files remain under `_archive/` and are evidence only.

## CURRENT_TASK Consistency Checks

Verify all three current task files now reference:

- latest protected HEAD: `d215245 Improve sidecar root onboarding errors`
- latest published release: `release-2026-05-06-cmo-lua-builder-sidecar-onboarding`
- fresh-clone QA evidence for the release tag

Files:

```text
handoff/to-kimi/CURRENT_TASK.md
handoff/to-claude/CURRENT_TASK.md
handoff/to-gemini/CURRENT_TASK.md
```

Kimi-specific expectation:

- Kimi may list all three published releases.
- Kimi should still retain the accepted bundle baseline:
  - Main JS `366.01 kB`
  - Main CSS `58.27 kB`
  - `aiContextPruning` `8.56 kB`

Claude-specific expectation:

- Claude remains standby.
- Review triggers are unchanged.
- Context pruning and AI safety contracts remain documented.

Gemini-specific expectation:

- Gemini remains standby.
- Wording status mentions sidecar CLI onboarding guidance.
- Beginner wording boundaries remain unchanged.

## Optional Lightweight Verification

Only run if you see drift in the documents or git state:

```powershell
npm run lint
npm run build
```

Do not run `smoke:ai-adapter` unless Codex specifically asks; this directive is docs/handoff consistency only.

## Report Format

Return a compact QA report with:

- git HEAD / release tag mapping
- handoff inbox table
- CURRENT_TASK consistency result
- any drift or blocker
- final verdict

Expected final verdict if everything matches:

```text
APPROVED - post-release handoff baseline is consistent.
```
