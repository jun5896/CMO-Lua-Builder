math.randomseed(os.time())

WeatherDrift()

local fishingVessels = {
	{dbid=20, prefix='N/A', category='Commercial',}, -- Civilian Dhow [15m] -- Civilian (Civilian)
	{dbid=357, prefix='N/A', category='Commercial',}, -- Civilian Dhow [22m] -- Civilian (Civilian)
}

local numberOFCivFishingVessels = math.random(24,36)

for i = 1,numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1,#fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(27,30,48,51)
	local elevation = World_GetElevation(position)
	if elevation > -25 then 
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionFishingVessels
		else
			BugMessage('Game_Setup','Unable to place fishing vessel #'..i..' after 500 attempts!')
			break
		end
	end
	
	local unit = ScenEdit_AddUnit({
		side='Civilian',
		type='Ship',
		dbid=randomType,
		name='Fishing Vessel',
		lat=position.latitude,
		lon=position.longitude
	})

	ScenEdit_AssignUnitToMission(unit.guid, 'Fishing')
end

--Randomly place false contacts
local falseContactDBIDs = {
	95, --Large
	94, --Medium
	93 --Small
}

local falseQty =  math.random(6,12)

local errorCount = 0
for i = 1,falseQty do

	::redoPositionFalse::

	local position = RandomPosition(27,30,48,51)
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

local biolDBIDs = {
	220,
	220,
	92
}

local biolQty = math.random(6,18)

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
	local position = RandomPosition(27,30,48,51)
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