local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= "Weapon" then
    local targetList = {
        {type = "Facility", dbid = 100, points = 0, name = "Marker (City)", destroyedString = "destroyed"},
         --Marker (City)
        {
            type = "Facility",
            dbid = 483,
            points = 0,
            name = "Radar (Generic Surface Search Radar)",
            destroyedString = "destroyed"
        },
         --Radar (Generic Surface Search Radar)
        {type = "Facility", dbid = 7, points = 0, name = "Marker (Town)", destroyedString = "destroyed"},
         --Marker (Town)
        {
            type = "Facility",
            dbid = 99,
            points = 0,
            name = "Arty Bty (76mm M1902 Bty Towed Dug-in x 6)",
            destroyedString = "destroyed"
        },
         --Arty Bty (76mm M1902 Bty Towed Dug-in x 6)
        {type = "Ship", dbid = 1321, points = 150, name = "Civilian Junk [35m, Armed]", destroyedString = "sunk"},
         --Civilian Junk [35m, Armed]
        {type = "Ship", dbid = 1322, points = 150, name = "Civilian Junk [35m]", destroyedString = "sunk"},
         --Civilian Junk [35m]
        {type = "Ship", dbid = 1488, points = 150, name = "TK P-4 [Pr.123K]", destroyedString = "sunk"}
     --TK P-4 [Pr.123K]
    }

    local matchData = {}

    for k, v in ipairs(targetList) do
        if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
            matchData = v
        end
    end

    if matchData == {} then
        BugMessage("NK_UnitDestroyed", "No dbid match found for destroyed unit")
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage(
                "playerside",
                "Could not find match for destroyed unit " ..
                    theDestroyedUnit.name .. ", dbid " .. theDestroyedUnit.dbid
            )
        end
    else
        ChangeScore("United Nations", matchData.points,'A North Korean '.. theDestroyedUnit.name .. " was " .. matchData.destroyedString .. ".")
    end
end
