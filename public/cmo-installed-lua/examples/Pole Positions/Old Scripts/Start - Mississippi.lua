a = math.random(1,4)

if a == 1 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 782 USS Mississippi', heading=030, latitude='71.9098665322458', longitude='-169.098255236773'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 782 USS Mississippi', 'PZ Alaska')
	end
elseif a == 2 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 782 USS Mississippi', heading=350, latitude='73.3032122460547', longitude='-145.418449733717'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 782 USS Mississippi', 'PZ Alaska')
	end
elseif a == 3 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 782 USS Mississippi', heading=20, latitude='62.1729221120153', longitude='-168.262564436386'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 782 USS Mississippi', 'PZ Alaska')
	end
elseif a == 4 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 782 USS Mississippi', heading=200, latitude='84.5032877193674', longitude='-153.505380265727'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 782 USS Mississippi', 'PZ Alaska')	
	end
end