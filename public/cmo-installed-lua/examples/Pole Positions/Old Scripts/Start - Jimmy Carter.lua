a = math.random(1,6)

if a == 1 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 23 USS Jimmy Carter', heading=000, latitude='67.1432291248884', longitude='-169.555580029793'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 23 USS Jimmy Carter', 'ATGU')
	end
elseif a == 2 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 23 USS Jimmy Carter', heading=280, latitude='76.3147331247301', longitude='-127.693717603524'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 23 USS Jimmy Carter', 'ATGU')
	end
elseif a == 3 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 23 USS Jimmy Carter', heading=300, latitude='84.9542942176137', longitude='-64.0866770560132'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 23 USS Jimmy Carter', 'ATGU')
	end
elseif a == 4 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 23 USS Jimmy Carter', heading=030, latitude='83.4280315891238', longitude='59.1519979196596'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 23 USS Jimmy Carter', 'ATGU')	
	end
elseif a == 5 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 23 USS Jimmy Carter', heading=200, latitude='81.767884693935', longitude='-164.143595857171'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 23 USS Jimmy Carter', 'ATGU')
	end
elseif a == 6 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 23 USS Jimmy Carter', heading=330, latitude='62.886867876806', longitude='-167.659692953428'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 23 USS Jimmy Carter', 'ATGU')	
	end
end