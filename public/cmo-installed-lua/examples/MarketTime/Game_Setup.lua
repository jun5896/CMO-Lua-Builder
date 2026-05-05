math.randomseed(os.time())

WeatherDrift()

local ships = {
	{name='Suspected Infiltration Vessel  X-030101', guid='9a37999e-2399-4944-8435-058462af6a41'} , 
	{name='Suspected Infiltration Vessel  X-030102', guid='451f1eef-7e0a-4f61-9361-85f182c5698c'} , 
	{name='Enemy Combatant Vessel H-030101', guid='73e9e242-afa6-4c1f-a090-20ef8e43a7a1'} , 
	{name='Enemy Combatant Vessel H-030102', guid='b469a96c-802e-4406-b39e-cd933140c703'} , 
	{name='Suspected Infiltration Vessel  X-030104', guid='79106810-6fd0-418e-a6db-50510d8f1ab9'} , 
	{name='Enemy Combatant Vessel H-030103', guid='cd0147a1-16bd-4350-bc3e-7c41e009b85b'} , 
	{name='Suspected Infiltration Vessel  X-030103', guid='28f0770a-41db-471b-a17d-1064f9cf1f97'}
}

for k,v in pairs (ships) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local newPos = CircularRandomPosition(unit.latitude,unit.longitude,10)
	if OverWater(newPos.latitude,newPos.longitude) then
		unit = ScenEdit_SetUnit({guid=unit.guid,latitude=newPos.latitude,longitude=newPos.longitude})
	end
    if unit.dbid == 1321 then
        local refPointPos = CircularRandomPosition(unit.latitude,unit.longitude,25)
        local refPoint = ScenEdit_AddReferencePoint({name=unit.name..' last known position.',side='MACV',latitude=refPointPos.latitude,longitude=refPointPos.longitude,highlighted=true,locked=true})
    end
end

for each,ship in ipairs (ships) do
	local shipData = ScenEdit_GetUnit({guid=ship.guid})
    local shipWaypoints = shipData.course
	local newWaypoints = {}
	for waypoint = 1,4 do
		oldWaypoint = shipWaypoints[waypoint]
		newWaypoint = CircularRandomPosition(oldWaypoint.latitude,oldWaypoint.longitude,10)
        table.remove(shipWaypoints,waypoint)
        table.insert(shipWaypoints,waypoint,newWaypoint)
		ScenEdit_SetUnit({guid=shipData.guid,course=shipWaypoints})
	end
end


local fishingVessels = {
	{dbid=20, prefix='N/A', category='Commercial',}, -- Civilian Dhow [15m] -- Civilian (Civilian)
	{dbid=357, prefix='N/A', category='Commercial',}, -- Civilian Dhow [22m] -- Civilian (Civilian)
}

local numberOFCivFishingVessels = math.random(48,96)

for i = 1,numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1,#fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(7,17,102,112)
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