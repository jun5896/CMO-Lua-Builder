-- =========================
-- Angola Ceasefire Counter
-- =========================

Angola_CeasefireCounter = Angola_CeasefireCounter + 1
ScenEdit_SetKeyValue('Angola_CeasefireCounterKey', tostring(Angola_CeasefireCounter))

if Angola_CeasefireCounter >= Angola_CeasefireTime then
	ScenEdit_SpecialMessage('playerside', 'Admiral,<BR><BR>POTUS has called for a cessation of hostilities and directed the US Ambassador at the UN to table a Security Council Resolution putting a Cease Fire in place while accusing the Russians of further aggression and destabilizing conduct.<BR><BR>You are directed to recall all attacks and cease hostile actions. The evacuation will continue and a battalion of the 82nd Airborne Division is being flown into Luanda to help stabilize the situation.')
	ScenEdit_SetEvent('Angola Ceasefire Counter', {isactive=false})
	ScenEdit_EndScenario()
end

-- =========================
-- Angola Hostility Check
-- =========================

ScenEdit_SetEvent('Angola Ceasefire Counter', {isactive=true})
ScenEdit_SetEvent('Angola Hostility Check', {isactive=false})

-- =========================
-- Russia Ceasefire Counter
-- =========================

Russia_CeasefireCounter = Russia_CeasefireCounter + 1
ScenEdit_SetKeyValue('Russia_CeasefireCounterKey', tostring(Russia_CeasefireCounter))

if Russia_CeasefireCounter >= Russia_CeasefireTime then
	ScenEdit_SpecialMessage('playerside', 'Admiral,<BR><BR>POTUS has called for a cessation of hostilities and directed the US Ambassador at the UN to table a Security Council Resolution putting a Cease Fire in place while accusing the Russians of further aggression and destabilizing conduct.<BR><BR>You are directed to recall all attacks and cease hostile actions. The evacuation will continue and a battalion of the 82nd Airborne Division is being flown into Luanda to help stabilize the situation.')
	ScenEdit_SetEvent('Russia Ceasefire Counter', {isactive=false})
	ScenEdit_EndScenario()
end

-- =========================
-- Russia Hostility Check
-- =========================

ScenEdit_SetEvent('Russia Ceasefire Counter', {isactive=true})
ScenEdit_SetEvent('Russia Hostility Check', {isactive=false})