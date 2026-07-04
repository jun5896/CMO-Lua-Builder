scenarioScriptFilePath = '/Shamal/'

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
scenarioZuluOffset = 3 ----------CHANGE PER SCENARIO

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

function DTG(TimeVar)
	if TimeVar == nil then
		TimeVar = ScenEdit_CurrentTime()
	end
	local msgtime = os.date("!%d%H%M" .. "Z" .. " " .. "%b %y", TimeVar)
	local msgtime = string.upper(msgtime)
	return msgtime
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
		'WX REPORT ' .. DTG .. ' - PERSIAN GULF<BR>AVERAGE TEMP '.. tempC ..'°C / '..tempF..'°F <BR> SEA STATE '.. sea ..' <BR>'..rain..' PRECIPITATION <BR>'..cloud..' <BR>'..outlook)

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

function WeatherDrift()
	local weatherBaseline = { rainfall = 0, temp = 37, undercloud = 0, seastate = 3 }
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

function RandomiseUnitTableProficiency(unitTable)
	for k,v in ipairs (unitTable) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.type ~= 'Group' then
			local chance = math.random(1,100)
			if chance <=50 then proficiency = 2
			elseif chance <=70 then proficiency = 3
			elseif chance <=90 then proficiency = 1
			elseif chance <=95 then proficiency = 4
			elseif chance <=100 then proficiency = 0
			end
			ScenEdit_SetUnit({guid=v.guid,proficiency=proficiency})
		end
	end
end

function RandomiseSideUnitProficiency(sideName)
	local sideUnits = VP_GetSide({side=sideName}).units
	RandomiseUnitTableProficiency(sideUnits)
end

----------SCENARIO SPECIFIC

function RandomiseReadyTime(aircraftGUID)
	local unit = ScenEdit_GetUnit({guid=aircraftGUID})
	ScenEdit_SetLoadout({unitName=unit.guid,
		loadoutid=0,
		TimeToReady_Minutes=math.random(0,(12*60))})
end
