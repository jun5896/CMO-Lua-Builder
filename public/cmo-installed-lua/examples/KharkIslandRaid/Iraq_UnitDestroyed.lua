local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {dbid=1202, name='Mirage F.1EQ-5', type='Aircraft', points=100, descriptor='shot down.'}, --Mirage F.1EQ-5
        {dbid=1881, name='Radar (Bar Lock A [P-37])', type='Facility', points=250, descriptor='destroyed... How on earth did you let that happen?!'}, --Radar (Bar Lock A [P-37])
        {dbid=2238, name='MiG-23ML Flogger G', type='Aircraft', points=100, descriptor='shot down.'}, --MiG-23ML Flogger G
        {dbid=356, name='Su-22M-3K Fitter J', type='Aircraft', points=125, descriptor='shot down.'}, --Su-22M-3K Fitter J
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid then
            matchData = v
        end
    end

    if matchData == {} then
        BugMessage('Iraq_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('Iraq',matchData.points*-1,'An Iraqi '..matchData.name.. ' was '..matchData.descriptor)
    end

end
