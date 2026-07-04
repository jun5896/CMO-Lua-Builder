local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1139, points=250, name='Tu-16R Badger E', destroyedString='destroyed'},--Tu-16R Badger E
        {type='Aircraft', dbid=1321, points=250, name='Tu-16RM-1/2 Badger D', destroyedString='destroyed'},--Tu-16RM-1/2 Badger D
        {type='Aircraft', dbid=2156, points=50, name='Su-27P Flanker B', destroyedString='destroyed'},--Su-27P Flanker B
        {type='Aircraft', dbid=2253, points=50, name='MiG-31 Foxhound', destroyedString='destroyed'},--MiG-31 Foxhound
        {type='Aircraft', dbid=50, points=50, name='Ka-25BSh Hormone A', destroyedString='destroyed'},--Ka-25BSh Hormone A
        {type='Aircraft', dbid=692, points=50, name='Be-12PL Mail', destroyedString='destroyed'},--Be-12PL Mail
        {type='Aircraft', dbid=2437, points=350, name='Tu-22M-2 Backfire B', destroyedString='destroyed'},--Tu-22M-2 Backfire B
        {type='Aircraft', dbid=326, points=50, name='Mi-14PS Haze C', destroyedString='destroyed'},--Mi-14PS Haze C

        {type='Facility', dbid=1155, points=0, name='Radar (Back Net [P-80])', destroyedString='destroyed'},--Radar (Back Net [P-80])
        {type='Facility', dbid=1335, points=0, name='Radar (Spoon Rest D [P-18])', destroyedString='destroyed'},--Radar (Spoon Rest D [P-18])
        {type='Facility', dbid=1592, points=0, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 3201-4000m Runway)
        {type='Facility', dbid=1593, points=0, name='Single-Unit Airfield (1x 1401-2000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 1401-2000m Runway)
        {type='Facility', dbid=16, points=0, name='SAM Bn (SA-2f Guideline [S-75M Volkhov])', destroyedString='destroyed'},--SAM Bn (SA-2f Guideline [S-75M Volkhov])
        {type='Facility', dbid=1787, points=0, name='SAM Bn (SA-3c Goa [S-125M1 Neva-M])', destroyedString='destroyed'},--SAM Bn (SA-3c Goa [S-125M1 Neva-M])
        {type='Facility', dbid=188, points=0, name='Radar (Bar Lock A [P-37])', destroyedString='destroyed'},--Radar (Bar Lock A [P-37])
        {type='Facility', dbid=270, points=0, name='Radar (Long Track [P-40])', destroyedString='destroyed'},--Radar (Long Track [P-40])
        {type='Facility', dbid=587, points=0, name='SAM Grp (SA-5c Gammon [S-200M Vega M], 2x Bn)', destroyedString='destroyed'},--SAM Grp (SA-5c Gammon [S-200M Vega M], 2x Bn)

        {type='Ship', dbid=1007, points=1000, name='BPK Kashin [Pr.61]', destroyedString='sunk'},--BPK Kashin [Pr.61]
        {type='Ship', dbid=1287, points=1000, name='EM Sovremenny I [Pr.956 Sarych]', destroyedString='sunk'},--EM Sovremenny I [Pr.956 Sarych]
        {type='Ship', dbid=155, points=3000, name='BPK Kresta II [Pr.1134A Berkut A]', destroyedString='sunk'},--BPK Kresta II [Pr.1134A Berkut A]
        {type='Ship', dbid=94, points=1000, name='SKR Krivak III [Pr.1135.1 Nerei]', destroyedString='sunk'},--SKR Krivak III [Pr.1135.1 Nerei]

        {type='Submarine', dbid=236, points=1000, name='PLA-971 Akula I [Shchuka-B]', destroyedString='sunk'},--PLA-971 Akula I [Shchuka-B]
    }


	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('USSR_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
    else
        ChangeScore('Soviet Union',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
        ChangeScore('United States',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')
        if theDestroyedUnit.type == 'Aircraft' and ScenEdit_PlayerSide() == 'Soviet Union' then
            GenerateSurvivors(theDestroyedUnit.latitude,theDestroyedUnit.longitude,theDestroyedUnit.name)
        end
    end

    local function FirstUSSRUnitHasBeenDestroyed(boolValue)
        if boolValue == nil then
            return ConvertStringToBoolean(ScenEdit_GetKeyValue('unitDestroyedUSSR'))
        elseif boolValue == true then
            ScenEdit_SetKeyValue('unitDestroyedUSSR','true')
            return true
        elseif boolValue == false then
            ScenEdit_SetKeyValue('unitDestroyedUSSR','false')
            return false
        else
            return nil
        end
    end

    if not FirstUSSRUnitHasBeenDestroyed() then
        if ScenEdit_PlayerSide() == 'Soviet Union' then
            local unitDescription = theDestroyedUnit.classname..' '..theDestroyedUnit.type
            if theDestroyedUnit.type == 'Ship' or theDestroyedUnit.type == 'Submarine' then
                unitDescription = theDestroyedUnit.name
            end
            TelexMessageToPlayerSoviet(
                'strazh',
                'central operations directorate - moscow',
                'updated orders',
                'ob',
                'monolit',
                '1. acknowledge your report of loss of '..unitDescription..' <BR>'..
                '2. american provocations and aggression have reached a level that can no longer be tolerated <BR>'..
                '3. you are directed to mount a retaliatory strike on american naval vessels transiting near petropavlovsk <BR>'..
                '4. aim to sink at least one american surface unit <BR>'..
                '5. minimise own losses' , 
                nil --location
            )
        end
        CommenceHostilities()
        FirstUSSRUnitHasBeenDestroyed(true)
    end
end