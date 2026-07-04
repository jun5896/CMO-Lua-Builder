a = math.random(1,2)

if a == 1 then
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='BS-64 RFS Podmoskovye', heading=295, latitude='82.0091051286464', longitude='41.8414099225931'})
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='K-371 RFS Pantera', heading=295, latitude='82.1911767503469', longitude='45.7109064436504'})
	if not ScenEdit_GetSideIsHuman('Russia') then
		ScenEdit_AssignUnitToMission('BS-64 RFS Podmoskovye', 'Preparation Area A')
		ScenEdit_AssignUnitToMission('K-371 RFS Pantera', 'Preparation Area A Escort')
	end
elseif a == 2 then
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='BS-64 RFS Podmoskovye', heading=110, latitude='81.5510639547088', longitude='4.41393068779108'})
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='K-371 RFS Pantera', heading=110, latitude='81.6864133034119', longitude='5.4233912136135'})
	if not ScenEdit_GetSideIsHuman('Russia') then
		ScenEdit_AssignUnitToMission('BS-64 RFS Podmoskovye', 'Preparation Area B')
		ScenEdit_AssignUnitToMission('K-371 RFS Pantera', 'Preparation Area B Escort')
	end
end