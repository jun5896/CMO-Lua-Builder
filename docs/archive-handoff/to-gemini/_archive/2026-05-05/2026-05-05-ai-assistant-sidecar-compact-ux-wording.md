# Gemini Wording Directive - AI Assistant / Sidecar Compact UX Polish

## Role

Korean UX wording reviewer only. Do not edit files. Do not propose code patches. Keep output compact and UI-ready.

## Current Baseline

Latest protected local HEAD:

```text
f3eec7c Refresh agent CURRENT_TASK baselines
```

Accepted watch lines:

- Main JS: `366.05 kB`
- Main CSS: `58.27 kB`
- `aiContextPruning`: `8.56 kB`
- Scenario loader: `1857 readyWithInternalSidecar / 42 decoderFailed / issues 0`

## Review Scope

Review current user-facing wording in these areas:

1. AI Interpreter Chat next-action guidance
2. AI Response Review paste-ready / blocked / follow-up wording
3. Context Pruning visibility card labels
4. Sidecar / scenario readiness / cache wording
5. Manual fallback wording around prompt-copy and request-copy

Primary source files to inspect:

- `src/components/AiInterpreterChatPanel.jsx`
- `src/components/AiResponseReviewPanel.jsx`
- `src/components/LuaAssistant.jsx`
- `src/App.jsx`
- `handoff/to-gemini/CURRENT_TASK.md`

## Safety Meaning To Preserve

Do not soften these meanings:

- AI can draft Lua, but CMO engine testing is still required.
- Lua must not be pasted/applied until parser says paste-ready.
- Missing Side, Mission, Unit GUID, DBID, Loadout ID, RP, or Zone should trigger ask-back, not invention.
- Sidecars are local generated analysis files, not edits to `.scen`.
- `.scenario-extract-cache` is temporary scratch space, but cleanup should happen only when Codex/user says so.
- Prompt-copy/request-copy are manual fallback paths when the adapter is unavailable.

## Desired Output

Return a concise Korean report with these sections:

```text
## 유지해도 되는 문구
- ...

## 교체 추천
| 위치 | 현재 의미 | 추천 문구 | 이유 |
|---|---|---|---|

## 짧은 툴팁 후보
- ...

## 주의할 표현
- ...
```

Rules:

- Prefer short labels, one-line tooltips, and compact helper text.
- Do not create tutorial paragraphs.
- Do not invent CMO API facts.
- Keep exact terms such as `Side`, `Mission`, `GUID`, `DBID`, `Loadout ID`, `RP`, `Zone`, `Lua`, `CMO`.
- Mark uncertainty as `Codex 확인 필요`.
- If current wording is already good, say so instead of rewriting everything.

## Non-Goals

- No code implementation.
- No broad UI redesign.
- No parser/adapter contract review; Claude owns that if Codex opens a separate signal.
- No QA pipeline execution; Kimi owns QA.
