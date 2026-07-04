local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=10, points=100, name='F-14A Tomcat', destroyedString='destroyed'},--F-14A Tomcat
        {type='Aircraft', dbid=17, points=250, name='EA-6B Prowler ICAP II Blk 82', destroyedString='destroyed'},--EA-6B Prowler ICAP II Blk 82
        {type='Aircraft', dbid=2327, points=125, name='A-6E Intruder', destroyedString='destroyed'},--A-6E Intruder
        {type='Aircraft', dbid=270, points=250, name='E-2C Hawkeye Basic', destroyedString='destroyed'},--E-2C Hawkeye Basic
        {type='Aircraft', dbid=2710, points=125, name='S-3A Viking', destroyedString='destroyed'},--S-3A Viking
        {type='Aircraft', dbid=2803, points=250, name='P-3C Orion Update II', destroyedString='destroyed'},--P-3C Orion Update II
        {type='Aircraft', dbid=2830, points=50, name='SH-2F Seasprite', destroyedString='destroyed'},--SH-2F Seasprite
        {type='Aircraft', dbid=43, points=100, name='A-6E Intruder', destroyedString='destroyed'},--A-6E Intruder
        {type='Aircraft', dbid=7, points=50, name='SH-3H Sea King', destroyedString='destroyed'},--SH-3H Sea King
        {type='Aircraft', dbid=583, points=125, name='F-15C Eagle', destroyedString='destroyed'},--F-15C Eagle

        {type='Facility', dbid=152, points=0, name='Radar (AN/TPS-63)', destroyedString='destroyed'},--Radar (AN/TPS-63)
        {type='Facility', dbid=1713, points=0, name='Single-Unit Airfield (2x 2001-2600m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2001-2600m Runways)
        {type='Facility', dbid=1877, points=0, name='Single-Unit Airfield (1x 2600-3200m, Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2600-3200m, Runway)
        {type='Facility', dbid=763, points=0, name='Radar (AN/FPS-108 Cobra Dane)', destroyedString='destroyed'},--Radar (AN/FPS-108 Cobra Dane)

        {type='Ship', dbid=114, points=1000, name='DD 963 Spruance [VLS]', destroyedString='sunk'},--DD 963 Spruance [VLS]
        {type='Ship', dbid=1628, points=100000, name='CV 61 Ranger [Forrestal Class]', destroyedString="sunk! May god have mercy on your soul, because the Pentagon won't!"},--CV 61 Ranger [Forrestal Class]
        {type='Ship', dbid=1810, points=1000, name='AOE 1 Sacramento', destroyedString='sunk'},--AOE 1 Sacramento
        {type='Ship', dbid=1841, points=1000, name='FF 1052 Knox', destroyedString='sunk'},--FF 1052 Knox
        {type='Ship', dbid=1994, points=1000, name='CG 26 Belknap', destroyedString='sunk'},--CG 26 Belknap
        {type='Ship', dbid=750, points=1000, name='DDG 2 Charles F. Adams', destroyedString='sunk'},--DDG 2 Charles F. Adams
    }


	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('USA_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
    else
        ChangeScore('United States',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
        ChangeScore('Soviet Union',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')
        if theDestroyedUnit.type == 'Aircraft' and ScenEdit_PlayerSide() == 'United States' then
            GenerateSurvivors(theDestroyedUnit.latitude,theDestroyedUnit.longitude,theDestroyedUnit.name)
        end
    end

    local function FirstUSAUnitHasBeenDestroyed(boolValue)
        if boolValue == nil then
            return ConvertStringToBoolean(ScenEdit_GetKeyValue('unitDestroyedUSA'))
        elseif boolValue == true then
            ScenEdit_SetKeyValue('unitDestroyedUSA','true')
            return true
        elseif boolValue == false then
            ScenEdit_SetKeyValue('unitDestroyedUSA','false')
            return false
        else
            return nil
        end
    end

    if not FirstUSAUnitHasBeenDestroyed() then
        if ScenEdit_PlayerSide() == 'United States' then
            local unitDescription = theDestroyedUnit.classname..' '..theDestroyedUnit.type
            if theDestroyedUnit.type == 'Ship' or theDestroyedUnit.type == 'Submarine' then
                unitDescription = theDestroyedUnit.name
            end
            TelexMessageToPlayerNATO(
                'cvbg-61', 
                'compacflt', 
                'z', 
                'commander pacific fleet', 
                'cvbg 61',
                'secret', 
                '1. acknowledge your report of loss of '..unitDescription..' <BR>'..
                '2. soviet provocations and aggression have reached a level that can no longer be tolerated <BR>'..
                '3. you are directed to mount a retaliatory strike on soviet naval vessels off the coast of petropavlovsk <BR>'..
                '4. aim to sink at least one soviet surface unit <BR>'..
                '5. minimise own losses' , 
                nil --location
            )
            TelexMessageToPlayerNATO(
                'cvbg-61', 
                'compacaf', 
                'z', 
                'commander pacific air forces', 
                'cvbg 61',
                'secret', 
                '1. anticipate imminent escalation in hostilities with ussr <BR>'..
                '2. detachment of f-15cs from 43rd tfs at eareckson ab are available for your opcon <BR>'..
                '3. request opcon via special action', 
                {latitude='52.7173868791964', longitude='174.120568818604'} --location
            )
        
        ScenEdit_SetSpecialAction({ActionNameOrID='Request OPCON of 43rd TFS Det at Eareckson AB',isactive=true})

        end
        CommenceHostilities()
        FirstUSAUnitHasBeenDestroyed(true)
    end
end