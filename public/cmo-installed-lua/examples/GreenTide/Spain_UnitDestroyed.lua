local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
		{type='Aircraft', dbid=1585, points=150, name='P-3B Orion', destroyedString='destroyed'},--P-3B Orion
		{type='Aircraft', dbid=2004, points=50, name='S-70B-1 Seahawk [HS.23]', destroyedString='destroyed'},--S-70B-1 Seahawk [HS.23]
		{type='Aircraft', dbid=28, points=50, name='F/A-18A Hornet [EF-18M, C.15A]', destroyedString='destroyed'},--F/A-18A Hornet [EF-18M, C.15A]
		{type='Aircraft', dbid=3117, points=100, name='C-130H-30 Hercules [T.10]', destroyedString='destroyed'},--C-130H-30 Hercules [T.10]

		{type='Facility', dbid=1273, points=100, name='Sensor (MSP-500 [NASAMS II])', destroyedString='destroyed'},--Sensor (MSP-500 [NASAMS II])
		{type='Facility', dbid=1426, points=100, name='Ammo Shelter', destroyedString='destroyed'},--Ammo Shelter
		{type='Facility', dbid=1496, points=100, name='Ammo Pad', destroyedString='destroyed'},--Ammo Pad
		{type='Facility', dbid=1508, points=100, name='AvGas Tank Farm (40 x 40k Liter Tank)', destroyedString='destroyed'},--AvGas Tank Farm (40 x 40k Liter Tank)
		{type='Facility', dbid=1509, points=100, name='AvGas Tank Farm (10 x 75k Liter Tank)', destroyedString='destroyed'},--AvGas Tank Farm (10 x 75k Liter Tank)
		{type='Facility', dbid=1872, points=100, name='Radar (S-763 Lanza 3D)', destroyedString='destroyed'},--Radar (S-763 Lanza 3D)
		{type='Facility', dbid=217, points=100, name='A/C Tarmac Space (2x Large Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (2x Large Aircraft)
		{type='Facility', dbid=26, points=100, name='A/C Hangar (4x Small Aircraft)', destroyedString='destroyed'},--A/C Hangar (4x Small Aircraft)
		{type='Facility', dbid=27, points=100, name='A/C Hardened Aircraft Shelter (1x Large Aircraft)', destroyedString='destroyed'},--A/C Hardened Aircraft Shelter (1x Large Aircraft)
		{type='Facility', dbid=3, points=100, name='Building (Control Tower)', destroyedString='destroyed'},--Building (Control Tower)
		{type='Facility', dbid=344, points=100, name='A/C Tarmac Space (2x Very Large Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (2x Very Large Aircraft)
		{type='Facility', dbid=35, points=100, name='Runway (3200m)', destroyedString='destroyed'},--Runway (3200m)
		{type='Facility', dbid=353, points=100, name='Runway Access Point (Very Large Aircraft)', destroyedString='destroyed'},--Runway Access Point (Very Large Aircraft)
		{type='Facility', dbid=41, points=100, name='A/C Hangar (2x Large Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Large Aircraft)
		{type='Facility', dbid=427, points=100, name='Building (Airport Terminal)', destroyedString='destroyed'},--Building (Airport Terminal)
		{type='Facility', dbid=55, points=100, name='Runway (2600m)', destroyedString='destroyed'},--Runway (2600m)
		{type='Facility', dbid=653, points=100, name='SAM Plt/2 (NASAMS II)', destroyedString='destroyed'},--SAM Plt/2 (NASAMS II)
		{type='Facility', dbid=68, points=100, name='A/C Hangar (2x Medium Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Medium Aircraft)
		{type='Facility', dbid=71, points=100, name='SAM Plt (Mistral I MANPADS x 3)', destroyedString='destroyed'},--SAM Plt (Mistral I MANPADS x 3)
		{type='Facility', dbid=808, points=100, name='Radar (RAT-31SL)', destroyedString='destroyed'},--Radar (RAT-31SL)
		{type='Facility', dbid=86, points=100, name='A/C Hangar (2x Small Aircraft)', destroyedString='destroyed'},--A/C Hangar (2x Small Aircraft)

		{type='Ship', dbid=1400, points=250, name='F 81 Santa Maria [Perry]', destroyedString='sunk'},--F 81 Santa Maria [Perry]
		{type='Ship', dbid=2364, points=150, name='P 41 Meteoro', destroyedString='sunk'},--P 41 Meteoro
		{type='Ship', dbid=3127, points=50, name='11m RHIB', destroyedString='sunk'},--11m RHIB
		{type='Ship', dbid=768, points=250, name='F 101 Alvaro De Bazán', destroyedString='sunk'},--F 101 Alvaro De Bazán

		{type='Ship', dbid=1869, points=500, name='Oil Rig', destroyedString='destroyed after being captured'},

		{type='Submarine', dbid=495, points=250, name='S 71 Galerna [Agosta, S-70]', destroyedString='sunk'},--S 71 Galerna [Agosta, S-70]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('Spain_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
		ChangeScore('Spain',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString)
		ChangeScore('Morocco',matchData.points,theDestroyedUnit.name.. ' was '..matchData.destroyedString)
    end
end