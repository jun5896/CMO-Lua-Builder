scenarioScriptFilePath = '/GreenTide/'

function RunScript(fileName)
	local scriptFilePath = scenarioScriptFilePath..fileName..'.lua'
	print ('Attempting to execute '..scriptFilePath)
	if ScenEdit_RunScript(scriptFilePath) then
		print ('Success!')
	end
end

function LuaReset()
	print ('Resetting...')
	ScenEdit_ClearKeyValue("")
	print ('KeyValues cleared.')
	RunScript('LuaInit')
end

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

IsBetaVersion(true) --------------------------------------------------REMOVE BEFORE RELEASE
scenarioZuluOffset = -1 ----------CHANGE PER SCENARIO

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
		radius=math.random(0.1,max_radius),
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
		'TODOS',
		'METOPS',
		'r',
		'HYDROLOGICAL AND METEOROLOGICAL OFFICE',
		'ALL STATIONS',
		'unclass',
		'WX REPORT ' .. DTG .. ' - MOROCCAN COAST & CANARY ISLANDS <BR>AVERAGE TEMP '.. tempC ..'°C / '..tempF..'°F <BR> SEA STATE '.. sea ..' <BR>'..rain..' PRECIPITATION <BR>'..cloud..' <BR>'..outlook)

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
	local weatherBaseline = { seastate = 4, temp = 13, undercloud = 0.4, rainfall = 0 }
	local seastateVariability = math.random(0,2)
	local undercloudVariability = math.random(0,4)/10
	local tempVariability = math.random(-1,4)
	local rainfallVariability = math.random(0,10)

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
			unit.type == 'Ship' and unit.dbid ~= 1869 then
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

----------SCENARIO SPECIFIC

oilRigs = {
	{name='Orta Anchoa', guid='1a75e5e5-a99b-4b7c-8d8d-a65f9a2dda2c'},
	{name='Orta Bagre', guid='4c1f7ae5-7292-4cf4-a442-e4c32e6216d1'},
	{name='Orta Eglefino', guid='aebe1b72-2ce8-4b7d-838d-c217ed2601ac'},
	{name='Orta Mero', guid='fd3bda57-6c07-4077-8610-236af1a5058f'},
	{name='Orta Tilapia', guid='b896c3df-e877-4b73-b3fe-4f6b41ff1554'},
}

function CreateListOfOilRigsWithDistanceFromUnit(guid)
	local aircraft, result, unitList = ScenEdit_GetUnit({guid=guid}), {}, oilRigs
	for k,v in ipairs (unitList) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		local entry = {name=unit.name, range=Tool_Range(guid,unit.guid), guid=unit.guid, heading=Round(Tool_Bearing(guid,unit.guid))}
		table.insert(result, entry)
	end
	return result
end

function ReturnNearestOilRigToUnit(guid)
	local assetList, result = CreateListOfOilRigsWithDistanceFromUnit(guid), nil
	local key,closest = 1,assetList[1].range
	for k,v in ipairs(assetList) do
		if v.range < closest then
			key,closest = k,v.range
		end
	end
	result = assetList[key]
	return result
end

function OilRigHasBeenSecured(guid,booleanValue)
	local unit = ScenEdit_GetUnit({guid=guid})
	local keyValue = CreateGUIDKeyName(unit.guid)
	if booleanValue == nil then
		return ConvertStringToBoolean(ScenEdit_GetKeyValue(keyValue))
	elseif type(booleanValue) == 'boolean' then
		ScenEdit_SetKeyValue(keyValue,booleanValue)
		return booleanValue
	else
		error("OilRigHasBeenSecured(): boolean or nil input required for parameter 2")
	end
end

function SelectedUnitCanCarryRHIB()
	local selectedUnit = ScenEdit_SelectedUnits().units
	if #selectedUnit ~= 1 then
		ScenEdit_MsgBox('Only one unit may be selected. Select a single eligible unit and try again.',0)
		return false
    end
    selectedUnit = ScenEdit_GetUnit({guid=selectedUnit[1].guid})
    if (selectedUnit.type == 'Aircraft' and selectedUnit.dbid == 3117) or (selectedUnit.type == 'Submarine' and selectedUnit.dbid == 495) then
		return true
	else
		ScenEdit_MsgBox('This unit is not eligible for this special action.\n\n Select a single eligible unit and try again.',0)
		return false
	end
end

function AircraftIsInParametersToDropRHIB()
	if SelectedUnitCanCarryRHIB() then
		local aircraft = ScenEdit_GetUnit({guid=ScenEdit_SelectedUnits().units[1].guid})
		if not OverWater(aircraft.latitude,aircraft.longitude) then
			ScenEdit_MsgBox(aircraft.name..' is not over water.\n\n Dropping a RHIB might be a bad idea here.',0)
			return false
		elseif aircraft.altitude > 1000 then
			ScenEdit_MsgBox(aircraft.name..' is too high.\n\n Reduce altitude to below 1,000m/3,280ft',0)
			return false
		elseif aircraft.speed > 210 then
			ScenEdit_MsgBox(aircraft.name..' is moving too fast.\n\n Reduce speed to below 210kt',0)
			return false
		else
			return true
		end
	end
end

function DropRHIB()
	if AircraftIsInParametersToDropRHIB() then
		local aircraft = ScenEdit_GetUnit({guid=ScenEdit_SelectedUnits().units[1].guid})
		local droppedRHIB = ScenEdit_AddUnit({
			side=aircraft.side,
			type='Ship',
			dbid=3127,
			name='GOE II Det C',
			latitude=aircraft.latitude,
			longitude=aircraft.longitude,
            proficiency='Veteran'
		})
        local theMessage = "This is Granada Charlie, we're deployed and ready. Out."
        theMessage = GenerateRadioMessageBody(theMessage,droppedRHIB.name)
		RadioMessage('SHF SATCOM','12.8 GHz ENCRYPTED',theMessage)
		ScenEdit_SetSpecialAction({ActionNameOrID='Deploy RHIB from C-130',isactive=false})
    end
end

function SubmarineIsInParametersToDropRHIB()
	if SelectedUnitCanCarryRHIB() then
		local submarine = ScenEdit_GetUnit({guid=ScenEdit_SelectedUnits().units[1].guid})
		if submarine.altitude < -5 then
			ScenEdit_MsgBox(submarine.name..' is too deep.\n\n Surface the submarine in order to complete this action.',0)
			return false
		elseif submarine.speed > 5 then
			ScenEdit_MsgBox(submarine.name..' is moving too fast.\n\n Reduce speed to 5kt or below.',0)
			return false
		else
			return true
		end
	end
end

function FloatRHIB()
	if SubmarineIsInParametersToDropRHIB() then
		local submarine = ScenEdit_GetUnit({guid=ScenEdit_SelectedUnits().units[1].guid})
		local droppedRHIB = ScenEdit_AddUnit({
			side=submarine.side,
			type='Ship',
			dbid=3127,
			name='FGNE Det E',
			latitude=submarine.latitude,
			longitude=submarine.longitude,
            proficiency='Veteran'
		})
        local theMessage = "This is Rana Echo, we're deployed and ready. Out."
        theMessage = GenerateRadioMessageBody(theMessage,droppedRHIB.name)
		RadioMessage('SHF SATCOM','12.8 GHz ENCRYPTED',theMessage)
		ScenEdit_SetSpecialAction({ActionNameOrID='Deploy RHIB from submarine',isactive=false})
	end
end