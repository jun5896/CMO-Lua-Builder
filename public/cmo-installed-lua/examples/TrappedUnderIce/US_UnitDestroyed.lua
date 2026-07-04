local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Submarine', dbid=277, points=150, name='SSN 751 San Juan [Improved Los Angeles Class]', destroyedString='sunk'},--SSN 751 San Juan [Improved Los Angeles Class]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('US_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('United States',matchData.points * -1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
        ScenEdit_SpecialMessage('United States',"All vessels under your command have been destroyed.")
        ScenEdit_EndScenario()
    end
end