ScenEdit_RunScript('DeveloperMode.lua')

function ConvertStringToBoolean(stringName)
	local stringName = string.upper(stringName)
	local result = false
	if stringName == 'TRUE' then
		result = true
	end
	return result
end

function IsBetaVersion(booleanValue)
	if booleanValue == true then
		ScenEdit_SetKeyValue('betaVersion','true')
		return true
	elseif booleanValue == false then
		ScenEdit_SetKeyValue('betaVersion','false')
		return false
	else
		local betaStatus = ScenEdit_GetKeyValue('betaVersion')
		local result = ConvertStringToBoolean(betaStatus)
		return result
	end
end

IsBetaVersion(false)
scenarioZuluOffset = 5 

function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function DebugModeIsOn(booleanValue)
	if booleanValue == true then
		ScenEdit_SetKeyValue('debugMode','true')
		return true
	elseif booleanValue == false then
		ScenEdit_SetKeyValue('debugMode','false')
		return false
	else
		local debugStatus = ScenEdit_GetKeyValue('debugMode')
		local result = ConvertStringToBoolean(debugStatus)
		return result
	end
end

function RandomPosition(latitudeMin,latitudeMax,longitudeMin,longitudeMax)
	local lat_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local lon_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local pos_lat = math.random(latitudeMin,latitudeMax) + (lat_var/(10^13)) --latitude; 
	local pos_lon = math.random(longitudeMin,longitudeMax) + (lon_var/(10^13)) --longitude; 
	return {latitude=pos_lat,longitude=pos_lon}
end

