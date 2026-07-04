local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Ship', dbid=550, points=50, name='frigate', destroyedString='sunk'},--SKR Riga Mod [Pr.50 Gornostay]
		{type='Ship', dbid=1261, points=100, name='destroyer', destroyedString='sunk'},--BPK Kanin [Pr.57A Gnevny]
		{type='Ship', dbid=696, points=150, name='cruiser', destroyedString='sunk'},--BPK Kresta II [Pr.1134A Berkut A]

		{type='Submarine', dbid=73, points=50, name='nuclear attack submarine', destroyedString='sunk'},--PLA-627A November [Kit]
		{type='Submarine', dbid=65, points=300, name='ballistic missile submarine', destroyedString='sunk'},--PLRB-629A Golf II
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
        local submarineIsInZone = ConvertStringToBoolean(ScenEdit_GetKeyValue('SSBInZone'))
		
		if matchData.dbid == 65 then
            local submarineDistanceFromPort = Tool_Range({latitude='22.0374963776184', longitude='-80.4583776125159'},{latitude=theDestroyedUnit.latitude,longitude=theDestroyedUnit.longitude})
			if submarineIsInZone then
				ChangeScore('United States',300,'A Soviet ballistic missile submarine was sunk after entering Cuban territorial waters.')
			elseif submarineDistanceFromPort <= 25 then
				ChangeScore('United States',100,'A Soviet ballistic missile submarine was sunk close to a Cuban port.')
			else
				ChangeScore('United States',-500,'A Soviet ballistic missile submarine was sunk in international waters.')
			end
		else
			if submarineIsInZone then
				ChangeScore('United States',matchData.points,'A Soviet '..matchData.name..' was '..matchData.destroyedString..' after a Soviet ballistic missile submarine entered Cuban territorial waters.')
			else
				ChangeScore('United States',matchData.points*-2,'A Soviet '..matchData.name..' was '..matchData.destroyedString..' without justification.')
			end
		end
	end
end
