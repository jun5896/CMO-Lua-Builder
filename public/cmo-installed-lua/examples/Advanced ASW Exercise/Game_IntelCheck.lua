math.randomseed(os.time())

local sideUnits = VP_GetSide({side="OPFOR"}).units
local submarineCount = 0
for k,v in ipairs (sideUnits) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local unitType = string.upper(unit.type)
	if unitType == 'SUBMARINE' then
		submarineCount = submarineCount + 1
	end
end

local intelReceived = ConvertStringToBoolean(ScenEdit_GetKeyValue('intelReceived'))

if submarineCount < 3 or intelReceived == true then
	ScenEdit_SetKeyValue('intelReceived','true') --if the player has already killed a sub, no intel report
	ScenEdit_SetEvent('Game_IntelCheck',{isactive=false})
else
	local chance = math.random(1,100)
	if chance == 1 then --91.04% chance of occuring within 240 cycles (2 hrs game time)
		ScenEdit_RunScript('/Advanced ASW Exercise/Game_IntelReceived.lua')
	end
end