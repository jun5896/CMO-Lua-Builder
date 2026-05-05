math.randomseed(os.time())

WeatherDrift()

local fishingVessels = {
	{dbid=16, prefix='FV ', category ='Commercial'}, --Commercial Fishing Boat [23m]
	{dbid=328, prefix='FV ', category ='Commercial'}, --Commercial Fishing Boat [35m[
	{dbid=1788, prefix='FT ', category ='Commercial'}, --22m Dhow
	{dbid=1787, prefix='FT ', category ='Commercial'}, --15 Dhow
}

local numberOFCivFishingVessels = math.random(4,12)

for i = 1,numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1,#fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(-3,3,41,48)
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