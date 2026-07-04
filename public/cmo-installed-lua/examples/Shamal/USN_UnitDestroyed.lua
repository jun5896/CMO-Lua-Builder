local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=1098, points=400, name='EA-6B Prowler ICAP II Blk 86', destroyedString=nil},--EA-6B Prowler ICAP II Blk 86
        {type='Aircraft', dbid=1120, points=400, name='F/A-18A Hornet', destroyedString=nil},--F/A-18A Hornet
        {type='Aircraft', dbid=1121, points=400, name='F/A-18C Hornet', destroyedString=nil},--F/A-18C Hornet
        {type='Aircraft', dbid=13, points=400, name='E-2C Hawkeye Group I', destroyedString=nil},--E-2C Hawkeye Group I
        {type='Aircraft', dbid=17, points=400, name='EA-6B Prowler ICAP II Blk 82', destroyedString=nil},--EA-6B Prowler ICAP II Blk 82
        {type='Aircraft', dbid=2197, points=400, name='EA-6B Prowler ICAP II Blk 82', destroyedString=nil},--EA-6B Prowler ICAP II Blk 82
        {type='Aircraft', dbid=241, points=400, name='KA-6D Intruder', destroyedString=nil},--KA-6D Intruder
        {type='Aircraft', dbid=270, points=400, name='E-2C Hawkeye Basic', destroyedString=nil},--E-2C Hawkeye Basic
        {type='Aircraft', dbid=46, points=400, name='F-14B Tomcat', destroyedString=nil},--F-14B Tomcat
        {type='Aircraft', dbid=557, points=400, name='E-2C Hawkeye Group 0', destroyedString=nil},--E-2C Hawkeye Group 0
        {type='Aircraft', dbid=602, points=400, name='EA-6B Prowler ICAP II Baseline', destroyedString=nil},--EA-6B Prowler ICAP II Baseline
        {type='Aircraft', dbid=665, points=400, name='A-6E Intruder', destroyedString=nil},--A-6E Intruder
        {type='Aircraft', dbid=666, points=400, name='F-14A Tomcat', destroyedString=nil},--F-14A Tomcat
        {type='Aircraft', dbid=807, points=400, name='SH-3H Sea King', destroyedString=nil},--SH-3H Sea King
        {type='Aircraft', dbid=881, points=400, name='A-7E Corsair II', destroyedString=nil},--A-7E Corsair II
        {type='Aircraft', dbid=9, points=400, name='S-3B Viking', destroyedString=nil},--S-3B Viking
        {type='Aircraft', dbid=932, points=400, name='A-7E Corsair II [FLIR]', destroyedString=nil},--A-7E Corsair II [FLIR]
        {type='Ship', dbid=1625, points=40000, name='CV 60 Saratoga [Forrestal Class]', destroyedString=nil},--CV 60 Saratoga [Forrestal Class]
        {type='Ship', dbid=1628, points=40000, name='CV 61 Ranger [Forrestal Class]', destroyedString=nil},--CV 61 Ranger [Forrestal Class]
        {type='Ship', dbid=1669, points=40000, name='CV 67 John F. Kennedy', destroyedString=nil},--CV 67 John F. Kennedy
        {type='Ship', dbid=1983, points=40000, name='CV 66 America [Kitty Hawk Class]', destroyedString=nil},--CV 66 America [Kitty Hawk Class]
        {type='Ship', dbid=37, points=40000, name='CVN 71 Theodore Roosevelt [Nimitz Class]', destroyedString=nil},--CVN 71 Theodore Roosevelt [Nimitz Class]
        {type='Ship', dbid=573, points=40000, name='CV 41 Midway', destroyedString=nil},--CV 41 Midway
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('USN_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
		ChangeScore('USN',matchData.points*-1,theDestroyedUnit.name..' was destroyed.')
    end
end

