a = math.random(1,4)

if a == 1 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 786 USS Illinois', heading=050, latitude='78.3415088433432', longitude='-6.75905192352875'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 786 USS Illinois', 'PZ Greenland')
	end
elseif a == 2 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 786 USS Illinois', heading=350, latitude='79.1868858341127', longitude='35.79397101522'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 786 USS Illinois', 'PZ Greenland')
	end
elseif a == 3 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 786 USS Illinois', heading=300, latitude='82.7195395821267', longitude='57.1444887612139'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 786 USS Illinois', 'PZ Greenland')
	end
elseif a == 4 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSN 786 USS Illinois', heading=100, latitude='83.1333796957441', longitude='-5.9694730325986'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSN 786 USS Illinois', 'PZ Greenland')	
	end
end