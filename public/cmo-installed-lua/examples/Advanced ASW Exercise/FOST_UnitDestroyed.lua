local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type == 'Ship' then
	ChangeScore('FOST Units',-500,theDestroyedUnit.name..' was sunk')
	if theDestroyedUnit.dbid == 496  then
        local theMessage = ACP126('FOST','FLEET','i','CINCFLEET NORTHWOOD','FOST TASK GROUP COMMANDER',
			'exercise in confidence','confirm rfa grey rover destroyed by enemy action. <BR> BT <BR> exercise performance unsatisfactory. <BR> BT <BR> return to hms collingwood for debrief.')
        ScenEdit_SpecialMessage('playerside',theMessage)
        RegisterMessage(theMessage)
		ChangeScore('FOST Units',-500,'Mission failed!')
		ScenEdit_EndScenario()
    end
end