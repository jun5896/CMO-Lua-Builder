math.randomseed(os.time())
math.random()
Tool_EmulateNoConsole()

local airports = {
	{name = "Hermes Quijada International Airport", guid = "d748df21-f5c4-42c8-9f76-e561041ab084"},
	{name = "Congonhas Airport", guid = "6b464f48-addd-49c6-be82-9e678f0c4751"},
	{name = "Ministro Pistarini International Airport", guid = "70b75639-a9d9-449c-ba5e-30ff76a39995"},
	{name = "Afonso Pena Airport", guid = "178a3ae3-ac66-41d5-8048-8b2dbcfad4e1"},
	{name = "Cape Town International Airport", guid = "d00c92a4-3590-4b0b-8587-8204abba737b"},
	{name = "Maputo Airport", guid = "b886d5c3-7053-4a6f-867a-2038a134314e"},
	{name = "Resistencia International Airport", guid = "530c5b3d-9a70-4926-84c3-0efc3f461e13"}
}

local aircraft = {
	{dbid = 2421, ferryRange = 3800, loadoutid = 14761}, --Boeing 737-700ER -- Commercial (Commercial), 2008
	{dbid = 2424, ferryRange = 4260, loadoutid = 14762}, --Boeing 767-300 -- Commercial (Commercial), 1988
	{dbid = 2425, ferryRange = 5625, loadoutid = 14765}, --Boeing 767-400ER -- Commercial (Commercial), 2002
	{dbid = 2428, ferryRange = 7250, loadoutid = 9926}, --Airbus A.330-200 -- Commercial (Commercial), 1999
	{dbid = 2429, ferryRange = 5850, loadoutid = 9928}, --Airbus A.330-300 -- Commercial (Commercial), 1995
	{dbid = 2430, ferryRange = 8000, loadoutid = 14744}, --Airbus A.340-200 -- Commercial (Commercial), 1995
	{dbid = 2431, ferryRange = 6700, loadoutid = 9930}, --Airbus A.340-300 -- Commercial (Commercial), 1995
	{dbid = 2525, ferryRange = 7260, loadoutid = 9914}, --Boeing 747-400 -- Commercial (Commercial), 1990, 442x, Passenger
	{dbid = 2526, ferryRange = 6700, loadoutid = 9912}, --Boeing 747-300M -- Commercial (Commercial), 1984, 21x, Combi, Passenger + Container
	{dbid = 2531, ferryRange = 6700, loadoutid = 9912}, --Boeing 747-300 -- Commercial (Commercial), 1984, 56x, Passenger
	{dbid = 2533, ferryRange = 7360, loadoutid = 9919}, --Boeing 747-400F -- Commercial (Commercial), 1994, 126x, Freighter
	{dbid = 2534, ferryRange = 7670, loadoutid = 9917}, --Boeing 747-400ER -- Commercial (Commercial), 2003, 6x, ER Passenger
	{dbid = 2536, ferryRange = 7750, loadoutid = 9918}, --Boeing 747-400ERF -- Commercial (Commercial), 2003, 40x, ER Freighter
	{dbid = 2537, ferryRange = 8000, loadoutid = 9908}, --Boeing 747-8 -- Commercial (Commercial), 2012, Passenger
	{dbid = 2538, ferryRange = 7900, loadoutid = 8288}, --Boeing 747-8F -- Commercial (Commercial), 2012, Freighter
	{dbid = 2898, ferryRange = 5800, loadoutid = 15009}, --Gulfstream G550 -- Commercial (Commercial), 2004
	{dbid = 2956, ferryRange = 4220, loadoutid = 15779}, --Gulfstream G-IV SP -- Commercial (Commercial), 1987
	{dbid = 32, ferryRange = 8650, loadoutid = 9932}, --Airbus A.340-500 -- Commercial (Commercial), 2004
	{dbid = 3704, ferryRange = 3395, loadoutid = 18354}, --Boeing 757-300 -- Commercial (Commercial), 1999
	{dbid = 3974, ferryRange = 8150, loadoutid = 19912}, --Boeing 787-8 Dreamliner -- Commercial (Commercial), 2012
	{dbid = 3975, ferryRange = 8650, loadoutid = 19915}, --Boeing 787-9 Dreamliner -- Commercial (Commercial), 2015
	{dbid = 3976, ferryRange = 7350, loadoutid = 19919}, --Boeing 787-10 Dreamliner -- Commercial (Commercial), 2018
	{dbid = 3977, ferryRange = 5650, loadoutid = 19921}, --Boeing 777-200 -- Commercial (Commercial), 1995
	{dbid = 3978, ferryRange = 8100, loadoutid = 19923}, --Boeing 777-200ER -- Commercial (Commercial), 1997
	{dbid = 3979, ferryRange = 6400, loadoutid = 19929}, --Boeing 777-300 -- Commercial (Commercial), 1998
	{dbid = 3980, ferryRange = 9800, loadoutid = 19927}, --Boeing 777-200LR -- Commercial (Commercial), 1998
	{dbid = 3981, ferryRange = 8200, loadoutid = 19933}, --Boeing 777-300ER -- Commercial (Commercial), 1998
	{dbid = 3982, ferryRange = 4900, loadoutid = 19935}, --Boeing 777 Freighter -- Commercial (Commercial), 2009
	{dbid = 3983, ferryRange = 8650, loadoutid = 19939}, --Airbus A.350-800 -- Commercial (Commercial), 2017
	{dbid = 3984, ferryRange = 8150, loadoutid = 19942}, --Airbus A.350-900 -- Commercial (Commercial), 2015
	{dbid = 3985, ferryRange = 8400, loadoutid = 19944}, --Airbus A.350-1000 -- Commercial (Commercial), 2019
	{dbid = 3986, ferryRange = 8900, loadoutid = 19948}, --Airbus A.380-800 -- Commercial (Commercial), 2008
	{dbid = 4012, ferryRange = 2825, loadoutid = 20017}, --Learjet 36A -- Civilian (Civilian), 1977
	{dbid = 4044, ferryRange = 3125, loadoutid = 20138}, --MD-10-30F -- Commercial (Commercial), DC-10-30 Upgr
	{dbid = 4045, ferryRange = 6820, loadoutid = 20140}, --MD-11 -- Commercial (Commercial), 1991, DC-10 Mod
	{dbid = 4046, ferryRange = 3950, loadoutid = 20141}, --MD-11F -- Commercial (Commercial), 1991, DC-10 Mod
	{dbid = 4461, ferryRange = 3500, loadoutid = 22574}, --Gulfstream III -- Commercial (Commercial), 1981
	--Private aircraft have database ferry range as their range
	{dbid = 3244, ferryRange = 1765, loadoutid = 17394}, --King Air 350 -- Commercial (Commercial), 1991
	{dbid = 2897, ferryRange = 1400, loadoutid = 15006}, --F406 Caravan II -- Civilian (Civilian), 1986
	{dbid = 2558, ferryRange = 2075, loadoutid = 14738}, --Super King Air B200 -- Commercial (Commercial), 1975
	{dbid = 3324, ferryRange = 2240, loadoutid = 17584}, --Pilatus PC-12 -- Commercial (Commercial), 1994
	{dbid = 2557, ferryRange = 465, loadoutid = 9973}, --Piper PA-28 Cherokee -- Civilian (Civilian), 1962
	{dbid = 1571, ferryRange = 415, loadoutid = 8396}, --Cessna 152 -- Civilian (Civilian), 1978
	{dbid = 312, ferryRange = 700, loadoutid = 8398}, --Cessna 172 -- Civilian (Civilian), 1957
	{dbid = 3943, ferryRange = 970, loadoutid = 19786}, --Cessna 208A Caravan -- Civilian (Civilian), 1985
	{dbid = 3946, ferryRange = 970, loadoutid = 19790}, --Cessna 208A-675 Caravan -- Civilian (Civilian), 1998
	{dbid = 3945, ferryRange = 900, loadoutid = 19787}, --Cessna 208B Grand Caravan -- Civilian (Civilian), 1991
	{dbid = 3906, ferryRange = 1150, loadoutid = 19607}, --Cessna 337 Super Skymaster -- Civilian (Civilian), 1966
	{dbid = 4254, ferryRange = 1500, loadoutid = 21851}, --Cessna 500 Citation I -- Civilian (Civilian), 1972
	{dbid = 4255, ferryRange = 2300, loadoutid = 21854}, --Cessna 550 Citation II -- Civilian (Civilian), 1979
	{dbid = 4257, ferryRange = 2300, loadoutid = 21858}, --Cessna 560 Citation Ultra -- Civilian (Civilian), 1995
	{dbid = 4256, ferryRange = 2300, loadoutid = 21857} --Cessna 560 Citation V -- Civilian (Civilian), 1988
}

