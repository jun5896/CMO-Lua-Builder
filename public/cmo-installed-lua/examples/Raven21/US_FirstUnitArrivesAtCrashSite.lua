local theUnit = ScenEdit_UnitX()

if theUnit.dbid == 276 then
    local theMessage =
        GenerateRadioMessageBody(
        "We're at the crash site. Seven survivors, all crew accounted for.</p> <p>Four walking wounded, the other three are in critical condition. Recommend a rotary wing extraction at first light. The doc is working on them but he tells me he doesn't think they'll make it if we wait to evacuate them on the LCU.",
        theUnit.name
    )
    RadioMessage("VHF", "132.25MHz ENCRYPTED", theMessage, {latitude = theUnit.latitude, longitude = theUnit.longitude})
    ChangeScore("United States", 100, "Crash site secured by SEALs, casualties stabilised.")
    ScenEdit_SetEvent('US_FirstUnitArrivesAtCrashSite',{isactive=false})
else
    local theMessage =
        GenerateRadioMessageBody(
        "We're at the crash site. All crew accounted for.</p> <p>Four walking wounded, three KIA.",
        theUnit.name
    )
    RadioMessage("VHF", "132.25MHz ENCRYPTED", theMessage, {latitude = theUnit.latitude, longitude = theUnit.longitude})
    ChangeScore("United States", -50, "Crash site secured by Marines, medical care for survivors delayed.")
    ScenEdit_SetEvent('US_FirstUnitArrivesAtCrashSite',{isactive=false})
end
