if WeatherReportIsDue() then
	WeatherDrift()
	WeatherReport()
end

CleanUpIdleCivilianShips()

--failsafe for intel to come through
local intelReceived = ConvertStringToBoolean(ScenEdit_GetKeyValue('intelReceived'))
if not intelReceived then
	local timeHour = TimeIs().hour
	if timeHour >= 22 then
		ScenEdit_RunScript('/Advanced ASW Exercise/Game_IntelReceived.lua')
	end
end