local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	ChangeScore('Greece', 100 * -1, 'Civilian '..theDestroyedUnit.classname..' sunk.')
end