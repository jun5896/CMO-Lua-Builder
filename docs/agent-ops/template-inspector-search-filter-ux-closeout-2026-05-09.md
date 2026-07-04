# Template Inspector Search / Filter UX Closeout - 2026-05-09

## Purpose

Close Track A1 Template Inspector Search / Filter UX as an approved post-release operating slice.

This slice builds on the Template Inspector completion release by making the `51 / 51` annotation set easier to navigate. It adds quick filters, safety badges, result counts, and a persistent draft warning without changing parser, adapter, context-pruning, sidecar, package, or release-tag behavior.

## Baseline

Current public release remains:

- Release tag: `release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
- Tagged commit: `59bdab9 Mark template inspector completion release in README`.
- GitHub Release: `https://github.com/jun5896/CMO-Lua-Builder/releases/tag/release-2026-05-09-cmo-lua-builder-template-inspector-completion`.
- Release title: `CMO Lua Builder Template Inspector Completion`.

Track A1 commits:

- Plan commit: `898e35b Add template inspector search filter plan`.
- Claude taxonomy review directive commit: `1cdbcf4 Add Claude template inspector taxonomy review directive`.
- Product commit: `5dd1da1 Add template inspector search filter UX`.
- Kimi QA directive commit: `f84bdf2 Open template inspector search filter QA directive`.
- Kimi / Claude archive commit: `9768910 Archive template inspector search filter QA`.
- Kimi QA archive: `handoff/to-kimi/_archive/2026-05-09/2026-05-09-template-inspector-search-filter-ux-qa.md`.
- Claude review archive: `handoff/to-claude/_archive/2026-05-09/2026-05-09-template-inspector-filter-taxonomy-review.md`.

## User-Facing Change

Template Inspector now supports first-slice quick filtering:

- `Event`
- `Mission`
- `Unit`
- `DBID / Loadout`
- `RP / Zone`
- `Doctrine / EMCON`
- `KeyValue`

The filter model intentionally avoids overly broad filters:

- No standalone `GUID` quick filter.
- No standalone `Side` quick filter.
- No `Engine Test Required` quick filter.
- No `demo values` primary filter or badge.

Multiple active filters use OR / union semantics. Search text and filters combine together, so a resource must satisfy both the text query and at least one active filter when filters are active.

Safety badges added:

- `engine test required`
- `needs Side`
- `needs Mission`
- `needs Unit GUID`
- `needs DBID`
- `needs Loadout`
- `needs RP / Zone`
- `affects Side-wide`

Each resource row shows up to two badges. The selected detail card shows the full badge set.

Every selected source detail now includes:

```text
AI draft. CMO engine verification is still required before execution.
```

## Verified Pipeline

Codex pre-QA:

- RED static verifier: failed before implementation, as expected.
- `npm run lint`: PASS.
- A1 static verifier: PASS, Template Inspector annotations `51 / 51`.
- `npm run build`: PASS after approved rerun for sandbox `spawn EPERM`.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS after approved rerun for sandbox `spawn EPERM`; no raw `Bearer`, `Authorization`, or `sk-` leakage.

Kimi QA:

- `git status --short --branch`: clean (`main...origin/main`).
- `git show --stat --oneline 5dd1da1`: `2` files, `286` insertions, `7` deletions.
- `git show --name-only --oneline 5dd1da1`: `TemplateLibrary.jsx`, `PresetGuide.css`.
- `git diff --check 5dd1da1^ 5dd1da1`: no whitespace issues.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-client-parser`: PASS.
- `npm run smoke:ai-adapter`: PASS, HTTP 401 sanitization and no auth leakage.
- Static checkpoints: 27 / 27 PASS.
- Final verdict: APPROVED.
- Regression: none.

## Stable Baseline

- Main JS: `366.67 kB`.
- Main CSS: `58.27 kB`.
- `aiContextPruning`: `8.56 kB`.
- `PresetGuide` lazy JS: `33.99 kB`.
- `PresetGuide` lazy CSS: `7.49 kB`.
- Template Inspector annotations: `51 / 51`, `0` missing.

## Unchanged Contracts

- Manual prompt-copy fallback remains available.
- Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.
- Parser response contract is unchanged.
- AI adapter provider / secret redaction behavior is unchanged.
- Context pruning and `aiContextPruning` bundle are unchanged.
- Scenario sidecar root, transient open behavior, and sidecar commands are unchanged.
- `package.json`, `package-lock.json`, `server/**`, `tools/**`, `public/**`, and docs were not changed by the product commit.
- No release tag was created for this slice.

## Agent State

- Kimi: A1 product QA approved and archived; next useful task is docs/handoff-only QA for this closeout.
- Claude: taxonomy review answered and archived; no active directive.
- Gemini: standby; no separate wording review opened.

## Next Work Candidates

1. Ask Kimi for docs/handoff-only QA on this closeout.
2. If approved, archive that directive and return all inboxes to standby.
3. Decide whether A1 should receive a patch release tag or stay as post-release operating work.
4. Continue Track A2 AI drafting workflow tightening, or switch to Track B0 CMO Integration Probe if the user wants the in-game integration track next.
