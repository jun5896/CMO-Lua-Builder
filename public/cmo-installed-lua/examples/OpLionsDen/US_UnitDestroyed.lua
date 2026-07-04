local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1243, points=500, name='A-7E Corsair II', destroyedString='shot down'},--A-7E Corsair II

        {type='Ship', dbid=1615, points=1500, name='CA 148 Newport News', destroyedString='sunk'},--CA 148 Newport News
        {type='Ship', dbid=267, points=1500, name='DD 890 Gearing FRAM 1 (AGM-45 Shrike)', destroyedString='sunk'},--DD 890 Gearing FRAM 1 (AGM-45 Shrike)
        {type='Ship', dbid=72, points=1500, name='CLG 6 Providence', destroyedString='sunk'},--CLG 6 Providence
        {type='Ship', dbid=761, points=1500, name='DDG 2 Charles F. Adams', destroyedString='sunk'},--DDG 2 Charles F. Adams
        {type='Ship', dbid=868, points=1500, name='CV 43 Coral Sea [Midway Class]', destroyedString='sunk'},--CV 43 Coral Sea [Midway Class]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('MACV_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('United States',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
    end
end