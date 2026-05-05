math.randomseed(os.time())

--Set weather
WeatherDrift()

--Jitter sub position
local submarines = {
	{name = "TK-208 Dimitri Donskoy", guid = "e7337ae6-6c52-49b0-b4cb-f7edcabf56be"},
	{name = "B-414 Daniil Moskovskiy", guid = "c1a0e312-9ccc-43d1-9e6c-01899c8433d9"},
	{name = "B-276 Kostroma", guid = "43d97273-0d83-4698-b2ea-89ffef9f31fb"},
	{name = "K-317 Pantera", guid = "86e9f985-ccf7-41db-b74d-343ff9ebef08"}
}

for k,v in ipairs (submarines) do
	JitterPosition(v.guid,40)
end

--Randomly place false contacts
local falseContactDBIDs = {
	95, --Large
	94, --Medium
	93, --Small
}

local falseQty = math.random(24, 36)

for i = 1, falseQty do
	::redoPositionFalse::
	local position = RandomPosition(84, 86, -161, -103)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -10 then
		goto redoPositionFalse
	end
	local randomType = math.random(1, 3)
	ScenEdit_AddUnit(
		{
			side = "Nature",
			type = "Submarine",
			dbid = falseContactDBIDs[randomType],
			name = "False Contact " .. i,
			lat = position.latitude,
			lon = position.longitude
		}
	)
end