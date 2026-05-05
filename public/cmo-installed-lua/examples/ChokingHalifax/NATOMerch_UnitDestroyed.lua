

local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
        {type='Ship', dbid=1055, points=500, name='car freighter', destroyedString='sunk'},--Commercial Atlantic Conveyor [RO/RO]
        {type='Ship', dbid=144, points=1000, name='tanker', destroyedString='sunk'},--Commercial Tanker - General Purpose [20,000t DWT]
        {type='Ship', dbid=1599, points=500, name='car freighter', destroyedString='sunk'},--Commercial RO/RO Vessel [11,500t DWT]
        {type='Ship', dbid=775, points=750, name='container vessel', destroyedString='sunk'},--Commercial Container Vessel - Feeder [1,600 TEU, 20,000t DWT]
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('NATOMerch_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('Soviet Union',matchData.points,'A NATO merchant '..matchData.name.. ' was '..matchData.destroyedString..'.')
	end
end
