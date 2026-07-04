-- presets/airbase_scramble.lua
-- 적 항공기 탐지 → 호스트 비행장에서 신규 유닛 스폰 + Launch.
return {
    header = { title = "Airbase Scramble", description = "Detect → spawn → launch" },
    units = {
        -- 호스트 비행장 (이미 존재한다고 가정 시 생략 가능)
    },
    events = {
        {
            name = "Scramble-On-Detect",
            triggers = { {
                type = "UnitDetected", name = "scramble_detect",
                opts = {
                    DetectorSideID = "Blue",
                    TargetFilter = { TargetSide = "Red", TargetType = 1 },
                    MCL = 1,
                },
            } },
            actions = { {
                type = "LuaScript", name = "scramble_action",
                opts = { scripttext = [[
local interceptor = ScenEdit_AddUnit({
    side = "Blue", name = "QRA-1", type = "Aircraft", dbid = 211,
    loadoutid = 1404, base = "Blue Airbase",
})
if interceptor then
    if interceptor.Launch then interceptor:Launch() end
    print("QRA launched")
end
                ]] },
            } },
        },
    },
}
