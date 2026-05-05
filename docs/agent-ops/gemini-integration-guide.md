# Gemini Document Integration Guide

> **Owner:** Gemini  
> **Scope:** Consolidate multi-agent drafts into unified, language-consistent `docs/` deliverables.  
> **Authority:** Gemini may directly edit `docs/**/*.md` files for integration purposes. All other directories (`src/`, `tools/`, `server/`, `fixtures/`) remain read-only.

---

## 1. Why Integration Is Needed

Codex, Claude, and Kimi each produce independent drafts for the same topic (e.g., Task 3B AI chat protocol, scenario sidecar notes). Codex triangulates and merges functional content, but **language consistency, terminology unification, and structural alignment** across `docs/` are Gemini's responsibility.

Kimi has completed the Korean translation pass for `template-inspector-guide-seed.md`. From this point forward, **Gemini owns both language review and document integration** so that Kimi can focus on Claude validation and QA pipelines.

---

## 2. Integration Scope

| Source | Example Documents | Integration Target |
|--------|-------------------|-------------------|
| Kimi drafts | `docs/references/ai-assistant-conversation-protocol.md` (Task C) | Single merged protocol doc |
| Claude drafts | `~/.claude/.../ai-interpreter-chat-contract.md` | Cited, not copied verbatim; merge if Codex pulls into `docs/` |
| Kimi drafts | `docs/user-guides/template-inspector-guide-seed.md` (Task B) | Expand incrementally as new templates arrive |
| Kimi + Claude | `docs/references/scenario-sidecar-autoload-notes.md` + Task 2 contract | Ensure JSON shape references stay synchronized |

**Rule:** Do not merge backend artifacts that remain inside `~/.claude/` or `~/.codex/` handoff folders. Only integrate files that have been copied into the shared `docs/` tree by Codex or Kimi.

---

## 3. Integration Principles

### 3.1 Technical Immutability
- **API names** (`ScenEdit_AddUnit`, `ChangeScore`, etc.) must never be translated or altered.
- **File paths** inside backticks/code blocks remain verbatim.
- **Code blocks** (Lua, JSON, XML) are copied exactly; reformatting is allowed only for indentation consistency.
- **JSON shapes** and XML path descriptions must match the latest validated parser output (authority: `fixtures/iran-strike-xml-node-index.json` and `docs/references/scenario-xml-schema-catalog.md`).

### 3.2 Language Unification
- Identify the **primary language** of each document from `docs/agent-ops/gemini-review-queue.md`.
- Translate body text (goals, prerequisites, risk notes) into the primary language.
- Keep English for: API names, file names, CMO UI labels, and code comments.

### 3.3 Terminology Glossary (Authoritative)

| English | Korean | Notes |
|---------|--------|-------|
| Side | 진영 | Never "쪽" or "측" in formal docs |
| Doctrine | 교전수칙 | Previously "교전규칙"; unify to 교전수칙 |
| EMCON | 방사통제 | Previously "전자기통제"; unify to 방사통제 |
| Reference Point | 기준점 | |
| Zone | 구역 | NoNavZone = 비항해구역, ExclusionZone = 금지구역 when context requires |
| Mission | 임무 | |
| Event | 이벤트 | |
| Trigger | 트리거 | |
| Condition | 조건 | |
| Action | 행동 / 액션 | Prefer "행동" in CMO Event Editor context |
| Unit | 유닛 | |
| Contact | 접촉 | |
| Detection | 탐지 | |
| Score | 점수 | |
| Victory | 승리 | |
| Cargo | 화물 | |
| Logistics | 물류 | |
| Posture | 관계 / 태세 | "Side posture" = 진영 관계 |
| Spawn | 생성 | |
| Loadout | 탑재장비 | |
| Special Action | 특수행동 | |
| Scenario | 시나리오 | |

### 3.4 Conflict Resolution

