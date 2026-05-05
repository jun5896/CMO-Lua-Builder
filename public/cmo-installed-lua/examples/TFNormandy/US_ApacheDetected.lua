RadioMessageToPlayer("Eagle 6 this is Spark 4 Actual; be advised the Iraqis have a paint on one of your birds. Their comms chatter is going crazy--We're jamming their HF frequencies, but your boys might have a hot reception down there.")

--Iraq weapons free
ScenEdit_SetDoctrine({side='Iraq'},{weapon_control_status_air='0'})

local radarList = {
	{name='Radar (Flat Face B [P-19]) Najaf', guid='726bbfc1-8c0d-4c69-b7b5-2d4c4395b601'},
	{name='Radar (Flat Face B [P-19]) Nukhayb', guid='117f9487-0b13-435b-9ea4-e54a187a14c3'},
	{name='Radar (Flat Face B [P-19]) SW Anbar', guid='380ddb30-ddde-4cc8-b28f-b2feace88f9a'},
	{name='Radar (Side Net HF [PRV-11]) Najaf', guid='0db0748b-cfe0-4d74-b830-41478d9f8ef9'},
	{name='Radar (Side Net HF [PRV-11]) Nukhayb', guid='fc7d47a5-4919-4bfa-9d37-83dbc78ab3b4'},
	{name='Radar (Spoon Rest D [P-18]) Qalib Baqur', guid='46869a33-fab9-45f7-b7bd-cec317048199'},
	{name='Radar (Spoon Rest D [P-18]) Ruwayshid', guid='e77f121d-35f8-4ff2-95c3-e40521aba704'},
	{name='Radar (Spoon Rest D [P-18]) W Najaf', guid='ede4c4c5-3087-4f62-84e1-ad893f8f394c'},
	{name='Radar (Spoon Rest D [P-18]) W Nukhayb', guid='ca802a6d-ef31-4da2-a2c8-94af204e5693'},
	{name='Radar (Squat Eye [P-15M(2)]) SW Najaf', guid='b327fd36-1f23-4b43-90b6-6cc5039a3ed8'},
	{name='Radar (Squat Eye [P-15M(2)]) SW Nukhayb', guid='33d7d180-cec3-40fa-83a2-d025e4dc0eed'}
}

math.randomseed(os.time())

for k,v in pairs (radarList) do
	local chance = math.random(1,100)
	if chance <= 55 then
		local jammedUnit = ScenEdit_GetUnit({guid=v.guid})
		if jammedUnit ~= nil then
			ScenEdit_SetUnit({guid=jammedUnit.guid,OutOfComms=true})
		end
	end
end