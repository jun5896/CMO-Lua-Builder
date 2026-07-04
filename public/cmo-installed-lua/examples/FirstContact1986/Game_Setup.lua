math.randomseed(os.time())

WeatherDrift()

local function ReturnPlayerSide()
	local result, sideTable = nil, {'Soviet Union', 'Norway'}
	for k,v in ipairs (sideTable) do
		if ScenEdit_GetSideIsHuman (v) then
			result = v
		end
	end
	assert(result,'Player side set to invalid side.')
	return result
end

local function GroupJitter(sideName, radius)
	local sideGroups = VP_GetSide({side=sideName}).units
	for k,v in ipairs (sideGroups) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.type == 'Group' then
			local newPos = CircularRandomPosition(unit.latitude,unit.longitude,radius)
			if OverWater(newPos.latitude,newPos.longitude) then
				ScenEdit_SetUnit({guid=unit.guid,latitude=newPos.latitude,longitude=newPos.longitude})
			end
		end
	end
end

local function SetupAISide(sideName)
	GroupJitter(sideName, 10)
	ScenEdit_SetSidePosture('Civilian',sideName,'F')
end

local playerSide, AISide = ReturnPlayerSide(), nil

if playerSide == 'Soviet Union' then 
	AISide = 'Norway'
else
	AISide = 'Soviet Union'
end

SetupAISide(AISide)


local fishingVessels = {
	{dbid=16, prefix='FV ', category ='Commercial'}, --Commercial Fishing Boat [23m]
	{dbid=328, prefix='FV ', category ='Commercial'}, --Commercial Fishing Boat [35m[
	{dbid=2358, prefix='FT ', category ='Commercial'}, --Commercial Factory Trawler [2,500t DWT]
	{dbid=2359, prefix='FT ', category ='Commercial'}, --Commercial Large Trawler [1,250 DWT]
	{dbid=2357, prefix='FT ', category ='Commercial'}, --Commercial Trawler [800t DWT]
}

local numberOFCivFishingVessels = math.random(4,12)

for i = 1,numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1,#fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(70,72,19,25)
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