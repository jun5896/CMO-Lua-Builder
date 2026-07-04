# Gemini Directive - CMO Wiki / Code Assistant UX Review

Status: ACTIVE

## Goal

Review the CMO Wiki and Lua editor code-assistant design before Codex implementation.

This is a UX, information architecture, beginner guidance, and Korean wording review. Do not write code.

## Read These Files

Required:

- `docs/superpowers/specs/2026-05-13-cmo-wiki-code-assistant-design.md`
- `docs/superpowers/specs/2026-05-13-cmo-ai-advisory-workspace-design.md`
- `src/components/PresetGuide.jsx`
- `src/components/TemplateLibrary.jsx`

Optional context:

- `public/template-annotations.json`
- `docs/user-guides/cmo-domain-beginner-guide.md`
- `docs/user-guides/ai-assistant-ux-wording.md`

## Constraints

- Read-only review.
- Do not edit files unless Codex explicitly reassigns doc integration.
- Do not create commits.
- Focus on Korean UX copy, beginner comprehension, information structure, and prompt-draft wording.
- Do not propose automatic AI send, automatic CMO execution, polling, watchers, live-state claims, or arbitrary new template creation.
- Keep the code assistant framed as deterministic guidance from known wiki/example data, not as a second AI agent.

## Current Known Facts

- Current top-level app menu is `Lua 편집 에이전트`, `백과사전`, `설정`.
- `Lua 편집 에이전트` has `AI 에이전트 대화` and `Lua 편집기`.
- The user wants `AI 에이전트 대화` to feel like a normal consultation chat.
- The user wants `Lua 편집기` to be a manual scratchpad/checking aid.
- The user wants `백과사전` to explain confirmed CMO Lua information with related examples.
- New template creation should not be foregrounded because unsupported AI-created CMO patterns can fail in-engine.
- Any AI question draft must be text-only; the user must press send.

## Review Questions

Please answer directly:

1. Is `백과사전` the right label, or should it be more specific such as `CMO Lua 백과사전`?
2. What should one wiki entry show first so a beginner understands it quickly?
3. How should related examples be presented without making them look like guaranteed final code?
4. What Korean wording should explain "AI draft, CMO engine verification required" in a friendly but firm way?
5. What should the right-side `code assistant` be called so users do not confuse it with a second AI chatbot?
6. What empty-state copy should appear when pasted Lua does not match any known wiki topic?
7. How should the UI invite users to create an AI question draft without implying automatic execution or automatic send?
8. Should preset creation be hidden behind `고급`, placed after examples, or kept as a secondary tab?
9. What are the top 5 beginner misunderstandings this design should prevent?
10. What is the smallest UX slice that proves this direction works?

## Desired Output

Write a concise Korean review with:

- Verdict: APPROVED / APPROVED WITH CHANGES / BLOCKED.
- Top 5 UX recommendations.
- Suggested Korean labels and copy snippets.
- Red flags or confusing terms.
- Recommended first implementation slice.

If possible, include concrete UI copy for:

- wiki heading;
- required CMO values section;
- related examples section;
- code assistant empty state;
- text-only AI question draft button;
- engine verification footer.
