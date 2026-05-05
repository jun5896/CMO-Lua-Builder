local theShip = ScenEdit_UnitX()

if not HostilitiesHaveCommenced() then
    local backWhereYouCameFrom = Round((theShip.heading+180)%360)
    local theMessage = 'American vessel in position '..ConvertDecimalPositionToDegrees(theShip.latitude,theShip.longitude)..' you are in direct violation of international law. Alter course 180 degrees to heading '..backWhereYouCameFrom..' and leave the area immediately.'
    local theMessage = GenerateRadioMessageBody(theMessage,'unknown station')
    RadioMessage('VHF','121.5 MHz',theMessage,{latitude=theShip.latitude,longitude=theShip.longitude})
end

math.randomseed(os.time())
local swarmQuantity = math.random(8,12)
local swarmShips = {type='Ship',dbid=330,name='Toragh 21'} --Toragh [Boghammar Mod]
local origin = {latitude='26.4784362364463', longitude='57.0292593955296'}

for i = 1, swarmQuantity do
    local unit = ScenEdit_AddUnit({
        side='Iran',
        name='Boghammar '..i,
        type='Ship',
        dbid=swarmShips.dbid,
        latitude=origin.latitude,
        longitude=origin.longitude
    })
    ScenEdit_AssignUnitToMission(unit.guid,'Boghammar Swarm')
end