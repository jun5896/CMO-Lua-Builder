local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Ship', dbid=526, points=500, name='CLAA 119 Juneau', destroyedString='sunk'},--CLAA 119 Juneau
        {type='Ship', dbid=454, points=1000, name='C 44 Jamaica', destroyedString='sunk'},--C 44 Jamaica
        {type='Ship', dbid=432, points=500, name='F 57 Black Swan', destroyedString='sunk'},--F 57 Black Swan
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('UN_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('United Nations',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
    end
end