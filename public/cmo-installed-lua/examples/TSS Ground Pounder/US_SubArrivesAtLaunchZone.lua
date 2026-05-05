local unit = ScenEdit_UnitX()
local callsign

if unit.guid == '3M12KI-0HNEQME91196B' then
	AshevilleOnStation(true)
	callsign = 'NASH'
end

if unit.guid == '3M12KI-0HNEQME9119HT' then
	MiamiOnStation(true)
	callsign = 'NNMI'
end

msg = ACP126(
	'xcen',
	callsign,
	'p',
	unit.name,
	'CENTCOM',
	'SECRET',
	unit.name..' on station at designated launch zone. awaiting further instruction.'
)

ScenEdit_SpecialMessage('USN', msg)