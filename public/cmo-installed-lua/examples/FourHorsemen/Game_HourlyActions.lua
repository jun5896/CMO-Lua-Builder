--Weather drift and report if required
if WeatherReportIsDue() then
    WeatherDrift()
    WeatherReportSoviet()
end

--Clean up idle civilian ships
CleanUpIdleCivilianShips()