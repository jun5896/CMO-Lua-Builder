local submarine = {name='SSN 768 Hartford', guid='5e2209cf-f2cc-4893-bb51-bd2f87a3d92f'}
local enemyUnitList = VP_GetSide({side='Russia'}).units

local minRangeToBeSafe = 35
local subIsSafe = true

for k,v in ipairs(enemyUnitList) do
    local range = Tool_Range(submarine.guid,v.guid)
    if range < minRangeToBeSafe then
        subIsSafe = false
    end
end

if subIsSafe then ScenEdit_EndScenario() end