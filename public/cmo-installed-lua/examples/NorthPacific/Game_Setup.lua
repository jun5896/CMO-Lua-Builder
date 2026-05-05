math.randomseed(os.time())

WeatherDrift()

RunScript("CivilianAirTraffic")
RunScript("CivilianShipping")

local falseContactDBIDs = {
	95, --Large
	94, --Medium
	93, --Small
	653, --Magnetic
	654 --Magnetic and acoustic
}

local falseQty = math.random(6, 12)

local errorCount = 0
for i = 1, falseQty do
	::redoPositionFalse::

	local position = RandomPosition(45,55,162,172)
	local elevation = World_GetElevation(position)

	if elevation > -10 then
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
	local position = RandomPosition(45,55,162,172)
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

--War footing messages
local playerSide = ScenEdit_PlayerSide()
if playerSide == 'United States' then
	TelexMessageToPlayerNATO(
		'cvbg-61', 
		'compacflt', 
		'i', 
		'commander pacific fleet', 
		'cvbg 61', 
		'secret', 
		'1. sigint intercepts indicate soviet intentions to intercept P-3C aircraft detected east of bering island <BR>'..
		'2. referenced aircraft is in international airspace and conducting innocent transit within bounds of international law <BR>'..
		'3. maintain mission flight plan to skirt soviet airspace and conduct freedom of navigation exercise <BR>'..
		'4. prepare cvw-2 aaw assets to deter likely soviet harassment', 
		{latitude='54.3627642836236', longitude='169.728904721601'}
	)--location
else
	TelexMessageToPlayerSoviet(
		'strazh',
		'11th Red Banner Army of the PVO - Far East Military District',
		'air defence alert',
		'cc',
		'Vozdukh',
		'1. aircraft detected east of bering island <BR>'..
		'2. aircraft not responding to identification calls <BR>'..
		'3. intentions of aircraft unknown <BR>'..
		'4. assess aircraft as american spy plane conducting illegal espionage mission <BR>'..
		'5. you are ordered to immediately launch interceptors and destroy the aircraft <BR>' , 
		{latitude='54.3627642836236', longitude='169.728904721601'} --location
	)
end

