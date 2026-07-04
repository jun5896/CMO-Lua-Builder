scenarioScriptFilePath = '/ChumonchinChan/'

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
scenarioZuluOffset = 9 ----------CHANGE PER SCENARIO

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

function ChangeScore(side,amt,reason)
	local newScore = ScenEdit_GetScore(side) + amt
	ScenEdit_SetScore(side,newScore,reason)
	print (side..' score changed to '..newScore)
	return newScore
end

function WeatherDrift()
	local weatherBaseline = { seastate = 1, temp = 17, undercloud = 0.2, rainfall = 0 }
	local seastateVariability = math.random(0,2)
	local undercloudVariability = math.random(0,2)/10
	local tempVariability = math.random(-1,2)
	local rainfallVariability = 0

	local newTemp =  weatherBaseline.temp + tempVariability
	local newRainfall = weatherBaseline.rainfall + rainfallVariability
	local newUndercloud = weatherBaseline.undercloud + undercloudVariability
	local newSeastate = weatherBaseline.seastate + seastateVariability

	ScenEdit_SetWeather(
		newTemp, 
		newRainfall, 
		newUndercloud, 
		newSeastate 
	)
end

function BugMessage(eventName,description)
	if IsBetaVersion() then
		ScenEdit_MsgBox('An issue occured with '..eventName..';\n'..description..'\n\nThis will not affect system stability but may affect scenario balance. \n\nPlease report this in the Beta Testing Forum. \n\nThanks!', 0)
	else
		ScenEdit_MsgBox('An issue occured with '..eventName..';\n'..description..'\n\nThis will not affect system stability but may affect scenario balance. \n\nPlease report this in the Tech Support subforum on the Matrix Games forum, including a screenshot of this message. \n\nhttp://www.matrixgames.com/forums/tt.asp?forumid=1279', 0)
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

function DTGPreEpoch(timeVar)
	if timeVar == nil then timeVar = ScenEdit_CurrentTime() end
	local timeVar = timeVar + 4070908800 -- add seconds to bring year up to 2099 (+129 years)
	local timeStampTable = os.date("!*t",timeVar) -- build timestamp table
	local months = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'}
	local messageTime = string.format('%02d',timeStampTable.day).. 
        string.format('%02d',timeStampTable.hour) .. 
        string.format('%02d',timeStampTable.min) .. 
        'Z ' .. 
        months[timeStampTable.month] ..
        ' ' .. 
        (timeStampTable.year-2029)
	return messageTime
end

function GenerateRadioMessageBody(theMessage,callsign)
	local result
	if callsign == nil then callsign = 'unk stn' end
    result = '<P>'..string.upper(callsign)..'<BR> <I>"'..theMessage..'"</I></P> '
	return result
end

function RadioMessage(band,frequency,theMessage,location)
	assert(theMessage,'RadioMessage(): No message passed!')
	local DTGPreEpoch = DTGPreEpoch()
	local theMessage = "<P>"..DTGPreEpoch..' <BR>'..band..' <BR>'..frequency..' </P>'..theMessage
	if location ~= nil then
		ScenEdit_SpecialMessage('playerside',theMessage,{latitude=location.latitude,longitude=location.longitude})
	else
		ScenEdit_SpecialMessage('playerside',theMessage)
	end
	RegisterMessage(theMessage)
	--PlaySound(yeOldeRadioTone.mp3)
end