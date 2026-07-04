--Weather drift and report if required
if WeatherReportIsDue() then
    WeatherDrift()
    local playerSide = ScenEdit_PlayerSide()
    if playerSide == 'UK' then
        WeatherReportUK()
    else
        WeatherReportARG()
    end
end

--Clean up idle civilian ships
CleanUpIdleCivilianShips()