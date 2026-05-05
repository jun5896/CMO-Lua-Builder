local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Facility', dbid=100, points=0, name='Marker (City)', destroyedString='sunk'},--Marker (City)
        {type='Ship', dbid=1478, points=100, name='RKA Komar', destroyedString='sunk'},--RKA Komar
        {type='Ship', dbid=1480, points=200, name='RK Osa I [Pr.205]', destroyedString='sunk'},--RK Osa I [Pr.205]
        {type='Ship', dbid=1482, points=150, name='TK P-6 [Pr.183]', destroyedString='sunk'},--TK P-6 [Pr.183]
        {type='Ship', dbid=1483, points=100, name='MT T-43 [Pr.254K/M]', destroyedString='sunk'},--MT T-43 [Pr.254K/M]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('Syria_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('Israel',matchData.points*1,'A Syrian '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
        local remainingShips = 0
        local sideUnits = VP_GetSide({side='Syria'}).units
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Ship' then
                remainingShips = remainingShips + 1
            end
        end
        ScenEdit_MsgBox(remainingShips,0)
        if remainingShips == 0 then
            ScenEdit_SpecialMessage('Israel',"All enemy vessels have been destroyed.")
            ScenEdit_EndScenario()
        end
    end
end