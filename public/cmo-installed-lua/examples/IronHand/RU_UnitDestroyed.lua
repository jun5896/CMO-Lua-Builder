local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Aircraft', dbid=1336, points=500, name='Tu-22MR Backfire C', destroyedString='destroyed'},--Tu-22MR Backfire C
		{type='Aircraft', dbid=2017, points=150, name='MiG-29S Fulcrum C', destroyedString='destroyed'},--MiG-29S Fulcrum C
		{type='Aircraft', dbid=3820, points=200, name='Su-30M2 Flanker G', destroyedString='destroyed'},--Su-30M2 Flanker G
		{type='Aircraft', dbid=2371, points=150, name='Su-25SM Frogfoot A', destroyedString='destroyed'},--Su-25SM Frogfoot A
		{type='Aircraft', dbid=2376, points=500, name='Mi-26 Halo', destroyedString='destroyed'},--Mi-26 Halo
		{type='Aircraft', dbid=2379, points=200, name='Su-24MR Fencer E', destroyedString='destroyed'},--Su-24MR Fencer E
		{type='Aircraft', dbid=2687, points=500, name='Il-78M Midas', destroyedString='destroyed'},--Il-78M Midas
		{type='Aircraft', dbid=275, points=500, name='Su-34 Fullback', destroyedString='destroyed'},--Su-34 Fullback
		{type='Aircraft', dbid=2837, points=500, name='Tu-22M-3M Backfire C', destroyedString='destroyed'},--Tu-22M-3M Backfire C
		{type='Aircraft', dbid=357, points=500, name='Tu-160 Blackjack', destroyedString='destroyed'},--Tu-160 Blackjack
		{type='Aircraft', dbid=4568, points=250, name='Mi-8AMTSh Hip H', destroyedString='destroyed'},--Mi-8AMTSh Hip H
		{type='Aircraft', dbid=4607, points=500, name='Il-22PP Porubshchik', destroyedString='destroyed'},--Il-22PP Porubshchik
		{type='Aircraft', dbid=476, points=500, name='Su-24MP Fencer F', destroyedString='destroyed'},--Su-24MP Fencer F
		{type='Aircraft', dbid=520, points=500, name='Tu-95MSM Bear H', destroyedString='destroyed'},--Tu-95MSM Bear H
		{type='Aircraft', dbid=600, points=500, name='Su-24M2 Fencer D', destroyedString='destroyed'},--Su-24M2 Fencer D
		{type='Aircraft', dbid=711, points=500, name='A-50 Mainstay A', destroyedString='destroyed'},--A-50 Mainstay A
		{type='Facility', dbid=1487, points=0, name='SAM Bn (SA-10b Grumble [S-300PS])', destroyedString='destroyed'},--SAM Bn (SA-10b Grumble [S-300PS])
		{type='Facility', dbid=1592, points=0, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 3201-4000m Runway)
		{type='Facility', dbid=1626, points=0, name='Radar (Big Bird B [5N64S])', destroyedString='destroyed'},--Radar (Big Bird B [5N64S])
		{type='Facility', dbid=1628, points=0, name='Radar (Tin Shield B [5N59S/36D6])', destroyedString='destroyed'},--Radar (Tin Shield B [5N59S/36D6])
		{type='Facility', dbid=1712, points=0, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2001-2600m Runway)
		{type='Facility', dbid=1877, points=0, name='Single-Unit Airfield (1x 2600-3200m, Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2600-3200m, Runway)
		{type='Facility', dbid=249, points=0, name='SAM Bty (SA-4 Ganef [2K11 Krug])', destroyedString='destroyed'},--SAM Bty (SA-4 Ganef [2K11 Krug])
		{type='Facility', dbid=253, points=0, name='SAM Bn (SA-3c Goa [S-125M1 Neva-M])', destroyedString='destroyed'},--SAM Bn (SA-3c Goa [S-125M1 Neva-M])
		{type='Facility', dbid=254, points=0, name='SSM Bn (SS-26 Stone [9K720 Iskander-M] TEL)', destroyedString='destroyed'},--SSM Bn (SS-26 Stone [9K720 Iskander-M] TEL)
		{type='Facility', dbid=260, points=0, name='SAM Bn (SA-10a Grumble [S-300PT-1])', destroyedString='destroyed'},--SAM Bn (SA-10a Grumble [S-300PT-1])
		{type='Facility', dbid=265, points=0, name='Radar (Spoon Rest D [P-18])', destroyedString='destroyed'},--Radar (Spoon Rest D [P-18])
		{type='Facility', dbid=430, points=0, name='Single-Unit Airfield (2x 3201-4000m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 3201-4000m Runways)
		{type='Ship', dbid=2410, points=10000, name='MRK Buyan [Pr.21630 Buyan]', destroyedString='sunk?! How on earth did you manage that?!'},--MRK Buyan [Pr.21630 Buyan]
		{type='Ship', dbid=2411, points=10000, name='MRK Buyan Mod [Pr.21631 Buyan-M]', destroyedString='sunk?! How on earth did you manage that?!'},--MRK Buyan Mod [Pr.21631 Buyan-M]
		{type='Ship', dbid=2883, points=10000, name='SKR Gepard Mod [Pr.1166.1K]', destroyedString='sunk?! How on earth did you manage that?!'},--SKR Gepard Mod [Pr.1166.1K]
		{type='Submarine', dbid=508, points=10000, name='PL-636.3 Kilo [Varshavyanka]', destroyedString='sunk?! How on earth did you manage that?!'},--PL-636.3 Kilo [Varshavyanka]
	}


	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('RU_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('Russia',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
		if theDestroyedUnit.type == 'Aircraft' then
			GenerateSurvivors(theDestroyedUnit.latitude,theDestroyedUnit.longitude,theDestroyedUnit.name)
		end
	end
end