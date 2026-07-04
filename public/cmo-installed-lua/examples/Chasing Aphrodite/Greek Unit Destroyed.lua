local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local UnitList = {
		[2122] = {name='F-4E Phantom II', points=20, destroyedString='destroyed'},
		[3516] = {name='F-16DJ Blk 52+ Falcon [Peace Xenia III]', points=20, destroyedString='destroyed'},
		[3512] = {name='F-16DJ Blk 52+ Advanced Falcon [Peace Xenia IV]', points=20, destroyedString='destroyed'},
		[3934] = {name='Mirage 2000EG-S3', points=20, destroyedString='destroyed'},
		[1116] = {name='Mirage 2000-5EG Mk2', points=20, destroyedString='destroyed'},
		[919] = {name='EMB-145H AEWC', points=100, destroyedString='destroyed'},
		[1686] = {name='Heron UAV [Shoval]', points=10, destroyedString='destroyed'},
		[4320] = {name='Pegasus II UAV', points=10, destroyedString='destroyed'},
		[4357] = {name='P-3B Orion TAC/NAV MOD', points=100, destroyedString='destroyed'},
		[791] = {name='P-3B Orion TAC/NAV MOD', points=100, destroyedString='destroyed'},
		[3716] = {name='Mi-35P Hind', points=20, destroyedString='destroyed'},
		[2003] = {name='S-70B-6 Aegean Hawk', points=20, destroyedString='destroyed'},

		[407] = {name='F 450 Elli [Kortenaer Batch II]', points=100, destroyedString='sunk'},

		[146] = {name='S 116 Poseidon [Type 209-1200]', points=70, destroyedString='sunk'},
		[317] = {name='S 120 Papanikolis [Type 214HN]', points=70, destroyedString='sunk'},

		[35] = {name='Runway (3200m)', points=70, destroyedString='destroyed'},
		[1422] = {name='Runway-Grade Taxiway (3200m)', points=70, destroyedString='destroyed'},
		[353] = {name='Runway Access Point (Very Large Aircraft)', points=70, destroyedString='destroyed'},
		[27] = {name='A/C Hardened Aircraft Shelter (1x Large Aircraft)', points=70, destroyedString='destroyed'},
		[68] = {name='A/C Hangar (2x Medium Aircraft)', points=70, destroyedString='destroyed'},
		[92] = {name='A/C Hangar (2x Very Large Aircraft)', points=70, destroyedString='destroyed'},
		[217] = {name='A/C Tarmac Space (2x Large Aircraft)', points=70, destroyedString='destroyed'},
		[322] = {name='Ammo Bunker (Surface)', points=70, destroyedString='destroyed'},
		[1392] = {name='AvGas (100k Liter Underground Tank)', points=70, destroyedString='destroyed'},
		[427] = {name='Building (Airport Terminal)', points=70, destroyedString='destroyed'},
		[3] = {name='Building (Control Tower)', points=70, destroyedString='destroyed'},
		[431] = {name='Radar (AN/TPS-43F)', points=20, destroyedString='destroyed'},
		[2169] = {name='Radar (Big Bird C [64N6])', points=20, destroyedString='destroyed'},
		[918] = {name='Radar (HR-3000 RSRP)', points=20, destroyedString='destroyed'},
		[434] = {name='Radar (MPDR-90)', points=20, destroyedString='destroyed'},
		[983] = {name='Radar (RAT-31DL)', points=20, destroyedString='destroyed'},
		[369] = {name='Radar (S-743D Martello)', points=20, destroyedString='destroyed'},
		[977] = {name='Radar (Score)', points=20, destroyedString='destroyed'},
		[2166] = {name='Radar (Snow Drift [9S18M1])', points=20, destroyedString='destroyed'},
		[957] = {name='Radar (THD-1955 MPR)', points=20, destroyedString='destroyed'},
		[392] = {name='SAM Bn (SA-20a Gargoyle [S-300PM-1])', points=100, destroyedString='destroyed'},
		[377] = {name='SAM Bty (Patriot [PAC-2 GEM])', points=100, destroyedString='destroyed'},
		[2160] = {name='SAM Plt (SA-15b Gauntlet [9K330 Tor-M1])', points=50, destroyedString='destroyed'},
		[2164] = {name='SAM Plt (SA-17 Grizzly [9K317E Buk-M2E])', points=50, destroyedString='destroyed'},
		[1115] = {name='SAM Plt (Skyguard [Aspide, 35mm Oerlikon])', points=50, destroyedString='destroyed'},
		[1650] = {name='SAM Plt (Skyguard [Sparrow, 35mm Oerlikon])', points=50, destroyedString='destroyed'},
		[365] = {name='SSM Bty (MM.40 Exocet)', points=50, destroyedString='destroyed'},
		[1592] = {name='Single-Unit Airfield (1x 3201-4000m Runway)', points=0, destroyedString='destroyed'},
		[1714] = {name='Single-Unit Airfield (2x 2601-3200m Runways)', points=0, destroyedString='destroyed'},
	}

	if UnitList[theDestroyedUnit.dbid] then
		local matchData = UnitList[theDestroyedUnit.dbid]
		ChangeScore('Greece', matchData.points * -1, 'Greek '..matchData.name..' '..matchData.destroyedString..'.')
	else
		BugMessage('Greek Unit Destroyed', 'Could not find match for destroyed unit '..theDestroyedUnit.classname..', dbid '..theDestroyedUnit.dbid)
	end
end