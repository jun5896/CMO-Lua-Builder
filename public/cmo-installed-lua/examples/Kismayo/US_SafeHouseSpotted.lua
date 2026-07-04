local theSpottedUnit = ScenEdit_UnitX()
local theSpotter = ScenEdit_UnitY().unit

if theSpottedUnit.dbid == 452 then
    local theMessage = "We've spotted safe house. It's a real hornet's nest down there!"

    theMessage = GenerateRadioMessageBody(theMessage,theSpotter.name)

    RadioMessage('SATCOM','316.2 MHz Encrypted',theMessage,{latitude=theSpottedUnit.latitude, longitude=theSpottedUnit.longitude})

    TelexMessageToPlayer(
        'NKEA', 
        'CENTCOM', 
        'i', 
        'US CENTral COMmand', 
        'lhd 3 kearsarge', 
        'top secret', 
        '1. centcom acknowledges your report of locating the al-jabaab safe house. <br>2. you have a green light to proceed with insertion of ground forces and capture of the courier as planned. <br>3. good hunting and godspeed.', 
        {latitude=theSpottedUnit.latitude, longitude=theSpottedUnit.longitude}
    )

    ScenEdit_SetEvent('US_SafeHouseSpotted',{isactive=false})
end