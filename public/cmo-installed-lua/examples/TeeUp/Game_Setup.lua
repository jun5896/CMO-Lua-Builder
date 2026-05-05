math.randomseed(os.time())

WeatherDrift()

local ships = {
	{name='BPK Krondstadt', guid='500b3eb4-4c83-471f-bfb1-599b65bbe1ab'} , 
	{name='DPK Derzkiy', guid='dd9438f0-f521-4d61-973b-737151a99e73'} , 
	{name='SKR Kobchik', guid='b99e05d7-7ea6-4070-bc8a-94c5139cf33d'}
}

for k,v in pairs (ships) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local newPos = CircularRandomPosition(unit.latitude,unit.longitude,10)
	if OverWater(newPos.latitude,newPos.longitude) then
		ScenEdit_SetUnit({guid=unit.guid,latitude=newPos.latitude,longitude=newPos.longitude})
	end
end

local submarines = {
	{name='K-629', guid='027d7c57-9919-413d-82b7-3671a9ffde4d'} , 
	{name='K-21', guid='efef5ea6-e4e3-4fbf-bf3b-d77e7ef5f8ef'}
}

for k,v in pairs (submarines) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local newPos = CircularRandomPosition(unit.latitude,unit.longitude,10)
	if OverWater(newPos.latitude,newPos.longitude) then
		ScenEdit_SetUnit({guid=unit.guid,latitude=newPos.latitude,longitude=newPos.longitude})
	end
end

for each,submarine in ipairs (submarines) do
	local submarineData = ScenEdit_GetUnit({guid=submarine.guid})
    local submarineWaypoints = submarineData.course
	local newWaypoints = {}
	for waypoint = 1,2 do
		oldWaypoint = submarineWaypoints[waypoint]
		newWaypoint = CircularRandomPosition(oldWaypoint.latitude,oldWaypoint.longitude,10)
        table.remove(submarineWaypoints,waypoint)
        table.insert(submarineWaypoints,waypoint,newWaypoint)
		ScenEdit_SetUnit({guid=submarineData.guid,course=submarineWaypoints})
	end
end

local falseContactDBIDs = {
	95, --Large
	94, --Medium
	93, --Small
}

local falseQty =  math.random(16,24)

local errorCount = 0
for i = 1,falseQty do

	::redoPositionFalse::

	local position = RandomPosition(20,22,-82,-79)
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
	220, --Fish
	221, --Orcas
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
	local position = RandomPosition(20,22,-82,-79)
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