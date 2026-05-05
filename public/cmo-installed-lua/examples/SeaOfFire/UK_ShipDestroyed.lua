local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Ship', dbid=1780, points=1000, name='D 80 Sheffield [Type 42 Batch 1]', destroyedString=nil},--D 80 Sheffield [Type 42 Batch 1]
		{type='Ship', dbid=1782, points=1000, name='F 88 Broadsword [Type 22 Batch 1]', destroyedString=nil},--F 88 Broadsword [Type 22 Batch 1]
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('UK_ShipDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('Argentina',matchData.points,theDestroyedUnit.name..' was sunk.')
	end

	local numberOfShips = 0
	local unitList = VP_GetSide({side='United Kingdom'}).units
	for k,v in ipairs(unitList) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.type == 'Ship' then
			numberOfShips = numberOfShips + 1
		end
	end

	if numberOfShips == 0 then
		ChangeScore('Argentina',2000,'Both HMS Coventry and HMS Broadsword were sunk.')
		ScenEdit_EndScenario()
	end
end