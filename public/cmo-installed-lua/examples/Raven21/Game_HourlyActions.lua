if WeatherReportIsDue() then
	WeatherDrift()
	WeatherReport()
end

CleanUpIdleCivilianShips()

local timeHour = TimeIs().hour
if timeHour == 3 then
	local theMessage = GenerateRadioMessageBody('American forces encroaching on the sovereign territory of Somalia, your provocations will not be tolerated.</p> <p>Leave the area immediately or we will use force to defend the territory of the Somali people.','unknown station')

	RadioMessage('VHF','121.5 MHz',theMessage)

	TelexMessageToPlayer(
		'ntbi',
		'COMIDEASTFOR',
		'i',
		'Commander Middle east force',
		'co cv 34 oriskany',
		'secret',
		'1. acknowledge your reports of threatening radio transmissions from somali units.<BR> 2. as per department of state, diplomatic situation is very dynamic. current posturing from ussr indicates a willingness to escalate in order to achieve their goals. <br> 3. direction from POTUS is to coninue with mission and avoid provoking ussr.<br> 4. you are cleared to open fire on somali forces only if absolutely necessary to protect your forces.<br> 4. you are cleared to return fire, repeat return fire only on ussr forces.<br> BT<br> god speed, COMIDEASTFOR sends')
end