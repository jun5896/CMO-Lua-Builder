a = math.random(1,8)

if a == 1 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 700 USS Dallas', heading=350, latitude='88.3577500512558', longitude='-43.0487621776154'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 700 USS Dallas', 'Cyber 2')
	end
elseif a == 2 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 700 USS Dallas', heading=350, latitude='66.9706602658021', longitude='-167.026554488041'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 700 USS Dallas', 'Cyber 1')
	end
elseif a == 3 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 700 USS Dallas', heading=300, latitude='75.4822416893364', longitude='-132.135608948241'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 700 USS Dallas', 'Cyber 1')
	end
elseif a == 4 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 700 USS Dallas', heading=300, latitude='83.3273979105667', longitude='-141.113065607081'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 700 USS Dallas', 'Cyber 2')
	end
elseif a == 5 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 700 USS Dallas', heading=60, latitude='87.0756477569022', longitude='-5.08884105817846'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 700 USS Dallas', 'Cyber 3')
	end
elseif a == 6 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 700 USS Dallas', heading=60, latitude='83.6078851091719', longitude='3.55467094340892'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 700 USS Dallas', 'Cyber 3')
	end
elseif a == 7 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 700 USS Dallas', heading=30, latitude='77.197551369023', longitude='2.32421685163199'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 700 USS Dallas', 'Cyber 4')
	end
elseif a == 6 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 700 USS Dallas', heading=10, latitude='74.8548544275417', longitude='28.7916972907539'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 700 USS Dallas', 'Cyber 4')
	end
end

if ScenEdit_GetSideIsHuman('US') then
	ScenEdit_SetEvent('Dallas - Cyber Attack', {isActive = 'False'})
end

if not ScenEdit_GetSideIsHuman('US') then
	ScenEdit_SetEvent('Dallas - Cyber Attack', {isActive = 'True'})
end