if WeatherReportIsDue() then
	WeatherDrift()
	WeatherReport()
end

local remainingShips = 0
local sideUnits = VP_GetSide({side='Syria'}).units
for k,v in ipairs (sideUnits) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	if unit.type == 'Ship' then
		remainingShips = remainingShips + 1
	end
end
if remainingShips == 0 then
	ScenEdit_SpecialMessage('Israel',"All enemy vessels have been destroyed.")
	ScenEdit_EndScenario()
end

CleanUpIdleCivilianShips()