local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then 
    if theDestroyedUnit.side == 'United States' then
        RunScript('US_UnitDestroyed')
    elseif theDestroyedUnit.side == 'Somalia' then
        RunScript('Somalia_UnitDestroyed')
    elseif theDestroyedUnit.side == 'Soviet Union' then
        RunScript('USSR_UnitDestroyed')
    elseif theDestroyedUnit.side == 'Civilian' then
        RunScript('Civilian_UnitDestroyed')
    end
end

if theDestroyedUnit.side == 'Map Markers' and theDestroyedUnit.dbid == 1786 then
    ChangeScore('United States',1000,'Wreckage of Raven 21 destroyed.')
end