local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
        {type='Aircraft', dbid=101, points=400, name='Tornado GR.1A', destroyedString=nil},--Tornado GR.1A
        {type='Aircraft', dbid=1022, points=400, name='Tornado ADV', destroyedString=nil},--Tornado ADV
        {type='Aircraft', dbid=151, points=400, name='RF-4C Phantom II', destroyedString=nil},--RF-4C Phantom II
        {type='Aircraft', dbid=159, points=400, name='KC-135E Stratotanker', destroyedString=nil},--KC-135E Stratotanker
        {type='Aircraft', dbid=1692, points=400, name='KC-135R Stratotanker', destroyedString=nil},--KC-135R Stratotanker
        {type='Aircraft', dbid=1871, points=400, name='F-16CG Blk 42 Falcon', destroyedString=nil},--F-16CG Blk 42 Falcon
        {type='Aircraft', dbid=2063, points=400, name='E-3A Sentry', destroyedString=nil},--E-3A Sentry
        {type='Aircraft', dbid=211, points=400, name='F-15C Eagle', destroyedString=nil},--F-15C Eagle
        {type='Aircraft', dbid=214, points=400, name='KC-10A Extender', destroyedString=nil},--KC-10A Extender
        {type='Aircraft', dbid=320, points=400, name='EC-130H Compass Call', destroyedString=nil},--EC-130H Compass Call
        {type='Aircraft', dbid=475, points=400, name='EF-111A Raven', destroyedString=nil},--EF-111A Raven
        {type='Aircraft', dbid=583, points=400, name='F-15C Eagle', destroyedString=nil},--F-15C Eagle
        {type='Aircraft', dbid=590, points=400, name='E-8A Joint STARS', destroyedString=nil},--E-8A Joint STARS
        {type='Aircraft', dbid=645, points=400, name='F-4G Phantom II [Wild Weasel V]', destroyedString=nil},--F-4G Phantom II [Wild Weasel V]
        {type='Aircraft', dbid=667, points=400, name='F-111F Aardvark', destroyedString=nil},--F-111F Aardvark
        {type='Aircraft', dbid=765, points=400, name='E-3B Sentry', destroyedString=nil},--E-3B Sentry
        {type='Facility', dbid=1592, points=40000, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString=nil},--Single-Unit Airfield (1x 3201-4000m Runway)
        {type='Facility', dbid=430, points=40000, name='Single-Unit Airfield (2x 3201-4000m Runways)', destroyedString=nil},--Single-Unit Airfield (2x 3201-4000m Runways)
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('USAF_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
		ChangeScore('USAF',matchData.points*-1,theDestroyedUnit.name..' was destroyed.')
    end
end

