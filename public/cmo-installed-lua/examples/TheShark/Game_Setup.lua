math.randomseed(os.time())

WeatherDrift()

local submarine = {name = "S 131 Hangor ", guid = "01c88519-69ea-4fb8-b0cb-1b2f91f9cada"}

local frigates = {
	{name = "F 144 Kirpan", guid = "443f708b-1e15-467c-b002-42be504e572f"},
	{name = "F 149 Khukri", guid = "0026cabb-f628-4a3f-b8f8-b4a07b316aed"}
}

local playerSide = ScenEdit_PlayerSide()
local enemySide = 'India'
if playerSide == 'India' then enemySide = 'Pakistan' end

if playerSide == 'India' then
	JitterPosition(submarine.guid,10)
else
	for k,v in ipairs (frigates) do
		JitterPosition(v.guid,5)
	end
end

local fishingVessels = {
	{dbid = 20, prefix = "N/A", category = "Commercial"}, -- Civilian Dhow [15m] -- Civilian (Civilian)
	{dbid = 357, prefix = "N/A", category = "Commercial"} -- Civilian Dhow [22m] -- Civilian (Civilian)
}

local numberOFCivFishingVessels = math.random(8, 12)

for i = 1, numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1, #fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(18, 21, 69, 73)
	local elevation = World_GetElevation(position)
	if elevation > -25 then
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionFishingVessels
		else
			BugMessage("Game_Setup", "Unable to place fishing vessel #" .. i .. " after 500 attempts!")
			break
		end
	end

	local unit =
		ScenEdit_AddUnit(
		{
			side = "Civilian",
			type = "Ship",
			dbid = randomType,
			name = "Fishing Vessel",
			lat = position.latitude,
			lon = position.longitude
		}
	)

	ScenEdit_AssignUnitToMission(unit.guid, "Fishing")
end

--Randomly place false contacts
local False_DBIDs = {
	95, --Large
	94, --Medium
	93 --Small
}

local falseQty = math.random(16, 24)

for i = 1, falseQty do
	::redoPositionFalse::
	local position = RandomPosition(18, 21, 69, 73)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -10 or pos_elev < -500 then
		goto redoPositionFalse
	end
	local randomType = math.random(1, 3)
	ScenEdit_AddUnit(
		{
			side = "Nature",
			type = "Submarine",
			dbid = False_DBIDs[randomType],
			name = "False Contact " .. i,
			lat = position.latitude,
			lon = position.longitude
		}
	)
end

--Randomly place biologicals; 60% fish, 20% Orca, 20% Whale
local Biol_DBIDs = {
	220,
	220,
	92
}

local biolQty = math.random(16, 24)

for i = 1, biolQty do
	if i <= biolQty * 0.6 then
		randomType = Biol_DBIDs[1]
	elseif i <= biolQty * 0.8 then
		randomType = Biol_DBIDs[2]
	else
		randomType = Biol_DBIDs[3]
	end
	::redoPositionBiologics::
	local position = RandomPosition(18, 21, 69, 73)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -25 then
		goto redoPositionBiologics
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
