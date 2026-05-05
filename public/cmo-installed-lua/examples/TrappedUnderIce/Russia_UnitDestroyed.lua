local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Submarine', dbid=270, points=300, name='SSBN', destroyedString='sunk'},--PLARB-941 Typhoon [Akula]
        {type='Submarine', dbid=130, points=20, name='SSN', destroyedString='sunk'},--PLA-671RTMK Victor III [Shchuka]
        {type='Submarine', dbid=192, points=20, name='SSN', destroyedString='sunk'},--PLA-945 Sierra I [Barrakuda]
        {type='Submarine', dbid=127, points=20, name='SSN', destroyedString='sunk'},--PLA-971 Akula I [Shchuka-B]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Russia_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('United States',matchData.points,'A Russian '..matchData.name..' was '..matchData.destroyedString..'.')

        if theDestroyedUnit.dbid == 270 then
            local theMessage =ACP126(
                'NHRT',
                'COMSUBPAC',
                'z',
                'CMDR SUBMARINES PACIFIC',
                'SSN 768 HARTFORD',
                'TOP SECRET',
                '1. COMSUBPAC ACKNOWLEDGES YOUR REPORT OF SINKING THE RUSSIAN SSBN.<BR> 2. BRAVO ZULU. <BR>3. WITHDRAW AND TRANSIT TO BANGOR FOR DEBRIEFING.'
            )
            ScenEdit_SpecialMessage('playerside',theMessage)
            RegisterMessage(theMessage)
            ScenEdit_SetEvent('US_SubWithdraw',{isactive=true})
        end

        local remainingShips = 0
        local sideUnits = VP_GetSide({side='Russia'}).units
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Submarine' then
                remainingShips = remainingShips + 1
            end
        end
        if remainingShips == 0 then
            ScenEdit_EndScenario()
        end      
    end
end