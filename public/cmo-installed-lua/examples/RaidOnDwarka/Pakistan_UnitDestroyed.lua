local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
        {type='Aircraft', dbid=1036, points=0, name='RB-57B Canberra', destroyedString='destroyed.'},--RB-57B Canberra

        {type='Ship', dbid=1281, points=700, name='C 84 Babur', destroyedString='sunk.'},--C 84 Babur
        {type='Ship', dbid=1399, points=300, name='D 260 Tippu Sultan', destroyedString='sunk.'},--D 260 Tippu Sultan
        {type='Ship', dbid=1401, points=400, name='D 163 Khaibar', destroyedString='sunk.'},--D 163 Khaibar
        {type='Ship', dbid=971, points=400, name='D 164 Shah Jahan', destroyedString='sunk.'},--D 164 Shah Jahan
        {type='Ship', dbid=987, points=400, name='D 160 Alamgir', destroyedString='sunk.'},--D 160 Alamgir
        {type='Ship', dbid=988, points=400, name='D 162 Jahangir', destroyedString='sunk.'},--D 162 Jahangir
        {type='Ship', dbid=990, points=400, name='D 161 Badr', destroyedString='sunk.'},--D 161 Badr

        {type='Submarine', dbid=369, points=0, name='S 130 Ghazi (GUPPY IIA)', destroyedString='sunk.'},--S 130 Ghazi (GUPPY IIA)
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Pakistan_ShipDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('Pakistan',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString)
	end

	local numberOfShips = 0
	local unitList = VP_GetSide({side='Pakistan'}).units
	for k,v in ipairs(unitList) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.type == 'Ship' then
			numberOfShips = numberOfShips + 1
		end
	end

	if numberOfShips == 0 then
		ChangeScore('Pakistan',-1000,'All friendly ships were sunk.')
		ScenEdit_EndScenario()
	end
end