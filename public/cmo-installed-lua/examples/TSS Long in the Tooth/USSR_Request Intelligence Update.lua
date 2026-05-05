submarine = ScenEdit_GetUnit({guid='9bca913e-d0cf-4f0e-bdce-55c7fd26cff5'})
if submarine.altitude > -21 then
time_now = ScenEdit_CurrentTime()
time_lockout = tonumber(ScenEdit_GetKeyValue('lockout'))
if time_lockout == nil then time_lockout = 0 end
if time_now > time_lockout then


	math.randomseed(os.time())

	US_Ships = {
		{name="FF 1079 Bowen", guid='675412cb-4099-4410-a957-161969e07220', type = "Frigate"},
		{name='WHEC 721 Gallatin', guid='74ffb848-2f9d-43ba-91d3-c411e1990a4f', type = "Coast Guard"},
		{name='FF 1061 Patterson', guid='f1b176f0-117f-4709-9aed-6ff93702cb2e', type = "Frigate"},
		{name='FFG 15 Estocin', guid='acbc455a-05e2-4627-aa87-d811ca87d943', type = "Frigate"},
		{name='FF 1091 Miller', guid='77aa4baf-71fc-40b9-82b4-9c86a9721322', type = "Frigate"},
		{name='FF 1090 Ainsworth', guid='a065493b-2617-4ae1-824b-e93c6b3818e2', type = "Frigate"},
		{name='DDG 41 King', guid='5f3d22c2-5ec9-4490-a501-6bb6afcb9b80', type = "Destroyer"},
		{name='WPB 82343 Point Wells', guid='830337ff-e5be-41b9-999f-dbc97d78ee16', type = "Coast Guard"},
		{name='WMEC 902 Tampa', guid='864317d1-0cc1-48ec-a7ff-1bfc96af7dd6', type = "Coast Guard"},
		{name='WPB 82318 Point Herron', guid='608b921d-0a94-41ce-8504-38062224d5ea', type = "Coast Guard"},
	}

	list = {}
	ctr = 0 

	for k,v in pairs(US_Ships) do
		unit = ScenEdit_GetUnit({guid=v.guid})
		if unit then
			ctr = ctr + 1
			list[ctr]=unit
		end
	end

	dtg = DTG()
	intel = ''
	ctr = 0 

	for k,v in pairs(list) do
		chance = math.random(1,5)
		if chance == 1 then
			ctr = ctr + 1
			chance = math.random(1,3)
			if chance == 1 then
				pos_lat = tostring(round(v.latitude,3))
				pos_lon = tostring(round(v.longitude,3))
				pos = pos_lat..'/'..pos_lon
				spd = round(v.speed,0)
				hdg = round(v.heading,0)
				intel = intel..string.upper(v.name..'; pos '..pos..' spd '..spd..' hdg '..hdg..' <BR>') --solid location course and speed
				ScenEdit_AddReferencePoint({side='Soviet Union',name=v.name..' SPD '..spd..' HDG '..hdg..' '..dtg,latitude=v.latitude,longitude=v.longitude,highlighted=true})
			elseif chance == 2 then
				circle = World_GetCircleFromPoint({latitude=v.latitude,longitude=v.longitude,radius=math.random(1,50)/10,numpoints=36})
				rand_point = math.random(1,#circle)
				pos_lat = tostring(round(circle[rand_point].Latitude,3))
				pos_lon = tostring(round(circle[rand_point].Longitude,3))
				pos = pos_lat..'/'..pos_lon
				spd = round(v.speed,0)
				hdg = round(v.heading,0)
				intel = intel..string.upper(v.name..'; pos '..pos..' spd '..spd..' hdg '..hdg..' <BR>')
				ScenEdit_AddReferencePoint({side='Soviet Union',name=v.name..' SPD '..spd..' HDG '..hdg..' '..dtg,latitude=circle[rand_point].Latitude,longitude=circle[rand_point].Longitude,highlighted=true})--+/- 5nm with accurate course and speed
			elseif chance == 3 then
				circle = World_GetCircleFromPoint({latitude=v.latitude,longitude=v.longitude,radius=math.random(1,75)/10,numpoints=36})
				rand_point = math.random(1,#circle)
				pos_lat = tostring(round(circle[rand_point].Latitude,3))
				pos_lon = tostring(round(circle[rand_point].Longitude,3))
				pos = pos_lat..'/'..pos_lon
				intel = intel..string.upper(v.name..'; pos '..pos..' <BR>') 
				ScenEdit_AddReferencePoint({side='Soviet Union',name=v.name..' '..dtg,latitude=circle[rand_point].Latitude,longitude=circle[rand_point].Longitude,highlighted=true})--position only, +/- 7.5nm
			end
		end
	end

	ScenEdit_SetKeyValue('intel',intel)

	time_lockout = tostring(time_now + 7200)
	ScenEdit_SetKeyValue('lockout',time_lockout)
		if intel ~= '' then
			msg = Signal('k 14', 'north fleet hq severomorsk', 'intelligence update', 'cc \\ air', 'the following units have updated intelligence information: <BR>'..intel) --recipient,sender,subject,precedence,body
			ScenEdit_SpecialMessage('Soviet Union',msg)
		else
			msg = Signal('k 14', 'north fleet hq severomorsk', 'intelligence update', 'cc \\ air', 'no updated intelligence available at this time') --recipient,sender,subject,precedence,body
			ScenEdit_SpecialMessage('Soviet Union',msg)
		end
	else

	time_str = DTG(time_lockout)
		ScenEdit_MsgBox('No further intel updates available until '..time_str,6)
	end

	else
		ScenEdit_MsgBox(submarine.name..' is too deep to receive intel updates. Come to periscope depth (-20m/-66ft).',6)
	end

	detected = InterceptCheck()

	if detected == true then
		ScenEdit_SetUnit({guid='9bca913e-d0cf-4f0e-bdce-55c7fd26cff5',autodetectable=true})
		ScenEdit_SetEvent('Game_Autodetect',{isactive=true})
	end
end