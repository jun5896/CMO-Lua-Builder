local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1971, points=0, name='Sea King Mk42 [HAS.1]', destroyedString='destroyed'},--Sea King Mk42 [HAS.1]
        {type='Facility', dbid=100, points=0, name='Marker (City)', destroyedString='destroyed'},--Marker (City)
        {type='Facility', dbid=1610, points=0, name='Single-Unit Airfield (Heliport)', destroyedString='destroyed'},--Single-Unit Airfield (Heliport)
        {type='Ship', dbid=1276, points=150, name='F 149 Khukri', destroyedString='sunk'},--F 149 Khukri
        {type='Ship', dbid=972, points=150, name='F 144 Kirpan', destroyedString='sunk'},--F 144 Kirpan
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('India_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('India',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
        ChangeScore('Pakistan',matchData.points,'An Indian '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
        local remainingShips = 0
        local sideUnits = VP_GetSide({side='India'}).units
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Ship' then
                remainingShips = remainingShips + 1
            end
        end
        local playerSide = ScenEdit_PlayerSide()
        if remainingShips == 0 then
            if playerSide == 'India' then
                ScenEdit_SpecialMessage('India',"All vessels under your command have been destroyed.")
                ScenEdit_EndScenario()
            else
                local theMessage = NonAlignedSignal(
                    'S 131 Hangor', --recipient
                    'NAVAL HQ KARACHI', --sender
                    'UPDATED ORDERS', --subject
                    'SECRET', --classification
                    'PRIORITY', --precedence
                    'HQ ACKNOWLEDGES YOUR REPORTS OF SINKING 2 X INDIAN SURFACE COMBATANTS.</P> <P>BRAVO ZULU.</P> <P>WITHDRAW AND RETURN TO BASE IN KARACHI FOR DEBRIEFING.')
            
                ScenEdit_SpecialMessage('playerside',theMessage)
                RegisterMessage(theMessage)

                ScenEdit_SetEvent('PAK_SubWithdraw',{isactive=true})
            end
        end
    end
end