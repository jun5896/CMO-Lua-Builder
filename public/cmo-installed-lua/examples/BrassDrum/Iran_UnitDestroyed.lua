local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1010, points=100, name='Su-24M Fencer D', destroyedString='destroyed'},--Su-24M Fencer D
        {type='Aircraft', dbid=1309, points=50, name='F-4E Phantom II', destroyedString='destroyed'},--F-4E Phantom II
        {type='Aircraft', dbid=1312, points=100, name='F-14A Tomcat [F-14AM]', destroyedString='destroyed'},--F-14A Tomcat [F-14AM]
        {type='Aircraft', dbid=1313, points=150, name='P-3F Orion', destroyedString='destroyed'},--P-3F Orion
        {type='Aircraft', dbid=1346, points=100, name='MiG-29 Fulcrum A', destroyedString='destroyed'},--MiG-29 Fulcrum A
        {type='Aircraft', dbid=1851, points=150, name='Il-38N May', destroyedString='destroyed'},--Il-38N May
        {type='Aircraft', dbid=2423, points=200, name='Boeing 707-3J9C Boom/Drogue Tanker', destroyedString='destroyed'},--Boeing 707-3J9C Boom/Drogue Tanker
        {type='Aircraft', dbid=2474, points=20, name='J-7IIH Fishbed [MiG-21 Copy]', destroyedString='destroyed'},--J-7IIH Fishbed [MiG-21 Copy]
        {type='Aircraft', dbid=371, points=25, name='Ka-27PL Helix A', destroyedString='destroyed'},--Ka-27PL Helix A
        {type='Aircraft', dbid=715, points=100, name='J-10A Vigorous Dragon', destroyedString='destroyed'},--J-10A Vigorous Dragon

        {type='Facility', dbid=1047, points=50, name='Radar (AN/TPS-70)', destroyedString='destroyed'},--Radar (AN/TPS-70)
        {type='Facility', dbid=1227, points=50, name='Radar (China JY-14 Great Wall)', destroyedString='destroyed'},--Radar (China JY-14 Great Wall)
        {type='Facility', dbid=1254, points=100, name='SAM Plt (SA-13 Gopher [9K35 Strela-10])', destroyedString='destroyed'},--SAM Plt (SA-13 Gopher [9K35 Strela-10])
        {type='Facility', dbid=1385, points=10, name='A/C Weather Shelter (1x Medium Aircraft)', destroyedString='destroyed'},--A/C Weather Shelter (1x Medium Aircraft)
        {type='Facility', dbid=1388, points=0, name='A/C Open Parking Spot (1x Large Aircraft)', destroyedString='destroyed'},--A/C Open Parking Spot (1x Large Aircraft)
        {type='Facility', dbid=1426, points=100, name='Ammo Shelter', destroyedString='destroyed'},--Ammo Shelter
        {type='Facility', dbid=1496, points=100, name='Ammo Pad', destroyedString='destroyed'},--Ammo Pad
        {type='Facility', dbid=1556, points=25, name='A/C Hangar (1x Very Large Aircraft)', destroyedString='destroyed'},--A/C Hangar (1x Very Large Aircraft)
        {type='Facility', dbid=177, points=250, name='Bunker (Sector Control Station)', destroyedString='destroyed'},--Bunker (Sector Control Station)
        {type='Facility', dbid=1813, points=200, name='SSM Bn (C-704 [Nasr])', destroyedString='destroyed'},--SSM Bn (C-704 [Nasr])
        {type='Facility', dbid=1815, points=100, name='AAA Bty (100mm KS-19 Auto [Sair] x 4, GFCR)', destroyedString='destroyed'},--AAA Bty (100mm KS-19 Auto [Sair] x 4, GFCR)
        {type='Facility', dbid=1878, points=100, name='AAA Bty (14.5mm/79 ZPU-4 Quad x 4)', destroyedString='destroyed'},--AAA Bty (14.5mm/79 ZPU-4 Quad x 4)
        {type='Facility', dbid=1995, points=0, name='Single-Unit Airfield (1x 4000m+ Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 4000m+ Runway)
        {type='Facility', dbid=217, points=0, name='A/C Tarmac Space (2x Large Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (2x Large Aircraft)
        {type='Facility', dbid=260, points=100, name='SAM Bn (SA-10a Grumble [S-300PT-1])', destroyedString='destroyed'},--SAM Bn (SA-10a Grumble [S-300PT-1])
        {type='Facility', dbid=27, points=25, name='A/C Hardened Aircraft Shelter (1x Large Aircraft)', destroyedString='destroyed'},--A/C Hardened Aircraft Shelter (1x Large Aircraft)
        {type='Facility', dbid=281, points=0, name='A/C Tarmac Space (2x Medium Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (2x Medium Aircraft)
        {type='Facility', dbid=3, points=0, name='Building (Control Tower)', destroyedString='destroyed'},--Building (Control Tower)
        {type='Facility', dbid=322, points=100, name='Ammo Bunker (Surface)', destroyedString='destroyed'},--Ammo Bunker (Surface)
        {type='Facility', dbid=34, points=25, name='AvGas (40k Liter Tank)', destroyedString='destroyed'},--AvGas (40k Liter Tank)
        {type='Facility', dbid=35, points=0, name='Runway (3200m)', destroyedString='destroyed'},--Runway (3200m)
        {type='Facility', dbid=353, points=0, name='Runway Access Point (Very Large Aircraft)', destroyedString='destroyed'},--Runway Access Point (Very Large Aircraft)
        {type='Facility', dbid=399, points=100, name='SAM Bn (SA-20a Gargoyle [S-300PM-1])', destroyedString='destroyed'},--SAM Bn (SA-20a Gargoyle [S-300PM-1])
        {type='Facility', dbid=41, points=25, name='A/C Hangar (2x Large Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Large Aircraft)
        {type='Facility', dbid=418, points=100, name='SAM Sec (SA-16 Gimlet [9K310 Igla-1] MANPADS x 3)', destroyedString='destroyed'},--SAM Sec (SA-16 Gimlet [9K310 Igla-1] MANPADS x 3)
        {type='Facility', dbid=419, points=50, name='Radar (Tin Shield A [5N59])', destroyedString='destroyed'},--Radar (Tin Shield A [5N59])
        {type='Facility', dbid=427, points=0, name='Building (Airport Terminal)', destroyedString='destroyed'},--Building (Airport Terminal)
        {type='Facility', dbid=430, points=0, name='Single-Unit Airfield (2x 3201-4000m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 3201-4000m Runways)
        {type='Facility', dbid=44, points=25, name='AvGas (75k Liter Tank)', destroyedString='destroyed'},--AvGas (75k Liter Tank)
        {type='Facility', dbid=547, points=100, name='SAM Plt (SA-11 Gadfly [9K37 Buk-M1])', destroyedString='destroyed'},--SAM Plt (SA-11 Gadfly [9K37 Buk-M1])
        {type='Facility', dbid=55, points=100, name='Runway (2600m)', destroyedString='destroyed'},--Runway (2600m)
        {type='Facility', dbid=556, points=100, name='SAM Plt (RBS 70 Mk1 MANPADS x 3)', destroyedString='destroyed'},--SAM Plt (RBS 70 Mk1 MANPADS x 3)
        {type='Facility', dbid=68, points=25, name='A/C Hangar (2x Medium Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Medium Aircraft)
        {type='Facility', dbid=757, points=100, name='Runway (4000m)', destroyedString='destroyed'},--Runway (4000m)
        {type='Facility', dbid=764, points=100, name='Vehicle (Mobile Jammer)', destroyedString='destroyed'},--Vehicle (Mobile Jammer)
        {type='Facility', dbid=84, points=25, name='AvGas (150k Liter Tank)', destroyedString='destroyed'},--AvGas (150k Liter Tank)
        {type='Facility', dbid=86, points=25, name='A/C Hangar (2x Small Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Small Aircraft)
        {type='Facility', dbid=901, points=100, name='SAM Bn (SA-6a Gainful [2K12E Kvadrat])', destroyedString='destroyed'},--SAM Bn (SA-6a Gainful [2K12E Kvadrat])
        {type='Facility', dbid=902, points=100, name='SAM Bn (HQ-2b)', destroyedString='destroyed'},--SAM Bn (HQ-2b)
        {type='Facility', dbid=904, points=100, name='SSM Bn (C-802)', destroyedString='destroyed'},--SSM Bn (C-802)
        {type='Facility', dbid=906, points=100, name='SAM Plt (HN-5A MANPADS x 4)', destroyedString='destroyed'},--SAM Plt (HN-5A MANPADS x 4)
        {type='Facility', dbid=909, points=100, name='AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)', destroyedString='destroyed'},--AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)
        {type='Facility', dbid=910, points=100, name='AAA Sec (35mm Twin Oerlikon x 2, Skyguard FCR)', destroyedString='destroyed'},--AAA Sec (35mm Twin Oerlikon x 2, Skyguard FCR)
        {type='Facility', dbid=911, points=100, name='AAA Plt/3 (23mm ZU-23-2 x 2)', destroyedString='destroyed'},--AAA Plt/3 (23mm ZU-23-2 x 2)
        {type='Facility', dbid=912, points=100, name='AAA Sec (35mm Twin Oerlikon x 2)', destroyedString='destroyed'},--AAA Sec (35mm Twin Oerlikon x 2)
        {type='Facility', dbid=943, points=25, name='AvGas (400k Liter Underground Tank)', destroyedString='destroyed'},--AvGas (400k Liter Underground Tank)

        {type='Ship', dbid=330, points=20, name='Toragh [Boghammar Mod]', destroyedString='sunk'},--Toragh [Boghammar Mod]
        {type='Ship', dbid=1198, points=350, name='P 313-1 Fath [Thondor Type 021 Houdong]', destroyedString='sunk'},--P 313-1 Fath [Thondor Type 021 Houdong]
        {type='Ship', dbid=2002, points=350, name='Type 022 Houbei', destroyedString='sunk'},--Type 022 Houbei

        {type='Submarine', dbid=313, points=500, name='901 Tareq [PL-877EKM Kilo]', destroyedString='sunk'},--901 Tareq [PL-877EKM Kilo]
        {type='Submarine', dbid=508, points=500, name='PL-636.3 Kilo [Varshavyanka]', destroyedString='sunk'},--PL-636.3 Kilo [Varshavyanka]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Iran_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('United States',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')

        ---War footing
        CommenceHostilities()

        ----------Sector control stations
        local airDefenceHQ = {name='Air Defence HQ', guid='d81ae11f-f1b1-406a-9eb6-13ee09f3b6fa'}
        local navalOpsHQ = {name='Naval Operations Command', guid='a3a0c7d8-6379-4a93-b581-f107b2b1509b'}

        if theDestroyedUnit.guid == navalOpsHQ.guid and not NavalHQMessageHasPlayed() then
            DisruptIranNavalComms()
            NavalHQMessageHasPlayed(true)
        end

        if theDestroyedUnit.guid == airDefenceHQ.guid and not IADSMessageHasPlayed() then
            DisruptIranIADSComms()
            IADSMessageHasPlayed(true)
        end
    end
end