local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=1846, points=200, name='Shackleton AEW.2', destroyedString='destroyed'},--Shackleton AEW.2
        {type='Aircraft', dbid=2212, points=50, name='Sea King HAS.5', destroyedString='destroyed'},--Sea King HAS.5
        {type='Aircraft', dbid=2213, points=50, name='Lynx HAS.3', destroyedString='destroyed'},--Lynx HAS.3
        {type='Aircraft', dbid=33, points=50, name='Lynx HAS.3', destroyedString='destroyed'},--Lynx HAS.3
        {type='Aircraft', dbid=36, points=50, name='Sea Harrier FRS.1', destroyedString='destroyed'},--Sea Harrier FRS.1
        {type='Aircraft', dbid=37, points=50, name='Sea King AEW.2', destroyedString='destroyed'},--Sea King AEW.2
        {type='Aircraft', dbid=66, points=100, name='Buccaneer S.2B', destroyedString='destroyed'},--Buccaneer S.2B
        {type='Aircraft', dbid=95, points=200, name='Nimrod MR.2P', destroyedString='destroyed'},--Nimrod MR.2P

        {type='Facility', dbid=165, points=0, name='Radar (HF-200 Mk4 HF)', destroyedString='destroyed'},--Radar (HF-200 Mk4 HF)
        {type='Facility', dbid=1712, points=0, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2001-2600m Runway)
        {type='Facility', dbid=1714, points=0, name='Single-Unit Airfield (2x 2601-3200m Runways)', destroyedString='destroyed'},--Single-Unit Airfield (2x 2601-3200m Runways)
        {type='Facility', dbid=776, points=0, name='Radar (Type 80 Linesman)', destroyedString='destroyed'},--Radar (Type 80 Linesman)
        {type='Facility', dbid=777, points=0, name='Radar (Type 95 [S-259])', destroyedString='destroyed'},--Radar (Type 95 [S-259])
        {type='Facility', dbid=897, points=0, name='Radar (Type 96 [S-649])', destroyedString='destroyed'},--Radar (Type 96 [S-649])

        {type='Ship', dbid=1359, points=1000, name='D 80 Sheffield [Type 42 Batch 1]', destroyedString='sunk'},--D 80 Sheffield [Type 42 Batch 1]
        {type='Ship', dbid=1361, points=1000, name='D 89 Exeter [Type 42 Batch 2]', destroyedString='sunk'},--D 89 Exeter [Type 42 Batch 2]
        {type='Ship', dbid=1363, points=1000, name='D 95 Manchester [Type 42 Batch 3]', destroyedString='sunk'},--D 95 Manchester [Type 42 Batch 3]
        {type='Ship', dbid=1364, points=6000, name='R 05 Invincible', destroyedString='sunk'},--R 05 Invincible
        {type='Ship', dbid=1433, points=1000, name='F 88 Broadsword [Type 22 Batch 1]', destroyedString='sunk'},--F 88 Broadsword [Type 22 Batch 1]
        {type='Ship', dbid=1434, points=1000, name='F 92 Boxer [Type 22 Batch 2]', destroyedString='sunk'},--F 92 Boxer [Type 22 Batch 2]
        {type='Ship', dbid=1504, points=1000, name='F 40 Sirius [Type 12I Leander Batch 2TA]', destroyedString='sunk'},--F 40 Sirius [Type 12I Leander Batch 2TA]
        {type='Ship', dbid=1604, points=2000, name='A 385 Fort Grange [Fort Class]', destroyedString='sunk'},--A 385 Fort Grange [Fort Class]
        {type='Ship', dbid=1966, points=1000, name='F 169 Amazon [Type 21, Exocet]', destroyedString='sunk'},--F 169 Amazon [Type 21, Exocet]

        {type='Submarine', dbid=30, points=1000, name='S 107 Trafalgar', destroyedString='sunk'},--S 107 Trafalgar
        {type='Submarine', dbid=432, points=1000, name='S 108 Swiftsure', destroyedString='sunk'},--S 108 Swiftsure
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('UK_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('United Kingdom',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
        ChangeScore('USSR',matchData.points,'A British '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
    end
end