local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1853, points=200, name='KC-135R Stratotanker', destroyedString='destroyed'},--KC-135R Stratotanker
        {type='Aircraft', dbid=2360, points=0, name='F-16CJ Blk 50 Falcon [Peace Onyx IV]', destroyedString='destroyed'},--F-16CJ Blk 50 Falcon [Peace Onyx IV]
        {type='Aircraft', dbid=3218, points=200, name='E-737 Wedgetail', destroyedString='destroyed'},--E-737 Wedgetail
        {type='Aircraft', dbid=832, points=0, name='F-16CM Blk 40 Falcon [Peace Onyx III CCIP Upgr]', destroyedString='destroyed'},--F-16CM Blk 40 Falcon [Peace Onyx III CCIP Upgr]

        {type='Facility', dbid=1068, points=0, name='Radar (TRS 22XX)', destroyedString='destroyed'},--Radar (TRS 22XX)
        {type='Facility', dbid=1714, points=0, name='Single-Unit Airfield (2x 2601-3200m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2601-3200m Runways)
        {type='Facility', dbid=430, points=0, name='Single-Unit Airfield (2x 3201-4000m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 3201-4000m Runways)
        {type='Facility', dbid=572, points=0, name='Radar (AN/FPS-88)', destroyedString='destroyed'},--Radar (AN/FPS-88)
        {type='Facility', dbid=917, points=0, name='Radar (HR-3000 RSRP)', destroyedString='destroyed'},--Radar (HR-3000 RSRP)
        {type='Facility', dbid=986, points=0, name='Radar (RAT-31DL)', destroyedString='destroyed'},--Radar (RAT-31DL)

        {type='Ship', dbid=1135, points=500, name='F 490 Gaziantep [Perry, Gabya Class]', destroyedString='sunk'},--F 490 Gaziantep [Perry, Gabya Class]
        {type='Ship', dbid=531, points=500, name='F 246 Salihreis [Meko 200TN Track IIB]', destroyedString='sunk'},--F 246 Salihreis [Meko 200TN Track IIB]
        {type='Ship', dbid=909, points=500, name='F 240 Yavuz [Meko 200TN Track I]', destroyedString='sunk'},--F 240 Yavuz [Meko 200TN Track I]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('TU_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('Greece',matchData.points,'An enemy '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
    end
end