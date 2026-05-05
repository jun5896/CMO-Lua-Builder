a = math.random(1,2)

if a == 1 then
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='K-139 RFS Belgorod', heading=280, latitude='81.5692423898793', longitude='147.53660786426'})
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='K-157 RFS Vepr', heading=270, latitude='82.1950511118441', longitude='151.036814599659'})
	if not ScenEdit_GetSideIsHuman('Russia') then
		ScenEdit_AssignUnitToMission('K-139 RFS Belgorod', 'Emplacement zone A')
		ScenEdit_AssignUnitToMission('K-157 RFS Vepr', 'Emplacement zone A Escort')
	end
elseif a == 2 then
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='K-139 RFS Belgorod', heading=090, latitude='87.0533581265612', longitude='128.623523919292'})
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='K-157 RFS Vepr', heading=100, latitude='86.8974989211257', longitude='130.028913292364'})
	if not ScenEdit_GetSideIsHuman('Russia') then
		ScenEdit_AssignUnitToMission('K-139 RFS Belgorod', 'Emplacement zone D')
		ScenEdit_AssignUnitToMission('K-157 RFS Vepr', 'Emplacement zone D Escort')
	end
end