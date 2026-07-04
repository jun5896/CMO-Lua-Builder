local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then 
        RunScript(theDestroyedUnit.side..'_UnitDestroyed')
end