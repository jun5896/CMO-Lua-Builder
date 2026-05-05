local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Facility', dbid=1088, points=10, name='AAA section', destroyedString='destroyed'},--AAA Sec (35mm Twin Oerlikon x 2, Skyguard FCR)
		{type='Facility', dbid=1393, points=10, name='AvGas tank', destroyedString='destroyed'},--AvGas (200k Liter Underground Tank)
		{type='Facility', dbid=1422, points=10, name='Runway-Grade Taxiway (3200m)', destroyedString='destroyed'},--Runway-Grade Taxiway (3200m)
		{type='Facility', dbid=1869, points=4000, name='nuclear-capable SSM battalion', destroyedString='destroyed'},--SSM Bn (Hatf 7 [Babur] TEL)
		{type='Facility', dbid=1870, points=4000, name='nuclear-capable SSM battalion', destroyedString='destroyed'},--SSM Bn (Hatf 6 [Shaheen 2] TEL)
		{type='Facility', dbid=1954, points=10, name='MANPADs section', destroyedString='destroyed'},--SAM Sec (QW-1 Vanguard MANPADS)
		{type='Facility', dbid=217, points=10, name='A/C Tarmac Space (2x Large Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (2x Large Aircraft)
		{type='Facility', dbid=27, points=10, name='hardened aircraft shelter', destroyedString='destroyed'},--A/C Hardened Aircraft Shelter (1x Large Aircraft)
		{type='Facility', dbid=3, points=10, name='control tower building', destroyedString='destroyed'},--Building (Control Tower)
		{type='Facility', dbid=322, points=10, name='ammo bunker', destroyedString='destroyed'},--Ammo Bunker (Surface)
		{type='Facility', dbid=35, points=10, name='Runway (3200m)', destroyedString='destroyed'},--Runway (3200m)
		{type='Facility', dbid=353, points=10, name='Runway Access Point (Very Large Aircraft)', destroyedString='destroyed'},--Runway Access Point (Very Large Aircraft)
		{type='Facility', dbid=41, points=10, name='hangar', destroyedString='destroyed'},--A/C Hangar (2x Large Aircraft)
		{type='Facility', dbid=588, points=10, name='SAM platoon', destroyedString='destroyed'},--SAM Plt (Crotale-4000)
		{type='Facility', dbid=630, points=10, name='armored platoon', destroyedString='destroyed'},--Armored Plt (Type 85 MBT x 4)
		{type='Facility', dbid=68, points=10, name='hangar', destroyedString='destroyed'},--A/C Hangar (2x Medium Aircraft)
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
		end
	end

	if matchData.dbid == nil then
		BugMessage('BadPK_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		if theDestroyedUnit.dbid == 322 and theDestroyedUnit.guid == 'a2e2be10-5ea8-4e6a-b317-3e422d0b4950' then
			ChangeScore('United States',4000,'The rogue Pakistani nuclear storage bunker was destroyed.')
		elseif theDestroyedUnit.dbid == 1869 or theDestroyedUnit.dbid == 1870 then
			ChangeScore('United States',matchData.points,'A rogue Pakistani '..matchData.name.. ' was '..matchData.destroyedString)
		else
			ChangeScore('United States',matchData.points,'A rogue Pakistani '..matchData.name.. ' was '..matchData.destroyedString)
		end
	end
end