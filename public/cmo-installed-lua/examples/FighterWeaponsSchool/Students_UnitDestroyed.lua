local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
        {type='Aircraft', dbid=2830, points=-200, name='aircraft', destroyedString='shot down'},--F-4E Phantom II
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Students_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('Students',matchData.points,'A student '..matchData.name.. ' was '..matchData.destroyedString..'.')
        
        local sideUnits = VP_GetSide({side='Students'}).units
        local aircraftRemaining = 0
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Aircraft' then
                aircraftRemaining = aircraftRemaining + 1
            end
        end
        if aircraftRemaining == 0 then
            ChangeScore('Students',-2500,'All aircraft were lost.')
            ScenEdit_EndScenario()
        end
	end
end

