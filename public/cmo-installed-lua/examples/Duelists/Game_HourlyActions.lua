--Weather drift and report if required
if WeatherReportIsDue() then
    WeatherDrift()
    local playerSide = ScenEdit_PlayerSide()
    if playerSide == 'United Kingdom' then
        WeatherReportNATO()
    else
        WeatherReportRUS()
    end
end

--Clean up idle civilian ships
CleanUpIdleCivilianShips()