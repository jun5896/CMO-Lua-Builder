local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then 
    if theDestroyedUnit.side == 'United States' or theDestroyedUnit.side == 'Philippines' then
        RunScript('US_UnitDestroyed')
    elseif theDestroyedUnit.side == 'PLAN' or theDestroyedUnit.side == 'CCG' then
        RunScript('PLAN_UnitDestroyed')
    end
end