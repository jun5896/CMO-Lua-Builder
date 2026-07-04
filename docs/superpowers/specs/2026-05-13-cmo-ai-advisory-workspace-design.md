# CMO AI Advisory Workspace Redesign

## Goal

Turn the local page into a beginner-friendly CMO mission scripting advisor:

- The primary surface is a normal chat window.
- The AI behaves like a consulting assistant, not a one-shot code generator.
- The Lua editor becomes a lightweight scratchpad for user-provided code checks.
- Presets, template examples, and the feature encyclopedia become one wiki-like knowledge surface.
- Large scenario context is handled through path-based scans and generated summaries, not by browser-reading whole `.scen` files.

This redesign keeps the B2/B3/B4 safety boundaries: no automatic CMO execution, no automatic AI send from logs or snapshots, no live-state claims, no browser-supplied privileged roots, and no raw credential persistence.

## Trigger

The current AI Chat entrypoint is improved, but it still feels like a prompt launcher attached to an expert workflow. The user wants the opposite shape:

1. A beginner can ask lightweight questions in ordinary chat.
2. The AI asks back to narrow mission intent, CMO objects, required IDs, and verification steps.
3. Lua is produced only after enough scenario facts are known.
4. If the user asks outside the product purpose, the AI politely redirects toward CMO mission scripting, scenario design, Lua validation, or prompt formulation.
5. Heavy Event / Lua Assistant surfaces should be reduced to simple checking and manual copy support.

## Empirical Constraint: Scenario File Sizes

Local CMO scenario scan on 2026-05-13:

- `.scen` files found: `1058`
- Total size: `641.1 MB`
- Files over `1.25 MB`: `149`
- Files over decimal `10 MB`: `2`
- Largest observed file: `17.49 MB`, `Red Dragon Descends 2026 v0.scen`

Implication:

- The current browser attachment cap around `1.25 MB` is acceptable only as an early convenience path.
- It is not a realistic long-term scenario-ingestion strategy.
- Full scenario context must come from path-based tooling, sidecar summaries, transient adapter summaries, or future server-side indexed context.
- Browser direct upload should remain bounded and explicitly labeled "small file / metadata helper".

## Product Shape

The app should feel like a three-part workstation:

1. **AI Chat**: the main place where the user describes intent, asks questions, attaches small context files, and receives guided ask-back.
2. **Lua Scratchpad**: a reduced editor where the user pastes Lua and gets local checks, formatting hints, and copy support. It is not the main generation surface.
3. **CMO Wiki / Presets**: a searchable knowledge panel that combines feature encyclopedia entries, template examples, safety notes, and beginner explanations.

The current B2/B3/B4 controls remain available as explicit user actions, but they should be presented as support actions inside the chat/scratchpad flow, not as the user's first mental model.

## AI Chat Behavior

The default behavior is consultation mode.

When the user asks for a script:

- First identify intent: mission setup, event automation, unit action, doctrine/EMCON, scoring, weather, cargo, reference points, or general scenario design.
- Ask for missing CMO facts before drafting: Side names, Mission names, Unit GUIDs, DBID, Loadout ID, RP / Zone names, coordinates, trigger rules, and expected verification path.
- Use already confirmed context from Track A3 before asking the same question again.
- When enough context exists, produce a draft and tell the user how to test it in CMO.
- Keep "AI draft, CMO engine verification required" language visible.

When the user asks a broad beginner question:

- Explain the concept in plain language.
- Offer 2-3 concrete paths the user can choose.
- Ask one focused follow-up question.
- Avoid dumping API references before the user has chosen a direction.

When the user asks something off-topic:

- Do not hard-fail unless the question is clearly unrelated.
- Use a polite redirect:
  - "이 도구는 CMO 미션/시나리오 Lua 작업에 맞춰져 있어요. 질문을 CMO 시나리오 설계, Lua 자동화, 이벤트/미션 구성, 또는 프롬프트 작성 쪽으로 바꿔주면 바로 도와드릴게요."
- If the question can be bridged into scenario design or prompt writing, offer that bridge.

## Tool / API Checking Framing

The web app cannot truthfully claim it can run Codex-side local tools by itself.

Correct framing:

- "CMO에서 확인해야 할 값" for user-side checks.
- "앱이 이미 가져온 스냅샷/로그/Confirmed Context 기준" for app-side context.
- "필요하면 다음 단계에서 경로 기반 스캔으로 연결" for future server/adapter capabilities.

