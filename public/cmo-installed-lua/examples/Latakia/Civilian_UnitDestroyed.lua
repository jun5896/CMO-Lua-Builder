local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    ChangeScore('Israel',-500,'A Civilian vessel was sunk.')
end