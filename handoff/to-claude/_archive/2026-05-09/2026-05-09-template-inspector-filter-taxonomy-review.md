# Claude Review Directive - Template Inspector Filter Taxonomy

## Status

Active focused review request.

## Role

Claude is assigned as a read-only design and risk reviewer for the next Track A slice:

```text
A1 Template Inspector Search and Filter UX
```

Codex will implement. Kimi will QA after implementation. Claude should not implement product code for this directive.

## Context

The Template Inspector annotation dataset is complete:

```text
public/template-annotations.json: 51 / 51 annotated resources, 0 missing
```

The new roadmap splits future work into:

- Track A: AI Script Editor Automation.
- Track B: CMO Scenario Integration.

The next recommended implementation is Track A1, not CMO filesystem work:

```text
docs/superpowers/specs/2026-05-09-ai-editor-cmo-integration-roadmap-design.md
```

The CMO Integration Probe design remains relevant but is not the current review target:

```text
docs/superpowers/specs/2026-05-09-cmo-integration-probe-design.md
```

## Files To Review

Read-only review scope:

- `docs/superpowers/specs/2026-05-09-ai-editor-cmo-integration-roadmap-design.md`
- `public/template-annotations.json`
- `public/cmo-dev-work/manifest.json`
- `src/components/TemplateLibrary.jsx`
- `src/components/PresetGuide.jsx`
- `src/components/PresetGuide.css`

Do not edit these files.

## Requested Review

Review the proposed A1 Template Inspector Search and Filter UX before Codex implementation.

Please answer these questions:

1. What quick filters should A1 expose first?
2. Which filters should be derived from manifest metadata, and which should be derived from annotation text?
3. What requirement badges should be shown on each resource row or detail card?
4. Which badge labels could mislead users into thinking AI Lua is engine-verified?
5. Which annotation phrases should be searched but not surfaced as badges?
6. Which filters are too broad or too noisy for the first slice?
7. What focused Kimi QA checkpoints should Codex include after implementation?

## Initial Codex Recommendation To Review

Proposed first-slice quick filters:

- Event
- Mission
- Unit
- DBID / Loadout
- GUID
- RP / Zone
- Weather
- Side / Posture
- KeyValue
- Engine Test Required

Proposed first-slice badges:

- needs Side
- needs Mission
- needs GUID
- needs DBID
- needs Loadout
- needs RP / Zone
- needs CMO test
- demo values

Proposed implementation boundary:

- Extend `resourceSearchText()` to include annotation text.
- Add quick filter state inside `TemplateLibrary.jsx`.
- Derive badges from annotation text and resource metadata.
- Add focused CSS inside `PresetGuide.css`.
- Keep work inside the existing Preset Guide lazy chunk.
- Do not touch AI adapter, parser, context pruning, scenario sidecar tools, or CMO folders.

## Safety Constraints

Do not recommend anything that weakens these invariants:

- AI Lua remains a draft until CMO engine verification.
- `isPasteReady === true` remains the only apply/save gate.
- Prompt-copy and request-copy fallback remain visible.
- No generated sidecar data returns to `public/` or `dist/`.
- No CMO folder writes for A1.
- No raw API key, Bearer, Authorization, or `sk-` handling changes.
- No automatic AI send.

## Deliverable

Return a concise review with these sections:

1. Verdict
2. Recommended filter taxonomy
3. Recommended badge taxonomy
4. Wording risks
5. Implementation guardrails for Codex
6. Kimi QA checklist
7. Open questions, if any

No code changes. No commits. No broad refactor.

If you need to write a durable artifact, create at most one review memo under:

```text
handoff/to-codex/
```

Do not modify `src/**`, `server/**`, `tools/**`, `package.json`, `package-lock.json`, or existing handoff files.
