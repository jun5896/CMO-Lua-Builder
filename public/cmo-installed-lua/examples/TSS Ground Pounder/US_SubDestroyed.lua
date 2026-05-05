unit = ScenEdit_UnitX()
ChangeScore('USN', -250, unit.name..' was destroyed.')

local submarineList = {
	{name='SSN 755 Miami', guid='3M12KI-0HNEQME9119HT'},
	{name='SSN 758 Asheville', guid='3M12KI-0HNEQME91196B'}
}

local submarinesRemaining = 0

for _,submarine in ipairs(submarineList) do
	local submarineData = ScenEdit_GetUnit({guid=submarine.guid})
	if submarineData ~= nil then
		submarinesRemaining = submarinesRemaining + 1
	end
end

if submarinesRemaining == 0 then
	ScenEdit_EndScenario()
	ScenEdit_MsgBox('All submarines have been destoryed.', 0)
end