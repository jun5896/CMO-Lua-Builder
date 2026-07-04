local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=237, points=0, name='SH-60B Seahawk', destroyedString='destroyed'},--SH-60B Seahawk
        {type='Aircraft', dbid=2600, points=0, name='Lynx HAS.2', destroyedString='destroyed'},--Lynx HAS.2
        {type='Aircraft', dbid=2803, points=0, name='P-3C Orion Update II', destroyedString='destroyed'},--P-3C Orion Update II
        {type='Aircraft', dbid=33, points=0, name='Lynx HAS.3', destroyedString='destroyed'},--Lynx HAS.3
        {type='Aircraft', dbid=36, points=0, name='Sea Harrier FRS.1', destroyedString='destroyed'},--Sea Harrier FRS.1
        {type='Aircraft', dbid=37, points=0, name='Sea King AEW.2', destroyedString='destroyed'},--Sea King AEW.2
        {type='Aircraft', dbid=38, points=0, name='Sea King HAS.5', destroyedString='destroyed'},--Sea King HAS.5
        {type='Aircraft', dbid=702, points=0, name='AB.212 ASW [SH-212A]', destroyedString='destroyed'},--AB.212 ASW [SH-212A]
        {type='Aircraft', dbid=905, points=0, name='Wasp HAS.1', destroyedString='destroyed'},--Wasp HAS.1
        {type='Aircraft', dbid=95, points=0, name='Nimrod MR.2P', destroyedString='destroyed'},--Nimrod MR.2P

        {type='Facility', dbid=1712, points=0, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2001-2600m Runway)
        {type='Facility', dbid=1714, points=0, name='Single-Unit Airfield (2x 2601-3200m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2601-3200m Runways)

        {type='Ship', dbid=1125, points=2000, name='carrier', destroyedString='sunk'},--R 06 Illustrious [Invincible Class]
        {type='Ship', dbid=114, points=300, name='destroyer', destroyedString='sunk'},--DD 963 Spruance [VLS]
        {type='Ship', dbid=1362, points=300, name='destroyer', destroyedString='sunk'},--D 95 Manchester [Type 42 Batch 3]
        {type='Ship', dbid=1383, points=2000, name='carrier', destroyedString='sunk'},--C 551 Giuseppe Garibaldi
        {type='Ship', dbid=1385, points=300, name='destroyer', destroyedString='sunk'},--D 550 Audace
        {type='Ship', dbid=14, points=200, name='frigate', destroyedString='sunk'},--F 88 Broadsword [Type 22 Batch 1]
        {type='Ship', dbid=1504, points=200, name='frigate', destroyedString='sunk'},--F 40 Sirius [Type 12I Leander Batch 2TA]
        {type='Ship', dbid=1602, points=500, name='UNREP vessel', destroyedString='sunk'},--A 122 Olwen
        {type='Ship', dbid=1707, points=200, name='frigate', destroyedString='sunk'},--F 570 Maestrale
        {type='Ship', dbid=18, points=200, name='frigate', destroyedString='sunk'},--F 85 Cornwall [Type 22 Batch 3]
        {type='Ship', dbid=512, points=400, name='cruiser', destroyedString='sunk'},--CG 49 Vincennes [Ticonderoga Baseline 1, Mk26]
        {type='Ship', dbid=683, points=200, name='frigate', destroyedString='sunk'},--F 92 Boxer [Type 22 Batch 2]
        {type='Ship', dbid=706, points=300, name='destroyer', destroyedString='sunk'},--DD 963 Spruance [Baseline]
        {type='Submarine', dbid=33, points=300, name='submarine', destroyedString='sunk'},--SSN 688 Los Angeles [Flight I]
        {type='Submarine', dbid=62, points=300, name='submarine', destroyedString='sunk'},--SSN 637 Sturgeon
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('NATO_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('Soviet Union',matchData.points,'A NATO '..matchData.name..' was '..matchData.destroyedString..'.')
    end
end