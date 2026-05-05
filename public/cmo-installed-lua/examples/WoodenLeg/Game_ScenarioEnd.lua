local sideUnits = VP_GetSide({side='Israel'}).units
local airborneFighters = 0


for k,v in ipairs (sideUnits) do
    local unit = ScenEdit_GetUnit({guid=v.guid})
    if unit.type == 'Aircraft' and unit.dbid == 1771 then
        if GetAltitudeAGL(unit.guid) > 2 then
            airborneFighters = airborneFighters + 1
        end
    end
end

if airborneFighters == 0 then
    local playerInput = ScenEdit_MsgBox('It appears all fighters have returned to base after striking their targets, would you like to end the scenario?\n\nYes to end\nNo to check again in 5 minutes\nCancel to stop checking',3)
    playerInput = string.upper(playerInput)
    if playerInput == 'YES' then
        ScenEdit_EndScenario()
    elseif playerInput == 'CANCEL' then
        ScenEdit_SetEvent('Game_ScenarioEnd',{isactive=false})
    end
end