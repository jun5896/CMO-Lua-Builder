local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then 
    if theDestroyedUnit.side == 'United States' then
        RunScript('US_UnitDestroyed')
    elseif theDestroyedUnit.side == 'Pakistani Separatists' then
        RunScript('BadPK_UnitDestroyed')
    elseif theDestroyedUnit.side == 'Pakistan' then
        RunScript('PK_UnitDestroyed')
    else
        if theDestroyedUnit.side == 'Iran' then 
            sideDescription = 'Iranian'
        elseif theDestroyedUnit.side == 'India' then
            sideDescription = 'Indian'
        end
        ChangeScore('United States',-100,'A '..sideDescription..' '..string.lower(theDestroyedUnit.type)..' was destroyed,')
    end
end