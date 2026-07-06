# Kimi QA Directive - README Sidecar Root Guidance

Date: 2026-05-06
Requested by: Codex
Mode: read-only QA / docs consistency monitor

## Purpose

Verify the README update added in:

```text
e6f2057 Update README sidecar root guidance
```

This is a documentation-only change. It aligns README sidecar guidance with the Settings > Storage UI hint and removes an obsolete early baseline reference.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not archive this directive; Codex will archive it after your report.
- Do not run broad scenario extraction or sidecar pruning.
- Do not change release tags.
- Treat `e6f2057` as a README / operating-docs polish commit, not a new product release tag.

## Required Checks

Run or statically verify:

```powershell
git status --short --branch
git log -6 --oneline
```

Optional for docs-only confidence:

```powershell
npm run lint
npm run build
```

Do not run `smoke:ai-adapter` unless you see code drift. This directive is README consistency only.

## Static Checkpoints

Verify:

1. `README.md` no longer claims the current GitHub baseline is `556d99e`.
2. `README.md` names the current public product release:
   - `release-2026-05-06-cmo-lua-builder-sidecar-onboarding`
3. README explains that `main` may include post-release handoff/QA docs and small operating UI polish.
4. README Sidecar Storage still states original `.scen` files are not modified.
5. README includes the concrete external root:
   - `C:\Users\dlwls\.codex\cmo-scenario-sidecars`
6. README now mirrors the Settings UI hint:
   - `%USERPROFILE%\.codex\cmo-scenario-sidecars`
7. README still documents `CMO_SCENARIO_SIDECAR_ROOT` as the override.
8. README bundle baseline reflects the UI hint build:
   - Main JS `366.29 kB`
   - Main CSS `58.27 kB`
   - `aiContextPruning` `8.56 kB`
9. No source files changed as part of this README commit.

## Report Format

Return a compact QA report with:

- git/head status
- README checkpoint table
- optional lint/build result if run
- any drift or blocker
- final verdict

Expected final verdict if all checks pass:

```text
APPROVED - README sidecar root guidance is consistent.
```
