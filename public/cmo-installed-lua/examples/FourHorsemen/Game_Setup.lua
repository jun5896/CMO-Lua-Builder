math.randomseed(os.time())

WeatherDrift()

local function RandomiseReadyTime(aircraftGUID,maxHours)
	local unit = ScenEdit_GetUnit({guid=aircraftGUID})
	ScenEdit_SetLoadout({unitName=unit.guid,
		loadoutid=0,
		TimeToReady_Minutes=math.random(0,(maxHours*60))})
end

local function GetListOfAircraftOnSide(sideName)
	local aircraftTable = {}
	local sideUnits = VP_GetSide({side=sideName}).units
	for k,v in ipairs (sideUnits) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.type == 'Aircraft' then
			table.insert(aircraftTable,unit)
		end
	end
	return aircraftTable
end

local function RandomiseAircraftReadyTimesForSide(sideName,maxHours)
	local aircraftTable = GetListOfAircraftOnSide(sideName)
	for k,v in ipairs (aircraftTable) do
		RandomiseReadyTime(v.guid,maxHours)
	end
end

RandomiseAircraftReadyTimesForSide('NATO',12)
RandomiseSideUnitProficiency('NATO')

local falseContactDBIDs = {
	95, --Large
	94, --Medium
	93, --Small
	653, --Magnetic
	654 --Magnetic and acoustic
}

local falseQty = math.random(12, 18)

local errorCount = 0
for i = 1, falseQty do
	::redoPositionFalse::

	local position = RandomPosition(60, 64, -20, -7)
	local elevation = World_GetElevation(position)

	if elevation > -10 or elevation < -500 then
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionFalse
		else
			BugMessage("Game_Setup", "Unable to place false contact #" .. i .. " after 500 attempts!")
			break
		end
	end

	local randomType = falseContactDBIDs[math.random(1, #falseContactDBIDs)]

	ScenEdit_AddUnit(
		{
			side = "Nature",
			type = "Submarine",
			dbid = randomType,
			name = "False Contact " .. i,
			lat = position.latitude,
			lon = position.longitude
		}
	)
end

--Randomly place biologicals; 60% fish, 20% Orca, 20% Whale
local biolDBIDs = {
	354, --Fish
	355, --Orcas
	92 --Whale
}

local biolQty = math.random(9, 18)

for i = 1, biolQty do
	local randomType
	local errorCount = 0

	if i <= biolQty * 0.6 then
		randomType = biolDBIDs[1]
	elseif i <= biolQty * 0.8 then
		randomType = biolDBIDs[2]
	else
		randomType = biolDBIDs[3]
	end

	::redoPositionBiologics::
	local position = RandomPosition(60, 64, -20, -7)
	local elevation = World_GetElevation(position)
	if elevation > -25 then
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionBiologics
		else
			BugMessage("Game_Setup", "Unable to place biologic contact #" .. i .. " after 500 attempts!")
			break
		end
	end

	local unit =
		ScenEdit_AddUnit(
		{
			side = "Nature",
			type = "Submarine",
			dbid = randomType,
			name = "Biol Contact " .. i,
			lat = position.latitude,
			lon = position.longitude
		}
	)

	ScenEdit_AssignUnitToMission(unit.name, "Wander")
end
