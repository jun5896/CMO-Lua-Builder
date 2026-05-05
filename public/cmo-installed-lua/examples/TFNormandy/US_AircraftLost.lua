local destroyedUnit = ScenEdit_UnitX()

if destroyedUnit.dbid == 247 or destroyedUnit.dbid == 512 or destroyedUnit.dbid == 260 then --Unit was a PaveLow, Chinook or Blackhawk

    ScenEdit_PlaySound('radiochirp.mp3')
    RadioMessageToPlayer("BREAK BREAK BREAK, " .. destroyedUnit.name .. " is down. Mission abort, repeat, mission abort.")
    ChangeScore('playerside',-500,'An American '..destroyedUnit.classname..' ('..destroyedUnit.name..') was shot down.')
    ChangeScore('playerside',-500,'The mission was aborted due to loss of a critical support asset ('..destroyedUnit.name..').')
    ScenEdit_EndScenario()

elseif destroyedUnit.dbid == 1603 then --Destroyed unit was an Apache

    numberOfApachesLost = IncrementApacheLosses()
    ChangeScore('playerside',-250,'An American '..destroyedUnit.classname..' ('..destroyedUnit.name..') was shot down.')
    
    if numberOfApachesLost >= 3 then
        
        RadioMessageToPlayer("BREAK BREAK BREAK, " .. destroyedUnit.name .. " is down. We've taken too many losses. Mission abort, repeat, mission abort.")
        ChangeScore('playerside',-500,'The mission was aborted due to heavy losses.')
        ScenEdit_EndScenario()

    elseif numberOfApachesLost == 2 then
        
        RadioMessageToPlayer("BREAK BREAK BREAK; Eagle 6 be advised " .. destroyedUnit.name .. " " .. "is down. They went in hard, there's no survivors.")

    elseif numberOfApachesLost == 1 then

        math.randomseed(os.time())

        local wreckage = ScenEdit_AddUnit({
            type='Facility', 
            dbid=2350, 
            side=destroyedUnit.side, 
            name=destroyedUnit.name .. " " .. "Wreckage", 
            latitude=destroyedUnit.latitude,
            longitude=destroyedUnit.longitude
        })

        local aircrewPosition = CircularRandomPosition(wreckage.latitude, wreckage.longitude, 0.5)

        local aircrew = ScenEdit_AddUnit({
            type='Facility', 
            dbid=2441, 
            side=destroyedUnit.side, 
            name=destroyedUnit.name.." Aircrew", 
            latitude=aircrewPosition.latitude, 
            longitude=aircrewPosition.longitude
        })

        local blastMissionCircle = World_GetCircleFromPoint({
            latitude=wreckage.latitude,
            longitude=wreckage.longitude,
            radius=25,
            numpoints=4
        })
        
        for i = 1,4 do
            ScenEdit_SetReferencePoint({
                side='USAF',
                name='Blast '..i,
                latitude=blastMissionCircle[i].latitude,
                longitude=blastMissionCircle[i].longitude,
            })
        end

        --Assign blue a/c to mission
        ScenEdit_AssignUnitToMission('Blast 1', 'Blast')
        ScenEdit_AssignUnitToMission('Blast 2', 'Blast')

        --Message informing player
        RadioMessageToPlayer("BREAK BREAK BREAK; Eagle 6 be advised " .. destroyedUnit.name .. " " .. "is down.")

        --Blast on the way
        RadioMessageToPlayer("Eagle 6 this is Blast 4 Actual; Acknowledged the last. We're inbound hot, request aircraft in vicinity remain below angels 3. Blast flight is cleared hot hostile ground targets IVO " .. destroyedUnit.name .. " crash site")
        
        ScenEdit_SetEvent('US_CSAR',{isactive=true})
    end
end