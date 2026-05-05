math.randomseed(os.time())

WeatherDrift()

local ships = {
	{name='Varyag Group', guid='4a5c677b-7ae3-46d5-80cb-9d315dcf4643'}
}

for k,v in pairs (ships) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local newPos = CircularRandomPosition(unit.latitude,unit.longitude,100)
	if OverWater(newPos.latitude,newPos.longitude) then
		ScenEdit_SetUnit({guid=unit.guid,latitude=newPos.latitude,longitude=newPos.longitude})
	end
end

local submarines = {
	{name='B-98', guid='a075db83-95aa-45c2-9a09-53f4f5db117b'} , 
	{name='S-53', guid='df2a13df-82d4-4f2c-83dd-0c276993a633'} , 
	{name='S-32', guid='94a56506-059b-48a9-bf79-3662017fe9b0'} , 
	{name='B-519', guid='b55ffcbc-df90-4231-b0b5-81d73adbb1b5'} , 
	{name='K-14', guid='e0a459d4-fd12-4ec5-ac43-81770fe32382'}
}

for k,v in pairs (submarines) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local newPos = CircularRandomPosition(unit.latitude,unit.longitude,200)
	if OverWater(newPos.latitude,newPos.longitude) then
		ScenEdit_SetUnit({guid=unit.guid,latitude=newPos.latitude,longitude=newPos.longitude})
	end
end

local falseContactDBIDs = {
	95, --Large
	94, --Medium
	93, --Small
}

local falseQty =  math.random(6,12)

local errorCount = 0
for i = 1,falseQty do

	::redoPositionFalse::

	local position = RandomPosition(68,71,-8,18)
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
	local position = RandomPosition(68,71,-8,18)
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

	ScenEdit_AssignUnitToMission(unit.guid, 'Wander')
end

local fishingVessels = {
	{dbid=2117, prefix='FT', category='Commercial',}, -- Commercial Factory Trawler [2,500t DWT] -- Commercial (Commercial)
	{dbid=1865, prefix='FV', category='Commercial',}, -- Commercial Fishing Boat [23m] -- Commercial (Commercial)
	{dbid=508, prefix='FV', category='Commercial',}, -- Commercial Fishing Boat [35m] -- Commercial (Commercial)
	{dbid=2118, prefix='FT', category='Commercial',}, -- Commercial Large Trawler [1,250t DWT] -- Commercial (Commercial)
	{dbid=2119, prefix='FT', category='Commercial',}, -- Commercial Trawler [800t DWT] -- Commercial (Commercial)
}

local AGIs = {
	507,	--SSV Lentra -- Soviet Union [-1991] (Naval Fleet [V-MF]), 1957
	505,	--SSV Mayak [Pr.502, ASW Mod] -- Soviet Union [-1991] (Naval Fleet [V-MF]), 1973-1991, 2x
	1928,	--SSV Mayak [Pr.502, Intelligence Mod] -- Soviet Union [-1991] (Naval Fleet [V-MF]), 1977-1991, 10x
	1929,	--SSV Mirnyy [Pr.393A] -- Soviet Union [-1991] (Naval Fleet [V-MF]), 1965-1991
	721,	--SSV Moma [Pr.861] -- Soviet Union [-1991] (Naval Fleet [V-MF]), 1968-1991
	1927,	--SSV Okean -- Soviet Union [-1991] (Naval Fleet [V-MF]), 1959-1991
	722,	--SSV Primorye [Pr.394B/994] -- Soviet Union [-1991] (Naval Fleet [V-MF]), 1970-1991
}

local numberOFCivFishingVessels = math.random(6,12)

for i = 1,numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1,#fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(68,71,-8,18)
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

local numberOfSovFishingVessels = math.random(6,9)

errorCount = 0

for i = 1,numberOfSovFishingVessels do
	local randomType = fishingVessels[math.random(1,#fishingVessels)].dbid

	::redoPositionSovFishingVessels::
	local position = RandomPosition(68,71,-8,18)
	local elevation = World_GetElevation(position)
	if elevation > -25 then 
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionSovFishingVessels
		else
			BugMessage('Game_Setup','Unable to place fishing vessel #'..i..' after 500 attempts!')
			break
		end
	end
	
	local unit = ScenEdit_AddUnit({
		side='Soviet Merchant Shipping',
		type='Ship',
		dbid=randomType,
		name='Fishing Vessel',
		lat=position.latitude,
		lon=position.longitude
	})

	ScenEdit_AssignUnitToMission(unit.guid, 'Snooping')
end

local numberOfSovAGIs = math.random(3,6)

errorCount = 0

for i = 1,numberOfSovAGIs do
	local randomType = AGIs[math.random(1,#AGIs)]

	::redoPositionAGIs::
	local position = RandomPosition(68,71,-8,18)
	local elevation = World_GetElevation(position)
	if elevation > -25 then 
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionAGIs
		else
			BugMessage('Game_Setup','Unable to place fishing vessel #'..i..' after 500 attempts!')
			break
		end
	end
	
	local unit = ScenEdit_AddUnit({
		side='Soviet Merchant Shipping',
		type='Ship',
		dbid=randomType,
		name='AGI',
		lat=position.latitude,
		lon=position.longitude
	})

	ScenEdit_AssignUnitToMission(unit.guid, 'Snooping')
end
