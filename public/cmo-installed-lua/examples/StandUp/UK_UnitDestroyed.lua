local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=1077, points=100, name='Merlin HM.1', destroyedString='destroyed'},--Merlin HM.1
        {type='Aircraft', dbid=1709, points=750, name='VC.10 K.4', destroyedString='destroyed'},--VC.10 K.4
        {type='Aircraft', dbid=1863, points=500, name='Typhoon FGR.4', destroyedString='destroyed'},--Typhoon FGR.4
        {type='Aircraft', dbid=373, points=100, name='Sea King HAR.3', destroyedString='destroyed'},--Sea King HAR.3
        {type='Aircraft', dbid=928, points=250, name='Hercules C.4 [C-130J-30]', destroyedString='destroyed'},--Hercules C.4 [C-130J-30]
        {type='Facility', dbid=1877, points=0, name='Single-Unit Airfield (1x 2600-3200m, Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2600-3200m, Runway)
        {type='Facility', dbid=219, points=0, name='SAM Plt/2 (Rapier FSC Blindfire)', destroyedString='destroyed'},--SAM Plt/2 (Rapier FSC Blindfire)
        {type='Facility', dbid=778, points=50, name='Radar (Type 101 [AR-327])', destroyedString='destroyed'},--Radar (Type 101 [AR-327])
        {type='Ship', dbid=1406, points=1500, name='A 389 Wave Knight', destroyedString='sunk'},--A 389 Wave Knight
        {type='Ship', dbid=1530, points=500, name='P 281 Tyne [River Class, Batch 1]', destroyedString='sunk'},--P 281 Tyne [River Class, Batch 1]
        {type='Ship', dbid=752, points=1500, name='F 236 Montrose [Type 23 Duke]', destroyedString='sunk'},--F 236 Montrose [Type 23 Duke]
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
        ChangeScore('Argentina',matchData.points,'A '..theDestroyedUnit.side.. ' '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
    end
end