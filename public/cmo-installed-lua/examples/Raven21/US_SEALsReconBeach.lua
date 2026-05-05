local theUnit = ScenEdit_UnitX()

if theUnit.dbid == 276 then
    local theMessage = GenerateRadioMessageBody(
        "The beach is clear. We're ready to head towards the crash site, out.",
        theUnit.name
    )
    RadioMessage("VHF", "132.25MHz ENCRYPTED", theMessage, {latitude = theUnit.latitude, longitude = theUnit.longitude})
    ChangeScore("United States", 50, "Beach reconnaisance complete.")
    ScenEdit_SetEvent("US_SEALsReconBeach", {isactive = false})
end
