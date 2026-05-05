unit = ScenEdit_UnitX()

ChangeScore('USN', 30, unit.name..' reached the safe zone.')

local callsign

if unit.guid== '3M12KI-0HNEQME9119HT' then
	callsign = 'NNMI'
else
	callsign = 'NASH'
end

msg = ACP126(
	'xcen',
	callsign,
	'r',
	unit.name,
	'USCENTCOM',
	'confidential',
	unit.name..' arrived in safe zone. <BR> <BR> resuming patrol.'
)

ScenEdit_SpecialMessage('USN', msg)

ScenEdit_DeleteUnit({guid=unit.guid})

local submarineList = {
	{name='SSN 755 Miami', guid='3M12KI-0HNEQME9119HT'},
	{name='SSN 758 Asheville', guid='3M12KI-0HNEQME91196B'}
}

local submarinesRemaining = 0

for _,submarine in ipairs(submarineList) do
	if submarine.guid == unit.guid then
		goto continue -- Skip the unit that was just deleted
	end

	local submarineData = ScenEdit_GetUnit({guid=submarine.guid})
	if submarineData ~= nil then
		submarinesRemaining = submarinesRemaining + 1
	end

	::continue::
end

if submarinesRemaining == 0 then
	ScenEdit_EndScenario()
	ScenEdit_MsgBox('All submarines have returned to normal operations.', 0)
end