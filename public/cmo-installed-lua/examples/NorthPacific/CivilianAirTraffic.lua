math.randomseed(os.time())
math.random()
--Tool_EmulateNoConsole()

local missionList = {}

local airports = {
	{name = "Vladivostok International Airport", guid = "b5f90609-ccc6-4d45-a050-b4386da9bdd9"},
	{name = "Petropavlosk South Airport", guid = "4503f569-95e2-45b3-856a-96284f4ffaa2"},
	{name = "Beijing Capital International Airport", guid = "91be94a0-451f-4e29-a07e-d05ebfbcb27b"},
	{name = "Los Angeles International Airport", guid = "74af6ec5-d218-4044-b79f-9744536e9676"},
	{name = "Ted Stevens Anchorage International Airport", guid = "6d50c74b-8111-4978-b58a-b58292b5d879"},
	{name = "Tokyo Haneda International Airport", guid = "a60b2757-565d-40df-aa51-973882f1f562"},
	{name = "Vancouver International Airport", guid = "7abd9bfd-fde8-451c-bad8-df070c28f169"}
}

local aircraft = {
	{dbid = 2428, ferryRange = 7250, loadoutid = 9926}, --Airbus A.330-200 -- Commercial (Commercial), 1999
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
	{dbid = 32, ferryRange = 8650, loadoutid = 9932}, --Airbus A.340-500 -- Commercial (Commercial), 2004
	{dbid = 3974, ferryRange = 8150, loadoutid = 19912}, --Boeing 787-8 Dreamliner -- Commercial (Commercial), 2012
	{dbid = 3975, ferryRange = 8650, loadoutid = 19915}, --Boeing 787-9 Dreamliner -- Commercial (Commercial), 2015
	{dbid = 3976, ferryRange = 7350, loadoutid = 19919}, --Boeing 787-10 Dreamliner -- Commercial (Commercial), 2018
	{dbid = 3978, ferryRange = 8100, loadoutid = 19923}, --Boeing 777-200ER -- Commercial (Commercial), 1997
	{dbid = 3979, ferryRange = 6400, loadoutid = 19929}, --Boeing 777-300 -- Commercial (Commercial), 1998
	{dbid = 3980, ferryRange = 9800, loadoutid = 19927}, --Boeing 777-200LR -- Commercial (Commercial), 1998
	{dbid = 3981, ferryRange = 8200, loadoutid = 19933}, --Boeing 777-300ER -- Commercial (Commercial), 1998
	{dbid = 3983, ferryRange = 8650, loadoutid = 19939}, --Airbus A.350-800 -- Commercial (Commercial), 2017
	{dbid = 3984, ferryRange = 8150, loadoutid = 19942}, --Airbus A.350-900 -- Commercial (Commercial), 2015
	{dbid = 3985, ferryRange = 8400, loadoutid = 19944}, --Airbus A.350-1000 -- Commercial (Commercial), 2019
	{dbid = 3986, ferryRange = 8900, loadoutid = 19948}, --Airbus A.380-800 -- Commercial (Commercial), 2008
	{dbid = 4045, ferryRange = 6820, loadoutid = 20140}, --MD-11 -- Commercial (Commercial), 1991, DC-10 Mod
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

local function ThisFerryMissionExists(missionName)
	local result = false
	for k, v in ipairs(missionList) do
		if v == missionName then
			return true
		end
	end
	return false
end

local function AddMissionToList(missionName)
	table.insert(missionList, missionName)
end

local function GenerateFerryMission(destinationName)
	local mission
	if ThisFerryMissionExists(destinationName) then
		mission = ScenEdit_GetMission("Civilian", destinationName)
	else
		mission = ScenEdit_AddMission("Civilian", destinationName, "ferry", {destination = destinationName})
		ScenEdit_SetMission("Civilian", mission.guid, {FerryBehavior = "Random", flightSize = 1})
		AddMissionToList(mission.name)
	end
	return mission
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
			TimeToReady_Minutes = math.random(0, (4 * 60))
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

for i = 1, 100 do
	GenerateAircraft()
end
