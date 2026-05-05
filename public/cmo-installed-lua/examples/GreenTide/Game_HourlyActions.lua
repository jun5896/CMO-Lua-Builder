--Weather drift and report if required
if WeatherReportIsDue() then
	WeatherDrift()
	WeatherReport()
end

--Clean up idle civilian ships
CleanUpIdleCivilianShips()

--Check victory conditions
local scoreSpain, scoreMorocco = ScenEdit_GetScore("Spain"), ScenEdit_GetScore("Morocco")
local relativeScore = scoreSpain - scoreMorocco
if relativeScore >= 1000 then
	local theMessage = ACP126('xcga','JEMAD','z','Jefe del Estado Mayor de la Defensa','comandante grupo alfa','secreto','1. Moroccan government has requested a cease-fire and conceded ownership of the Orta field to Spain. It is understood that the speed, ferocity and tenacity of your actions in securing the Orta platforms were a major factor in this decision. <BR>2. In respect of the Moroccan capitulation hostilities are to cease immediately. <BR>3. Bravo Zulu, Jefe del Estado Mayor de la Defensa sends.')
    ScenEdit_SpecialMessage('playerside',theMessage)
    ChangeScore('Spain',-2000,'A French submarine was destroyed in direct contravention of orders.')
    ScenEdit_EndScenario()
end