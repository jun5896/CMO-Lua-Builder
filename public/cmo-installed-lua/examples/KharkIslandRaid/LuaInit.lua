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

function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function DTG(TimeVar)
	if TimeVar == nil then
		TimeVar = ScenEdit_CurrentTime()
	end
	local msgtime = os.date("!%d%H%M" .. "Z" .. " " .. "%b %y", TimeVar)
	local msgtime = string.upper(msgtime)
	return msgtime
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

function WeatherReport(outlook)
	if outlook == nil then outlook = 'next forecast at '..DTG(ScenEdit_CurrentTime()+21600) end
	--Generate special message to player
	local weather = ScenEdit_GetWeather() --Get new weather parameters
	local temp, cloud, rain, sea = weather.temp, weather.undercloud, weather.rainfall, weather.seastate

	local f_temp = Round((temp*1.8) + 32,0) --Convert to Fahrenheit for philistines

	--create rain/precipitation descriptor (based on in-game descriptions)
	if rain == 0 then  precipdesc = 'nil'
	elseif rain < 5 then  precipdesc = 'very light'
	elseif rain < 11 then  precipdesc = 'light'
	elseif rain < 20 then  precipdesc = 'moderate'
	elseif rain < 30 then  precipdesc = 'heavy'
	elseif rain < 40 then  precipdesc = 'very heavy'
	else  precipdesc = 'extreme'
	end

	--create cloud descriptor (based on in-game descriptions)
	if cloud == 0 then  clouddesc = 'clear skies'
	elseif cloud < 0.2 then  clouddesc = 'light low clouds'
	elseif cloud < 0.3 then  clouddesc = 'light middle clouds'
	elseif cloud < 0.4 then  clouddesc = 'light high clouds'
	elseif cloud < 0.5 then  clouddesc = 'moderate low clouds'
	elseif cloud < 0.6 then  clouddesc = 'moderate middle clouds'
	elseif cloud < 0.7 then  clouddesc = 'moderate high clouds'
	elseif cloud < 0.8 then  clouddesc = 'moderate middle clouds & light high clouds'
	elseif cloud < 0.9 then  clouddesc = 'solid middle clouds & moderate high clouds'
	elseif cloud < 1.0 then  clouddesc = 'thin fog & solid cloud cover'
	else clouddesc = 'thick fog & solid cloud cover'
	end
	
	--rec_station,snd_station,precedence,from,to,classification,body
	local wx_time = DTG()
	local wx_report = ACP126('TODOS','METOPS','r','HYDROLOGICAL AND METEOROLOGICAL OFFICE','ALL STATIONS','unclass','WX REPORT ' .. wx_time .. ' - CARRIBEAN COAST <BR>AVERAGE TEMP '.. temp ..'°C / '..f_temp..'°F <BR> SEA STATE '.. sea ..' <BR>'..precipdesc..' PRECIPITATION <BR>'..clouddesc..' <BR>'..outlook)
	ScenEdit_SpecialMessage('playerside',wx_report)
	RegisterMessage(wx_report) --turned off for testing phase
end

function TimeIs(timeVar)
	if timeVar == nil then timeVar = ScenEdit_CurrentTime() end
	local timeStampTable = os.date("!*t",timeVar)
	local timeTable = {day = timeStampTable.day, 
		hour = timeStampTable.hour, 
		minute = timeStampTable.min}
    return timeTable
end

function ReturnUnitProficiencyAsNumber (unitGUID)
	local proficiencyList = {
		{stringName = 'Novice', numberValue = 0},
		{stringName = 'Cadet', numberValue = 1},
		{stringName = 'Regular', numberValue = 2},
		{stringName = 'Veteran', numberValue = 3},
		{stringName = 'Ace', numberValue = 4},
	}
	local unitProficiencyString = ScenEdit_GetUnit({guid=unitGUID}).proficiency
	for k,v in ipairs (proficiencyList) do
		if unitProficiencyString == v.stringName then
			matchedValue = v.numberValue
		end
	end
	if matchedValue == nil then
		return 'Error! No match found'
	else
		return matchedValue
	end
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
	local weatherBaseline = { seastate = 1, undercloud = 0.2, temp = 23, rainfall = 0 }
	local seastateVariability = math.random(0,2)
	local undercloudVariability = math.random(0,2)/10
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