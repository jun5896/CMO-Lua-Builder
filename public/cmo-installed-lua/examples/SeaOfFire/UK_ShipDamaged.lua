local theDamagedUnit = ScenEdit_UnitX()

if theDamagedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Ship', dbid=1780, points=500, name='D 80 Sheffield [Type 42 Batch 1]', destroyedString=nil},--D 80 Sheffield [Type 42 Batch 1]
		{type='Ship', dbid=1782, points=500, name='F 88 Broadsword [Type 22 Batch 1]', destroyedString=nil},--F 88 Broadsword [Type 22 Batch 1]
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDamagedUnit.dbid and v.type == theDamagedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('UK_ShipDamaged', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDamagedUnit.name..', dbid '..theDamagedUnit.dbid)
		end
	else
		ChangeScore('Argentina',matchData.points,theDamagedUnit.name..' was severely damaged.')
	end
end