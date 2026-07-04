local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
        {type='Aircraft', dbid=574, points=250, name='Canadian ASW helicopter', destroyedString='shot down'},--CH-124A Heltas [Sea King]
        {type='Aircraft', dbid=585, points=250, name='Canadian maritime patrol aircraft', destroyedString='shot down'},--CP-140 Aurora [P-3C Orion]

        {type='Facility', dbid=1904, points=100, name='Canadian infantry platoon', destroyedString='destroyed'},--Inf Plt (Recon)
        {type='Facility', dbid=427, points=100, name='Canadian airport building', destroyedString='destroyed'},--Building (Airport Terminal)
        {type='Facility', dbid=52, points=2000, name='Canadian logistic depot', destroyedString='destroyed'},--A/C Hardened Aircraft Shelter (4x Large Aircraft)
        {type='Facility', dbid=9, points=100, name='Canadian airport building', destroyedString='destroyed'},--A/C Hangar (4x Large Aircraft)

        {type='Ship', dbid=1417, points=1000, name='American logistics vessel', destroyedString='sunk'},--AE 21 Suribachi
        {type='Ship', dbid=1464, points=500, name='Canadian destroyer', destroyedString='sunk'},--DDE 257 Restigouche
        {type='Ship', dbid=1607, points=100, name='British minesweeper', destroyedString='sunk'},--M 1101 Conniston [Ton Class]
        {type='Ship', dbid=872, points=250, name='Canadian destroyer', destroyedString='sunk'},--DDH 205 St. Laurent
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('NATO_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('Soviet Union',matchData.points,'A '..matchData.name.. ' was '..matchData.destroyedString..'.')
	end
end