function CircularRandomPosition(x_latitude, x_longitude, max_radius)
	local randomisationCircle = World_GetCircleFromPoint({
		latitude=x_latitude,
		longitude=x_longitude,
		radius=(math.random(0,max_radius*10)/10),
		numpoints = 72})
	local randomisedPoint = randomisationCircle[math.random(1,#randomisationCircle)]
	return randomisedPoint
end

function ShuffleTable( t )
	local rand = math.random 
	assert( t, "ShuffleTable() expected a table, got nil" )
	local iterations = #t
	local j
	
	for i = iterations, 2, -1 do
		j = rand(i)
		t[i], t[j] = t[j], t[i]
	end
end

function ChangeScore(side,amt,reason)
	local newScore = ScenEdit_GetScore(side) + amt
	ScenEdit_SetScore(side,newScore,reason)
	print (side..' score changed to '..newScore)
	return newScore
end

function DTG(TimeVar)
	if TimeVar == nil then
		TimeVar = ScenEdit_CurrentTime()
	end
	local msgtime = os.date("!%d%H%M" .. "Z" .. " " .. "%b %y", TimeVar)
	local msgtime = string.upper(msgtime)
	return msgtime
end

function DTGSoviet(TimeVar)
	if TimeVar == nil then 
	TimeVar = ScenEdit_CurrentTime()
	end
	msgtime = os.date("!%H%M" .. "UTC" .. " " .. "%d %b %y r.", TimeVar)
	msgtime = string.upper(msgtime)
	return msgtime
end

function Signal(recipient,sender,subject,precedence,body)
	local msg_time = DTGSoviet()

	local signal_string = string.upper(
		'<P>'.. precedence.. '\\'..'\\ <BR>' .. 
		'FROM: '..sender..' <BR>' .. 
		'TO: '..recipient..' <BR>' ..
		'SUBJ: '..subject..' <BR>' .. 
		msg_time .. '</P>' ..
		'<P>'..body.. '</P>' ..
		'<P>'..'\\'..'\\'..precedence..'</P>'
	)
	return signal_string
end

function ACP126(rec_station,snd_station,precedence,from,to,classification,body)
	--rec_station --4 letter code (e.g. YDCX)
	--snd_station --4 letter code +/- NR 3 number (e.g. YBDN NR 270)
	--precedence --Flash (Z), Immediate (O), Priority (P), Routine (R), Flash Override (Y)
	local dtg = DTG()
	--from --e.g. MET FLT OPS
	--to --e.g. SSN 21 SEAWOLF
	--classification --Unclass +/- SBU / FOUO / NOFORN (Restricted), Confidential, Secret, Top Secret
	--body
	_,gr = body:gsub("%S+","")
	local sig_string = string.upper('<P><FONT face=Consolas>'..rec_station..' <BR>'..
	'DE '..snd_station..' <BR>'..
	precedence..' '..dtg..' <BR>'..
	'fm '..from..' <BR>'..
	'to '..to..' <BR>'..
	'wd gr'..gr..' <BR>'..
	'bt <BR>'..
	classification..' <BR>'..
	body..' <BR>'..
	'bt <BR>'..
	'nnnn </P>')
	return sig_string
end

function RegisterMessage(messageString)
	local counter = 0
	for int1 = 1, 10 do
		local storedMessage = ScenEdit_GetKeyValue('storedMessage_'..int1)
		if storedMessage ~= nil then
			counter = counter + 1
		end
	end
	
	if counter == 10 then
		for int2 = 1, 10 do
			local shiftedMessage = ScenEdit_GetKeyValue('storedMessage_'..int2)
			local shiftedMessageSlot = int2 - 1
			ScenEdit_SetKeyValue('storedMessage_'..shiftedMessageSlot,shiftedMessage)
		end
		messageNumber = 10
	elseif counter <= 9 then
		messageNumber = counter + 1
	elseif counter == 0 then
		messageNumber = 1
	end
	ScenEdit_SetKeyValue('storedMessage_'..messageNumber,messageString)	
end

function ReplayMessages()
	for i = 10,1,-1 do
		local message = ScenEdit_GetKeyValue('storedMessage_'..i)
		if message ~= nil and message ~= '' then
			ScenEdit_SpecialMessage('playerside',message)
		end
	end
end

function GenerateRainDescriptor(rain)
	local result 
	if rain == 0 then  result = 'nil'
		elseif rain < 5 then  result = 'very light'
		elseif rain < 11 then  result = 'light'
		elseif rain < 20 then  result = 'moderate'
		elseif rain < 30 then  result = 'heavy'
		elseif rain < 40 then  result = 'very heavy'
		else  result = 'extreme'
	end
	return result
end

function GenerateCloudDescriptor(cloud)
	local result
	if cloud == 0 then  result = 'clear skies'
		elseif cloud < 0.2 then result = 'light low clouds'
		elseif cloud < 0.3 then result = 'light middle clouds'
		elseif cloud < 0.4 then result = 'light high clouds'
		elseif cloud < 0.5 then result = 'moderate low clouds'
		elseif cloud < 0.6 then result = 'moderate middle clouds'
		elseif cloud < 0.7 then result = 'moderate high clouds'
		elseif cloud < 0.8 then result = 'moderate middle clouds & light high clouds'
		elseif cloud < 0.9 then result = 'solid middle clouds & moderate high clouds'
		elseif cloud < 1.0 then result = 'thin fog & solid cloud cover'
		else result = 'thick fog & solid cloud cover'
	end
	return result
end

function ConvertTempCtoF(temp)
	local result = Round((temp*1.8) + 32,0)
	return result
end

function WeatherReport(outlook)
	if outlook == nil then outlook = 'next forecast at '..DTG(ScenEdit_CurrentTime()+21600) end

	local weather, DTG = ScenEdit_GetWeather(), DTG()
	local tempC, tempF, cloud, rain, sea = weather.temp, ConvertTempCtoF(weather.temp), GenerateCloudDescriptor(weather.undercloud), GenerateRainDescriptor(weather.rainfall), weather.seastate

	local theMessage = ACP126(
		'ALL',
		'metoc',
		'r',
		'Naval Meteorology and Oceanography Command',
		'ALL STATIONS',
		'unclass',
		'WX REPORT ' .. DTG .. 
		' - GULF OF Arabia <BR>AVERAGE TEMP '..
		tempC ..'°C / '..
		tempF..'°F <BR> SEA STATE '.. sea ..
		' <BR>'..rain..' PRECIPITATION <BR>'..
		cloud..' <BR>'..outlook)

	ScenEdit_SpecialMessage('playerside',theMessage)
	RegisterMessage(theMessage)
end

function TimeIs(timeVar)
	if timeVar == nil then timeVar = ScenEdit_CurrentTime() end
	local timeStampTable = os.date("!*t",timeVar)
	local timeTable = {day = timeStampTable.day, 
		hour = timeStampTable.hour, 
		minute = timeStampTable.min}
	return timeTable
end

function ReturnTimeStringAsNumberOfMinutes(targetString)
	if string.len(targetString) < 3 then --Is this already a number of minutes?
		result = tonumber(targetString)
	else --if not, parse the string to get the values
		local hourDelimiter = string.find(targetString,' hr')
		if hourDelimiter ~= nil then 
			hour = string.sub(targetString,1,hourDelimiter-1) 
		end
		local minuteDelimiter = string.find(targetString,' min')
		if minuteDelimiter ~= nil then 
			minute = string.sub(targetString,hourDelimiter+3,minuteDelimiter-1) 
		end
		result = (hour*60)+minute
	end
	return result
end

function WeatherDrift()
	local weatherBaseline = { seastate = 1, temp = 23, undercloud = 0.30000000, rainfall = 0 }
	local seastateVariability = math.random(0,2)
	local undercloudVariability = 0
	local tempVariability = math.random(-1,4)
	local rainfallVariability = 0

	local newTemp =  weatherBaseline.temp + tempVariability
	local newRainfall = weatherBaseline.rainfall + rainfallVariability
	local newUndercloud = weatherBaseline.undercloud + undercloudVariability
	local newSeastate = weatherBaseline.seastate + seastateVariability

	ScenEdit_SetWeather(
		newTemp, --temp
		newRainfall, --rainfall
		newUndercloud, --undercloud
		newSeastate --seastate
	)
end

function BugMessage(eventName,description)
	if IsBetaVersion() then
		ScenEdit_MsgBox('An issue occured with '..eventName..';\n'..description..'\n\nThis will not affect system stability but may affect scenario balance. \n\nPlease report this in the Beta Testing Forum. \n\nThanks!', 0)
	else
		ScenEdit_MsgBox('An issue occured with '..eventName..';\n'..description..'\n\nThis will not affect system stability but may affect scenario balance. \n\nPlease report this in the Tech Support subforum on the Matrix Games forum, including a screenshot of this message. \n\nhttp://www.matrixgames.com/forums/tt.asp?forumid=1279', 0)
	end
end

function WeatherReportIsDue()
	local result = false
	local hourZulu = TimeIs().hour
	local hourLocal = hourZulu + scenarioZuluOffset
	if hourLocal %6 == 0 then
			result = true
	end
	return result
end

function CleanUpIdleCivilianShips()
	local unitList = VP_GetSide({side='Civilian'}).units
	local numberOfCivilianUnits = #unitList
	local numberOfUnitsDeleted = 0
	for k,v in ipairs (unitList) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if (unit.course[1] == nil or unit.speed == 0) and 
			unit.type == 'Ship' then
			ScenEdit_DeleteUnit({guid=v.guid})
			numberOfUnitsDeleted = numberOfUnitsDeleted + 1
		end
	end

	if DebugModeIsOn() and numberOfUnitsDeleted > 0 then
		ScenEdit_SpecialMessage('playerside','Civ_Cleanup fired. <BR>Initial civilian Units: '..numberOfCivilianUnits..' <BR>Civilian units cleaned up: '..numberOfUnitsDeleted)
	end
end

function OverWater (latitude, longitude)
	local pointElevation = World_GetElevation({
		latitude = latitude,
		longitude = longitude})
	if pointElevation < 0 then
		return true
	else
		return false
	end
end

function CreateGUIDKeyName(guid)
	return 'x_'..guid
end

function RetrieveGUIDFromKey(key)
	local stringLength = string.len(key)
	local result = string.sub(key,3,stringLength)
	return result
end

function GenerateRadioMessageBody(theMessage,callsign)
	local result
	if callsign == nil then callsign = 'unk stn' end
	result = '<P>'..string.upper(callsign)..'<BR> <I>"'..theMessage..'"</I></P> '
	return result
end

function RadioMessage(band,frequency,theMessage,location)
	assert(theMessage,'RadioMessage(): No message passed!')
	local DTG = DTG()
	local theMessage = "<P>"..DTG..' <BR>'..band..' <BR>'..frequency..' </P>'..theMessage
	if location ~= nil then
		ScenEdit_SpecialMessage('playerside',theMessage,{latitude=location.latitude,longitude=location.longitude})
	else
		ScenEdit_SpecialMessage('playerside',theMessage)
	end
	RegisterMessage(theMessage)
end

function ConvertDecimalPositionToDegrees(latitude,longitude)
	local latitidePrefix, longitudePrefix
	if latitude > 0 then
		latitidePrefix = "N"
	else
		latitidePrefix = "S"
		latitude = latitude*-1
	end

	local latitudeDegrees = math.floor(latitude)
	local latitudeMinutes = math.floor((latitude - latitudeDegrees)*60)
	local latitudeSeconds = (((latitude-latitudeDegrees)*60) - latitudeMinutes)*60
	latitudeSeconds = Round(latitudeSeconds, 0)

	if longitude > 0 then
		longitudePrefix = "E"
	else
		longitudePrefix = "W"
		longitude = longitude*-1
	end

	local longitudeDegrees = math.floor(longitude)
	local longitudeMinutes = math.floor((longitude - longitudeDegrees)*60)
	local longitudeSeconds = (((longitude-longitudeDegrees)*60) - longitudeMinutes)*60
	longitudeSeconds = Round(longitudeSeconds, 0)

	local result = (latitidePrefix..latitudeDegrees .. "°" .. latitudeMinutes .. "'" .. latitudeSeconds .. '", '..
		longitudePrefix..longitudeDegrees .. "°" .. longitudeMinutes .. "'" .. longitudeSeconds .. '"')
	return result
end

function RandomLetter()
	local alphabet = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
	return string.upper(alphabet[math.random(1,#alphabet)])
end

-- SCENARIO SPECIFIC

-- Pakistan Air Defence Zones

airDefenceAircraft = {
	{zone='Central',type='Aircraft',dbid=364,name='Skybolt-M #1',guid='378dcf53-d82f-44e8-b7e8-283797eb290a',},
	{zone='Central',type='Aircraft',dbid=364,name='Skybolt-M #2',guid='674770d4-9654-4316-a967-faee079e4b63',},
	{zone='Central',type='Aircraft',dbid=364,name='Skybolt-R #1',guid='6642c166-956f-4a16-9768-ef151501ec05',},
	{zone='Central',type='Aircraft',dbid=364,name='Skybolt-R #2',guid='0ee33f17-4dd5-44d5-9429-c827150510b6',},
	{zone='Central',type='Aircraft',dbid=364,name='Skybolt-R #3',guid='b8db6ecb-56f9-4335-9820-70bc355eba6c',},
	{zone='Central',type='Aircraft',dbid=364,name='Skybolt-R #4',guid='25a53391-aed3-499c-8fba-1472f9e23805',},
	{zone='Central',type='Aircraft',dbid=2916,name='Falcon-S #1',guid='b9974351-8639-4775-a1fb-6f3df3d2c6dd',},
	{zone='Central',type='Aircraft',dbid=2916,name='Falcon-S #2',guid='261a1ffd-ae2a-43bf-92ec-04e7c5fc893d',},
	{zone='North',type='Aircraft',dbid=364,name='Skybolt Murid #1',guid='ef172f51-f73b-4280-b017-07a371169131',},
	{zone='North',type='Aircraft',dbid=364,name='Skybolt Murid #2',guid='ec3857ad-63d3-494f-9035-f7f2f6321959',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #1',guid='ab11aeab-b741-49c1-aa4d-611b15e011a7',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #2',guid='cf269940-49db-4444-ab02-3818699b6d86',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #3',guid='6d43698d-70ae-47ef-a0ef-86d614874a5f',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #4',guid='dc80f642-36ea-4f6d-8056-3dc4c1855abf',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #5',guid='0b6b7ddd-403c-44c9-9d5d-e0fc5d9c7504',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #6',guid='f68f2717-c280-4830-a708-54bb641ff2a1',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #7',guid='e372f03e-cdd1-48aa-824a-29acaa5e3402',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #8',guid='998b3c35-8357-4b38-af62-9265806395dc',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #9',guid='8e1166eb-06a0-492d-9fef-6b06bafc1d7d',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #10',guid='ca883c38-3f7e-48bf-bddc-2a67c464f870',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #11',guid='6a75e2d8-6b72-4eee-832c-edd6afbf48b6',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #12',guid='7a29edd1-8410-41e0-8564-e330ef56626a',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #13',guid='7518c6c3-1e4c-44f2-aa1c-aa6688de9b0b',},
	{zone='North',type='Aircraft',dbid=365,name='Thunder-Peshwar #14',guid='c2e2efe9-c142-4ba7-a92a-1af170eb55bd',},
	{zone='North',type='Aircraft',dbid=2913,name='Erieye #1',guid='4b5e26ff-e950-4f0f-8e76-2bd165896d78',},
	{zone='North',type='Aircraft',dbid=2913,name='Erieye #2',guid='2fa45f68-ed15-4fbc-9060-6b6e148f97a5',},
	{zone='North',type='Aircraft',dbid=2913,name='Erieye #3',guid='b956dd41-e736-4132-ae39-77aeda9896af',},
	{zone='South',type='Aircraft',dbid=2161,name='Mirage #1',guid='2eb38291-5f5d-4088-a30f-d712e3ea0361',},
	{zone='South',type='Aircraft',dbid=2161,name='Mirage #2',guid='73e673cd-b111-437c-b2a9-1977d122d047',},
	{zone='South',type='Aircraft',dbid=2161,name='Mirage #3',guid='73e198ea-dcb8-4e45-8100-233125a1af52',},
	{zone='South',type='Aircraft',dbid=2161,name='Mirage #4',guid='bc5088b7-761a-415c-bfcf-7dfe9ad26700',},
	{zone='South',type='Aircraft',dbid=2914,name='Y-8 #1',guid='f1594866-c752-4acc-916b-720d905fa222',},
	{zone='South',type='Aircraft',dbid=2915,name='Falcon Jac #1',guid='2c99359a-d5f5-42a3-a9c6-2ddc1ea1236f',},
	{zone='South',type='Aircraft',dbid=2915,name='Falcon Jac #2',guid='ece69877-2ea0-4d9f-8473-cecb70b6b8d7',},
	{zone='South',type='Aircraft',dbid=2915,name='Falcon Jac #3',guid='02d5f2c6-fb8e-417e-bb3c-ab2379226ed4',},
	{zone='South',type='Aircraft',dbid=2915,name='Falcon Jac #4',guid='67932f1a-54d1-4fc2-8ebd-f12e99af028c',},
	{zone='West',type='Aircraft',dbid=363,name='Airguard #1',guid='179b1b58-5108-4d51-81a3-e9e9f6f8e8e6',},
	{zone='West',type='Aircraft',dbid=363,name='Airguard #2',guid='f8cafd4a-ccd4-4da8-819e-d8a8c3c2034c',},
	{zone='West',type='Aircraft',dbid=363,name='Airguard #3',guid='132b3d72-f3c9-4fb5-865e-8ad2d6715dc9',},
	{zone='West',type='Aircraft',dbid=363,name='Airguard #4',guid='47d5b957-6888-4aff-a7d3-7a8251458dea',},
}

airDefenceFacilities = {
	{zone='ADHQ',type='Facility',dbid=5,name='Chaklala Air Defense HQ',guid='60c8099b-30e9-4646-b65f-cf18490c2814',},
	{zone='Central',type='Facility',dbid=100,name='Air Defense Sector HQ Central',guid='fab43e73-62af-4a22-8f9a-22e2fb36252c',},
	{zone='Central',type='Facility',dbid=362,name='AN/FPS-100',guid='7eef54f1-ca27-45ac-921e-0848d2e4b41b',},
	{zone='Central',type='Facility',dbid=1088,name='AAA Sec (35mm Oerlikon x 2, Skyguad FCR) -- Pakistan (Air Force), 0-0, 2x Bty',guid='6ad59d3f-3851-4101-ae6f-ed1603e79171',},
	{zone='Central',type='Facility',dbid=1349,name='AN/TPS-77',guid='9cd41b88-0701-463b-8653-7abc918d9373',},
	{zone='Central',type='Facility',dbid=1349,name='AN/TPS-77',guid='9edb3e30-23df-4870-acba-a148991c763a',},
	{zone='Central',type='Facility',dbid=1349,name='AN/TPS-77',guid='44f9130f-c24c-436b-a12f-69cb08255d63',},
	{zone='Central',type='Facility',dbid=1349,name='AN/TPS-77',guid='40176b77-ea6c-45c4-9dea-41b6c5da0300',},
	{zone='Central',type='Facility',dbid=1456,name='MPDR-45',guid='68163fcb-7b03-4e64-a689-3d460636b28e',},
	{zone='Central',type='Facility',dbid=1456,name='MPDR-45',guid='300959c3-bbaf-45d4-a6d9-37865122da23',},
	{zone='Central',type='Facility',dbid=1456,name='MPDR-45',guid='b0869223-e545-49bd-8d3a-d8c2d290df65',},
	{zone='Central',type='Facility',dbid=1592,name='PAF Rafiqui/Shorkot',guid='e81195b2-bf54-4688-adc9-6dffb93bbc65',},
	{zone='Central',type='Facility',dbid=1605,name='AN/FPS-89 HF',guid='a9f95c81-e664-4c07-98fb-1ea5e8b535e1',},
	{zone='Central',type='Facility',dbid=1713,name='PAF Mushaf/PAF Sargodha',guid='0d92db6f-1c81-403a-b322-b2c4321081b0',},
	{zone='Central',type='Facility',dbid=1714,name='PAF Mianwali',guid='108d2d8f-fa35-4533-89b8-9118738539a0',},
	{zone='Central',type='Facility',dbid=1866,name='Radar (RAC-3D) -- Pakistan (Air Force), 2012-0, Spada 2000',guid='0c1c9ee9-1e87-4ab6-976d-22033ca784f7',},
	{zone='Central',type='Facility',dbid=1866,name='Radar (RAC-3D) -- Pakistan (Air Force), 2012-0, Spada 2000',guid='f2333362-3042-48bd-97cb-4b75892b05e0',},
	{zone='Central',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='79e3dd91-ee25-4375-b199-a7d22b826d94',},
	{zone='Central',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='162e28c6-912a-4b02-95a3-e13097c5a7ca',},
	{zone='Central',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='af0842c3-adbe-4281-8954-f2ef57d0b07e',},
	{zone='Central',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='fc2358b0-93d5-41f1-8b0f-006b6d7777d3',},
	{zone='North',type='Facility',dbid=100,name='Air Defense Sector HQ North',guid='e3f49c5e-deca-4eee-bd3e-7453c329b477',},
	{zone='North',type='Facility',dbid=430,name='PAF Skardu/Skardu Airport',guid='2da1d606-4923-414c-ad59-67f0db9fd1ab',},
	{zone='North',type='Facility',dbid=586,name='AN/TPS-43',guid='2da47cc9-b8e6-4623-ba23-8cd7d4937c88',},
	{zone='North',type='Facility',dbid=762,name='HQ-2 Site',guid='fb7f5459-9a27-4d18-84da-3538fc47c9e9',},
	{zone='North',type='Facility',dbid=1088,name='AAA Sec (35mm Oerlikon x 2, Skyguad FCR) -- Pakistan (Air Force), 0-0, 2x Bty',guid='18d92539-26d4-4938-a24b-b8a0e922e33a',},
	{zone='North',type='Facility',dbid=1456,name='MPDR-45',guid='02ba2e85-0a32-4c18-8fa3-1f13ba7ee831',},
	{zone='North',type='Facility',dbid=1456,name='MPDR-45',guid='458681e0-e1aa-41dc-a6f9-51537038550a',},
	{zone='North',type='Facility',dbid=1456,name='MPDR-45',guid='b644274b-1eb1-44f4-a899-4635a7d60112',},
	{zone='North',type='Facility',dbid=1456,name='MPDR-45',guid='bcd63f84-0820-4862-b39c-15e74314a7cd',},
	{zone='North',type='Facility',dbid=1456,name='MPDR-45',guid='d3751b65-d79e-4850-801f-340c5bfab6c1',},
	{zone='North',type='Facility',dbid=1712,name='PAF Peshawar',guid='72cbef30-7622-40ae-a882-bec5f2fc28ca',},
	{zone='North',type='Facility',dbid=1713,name='Benazir Bhutto International Airport/PAF Chaklala',guid='d313b9ca-6f8e-440e-8658-c2542386ffa3',},
	{zone='North',type='Facility',dbid=1713,name='PAF Murid',guid='e200fb6a-0a0a-4f48-bad1-821c70a96f61',},
	{zone='North',type='Facility',dbid=1866,name='Radar (RAC-3D) -- Pakistan (Air Force), 2012-0, Spada 2000',guid='b4a78a19-24fa-4ac9-817f-37d027783117',},
	{zone='North',type='Facility',dbid=1866,name='S Radar (RAC-3D)',guid='37fa6b5b-4e43-4013-a355-5e0d04274788',},
	{zone='North',type='Facility',dbid=1868,name='S SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='afcedae7-2231-46b0-ba2a-bd9e9765373e',},
	{zone='North',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='c61b50f5-1a64-4f67-b392-50c35b34db54',},
	{zone='North',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='e8441c11-5e73-4729-a5b4-fca0504fc6f7',},
	{zone='South',type='Facility',dbid=100,name='Air Defense Sector HQ South',guid='6de8dd88-ab9c-432f-aa11-77455d67d7cc',},
	{zone='South',type='Facility',dbid=586,name='AN/TPS-43',guid='2bb77670-5ccb-4894-b68d-2400ef49ce11',},
	{zone='South',type='Facility',dbid=1088,name='AAA Sec (35mm Oerlikon x 2, Skyguad FCR) -- Pakistan (Air Force), 0-0, 2x Bty',guid='7a386fe5-f42a-4c73-949e-db5ded255016',},
	{zone='South',type='Facility',dbid=1088,name='AAA Sec (35mm Oerlikon x 2, Skyguad FCR) -- Pakistan (Air Force), 0-0, 2x Bty',guid='334aa384-e7b5-43d2-9451-7cd91a54c843',},
	{zone='South',type='Facility',dbid=1088,name='AAA Sec (35mm Oerlikon x 2, Skyguad FCR) -- Pakistan (Air Force), 0-0, 2x Bty',guid='a617dc3c-5a7b-4f0a-bac2-f5eb88ca9b8f',},
	{zone='South',type='Facility',dbid=1349,name='AN/TPS-77',guid='30f540cd-969e-4653-98b6-09f575549990',},
	{zone='South',type='Facility',dbid=1349,name='AN/TPS-77',guid='0797f1a7-43f5-4b39-8ef0-aed9cd310d58',},
	{zone='South',type='Facility',dbid=1349,name='AN/TPS-77',guid='f3e302e7-b767-4b70-b5c0-23f5566da155',},
	{zone='South',type='Facility',dbid=1455,name='YLC-2',guid='04c1198a-dede-4f17-924d-798cb746beb8',},
	{zone='South',type='Facility',dbid=1455,name='YLC-2',guid='184708c7-e894-47d5-a60b-58d2b0287c16',},
	{zone='South',type='Facility',dbid=1456,name='MPDR-45',guid='a3958aec-6dd2-43b0-a114-a309cbaf03f8',},
	{zone='South',type='Facility',dbid=1456,name='MPDR-45',guid='c0a8ba22-07f2-4264-a1fe-ed0aa4509285',},
	{zone='South',type='Facility',dbid=1592,name='PAF Nawabshah',guid='b678c2be-a8c9-434f-a99d-e4f9422ea289',},
	{zone='South',type='Facility',dbid=1592,name='Shamsi Airport',guid='3ac29e56-0f38-4125-a557-ebc37a6ea1c1',},
	{zone='South',type='Facility',dbid=1594,name='Gwadar Airport',guid='3607603c-e8c6-40e5-8763-269417ce27eb',},
	{zone='South',type='Facility',dbid=1594,name='Omara Airport',guid='803857ce-f630-4a81-a03e-8e855423d7ec',},
	{zone='South',type='Facility',dbid=1712,name='Hyderabad Airport',guid='7baa6854-7686-4155-b447-234f7868e4c6',},
	{zone='South',type='Facility',dbid=1712,name='Pasni Airport/PAF Pasni',guid='3259b600-efb9-4681-a2e5-00797c6712b3',},
	{zone='South',type='Facility',dbid=1712,name='Sukkur Airport/PAF Sukkur',guid='312b73e4-3773-4408-8f8a-d9af4cff2e15',},
	{zone='South',type='Facility',dbid=1712,name='Turbat Airport',guid='63decac7-5df2-4ee2-9959-2c32dda954ec',},
	{zone='South',type='Facility',dbid=1713,name='PAF Faisal/PNS Mehran',guid='b3fa1f05-9a69-4dc3-9959-c2e443c0702b',},
	{zone='South',type='Facility',dbid=1713,name='PAF Masroor',guid='a639084a-1d6a-4e2e-8c8e-f81b29da8425',},
	{zone='South',type='Facility',dbid=1714,name='Jinnah International Airport',guid='53b01ff2-be39-47fc-a597-69932d6f4b91',},
	{zone='South',type='Facility',dbid=1714,name='PAF Shahbaz/Jacobabad Airport',guid='ab4015ef-4240-476a-8035-8ec68e8df882',},
	{zone='South',type='Facility',dbid=1866,name='Radar (RAC-3D) -- Pakistan (Air Force), 2012-0, Spada 2000',guid='551360c3-4e5d-4eb8-8526-ae185e4b7159',},
	{zone='South',type='Facility',dbid=1866,name='Radar (RAC-3D) -- Pakistan (Air Force), 2012-0, Spada 2000',guid='cbf692ba-8cc7-4f33-b5f0-5d54f35e3691',},
	{zone='South',type='Facility',dbid=1866,name='Radar (RAC-3D) -- Pakistan (Air Force), 2012-0, Spada 2000',guid='f79d7ee4-5ea0-4d75-9d87-da5d7fd56917',},
	{zone='South',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='1b71372c-7c57-40fb-8a2c-30ca09380d11',},
	{zone='South',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='86373044-aa38-4050-887b-66f5f0778743',},
	{zone='South',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='a0eba51b-6ba5-48bc-b401-924216c2a301',},
	{zone='South',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='c72e6282-c2b4-4fc1-ae77-44cd51a664a3',},
	{zone='South',type='Facility',dbid=1868,name='SAM Plt (Spada 2000 [Aspide]) -- Pakistan (Air Force), 2012-0, 2x + RAC-3D pr Bty',guid='c4862589-1191-45ca-bc0a-6c5ea437007d',},
	{zone='West',type='Facility',dbid=100,name='Air Defense Sector HQ West',guid='1cb96e59-afd9-4038-a4ec-48fb05f2516b',},
	{zone='West',type='Facility',dbid=430,name='PAF Samungli/Quetta International Airport',guid='2be5f89f-9a26-4d80-a258-d6f79863ddfa',},
	{zone='West',type='Facility',dbid=586,name='AN/TPS-43',guid='73b825f9-3401-4693-9de7-b0b53f4c750d',},
}

----------------------------------

function ReturnZoneOfAircraft(guid)
	local result = nil
	for k,v in ipairs (airDefenceAircraft) do
		if guid == v.guid then
			result = v.zone
			break
		end
	end
	return result
end

function ReturnZoneOfFacility(guid)
	local result = nil
	for k,v in ipairs (airDefenceFacilities) do
		if guid == v.guid then
			result = v.zone
			break
		end
	end
	return result
end

function ReturnZoneOfADUnit(unitType, guid)
	local result = nil

	if unitType == 'Aircraft' then
		result = ReturnZoneOfAircraft(guid)
	elseif unitType == 'Facility' then
		result = ReturnZoneOfFacility(guid)
	end

	return result
end

function DisruptPKAirDefenceZone(unitType, guid)
	local affectedZone = ReturnZoneOfADUnit(unitType, guid)
	
	if not affectedZone then
		ScenEdit_MsgBox("DisruptPKAirDefenceZone: No Zone Identified for GUID " .. guid)
		return
	end

	ScenEdit_SetDoctrine({side="Pakistan"}, {weapon_control_status_air=1})

	for k,v in ipairs(airDefenceFacilities) do
		if affectedZone == 'ADHQ' or affectedZone == v.zone then
			ScenEdit_SetUnit({guid=v.guid, outofcomms=true})
		end
	end
end

-- Gameplay Notes

function ThisIsFirstLoad(booleanValue)
	local result
	if booleanValue == nil then
		result = ScenEdit_GetKeyValue('firstLoad')
		if result == '' or result == nil then result = true end
		if result == 'false' then result = false end
	else
		if booleanValue == true then
			ScenEdit_ClearKeyValue('firstLoad')
			result = true
		elseif booleanValue == false then
			ScenEdit_SetKeyValue('firstLoad','false')
			result = false
		end
	end
	return result
end

function DisplayGamePlayNotes()
	local gameplayNotes = '<h1>Gameplay Notes</h1> <P>This scenario uses communications disruption, which is built in to the scenario and does not require any activation by the player. When a relevant enemy headquarters sustains enough damage units under their command may fall off the communications grid, severely hampering coordination. You will be notified via Special Message when this happens. The scenario briefing may contain hints as to where the headquarters are; or you may have to deduce this yourself...</P>'
	ScenEdit_SpecialMessage('playerside',gameplayNotes)
end

if ThisIsFirstLoad() and not inDevelopment then
	DisplayGamePlayNotes()
	ThisIsFirstLoad(false)
end