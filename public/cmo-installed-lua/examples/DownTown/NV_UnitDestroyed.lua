local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1212, points=25, name='MiG-17PF Fresco D', destroyedString='destroyed'},--MiG-17PF Fresco D
        {type='Aircraft', dbid=2175, points=25, name='MiG-21PF Fishbed D', destroyedString='destroyed'},--MiG-21PF Fishbed D
        {type='Aircraft', dbid=2186, points=25, name='J-6 Farmer', destroyedString='destroyed'},--J-6 Farmer

        {type='Facility', dbid=100, points=0, name='Marker (City)', destroyedString='destroyed'},--Marker (City)
        {type='Facility', dbid=103, points=0, name='Bridge (Two-lane 60 Tons)', destroyedString='destroyed'},--Bridge (Two-lane 60 Tons)
        {type='Facility', dbid=120, points=0, name='Building (Control Tower)', destroyedString='destroyed'},--Building (Control Tower)
        {type='Facility', dbid=193, points=0, name='AAA Bty (57mm ZSU-57-2 x 4)', destroyedString='destroyed'},--AAA Bty (57mm ZSU-57-2 x 4)
        {type='Facility', dbid=222, points=0, name='AAA Bty (37mm Type 65 Twin x 4)', destroyedString='destroyed'},--AAA Bty (37mm Type 65 Twin x 4)
        {type='Facility', dbid=247, points=0, name='A/C Revetment (1x Medium Aircraft)', destroyedString='destroyed'},--A/C Revetment (1x Medium Aircraft)
        {type='Facility', dbid=256, points=0, name='A/C Revetment (1x Large Aircraft)', destroyedString='destroyed'},--A/C Revetment (1x Large Aircraft)
        {type='Facility', dbid=264, points=0, name='A/C Camouflaged Revetment (1x Medium Aircraft)', destroyedString='destroyed'},--A/C Camouflaged Revetment (1x Medium Aircraft)
        {type='Facility', dbid=283, points=0, name='Bunker (Sector Control Station)', destroyedString='destroyed'},--Bunker (Sector Control Station)
        {type='Facility', dbid=293, points=0, name='Runway (2000m)', destroyedString='destroyed'},--Runway (2000m)
        {type='Facility', dbid=309, points=0, name='Runway (2600m)', destroyedString='destroyed'},--Runway (2600m)
        {type='Facility', dbid=316, points=0, name='Structure (Railway Yard)', destroyedString='destroyed'},--Structure (Railway Yard)
        {type='Facility', dbid=388, points=0, name='Building (Airport Terminal)', destroyedString='destroyed'},--Building (Airport Terminal)
        {type='Facility', dbid=396, points=0, name='Ammo Revetment', destroyedString='destroyed'},--Ammo Revetment
        {type='Facility', dbid=400, points=0, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2001-2600m Runway)
        {type='Facility', dbid=406, points=0, name='Ammo Shelter', destroyedString='destroyed'},--Ammo Shelter
        {type='Facility', dbid=411, points=0, name='Runway-Grade Taxiway (2000m)', destroyedString='destroyed'},--Runway-Grade Taxiway (2000m)
        {type='Facility', dbid=413, points=0, name='Runway-Grade Taxiway (2600m)', destroyedString='destroyed'},--Runway-Grade Taxiway (2600m)
        {type='Facility', dbid=417, points=0, name='AvGas (400k Liter Underground Tank)', destroyedString='destroyed'},--AvGas (400k Liter Underground Tank)
        {type='Facility', dbid=43, points=0, name='AvGas (400k Liter Tank)', destroyedString='destroyed'},--AvGas (400k Liter Tank)
        {type='Facility', dbid=432, points=0, name='A/C Hangar (2x Large Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Large Aircraft)
        {type='Facility', dbid=433, points=0, name='A/C Hangar (2x Medium Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Medium Aircraft)
        {type='Facility', dbid=434, points=0, name='A/C Hangar (2x Small Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Small Aircraft)
        {type='Facility', dbid=440, points=0, name='A/C Tarmac Space (2x Large Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (2x Large Aircraft)
        {type='Facility', dbid=441, points=0, name='A/C Tarmac Space (2x Medium Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (2x Medium Aircraft)
        {type='Facility', dbid=45, points=0, name='AvGas (150k Liter Tank)', destroyedString='destroyed'},--AvGas (150k Liter Tank)
        {type='Facility', dbid=451, points=0, name='Runway Access Point (Very Large Aircraft)', destroyedString='destroyed'},--Runway Access Point (Very Large Aircraft)
        {type='Facility', dbid=621, points=0, name='AAA Bty (ZPU-2 x 4 + Fire Can FC)', destroyedString='destroyed'},--AAA Bty (ZPU-2 x 4 + Fire Can FC)
        {type='Facility', dbid=628, points=0, name='AAA Bty (12.7mm DSHK x 4)', destroyedString='destroyed'},--AAA Bty (12.7mm DSHK x 4)
        {type='Facility', dbid=630, points=0, name='SAM Bn (SA-2d Guideline [S-75 Dvina])', destroyedString='destroyed'},--SAM Bn (SA-2d Guideline [S-75 Dvina])
        {type='Facility', dbid=633, points=0, name='SAM Sec (SA-7a Grail MANPADS x 4)', destroyedString='destroyed'},--SAM Sec (SA-7a Grail MANPADS x 4)
        {type='Facility', dbid=634, points=0, name='AAA Bty (57mm M1950 x 4)', destroyedString='destroyed'},--AAA Bty (57mm M1950 x 4)
        {type='Facility', dbid=66, points=0, name='Radar (Token)', destroyedString='destroyed'},--Radar (Token)

        {type='Ship', dbid=1616, points=50, name='TK P-6 [Pr.183]', destroyedString='sunk'},--TK P-6 [Pr.183]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('NV_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('USN',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')

        ----------Sector control station

        local function CommsDisruptedMessageHasPlayed(boolValue)
            if boolValue == nil then
                return ConvertStringToBoolean(ScenEdit_GetKeyValue('commsDisruptedMessage'))
            elseif boolValue == true then
                ScenEdit_SetKeyValue('commsDisruptedMessage','true')
                return true
            elseif boolValue == false then
                ScenEdit_SetKeyValue('commsDisruptedMessage','false')
                return false
            else
                return nil
            end
        end

        local sectorControlStation = {name='Sector Control Station', guid='1b82ad31-37b1-40c9-8abe-48d1f4b21cbf'}

        if theDestroyedUnit.guid == sectorControlStation.guid and not CommsDisruptedMessageHasPlayed() then
            DisruptNVComms()
            CommsDisruptedMessageHasPlayed(true)
        end

        --------------------Target destroyed messages

        local function TargetDestroyedMessageHasPlayed(boolValue)
            if boolValue == nil then
                return ConvertStringToBoolean(ScenEdit_GetKeyValue('targetDestroyedMessage'))
            elseif boolValue == true then
                ScenEdit_SetKeyValue('targetDestroyedMessage','true')
                return true
            elseif boolValue == false then
                ScenEdit_SetKeyValue('targetDestroyedMessage','false')
                return false
            else
                return nil
            end
        end

        local majorTargets = {
            {name='Paul Domer Bridge', guid='c12ad176-aaf8-4907-b9a1-3d008e4af15b',points=750},
            {name='Yen Vien Railway Yard', guid='13bb60c0-d188-48a5-b735-0229abdeb33a',points=1500},
            {name='Cầu Vĩnh Tuy Bridge', guid='25c4cff5-8f18-4a9d-9158-451811c37ccb',points=750}
        }

        for k,v in ipairs (majorTargets) do
            if theDestroyedUnit.guid == v.guid then
                ChangeScore('USN',v.points,'The '..v.name..' was destroyed.')
            end
        end

        local targetsRemaining = 0
        for k,v in ipairs (majorTargets) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit ~= nil then
                targetsRemaining = targetsRemaining + 1
            end
        end

        if targetsRemaining == 0 and not TargetDestroyedMessageHasPlayed() then
            TelexMessageToPlayer(
                'CAG 61',
                'CLG 6',
                'i',
                'RED CROWN',
                'CARRIER AIR GROUP COMMANDER CVW-2',
                'SECRET',
                '1. STRIKE PACKAGE OBJECTIVES CONFIRMED DESTROYED <BR>2. RECOMMEND RECOVERING CVW-2 AIRCRAFT TO CV 61',
                nil
            )
            TargetDestroyedMessageHasPlayed(true)
        end
    end
end