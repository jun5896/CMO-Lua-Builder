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

local falseQty = math.random(12, 18)

local errorCount = 0
for i = 1, falseQty do
	::redoPositionFalse::

	local position = RandomPosition(6, 10, 109, 114)
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
	local position = RandomPosition(6, 10, 109, 114)
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

local playerside = ScenEdit_PlayerSide()

if playerside == 'India' then
	local position = {latitude=8.20335765008032, longitude=111.491242286826}
	local positionDescription = ConvertDecimalPositionToDegrees(position.latitude,position.longitude)
	local theMessage = GenerateRadioMessageBody('Indian warships in position '..positionDescription..' this is Chinese Warship.</P> <P>You are encroaching on Chinese sovereign territory and your intentions are not understood. Turn around immediately and leave the area. </P><P>We will not warn you again.','Chinese Warship')
	RadioMessage('VHF','121.5MHz',theMessage,{latitude=8.20335765008032, longitude=111.491242286826})
	
else
	local theMessage = NonAlignedSignal(
		'CMDR CTF LIAONING', --recipient
		'SOUTH SEA FLEET HQ - Zhanjiang', --sender
		'UPDATED ORDERS', --subject
        'TOP SECRET', --classification
		'FLASH', --precedence
		'1. DESPITE REPEATED WARNINGS INDIAN NAVAL VESSELS CONTINUE TO AGITATE AND THREATEN OUR FORCES IN THE SOUTH CHINA SEA.<BR> 2. INTELLIGENCE SUGGESTS THAT THE INDIANS ARE PLANNING TO LAUNCH A STRIKE AGAINST OUR FORCES IN THE IMMEDIATE FUTURE.<BR> 3. YOU ARE THEREFORE DIRECTED TO REMOVE THE INDIAN NAVAL FORCES FROM THE SOUTH CHINA SEA USING WHATEVER FORCE NECESSARY.')

	ScenEdit_SpecialMessage('playerside',theMessage)
	RegisterMessage(theMessage)
end