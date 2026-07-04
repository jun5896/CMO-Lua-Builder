local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1076, points=25, name='Vampire FB. Mk52', destroyedString='shot down'},--Vampire FB. Mk52
        {type='Aircraft', dbid=1077, points=25, name='Hunter F.6', destroyedString='shot down'},--Hunter F.6
        {type='Aircraft', dbid=1079, points=25, name='IL-14 Crate', destroyedString='shot down'},--IL-14 Crate
        {type='Aircraft', dbid=1080, points=50, name='Il-28 Beagle', destroyedString='shot down'},--Il-28 Beagle
        {type='Aircraft', dbid=1089, points=25, name='Mi-4M Hound B', destroyedString='shot down'},--Mi-4M Hound B
        {type='Aircraft', dbid=475, points=25, name='Venom FB.Mk50', destroyedString='shot down'},--Venom FB.Mk50

        {type='Facility', dbid=100, points=25, name='Marker (City)', destroyedString=nil},--Marker (City)
        {type='Facility', dbid=101, points=25, name='A/C Camouflaged Parking Spot (1x Large Aircraft)', destroyedString=nil},--A/C Camouflaged Parking Spot (1x Large Aircraft)
        {type='Facility', dbid=116, points=25, name='A/C Tarmac Space (4x Medium Aircraft)', destroyedString=nil},--A/C Tarmac Space (4x Medium Aircraft)
        {type='Facility', dbid=120, points=25, name='Building (Control Tower)', destroyedString=nil},--Building (Control Tower)
        {type='Facility', dbid=1418, points=25, name='AAA Bty (57mm M1950 x 4)', destroyedString=nil},--AAA Bty (57mm M1950 x 4)
        {type='Facility', dbid=1582, points=25, name='AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)', destroyedString=nil},--AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)
        {type='Facility', dbid=206, points=75, name='Armored Plt (SU-100 SPG)', destroyedString=nil},--Armored Plt (SU-100 SPG)
        {type='Facility', dbid=211, points=75, name='Armored Plt (T-55 MBT x 4)', destroyedString=nil},--Armored Plt (T-55 MBT x 4)
        {type='Facility', dbid=214, points=25, name='A/C Hangar (4x Medium Aircraft)', destroyedString=nil},--A/C Hangar (4x Medium Aircraft)
        {type='Facility', dbid=217, points=25, name='AAA Bty (100mm KS-19 x 4)', destroyedString=nil},--AAA Bty (100mm KS-19 x 4)
        {type='Facility', dbid=221, points=25, name='Ammo Bunker (Surface)', destroyedString=nil},--Ammo Bunker (Surface)
        {type='Facility', dbid=293, points=25, name='Runway (2000m)', destroyedString=nil},--Runway (2000m)
        {type='Facility', dbid=309, points=25, name='Runway (2600m)', destroyedString=nil},--Runway (2600m)
        {type='Facility', dbid=34, points=25, name='AvGas (750k Liter Tank)', destroyedString=nil},--AvGas (750k Liter Tank)
        {type='Facility', dbid=350, points=25, name='Runway Access Point (Medium Aircraft)', destroyedString=nil},--Runway Access Point (Medium Aircraft)
        {type='Facility', dbid=38, points=25, name='Diesel (750k Liter Tank)', destroyedString=nil},--Diesel (750k Liter Tank)
        {type='Facility', dbid=396, points=25, name='Ammo Revetment', destroyedString=nil},--Ammo Revetment
        {type='Facility', dbid=400, points=25, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString=nil},--Single-Unit Airfield (1x 2001-2600m Runway)
        {type='Facility', dbid=435, points=25, name='A/C Hangar (2x Very Large Aircraft)', destroyedString=nil},--A/C Hangar (2x Very Large Aircraft)
        {type='Facility', dbid=443, points=25, name='A/C Tarmac Space (2x Very Large Aircraft)', destroyedString=nil},--A/C Tarmac Space (2x Very Large Aircraft)
        {type='Facility', dbid=45, points=25, name='AvGas (150k Liter Tank)', destroyedString=nil},--AvGas (150k Liter Tank)
        {type='Facility', dbid=451, points=25, name='Runway Access Point (Very Large Aircraft)', destroyedString=nil},--Runway Access Point (Very Large Aircraft)
        {type='Facility', dbid=59, points=25, name='Structure (Pier [Extra Large, 200-500m])', destroyedString=nil},--Structure (Pier [Extra Large, 200-500m])
        {type='Facility', dbid=66, points=25, name='Radar', destroyedString=nil},--Radar (Token)

        {type='Ship', dbid=635, points=25, name='TK P-6 [Pr.183]', destroyedString='sunk'},--TK P-6 [Pr.183]
    }


	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Iraq_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
    else
        if matchData.type ~= 'Facility' then
            local description = string.lower(matchData.type)
            ChangeScore('United Kingdom',matchData.points,'An Iraqi '..description..' was '..matchData.destroyedString..'.')
        else
            ChangeScore('United Kingdom',matchData.points,'An Iraqi '..theDestroyedUnit.classname..' was destroyed.')
        end
    end
end