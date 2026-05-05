local theConvoy = ScenEdit_UnitX()

ScenEdit_DeleteUnit({guid=theConvoy.guid})

ScenEdit_SetEvent('US_SafeHouseSpotted',{isactive=true})

local theSafeHouse = ScenEdit_AddUnit({
    side='Terrorists',
    type='Facility',
    name='Safe House',
    dbid=452,
    autodetectable=false,
    latitude='0.112444559090065', 
    longitude='42.5524090896895'
})

local numberOfAAA = math.random(2,3)
local numberOfInfantry = math.random(3,4)
local numberOfTechnicals = math.random(1,2)
local numberOfAAATechnicals = math.random(1,2)
local dbidAAA, dbidInfantry, dbidTechnical, dbidAAATechnical = 2658, 625, 1981, 2738
local maxRadiusFromHouse = 1

for i = 1,numberOfAAA do
    randomPos = CircularRandomPosition(theSafeHouse.latitude, theSafeHouse.longitude, maxRadiusFromHouse)
    ScenEdit_AddUnit({
        side='Terrorists',
        type='Facility',
        name='Terrorist AAA #'..i,
        dbid=dbidAAA,
        autodetectable=false,
        latitude=randomPos.latitude, 
        longitude=randomPos.longitude
    })
end

for i = 1,numberOfInfantry do
    randomPos = CircularRandomPosition(theSafeHouse.latitude, theSafeHouse.longitude, maxRadiusFromHouse)
    ScenEdit_AddUnit({
        side='Terrorists',
        type='Facility',
        name='Terrorist Infantry #'..i,
        dbid=dbidInfantry,
        autodetectable=false,
        latitude=randomPos.latitude, 
        longitude=randomPos.longitude
    })
end

for i = 1,numberOfTechnicals do
    randomPos = CircularRandomPosition(theSafeHouse.latitude, theSafeHouse.longitude, maxRadiusFromHouse)
    ScenEdit_AddUnit({
        side='Terrorists',
        type='Facility',
        name='Terrorist Technical #'..i,
        dbid=dbidTechnical,
        autodetectable=false,
        latitude=randomPos.latitude, 
        longitude=randomPos.longitude
    })
end

for i = 1,numberOfAAATechnicals do
    randomPos = CircularRandomPosition(theSafeHouse.latitude, theSafeHouse.longitude, maxRadiusFromHouse)
    ScenEdit_AddUnit({
        side='Terrorists',
        type='Facility',
        name='Terrorist AAA Technical #'..i,
        dbid=dbidAAATechnical,
        autodetectable=false,
        latitude=randomPos.latitude, 
        longitude=randomPos.longitude
    })
end