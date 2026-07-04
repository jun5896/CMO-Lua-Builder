local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Facility', dbid=340, points=100, name='infantry platoon', destroyedString='destroyed'},--Inf Plt
        {type='Ship', dbid=1110, points=100, name='patrol boat', destroyedString='sunk'},--MPK Shanghai
        {type='Ship', dbid=1111, points=100, name='patrol boat', destroyedString='sunk'},--MPK SO1 [Pr.201M]
        {type='Ship', dbid=1321, points=100, name='armed cargo vessel', destroyedString='sunk'},--Civilian Junk [35m, Armed]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('NVA_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('MACV',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')

        local remainingShips = 0
        local sideUnits = VP_GetSide({side='North Vietnam'}).units
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Ship' then
                remainingShips = remainingShips + 1
            end
        end
        if remainingShips == 0 then
            ChangeScore('MACV',500,'All enemy ships destroyed.')
            ScenEdit_SpecialMessage('MACV',"All suspect vessels have been destroyed.")
            ScenEdit_EndScenario()
        end
    end
end