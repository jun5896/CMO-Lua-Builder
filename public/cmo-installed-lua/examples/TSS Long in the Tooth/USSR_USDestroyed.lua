ship = ScenEdit_UnitX()

USN = {2665,2666,1163,2668,269}
for k,v in pairs(USN) do
	if ship.dbid == v then
		ChangeScore('Soviet Union',100,'A US Navy frigate was sunk')
	end
end

USCG = {241,2729,1739}
for k,v in pairs(USCG) do
	if ship.dbid == v then
		ChangeScore('Soviet Union',25,'A USCG cutter was sunk')
	end
end

if ship.dbid == 2059 then
	ChangeScore('Soviet Union',150,'A US Navy destroyer was sunk')
end