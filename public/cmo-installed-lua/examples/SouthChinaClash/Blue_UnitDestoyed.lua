local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=1006, points=50, name='MQ-8B Fire Scout UAV', destroyedString='destroyed'},--MQ-8B Fire Scout UAV
        {type='Aircraft', dbid=1397, points=100, name='F.27-200MAR Maritime', destroyedString='destroyed'},--F.27-200MAR Maritime
        {type='Aircraft', dbid=1984, points=200, name='KC-135R Stratotanker', destroyedString='destroyed'},--KC-135R Stratotanker
        {type='Aircraft', dbid=2006, points=100, name='MH-60R Seahawk', destroyedString='destroyed'},--MH-60R Seahawk
        {type='Aircraft', dbid=2139, points=100, name='F/A-18E Super Hornet', destroyedString='destroyed'},--F/A-18E Super Hornet
        {type='Aircraft', dbid=2705, points=200, name='P-8A Poseidon', destroyedString='destroyed'},--P-8A Poseidon
        {type='Aircraft', dbid=2846, points=50, name='MQ-4C Triton UAV [Global Hawk Mod]', destroyedString='destroyed'},--MQ-4C Triton UAV [Global Hawk Mod]
        {type='Aircraft', dbid=306, points=200, name='P-3C Orion Update III AIP', destroyedString='destroyed'},--P-3C Orion Update III AIP
        {type='Facility', dbid=1712, points=0, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2001-2600m Runway)
        {type='Facility', dbid=430, points=0, name='Single-Unit Airfield (2x 3201-4000m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 3201-4000m Runways)
        {type='Ship', dbid=2594, points=300, name='LCS 1 Freedom', destroyedString='sunk'},--LCS 1 Freedom
        {type='Ship', dbid=2017, points=100, name='PS 35 Emilio Jacinto [Peacock]', destroyedString='sunk'},--PS 35 Emilio Jacinto [Peacock]
        {type='Ship', dbid=2349, points=750, name='DDG 96 Bainbridge [Arleigh Burke Flight IIA]', destroyedString='sunk'},--DDG 96 Bainbridge [Arleigh Burke Flight IIA]
        {type='Submarine', dbid=74, points=500, name='SSN 774 Virginia [Flight I]', destroyedString='sunk'},--SSN 774 Virginia [Flight I]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData.dbid == nil then
        BugMessage('US_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('United States',matchData.points*-2,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
        ChangeScore('PLAN',matchData.points,'A '..matchData.name..' was '..matchData.destroyedString..'.')
    end
end