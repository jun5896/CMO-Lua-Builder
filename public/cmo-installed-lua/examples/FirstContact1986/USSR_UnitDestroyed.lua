local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Ship', dbid=1007, points=300, name='destroyer', destroyedString='sunk'},--BPK Kashin [Pr.61]
        {type='Ship', dbid=134, points=100, name='missile boat', destroyedString='sunk'},--RK Osa II [Pr.205U]
        {type='Ship', dbid=68, points=200, name='corvette', destroyedString='sunk'},--MRK Nanuchka III [Pr.1234.1 Ovod]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('USSR_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('Norway',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')
        ChangeScore('Soviet Union',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')

        local remainingShips = 0
        local sideUnits = VP_GetSide({side='Soviet Union'}).units
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Ship' then
                remainingShips = remainingShips + 1
            end
        end
        if remainingShips == 0 then
            ChangeScore('Norway',500,'All enemy ships destroyed.')
            ScenEdit_SpecialMessage('Norway',"All enemy vessels have been destroyed.")
            ScenEdit_SpecialMessage('Soviet Union',"All vessels under your command have been destroyed.")
            ScenEdit_EndScenario()
        end
    end
end