math.randomseed(os.time())

WeatherDrift()

local function SetupSideAsAI(sideName)
	ScenEdit_SetSidePosture('Civilian', sideName, 'F')
	ScenEdit_SetSidePosture('Nature', sideName, 'F')
	ScenEdit_SetDoctrine({side=sideName}, {
		weapon_control_status_air = 1,
		weapon_control_status_surface = 1,
		weapon_control_status_subsurface = 1,
		weapon_control_status_land = 1,
		})
end


if ScenEdit_PlayerSide() == 'United States' then
	SetupSideAsAI('PLAN')
elseif ScenEdit_PlayerSide() == 'PLAN' then
	SetupSideAsAI('United States')
end

RunScript("CivilianAirTraffic")
RunScript("CivilianShipping")

local chinaUnitsToJitter = {
	{name = "Shen Lian Cheng 781", guid = "d1d63bb4-49c0-48cd-ad03-ceeb9a3ea862", jitterRange = 20},
	{name = "Zhong Shui 768", guid = "bd0d2bd1-1188-4682-937e-0305d247fa26", jitterRange = 20},
	{name = "Lu Rong Yuan Yu 206", guid = "9bef247d-cedf-4153-8bbc-37a323be830e", jitterRange = 20},
	{name = "Feng Hui 18", guid = "1c81dfc5-f7f5-49a5-a45a-d847acde7b34", jitterRange = 20},
	{name = "Lu Rong Yuan Yu 168", guid = "8b4415f7-aa7d-436b-9577-9621fc7f8904", jitterRange = 20},
	{name = "Hu Yu 912", guid = "65c614c2-fe85-4e6c-ab45-3aee49f9c3c5", jitterRange = 20},
	{name = "Fu Yuan Yu 7088", guid = "2c92091d-0b01-458c-99bd-e6ba83597551", jitterRange = 20},
	{name = "1002", guid = "cf1cdccd-42ed-4fc6-9926-dfa460f84082", jitterRange = 20},
	{name = "330", guid = "db45d569-8744-443a-a231-3f73d442bbf1", jitterRange = 20},
	{name = "Qinzhou", guid = "9b117eee-c8d4-42c0-a63e-766d45c8189a", jitterRange = 20}
}

local usUnitsToJitter = {
	{name = "LCS 1 Freedom", guid = "520d37cd-0567-42c6-949c-5b9898e53ae6", jitterRange = 20},
	{name = "LCS 3 Fort Worth", guid = "ff766d3d-9a49-4ae7-b0c7-ad383d874e12", jitterRange = 20},
	{name = "DDG 97 Halsey", guid = "0142ae92-f854-4d6d-92c9-73f2272c9962", jitterRange = 20},
	{name = "SSN 776 Hawaii", guid = "18cdf2f9-ea70-48fa-8d2d-9c82f6ebbff3", jitterRange = 20},
	{name = "BRP Artemio Ricarte", guid = "d98f2eee-bdaa-4cc1-8926-bc5d0e28391f", jitterRange = 20},
	{name = "BRP Emilio Jacinto", guid = "6d775420-25d9-4a61-8a06-c7b6c8d82a3b", jitterRange = 20}
}

function JitterUnits(side)
	local sideJitterList
	if side == 'PLAN' then
		sideJitterList = chinaUnitsToJitter
	else
		sideJitterList = usUnitsToJitter
	end
	for k,v in ipairs (sideJitterList) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		local newPos = CircularRandomPosition(unit.latitude, unit.longitude, v.jitterRange)
		if OverWater(newPos.latitude,newPos.longitude) then
			ScenEdit_SetUnit({guid=unit.guid,latitude=newPos.latitude,longitude=newPos.longitude})
		end
	end
end

local playerSide = ScenEdit_PlayerSide()
local computerSide
if playerSide == 'PLAN' then
	computerSide = 'United States'
else
	computerSide = 'PLAN'
end

if inDevelopment then
    local userInput  = string.upper(ScenEdit_MsgBox('Jitter units for '..computerSide..'?',1))
	if userInput == 'OK' then JitterUnits(computerSide) end
else
	JitterUnits(computerSide)
end

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

	local position = RandomPosition(12, 16, 114, 120)
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

local biolQty = math.random(18, 36)

errorCount = 0

for i = 1, biolQty do
	local randomType

	if i <= biolQty * 0.6 then
		randomType = biolDBIDs[1]
	elseif i <= biolQty * 0.8 then
		randomType = biolDBIDs[2]
	else
		randomType = biolDBIDs[3]
	end

	::redoPositionBiologics::
	local position = RandomPosition(12, 16, 114, 120)
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
