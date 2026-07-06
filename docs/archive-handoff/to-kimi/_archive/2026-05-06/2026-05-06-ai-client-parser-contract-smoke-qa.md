# Kimi QA Directive - AI Client Parser Contract Smoke

Date: 2026-05-06
Requested by: Codex
Mode: read-only QA / parser-contract regression monitor

## Purpose

Verify the no-dependency smoke test added in:

```text
607196f Add AI client parser contract smoke
```

This is a small test-foundation step, not a Vitest rollout. It adds a Node `assert` smoke script for the AI adapter client parser contract.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not archive this directive; Codex will archive it after your report.
- Do not install Vitest or any new test framework.
- Do not change `package-lock.json` unless Codex opens a separate dependency task.
- Do not run broad scenario extraction or sidecar pruning.
- Treat `607196f` as an operating/test smoke commit, not a product release tag.

## Required Pipeline

Run:

```powershell
git status --short --branch
npm run smoke:ai-client-parser
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `smoke:ai-adapter` hits `spawn EPERM`, report it as sandbox/environment unless code evidence says otherwise. Codex can rerun with approved spawn permissions.

## Expected Bundle Watch

Because the new script is under `tools/`, production bundle sizes should remain unchanged:

- Main JS should remain about `366.29 kB` and under `400 kB`.
- Main CSS should remain `58.27 kB` and under `60 kB`.
- `aiContextPruning` should remain `8.56 kB` and under `9 kB`.

## Static Checkpoints

Verify:

1. `package.json` contains `smoke:ai-client-parser`.
2. `tools/verify-ai-client-parser-contract.mjs` exists.
3. The smoke script imports only Node built-ins and existing `src/lib/aiAdapterClient.js` exports.
4. No new dependency or devDependency was added.
5. `package-lock.json` was not changed for this commit.
6. The script covers `extractAssistantText` for:
   - OpenAI-compatible response shape
   - Ollama response shape
   - adapter error shape
7. The script covers `parseAiInterpreterResponse` for:
   - paste-ready response with all required headings
   - missing `Paste-ready Lua` heading
   - placeholder Lua block
   - unsafe Lua surface
   - `BLOCKER` response
8. README QA pipeline includes `npm run smoke:ai-client-parser`.
9. Existing `smoke:ai-adapter` redaction behavior still passes.

## Report Format

Return a compact QA report with:

- pipeline results
- bundle sizes
- static checkpoint table
- dependency/package-lock status
- any regression
- final verdict

Expected final verdict if all checks pass:

```text
APPROVED - AI client parser contract smoke holds.
```
