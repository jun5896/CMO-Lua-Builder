# Gemini Language Review Queue

> **Owner:** Gemini  
> **Scope:** Korean/English mixed expression, terminology consistency, tone, readability, and structural consolidation of multi-agent drafts in `docs/`.  
> **Rule:** Gemini does not write functional code, but may directly edit `docs/**/*.md` for integration per `docs/agent-ops/gemini-integration-guide.md`.

---

## Pending Review

| # | Document | Primary Language | Key Review Points | Status |
|---|----------|------------------|-------------------|--------|
| 1 | `docs/references/ai-assistant-conversation-protocol.md` | English (with Korean user context) | Terminology consistency ("prompt section" vs "프롬프트 구성"), tone (developer-facing but explains to Korean users), clarity of guardrails | ✅ Integrated |
| 2 | `docs/user-guides/template-inspector-guide-seed.md` | Korean (with English API names) | Korean expression naturalness, English API names kept as-is consistency, heading hierarchy, "Safe Coding Pattern" readability | ✅ Integrated |
| 3 | `docs/references/scenario-sidecar-autoload-notes.md` | English | Clarity of autoload sequence, terminology ("sidecar" vs "companion file"), JSON schema description conciseness | ✅ Integrated |
| 4 | `docs/references/scenario-xml-schema-catalog.md` | English | Technical accuracy of XML path descriptions, consistency of "Side-nested" vs "root-level" phrasing, max-depth notation | ✅ Integrated |

## Review Format

When Gemini completes a review, add an entry below with:

- **Document:** file path
- **Reviewer:** Gemini
- **Date:** ISO 8601
- **Summary:** 1-2 sentence overall assessment
- **Issues Found:** bullet list (if any) with severity `[major|minor|suggestion]`
- **Recommended Changes:** specific text replacements or restructuring advice
- **Status:** `✅ Reviewed — no changes` or `✅ Reviewed — changes recommended`

## Completed Reviews

- **Document:** `docs/references/ai-assistant-conversation-protocol.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** The document effectively uses a concise, imperative English tone for developer specifications. Guardrails are clearly outlined, and there are no terminology inconsistencies.
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Integrated — Rules section concisified (2026-05-03)`

- **Document:** `docs/user-guides/template-inspector-guide-seed.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** The document is primarily written in English with Korean translations only added to the headings, which conflicts with its designated primary language (Korean). The instructional tone needs full translation to match the queue's requirements.
- **Issues Found:**
  - `[major]` The body text (instructions, goals, prerequisites, risk notes) is written entirely in English, despite the primary language being defined as Korean.
  - `[minor]` There is an abrupt language switch in the "Guardrails (적용 규칙)" section, where the heading mixes both languages but the rules remain entirely in English.
- **Recommended Changes:** Translate the body text into plain, direct Korean. Maintain API names, file paths, and code blocks exactly as they are in English.
- **Status:** `✅ Integrated — Glossary sweep and structural finalization complete (2026-05-03)`

- **Document:** `docs/references/scenario-sidecar-autoload-notes.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** The document provides a clear, concise explanation of the sidecar autoload sequence with excellent structural readability. Terminology is consistent, using "sidecar" throughout rather than mixing with "companion file".
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Reviewed — no changes`

- **Document:** `docs/references/scenario-xml-schema-catalog.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** The document maintains technical accuracy and readable tables without any abrupt language switching. Phrasing for XML hierarchy ("root-level" vs "nested under each Side") and max-depth notation are clear and consistent.
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Reviewed — no changes`

- **Document:** `docs/contracts/ai-interpreter-chat-contract.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** English-only, developer-facing backend/contract artifact. Excluded from language review per Kimi's pipeline review.
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Excluded — Backend/contract artifact`

- **Document:** `docs/contracts/response-normalization-and-error-taxonomy.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** English-only, developer-facing backend/contract artifact. Excluded from language review per Kimi's pipeline review.
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Excluded — Backend/contract artifact`

- **Document:** `docs/user-guides/ai-assistant-ux-wording.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** Gemini original deliverable containing UX wording for loading states, 10 user goals, and prompt flow rules.
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Created — Ready for Codex implementation`

- **Document:** `docs/user-guides/cmo-domain-beginner-guide.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** Gemini original deliverable containing a beginner glossary, DB orientation, and safety guidelines for the AI assistant.
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Created — Ready for Codex implementation`

- **Document:** `docs/references/a-helping-hand-extraction-review.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** Gemini original deliverable containing an extraction pipeline review for the scenario 'A Helping Hand, 1979'. Validates UX messaging, summary exposure, and AI inference boundaries based on real extracted data.
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Created — Ready for reference`

- **Document:** `docs/references/decoder-failure-review.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** Gemini original deliverable addressing decoder failure UX (e.g. for older scenarios like 'Deja Vu'). Provides UI copy and beginner-friendly troubleshooting steps.
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Created — Ready for Codex implementation`

- **Document:** `docs/references/ai-token-efficiency-strategy.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** Gemini original deliverable outlining architectural strategies for token efficiency, including template-driven parameter JSON, dynamic context pruning, and early ask-back mechanisms.
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Created — Ready for Codex architecture reference`

- **Document:** `docs/user-guides/ambiguous-goal-interpretation.md`
- **Reviewer:** Gemini
- **Date:** 2026-05-03T00:00:00Z
- **Summary:** Gemini original deliverable defining how the AI should interpret vague user goals and ask for missing CMO context (Ask-back behavior).
- **Issues Found:**
  - None
- **Recommended Changes:** None
- **Status:** `✅ Created — Ready for Codex prompt engineering`

---

## Notes for Reviewers / Integrators

1. **API names are sacred.** `ScenEdit_AddUnit`, `ChangeScore`, etc. must not be translated or modified.
2. **File paths** inside code blocks or backticks should remain verbatim.
3. **Korean tone:** prefer plain, direct instructional style (e.g., "확인하라" rather than "확인하시기 바랍니다") for developer docs.
4. **English tone:** prefer concise, imperative style for technical specifications.
5. If a document mixes both languages heavily, flag sections where language switching feels abrupt.
6. **Integration authority:** Gemini may merge sections, reorder headings, and apply the glossary directly to `docs/**/*.md`. See `docs/agent-ops/gemini-integration-guide.md` for the full process and conflict-resolution rules.