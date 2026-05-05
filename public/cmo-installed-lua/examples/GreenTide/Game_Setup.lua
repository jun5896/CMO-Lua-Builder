math.randomseed(os.time())

WeatherDrift()

RunScript('CivilianAirTraffic')
RunScript('CivilianShipping')

local falseContactDBIDs = {
	95, --Large
	94, --Medium
	93, --Small
	653, --Magnetic
	654, --Magnetic and acoustic
}

local falseQty =  math.random(12,18)

local errorCount = 0
for i = 1,falseQty do

	::redoPositionFalse::

	local position = RandomPosition(26,29,-15,-10)
	local elevation = World_GetElevation(position)

	if elevation > -10 or elevation < -500 then
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionFalse
		else
			BugMessage('Game_Setup','Unable to place false contact #'..i..' after 500 attempts!')
			break
		end
	end

	local randomType = falseContactDBIDs[math.random(1,#falseContactDBIDs)]

	ScenEdit_AddUnit({ 
		side='Nature',
		type='Submarine',
		dbid=randomType,
		name='False Contact '..i,
		lat=position.latitude,
		lon=position.longitude
	})
end

--Randomly place biologicals; 60% fish, 20% Orca, 20% Whale
local biolDBIDs = {
	354, --Fish
	355, --Orcas
	92 --Whale
}

local biolQty = math.random(18,36)

errorCount = 0

for i = 1,biolQty do
	local randomType

	if i <= biolQty * 0.6 then
		randomType = biolDBIDs[1]
	elseif i <= biolQty * 0.8 then
		randomType = biolDBIDs[2]
	else
		randomType = biolDBIDs[3]
	end

	::redoPositionBiologics::
	local position = RandomPosition(26,29,-15,-10)
	local elevation = World_GetElevation(position)
	if elevation > -25 then 
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionBiologics
		else
			BugMessage('Game_Setup','Unable to place biologic contact #'..i..' after 500 attempts!')
			break
		end
	end
	
	local unit = ScenEdit_AddUnit({
		side='Nature',
		type='Submarine',
		dbid=randomType,
		name='Biol Contact '..i,
		lat=position.latitude,
		lon=position.longitude
	})

	ScenEdit_AssignUnitToMission(unit.name, 'Wander')
end