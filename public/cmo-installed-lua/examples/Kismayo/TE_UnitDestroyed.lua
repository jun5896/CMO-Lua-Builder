local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Aircraft', dbid=3945, points=-5000, name='Cessna 208B Grand Caravan', destroyedString='destroyed in direct contravention of your orders. Enjoy your court martial!'},--Cessna 208B Grand Caravan
		{type='Facility', dbid=1981, points=100, name='Armed Technical [12.7mm]', destroyedString='destroyed'},--Vehicle (Truck, Armed Technical [12.7mm] x 1)
		{type='Facility', dbid=2658, points=100, name='AAA Bty (14.5mm/79 ZPU-4 Quad x 4)', destroyedString='destroyed'},--AAA Bty (14.5mm/79 ZPU-4 Quad x 4)
		{type='Facility', dbid=2738, points=100, name='Armed Technical [ZU-23-2]', destroyedString='destroyed'},--Vehicle (Truck, Armed Technical [ZU-23-2] x 1)
		{type='Facility', dbid=452, points=-5000, name='Safe House', destroyedString='destroyed in direct contravention of your orders. Enjoy your court martial!'},--Building (Medium)
		{type='Facility', dbid=622, points=-5000, name='Vehicle Convoy', destroyedString='destroyed in direct contravention of your orders. Enjoy your court martial!'},--Vehicle (Car x 4)
		{type='Facility', dbid=625, points=100, name='Terrorist Infantry Cell', destroyedString='destroyed'},--Inf Plt (Terrorists)
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('TE_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theUnit.name..', dbid '..theUnit.dbid)
		end
	else
		ChangeScore('United States',matchData.points,'An al-Jabaab '..matchData.name..' was '..matchData.destroyedString)

		local function PlayerDidSomethingSilly()
			if theDestroyedUnit.dbid == 3945 or
				theDestroyedUnit.dbid == 452 or
					theDestroyedUnit.dbid == 622 then
						return true
			else
				return false
			end
		end

		if PlayerDidSomethingSilly() then
			TelexMessageToPlayer(
				'NKEA', 
				'CENTCOM', 
				'i', 
				'US CENTral COMmand', 
				'lhd 3 kearsarge', 
				'top secret', 
				'1. centcom acknowledges your report of destroying an al-jabaab '..matchData.name..'. <br>2. the mission is compromised. abort mission and recall all units. <br>3. you are relieved of command effective immediately.', 
				{latitude=theDestroyedUnit.latitude, longitude=theDestroyedUnit.longitude}
			)
			ScenEdit_EndScenario()
		end
	end
end