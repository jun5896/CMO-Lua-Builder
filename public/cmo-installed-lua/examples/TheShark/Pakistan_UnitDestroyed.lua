local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Submarine', dbid=368, points=300, name='S 131 Hangor [Daphne]', destroyedString='sunk'},--S 131 Hangor [Daphne]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Pakistan_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('India',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')
        ChangeScore('Pakistan',matchData.points * -1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
        ScenEdit_SpecialMessage('Pakistan',"All vessels under your command have been destroyed.")
        ScenEdit_EndScenario()
    end
end