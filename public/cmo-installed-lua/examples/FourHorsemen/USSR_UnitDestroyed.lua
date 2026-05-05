local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Submarine', dbid=103, points=500, name='PLARK-949A Oscar II [Antey]', destroyedString='sunk'},--PLARK-949A Oscar II [Antey]
        {type='Submarine', dbid=290, points=200, name='PLA-685 Mike [Plavnik]', destroyedString='sunk'},--PLA-685 Mike [Plavnik]
        {type='Submarine', dbid=138, points=200, name='PLA-671RTM Victor III [Shchuka]', destroyedString='sunk'},--PLA-671RTM Victor III [Shchuka]
        {type='Submarine', dbid=56, points=200, name='PLA-705K Alfa [Lira]', destroyedString='sunk'},--PLA-705K Alfa [Lira]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('USSR_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('USN',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
        local numberOfSubsRemaining = 0
        local unitList = VP_GetSide({side='Soviet Union'}).units
        for k,v in ipairs (unitList) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.type == 'Submarine' then
                numberOfSubsRemaining = numberOfSubsRemaining + 1
            end
        end

        if numberOfSubsRemaining == 0 then
            ChangeScore('Soviet Union',-900,'All submarines under your command were lost.')
            ScenEdit_EndScenario()
        end
    end
end