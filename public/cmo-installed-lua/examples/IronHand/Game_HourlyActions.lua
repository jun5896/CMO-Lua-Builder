--Weather drift and report if required
if WeatherReportIsDue() then
    WeatherDrift()
    WeatherReportRUS()
end

--Clean up idle civilian ships
CleanUpIdleCivilianShips()