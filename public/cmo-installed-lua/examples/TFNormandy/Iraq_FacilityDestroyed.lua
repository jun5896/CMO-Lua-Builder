local destroyedUnit = ScenEdit_UnitX()

local unitList = {
    {dbid=6, points=50, destroyedString='Communications Bunker'},--Bunker (Comm Center)
    {dbid=45, points=10, destroyedString='Diesel Tank'},--Diesel (40k Liter Tank)
    {dbid=119, points=10, destroyedString='Generator'},--Structure (Generator)
    {dbid=177, points=50, destroyedString='Communications Bunker'},--Bunker (Sector Control Station)
    {dbid=364, points=10, destroyedString='Infantry Section'},--Inf Sec (Observation Post)
    {dbid=624, points=10, destroyedString='Truck Group'},--Vehicles (Truck x 4)
    {dbid=1698, points=10, destroyedString='Flat Face B Radar'},--Radar (Flat Face B [P-19])
    {dbid=1749, points=10, destroyedString='Tent Group'},--Building (Tents)
    {dbid=1830, points=200, destroyedString='Spoon Rest D Radar target'},--Radar (Spoon Rest D [P-18])
    {dbid=1833, points=15, destroyedString='ZSU-23-4 Shilka AAA Section'},--AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)
    {dbid=1835, points=15, destroyedString='SA-9b Gaskin SAM Platoon'},--SAM Plt (SA-9b Gaskin [9K31 Strela-1])
    {dbid=1878, points=15, destroyedString='14.5mm/79 ZPU-4 Quad AAA Battery'},--AAA Bty (14.5mm/79 ZPU-4 Quad x 4)
    {dbid=1879, points=15, destroyedString='SA-7b Grail SAM Section'},--SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)
    {dbid=1880, points=10, destroyedString='Squat Eye Radar'},--Radar (Squat Eye [P-15M(2)])
    {dbid=1882, points=10, destroyedString='Side Net HF Radar'},--Radar (Side Net HF [PRV-11])
    {dbid=1883, points=15, destroyedString='SA-14 Gremlin SAM Section'},--SAM Sec (SA-14 Gremlin [9K34 Strela-3] MANPADS x 3)
    {dbid=1886, points=15, destroyedString='37mm M1939 AAA Battery'},--AAA Bty (37mm M1939 x 6)
    {dbid=1887, points=15, destroyedString='23mm ZU-23-2 AAA Section'},--AAA Plt/3 (23mm ZU-23-2 x 2)
    {dbid=2553, points=15, destroyedString='ELINT Vehicle'},--Vehicle (ELINT [Average])
    {dbid=2554, points=15, destroyedString='ELINT Vehicle'},--Vehicle (ELINT [Simple])
}

local matchedData = nil

for k,v in ipairs (unitList) do
    if destroyedUnit.dbid == v.dbid then
        matchedData = v
    end
end

if matchedData == nil then
    BugMessage('Iraq_FacilityDestroyed','Unable to match destroyed unit')
else
    ChangeScore('playerside',matchedData.points,'An Iraqi '..matchedData.destroyedString..' was destroyed.')
end