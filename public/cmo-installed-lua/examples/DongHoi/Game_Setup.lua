math.randomseed(os.time())

WeatherDrift()

local shipsToJitter = {
	{name = "Swatow", guid = "7e1bccfe-e8d0-41e2-94a4-a5032d524541"},
	{name = "Swatow", guid = "1d967252-e824-4160-9ad9-53c3bbdd5279"},
	{name = "P-4 MTB", guid = "0f455548-5a47-4844-89dc-28e72d91038f"},
	{name = "P-4 MTB", guid = "b4f180fc-ab55-46aa-895e-a01694c835ec"},
	{name = "Swatow", guid = "b762144f-9271-4d7b-b7e2-b54ed6c62251"},
	{name = "Swatow", guid = "2c8d9532-5767-4e56-a38d-081ec408bb88"},
	{name = "P-4 MTB", guid = "8b6518e8-f3ff-48b7-980f-9236f1593c0c"},
	{name = "P-4 MTB", guid = "fbb83b4c-fe86-4459-9e1f-47402265c016"},
	{name = "SSV Okean", guid = "f5ef8982-61e8-4220-8142-9ab84db46d7c"},
}

for k,v in ipairs (shipsToJitter) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local newPos = CircularRandomPosition(unit.latitude,unit.longitude,10)
	if OverWater(newPos.latitude,newPos.longitude) then
		ScenEdit_SetUnit({guid=unit.guid,latitude=newPos.latitude,longitude=newPos.longitude})
	end
end

local fishingVessels = {
	{dbid = 20, prefix = "N/A", category = "Commercial"}, -- Civilian Dhow [15m] -- Civilian (Civilian)
	{dbid = 357, prefix = "N/A", category = "Commercial"} -- Civilian Dhow [22m] -- Civilian (Civilian)
}

local numberOFCivFishingVessels = math.random(48, 96)

for i = 1, numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1, #fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(16, 19, 105, 110)
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
