--Weather drift and report if required
if WeatherReportIsDue() then
    WeatherDrift()
    if ScenEdit_PlayerSide() == 'Soviet Union' then
        WeatherReportUSSR()
    else
        WeatherReportNATO()
    end
end

--failsafe to commence hostilities
CommenceHostilities()

--Clean up idle civilian ships
CleanUpIdleCivilianShips()