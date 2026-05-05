local destroyedUnit = ScenEdit_UnitX()

if destroyedUnit.type ~= 'Weapon' then	
	math.randomseed(os.time())

	local unitValueTable = {
		{type="Aircraft", dbid=1170, points=1500, isUAV=false, numberOfCrew=1}, -- F-15A Eagle [Baz]
		{type="Aircraft", dbid=1614, points=2500, isUAV=false, numberOfCrew=0}, -- C-130E Hercules		
		{type="Aircraft", dbid=1698, points=750, isUAV=false, numberOfCrew=0}, -- S-70A-9 Blackhawk [AH-60L Battle Hawk]
		{type="Aircraft", dbid=1723, points=2500, isUAV=false, numberOfCrew=0}, -- C-130J Hercules
		{type="Aircraft", dbid=1783, points=750, isUAV=false, numberOfCrew=0}, -- AH-64A Apache [Peten]
		{type="Aircraft", dbid=1910, points=2500, isUAV=false, numberOfCrew=0}, -- C-130H Hercules [Qarnaf]
		{type="Aircraft", dbid=1915, points=2500, isUAV=false, numberOfCrew=0}, -- KC-130H Hercules [Qarnaf]
		{type="Aircraft", dbid=2405, points=750, isUAV=false, numberOfCrew=0}, -- AS.565SA Panther [Atalef]
		{type="Aircraft", dbid=2558, points=500, isUAV=false, numberOfCrew=0}, -- Super King Air B200
		{type="Aircraft", dbid=2700, points=3000, isUAV=false, numberOfCrew=0}, -- Boeing 707-320 Tanker [KC-707 Saknayee]
		{type="Aircraft", dbid=2955, points=3000, isUAV=false, numberOfCrew=0}, -- Gulfstream G550 AEW [Nahshon-Shavit, SEMA]
		{type="Aircraft", dbid=3498, points=2750, isUAV=false, numberOfCrew=1}, -- F-35A Lightning II
		{type="Aircraft", dbid=3560, points=1500, isUAV=false, numberOfCrew=2}, -- F-15B Eagle [Baz]
		{type="Aircraft", dbid=3656, points=1500, isUAV=false, numberOfCrew=2}, -- F-15D Eagle [Akef-2000]
		{type="Aircraft", dbid=3657, points=1500, isUAV=false, numberOfCrew=1}, -- F-15C Eagle [Akef-2000]
		{type="Aircraft", dbid=3955, points=1000, isUAV=false, numberOfCrew=2}, -- M.346 Master
		{type="Aircraft", dbid=4321, points=1500, isUAV=false, numberOfCrew=1}, -- F-16C Blk 30 Falcon [Barak]
		{type="Aircraft", dbid=4322, points=1500, isUAV=false, numberOfCrew=2}, -- F-16D Blk 30 Falcon [Barak]
		{type="Aircraft", dbid=4323, points=1500, isUAV=false, numberOfCrew=1}, -- F-16CG Blk 40 Falcon [Barak]
		{type="Aircraft", dbid=4732, points=2750, isUAV=false, numberOfCrew=0}, -- CH-53C Sea Stallion [Yasur 2025]
		{type="Aircraft", dbid=4776, points=1500, isUAV=false, numberOfCrew=2}, -- F-15I Eagle [Raam]
		{type="Aircraft", dbid=4779, points=1500, isUAV=false, numberOfCrew=2}, -- F-16I Falcon [Sufa]
		{type="Aircraft", dbid=4783, points=1500, isUAV=false, numberOfCrew=2}, -- F-16DG Blk 40 Falcon [Barak]
		{type="Aircraft", dbid=566, points=750, isUAV=false, numberOfCrew=0}, -- AH-64D Apache Longbow [Saraph]
		{type="Aircraft", dbid=676, points=3000, isUAV=false, numberOfCrew=0}, -- Gulfstream G550 AEW [Nahshon-Eitam, CAEW]		
	}

	local function UnitIsOwnedByPlayer()
		local result = false
		local unit = destroyedUnit
		if ReturnPlayerSide() == unit.side then result = true end
		return result
	end

	local function DestroyedUnitIsShipOrShallowSub()
		local unit = destroyedUnit
		local result = false
		if unit.type == 'Ship' or (unit.type == 'Submarine' and unit.altitude > -150) then
			result = true
		end
		return result
	end

	local function DestroyedUnitIsAirborneAircraft()
		local unit = destroyedUnit
		local result = false
		if unit.type == 'Aircraft' and unit.condition_v == 'Airborne' then 
			result = true
		end
		return result
	end

	local function GenerateUnitDestructionSuffix()
		local result = ' was destroyed.'
		local unit = destroyedUnit
		if unit.type == 'Ship' or unit.type == 'Submarine' then
			result = ' was sunk.'
		end
		return result
	end

	local function GenerateScoreEventDescription()
		local result
		local unit = destroyedUnit
		local suffix = GenerateUnitDestructionSuffix()
		if UnitIsOwnedByPlayer(unitGUID) then
			result = unit.name..suffix
		else
			result = 'An enemy '..unit.type..suffix
		end
		return result
	end

	local function MatchGUIDToScoringList()
		local unit = destroyedUnit
		local result = {}
		for k,v in ipairs (unitValueTable) do
			if unit.dbid == v.dbid then 
				result = v 
			end
		end
		return result
	end

	local function CalculateNumberOfSurvivors()
		local unit, scoreData  = destroyedUnit, MatchGUIDToScoringList()
		local survivorNumber = Round(scoreData.numberOfCrew*(math.random(7,10)/10)) ---modify this as you like
		if survivorNumber < 1 then survivorNumber = 1 end
		return survivorNumber
	end

	local function PlaceSurvivors(numberOfSurvivors)
		local unit, resultTable, unitCtr, survivorsPerLifeRaft = destroyedUnit, {}, 0, 20
		while numberOfSurvivors > 0 do
			local randomPosition = CircularRandomPosition(unit.latitude, unit.longitude, 2)
			if OverWater(randomPosition.latitude, randomPosition.longitude) then
				unitCtr = unitCtr + 1
				local survivor = ScenEdit_AddUnit({side=unit.side..' Downed Aircrew',
					type='Ship',
					dbid=2553,
					name=unit.name..' Liferaft #'..unitCtr,
					latitude=randomPosition.latitude,
					longitude=randomPosition.longitude,
					autodetectable=true})
				table.insert(resultTable, survivor)
				numberOfSurvivors = numberOfSurvivors - survivorsPerLifeRaft
			else
				unitCtr = unitCtr + 1
				local survivor = ScenEdit_AddUnit({side=unit.side..' Downed Aircrew',
					type='Facility',
					dbid=2441,
					name=unit.name..' Survivor #'..unitCtr,
					latitude=randomPosition.latitude,
					longitude=randomPosition.longitude,
					autodetectable=true})
				table.insert(resultTable, survivor)
				numberOfSurvivors = numberOfSurvivors - 1
			end
		end
		return resultTable
	end

	local function GenerateSARMessage()
		local unit, messageString = destroyedUnit, ''
		local theMessage = 'Commander, we have just received report that one of our fighters was shot down! Luckily it looks like the crew ejected and emergency beacon was picked up on the SAR frequency. CSAR team from Unit 669 is standing by to extract, but we need to make sure the area is clear of SAM threats first!'
		ScenEdit_SpecialMessage('playerside',theMessage)
	end

	local function SetTimeOfDeathForMultipleSurvivors(survivorList)
		local result = {}
		for k,v in ipairs (survivorList) do
			local timeOfDeath = SetTimeOfDeath(v.guid)
			result[k] = {guid = v.guid, timeOfDeath=timeOfDeath}
			end
		return result
	end

	local function DoSurvivorRoutine()
		local unit, survivorChance, chanceRoll = destroyedUnit, 0, 0
		if DestroyedUnitIsAirborneAircraft(unit.guid) then
			survivorChance = 90 --modify this as you like; currently 101 to guarantee a survivor is generated for testing
		elseif DestroyedUnitIsShipOrShallowSub(unit.guid) then
			survivorChance = 75 --modify this as you like; currently 101 to guarantee a survivor is generated for testing
		end
		if survivorChance ~= 0 then
			chanceRoll = math.random(1,100)
			if chanceRoll < survivorChance then
				local numberOfSurvivors = CalculateNumberOfSurvivors()
				local survivorList = PlaceSurvivors(numberOfSurvivors)
				SetTimeOfDeathForMultipleSurvivors(survivorList)
				SearchAndRescueIsInEffect(true)
				if unit.side == ReturnPlayerSide() then
					GenerateSARMessage()
					local DTG = DTG()
					ScenEdit_AddReferencePoint({side=unit.side,name=unit.name..' Rescue Beacon '..DTG, latitude=unit.latitude,longitude=unit.longitude, highlighted=true})
				end
			end
		end
	end

	local function UnitDestroyed()
		local unit = destroyedUnit
		local scoreData = MatchGUIDToScoringList(unit.guid)
		print (scoreData)
		local scoreDescription = GenerateScoreEventDescription(unit.guid)
		local penalty = ChangeScore(unit.side,scoreData.points*-1,scoreDescription)
		local survivors = DoSurvivorRoutine()
	end

	UnitDestroyed()
end