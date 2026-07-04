# Scenario Extraction Pipeline Review: "A Helping Hand, 1979"

> **Reviewer:** Gemini  
> **Date:** 2026-05-03  
> **Scenario:** A Helping Hand, 1979 (Standalone Scenarios)  
> **Purpose:** Validate the extraction pipeline UI messages, context exposure, Lua scale, and assistant inference boundaries.

## 1. UI Message Validation (Metadata -> Extraction)

**Review Target:** Does the UI message explain why the browser saw metadata first?

**Findings:** 
Yes. Based on the implemented `metadataOnlyNeedsDecoder` state, the UI clearly states `[압축 해제 필요]` and explains that the file is compressed, allowing only the title and description (metadata) to be read initially. It avoids the term "failed" and instead presents the extraction pipeline commands (`scan`, `extract:scenario-xml`, `summarize:scenario`) as a natural continuation. This effectively sets user expectations that the scenario is valid but simply requires the CMO engine decoder.

## 2. Summary Context Exposure

**Review Target:** Does the summary expose enough Side/Mission/Event/Lua context for the AI assistant to ask good follow-up questions?

**Findings:** 
The summary correctly exposes:
- **Sides:** E.g., `United States / UK Forces`, `Soviet Union`.
- **Missions:** Exposes mission tags and counts (11 missions detected).
- **Events & Triggers:** Parses 26 events successfully.
- **Reference Points & Units:** Parses 18 RPs and 327/332 units.

**Assistant Application:**
Because the summary accurately captures Side names, Mission counts, and existing Triggers/Events, the AI assistant has exactly the right constraints to say: *"I see you are playing as 'United States / UK Forces'. Do you want to attach this logic to one of your existing 11 missions, or create a new one?"*

## 3. Lua Scale & Safe Mode Activation

**Review Target:** Are there unusually large Lua scripts that need `largeLuaSafeMode`, search, or file-by-file navigation?

**Findings:** 
In this specific standalone scenario ("A Helping Hand"), the scripts are relatively standard size. However, the presence of multiple events (26) means that aggregating all Lua actions into a single view could become heavy.
The `largeLuaSafeMode` UI message (`[안전 모드]`) is well-suited for scenarios with hundreds of Lua actions, cleanly warning the user that syntax highlighting and autosave are limited to preserve browser responsiveness.

## 4. Object Inference vs. User Confirmation

**Review Target:** Which CMO objects are safe to infer from extracted data, and which must still be confirmed by the user inside CMO?

**Safe to Infer (from Summary JSON):**
- **Side Names:** Exact strings like `United States / UK Forces`.
- **Mission Existence:** Whether a named mission currently exists.
- **Event/Trigger Names:** The exact names of existing events.
- **Game/DB Version:** `Command: Modern Operations v1.08 - Build 1734` and DB Version.

**Must be Confirmed/Provided by User:**
- **Specific Unit GUIDs:** The summary cap limits unit details. The AI must still ask the user to use "Copy Unit ID" in CMO for exact targeting.
- **Database IDs (DBID / Loadout ID):** If spawning a new unit or changing loadouts, the AI cannot safely hallucinate IDs. It must prompt the user to check the Database Viewer.
- **Zone Polygon Coordinates:** While RPs exist, the exact drawing of a Zone must be validated inside the CMO engine.

## 5. Beginner-Facing Checklist Pre-Generation

**Review Target:** What beginner-facing checklist should be shown before generating paste-ready Lua?

**Checklist Template:**
1. **DB Version Check:** Ensure your current CMO engine DB matches the scenario (v1.08 - Build 1734).
2. **Object Names:** Ensure any Side or Mission names mentioned match the extraction exactly.
3. **Engine Preparation:** If the script relies on a "UnitEntersArea" trigger, have you drawn the reference points and zone in the CMO Event Editor?
4. **Validation:** The AI provides the Lua logic, but you must paste it into the "Lua Script Action" window and test it running in CMO.