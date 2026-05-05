local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {name='Dash-8-300 MPA', dbid=2064, type='Aircraft', points=50, descriptor='destroyed'},
        {name='OV-10D Bronco', dbid=2997, type='Aircraft', points=25, descriptor='destroyed'},
        {name='AS.555SN', dbid=405, type='Aircraft', points=25, descriptor='destroyed'},
        {name='Kfir C.7', dbid=1253, type='Aircraft', points=25, descriptor='destroyed'},
        {name='UH-60L Blackhawk', dbid=4251, type='Aircraft', points=20, descriptor='destroyed'},
        {name='AH-60A Arpia III', dbid=4252, type='Aircraft', points=20, descriptor='destroyed'},
        {name='Mi-17V5 Hip H', dbid=3879, type='Aircraft', points=20, descriptor='destroyed'},
        {name='Bell 412EP', dbid=4094, type='Aircraft', points=25, descriptor='destroyed'},
        
        {name='BL 161 Cartagena de Indias', dbid=1929, points=0, descriptor='sunk in a surprise attack!'},
        {name='FM 53 Antioquia', dbid=1924, type='Ship', points=25, descriptor='sunk'},
        {name='SO 28 Pijao', dbid=242, type='Submarine', points=25, descriptor='sunk'},
        
        {name='AN/TPS-70 Early Warning Radar', dbid=1563, type='Facility', points=25, descriptor='destroyed'},
        {name='SF Recon Team', dbid=614, type='Facility', points=25, descriptor='KIA'},
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid then
            matchData = v
        end
    end

    if matchData == {} then
        BugMessage('Colombia_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('Colombia',matchData.points*-1,'A Colombian '..matchData.name.. ' was '..matchData.descriptor..'.')
    end

    ----------------------

    if theDestroyedUnit.dbid == 1929 then
        local liferaftDBID = 2553
        local liferaftSpawnPoint = {latitude=theDestroyedUnit.latitude,longitude=theDestroyedUnit.longitude}
        for i = 1, 4 do
            local thisLiferaftPositionList = World_GetCircleFromPoint({latitude=liferaftSpawnPoint.latitude,longitude=liferaftSpawnPoint.longitude,radius=math.random(1,15)/10,numpoints=36})
            local thisLiferaftPosition = thisLiferaftPositionList[math.random(1,#thisLiferaftPositionList)]
            local liferaft = ScenEdit_AddUnit({side='Survivors', type='Ship', name=theDestroyedUnit.name..' Liferaft #'..i, dbid = liferaftDBID, latitude=thisLiferaftPosition.latitude, longitude=thisLiferaftPosition.longitude})
        end
        
		local descriptionString = 'vhf distress call received from '..theDestroyedUnit.name..' followed by epirb activation. <BR>confirm '..theDestroyedUnit.name..' sunk with survivors in the water.'
        local theMessage = ACP126('TODOS','SAROPS','r','search and rescue operations','ALL STATIONS','confidential',descriptionString)
        ScenEdit_SpecialMessage('playerside',theMessage)
        RegisterMessage(theMessage)
		
        local theMessage = ACP126('OBISPO','HQJOC','o','joint operations command bogota','obispo','secret',theDestroyedUnit.name..' reported contact with a POSSUB via periscope sighting moments before being struck by presumed torpedoes. Understand this to be an act of war, most likely perpetrated by venezuelan submarine.</p> <p>Revised orders as follows: <BR> 1. Immediately dispatch SAR resources to last known position of '..theDestroyedUnit.name..' to effect rescue of survivors <BR> 2. Commence aggressive ASW operations at same. You are clear to attack identified venezuelan submarines within 10nm of last known position of '..theDestroyedUnit.name..' <BR> 3. Immediately prepare for accelerated raid on rebel camp as per daily orders; anticipate green light for raid launch within 90 minutes. <BR> 4. await further intelligence and permission to launch raid before committing forces.</p> ROE changes: <BR> Air - Tight <BR> surface - tight <br> subsurface - tight with exception of free fire zone as described above.')
        ScenEdit_SpecialMessage('playerside',theMessage)
        RegisterMessage(theMessage)
		
        local circle = World_GetCircleFromPoint({latitude=theDestroyedUnit.latitude, longitude=theDestroyedUnit.longitude, radius=10, numpoints = 12})
        for k,v in ipairs (circle) do
            local refPoint = ScenEdit_AddReferencePoint({side='Colombia',name='ASW Free Fire Zone #'..k,latitude=v.latitude,longitude=v.longitude,highlighted=true})
        end
    end
end