| Conflict Type | Resolution |
|---------------|------------|
| Technical discrepancy (e.g., wrong XML path) | Flag for **Kimi** or **Claude**; do not guess. |
| Language style (e.g., "확인하라" vs "확인하세요") | **Gemini decides**; prefer plain imperative for dev docs. |
| Section ordering | **Gemini decides**; prioritize user workflow over author preference. |
| Duplicate content across drafts | Keep the more detailed version; merge unique bullets from the other. |
| Dual-draft divergence (Claude vs Kimi) | Preserve both perspectives in separate sub-sections if Codex has not yet chosen. Label them clearly: "Claude draft perspective" / "Kimi draft perspective". |

---

## 4. Integration Process

### Step 1 — Identify Target
Read `docs/agent-ops/gemini-review-queue.md` and pick the next document marked `🔍 Pending integration` or `✅ Reviewed — changes recommended`.

### Step 2 — Language Review First
Perform the language review (terminology, tone, readability) before structural merges. Record findings in `docs/agent-ops/gemini-review-queue.md` under Completed Reviews.

### Step 3 — Structural Merge
- Open the target document and any related drafts.
- Merge sections according to the conflict-resolution table above.
- Ensure heading hierarchy is consistent (`#` → `##` → `###`).
- Update the table of contents if present.

### Step 4 — Glossary Sweep
Run a find/replace pass using the Terminology Glossary. Do not touch code blocks.

### Step 5 — Self-Check
- [ ] No API names were translated.
- [ ] No file paths were altered.
- [ ] Code blocks are verbatim (except indentation).
- [ ] Primary language is consistent throughout body text.
- [ ] All `[major]` issues from review are addressed.

### Step 6 — Commit & Handoff
1. Write the integrated file directly to `docs/`.
2. Update `docs/agent-ops/gemini-review-queue.md`:
   - Move the document from Pending to Completed.
   - Add integration summary (date, scope, any flagged technical issues).
3. If technical discrepancies were found, open a **Kimi handoff note** by creating a file under `docs/reviews/kimi-handoff-<topic>.md` with:
   - Document path
   - Discrepancy description
   - Suggested fix (if any)
   - Severity `[blocking|non-blocking]`

---

## 5. Review Scope Rules (Path-Based)

- `docs/user-guides/**`: Gemini review target by default.
- `docs/contracts/**`: excluded from language review by default; keep English unless Codex explicitly requests translation.
- `docs/agent-ops/**`: process docs; review only for clarity if directly requested.
- `docs/references/**`: technical references; review only for terminology consistency or if user-facing snippets are later extracted.
- `docs/samples/**`: never language-review payload content unless sample comments are explicitly user-facing.

---

## 6. Boundaries (Unchanged)

- **No functional code:** Gemini does not edit `src/`, `tools/`, `server/`, `public/cmo-dev-work/`, or `fixtures/`.
- **No git mutations:** Gemini does not run `git commit`, `git push`, or alter `.gitignore`.
- **No package changes:** Gemini does not modify `package.json` or `package-lock.json`.
- **No lint/build responsibility:** After Gemini integrates a doc, **Kimi** runs `npm run lint` and `npm run build` to ensure no accidental JSX/CSS injection occurred via markdown.

---

## 7. Current Integration Backlog

| Priority | Document | Status | Blocker |
|----------|----------|--------|---------|
| 1 | `docs/user-guides/template-inspector-guide-seed.md` | ✅ Language pass done by Kimi. Needs Gemini glossary sweep + structural finalization. | None |
| 2 | `docs/references/ai-assistant-conversation-protocol.md` | ✅ Reviewed. Needs Rules section concisification per Gemini recommendation. | None |
| 3 | `docs/references/scenario-sidecar-autoload-notes.md` | ✅ Reviewed — no changes. | None |
| 4 | `docs/references/scenario-xml-schema-catalog.md` | ✅ Reviewed — no changes. | None |

**Next action for Gemini:** Finalize `template-inspector-guide-seed.md` glossary sweep, then concisify the Rules section in `docs/references/ai-assistant-conversation-protocol.md`.