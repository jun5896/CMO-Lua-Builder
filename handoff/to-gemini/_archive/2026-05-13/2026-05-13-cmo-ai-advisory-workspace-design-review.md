# Gemini Directive - CMO AI Advisory Workspace Design Review

Status: ARCHIVED / SUPERSEDED

## Archive Note

This broad advisory workspace review was superseded by the more focused CMO Wiki / Code Assistant UX review:

```text
handoff/to-gemini/2026-05-13-cmo-wiki-code-assistant-ux-review.md
```

The broad direction has already been incorporated into:

```text
docs/superpowers/specs/2026-05-13-cmo-ai-advisory-workspace-design.md
docs/superpowers/specs/2026-05-13-cmo-wiki-code-assistant-design.md
```

## Original Goal

Review the approved direction for the CMO AI Advisory Workspace before Codex implements it.

This is a UX / information architecture / Korean wording review. Do not write code.

## Original Review Questions

1. Does the chat-first consultation flow match how a beginner CMO user would ask for help?
2. When the user says `CAP 미션 자동화 스크립트 만들어줘`, what should the assistant ask first?
3. Is the off-topic redirect wording polite enough while still keeping the tool focused?
4. Are the navigation labels `AI Chat`, `Lua Scratchpad`, `Wiki / Presets`, `CMO Bridge`, `Settings` clear, or would you rename them?
5. How should the UI explain that `.scen` browser attachment is limited, without making the app feel broken?
6. How should feature encyclopedia entries connect to related template examples and detailed beginner explanations?
7. Which old expert UI concepts should disappear from the default path, and which should remain behind an advanced disclosure?
8. What Korean copy should appear near `AI Chat에 질문 초안 만들기` so users understand it is text-only and not automatic execution?
9. How should the app say "the AI can guide you to check CMO API/tool values" without claiming live CMO inspection?
10. What is the smallest first implementation slice that would prove this direction is right?

## Original Known Facts

- Track A, B2, B3, and B4 are released.
- Current public release at the time was `release-2026-05-11-cmo-lua-builder-state-snapshot-import`.
- Local scenario scan found `1058` `.scen` files, `149` over `1.25 MB`, and a largest observed `.scen` of `17.49 MB`.
- Any redesign must avoid adding large main-bundle UI.
