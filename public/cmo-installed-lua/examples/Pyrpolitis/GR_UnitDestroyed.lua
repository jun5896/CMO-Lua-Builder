local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1055, points=0, name='F-16CJ Blk 50 Falcon [Peace Xenia II]', destroyedString='destroyed'},--F-16CJ Blk 50 Falcon [Peace Xenia II]
        {type='Aircraft', dbid=1116, points=0, name='Mirage 2000-5EG Mk2', destroyedString='destroyed'},--Mirage 2000-5EG Mk2
        {type='Aircraft', dbid=2067, points=0, name='A-7H Corsair II', destroyedString='destroyed'},--A-7H Corsair II
        {type='Aircraft', dbid=2122, points=0, name='F-4E Phantom II', destroyedString='destroyed'},--F-4E Phantom II
        {type='Aircraft', dbid=2795, points=0, name='F-16CJ Blk 52+ Falcon [Peace Xenia III]', destroyedString='destroyed'},--F-16CJ Blk 52+ Falcon [Peace Xenia III]
        {type='Aircraft', dbid=657, points=0, name='Mirage 2000EG-S3', destroyedString='destroyed'},--Mirage 2000EG-S3
        {type='Aircraft', dbid=919, points=200, name='EMB-145H AEWC', destroyedString='destroyed'},--EMB-145H AEWC
        {type='Facility', dbid=1592, points=0, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 3201-4000m Runway)
        {type='Facility', dbid=1714, points=0, name='Single-Unit Airfield (2x 2601-3200m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2601-3200m Runways)
        {type='Facility', dbid=369, points=0, name='Radar (S-743D Martello)', destroyedString='destroyed'},--Radar (S-743D Martello)
        {type='Facility', dbid=430, points=0, name='Single-Unit Airfield (2x 3201-4000m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 3201-4000m Runways)
        {type='Facility', dbid=431, points=0, name='Radar (AN/TPS-43F)', destroyedString='destroyed'},--Radar (AN/TPS-43F)
        {type='Facility', dbid=434, points=0, name='Radar (MPDR-90)', destroyedString='destroyed'},--Radar (MPDR-90)
        {type='Facility', dbid=615, points=0, name='Building (Communication Hub)', destroyedString='destroyed'},--Building (Communication Hub)
        {type='Facility', dbid=918, points=0, name='Radar (HR-3000 RSRP)', destroyedString='destroyed'},--Radar (HR-3000 RSRP)
        {type='Facility', dbid=957, points=0, name='Radar (THD-1955 MPR)', destroyedString='destroyed'},--Radar (THD-1955 MPR)
        {type='Facility', dbid=983, points=0, name='Radar (RAT-31DL)', destroyedString='destroyed'},--Radar (RAT-31DL)
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('GR_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('Russia',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
    end
end