Avoid:

- "제가 CMO를 직접 확인했습니다" unless the value came from an imported snapshot, log feedback, or summary.
- "실시간 상태" unless a future phase actually proves live read-back.
- "API를 확인해서 보장합니다" unless the app has a local verified source for that claim.

## Lua Scratchpad

The current second editing area should be simplified.

Keep:

- Manual text entry.
- Basic Lua syntax / structure heuristics.
- "copy to AI Chat" or "ask AI about this code" action.
- Local red-flag checks for placeholders, unsafe surfaces, incomplete CMO identifiers, and obvious formatting issues.

Remove or de-emphasize:

- Multi-panel expert output flow as the default.
- Apply-style generation affordances as the main interaction.
- Heavy status cards that compete with the chat surface.

The scratchpad is a supportive mirror: "Did I paste the code correctly? What should I ask the AI about it?"

## CMO Wiki / Presets

The Preset Guide should be integrated into a wiki-like knowledge surface.

Structure:

- Feature encyclopedia entry: what the CMO concept/API does.
- Related template examples: which `.tpl.lua` / preset resources use it.
- Beginner explanation: when to use it, what can go wrong, what values must be checked in CMO.
- Safety and verification: CMO engine test requirement, required IDs, and common failure modes.
- "Ask AI about this" button: inserts a text-only chat draft that references the selected wiki topic and example.

Preset creation should appear after the editor/scratchpad, not as the primary front door. The user should first understand what they want, then pick an example.

## Attachment and Folder Scan Policy

Short-term browser attachment:

- Keep small `.lua`, `.txt`, `.md`, `.html`, `.css`, `.json`, `.xml`, `.ini`, `.cfg`, `.yaml`, `.yml`, `.csv` attachments.
- Keep bounded reads.
- Label the limit clearly as a temporary helper, not the real scenario ingestion path.

Scenario files:

- Direct browser `.scen` reads are only for small metadata previews.
- Large `.scen` context must use path-based local tooling or sidecar summaries.
- The UI should explain that many installed scenarios exceed the browser helper limit.

Folder scan:

- Browser folder scan can gather lightweight text context for Lua/CSS/HTML/background notes.
- It must enforce max file count, max per-file read, and max total read.
- It must not imply it can fully parse large scenarios.

Future path:

- Add a path-based scenario context action that calls existing or new adapter tooling.
- Prefer generated summaries over raw `.scen` transfer.
- Preserve no browser-supplied privileged roots for B2/B3/B4 endpoints.

## Layout Direction

Recommended top-level tabs:

1. `AI Chat`
2. `Lua Scratchpad`
3. `Wiki / Presets`
4. `CMO Bridge`
5. `Settings`

`AI Chat` is the default and leftmost.

`CMO Bridge` can contain B2 save, B3 log feedback, and B4 snapshot import, but these should also be reachable contextually from chat responses.

If bundle pressure is too high, `Wiki / Presets` and `CMO Bridge` should remain lazy-loaded chunks.

## Bundle Constraint

Current post-AI-chat baseline is near the watch line:

- Main JS: about `398.55 kB`
- Main CSS: about `59.32 kB`
- aiContextPruning: `8.56 kB`

Implementation must not simply add more main-bundle UI. It should:

- Remove or lazy-load legacy heavy assistant panels.
- Reuse existing CSS where possible.
- Avoid adding broad global CSS.
- Keep wiki/preset surfaces in lazy chunks.
- Consider deleting or demoting unused expert UI instead of hiding it with CSS.

## Frontend Architecture Review Disposition

Gemini's frontend architecture review raised five structural points. They are broadly valid, but they need to be sequenced around the current bundle and release constraints.

### 1. `LuaAssistant.jsx` God Component

Disposition: adopt immediately.

Current verified state:

- `src/components/LuaAssistant.jsx`: about `220 KB`, `4748` lines.
- It contains utility functions, large state clusters, local persistence handling, editor rendering, AI chat state, CMO bridge state, and multiple UI panels.

Refactor direction:

- Split by product surface first, not by abstract technical layer:
  - `AiChatWorkspace`
  - `LuaScratchpadPanel`
  - `CmoBridgePanel`
  - `CmoWikiPresetPanel`
  - `AssistantSessionControls`
- Move pure helpers out first:
  - `compactSessionText`
  - Lua token/highlight helpers
  - attachment packing helpers
  - prompt/context formatting helpers
