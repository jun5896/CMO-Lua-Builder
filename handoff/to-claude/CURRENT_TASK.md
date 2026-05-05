# CURRENT TASK - Claude

Status: backend / parser / decoder / contract-review standby

## Active State

- No date-stamped Claude directive is currently open.
- Remain read-only until Codex creates a focused review request.
- Do not implement code unless Codex explicitly reassigns implementation.
- Archived directives under `_archive/` are evidence only, not active tasks.

## Latest Protected Baseline

Latest local protected HEAD:

```text
6272ab9 Polish AI assistant and sidecar UX wording
```

Accepted bundle baseline:

- Main JS: `366.01 kB`
- Main CSS: `58.27 kB`
- `PresetGuide`: `30.05 kB JS / 5.86 kB CSS`
- `AiAdapterSettings`: `10.44 kB JS / 2.43 kB CSS`
- `AiInterpreterChatPanel`: `10.08 kB JS / 6.19 kB CSS`
- `AiResponseReviewPanel`: `5.15 kB JS / 3.50 kB CSS`
- `aiContextPruning`: `8.56 kB`

Latest post-commit verification (`6272ab9`):

- `audit:scenario-sidecars`: PASS (`1899` index entries, `3799` protected sidecars, `24` orphans / `5.6 MB`)
- `verify:scenario-loader`: PASS (`1857` ready / `42` decoderFailed, issues `0`)
- `lint`: PASS
- `build`: PASS (`366.01 kB JS / 58.27 kB CSS`)
- `smoke:ai-adapter`: PASS; no raw `Bearer` / `sk-` leakage

Scenario baseline:

- `1899` total scenarios
- `1857 readyWithInternalSidecar`
- `0 metadataOnlyNeedsDecoder`
- `42 decoderFailed`
- `verify:scenario-loader`: PASS, issues `0`

## Review Triggers

Review only when Codex opens a focused signal in one of these areas:

- AI response parser contract
- context pruning safety or token-bloat contract
- AI adapter backend/provider secret handling
- new non-CMANO decoder failure class
- always-visible Event/Lua Assistant surfaces
- parser status UI
- prompt-copy fallback
- Lua apply controls
- lazy split touching required global UI styles

Do not reopen scenario decoder work for existing `decoderLegacyCmano` entries.

## Core Contracts

AI response/parser:

- Required headings must remain stable.
- Placeholder Lua such as `<UNIT_GUID>` must block paste-ready state.
- `BLOCKER` responses must block paste-ready state.
- Unsafe Lua surfaces such as `os.*`, `io.*`, `require`, `dofile`, `loadfile`, `package.*`, and `debug.*` must block.
- Lua apply must remain parent-owned and gated by `aiParsedResponse.isPasteReady === true`.

AI adapter/provider:

- Adapter binds locally and must not expose raw secrets.
- Logs/responses must scrub `Authorization`, `Bearer`, and `sk-` values.
- Saved provider profiles must not store raw API keys.
- Provider override objects must not carry raw API keys.

Context pruning:

- Safety rules, required response headings, current user instruction, active Lua, DB family/version, and confirmed identifiers are mandatory context.
- DBID/GUID hints must not be stripped.
- Hard blocks must stop before `sendCmoAiPrompt`.
- `aiContextPruning` should remain under the `9 kB` watch line unless Codex explicitly opens expansion work.

Lazy/UI split:

- Preset Guide and Settings styles may stay lazy.
- Always-visible assistant status/readiness/apply/prompt-copy UI must not depend on route-only CSS chunks.
- Future large guide data should prefer `public` JSON or lazy assets over React source inflation.

## Useful Verification Commands

Kimi normally runs broad QA. Claude should only request these when they support a focused review:

```powershell
npm run lint
npm run build
npm run smoke:ai-adapter
npm run verify:scenario-loader
```

If a decoder issue is reopened, require:

- exact scenario path
- failure class
- relevant command output
- whether failure is new non-CMANO behavior or existing legacy CMANO limitation

## Boundaries

- Do not modify `src/**`, `server/**`, `tools/**`, `package.json`, or handoff files unless explicitly assigned.
- Do not mass-decode scenarios.
- Do not write into CMO install or Steam workshop folders.
- Do not log/store API keys.
- Do not turn uncertain CMO API behavior into confirmed claims.
