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

function LuaReset()
	print ('Resetting...')
	ScenEdit_ClearKeyValue("")
	print ('KeyValues cleared.')
	ScenEdit_ExecuteEventAction('LuaInit')
end

IsBetaVersion(false) -- Remove Before Release
scenarioZuluOffset = -5 -- Change Per Scenario

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
	-- rec_station --4 letter code (e.g. YDCX)
	-- snd_station --4 letter code +/- NR 3 number (e.g. YBDN NR 270)
	-- precedence --Flash (Z), Immediate (O), Priority (P), Routine (R), Flash Override (Y)
	local dtg = DTG()
	-- from --e.g. MET FLT OPS
	-- to --e.g. SSN 21 SEAWOLF
	-- classification --Unclass +/- SBU / FOUO / NOFORN (Restricted), Confidential, Secret, Top Secret
	-- body
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
	-- Generate special message to player
	local weather = ScenEdit_GetWeather() --Get new weather parameters
	local temp, cloud, rain, sea = weather.temp, weather.undercloud, weather.rainfall, weather.seastate

	local f_temp = Round((temp*1.8) + 32,0) --Convert to Fahrenheit for philistines

	-- Create rain/precipitation descriptor (based on in-game descriptions)
	if rain == 0 then  precipdesc = 'nil'
	elseif rain < 5 then  precipdesc = 'very light'
	elseif rain < 11 then  precipdesc = 'light'
	elseif rain < 20 then  precipdesc = 'moderate'
	elseif rain < 30 then  precipdesc = 'heavy'
	elseif rain < 40 then  precipdesc = 'very heavy'
	else  precipdesc = 'extreme'
	end

	-- Create cloud descriptor (based on in-game descriptions)
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
	
	-- rec_station,snd_station,precedence,from,to,classification,body
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

function ReturnTimeStringAsNumberOfMinutes(targetString)
	if string.len(targetString) < 3 then --Is this already a number of minutes?
		result = tonumber(targetString)
	else -- if not, parse the string to get the values
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
	local weatherBaseline = { seastate = 1, undercloud = 0.2, temp = 17, rainfall = 3 }
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

-- Radio Comms

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
	--PlaySound(yeOldeRadioTone.mp3)
end

-- SAR

function ReturnSurvivor(selectedUnits)
	local survivorSide = 'Survivors'
	local rescuerSide = 'Colombia'
	if selectedUnits.units then
		for k,v in ipairs(selectedUnits.units) do
			local unit = ScenEdit_GetUnit({guid=v.guid})
			if unit.side == survivorSide then
				return unit
			end
		end
	end
	if selectedUnits.contacts then
		for k,v in ipairs(selectedUnits.contacts) do
			local contact = ScenEdit_GetContact({side=rescuerSide,guid=v.guid})
			if contact.side == survivorSide then
				local actualUnit = ScenEdit_GetUnit({guid=survivor.actualunitid})
				return actualUnit
			end
		end
	end
	return nil
end

function ReturnRescuer(selectedUnits)
	local rescuerSide = 'Colombia'
	for k,v in ipairs(selectedUnits.units) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.side == rescuerSide then
			return unit
		end
	end
	return nil
end

function ValidUnitSelection(selectedUnits)
	local tooMany, noneSelected = false, false
	if selectedUnits.units ~= nil then
		if #selectedUnits.units > 2 then
			tooMany = true
		end
	else
		noneSelected = true
	end

	if selectedUnits.contacts ~= nil then
		if #selectedUnits.contacts > 1 then
			tooMany = true
		end
	end

	if not tooMany and not noneSelected then
		return true
	else
		return false
	end
end

function GetSelectedUnitInformation()
	local selectedUnits = ScenEdit_SelectedUnits()
	if ValidUnitSelection(selectedUnits) then
		local rescuer = ReturnRescuer(selectedUnits)
		local survivor = ReturnSurvivor(selectedUnits)
		if rescuer == nil or survivor == nil then
			ScenEdit_MsgBox('Select both a downed pilot to rescue and a nearby friendly unit to perform this special action.',0)
			return nil
		else
			return {rescuer=rescuer,survivor=survivor}
		end
	end
end

function ReturnRangeBetweenRescuerAndSurvivor()
	local metresPerNMi, feetPerM  = 1852, 3.28084
	local selectedUnits = GetSelectedUnitInformation()
	local rangeMetres = Round(Tool_Range(selectedUnits.rescuer.guid, selectedUnits.survivor.guid) * metresPerNMi)
	local rangeFeet = Round(rangeMetres * feetPerM)
	return {feet=rangeFeet,metres=rangeMetres}
end

function RescuerIsCloseEnoughToRescueSurvivor()
	local range = ReturnRangeBetweenRescuerAndSurvivor()
	local maxRescueRange, feetPerM = 1000, 3.28084
	local maxRescueRangeFeet =  Round(maxRescueRange * feetPerM)
	if range.metres < maxRescueRange then
		return true
	else
		ScenEdit_MsgBox('Rescuer must be within '..maxRescueRange..'m / '..maxRescueRangeFeet..'ft.\n\nCurrent range is '..range.metres..'m / '..range.feet..'ft.\n\nMove closer to the vessel.',0)
		return false
	end
end

