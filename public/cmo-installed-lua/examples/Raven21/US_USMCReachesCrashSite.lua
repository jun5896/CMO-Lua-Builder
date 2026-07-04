local theUnit = ScenEdit_UnitX()

if theUnit.dbid == 1346 or theUnit.dbid == 1696 then
    GenerateRadioMessageBody(
        "We're at the crash site and ready to provide security until the helos can come in for extraction.",
        theUnit.name
    )
    RadioMessage(
        "VHF",
        "132.25MHz ENCRYPTED",
        theMessage,
        {latitude = theUnit.latitude, longitude = theUnit.longitude}
    )
    ChangeScore('United States',100,'USMC ground forces reached the crash site to provide security for extraction.')
    ScenEdit_SetEvent('US_USMCReachesCrashSite',{isactive=false})
end