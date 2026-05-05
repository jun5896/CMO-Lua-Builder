ChangeScore('Iran', 1, 'Counter')
unit = ScenEdit_UnitX()
unit_type = string.lower(unit.type)
ChangeScore('USN', -250, 'An Iranian '..unit_type..' was destroyed.')