function AircraftIsRescueCapable(dbid)
	local dbidList = {
		3879, -- Mi-17V5 Hip H
		405, -- AS.555SN Fennec
		4094, -- Bell 412EP Basic [NB-412EP]
		4251, -- UH-60L Blackhawk
		4252, -- AH-60A Arpia III [Blackhawk]
	}
	for k,v in ipairs (dbidList) do
		if v == dbid then
			return true 
		end
	end
	return false
end

function ReturnUnitAltitudeAGL(guid)
	local unit = ScenEdit_GetUnit({guid=guid})
	local altitudeAboveSeaLevel, terrainElevation =  unit.altitude, World_GetElevation({latitude=unit.latitude,longitude=unit.longitude})
	if terrainElevation < 0 then terrainElevation = 0 end
	local altitudeAboveGround = altitudeAboveSeaLevel - terrainElevation
	return altitudeAboveGround
end

function AirUnitIsWithinRescueParams()
	local rescuer = GetSelectedUnitInformation().rescuer
	local altitudeAboveGround = ReturnUnitAltitudeAGL(rescuer.guid)
	if altitudeAboveGround <= 75 and rescuer.speed <= 50 then
		return RescuerIsCloseEnoughToRescueSurvivor()
	else
		ScenEdit_MsgBox(rescuer.name..' is flying too high or too fast to perform a rescue.\n\nAircraft performing rescues must be flying at less than 245ft/75m AGL and slower than 50 knots.',0)
		return false
	end  
end

function ShipOrSubmarineIsWithinRescueParams()
	local rescuer = GetSelectedUnitInformation().rescuer
	if rescuer.altitude >= -20 and rescuer.speed <= 6 then
		return RescuerIsCloseEnoughToRescueSurvivor()
	else
		local errorString = rescuer.name..' is moving too fast to perform a rescue.\n\nShips performing rescues must be moving at 5 knots or less.'
		if rescuer.type == 'Submarine' then
			errorString = rescuer.name..' is either moving too fast or is too deeply submerged to perform a rescue.\n\nSubmarines performing rescues must be moving at 5 knots or less and be on the surface.'
		ScenEdit_MsgBox(errorString,0)
		return false
		end
	end
end

function ContactIsValidRescueTarget()
	local selectedUnits = GetSelectedUnitInformation()
	if selectedUnits.survivor.type == 'Ship' and selectedUnits.survivor.dbid == 2553 then
		return true
	else
		ScenEdit_MsgBox('The selected contact is not capable of being rescued!',0)
		return false
	end
end

function PlayerUnitIsEligibleToRescue()
	local selectedUnits, result = GetSelectedUnitInformation(), false
	if ContactIsValidRescueTarget() then
		if selectedUnits.rescuer.type == 'Ship' or selectedUnits.rescuer.type == 'Submarine' then
			return ShipOrSubmarineIsWithinRescueParams()
		elseif selectedUnits.rescuer.type == 'Aircraft' and AircraftIsRescueCapable(selectedUnits.rescuer.dbid) then
			return AirUnitIsWithinRescueParams()
		else
			ScenEdit_MsgBox('Unit must be capable of rescue to attempt this special action.\n\nTry selecting a ship, submarine or helicopter.',0)
			return result
		end
	end
end

function PerformRescue()
	local selectedUnits = GetSelectedUnitInformation()
	ScenEdit_DeleteUnit({guid=selectedUnits.survivor.guid})
	local message = "We've rescued the survivors from "..selectedUnits.survivor.name.."."
	local theMessage = GenerateRadioMessageBody(message,selectedUnits.rescuer.name)
	RadioMessage('VHF','134.25MHz',theMessage,{latitude=selectedUnits.survivor.latitude, longitude=selectedUnits.survivor.longitude})
end

function AttemptRescue()
	local selectedUnits = GetSelectedUnitInformation()
	if selectedUnits ~= nil then
		if PlayerUnitIsEligibleToRescue() then
			PerformRescue()
			ChangeScore('Colombia',25,selectedUnits.survivor.name..' was rescued.')
		end
	end
end

-- Scenario Setup

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
	local gameplayNotes = '<h1>Gameplay Notes</h1> <p>This scenario has additional features, which are activated by <u>Special Actions</u>. To access the Special Action Menu you can either click on the Special Actions button on the toolbar, or use the Game > Special Actions menu command.</p><h2>Replay Special Messages</h2> <p>Replay the last ten (10) special messages recieved.</p> <h2>Perform Search and Rescue</h2> <p>Attempt to rescue a downed pilot or shipwreck survivors. To rescue survivors, select the survivor and a nearby friendly unit and execute the special action.</p>'
	ScenEdit_SpecialMessage('playerside',gameplayNotes)
end

if ThisIsFirstLoad() then
	if inDevelopment then -- Ask to do stuff
		userInput = string.upper(ScenEdit_MsgBox('Display Gameplay Notes?',1))
		if userInput == 'OK' then
			DisplayGamePlayNotes()
		end

		userInput = string.upper(ScenEdit_MsgBox('Set firstLoad key value to false?',1))
		if userInput == 'OK' then
			ThisIsFirstLoad(false)
		end
	else -- Don't give the option and just do it
		DisplayGamePlayNotes()
		ThisIsFirstLoad(false)
	end
end