local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
        {type='Aircraft', dbid=3563, points=100, name='aircraft', destroyedString='shot down'},--F-5E Tiger II [DACT]
        {type='Facility', dbid=1070, points=25, name='AAA battery', destroyedString='destroyed'},--AAA Bty (37mm T65 Twin x 4)
        {type='Facility', dbid=1071, points=25, name='AAA battery', destroyedString='destroyed'},--AAA Bty (57mm M1950 x 4 + Fire Can FC)
        {type='Facility', dbid=256, points=0, name='aircraft revetment', destroyedString=nil},--A/C Revetment (1x Large Aircraft)
        {type='Facility', dbid=311, points=100, name='SAM battalion', destroyedString='destroyed'},--SAM Bn (SA-3b Goa [S-125M Neva-M])
        {type='Facility', dbid=975, points=50, name='SAM platoon', destroyedString='destroyed'},--SAM Plt (SA-9b Gaskin [9K31 Strela-1])
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('OPFOR_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('Students',matchData.points,'An OPFOR '..matchData.name.. ' was '..matchData.destroyedString..'.')
	end
end

