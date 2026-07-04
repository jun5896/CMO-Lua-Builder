# Event Export Samples

All `.txt` files in this folder are **synthetic** (hand-written) samples that mimic real CMO engine output formats.

> **Status: reference-only / non-smoke.**  
> The current parser (`tools/parse-cmo-event-export.mjs`) expects **XML-shaped input** (e.g. extracted scenario XML or `Tool_DumpEvents()` XML). These plain-text / Lua-table samples do not match that contract. Failures here are **fixture/contract drift**, not parser defects.

They are retained as reference material for:
- Future parser format expansion discussions
- Human-readable examples of what CMO console output looks like

| File | Mimics | Tolerance Test | Smoke Test |
|------|--------|----------------|------------|
| `tool-dump-events-sample.txt` | `Tool_DumpEvents()` summary list | Clean, structured | **No** (plain text) |
| `scenedit-getevent-sample.txt` | `ScenEdit_GetEvent("...")` return table | Deep nested Lua table | **No** (Lua table) |
| `mixed-console-paste-sample.txt` | User copy-paste from console | Missing lines, garbled text, partial output | **No** (mixed plain text) |

For actual parser smoke tests, use `fixtures/cmo-scenario-mini.xml`.
