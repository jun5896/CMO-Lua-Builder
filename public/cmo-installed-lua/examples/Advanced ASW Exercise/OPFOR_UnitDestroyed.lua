local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type == 'Submarine' then
	ChangeScore('FOST Units',500,theDestroyedUnit.name..' was sunk')
end