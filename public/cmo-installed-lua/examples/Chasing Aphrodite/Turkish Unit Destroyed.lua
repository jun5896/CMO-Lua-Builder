local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local UnitList = {
		[4242] = {type='Aircraft', name='F-16DM Blk 40 Falcon [Peace Onyx III CCIP Upgr]', points=20, destroyedString='destroyed'},
		[4244] = {type='Aircraft', name='F-16DM Blk 50 Falcon [Peace Onyx III CCIP Upgr]', points=20, destroyedString='destroyed'},
		[3557] = {type='Aircraft', name='F-16DJ Blk 50 Falcon [Peace Onyx IV]', points=20, destroyedString='destroyed'},
		[3218] = {type='Aircraft', name='E-7A Peace Eagle [Wedgetail]', points=100, destroyedString='destroyed'},
		[1853] = {type='Aircraft', name='KC-135R Stratotanker', points=100, destroyedString='destroyed'},
		[2597] = {type='Aircraft', name='ATR-72-ASW [Meltem III]', points=50, destroyedString='destroyed'},
		[754] = {type='Aircraft', name='CN-235MPA Persuader [Meltem II]', points=50, destroyedString='destroyed'},
		[748] = {type='Aircraft', name='S-70B-28 Seahawk', points=20, destroyedString='destroyed'},
		[2833] = {type='Aircraft', name='S-70B-28 Seahawk', points=20, destroyedString='destroyed'},

		[518] = {type='Ship', name='F 500 Bozcaada [Burak Class]', points=50, destroyedString='sunk'},
		[2835] = {type='Ship', name='F 495 Gediz [Gabya Class, Perry Class]', points=100, destroyedString='sunk'},
		[1135] = {type='Ship', name='F 490 Gaziantep [Perry Class, Gabya Class]', points=100, destroyedString='sunk'},
		[909] = {type='Ship', name='F 240 Yavuz [Meko 200TN Track I]', points=100, destroyedString='sunk'},
		[2063] = {type='Ship', name='F 511 Heybeliada [Ada Class]', points=50, destroyedString='sunk'},
		[484] = {type='Ship', name='Platform [Class A, 90000t]', points=1000, destroyedString='sunk'},

		[229] = {type='Submarine', name='S 347 Atilay [Type 209-1200, Ay Class]', points=70, destroyedString='sunk'},
		[230] = {type='Submarine', name='S 353 Preveze [Type 209-1400, Preveze/Gür Class]', points=70, destroyedString='sunk'},

		[35] = {type='Facility', name='Runway (3200m)', points=0, destroyedString='destroyed'},
		[307] = {type='Facility', name='Runway Access Point (Medium Aircraft)', points=0, destroyedString='destroyed'},
		[4] = {type='Facility', name='A/C Hardened Aircraft Shelter (1x Medium Aircraft)', points=0, destroyedString='destroyed'},
		[41] = {type='Facility', name='A/C Hangar (2x Large Aircraft)', points=0, destroyedString='destroyed'},
		[227] = {type='Facility', name='A/C Hangar (4x Medium Aircraft)', points=0, destroyedString='destroyed'},
		[1556] = {type='Facility', name='A/C Hangar (1x Very Large Aircraft)', points=0, destroyedString='destroyed'},
		[3] = {type='Facility', name='Building (Control Tower)', points=0, destroyedString='destroyed'},
		[1093] = {type='Facility', name='AAA Sec (35mm Twin Oerlikon x 2, Skyguard FCR)', points=0, destroyedString='destroyed'},
		[572] = {type='Facility', name='Radar (AN/FPS-88)', points=0, destroyedString='destroyed'},
		[917] = {type='Facility', name='Radar (HR-3000 RSRP)', points=0, destroyedString='destroyed'},
		[986] = {type='Facility', name='Radar (RAT-31DL)', points=0, destroyedString='destroyed'},
		[1068] = {type='Facility', name='Radar (TRS 22XX)', points=0, destroyedString='destroyed'},
		[790] = {type='Facility', name='SAM Bty (I-HAWK [HAWK-XXI, HEOS])', points=0, destroyedString='destroyed'},
		[2138] = {type='Facility', name='SAM Sec (Atligan x 2 [Stinger])', points=0, destroyedString='destroyed'},
		[696] = {type='Facility', name='SAM Plt/2 (Rapier B1X)', points=0, destroyedString='destroyed'},
		[1715] = {type='Facility', name='SSM Bty (Harpy TEL)', points=0, destroyedString='destroyed'},
		[1648] = {type='Facility', name='SSM Plt (J-600T Yildirim)', points=0, destroyedString='destroyed'},
		[430] = {type='Facility', name='Single-Unit Airfield (2x 3201-4000m Runways)', points=0, destroyedString='destroyed'},
		[1592] = {type='Facility', name='Single-Unit Airfield (1x 3201-4000m Runway)', points=0, destroyedString='destroyed'},
	}

	if UnitList[theDestroyedUnit.dbid] then
		local matchData = UnitList[theDestroyedUnit.dbid]
		ChangeScore('Greece', matchData.points, 'Turkish '..matchData.name..' '..matchData.destroyedString..'.')
	else
		BugMessage('Turkish Unit Destroyed', 'Could not find match for destroyed unit '..theDestroyedUnit.classname..', dbid '..theDestroyedUnit.dbid)
	end
end