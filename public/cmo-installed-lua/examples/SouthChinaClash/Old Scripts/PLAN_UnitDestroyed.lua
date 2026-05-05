local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=2478, points=100, name='J-10AH Vigorous Dragon', destroyedString='destroyed'},--J-10AH Vigorous Dragon
        {type='Aircraft', dbid=254, points=100, name='JH-7A Flounder', destroyedString='destroyed'},--JH-7A Flounder
        {type='Aircraft', dbid=354, points=200, name='Y-8X Cub', destroyedString='destroyed'},--Y-8X Cub
        {type='Aircraft', dbid=60, points=100, name='Z-9C Dauphin 2', destroyedString='destroyed'},--Z-9C Dauphin 2
        {type='Aircraft', dbid=862, points=100, name='Ka-28 Helix A', destroyedString='destroyed'},--Ka-28 Helix A
        {type='Facility', dbid=153, points=200, name='Bunker (SIGINT Station)', destroyedString='destroyed'},--Bunker (SIGINT Station)
        {type='Facility', dbid=1712, points=0, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2001-2600m Runway)
        {type='Facility', dbid=1714, points=0, name='Single-Unit Airfield (2x 2601-3200m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2601-3200m Runways)
        {type='Facility', dbid=768, points=100, name='Radar (China YLC-2)', destroyedString='destroyed'},--Radar (China YLC-2)
        {type='Ship', dbid=167, points=300, name='Type 053H Jianghu I [516 Changsha]', destroyedString='sunk'},--Type 053H Jianghu I [516 Changsha]
        {type='Ship', dbid=1965, points=300, name='Type 054A Jiangkai II [530 Xuzhou]', destroyedString='sunk'},--Type 054A Jiangkai II [530 Xuzhou]
        {type='Ship', dbid=2295, points=300, name='Type 056 Jiangdao [582 Bengbu]', destroyedString='sunk'},--Type 056 Jiangdao [582 Bengbu]
        {type='Ship', dbid=696, points=300, name='Type 052C Luyang II [170 Lanzhou]', destroyedString='sunk'},--Type 052C Luyang II [170 Lanzhou]
        {type='Submarine', dbid=403, points=300, name='Type 041 Yuan', destroyedString='sunk'},--Type 041 Yuan
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('PLAN_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('PLAN',matchData.points*-2,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
        ChangeScore('United States',matchData.points,'A '..theDestroyedUnit.side.. ' '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
    end
end