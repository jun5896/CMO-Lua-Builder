local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{type='Aircraft', dbid=1069, points=100, name='F/A-18D Hornet', destroyedString='destroyed'},--F/A-18D Hornet
		{type='Aircraft', dbid=1633, points=100, name='A-10C Thunderbolt II', destroyedString='destroyed'},--A-10C Thunderbolt II
		{type='Aircraft', dbid=1718, points=50, name='RQ-1B Predator UAV', destroyedString='destroyed'},--RQ-1B Predator UAV
		{type='Aircraft', dbid=1719, points=50, name='MQ-9B Reaper UAV', destroyedString='destroyed'},--MQ-9B Reaper UAV
		{type='Aircraft', dbid=1757, points=100, name='F-16CM Blk 40 Falcon', destroyedString='destroyed'},--F-16CM Blk 40 Falcon
		{type='Aircraft', dbid=1854, points=250, name='KC-135R Stratotanker', destroyedString='destroyed'},--KC-135R Stratotanker
		{type='Aircraft', dbid=1984, points=250, name='KC-135R Stratotanker', destroyedString='destroyed'},--KC-135R Stratotanker
		{type='Aircraft', dbid=214, points=250, name='KC-10A Extender', destroyedString='destroyed'},--KC-10A Extender
		{type='Aircraft', dbid=2781, points=500, name='B-52H Stratofortress', destroyedString='destroyed'},--B-52H Stratofortress
		{type='Aircraft', dbid=2787, points=75, name='RQ-170A Wraith [Sentinel] UAV', destroyedString='destroyed'},--RQ-170A Wraith [Sentinel] UAV
		{type='Aircraft', dbid=2847, points=50, name='RQ-4B Global Hawk Blk 30 UAV', destroyedString='destroyed'},--RQ-4B Global Hawk Blk 30 UAV
		{type='Aircraft', dbid=2859, points=100, name='AV-8B Harrier II+ [Night Attack]', destroyedString='destroyed'},--AV-8B Harrier II+ [Night Attack]
		{type='Aircraft', dbid=2918, points=500, name='U-2S', destroyedString='destroyed'},--U-2S
		{type='Aircraft', dbid=304, points=500, name='E-3C Sentry', destroyedString='destroyed'},--E-3C Sentry
		{type='Aircraft', dbid=306, points=250, name='P-3C Orion Update III AIP', destroyedString='destroyed'},--P-3C Orion Update III AIP
		{type='Aircraft', dbid=496, points=1000, name='B-2A Spirit Blk 30', destroyedString='destroyed'},--B-2A Spirit Blk 30
		{type='Aircraft', dbid=573, points=500, name='RC-135V Rivet Joint', destroyedString='destroyed'},--RC-135V Rivet Joint
		{type='Aircraft', dbid=601, points=250, name='EA-6B Prowler ICAP III', destroyedString='destroyed'},--EA-6B Prowler ICAP III
		{type='Aircraft', dbid=617, points=500, name='RC-135W Rivet Joint', destroyedString='destroyed'},--RC-135W Rivet Joint
		{type='Aircraft', dbid=691, points=250, name='F-22A Raptor', destroyedString='destroyed'},--F-22A Raptor
		{type='Aircraft', dbid=956, points=100, name='F-15E Strike Eagle', destroyedString='destroyed'},--F-15E Strike Eagle
		{type='Facility', dbid=1391, points=0, name='A/C Open Parking Spot (1x Very Large Aircraft)', destroyedString='destroyed'},--A/C Open Parking Spot (1x Very Large Aircraft)
		{type='Facility', dbid=1422, points=0, name='Runway-Grade Taxiway (3200m)', destroyedString='destroyed'},--Runway-Grade Taxiway (3200m)
		{type='Facility', dbid=143, points=0, name='Radar (AN/TPS-75)', destroyedString='destroyed'},--Radar (AN/TPS-75)
		{type='Facility', dbid=1592, points=0, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 3201-4000m Runway)
		{type='Facility', dbid=1713, points=0, name='Single-Unit Airfield (2x 2001-2600m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2001-2600m Runways)
		{type='Facility', dbid=1714, points=0, name='Single-Unit Airfield (2x 2601-3200m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2601-3200m Runways)
		{type='Facility', dbid=184, points=0, name='A/C Revetment (1x Large Aircraft)', destroyedString='destroyed'},--A/C Revetment (1x Large Aircraft)
		{type='Facility', dbid=217, points=0, name='A/C Tarmac Space (2x Large Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (2x Large Aircraft)
		{type='Facility', dbid=3, points=0, name='Building (Control Tower)', destroyedString='destroyed'},--Building (Control Tower)
		{type='Facility', dbid=320, points=0, name='Ammo Revetment', destroyedString='destroyed'},--Ammo Revetment
		{type='Facility', dbid=35, points=0, name='Runway (3200m)', destroyedString='destroyed'},--Runway (3200m)
		{type='Facility', dbid=353, points=0, name='Runway Access Point (Very Large Aircraft)', destroyedString='destroyed'},--Runway Access Point (Very Large Aircraft)
		{type='Facility', dbid=41, points=0, name='A/C Hangar (2x Large Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Large Aircraft)
		{type='Facility', dbid=430, points=0, name='Single-Unit Airfield (2x 3201-4000m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 3201-4000m Runways)
		{type='Facility', dbid=944, points=0, name='AvGas (150k Liter Underground Tank)', destroyedString='destroyed'},--AvGas (150k Liter Underground Tank)
		{type='Ship', dbid=1195, points=2000, name='DDG 96 Bainbridge [Arleigh Burke Flight IIA]', destroyedString='sunk'},--DDG 96 Bainbridge [Arleigh Burke Flight IIA]
		{type='Ship', dbid=1941, points=2000, name='DDG 81 Winston S. Churchill [Arleigh Burke Flight IIA]', destroyedString='sunk'},--DDG 81 Winston S. Churchill [Arleigh Burke Flight IIA]
		{type='Ship', dbid=438, points=2000, name='DDG 51 Arleigh Burke [Arleigh Burke Flight I]', destroyedString='sunk'},--DDG 51 Arleigh Burke [Arleigh Burke Flight I]
		{type='Submarine', dbid=182, points=2000, name='SSGN 726 Ohio [DDS]', destroyedString='sunk'},--SSGN 726 Ohio [DDS]
		{type='Submarine', dbid=216, points=2000, name='SSN 23 Jimmy Carter [Seawolf Class]', destroyedString='sunk'},--SSN 23 Jimmy Carter [Seawolf Class]
		{type='Submarine', dbid=74, points=2000, name='SSN 774 Virginia [Flight I]', destroyedString='sunk'},--SSN 774 Virginia [Flight I]
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
		end
	end

	if matchData.dbid == nil then
		BugMessage('United States_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('United States',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
	end
end