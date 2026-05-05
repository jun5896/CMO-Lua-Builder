--Weather drift and report if required
if WeatherReportIsDue() then
	WeatherDrift()
	WeatherReport()
end

--Clean up idle civilian ships
CleanUpIdleCivilianShips()

---Top up fuel for Dhows
local sideUnitList = VP_GetSide({side='Neutral'}).units

local shipList = {}

for k,v in ipairs (sideUnitList) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	if unit.type == 'Ship' then table.insert(shipList,unit) end
end

for k,v in ipairs (shipList) do
    local unit = ScenEdit_GetUnit({guid=v.guid})
    ScenEdit_SetUnit({guid=unit.guid,fuel={{'DieselFuel',Round(unit.fuel[3001].max*0.95)}}})
end

--Check victory conditions
local tenerifeIsClear = ConvertStringToBoolean(ScenEdit_GetKeyValue('tenerifeIsClear'))
local granCanariaIsClear = ConvertStringToBoolean(ScenEdit_GetKeyValue('granCanariaIsClear'))
local tenerifeLandingIsComplete = ConvertStringToBoolean(ScenEdit_GetKeyValue('tenerifeLandingIsComplete'))
local granCanariaLandingIsComplete = ConvertStringToBoolean(ScenEdit_GetKeyValue('granCanariaLandingIsComplete'))

if tenerifeIsClear and granCanariaIsClear and tenerifeLandingIsComplete and granCanariaLandingIsComplete then
	theMessage = ACP126()
	ScenEdit_SpecialMessage('playerside',theMessage)
	ScenEdit_EndScenario()
end