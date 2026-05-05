a = math.random(1,2)

if a == 1 then
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='BS-136 RFS Orenburg', heading=320, latitude='73.486949766786', longitude='-157.50548750592'})
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='K-295 RFS Samara', heading=320, latitude='73.8600069097283', longitude='-157.12900409373'})
	if not ScenEdit_GetSideIsHuman('Russia') then
		ScenEdit_AssignUnitToMission('BS-136 RFS Orenburg', 'Activation Site A')
		ScenEdit_AssignUnitToMission('K-295 RFS Samara', 'Activation Site A Escort')
	end
elseif a == 2 then
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='BS-136 RFS Orenburg', heading=120, latitude='79.1926405489423', longitude='-161.787673473522'})
	ScenEdit_SetUnit({type='Submarine', side='Russia', name='K-295 RFS Samara', heading=120, latitude='79.3896761594767', longitude='-163.085513047321'})
	if not ScenEdit_GetSideIsHuman('Russia') then
		ScenEdit_AssignUnitToMission('BS-136 RFS Orenburg', 'Activation Site D')
		ScenEdit_AssignUnitToMission('K-295 RFS Samara', 'Activation Site D Escort')
	end
end