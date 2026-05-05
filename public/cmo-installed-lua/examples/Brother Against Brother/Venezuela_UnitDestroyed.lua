local theUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{name='Su-30MK2 Flanker G', dbid=565, type='Aircraft', points=25, descriptor='shot down'},
		{name='F-16A Falcon', dbid=2215, type='Aircraft', points=25, descriptor='shot down'},
		{name='Auxillary Replenishment Tanker', dbid=1927, type='Ship', points=150, descriptor='sunk'},
		{name='Guided Missile Frigate', dbid=317, type='Ship', points=125, descriptor='sunk'},
		{name='Diesel Submarine', dbid=362, type='Submarine', points=100, descriptor='sunk'},
		{name='Early Warning Radar', dbid=610, type='Facility', points=10, descriptor='destroyed'},
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theUnit.dbid then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Venezuela_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theUnit.name..', dbid '..theUnit.dbid)
		end
	else
		ChangeScore('Colombia',matchData.points,'A Venezuelan '..matchData.name.. ' was '..matchData.descriptor)
	end
end