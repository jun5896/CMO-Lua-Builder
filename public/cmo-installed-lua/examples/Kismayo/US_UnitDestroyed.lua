local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
		{type='Aircraft', dbid=1006, points=500, name='MQ-8B Fire Scout UAV', destroyedString='destroyed', isDrone=true},--MQ-8B Fire Scout UAV
		{type='Aircraft', dbid=2006, points=1000, name='MH-60R Seahawk', destroyedString='destroyed'},--MH-60R Seahawk
		{type='Aircraft', dbid=2843, points=1000, name='AH-1Z Viper [Super Cobra]', destroyedString='destroyed'},--AH-1Z Viper [Super Cobra]
		{type='Aircraft', dbid=2859, points=2500, name='AV-8B Harrier II+ [Night Attack]', destroyedString='destroyed'},--AV-8B Harrier II+ [Night Attack]
		{type='Aircraft', dbid=297, points=2000, name='MV-22B Osprey', destroyedString='destroyed'},--MV-22B Osprey
		{type='Facility', dbid=884, points=1000, name='Inf Sec (US Navy SEAL Recon Team)', destroyedString='KIA'},--Inf Sec (US Navy SEAL Recon Team)
		{type='Facility', dbid=2987, points=1000, name='Inf Sec', destroyedString='KIA'},--Inf Sec
		{type='Ship', dbid=1840, points=10000, name='LCS 2 Independence', destroyedString='sunk'},--LCS 2 Independence
		{type='Ship', dbid=759, points=10000, name='LHD 2 Essex [Wasp]', destroyedString='sunk'},--LHD 2 Essex [Wasp]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('US_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
		ChangeScore('United States',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
		
		if not matchData.isDrone and theDestroyedUnit.type == 'Aircraft' then
			GenerateSurvivors(theDestroyedUnit.latitude,theDestroyedUnit.longitude,theDestroyedUnit.name)
		end
    end
end