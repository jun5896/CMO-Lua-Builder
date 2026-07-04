--Weather drift and report if required
if WeatherReportIsDue() then
    WeatherDrift()
    local playerSide = ScenEdit_PlayerSide()
    if playerSide == 'PLAN' then
        WeatherReportPRC()
    else
        WeatherReportUS()
    end
end

--Clean up idle civilian ships
CleanUpIdleCivilianShips()