a = math.random(1,4)

if a == 1 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 21 USS Seawolf', heading=330, latitude='83.8929625034283', longitude='-134.745313689003'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 21 USS Seawolf', 'PZ Ridge')
	end
elseif a == 2 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 21 USS Seawolf', heading=350, latitude='81.349995096772', longitude='173.810829530962'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 21 USS Seawolf', 'PZ Ridge')
	end
elseif a == 3 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 21 USS Seawolf', heading=20, latitude='85.0374692276509', longitude='-4.69270536246881'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 21 USS Seawolf', 'PZ Ridge')
	end
elseif a == 4 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 21 USS Seawolf', heading=320, latitude='76.7425608560806', longitude='-142.65662015308'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 21 USS Seawolf', 'PZ Ridge')	
	end
end