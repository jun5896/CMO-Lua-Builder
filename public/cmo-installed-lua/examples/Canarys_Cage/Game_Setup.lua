math.randomseed(os.time())

--Set weather
WeatherDrift()

if DebugModeIsOn() then
	WeatherReport('WEATHER INITIALISED')
end

local function RandomPosition(latitudeMin,latitudeMax,longitudeMin,longitudeMax)
	local lat_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local lon_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local pos_lat = math.random(latitudeMin,latitudeMax) + (lat_var/(10^13)) --latitude; 
	local pos_lon = math.random(longitudeMin,longitudeMax) + (lon_var/(10^13)) --longitude; 
	return {latitude=pos_lat,longitude=pos_lon}
end

--Randomly place false contacts
local falseContactDBIDs = {
	95, --Large
	94, --Medium
	93, --Small
	653, --Magnetic
	654, --Magnetic and acoustic
}

local falseQty =  math.random(24,32)

for i = 1,falseQty do
	::redoPositionFalse::
	local position = RandomPosition(28,36,-17,-6)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -10 or pos_elev < -500 then goto redoPositionFalse end
	local randomType = math.random(1,3)
	ScenEdit_AddUnit({side='Nature',type='Submarine',dbid=False_DBIDs[randomType],name='False Contact '..i,lat=position.latitude,lon=position.longitude})
end

--Randomly place biologicals; 60% fish, 20% Orca, 20% Whale
local Biol_DBIDs = {
	354, --Fish
	354, --Orcas
	92 --Whale
}

local biolQty = math.random(24,32)

for i = 1,biolQty do
	if i <= biolQty * 0.6 then
		randomType = Biol_DBIDs[1]
	elseif i <= biolQty * 0.8 then
		randomType = Biol_DBIDs[2]
	else
		randomType = Biol_DBIDs[3]
	end
	::redoPositionBiologics::
	local position = RandomPosition(28,36,-17,-6)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -25 then goto redoPositionBiologics end
	
	local unit = ScenEdit_AddUnit({side='Nature',type='Submarine',dbid=randomType,name='Biol Contact '..i,lat=position.latitude,lon=position.longitude})
	ScenEdit_AssignUnitToMission(unit.name, 'Wander')
end

--Civilian Shipping & Air Traffic
ScenEdit_RunScript('/Canarys_Cage/CivilianShipping.lua')
ScenEdit_RunScript('/Canarys_Cage/CivilianAirTraffic.lua')

--Randomise NAIL sub and missile boat positions
local unitList = {
	{name='831', guid='cd04a37a-58c1-4c6c-9cb6-bac9223e9ce5'} , 
	{name='012 Rais Hadj Mubarek ', guid='637b7b06-f0e2-4408-b1b1-6078a7dffd17'} , 
	{name='S 311 Al Badr', guid='f35e7d7d-3740-45d0-89ba-c63314916bb1'} , 
	{name='852', guid='f88b4544-6f5b-4802-8cf3-e38bb881ab22'} , 
	{name='849', guid='41897ece-a706-46a6-b2a7-670034712137'} , 
	{name='011 El Hadi Slimane', guid='868cbb27-7937-47c5-a234-69b3e0a9d446'} , 
	{name='852', guid='eacf3515-008d-4aa0-9309-810689acf6b3'},
	{name='561 Ramadan', guid='7c1ae131-0514-4b62-b757-e98c8c38a0bf'} , 
	{name='562 Khyber', guid='590b7785-c133-42fb-bc87-db19e0050bdb'} , 
	{name='566 Badr', guid='e5926ece-ff6b-4ca5-86d2-0f2b044bfc24'} , 
	{name='563 El Kadesseya', guid='504f744f-c7de-42b6-bbe9-92bcc26d447c'}
}

for k,v in ipairs (unitList) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local newPos = CircularRandomPosition(unit.latitude,unit.longitude,75)
	if OverWater(newPos.latitude, newPos.longitude) then
		ScenEdit_SetUnit({guid=unit.guid,
			latitude=newPos.latitude,
			longitude=newPos.longitude})
	end
end

--Add randomised tattle-tales
local tattleTable = {
	16, --Commercial fishing boat 23m
	1787, --Dhow 15m
	1788 --Dhow 22m
}

local tattleQty =  math.random(2,9)

for i = 1,tattleQty do
	::redoPositionTattle::
	local position = RandomPosition(30,35,-15,-10)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -10 then goto redoPositionTattle end
	local randomType = math.random(1,3)
	local unit = ScenEdit_AddUnit({side='Neutral',type='Ship',dbid=tattleTable[randomType],name='Unidentifed Vessel #'..i,lat=position.latitude,lon=position.longitude})
	
	ScenEdit_AssignUnitToMission(unit.name, 'Wander')
end

