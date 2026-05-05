local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {

        {type='Aircraft', dbid=1402, points=25, name='MiG-29 Fulcrum C', destroyedString='destroyed'},--MiG-29 Fulcrum C

        {type='Facility', dbid=1560, points=10, name='SAM Sec (SA-24 Grouse [9K338 Igla-S] MANPADS x 3)', destroyedString='destroyed'},--SAM Sec (SA-24 Grouse [9K338 Igla-S] MANPADS x 3)
        {type='Facility', dbid=1592, points=0, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 3201-4000m Runway)
        {type='Facility', dbid=1613, points=50, name='Radar (Back Net [P-80])', destroyedString='destroyed'},--Radar (Back Net [P-80])
        {type='Facility', dbid=1628, points=50, name='Radar (Tin Shield B [5N59S/36D6])', destroyedString='destroyed'},--Radar (Tin Shield B [5N59S/36D6])
        {type='Facility', dbid=1712, points=0, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2001-2600m Runway)
        {type='Facility', dbid=177, points=0, name='Bunker (Sector Control Station)', destroyedString='destroyed'},--Bunker (Sector Control Station)
        {type='Facility', dbid=188, points=50, name='Radar (Bar Lock A [P-37])', destroyedString='destroyed'},--Radar (Bar Lock A [P-37])
        {type='Facility', dbid=249, points=200, name='SAM Bty (SA-4 Ganef [2K11 Krug])', destroyedString='destroyed'},--SAM Bty (SA-4 Ganef [2K11 Krug])
        {type='Facility', dbid=250, points=10, name='SAM Plt (SA-19 Grisom [9K22 Tunguska])', destroyedString='destroyed'},--SAM Plt (SA-19 Grisom [9K22 Tunguska])
        {type='Facility', dbid=253, points=20, name='SAM Bn (SA-3c Goa [S-125M1 Neva-M])', destroyedString='destroyed'},--SAM Bn (SA-3c Goa [S-125M1 Neva-M])
        {type='Facility', dbid=265, points=50, name='Radar (Spoon Rest D [P-18])', destroyedString='destroyed'},--Radar (Spoon Rest D [P-18])
        {type='Facility', dbid=269, points=20, name='SAM Bn (SA-2f Guideline [S-75M Volkhov])', destroyedString='destroyed'},--SAM Bn (SA-2f Guideline [S-75M Volkhov])
        {type='Facility', dbid=333, points=50, name='Radar (Tall King A [P-14])', destroyedString='destroyed'},--Radar (Tall King A [P-14])
        {type='Facility', dbid=386, points=0, name='SAM Bn (SA-20b Gargoyle [S-300PMU-2 Favorit])', destroyedString='destroyed'},--SAM Bn (SA-20b Gargoyle [S-300PMU-2 Favorit])
        {type='Facility', dbid=386, points=1000, name='SAM Bn (SA-20b Gargoyle [S-300PMU-2])', destroyedString='destroyed'},--SAM Bn (SA-20b Gargoyle [S-300PMU-2])
        {type='Facility', dbid=420, points=10, name='SAM Sec (SA-18 Grouse [9K38 Igla] MANPADS x 3)', destroyedString='destroyed'},--SAM Sec (SA-18 Grouse [9K38 Igla] MANPADS x 3)
        {type='Facility', dbid=426, points=10, name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', destroyedString='destroyed'},--SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)
        {type='Facility', dbid=587, points=500, name='SAM Grp (SA-5c Gammon [S-200M Vega M], 2x Bn)', destroyedString='destroyed'},--SAM Grp (SA-5c Gammon [S-200M Vega M], 2x Bn)
        {type='Facility', dbid=80, points=10, name='AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)', destroyedString='destroyed'},--AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)
    }

    



	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('AZ_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('Russia',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')

        ---War footing
        local function WarFootingIsOn(boolValue)
            if boolValue == 'destroyed' then
                return ConvertStringToBoolean(ScenEdit_GetKeyValue('warFooting'))
            elseif boolValue == true then
                ScenEdit_SetKeyValue('warFooting','true')
                return true
            elseif boolValue == false then
                ScenEdit_SetKeyValue('warFooting','false')
                return false
            else
                return 'destroyed'
            end
        end

        if not WarFootingIsOn() then
            ScenEdit_SetDoctrine({side="Azerbaijan"}, {weapon_control_status_air=1})
            WarFootingIsOn(true)
        end

        ----------Sector control station

        local function CommsDisruptedMessageHasPlayed(boolValue)
            if boolValue == 'destroyed' then
                return ConvertStringToBoolean(ScenEdit_GetKeyValue('commsDisruptedMessage'))
            elseif boolValue == true then
                ScenEdit_SetKeyValue('commsDisruptedMessage','true')
                return true
            elseif boolValue == false then
                ScenEdit_SetKeyValue('commsDisruptedMessage','false')
                return false
            else
                return 'destroyed'
            end
        end

        local sectorControlStation = {name='Bunker (Sector Control Station)', guid='5236e824-ebe7-424d-a5f9-f2bff12ba838'}

        if theDestroyedUnit.guid == sectorControlStation.guid and not CommsDisruptedMessageHasPlayed() then
            DisruptAZComms()
            CommsDisruptedMessageHasPlayed(true)
        end

        --------------------Target destroyed messages

        local function TargetDestroyedMessageHasPlayed(boolValue)
            if boolValue == 'destroyed' then
                return ConvertStringToBoolean(ScenEdit_GetKeyValue('targetDestroyedMessage'))
            elseif boolValue == true then
                ScenEdit_SetKeyValue('targetDestroyedMessage','true')
                return true
            elseif boolValue == false then
                ScenEdit_SetKeyValue('targetDestroyedMessage','false')
                return false
            else
                return 'destroyed'
            end
        end

        local majorTargets = {
            {name='SAM Bn (SA-20b Gargoyle [S-300PMU-2])', guid='9e5180c8-6c65-4361-a8fb-9f6e138a7a33'},
            {name='SAM Bty (SA-4 Ganef [2K11 Krug])', guid='fdd0ce52-9f30-400e-b624-e94c7b509d75'},
            {name='SAM Bty (SA-4 Ganef [2K11 Krug])', guid='8d031a8e-a078-41de-bd2f-a3209837aa69'},
            {name='SAM Bty (SA-4 Ganef [2K11 Krug])', guid='d300ae4b-ba1c-4864-9503-ada51174c072'},
            {name='SAM Grp (SA-5c Gammon [S-200M Vega M], 2x Bn)', guid='640a7c08-a17a-4fba-b055-07b568f22df5'},
            {name='SAM Grp (SA-5c Gammon [S-200M Vega M], 2x Bn)', guid='ea26ec18-c50b-4ea2-a768-f86216f52c09'},
        }

        local targetsRemaining = 0
        for k,v in ipairs (majorTargets) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit ~= 'destroyed' then
                targetsRemaining = targetsRemaining + 1
            end
        end

        if targetsRemaining == 0 and not TargetDestroyedMessageHasPlayed() then
            TelexMessageToPlayer(
                "IRON HAND",
                'Main Intelligence Directorate',
                'subject',
                'Sovershenno sekretno',
                'Vozdukh',
                '1. MISSION OBJECTIVES CONFIRMED DESTROYED <BR>2. MISSION COMPLETE',
                'destroyed'
            )
            TargetDestroyedMessageHasPlayed(true)
        end
    end
end