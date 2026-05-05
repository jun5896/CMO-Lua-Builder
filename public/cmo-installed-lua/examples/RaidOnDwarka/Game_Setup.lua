math.randomseed(os.time())

WeatherDrift()

local fishingVessels = {
	{dbid=20, prefix='N/A', category='Commercial',}, -- Civilian Dhow [15m] -- Civilian (Civilian)
	{dbid=357, prefix='N/A', category='Commercial',}, -- Civilian Dhow [22m] -- Civilian (Civilian)
}

local numberOFCivFishingVessels = math.random(4,8)

for i = 1,numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1,#fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(20,22,68,70)
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