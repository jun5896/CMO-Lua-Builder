local submarine = {name='S 131 Hangor ', guid='01c88519-69ea-4fb8-b0cb-1b2f91f9cada'}
local enemyUnitList = VP_GetSide({side='India'}).units

local minRangeToBeSafe = 35
local subIsSafe = true

for k,v in ipairs(enemyUnitList) do
    local range = Tool_Range(submarine.guid,v.guid)
    if range < minRangeToBeSafe then
        subIsSafe = false
    end
end

if subIsSafe then ScenEdit_EndScenario() end