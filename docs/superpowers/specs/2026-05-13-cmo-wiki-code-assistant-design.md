# CMO Wiki and Code Assistant Design

## Goal

Rework the newly simplified workspace into a safer learning-and-authoring loop:

1. `Lua 편집 에이전트` remains the entry point for conversation and manual Lua checking.
2. `Lua 편집기` gains a right-side code assistant that does not call AI by itself.
3. `백과사전` becomes the verified knowledge surface that joins concepts, required CMO values, template examples, and engine-verification notes.
4. AI chat and the editor can reference wiki entries as harnessed context, so the assistant is pushed toward known-working CMO Lua patterns instead of inventing unsupported code.

The intent is not to add a bigger template creator. The intent is to make the existing verified template and example corpus easier to understand and easier to use as constraints for AI drafting.

## Product Framing

The app should now feel like three connected surfaces:

| Surface | User mental model | Product role |
| --- | --- | --- |
| `AI 에이전트 대화` | "I ask a CMO mission scripting question." | Consultation, follow-up questions, draft guidance, no automatic execution. |
| `Lua 편집기` | "I paste or write Lua and check whether it looks right." | Manual scratchpad plus wiki-backed code assistant. |
| `백과사전` | "I learn what CMO Lua features exist and see verified examples." | Searchable concept + example wiki that feeds chat/editor context. |

`설정` remains unchanged.

## Core Principle

Do not let the UI imply that arbitrary new CMO Lua patterns are supported just because AI can write them.

The wiki/code assistant should bias the user and AI toward:

- confirmed template resources from `public/template-annotations.json`;
- installed example metadata from the existing CMO Lua manifest;
- existing template catalog definitions in `src/data/templateCatalog`;
- explicit CMO user checks such as Side, Mission, Unit GUID, DBID, Loadout ID, RP/Zone, coordinates, Doctrine/EMCON values;
- visible "AI draft, CMO engine verification required" language.

The UI should avoid:

- a "create new template" front door;
- claims that the AI can verify live CMO state;
- claims that examples are engine-tested final code;
- broad "generate anything" affordances in the editor.

## Information Architecture

### Top-Level Navigation

The top-level app shell already has:

1. `Lua 편집 에이전트`
2. `백과사전`
3. `설정`

Keep this shape.

Inside `Lua 편집 에이전트`:

1. `AI 에이전트 대화` remains the default sub mode.
2. `Lua 편집기` remains the manual / semi-manual scratchpad sub mode.

### Encyclopedia Layout

The encyclopedia should be a wiki, not just a source browser.

Recommended first-slice layout:

1. Left rail: search + compact topic/category list.
2. Main detail card:
   - concept title;
   - plain-language explanation;
   - when to use it;
   - required CMO values;
   - safe pattern;
   - related API names;
   - related template/example files;
   - CMO verification checklist.
3. Action row:
   - `AI에게 이 주제로 질문 초안 만들기`;
   - `Lua 편집기에 예문 참고로 보내기` if an exact template/example source exists;
   - no automatic AI send.

The existing `TemplateLibrary` search/filter logic can remain the data owner for resource discovery. A new wrapper or extracted helper should make the selected resource easier to read as a wiki entry.

### Lua Editor Code Assistant

The editor-side code assistant should sit to the right of the manual Lua input.

It should be a local, deterministic support panel:

- show matched wiki topics based on API names or keywords in the pasted code;
- show "CMO에서 확인할 값" from matched annotations;
- show related examples;
- show common failure modes;
- offer a text-only "AI에게 검토 질문 만들기" button.

It must not:

- call the AI automatically;
- execute Lua;
- save to CMO;
- mutate `.scen`;
- claim CMO runtime verification.

The panel is a harnessed reading aid, not an autonomous code reviewer.

## Data Sources

Use existing sources first:

1. `public/template-annotations.json`
   - 51 / 51 template annotations.
   - Main source for beginner notes, prerequisites, safe pattern, AI hint, checks.
2. `public/cmo-dev-work/manifest.json`
   - DB baseline and builder template metadata.
3. `public/cmo-installed-lua/manifest.json`
   - Installed examples and API index if present.
4. `src/data/templateCatalog`
   - Template definitions and fields used by the existing preset builder.

Do not add a new generation-oriented data format in the first slice.

If a shared transform is needed, add a small pure helper such as:

```text
src/lib/cmoWikiEntries.js
```

Expected helper responsibilities:

- normalize annotation + resource + template catalog data into wiki entries;
- derive required-value badges;
- derive code-assistant matches from Lua text;
- format a text-only AI question draft.

This keeps logic out of `LuaAssistant.jsx` and prevents `TemplateLibrary.jsx` from becoming another monolith.

## Component Direction

Recommended components for the first implementation:

```text
src/components/CmoWikiPanel.jsx
src/components/CmoWikiPanel.css
src/components/LuaEditorCodeAssistant.jsx
src/components/LuaEditorCodeAssistant.css
src/lib/cmoWikiEntries.js
tools/verify-cmo-wiki-code-assistant-contract.mjs
```

`CmoWikiPanel` can initially wrap or reuse parts of `TemplateLibrary`, but the visible wording should shift from "Template Inspector" toward "CMO Lua 백과사전".

`LuaEditorCodeAssistant` should receive:

```js
{
  luaText,
  wikiEntries,
  onDraftQuestion,
  onPickEntry
}
```

It should return only UI. It should not own fetch, AI calls, CMO writes, or adapter state.

## AI Harnessing Flow

When a user clicks "AI에게 이 주제로 질문 초안 만들기":

