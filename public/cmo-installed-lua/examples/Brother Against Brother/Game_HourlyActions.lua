local theRescueSummary = ScenEdit_GetKeyValue('rescueSummary')
if theRescueSummary ~= nil and theRescueSummary ~= '' then
	local theMessage = ACP126('TODOS','SAROPS','r','search and rescue operations','ALL STATIONS',
			'confidential','sar activity summary for preceding hour as follows:'..theRescueSummary)
	ScenEdit_SpecialMessage('playerside',theMessage)
	RegisterMessage(theMessage)
	ScenEdit_SetKeyValue('rescueSummary','')
end

if WeatherReportIsDue() then
	WeatherDrift()
	WeatherReport()
end

CleanUpIdleCivilianShips()

--failsafe for BL161 to get destroyed
local doomedShip = ScenEdit_GetUnit({guid='60f8741a-53c9-4741-bb80-850431e0b657'})
if doomedShip ~= nil then
	ScenEdit_KillUnit({guid=doomedShip.guid})
end

--failsafe for intel to come through
local intelReceived = ConvertStringToBoolean(ScenEdit_GetKeyValue('intelReceived'))
if not intelReceived then
	local timeHour = TimeIs().hour
	if timeHour >= 12 then
		ScenEdit_ExecuteEventAction('Game_IntelReceived')
	end
end

local gameOver = ConvertStringToBoolean(ScenEdit_GetKeyValue('GameOver'))

if gameOver then 
	ScenEdit_EndScenario()
end