local function ReturnFerryRangeFromGUID(aircraftGUID)
	local result
	local unit = ScenEdit_GetUnit({guid = aircraftGUID})
	for k, v in ipairs(aircraft) do
		if unit.dbid == v.dbid then
			result = v.ferryRange
		end
	end
	return result
end

local function ReturnFerryRangeFromDBID(aircraftDBID)
	local result
	for k, v in ipairs(aircraft) do
		if aircraftDBID == v.dbid then
			result = v.ferryRange
		end
	end
	return result
end

local function GenerateListOfPossibleDestinations_GUID(aircraftGUID)
	local unit = ScenEdit_GetUnit({guid = aircraftGUID})
	local safeRange = ReturnFerryRangeFromGUID(aircraftGUID) * 0.8
	local result = {}
	for k, v in ipairs(airports) do
		local tripDistance = Tool_Range(aircraftGUID, v.guid)
		if tripDistance < safeRange then
			local tableEntry = {name = v.name, guid = v.guid, range = tripDistance}
			table.insert(result, tableEntry)
		end
	end
	return result
end

local function GenerateListOfPossibleDestinations_ByRange(safeRange, aircraftGUID)
	local unit = ScenEdit_GetUnit({guid = aircraftGUID})
	local result = {}
	for k, v in ipairs(airports) do
		local tripDistance = Tool_Range(aircraftGUID, v.guid)
		if tripDistance < safeRange then
			local tableEntry = {name = v.name, guid = v.guid, range = tripDistance}
			table.insert(result, tableEntry)
		end
	end
	return result