--Set the course for the amphib group
local amphibCourses = {
	{ --along the coast
		[1] = { longitude = -10.4612889030506, latitude = 31.3472550751022, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[2] = { longitude = -11.5954945842185, latitude = 29.8845648236757, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[3] = { longitude = -13.90880589784, latitude = 29.6147640580066, TypeOf = 'ManualPlottedCourseWaypoint' },
		[4] = { longitude = -15.7457378212443, latitude = 28.59261128783, TypeOf = 'ManualPlottedCourseWaypoint' },
	},
	{ --zig-zag
		[1] = { longitude = -11.0352048331881, latitude = 31.7910855040847, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[2] = { longitude = -12.1039363460622, latitude = 31.936257278026, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[3] = { longitude = -12.6841360968071, latitude = 31.0247936731092, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[4] = { longitude = -13.8962356581637, latitude = 31.1449110327042, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[5] = { longitude = -13.9495114451645, latitude = 30.1476333053443, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[6] = { longitude = -15.7576005876196, latitude = 29.3168369506125, TypeOf = 'ManualPlottedCourseWaypoint' },
	},
	{ --straight in
		[1] = { longitude = -11.2463001530133, latitude = 32.1339452672464, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[2] = { longitude = -13.4859406723215, latitude = 31.5370267730227, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[3] = { longitude = -14.7147611433607, latitude = 30.232510138178, TypeOf = 'ManualPlottedCourseWaypoint' }, 
		[4] = { longitude = -15.756998436021, latitude = 28.5758954662111, TypeOf = 'ManualPlottedCourseWaypoint' } 
	}
}

ScenEdit_SetUnit({name='Amphib Group', guid='70ad503e-ebb5-4bf9-9f83-48b359f48efa',course=amphibCourses[math.random(1,#amphibCourses)]})

--Randomise NAIL submarine patrol zones
--[[ Removed from this version -- too hard basket
local rpTable = {}
for i = 1, 7 do
	local rp = ScenEdit_GetReferencePoint({side='NAIL',
		name='Submarine PZ '..i})
	table.insert(rpTable,rp)
end

local function CreateListOfNAILSubs()
	local result, sideUnits = {}, VP_GetSide({side='NAIL'}).units
	for k,v in ipairs (sideUnits)
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.type == 'Submarine' then table.insert(result,unit) end
	end
	return result
end

local function CreateListOfUnassignedSubs()
	local subTable = CreateListOfNAILSubs()
	local result, n = {}, 0
	for k,v in ipairs (subTable) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit ~= nil and unit.mission == nil then
            n = n + 1
			result[n]= unit.guid
		end
	end
	return result
end

--central point jitter
for k,v in ipairs (rpTable) do
	local newPos = CircularRandomPosition(v.latitude,v.longitude,50)
	if OverWater(newPos.latitude,newPos.longitude) then
		ScenEdit_SetReferencePoint({
			guid=v.guid,
			latitude=newPos.latitude,
			longitude=newPos.longitude})
	end
end



--local subTable = CreateListOfUnassignedSubs()

-- COMMENTED OUT BECAUSE ITS JUST A FUCKING MESS AT THIS POINT
local subTable = {
	{name='831', guid='cd04a37a-58c1-4c6c-9cb6-bac9223e9ce5'} , 
	{name='012 Rais Hadj Mubarek ', guid='637b7b06-f0e2-4408-b1b1-6078a7dffd17'} , 
	{name='S 311 Al Badr', guid='f35e7d7d-3740-45d0-89ba-c63314916bb1'} , 
	{name='852', guid='f88b4544-6f5b-4802-8cf3-e38bb881ab22'} , 
	{name='849', guid='41897ece-a706-46a6-b2a7-670034712137'} , 
	{name='011 El Hadi Slimane', guid='868cbb27-7937-47c5-a234-69b3e0a9d446'} , 
	{name='852', guid='eacf3515-008d-4aa0-9309-810689acf6b3'},
}




local rp = rpTable[1] --example

for k,v in ipairs(subTable) do
unit = ScenEdit_GetUnit({guid=v.guid})
	if unit ~= nil and unit.mission == nil then 
		v.range = Tool_Range(v.guid,rp.guid)
	else
        v.range = 99999
	end		
end

print (subTable)

local function CreateListOfUnassignedSubs()
	local result, n = {}, 0
	for k,v in ipairs (subTable) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit ~= nil and unit.mission == nil then
            n = n + 1
			result[n]= unit.guid
		end
	end
	return result
end



--for each reference point
for k,v in ipairs (rpTable) do
    local subList = CreateListOfUnassignedSubs()
	local closestUnit = ReturnClosestUnassignedSub(v.guid)
	print (closestUnit.name..' is the closest unit at '..closestUnit.range..' from '..v.name)
	--CreateMissionAndAssignClosestSub(unassignedSubList[1].guid,v.guid)
end
--create a table of unassigned subs
--assign the closest sub
--then move on to the next reference point
]]