math.randomseed(os.time())

--Set weather
WeatherDrift()

if DebugModeIsOn() then
	WeatherReport('WEATHER INITIALISED')
end

--Randomly place and assign Iranian aircraft
local enemyFlights = {
	{name='Panther', dbid=1153, loadoutid=4691, qty=2},
	{name='Jaguar', dbid=1153, loadoutid=4691, qty=2},
	{name='Ghost', dbid=1308, loadoutid=332, qty=2},
	{name='Wraith', dbid=229, loadoutid=2173, qty=2},
}

local enemyAirbases = {
	{name='Shiraz Air Base', guid='41c558b8-c988-4cb6-8cab-0593f68c6636', mission='Shiraz Intercept'}, 
	{name='Busheur Air Base', guid='d71e9f85-ce5c-43c0-8436-9d3150595e85', mission='Busheur Intercept'}, 
	{name='Omidiyeh Air Base', guid='474dcbea-7484-41bd-be24-45bfb94651b2', mission='Omidiyeh Intercept'}
}

local function RandomiseFlightsToBases()
    for k,v in ipairs(enemyFlights) do
        local flightBase = enemyAirbases[math.random(1,#enemyAirbases)]
        for i = 1,v.qty do
            local unit = ScenEdit_AddUnit({
                side='Iran',
                name=v.name..' #'..i,
                type='Aircraft',
                dbid=v.dbid,
                base=flightBase.guid,
                loadoutid=v.loadoutid
			})
			ScenEdit_AssignUnitToMission(unit.name,flightBase.mission)
        end
    end
end

RandomiseFlightsToBases()

--Randomise position of frigate
local frigate = ScenEdit_GetUnit({name='F 73 Sabalan', guid='665e4981-eb09-4d33-a078-2db72598620b'})

local frigatePlacementAttempt = 0
::redoFrigatePlacement::
local newFrigatePosition = CircularRandomPosition(frigate.latitude, frigate.longitude, 20)
if not OverWater(newFrigatePosition.latitude,newFrigatePosition.longitude) then
	if frigatePlacementAttempt <= 50 then
		frigatePlacementAttempt = frigatePlacementAttempt + 1
		goto redoFrigatePlacement
    end
else
    ScenEdit_SetUnit({
        guid=frigate.guid,
        latitude=newFrigatePosition.latitude,
        longitude=newFrigatePosition.longitude
    })
end

--Randomise proficiency
RandomiseSideUnitProficiency('Iraq')
RandomiseSideUnitProficiency('Iran')

--Randomly place dhows and fishing vessels
local Civ_DBIDs = {
	1788,
	1787,
	16
}

local civQty = math.random(8,12)

for i = 1,civQty do
	if i <= civQty * 0.6 then
		randomType = Civ_DBIDs[1]
	elseif i <= civQty * 0.8 then
		randomType = Civ_DBIDs[2]
	else
		randomType = Civ_DBIDs[3]
	end
	::redoPositionCivilianVessel::
	local position = RandomPosition(28,30,48,51)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -10 then goto redoPositionCivilianVessel end
	
	local unit = ScenEdit_AddUnit({side='Civilian',type='Ship',dbid=randomType,name='Civilian Vessel '..i,lat=position.latitude,lon=position.longitude})
    ScenEdit_AssignUnitToMission(unit.name, 'Wander')
end