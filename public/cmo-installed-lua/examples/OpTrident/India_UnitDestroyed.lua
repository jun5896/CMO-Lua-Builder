local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Ship', dbid=523, points=1000, name='A 60 Dharini', destroyedString='sunk'},--A 60 Dharini
        {type='Ship', dbid=967, points=200, name='K 80 Veer [Pr.205 Osa I, Vidyut Class]', destroyedString='sunk'},--K 80 Veer [Pr.205 Osa I, Vidyut Class]
        {type='Ship', dbid=969, points=200, name='P 68 Arnala [Pr.159AE Petya III]', destroyedString='sunk'},--P 68 Arnala [Pr.159AE Petya III]
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

        local remainingShips = 0
        local sideUnits = VP_GetSide({side='India'}).units
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Ship' then
                remainingShips = remainingShips + 1
            end
        end
        if remainingShips == 0 then
            ScenEdit_SpecialMessage('India',"All vessels under your command have been destroyed.")
            ScenEdit_EndScenario()
        end
    end
end