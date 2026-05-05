local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
    ChangeScore('Argentina',-1500,'ARA San Luis was lost.')
    ScenEdit_EndScenario()
end