local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then 
	local penalty = -100
	local sideDescription = ''
	if theDestroyedUnit.side == 'Iran' then 
		sideDescription = 'Iranian'
	elseif theDestroyedUnit.side == 'India' then
		sideDescription = 'Indian'
	elseif theDestroyedUnit.side == 'Civilian' then
		penalty = -1000
		sideDescription = 'Civilian'
	end
	ChangeScore('United States',penalty,'A '..sideDescription..' '..string.lower(theDestroyedUnit.type)..' was destroyed.')
end