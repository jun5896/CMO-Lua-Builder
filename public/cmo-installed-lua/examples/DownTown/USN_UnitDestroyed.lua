local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1236, points=200, name='A-4C Skyhawk', destroyedString='destroyed'},--A-4C Skyhawk
        {type='Aircraft', dbid=1594, points=500, name='EKA-3B Skywarrior', destroyedString='destroyed'},--EKA-3B Skywarrior
        {type='Aircraft', dbid=2140, points=500, name='KA-3B Skywarrior', destroyedString='destroyed'},--KA-3B Skywarrior
        {type='Aircraft', dbid=242, points=200, name='F-4B Phantom II', destroyedString='destroyed'},--F-4B Phantom II
        {type='Aircraft', dbid=270, points=500, name='E-2A Hawkeye', destroyedString='destroyed'},--E-2A Hawkeye
        {type='Aircraft', dbid=3042, points=500, name='RA-3B Skywarrior', destroyedString='destroyed'},--RA-3B Skywarrior
        {type='Aircraft', dbid=347, points=200, name='A-6A Intruder', destroyedString='destroyed'},--A-6A Intruder
        {type='Aircraft', dbid=576, points=200, name='UH-2A Seasprite', destroyedString='destroyed'},--UH-2A Seasprite
        {type='Aircraft', dbid=666, points=200, name='A-7A Corsair II', destroyedString='destroyed'},--A-7A Corsair II
        {type='Aircraft', dbid=687, points=500, name='RA-5C Vigilante', destroyedString='destroyed'},--RA-5C Vigilante

        {type='Ship', dbid=1225, points=10000, name='CGN 35 Truxtun', destroyedString='sunk'},--CGN 35 Truxtun
        {type='Ship', dbid=78, points=10000, name='CGN 25 Bainbridge', destroyedString='sunk'},--CGN 25 Bainbridge
        {type='Ship', dbid=83, points=10000, name='CGN 9 Long Beach', destroyedString='sunk'},--CGN 9 Long Beach
        {type='Ship', dbid=874, points=100000, name='CV 61 Ranger [Forrestal Class]', destroyedString='sunk'},--CV 61 Ranger [Forrestal Class]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('USN_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('USN',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
        if theDestroyedUnit.type == 'Aircraft' then
            GenerateSurvivors(theDestroyedUnit.latitude,theDestroyedUnit.longitude,theDestroyedUnit.name)
        end
    end
end