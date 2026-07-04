local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {

        {type='Aircraft', dbid=371, points=50, name='helicopter', destroyedString='destroyed'},--Ka-27PL Helix A
        {type='Ship', dbid=2308, points=375, name='frigate', destroyedString='sunk'},--MPK Gremyashchy [Pr.2038.5, Improved Steregushchy]
        {type='Ship', dbid=68, points=150, name='corvette', destroyedString='sunk'},--MRK Nanuchka III [Pr.1234.1 Ovod]
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
        ChangeScore('Norway',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')
        ChangeScore('Russia',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')

        local remainingShips = 0
        local sideUnits = VP_GetSide({side='Russia'}).units
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Ship' then
                remainingShips = remainingShips + 1
            end
        end
        if remainingShips == 0 then
            ChangeScore('Norway',500,'All enemy ships destroyed.')
            ScenEdit_SpecialMessage('Norway',"All enemy vessels have been destroyed.")
            ScenEdit_SpecialMessage('Russia',"All vessels under your command have been destroyed.")
            ScenEdit_EndScenario()
        end
    end
end