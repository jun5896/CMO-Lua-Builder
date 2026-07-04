a = math.random(1,4)

if a == 1 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSGN 726 USS Ohio', heading=000, latitude='64.9895121619844', longitude='-168.937832188155'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSGN 726 USS Ohio', 'Cluster Lance - CH1')
	end
elseif a == 2 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSGN 726 USS Ohio', heading=280, latitude='84.4880900702697', longitude='-114.928506179473'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSGN 726 USS Ohio', 'Cluster Lance - SV1')
	end
elseif a == 3 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSGN 726 USS Ohio', heading=300, latitude='86.9702037593431', longitude='-162.632642174002'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSGN 726 USS Ohio', 'Cluster Lance - LP1')
	end
elseif a == 4 then
	ScenEdit_SetUnit({type='Submarine', side='US', name='SSGN 726 USS Ohio', heading=030, latitude='56.9920221149834', longitude='-174.868595650648'})
	if not ScenEdit_GetSideIsHuman('US') then
		ScenEdit_AssignUnitToMission('SSGN 726 USS Ohio', 'Cluster Lance - ES1')	
	end
end