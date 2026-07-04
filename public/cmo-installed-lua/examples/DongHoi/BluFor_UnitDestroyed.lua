local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=1711, points=500, name='SH-2D Seasprite LAMPS I', destroyedString='destroyed'},--SH-2D Seasprite LAMPS I
        {type='Aircraft', dbid=273, points=500, name='EC-121 Q Gold Digger', destroyedString='destroyed'},--EC-121 Q Gold Digger
        {type='Aircraft', dbid=338, points=500, name='OH-6A Cayuse [MD-500D]', destroyedString='destroyed'},--OH-6A Cayuse [MD-500D]
        {type='Ship', dbid=756, points=6000, name='CG 26 Belknap', destroyedString='sunk'},--CG 26 Belknap
        {type='Ship', dbid=778, points=3000, name='DD 710 Gearing FRAM 1 Group B', destroyedString='sunk'},--DD 710 Gearing FRAM 1 Group B
        {type='Ship', dbid=787, points=3000, name='DD 710 Gearing FRAM 2 Ex DDE', destroyedString='sunk'},--DD 710 Gearing FRAM 2 Ex DDE
        {type='Ship', dbid=802, points=6000, name='CLG 5 Oklahoma City', destroyedString='sunk'},--CLG 5 Oklahoma City
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('BluFor_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('USN',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
    end
end