local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=1110, points=250, name='P-3B Orion', destroyedString='destroyed'},--P-3B Orion
        {type='Aircraft', dbid=2009, points=250, name='KC-130H Hercules', destroyedString='destroyed'},--KC-130H Hercules
        {type='Aircraft', dbid=2100, points=120, name='S-2T Turbo Tracker', destroyedString='destroyed'},--S-2T Turbo Tracker
        {type='Aircraft', dbid=405, points=50, name='AS.555SN Fennec', destroyedString='destroyed'},--AS.555SN Fennec
        {type='Aircraft', dbid=73, points=120, name='A-4AR Fightinghawk', destroyedString='destroyed'},--A-4AR Fightinghawk
        {type='Aircraft', dbid=790, points=120, name='Super Etendard', destroyedString='destroyed'},--Super Etendard

        {type='Facility', dbid=1592, points=0, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 3201-4000m Runway)
        {type='Facility', dbid=1877, points=0, name='Single-Unit Airfield (1x 2600-3200m, Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2600-3200m, Runway)

        {type='Ship', dbid=3, points=1000, name='D 10 Almirante Brown [Meko 360H2]', destroyedString='sunk'},--D 10 Almirante Brown [Meko 360H2]
        {type='Ship', dbid=4, points=500, name='P 41 Espora [Meko 140/A16]', destroyedString='sunk'},--P 41 Espora [Meko 140/A16]

        {type='Submarine', dbid=37, points=500, name='S 41 Santa Cruz [TR 1700]', destroyedString='sunk'},--S 41 Santa Cruz [TR 1700]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('ARG_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('Argentina',matchData.points*-0.5,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
        ChangeScore('United Kingdom',matchData.points,'An Argentine '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
    end
end