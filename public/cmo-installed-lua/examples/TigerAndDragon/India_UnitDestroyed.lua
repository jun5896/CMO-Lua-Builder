local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=248, points=50, name='Sea King Mk42B [HAS.2]', destroyedString='destroyed'},--Sea King Mk42B [HAS.2]
        {type='Aircraft', dbid=608, points=50, name='Ka-31 Helix', destroyedString='destroyed'},--Ka-31 Helix
        {type='Aircraft', dbid=637, points=50, name='Ka-28 Helix A', destroyedString='destroyed'},--Ka-28 Helix A
        {type='Aircraft', dbid=920, points=75, name='MiG-29K Fulcrum D', destroyedString='destroyed'},--MiG-29K Fulcrum D

        {type='Ship', dbid=1437, points=250, name='F 47 Shivalik [Pr.17]', destroyedString='sunk'},--F 47 Shivalik [Pr.17]
        {type='Ship', dbid=2009, points=350, name='D 51 Rajput [Pr.61ME Kashin II]', destroyedString='sunk'},--D 51 Rajput [Pr.61ME Kashin II]
        {type='Ship', dbid=2010, points=250, name='F 45 Teg [PR.1135.6]', destroyedString='sunk'},--F 45 Teg [PR.1135.6]
        {type='Ship', dbid=2360, points=350, name='D 63 Kolkata [Pr.15A]', destroyedString='sunk'},--D 63 Kolkata [Pr.15A]
        {type='Ship', dbid=2371, points=500, name='A 50 Deepak', destroyedString='sunk'},--A 50 Deepak
        {type='Ship', dbid=603, points=350, name='D 61 Delhi [Pr.15]', destroyedString='sunk'},--D 61 Delhi [Pr.15]
        {type='Ship', dbid=681, points=3500, name='R 33 Vikramaditya [Gorshkov]', destroyedString='sunk'},--R 33 Vikramaditya [Gorshkov]
        {type='Ship', dbid=818, points=250, name='F 40 Talwar [Pr.1135.6]', destroyedString='sunk'},--F 40 Talwar [Pr.1135.6]

        {type='Submarine', dbid=166, points=250, name='S 55 Sindhughosh [PL-877E Kilo]', destroyedString='sunk'},--S 55 Sindhughosh [PL-877E Kilo]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('India_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('India',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
        ChangeScore('China',matchData.points,'An Indian '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
    end
end