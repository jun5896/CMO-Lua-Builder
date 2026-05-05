local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=1211, points=25, name='MiG-17F Fresco C', destroyedString='destroyed'},--MiG-17F Fresco C

        {type='Facility', dbid=100, points=0, name='Marker (City)', destroyedString='destroyed'},--Marker (City)
        {type='Facility', dbid=1093, points=500, name='Arty Bty (130mm/52 M-46 M1954 Towed Howitzer x 6)', destroyedString='destroyed'},--Arty Bty (130mm/52 M-46 M1954 Towed Howitzer x 6)
        {type='Facility', dbid=116, points=0, name='A/C Tarmac Space (4x Medium Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (4x Medium Aircraft)
        {type='Facility', dbid=120, points=500, name='Building (Control Tower)', destroyedString='destroyed'},--Building (Control Tower)
        {type='Facility', dbid=1310, points=50, name='Armored Plt (T-54 MBT)', destroyedString='destroyed'},--Armored Plt (T-54 MBT)
        {type='Facility', dbid=214, points=500, name='A/C Hangar (4x Medium Aircraft)', destroyedString='destroyed'},--A/C Hangar (4x Medium Aircraft)
        {type='Facility', dbid=221, points=500, name='Ammo Bunker (Surface)', destroyedString='destroyed'},--Ammo Bunker (Surface)
        {type='Facility', dbid=222, points=500, name='AAA Bty (37mm Type 65 Twin x 4)', destroyedString='destroyed'},--AAA Bty (37mm Type 65 Twin x 4)
        {type='Facility', dbid=224, points=500, name='Pill Box (12.7mm)', destroyedString='destroyed'},--Pill Box (12.7mm)
        {type='Facility', dbid=233, points=500, name='Vehicle (Truck Depot, 40x Vehicles)', destroyedString='destroyed'},--Vehicle (Truck Depot, 40x Vehicles)
        {type='Facility', dbid=239, points=500, name='Building (Very Large)', destroyedString='destroyed'},--Building (Very Large)
        {type='Facility', dbid=293, points=0, name='Runway (2000m)', destroyedString='destroyed'},--Runway (2000m)
        {type='Facility', dbid=37, points=500, name='Diesel (40k Liter Tank)', destroyedString='destroyed'},--Diesel (40k Liter Tank)
        {type='Facility', dbid=389, points=500, name='Building (Barracks)', destroyedString='destroyed'},--Building (Barracks)
        {type='Facility', dbid=414, points=0, name='Runway Access Point (Large Aircraft)', destroyedString='destroyed'},--Runway Access Point (Large Aircraft)
        {type='Facility', dbid=418, points=500, name='AvGas (750k Liter Underground Tank)', destroyedString='destroyed'},--AvGas (750k Liter Underground Tank)
        {type='Facility', dbid=450, points=500, name='Building (Guard post)', destroyedString='destroyed'},--Building (Guard post)
        {type='Facility', dbid=483, points=500, name='Radar (Generic Surface Search Radar)', destroyedString='destroyed'},--Radar (Generic Surface Search Radar)
        {type='Facility', dbid=638, points=500, name='AAA Bty (37mm T65 Twin x 4)', destroyedString='destroyed'},--AAA Bty (37mm T65 Twin x 4)

        {type='Ship', dbid=2160, points=50, name='Type 55A Shantou/Swatow', destroyedString='sunk'},--Type 55A Shantou/Swatow
        {type='Ship', dbid=784, points=50, name='TK P-4 [Pr.123K]', destroyedString='sunk'},--TK P-4 [Pr.123K]

        {type='Ship', dbid=1927, points=10000, name='SSV Okean', destroyedString='sunk'},--SSV Okean
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('RedFor_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        if theDestroyedUnit.side ~= 'USSR' then
            ChangeScore('USN',matchData.points,'A '..theDestroyedUnit.side.. ' '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
        else
            ChangeScore('USN',matchData.points*-1,'A Soviet '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'! Are you trying to start WW3?!')
        end
    end
end