local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Facility', dbid=100, points=0, name='Marker (City)', destroyedString='sunk'},--Marker (City)
        {type='Ship', dbid=1152, points=200, name='311 Mivtach [Saar 2]', destroyedString='sunk'},--311 Mivtach [Saar 2]
        {type='Ship', dbid=1154, points=200, name='340 Reshef [Saar 4]', destroyedString='sunk'},--340 Reshef [Saar 4]
        {type='Ship', dbid=1163, points=200, name='331 Saar [Saar 3]', destroyedString='sunk'},--331 Saar [Saar 3]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('Israel_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('Israel',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
        local remainingShips = 0
        local sideUnits = VP_GetSide({side='Israel'}).units
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Ship' then
                remainingShips = remainingShips + 1
            end
        end
        if remainingShips == 0 then
            ScenEdit_SpecialMessage('Israel',"All vessels under your command have been destroyed.")
            ScenEdit_EndScenario()
        end
    end
end