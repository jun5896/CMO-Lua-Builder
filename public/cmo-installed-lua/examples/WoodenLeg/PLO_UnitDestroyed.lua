local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Facility', dbid=115, points=125, name='Building (Large)', destroyedString=nil},--Building (Large)
		{type='Facility', dbid=452, points=125, name='Building (Medium)', destroyedString=nil},--Building (Medium)
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('PLO_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theUnit.name..', dbid '..theUnit.dbid)
		end
	else
		ChangeScore('Israel',matchData.points,'A target building was destroyed.')
		ScenEdit_SetEvent('Game_ScenarioEnd',{isactive=true})
	end
end