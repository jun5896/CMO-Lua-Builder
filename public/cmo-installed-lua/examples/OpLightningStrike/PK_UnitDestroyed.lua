local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Aircraft', dbid=2161, points=-25, name='Mirage IIIO(F/A) [ROSE I]', destroyedString='destroyed'},--Mirage IIIO(F/A) [ROSE I]
		{type='Aircraft', dbid=2913, points=-100, name='Saab 2000 AEW&C [Erieye]', destroyedString='destroyed'},--Saab 2000 AEW&C [Erieye]
		{type='Aircraft', dbid=2914, points=-100, name='Y-8F-400 Cub [ZDK-03 Karakoram Eagle]', destroyedString='destroyed'},--Y-8F-400 Cub [ZDK-03 Karakoram Eagle]
		{type='Aircraft', dbid=2915, points=-25, name='F-16CJ Blk 52+ Falcon [Peace Drive]', destroyedString='destroyed'},--F-16CJ Blk 52+ Falcon [Peace Drive]
		{type='Aircraft', dbid=2916, points=-25, name='F-16AM Falcon MLU', destroyedString='destroyed'},--F-16AM Falcon MLU
		{type='Aircraft', dbid=363, points=-25, name='F-7P Airguard', destroyedString='destroyed'},--F-7P Airguard
		{type='Aircraft', dbid=364, points=-25, name='F-7MP Skybolt [F-7PG]', destroyedString='destroyed'},--F-7MP Skybolt [F-7PG]
		{type='Aircraft', dbid=365, points=-25, name='JF-17 Thunder Blk 1', destroyedString='destroyed'},--JF-17 Thunder Blk 1


		{type='Facility', dbid=100, points=-100, name='Bunker (Medium C3M)', destroyedString='destroyed'},--Bunker (Medium C3M)
		{type='Facility', dbid=1088, points=-50, name='AAA Sec (35mm Twin Oerlikon x 2, Skyguard FCR)', destroyedString='destroyed'},--AAA Sec (35mm Twin Oerlikon x 2, Skyguard FCR)
		{type='Facility', dbid=1349, points=-50, name='Radar (AN/TPS-77)', destroyedString='destroyed'},--Radar (AN/TPS-77)
		{type='Facility', dbid=1455, points=-75, name='Radar (China YLC-2V)', destroyedString='destroyed'},--Radar (China YLC-2V)
		{type='Facility', dbid=1456, points=-100, name='Radar (MPDR-45)', destroyedString='destroyed'},--Radar (MPDR-45)
		{type='Facility', dbid=1592, points=-50, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 3201-4000m Runway)
		{type='Facility', dbid=1594, points=-50, name='Single-Unit Airfield (1x 901-1400m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 901-1400m Runway)
		{type='Facility', dbid=1605, points=-50, name='Radar (AN/FPS-89 HF)', destroyedString='destroyed'},--Radar (AN/FPS-89 HF)
		{type='Facility', dbid=1712, points=-50, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2001-2600m Runway)
		{type='Facility', dbid=1713, points=-50, name='Single-Unit Airfield (2x 2001-2600m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2001-2600m Runways)
		{type='Facility', dbid=1714, points=-50, name='Single-Unit Airfield (2x 2601-3200m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2601-3200m Runways)
		{type='Facility', dbid=1866, points=-50, name='Radar (RAC-3D)', destroyedString='destroyed'},--Radar (RAC-3D)
		{type='Facility', dbid=1868, points=-50, name='SAM Plt (Spada 2000 [Aspide])', destroyedString='destroyed'},--SAM Plt (Spada 2000 [Aspide])
		{type='Facility', dbid=362, points=-50, name='Radar (AN/FPS-100)', destroyedString='destroyed'},--Radar (AN/FPS-100)
		{type='Facility', dbid=430, points=-50, name='Single-Unit Airfield (2x 3201-4000m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 3201-4000m Runways)
		{type='Facility', dbid=5, points=-200, name='Bunker (Large C3M)', destroyedString='destroyed'},--Bunker (Large C3M)
		{type='Facility', dbid=586, points=-50, name='Radar (AN/TPS-43)', destroyedString='destroyed'},--Radar (AN/TPS-43)
		{type='Facility', dbid=762, points=-50, name='SAM Bn (HQ-2b [SA-2 Copy])', destroyedString='destroyed'},--SAM Bn (HQ-2b [SA-2 Copy])
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
		end
	end

	if matchData.dbid == nil then
		BugMessage('PK_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('United States',matchData.points,'A Pakistani '..string.lower(theDestroyedUnit.type).. ' was '..matchData.destroyedString)
	end

	if matchData.type == 'Facility' and (matchData.dbid == 100 or matchData.dbid == 5) then
		DisruptPKAirDefenceZone(theDestroyedUnit.type, theDestroyedUnit.guid)
	end
end