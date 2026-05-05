--Weather drift and report if required
if WeatherReportIsDue() then
    WeatherDrift()
    WeatherReport()
end

--Clean up idle civilian ships
CleanUpIdleCivilianShips()