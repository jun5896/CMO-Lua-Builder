SovietsHaveFiredWeapons(true)

if DebugModeIsOn() then
    local unit = ScenEdit_UnitX()
    ScenEdit_SpecialMessage(
        "playerside",
        "Soviet weapon fired.",
        {latitude = unit.latitude, longitude = unit.longitude}
    )
end
