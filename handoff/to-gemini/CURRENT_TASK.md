# CURRENT TASK - Gemini

Status: Korean UX wording / beginner guidance / prompt behavior reviewer

## Active State

- No date-stamped Gemini wording directive is currently open.
- Wait for Codex to request a focused wording review.
- Do not edit code or handoff files unless explicitly reassigned.
- Keep output UI-ready and compact.

## Latest Protected Baseline

Latest local protected HEAD:

```text
6272ab9 Polish AI assistant and sidecar UX wording
```

Current user-facing product model:

- `.scen` files open metadata first.
- Compressed scenario internals require local sidecar generation.
- Prepared sidecars are local/generated/regenerable files.
- Sidecars are not permanent edits to `.scen`.
- The web UI auto-links sidecars when present.

Current bundle baseline:

- Main JS: `366.01 kB`
- Main CSS: `58.27 kB`

Keep wording compact because the UI has watch lines for bundle size.

Latest wording status:

- Gemini compact UX wording directive was archived after Codex incorporated the safe subset.
- AI assistant wording now reinforces no-invention ask-back and CMO engine validation.
- Sidecar/cache wording now distinguishes local sidecar cache from temporary extraction cache and states that `.scen` files are not modified.
- Post-commit QA on `6272ab9`: lint/build/smoke PASS, no auth leak.

## Wording Review Triggers

Review only when Codex asks for wording around:

- `템플릿 / 프리셋 삽입`
- `폼 추가 / Builder Forms`
- `사용자 지정 프리셋 > 수정`
- `현재 표시된 프리셋 폼만 저장합니다`
- AI interpreter chat / follow-up guidance
- sidecar/cache explanation
- Template Inspector beginner notes
- ask-back guidance for ambiguous CMO goals

## Preferred Language Rules

Scenario / sidecar wording:

- Prefer `sidecar 준비 필요`, `로컬 분석 파일`, `임시 추출 캐시`.
- Avoid saying `.scen` was modified.
- Avoid saying deletion is always safe unless the UI also says sidecars must be regenerated.
- Avoid calling metadata-only state a failure.
- Existing `ContentScenario` support is a success path, not a failure.
- Existing `decoderLegacyCmano` items are legacy limitations unless Codex says a new class appeared.

AI assistant wording:

- Explain that AI can draft Lua, but CMO engine testing is still required.
- Reinforce ask-back when Side, Mission, Unit GUID, DBID, Loadout ID, RP, or Zone is missing.
- Keep warnings short and actionable.
- Do not imply AI output is safe to paste unless paste-ready validation passes.

Template / preset wording:

- `템플릿 / 프리셋 삽입`: templates/presets append below existing Lua and preserve current text.
- `폼 추가 / Builder Forms`: belongs to Preset Guide and creates editable preset forms.
- `수정`: replaces the current builder form/settings with the saved preset.
- `현재 표시된 프리셋 폼만 저장합니다`: saves one displayed form, avoiding accidental bundle presets.

Template Inspector notes:

- Keep exact CMO API names such as `ScenEdit_*`, `Tool_*`, `VP_*`.
- Mark uncertain API behavior, DBID, Loadout ID, GUID, Side, Mission, RP, or Zone claims as `Codex 확인 필요`.
- Do not claim engine-tested behavior unless Codex/user verified it.

## Output Shape

Prefer concise Korean:

- label candidates
- one-line tooltip text
- short empty-state text
- compact warning text
- beginner checklist
- small ambiguity/ask-back table

Avoid long tutorial prose unless Codex explicitly asks.

## Boundaries

- Do not edit code.
- Do not write into CMO install/workshop folders.
- Do not modify `.scen` files.
- Do not batch prepare scenarios.
- Do not paste long copyrighted manual/forum text.
