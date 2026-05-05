local theUnit = ScenEdit_UnitX()

if theUnit.type == 'Facility' and theUnit.dbid == 2987 then
    local badGuysLeft = VP_GetSide({side='Terrorists'}).units
    local badGuysLeft = #badGuysLeft

    local allowCapture = true
    if badGuysLeft > 2 then allowCapture = false end

    if allowCapture == true then

        local theMessage = "We've captured the courier. Ready for extraction."
        theMessage = GenerateRadioMessageBody(theMessage,theReconTeam.name)
        RadioMessage('SATCOM','316.2 MHz Encrypted',theMessage,{latitude='0.11267144147083', longitude='42.5517210502076'})

        ChangeScore('United States',2000,'Terrorist courier captured.')

        TelexMessageToPlayer(
            'NKEA', 
            'CENTCOM', 
            'i', 
            'US CENTral COMmand', 
            'lhd 3 kearsarge', 
            'top secret', 
            '1. centcom acknowledges your report of capturing the al-jabaab courier. <br>2. extract all us personnel and assets from somalian territorial limits. <br>3. bravo zulu, centcom sends', 
            {latitude='0.11267144147083', longitude='42.5517210502076'}
        )

        ScenEdit_SetEvent('US_MarinesAtSite',{isactive=false})
        ScenEdit_EndScenario()

    elseif not ClearOutMessageHasPlayed() then

        local theMessage = "There's too many hostiles nearby for us to attempt to capture the courier. We need to clear all hostiles from the area around the safe house!"
        theMessage = GenerateRadioMessageBody(theMessage,theUnit.name)
        RadioMessage('SATCOM','316.2 MHz Encrypted',theMessage,{latitude='0.11267144147083', longitude='42.5517210502076'})

        ClearOutMessageHasPlayed(true)
    end
end