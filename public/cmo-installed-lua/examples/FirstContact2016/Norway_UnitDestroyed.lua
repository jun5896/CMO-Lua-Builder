local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=559, points=50, name='helicopter', destroyedString='destroyed'},--NH90 NFH
        {type='Ship', dbid=1875, points=200, name='frigate', destroyedString='sunk'},--F 310 Fridtjof Nansen
        {type='Ship', dbid=627, points=100, name='corvette', destroyedString='sunk'},--P 960 Skjold
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Norway_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('Russia',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')
        ChangeScore('Norway',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')

        local remainingShips = 0
        local sideUnits = VP_GetSide({side='Norway'}).units
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Ship' then
                remainingShips = remainingShips + 1
            end
        end
        if remainingShips == 0 then
            ChangeScore('Russia',500,'All enemy ships destroyed.')
            ScenEdit_SpecialMessage('Russia',"All enemy vessels have been destroyed.")
            ScenEdit_SpecialMessage('Norway',"All vessels under your command have been destroyed.")
            ScenEdit_EndScenario()
        end
    end
end