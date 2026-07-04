local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=1139, points=200, name='Tu-16R Badger E', destroyedString='destroyed'},--Tu-16R Badger E
        {type='Aircraft', dbid=126, points=200, name='Tu-16P Badger J', destroyedString='destroyed'},--Tu-16P Badger J
        {type='Aircraft', dbid=129, points=200, name='Tu-95RT Bear D', destroyedString='destroyed'},--Tu-95RT Bear D
        {type='Aircraft', dbid=1321, points=200, name='Tu-16RM-1/2 Badger D', destroyedString='destroyed'},--Tu-16RM-1/2 Badger D
        {type='Aircraft', dbid=154, points=200, name='Tu-16K-10-26P Badger C Mod', destroyedString='destroyed'},--Tu-16K-10-26P Badger C Mod
        {type='Aircraft', dbid=155, points=200, name='Tu-16K-26PM Badger G Mod', destroyedString='destroyed'},--Tu-16K-26PM Badger G Mod
        {type='Aircraft', dbid=232, points=200, name='Il-78 Midas', destroyedString='destroyed'},--Il-78 Midas
        {type='Aircraft', dbid=2438, points=200, name='Tu-22M-3 Backfire C', destroyedString='destroyed'},--Tu-22M-3 Backfire C
        {type='Aircraft', dbid=4, points=50, name='Ka-27PL Helix A', destroyedString='destroyed'},--Ka-27PL Helix A
        {type='Aircraft', dbid=51, points=50, name='Ka-25Ts Hormone B', destroyedString='destroyed'},--Ka-25Ts Hormone B
        {type='Aircraft', dbid=61, points=200, name='Tu-142MK Bear F Mod 3', destroyedString='destroyed'},--Tu-142MK Bear F Mod 3
        
        {type='Facility', dbid=1592, points=0, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 3201-4000m Runway)
        {type='Facility', dbid=1712, points=0, name='Single-Unit Airfield (1x 2001-2600m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2001-2600m Runway)
        {type='Facility', dbid=1877, points=0, name='Single-Unit Airfield (1x 2600-3200m, Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2600-3200m, Runway)

        {type='Ship', dbid=150, points=5000, name='TAKR Kiev [Pr.1143 Krechyet]', destroyedString='sunk'},--TAKR Kiev [Pr.1143 Krechyet]
        {type='Ship', dbid=156, points=1000, name='BPK Udaloy I [Pr.1155 Fregat]', destroyedString='sunk'},--BPK Udaloy I [Pr.1155 Fregat]
        {type='Ship', dbid=176, points=1000, name='VTR Boris Chilikin [Pr.1559V]', destroyedString='sunk'},--VTR Boris Chilikin [Pr.1559V]
        {type='Ship', dbid=2111, points=1000, name='EM Sovremenny I [Pr.956 Sarych]', destroyedString='sunk'},--EM Sovremenny I [Pr.956 Sarych]
        {type='Ship', dbid=87, points=1000, name='RKR Slava [Pr.1164 Atlant]', destroyedString='sunk'},--RKR Slava [Pr.1164 Atlant]

        {type='Submarine', dbid=105, points=2000, name='PLARK-949 Oscar I [Granit]', destroyedString='sunk'},--PLARK-949 Oscar I [Granit]
        {type='Submarine', dbid=241, points=1000, name='PLA-945 Sierra I [Barrakuda]', destroyedString='sunk'},--PLA-945 Sierra I [Barrakuda]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('USSR_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
        ChangeScore('USSR',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
        ChangeScore('United Kingdom',matchData.points,'A Soviet '..string.lower(theDestroyedUnit.type)..' was '..matchData.destroyedString..'.')
    end
end