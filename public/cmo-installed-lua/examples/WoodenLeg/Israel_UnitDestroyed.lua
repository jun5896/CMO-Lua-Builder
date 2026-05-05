local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Aircraft', dbid=1771, points=500, name='F-15D Eagle [Akef]', destroyedString=nil},--F-15D Eagle [Akef]
		{type='Aircraft', dbid=2700, points=1000, name='Boeing 707-320 Tanker [KC-707 Saknayee]', destroyedString=nil},--Boeing 707-320 Tanker [KC-707 Saknayee]
		{type='Aircraft', dbid=490, points=500, name='SA.366G Dauphin 2 [Dolpheen]', destroyedString=nil},--SA.366G Dauphin 2 [Dolpheen]
		{type='Ship', dbid=117, points=1000, name='340 Aliyah [Saar 4.5, Helo Pad]', destroyedString=nil},--340 Aliyah [Saar 4.5, Helo Pad]
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
		ChangeScore('Israel',matchData.points*-1,theDestroyedUnit.name..' was destroyed.')
	end
end