--Weather drift and report if required
if WeatherReportIsDue() then
	WeatherDrift()
	WeatherReport()
end

--check victory conditions
local targetList = {
	{name = "[Target] Shaheen 2 TEL", guid = "19c05eca-2e3d-48f7-829f-38a9c380c45c"},
	{name = "[Target] Minhas Nuclear Storage Bunker", guid = "a2e2be10-5ea8-4e6a-b317-3e422d0b4950"},
	{name = "[Target] Babur TEL", guid = "76575944-bd4a-4cc7-a55d-2a50b9f35cf2"}
}

local counter = 0

for k, v in ipairs(targetList) do
	local unit = ScenEdit_GetUnit({guid = v.guid})
	if unit ~= nil then
		counter = counter + 1
	end
end

if counter == 0 then
	local theMessage =
		ACP126(
		"ols6",
		"centcom",
		"z",
		"us forces central command",
		"commander operation lightning strike",
		"top secret",
		"1. centcom has received confirmation of all rogue pakistani held nuclear devices destroyed<BR> 2. operation lightning strike assessed as success<BR> 3. Bravo zulu, comuscentcom sends"
	)
	ScenEdit_SpecialMessage("playerside", theMessage)
	RegisterMessage(theMessage)
	ScenEdit_EndScenario()
end