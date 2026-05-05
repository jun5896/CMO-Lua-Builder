math.randomseed(os.time())

WeatherDrift()

local fishingVessels = {
    {dbid=16, prefix='FV ', category ='Commercial'}, --Commercial Fishing Boat [23m]
    {dbid=328, prefix='FV ', category ='Commercial'}, --Commercial Fishing Boat [35m[
    {dbid=2358, prefix='FT ', category ='Commercial'}, --Commercial Factory Trawler [2,500t DWT]
    {dbid=2359, prefix='FT ', category ='Commercial'}, --Commercial Large Trawler [1,250 DWT]
    {dbid=2357, prefix='FT ', category ='Commercial'}, --Commercial Trawler [800t DWT]
}

local numberOFCivFishingVessels = math.random(18,24)

for i = 1,numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1,#fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(37,47,46,55)
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

local randomAAA = {
    80, --AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)
    426, --SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)
    420, --SAM Sec (SA-18 Grouse [9K38 Igla] MANPADS x 3)
    250, --SAM Plt (SA-19 Grisom [9K22 Tunguska])
    1560, --SAM Sec (SA-24 Grouse [9K338 Igla-S] MANPADS x 3)
}

local numberOfRandomAAA = math.random(18,36)

for i = 1,numberOfRandomAAA do
	local randomType = randomAAA[math.random(1,#randomAAA)]
	local errorCount = 0
	::redoPositionAAA::
	local position = RandomPosition(39,41,46,51)
	if OverWater(position.latitude,position.longitude) then 
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionAAA
		else
			BugMessage('Game_Setup','Unable to place random AAA  #'..i..' after 500 attempts!')
			break
		end
	end
	
	local unit = ScenEdit_AddUnit({
		side='Azerbaijan',
		type='Facility',
		dbid=randomType,
		name='Random AAA #'..i,
		lat=position.latitude,
		lon=position.longitude
	})
end