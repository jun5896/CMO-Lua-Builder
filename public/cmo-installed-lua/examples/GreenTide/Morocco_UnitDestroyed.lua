local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
		{type='Aircraft', dbid=1210, points=50, name='Mirage F.1EH', destroyedString='shot down'},--Mirage F.1EH
		{type='Aircraft', dbid=1837, points=150, name='Falcon 20F-ECM', destroyedString='shot down'},--Falcon 20F-ECM
		{type='Aircraft', dbid=2950, points=150, name='KC-130H Hercules', destroyedString='shot down'},--KC-130H Hercules
		{type='Aircraft', dbid=3150, points=50, name='AS.565MA Panther', destroyedString='shot down'},--AS.565MA Panther
		{type='Aircraft', dbid=3152, points=50, name='F-16CJ Blk 52+ Falcon', destroyedString='shot down'},--F-16CJ Blk 52+ Falcon
		{type='Aircraft', dbid=3153, points=50, name='Mirage F.1EM IV', destroyedString='shot down'},--Mirage F.1EM IV
		{type='Aircraft', dbid=3517, points=50, name='F-16DJ Blk 52+ Falcon', destroyedString='shot down'},--F-16DJ Blk 52+ Falcon

		{type='Facility', dbid=1036, points=-500, name='Radar (AN/TPS-63)', destroyedString='destroyed, breaching RoE'},--Radar (AN/TPS-63)
		{type='Facility', dbid=1592, points=-500, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed, breaching RoE'},--Single-Unit Airfield (1x 3201-4000m Runway)
		{type='Facility', dbid=1714, points=-500, name='Single-Unit Airfield (2x 2601-3200m Runways)', destroyedString='destroyed, breaching RoE'},--Single-Unit Airfield (2x 2601-3200m Runways)
		{type='Facility', dbid=1995, points=-500, name='Single-Unit Airfield (1x 4000m+ Runway)', destroyedString='destroyed, breaching RoE'},--Single-Unit Airfield (1x 4000m+ Runway)
		{type='Facility', dbid=586, points=-500, name='Radar (AN/TPS-43)', destroyedString='destroyed, breaching RoE'},--Radar (AN/TPS-43)
		{type='Facility', dbid=734, points=-500, name='SAM Bty (I-HAWK [P1])', destroyedString='destroyed, breaching RoE'},--SAM Bty (I-HAWK [P1])
		{type='Facility', dbid=806, points=-500, name='SAM Bty (I-HAWK [P1])', destroyedString='destroyed, breaching RoE'},--SAM Bty (I-HAWK [P1])
		{type='Facility', dbid=864, points=-500, name='Radar (KEVA 2010 [GM 403 Ground Master])', destroyedString='destroyed, breaching RoE'},--Radar (KEVA 2010 [GM 403 Ground Master])
		{type='Facility', dbid=892, points=-500, name='Radar (Generic Air Traffic Control)', destroyedString='destroyed, breaching RoE'},--Radar (Generic Air Traffic Control)

		{type='Ship', dbid=2363, points=250, name='F 611 Mohammed V [Floreal]', destroyedString='sunk'},--F 611 Mohammed V [Floreal]
		{type='Ship', dbid=2365, points=250, name='F 614 Sultan Moulay Ismail [Sigma 9813, FMMM]', destroyedString='sunk'},--F 614 Sultan Moulay Ismail [Sigma 9813, FMMM]
		{type='Ship', dbid=2366, points=250, name='F 613 Tarik Ben Ziyad [Sigma 10513, FMMM]', destroyedString='sunk'},--F 613 Tarik Ben Ziyad [Sigma 10513, FMMM]
		{type='Ship', dbid=2368, points=250, name='F 701 Mohammed VI [FREMM]', destroyedString='sunk'},--F 701 Mohammed VI [FREMM]
		{type='Ship', dbid=2560, points=150, name='P 318 Rais Bargach [OPV-64 Class]', destroyedString='sunk'},--P 318 Rais Bargach [OPV-64 Class]
		{type='Ship', dbid=2561, points=150, name='P 341 Bir Anzaran [OPV-70 Class]', destroyedString='sunk'},--P 341 Bir Anzaran [OPV-70 Class]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('Spain_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
		ChangeScore('Spain',matchData.points,'A Moroccan '..string.lower(theDestroyedUnit.type).. ' was '..matchData.destroyedString)
    end
end