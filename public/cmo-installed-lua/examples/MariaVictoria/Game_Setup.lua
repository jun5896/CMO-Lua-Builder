math.randomseed(os.time())

WeatherDrift()

local submarine = ScenEdit_GetUnit({guid='2512460a-69c5-4752-a2e9-bea1769abbdd'})
local newPos = CircularRandomPosition(submarine.latitude,submarine.longitude,15)

ScenEdit_SetUnit({guid=submarine.guid,latitude=newPos.latitude,longitude=newPos.longitude})

local cordella = ScenEdit_GetUnit({guid='11e5af70-e255-4595-9c95-94a5d99870cd'})
local newPos = CircularRandomPosition(cordella.latitude,cordella.longitude,7.5)

ScenEdit_SetUnit({guid=cordella.guid,latitude=newPos.latitude,longitude=newPos.longitude})

local shipGroups = {
	{name='Amphib Group', guid='21a3cfbb-89b3-45c9-9d82-c74771d7f873'} , 
	{name='ASW Group', guid='5cedf219-bf05-4b91-8562-636f53c82dbc'}
}

for each,group in ipairs (shipGroups) do
	local groupData = ScenEdit_GetUnit({guid=group.guid})
    local groupWaypoints = groupData.course
	local newWaypoints = {}
	for waypoint = 1,4 do
		oldWaypoint = groupWaypoints[waypoint]
		newWaypoint = CircularRandomPosition(oldWaypoint.latitude,oldWaypoint.longitude,10)
        table.remove(groupWaypoints,waypoint)
        table.insert(groupWaypoints,waypoint,newWaypoint)
		ScenEdit_SetUnit({guid=groupData.guid,course=groupWaypoints})
	end
end

local falseContactDBIDs = {
	95, --Large
	94, --Medium
	93, --Small
	653, --Magnetic
	654, --Magnetic and acoustic
}

local falseQty =  math.random(16,24)

local errorCount = 0
for i = 1,falseQty do

	::redoPositionFalse::

	local position = RandomPosition(-52,-49,-62,-56)
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

local biolQty = math.random(12,36)

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
	local position = RandomPosition(-52,-49,-62,-56)
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