

local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
        {type='Aircraft', dbid=1352, points=100, name='A-7B Corsair II', destroyedString='lost'},--A-7B Corsair II
        {type='Aircraft', dbid=1505, points=100, name='AH-1J Sea Cobra', destroyedString='lost'},--AH-1J Sea Cobra
        {type='Aircraft', dbid=1594, points=250, name='EKA-3B Skywarrior', destroyedString='lost'},--EKA-3B Skywarrior
        {type='Aircraft', dbid=1604, points=10, name='F-8J Crusader', destroyedString='lost'},--F-8J Crusader
        {type='Aircraft', dbid=1635, points=100, name='E-1B Tracer', destroyedString='lost'},--E-1B Tracer
        {type='Aircraft', dbid=17, points=50, name='UH-1E Huey', destroyedString='lost'},--UH-1E Huey
        {type='Aircraft', dbid=1709, points=50, name='SH-3H Sea King', destroyedString='lost'},--SH-3H Sea King
        {type='Aircraft', dbid=1712, points=50, name='SH-2F Seasprite', destroyedString='lost'},--SH-2F Seasprite
        {type='Aircraft', dbid=1770, points=100, name='AV-8A Harrier', destroyedString='lost'},--AV-8A Harrier
        {type='Aircraft', dbid=528, points=50, name='C-1A (TF-1) Trader', destroyedString='lost'},--C-1A (TF-1) Trader
        {type='Aircraft', dbid=625, points=75, name='RF-8G Crusader', destroyedString='lost'},--RF-8G Crusader
        {type='Aircraft', dbid=667, points=250, name='CH-46D Sea Knight', destroyedString='lost'},--CH-46D Sea Knight

        {type='Ship', dbid=1050, points=1000, name='AOR 1 Wichita', destroyedString='sunk'},--AOR 1 Wichita
        {type='Ship', dbid=1066, points=1000, name='CVA 34 Oriskany', destroyedString='sunk'},--CVA 34 Oriskany
        {type='Ship', dbid=1575, points=1000, name='LCU 1646', destroyedString='sunk'},--LCU 1646
        {type='Ship', dbid=1579, points=1000, name='LHA 1 Tarawa', destroyedString='sunk'},--LHA 1 Tarawa
        {type='Ship', dbid=50, points=1000, name='DD 931 Forrest Sherman', destroyedString='sunk'},--DD 931 Forrest Sherman
        {type='Ship', dbid=610, points=1000, name='LCM-6 Mod 1', destroyedString='sunk'},--LCM-6 Mod 1
        {type='Ship', dbid=666, points=1000, name='AE 21 Suribachi', destroyedString='sunk'},--AE 21 Suribachi
        {type='Ship', dbid=746, points=1000, name='FF 1052 Knox', destroyedString='sunk'},--FF 1052 Knox
        {type='Ship', dbid=76, points=1000, name='CG 16 Leahy', destroyedString='sunk'},--CG 16 Leahy
        {type='Ship', dbid=761, points=1000, name='DDG 2 Charles F. Adams', destroyedString='sunk'},--DDG 2 Charles F. Adams
        {type='Ship', dbid=769, points=1000, name='DDG 31 Decatur [Mod Forrest Sherman]', destroyedString='sunk'},--DDG 31 Decatur [Mod Forrest Sherman]
        {type='Ship', dbid=793, points=1000, name='LPD 4 Austin', destroyedString='sunk'},--LPD 4 Austin
        {type='Ship', dbid=812, points=1000, name='LSD 28 Thomaston', destroyedString='sunk'},--LSD 28 Thomaston

        {type='Facility', dbid=1346, points=500, name='Armored Plt (M-48A3 MBT)', destroyedString='KIA'},--Armored Plt (M-48A3 MBT)
        {type='Facility', dbid=1696, points=500, name='Mech Inf Sec (AAV-P7/A1 IFV x 3)', destroyedString='KIA'},--Mech Inf Sec (AAV-P7/A1 IFV x 3)
        {type='Facility', dbid=276, points=750, name='Inf Sec (US Navy SEAL Recon Team)', destroyedString='KIA'},--Inf Sec (US Navy SEAL Recon Team)
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Somalia_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        local usScore = ChangeScore('United States', matchData.points * -1, theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
        if usScore <= -2000 then
            TelexMessageToPlayer(
                'ntbi',
                'COMIDEASTFOR',
                'z',
                'Commander Middle east force',
                'commanding officer cv 34 oriskany',
                'top secret',
                '1. your wanton disregard for the safety of units under your command has compromised the mission.<BR> 2. you are relieved of command effective immediately. <br> 3. expect to face a court martial on your return to port.'
            )
            ChangeScore('United States',-500,'You were relieved of command.')
            ScenEdit_EndScenario()
        end
	end
end