local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
    ChangeScore('United States',-100,theDestroyedUnit.name..' was sunk.')
    
    local playerUnits = {
        {name='SSN 663 Hammerhead', guid='8563078c-8231-4712-bd12-b9169843eadd'} , 
        {name='SSN 615 Gato', guid='a6929e5b-3877-4543-b50b-83f0bbefce87'} , 
        {name='SSN 606 Tinosa ', guid='e44fea08-3a4f-499d-9c8d-8e604156be89'}
    }

    local playerUnitsRemaining = 0

    for k,v in ipairs(playerUnits) do
        local unit = ScenEdit_GetUnit({guid=v.guid})
        if unit ~= nil then
            playerUnitsRemaining = playerUnitsRemaining + 1
        end
    end

    if playerUnitsRemaining == 0 then
        ChangeScore('United States',-200,'All US submarines were sunk.')
    end
end