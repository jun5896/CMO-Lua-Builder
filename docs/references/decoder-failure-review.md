# Scenario Extraction Review: Decoder Failure UX

> **Reviewer:** Gemini  
> **Date:** 2026-05-03  
> **Scenario:** D챕j vu / Reds (Standalone Scenarios)  
> **Purpose:** Validate UX messaging when `prepare:scenario` fails with `CMO internal loader did not return Scenario XML`.

## 1. Context and Failure Analysis

> **Codex reconciliation note (2026-05-03):** This report captured the first
> failure symptom correctly, but the inferred root cause is now superseded.
> Follow-up diagnosis showed that the CMO loader did return XML. The decoded
> root was `<ContentScenario>` instead of `<Scenario>`, and the extractor was
> rejecting that valid content-style root. A second issue was also found:
> duplicate scenario file names could collide on the same sidecar slug and
> extraction cache file during parallel batch runs. Both issues have been
> patched in Codex. Keep the `decoderFailure` UX wording below only for future
> true extraction failures after these patches.

During batch extraction of older standalone scenarios (like "Deja Vu" and "Reds"), the extraction pipeline failed at the XML extraction step (`extract-cmo-scenario-xml.ps1`). The CMO engine internal loader did not return the `Scenario_Compressed` block as valid XML.

**Original root causes (now superseded):**
- Legacy format or unsupported encoding was suspected.

**Verified root causes:**
- The decoded XML was rooted at `<ContentScenario>`, not `<Scenario>`.
- Duplicate file names such as `9. Deja Vu.scen` caused sidecar slug collisions.
- Duplicate file names also caused extraction-cache file locks during parallel runs.

**Codex patch status (Updated):**
- `<ContentScenario>` is now accepted by `extract-cmo-scenario-xml.ps1`.
- `summarize-cmo-scenario-xml.mjs` harvests metadata from `<Scenario>` or `<ContentScenario>`.
- Duplicate file names receive hash-suffixed slugs.
- Extraction cache file names include path hashes.
- Follow-up batch test for `9. Deja Vu` succeeded `2/2`.

> **Update (2026-05-03):** While `<ContentScenario>` scenarios (e.g., Tutorials, Campaigns, and non-CMANO Standalone Scenarios) now extract perfectly, there remain 42 true decoder failures. These consist of the **`Standalone Scenarios_CMANO`** family (41 scenarios) and one local edge-case file (`Scenarios\Lua test\Ares-Lite-Advance-Threat-Test.scen`, classified as `decoderInvokeFailed`). These still require the `decoderFailure` fallback UX below until special handling is implemented.

## 2. Decoder Failure UX Strategy

When the pipeline hits this failure, it is critical not to tell the user "The file is broken." The file likely opens perfectly fine in the actual CMO game client. Instead, the UI should use the `decoderFailure` state.

**Proposed UI Wording (from `docs/user-guides/ai-assistant-ux-wording.md`):**

*   **배지 라벨:** `[수동 추출 필요]` (Manual Extraction Needed)
*   **한 줄 설명:** 로컬 디코더가 파일에서 시나리오 데이터를 추출하지 못했습니다.
*   **툴팁/도움말:** 파일이 손상된 것은 아닙니다. 구버전 DB를 사용하거나 지원되지 않는 특수한 구조를 가진 시나리오일 수 있습니다. (참고: 캠페인 및 콘텐츠 스타일 시나리오 구조는 현재 지원됩니다.)
*   **버튼 라벨:** `해결 방법 보기`
*   **경고 문구:** **안내:** 내부 데이터를 추출하지 못했습니다. 시나리오를 CMO 엔진에서 직접 열어 저장(Resave)하여 최신 버전으로 업데이트하거나, CMO 콘솔(Lua Console) 기능을 통해 수동으로 데이터를 내보내(Export) 주세요.

## 3. Beginner-Friendly Troubleshooting Checklist

If a user clicks "해결 방법 보기" (View Solutions), show this checklist:

1. **Re-save in CMO:** 
   - Open CMO.
   - Load the scenario in the Mission Editor.
   - Immediately "Save As" (this forces CMO to rewrite the file using the modern format).
   - Try `prepare:scenario` again in this tool.
2. **Database Update:**
   - If the scenario prompts for a Database Migration upon opening in CMO, accept it, save, and retry.
3. **Manual Extraction (Fallback):**
   - If the file still refuses headless extraction, you must use the in-game Lua console (`Tool_DumpEvents()`) to read existing logic. The AI Assistant will have to rely strictly on your manual context inputs.
