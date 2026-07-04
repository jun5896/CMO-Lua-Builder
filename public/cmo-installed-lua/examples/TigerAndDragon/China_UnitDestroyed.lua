local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=2487, points=200, name='KJ-200 Cub [GX5]', destroyedString='destroyed'},--KJ-200 Cub [GX5]
        {type='Aircraft', dbid=2496, points=100, name='J-15 Flying Shark [Su-33 Copy]', destroyedString='destroyed'},--J-15 Flying Shark [Su-33 Copy]
        {type='Aircraft', dbid=60, points=50, name='Z-9C Dauphin 2', destroyedString='destroyed'},--Z-9C Dauphin 2

        {type='Facility', dbid=1995, points=0, name='Single-Unit Airfield (1x 4000m+ Runway)', destroyedString='sunk'},--Single-Unit Airfield (1x 4000m+ Runway)

        {type='Ship', dbid=1676, points=300, name='Type 052 Luhu [113 Qingdao]', destroyedString='sunk'},--Type 052 Luhu [113 Qingdao]
        {type='Ship', dbid=1806, points=300, name='Type 051C Luzhou [115 Shenyang]', destroyedString='sunk'},--Type 051C Luzhou [115 Shenyang]
        {type='Ship', dbid=1830, points=300, name='Type 051DT Luda IV [109 Kaifeng]', destroyedString='sunk'},--Type 051DT Luda IV [109 Kaifeng]
        {type='Ship', dbid=1832, points=300, name='Type 051B Luhai [167 Shenzhen]', destroyedString='sunk'},--Type 051B Luhai [167 Shenzhen]
        {type='Ship', dbid=1965, points=300, name='Type 054A Jiangkai II [530 Xuzhou]', destroyedString='sunk'},--Type 054A Jiangkai II [530 Xuzhou]
        {type='Ship', dbid=2007, points=3500, name='Type 001 Liaoning [16 Liaoning, Shi Lang, Ex-Varyag]', destroyedString='sunk'},--Type 001 Liaoning [16 Liaoning, Shi Lang, Ex-Varyag]
        {type='Ship', dbid=2359, points=100, name='Commercial Large Trawler [1,250t DWT]', destroyedString='sunk'},--Commercial Large Trawler [1,250t DWT]
        {type='Ship', dbid=654, points=300, name='Type 903 Fuchi [886 Qiandaohu]', destroyedString='sunk'},--Type 903 Fuchi [886 Qiandaohu]
        {type='Ship', dbid=690, points=300, name='Type 052B Luyang I [168 Guangzhou]', destroyedString='sunk'},--Type 052B Luyang I [168 Guangzhou]
        {type='Ship', dbid=696, points=300, name='Type 052C Luyang II [170 Lanzhou]', destroyedString='sunk'},--Type 052C Luyang II [170 Lanzhou]
        {type='Ship', dbid=783, points=300, name='Type 053H3 Jiangwei II [564 Yichang]', destroyedString='sunk'},--Type 053H3 Jiangwei II [564 Yichang]
        
        {type='Submarine', dbid=124, points=300, name='Type 039G1 Song', destroyedString='sunk'},--Type 039G1 Song
        {type='Submarine', dbid=164, points=300, name='Type 093 Shang', destroyedString='sunk'},--Type 093 Shang
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('China_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('China',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
        ChangeScore('India',matchData.points,'A Chinese '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
    end
end