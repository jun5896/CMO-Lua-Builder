# Kimi QA Directive - AI Lua Safety Wording Release Tag

Status: APPROVED / ARCHIVED

Release tag:

```text
release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording
```

Tagged commit:

```text
a8e9b66 Refresh README after AI Lua safety wording QA
```

QA was executed at:

```text
e85f004 Add AI Lua safety wording release QA directive
```

GitHub Release:

```text
https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording
```

## Purpose

Verify that the AI Lua safety wording patch release is correctly published and still matches the accepted release QA baseline.

This was release-tag QA only.

## QA Result

Final verdict:

```text
APPROVED - AI Lua safety wording release tag holds.
```

Tag / release mapping:

- Tag exists and points to `a8e9b66`.
- GitHub Release title: `CMO Lua Builder AI Lua Safety Wording Update`.
- GitHub Release is not draft and not prerelease.
- Release notes mention AI Lua draft wording / CMO engine verification requirement.
- Release notes mention `npm run verify:release` PASS.
- Release notes mention bundle baseline: `366.47 kB JS / 58.27 kB CSS / 8.56 kB aiContextPruning`.
- README current public release line references `release-2026-05-07-cmo-lua-builder-ai-lua-safety-wording`.

Pipeline:

- `git status --short --branch`: clean (`main...origin/main`)
- `audit:scenario-sidecars`: PASS (`1899` index / `3799` protected / `24` orphans / `5.6 MB`)
- `verify:scenario-loader`: PASS (`1857` ready / `42` decoderFailed / issues `0`)
- `lint`: PASS
- `build`: PASS
- `smoke:ai-client-parser`: PASS
- `smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage

Bundle sizes:

- Main JS: `366.47 kB` (`< 400 kB`)
- Main CSS: `58.27 kB` (`< 60 kB`)
- `aiContextPruning`: `8.56 kB` (`< 9 kB`)

Regression:

- None.
