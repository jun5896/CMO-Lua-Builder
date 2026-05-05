local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Ship', dbid=1009, points=200, name='frigate', destroyedString='sunk'},--MGB Fairmile D
        {type='Ship', dbid=208, points=150, name='torpedo boat', destroyedString='sunk'},--P 351 Rapp
        {type='Ship', dbid=218, points=200, name='frigate', destroyedString='sunk'},--F Draug
        {type='Ship', dbid=853, points=250, name='destroyer', destroyedString='sunk'},--D Arendal
        {type='Ship', dbid=999, points=250, name='destroyer', destroyedString='sunk'},--D 306 Stavanger
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
        ChangeScore('Soviet Union',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')
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
            ChangeScore('Soviet Union',500,'All enemy ships destroyed.')
            ScenEdit_SpecialMessage('Soviet Union',"All enemy vessels have been destroyed.")
            ScenEdit_SpecialMessage('Norway',"All vessels under your command have been destroyed.")
            ScenEdit_EndScenario()
        end
    end
end