1. The UI inserts a draft into chat input.
2. The draft includes:
   - selected wiki topic;
   - selected template/example file;
   - required CMO values;
   - safe pattern;
   - engine verification checklist.
3. The UI switches to `AI 에이전트 대화`.
4. The user must press send.

Example draft shape:

```text
이 CMO Lua 기능을 사용하고 싶습니다.

주제: <wiki title>
관련 예문: <template/example file>
CMO에서 확인할 값:
- <prerequisite 1>
- <prerequisite 2>

안전 패턴:
<safePattern>

먼저 어떤 값이 부족한지 한 가지씩 질문해 주세요. 충분하면 CMO 엔진 검증이 필요한 Lua 초안을 작성해 주세요.
```

This reinforces consultation mode and prevents blind one-shot generation.

## Preset Builder Treatment

Preset creation should be demoted, not removed from the codebase immediately.

First slice:

- keep preset builder reachable from the encyclopedia only as a secondary "프리셋 제작" panel or advanced section;
- do not add "new template type" creation;
- do not foreground "Template 추가" as the primary encyclopedia action;
- prefer "관련 예문 보기" and "AI 질문 초안 만들기" over "제작 폼에 추가".

Reason:

- the verified 51 / 51 template set is valuable;
- arbitrary new template creation risks encouraging unsupported CMO Lua patterns;
- users should learn and adapt known examples before composing more complex scripts.

## Error Handling

If wiki data cannot load:

- show a compact "백과사전 데이터를 불러오지 못했습니다" message;
- keep the AI chat and manual editor usable;
- offer "목록 새로고침";
- do not block the whole workspace.

If code-assistant matching finds no topics:

- show a useful empty state:
  - "코드에서 알려진 CMO API/템플릿 단서를 찾지 못했습니다."
  - suggest searching the encyclopedia manually or asking AI to identify missing CMO facts.

If installed examples manifest is missing:

- keep builder template annotations available;
- explain that installed examples require the existing sync flow;
- do not fail the encyclopedia entirely.

## Bundle and CSS Constraints

Current baseline after the menu restructure:

```text
Main JS: 254.00 kB
Main CSS: 59.45 kB
LuaAssistant lazy chunk: 135.22 kB
aiContextPruning: 8.56 kB
```

Constraints:

- Main JS must stay below 400 kB.
- Main CSS must stay below 60 kB.
- `aiContextPruning` must stay below 9 kB.
- New CSS should be component-scoped and small.
- Avoid adding dependencies.
- Prefer lazy surfaces and shared helpers over adding logic to `App.jsx`.

The CSS margin is narrow. The first slice should reuse existing classes where possible and add only minimal component CSS.

## Testing and QA

Add a new smoke contract:

```text
npm run smoke:cmo-wiki-code-assistant
```

The contract should verify:

1. `public/template-annotations.json` still has 51 / 51 coverage.
2. wiki helper can build entries from annotations.
3. each entry preserves title, summary, prerequisites, safePattern, aiHint, and checks.
4. code assistant matching is deterministic for known API names.
5. text-only AI draft includes required CMO values and engine-verification wording.
6. no auto-send string path is introduced.
7. no CMO file write / log tail / polling / watcher behavior is introduced.
8. no new dependency or lockfile drift.
9. Main CSS remains below 60 kB after build.

Manual browser check should verify:

- `백과사전` opens as a wiki-like explanation page;
- searching a topic shows related examples and safety notes;
- `Lua 편집기` shows the code assistant on the right;
- clicking draft-question actions fills chat text but does not send;
- settings remain unchanged.

## Out of Scope

The first wiki/code-assistant slice does not:

- add Monaco or CodeMirror;
- add Zustand or another state library;
- add Vitest / React Testing Library;
- add live CMO read-back;
- parse large `.scen` files in the browser;
- create new template kinds;
- auto-generate or auto-send prompts;
- execute or save Lua automatically beyond existing B2 controls.

## Definition of Done

The slice is complete when:

1. `백과사전` presents CMO Lua features as wiki entries with linked examples.
2. `Lua 편집기` has a deterministic right-side code assistant.
3. users can turn a wiki topic or pasted code into a text-only AI chat question draft.
4. no AI call happens until the user presses send.
5. preset/template creation is visually secondary.
6. existing B2/B3/B4 safety boundaries are unchanged.
7. `npm run verify:release` passes.
8. bundle watch lines remain green.

## Open Question for Implementation Planning

Claude and Gemini pre-implementation reviews resolved the first-slice choice.

Claude architecture review recommended splitting the original wiki-first proposal into a smaller helper-only first slice:

1. **Slice 0 - helper-only**: extract deterministic wiki normalization / matching / text-only draft helpers from existing data, with no UI and no CSS.
2. **Slice 1 - wiki UI**: build the `백과사전` reading surface on top of the helper.
3. **Slice 2 - editor reference helper**: add the right-side deterministic code reference panel in `Lua 편집기`.

Gemini UX review refined the copy and framing:

- Prefer `CMO Lua 백과사전` for clarity when space allows.
- Avoid anthropomorphic wording for the right-side editor panel; use labels such as `Lua 참조 도우미` or `코드 분석 도움말`, not "agent".
- Show "언제 쓰나요?" / use-case before raw code.
- Present examples as reference patterns, not guaranteed final code.
- Make question-draft buttons explicitly text-only and not automatic execution.
- Demote preset creation behind advanced / secondary placement.

Implementation should therefore start with **Slice 0 helper-only**. This keeps CSS unchanged, prevents `LuaAssistant.jsx` growth, and gives both the wiki and editor assistant one shared deterministic data model.
