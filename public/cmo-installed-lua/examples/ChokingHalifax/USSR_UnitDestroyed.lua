local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
                {type='Submarine', dbid=147, points=-3000, name='B-402', destroyedString='sunk'},--PL-877 Kilo
                {type='Facility', dbid=2973, points=-500, name='152nd PDSS Det F', destroyedString='killed in action'},--Inf Sec (Naval Spetsnaz OMRP Squad [Generic Laser Designator])
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('USSR_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
        else
                ChangeScore('Soviet Union',matchData.points,matchData.name.. ' was '..matchData.destroyedString..'.')
                if matchData.type == 'Submarine' then
                        ScenEdit_EndScenario()
                end                      
	end
end