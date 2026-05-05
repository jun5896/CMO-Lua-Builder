local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
        {type='Ship', dbid=328, points=50, name='auxilliary minesweeper', destroyedString='sunk'},--Commercial Fishing Boat [35m]
        {type='Ship', dbid=44, points=1000, name='landing ship', destroyedString='sunk'},--L 10 Fearless
        {type='Ship', dbid=45, points=1000, name='landing ship', destroyedString='sunk'},--L 3029 Sir Lancelot [Round Table Class]
        {type='Ship', dbid=620, points=100, name='minehunter', destroyedString='sunk'},--M 29 Brecon [Hunt]
        {type='Ship', dbid=680, points=250, name='frigate', destroyedString='sunk'},--F 88 Broadsword [Type 22 Batch 1]
        {type='Ship', dbid=940, points=250, name='frigate', destroyedString='sunk'},--F 107 Rothesay [Type 12M]
        {type='Ship', dbid=991, points=250, name='frigate', destroyedString='sunk'},--F 169 Amazon [Type 21, Exocet]
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('UK_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('Argentina',matchData.points,'A British '..matchData.name.. ' was '..matchData.destroyedString..'.')
	end
end