- Extract hooks only after component boundaries are visible:
  - `useAssistantSession`
  - `useAiChatDrafts`
  - `useCmoBridgeState`

### 2. Code Editor Library

Disposition: defer.

Monaco Editor or CodeMirror may be useful later, but not in the first advisory-workspace slice.

Reasons:

- Main JS is already near the `400 kB` watch line.
- New editor dependencies would require dependency/lockfile review and likely new QA baselines.
- The user now wants the Lua editor to be a lightweight scratchpad, not the primary authoring engine.

Near-term direction:

- Reduce the custom editor's role.
- Keep simple manual input and local checks.
- Avoid expanding tokenization/highlighting complexity.
- Revisit CodeMirror/Monaco only after the scratchpad proves insufficient and after bundle budget is recovered.

### 3. Global CSS Size

Disposition: adopt gradually.

Current verified state:

- `src/index.css`: about `81 KB`, `3438` lines.

Near-term direction:

- Do not add broad new global CSS for this redesign.
- Keep new styles component-scoped.
- Prefer deleting or moving styles when old panels are removed/demoted.
- CSS Modules may be evaluated later, but this slice should first reduce global surface and keep watch-line risk low.

### 4. External State Manager

Disposition: defer.

Zustand could simplify the eventual architecture, but adding state libraries before splitting `LuaAssistant.jsx` risks making the data flow more abstract without reducing product complexity.

Near-term direction:

- Extract state by domain into focused hooks.
- Keep state local where possible.
- Only consider Zustand after:
  - chat, scratchpad, wiki, and bridge are separate components;
  - prop drilling is proven painful;
  - smoke contracts can protect the migration.

### 5. Frontend UI Test Framework

Disposition: defer until a dedicated testing/refactor gate.

The repo already has strong Node smoke contracts, but no Vitest / React Testing Library baseline.

Near-term direction:

- Continue using focused smoke contracts for this redesign.
- Add static UI contracts for navigation, copy, no auto-send, no live-state claims, and bundle boundaries.
- Do not introduce Vitest until Codex opens a testing/refactor task explicitly.

## Revised Implementation Priority

The architecture review changes the first implementation slice:

1. Add advisory chat policy contract.
2. Split `LuaAssistant.jsx` enough to create a real chat-first shell.
3. Move Lua input into a small scratchpad component.
4. Keep wiki/presets lazy.
5. Only then consider deeper editor/state/test tooling.

## Safety Invariants

Keep all existing safety boundaries:

- No automatic AI send from B3 logs or B4 snapshots.
- No automatic CMO execution.
- No polling, watcher, or live-state claim in this redesign.
- No `.scen` mutation.
- No raw API key persistence.
- No browser-provided privileged root paths.
- Lua generation remains draft language; CMO engine verification remains required.
- B2 save remains gated by `isPasteReady` where generation output is being saved.
- Manual copy fallback remains visible.

## Review Questions for Gemini

Gemini review should focus on UX / information architecture / wording, not implementation code:

1. Does the proposed AI Chat consultation flow make sense for a beginner CMO user?
2. What should the AI ask first when a user says, "CAP 미션 자동화 스크립트 만들어줘"?
3. How should off-topic redirection sound in Korean so it is focused but not hostile?
4. What top-level navigation labels are clearest: `Lua Scratchpad`, `Wiki / Presets`, `CMO Bridge`, or alternatives?
5. How should the app explain the `.scen` attachment size limit without making the tool feel broken?
6. How should feature encyclopedia entries and template examples be linked?
7. Which existing expert UI should be removed from the default path versus moved behind an advanced disclosure?
8. What copy should appear near "Ask AI about this code" so users understand it creates a draft question, not automatic execution?
9. How should the app phrase "AI can guide you to check CMO API/tool values" without claiming it can inspect CMO live state?
10. What would make the first-run experience feel like a helpful advisor instead of a form?

## Definition of Done

The redesign is complete when:

- A new user can open the app and immediately ask a CMO mission scripting question in chat.
- The AI asks useful clarifying questions before producing Lua.
- The scratchpad supports manual Lua checking without feeling like a second product.
- The wiki/preset surface connects concepts, examples, and safety explanation.
- Large scenario ingestion is honestly framed and routed away from browser full-file reads.
- B2/B3/B4 remain available but do not dominate the default UI.
- `npm run verify:release` remains PASS.
- Main JS and CSS stay under watch lines.