end

local function SortListOfAirportsByRange(airportTable)
	local rangeTable, result = {}, {}
	for k, v in ipairs(airportTable) do
		table.insert(rangeTable, v.range)
	end
	table.sort(rangeTable)
	for i = #rangeTable, 1, -1 do
		rangeValue = rangeTable[i]
		for key, value in ipairs(airportTable) do
			if value.range == rangeValue then
				table.insert(result, value)
			end
		end
	end
	return result
end

local function ChooseOneOfFurthestDestinations(airportTable)
	local airportTable = SortListOfAirportsByRange(airportTable)
	local tableLength = #airportTable
	if tableLength > 3 then
		tableLength = 3
	end
	local result = airportTable[math.random(1, tableLength)]
	return result
end

local function ThisFerryMissionExists(side, name)
	local mission = ScenEdit_GetMission(side, name)
	if mission == nil then
		return false
	else
		return true
	end
end

local function GenerateFerryMission(destinationName)
	local mission
	if ThisFerryMissionExists("Civilian", destinationName) then
		mission = ScenEdit_GetMission(Civilian, destinationName)
	else
		mission = ScenEdit_AddMission("Civilian", destinationName, "ferry", {destination = destinationName})
		ScenEdit_SetMission("Civilian", mission.guid, {FerryBehavior = "Random", flightSize = 1})
	end
	return (mission)
end

local function CreateMissionAndAssignAircraft_Random(aircraftGUID)
	local airportTable = GenerateListOfPossibleDestinations_GUID(aircraftGUID)
	local destinationName = ChooseOneOfFurthestDestinations(airportTable).name
	Tool_EmulateNoConsole()
	GenerateFerryMission(destinationName)
	ScenEdit_AssignUnitToMission(aircraftGUID, destinationName)
end

local function CreateMissionAndAssignAircraft(aircraftGUID, destinationName)
	Tool_EmulateNoConsole()
	local mission = GenerateFerryMission(destinationName)
	ScenEdit_AssignUnitToMission(aircraftGUID, destinationName)
	return mission
end

local function GenerateRandomAircraftName()
	local result
	local flightNumber = math.random(100, 999)
	result = RandomLetter() .. RandomLetter() .. "-" .. flightNumber
	return result
end

local function ReturnRandomAircraftEntry()
	return aircraft[math.random(1, #aircraft)]
end

local function NameIsADuplicate(nameString)
	Tool_EmulateNoConsole()
	local unit = ScenEdit_GetUnit({side = "Civilian", name = nameString})
	if unit == nil then
		return true
	else
		return false
	end
end

local function RandomiseReadyTime(aircraftGUID)
	local unit = ScenEdit_GetUnit({guid = aircraftGUID})
	ScenEdit_SetLoadout(
		{
			unitName = unit.guid,
			loadoutid = 0,
			TimeToReady_Minutes = math.random(0, (12 * 60))
		}
	)
end

local function GenerateAircraft()
	local error_Count = 0
	::redoGenerateAircraft::
	local aircraft = ReturnRandomAircraftEntry()
	local homebase = nil
	local homebaseList = airports

	homebase = homebaseList[math.random(1, #homebaseList)]

	local destination, destinationList

	local safeRange = ReturnFerryRangeFromDBID(aircraft.dbid)
	destinationList = GenerateListOfPossibleDestinations_ByRange(safeRange, homebase.guid)
	destination = ChooseOneOfFurthestDestinations(destinationList)

	local unit =
		ScenEdit_AddUnit(
		{
			side = "Civilian",
			type = "Aircraft",
			dbid = aircraft.dbid,
			name = GenerateRandomAircraftName(),
			base = homebase.guid,
			loadoutid = aircraft.loadoutid
		}
	)

	RandomiseReadyTime(unit.guid)

	CreateMissionAndAssignAircraft(unit.name, destination.name)

	local result = ScenEdit_GetUnit({guid = unit.guid})
	return result
end

for i = 1, 50 do
	GenerateAircraft()
end
