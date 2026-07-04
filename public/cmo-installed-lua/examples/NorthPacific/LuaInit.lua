ScenEdit_RunScript('DeveloperMode.lua')

math.randomseed(os.time())
math.random()

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
scenarioZuluOffset = 11 

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

function ChangeScore(side,amt,reason)
	local newScore = ScenEdit_GetScore(side) + amt
	ScenEdit_SetScore(side,newScore,reason)
	print (side..' score changed to '..newScore)
	return newScore
end

function WeatherDrift()
	local weatherBaseline = { seastate = 2, undercloud = 0.2, rainfall = 0, temp = 4 }
	local seastateVariability = math.random(-1,2)
	local undercloudVariability = math.random(-2,2)/10
	local tempVariability = math.random(-1,2)
	local rainfallVariability = math.random(0,10)

	local newTemp =  weatherBaseline.temp + tempVariability
	local newUndercloud = weatherBaseline.undercloud + undercloudVariability
	local newRainfall = weatherBaseline.rainfall + rainfallVariability
	if newUndercloud <= 0.2 then newRainfall = 0 end
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

function JitterPosition(guid,radius,overWater)
	if overWater == nil then overWater = false end
	local unit = ScenEdit_GetUnit({guid=guid})
	local newPos = CircularRandomPosition(unit.latitude,unit.longitude,radius)
	if OverWater(newPos.latitude,newPos.longitude) == overWater then
		ScenEdit_SetUnit({
			guid=unit.guid,
			latitude=newPos.latitude,
			longitude=newPos.longitude
		})
	end
end

------------------Comms
function RadioSoundEffect()
	local fileName = 'radioChirp'..math.random(1,8)..'.mp3'
	ScenEdit_PlaySound(fileName)
end

function DTGSoviet(TimeVar)
    if TimeVar == nil then 
    TimeVar = ScenEdit_CurrentTime()
    end
    msgtime = os.date("!%H%M" .. "UTC" .. " " .. "%d %b %y r.", TimeVar)
    msgtime = string.upper(msgtime)
    return msgtime
end

function DTG(TimeVar)
	if TimeVar == nil then
		TimeVar = ScenEdit_CurrentTime()
	end
	local msgtime = os.date("!%d%H%M" .. "Z" .. " " .. "%b %y", TimeVar)
	local msgtime = string.upper(msgtime)
	return msgtime
end

function GenerateRadioMessageBody(theMessage,callsign)
	local result
	if callsign == nil then callsign = 'unk stn' end
    result = '<P>'..string.upper(callsign)..'<BR> <I>"'..theMessage..'"</I></P> '
	return result
end

function RadioMessageSoviet(band,frequency,theMessage,location)
	assert(theMessage,'RadioMessageSoviet(): No message passed!')
	local DTGSoviet = DTGSoviet()
	local theMessage = "<P>"..DTGSoviet..' <BR>'..band..' <BR>'..frequency..' </P>'..theMessage
	if location ~= nil then
		ScenEdit_SpecialMessage('playerside',theMessage,{latitude=location.latitude,longitude=location.longitude})
	else
		ScenEdit_SpecialMessage('playerside',theMessage)
	end
	RegisterMessage(theMessage)
	RadioSoundEffect()
end

function RadioMessageNATO(band,frequency,theMessage,location)
	assert(theMessage,'RadioMessageNATO(): No message passed!')
	local DTG = DTG()
	local theMessage = "<P>"..DTG..' <BR>'..band..' <BR>'..frequency..' </P>'..theMessage
	if location ~= nil then
		ScenEdit_SpecialMessage('playerside',theMessage,{latitude=location.latitude,longitude=location.longitude})
	else
		ScenEdit_SpecialMessage('playerside',theMessage)
	end
	RegisterMessage(theMessage)
	RadioSoundEffect()
end

function RadioMessage(band,frequency,theMessage,location)
	local playerSide = ScenEdit_PlayerSide()
	if playerSide == 'Soviet Union' then
		return RadioMessageSoviet(band,frequency,theMessage,location)
	else
		return RadioMessageNATO(band,frequency,theMessage,location)
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

function Signal(recipient,sender,subject,classification,precedence,body)
    local msg_time = DTGSoviet()
	local signal_string = string.upper(
		'<P>'.. precedence.. '\\'..'\\ <BR>' .. 
		'FROM: '..sender..' <BR>' .. 
		'TO: '..recipient..' <BR>' ..
		'SUBJ: '..subject..' <BR>' .. 
		msg_time .. ' <BR>' ..
		classification .. '</P>' ..
		'<P>'..body.. '</P>' ..
		'<P>'..'\\'..'\\'..precedence..'</P>'
	)
	return signal_string
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

function TelexMessageToPlayerSoviet(recipient,sender,subject,classification,precedence,body,location)
	local theMessage = Signal(recipient,sender,subject,classification,precedence,body)
	if location ~= nil then
		ScenEdit_SpecialMessage('playerside',theMessage,{latitude=location.latitude,longitude=location.longitude})
	else
		ScenEdit_SpecialMessage('playerside',theMessage)
	end
	ScenEdit_PlaySound('telex.mp3')
	RegisterMessage(theMessage)
end

function TelexMessageToPlayerNATO(rec_station, snd_station, precedence, from, to, classification, body, location)
	local theMessage = ACP126(rec_station, snd_station, precedence, from, to, classification, body)
	if location ~= nil then
		ScenEdit_SpecialMessage('playerside',theMessage,{latitude=location.latitude,longitude=location.longitude})
	else
		ScenEdit_SpecialMessage('playerside',theMessage)
	end
	ScenEdit_PlaySound('telex.mp3')
	RegisterMessage(theMessage)
end

------------Weather

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

function WeatherReportUSSR(outlook)
	if outlook == nil then outlook = 'next forecast at '..DTGSoviet(ScenEdit_CurrentTime()+21600) end

	local weather, DTG = ScenEdit_GetWeather(), DTGSoviet()
	local tempC, tempF, cloud, rain, sea = weather.temp, ConvertTempCtoF(weather.temp), GenerateCloudDescriptor(weather.undercloud), GenerateRainDescriptor(weather.rainfall), weather.seastate

	TelexMessageToPlayerSoviet(
		'ALL', --recipient
		--function TelexMessageToPlayer(recipient, sender, subject, classification, precedence, body, location)
		'CENTRAL METEOROLOGICAL DIRECTORATE', --sender
		'WX REPORT - NORTH PACIFIC OCEAN', --subject
        'UNCLASSIFIED', --classification
		'ROUTINE', --precedence
		'AVERAGE TEMP '.. tempC ..'°C / '..tempF..'°F <BR> SEA STATE '.. sea ..' <BR>'..rain..' PRECIPITATION <BR>'..cloud..' <BR>'..outlook,
		nil
	)
end

function WeatherReportNATO(outlook)
	if outlook == nil then outlook = 'next forecast at '..DTG(ScenEdit_CurrentTime()+21600) end

	local weather, DTG = ScenEdit_GetWeather(), DTG()
	local tempC, tempF, cloud, rain, sea = weather.temp, ConvertTempCtoF(weather.temp), GenerateCloudDescriptor(weather.undercloud), GenerateRainDescriptor(weather.rainfall), weather.seastate

	TelexMessageToPlayerNATO(
		'ALL',
		'METOPS',
		'r',
		'HYDROLOGICAL AND METEOROLOGICAL OFFICE',
		'ALL STATIONS',
		'unclass',
		'WX REPORT '..DTG..' - NORTH PACIFIC OCEAN <BR>AVERAGE TEMP '..tempC..'°C / '..tempF..'°F <BR> SEA STATE '..sea..' <BR>'..rain..' PRECIPITATION <BR>'..cloud..' <BR>'..outlook,
		nil
	)
end

function TimeIs(timeVar)
	if timeVar == nil then timeVar = ScenEdit_CurrentTime() end
	local timeStampTable = os.date("!*t",timeVar)
	local timeTable = {day = timeStampTable.day, 
		hour = timeStampTable.hour, 
		minute = timeStampTable.min}
    return timeTable
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

------------------SAR
function ReturnSurvivor(selectedUnits)
	local survivorSide = 'Downed Pilots'
	local rescuerSide = ScenEdit_PlayerSide()
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
	local rescuerSide = ScenEdit_PlayerSide()
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
        ScenEdit_MsgBox('Rescuer must be within '..maxRescueRange..'m / '..maxRescueRangeFeet..'ft.\n\nCurrent range is '..range.metres..'m / '..range.feet..'ft.\n\nMove closer to attempt a rescue.',0)
        return false
    end
end

function AircraftIsRescueCapable(dbid)
	local dbidList = {
		2830,--SH-2F Seasprite
		7,--SH-3H Sea King
		326,--Mi-14PS Haze C
		50, --Ka-25BSh Hormone A
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
	if RescuerIsCloseEnoughToRescueSurvivor() then
		if altitudeAboveGround <= 75 and rescuer.speed <= 50 then
			return true
		else
			ScenEdit_MsgBox(rescuer.name..' is flying too high or too fast to perform a rescue.\n\nAircraft performing rescues must be flying at less than 245ft/75m AGL and slower than 50 knots.',0)
			return false
		end
	else
		return false
	end  
end

function ShipOrSubmarineIsWithinRescueParams()
	local rescuer = GetSelectedUnitInformation().rescuer
	if RescuerIsCloseEnoughToRescueSurvivor() then
		if rescuer.altitude >= -20 and rescuer.speed <= 6 then
			return true
		else
			local errorString = rescuer.name..' is moving too fast to perform a rescue.\n\nShips performing rescues must be moving at 5 knots or less.'
			if rescuer.type == 'Submarine' then
				errorString = rescuer.name..' is either moving too fast or is too deeply submerged to perform a rescue.\n\nSubmarines performing rescues must be moving at 5 knots or less and be on the surface.'
			ScenEdit_MsgBox(errorString,0)
			return false
			end
		end
	else
		return false
	end
end

function ContactIsValidRescueTarget()
	local selectedUnits = GetSelectedUnitInformation()
	if selectedUnits.survivor.type == 'Ship' and selectedUnits.survivor.dbid == 2553 then
		return true
	elseif selectedUnits.survivor.type == 'Facility' and selectedUnits.survivor.dbid == 2441 then
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
    local message = "We've rescued "..selectedUnits.survivor.name.."."
    local theMessage = GenerateRadioMessageBody(message,selectedUnits.rescuer.name)
    RadioMessage('VHF','134.25 MHz',theMessage,{latitude=selectedUnits.survivor.latitude, longitude=selectedUnits.survivor.longitude})
end

function AttemptRescue()
    local selectedUnits = GetSelectedUnitInformation()
    if selectedUnits ~= nil then
        if PlayerUnitIsEligibleToRescue() then
			PerformRescue()
			ChangeScore('playerside',50,selectedUnits.survivor.name..' was rescued.')
        end
    end
end

------Downed Pilot Generation
function DetermineTypeOfSurvivor(latitude,longitude)
	local liferaftDBID, strandedPersonDBID, survivorType = 2553, 2441, 'Facility'
	local survivorDBID = strandedPersonDBID
	if OverWater(latitude,longitude) then
		survivorType, survivorDBID = 'Ship', liferaftDBID
	end
	return {type=survivorType,dbid=survivorDBID}
end

function GenerateRankUSA()
	local ranks = {"LTJG","LT","LCDR"}
	local chance = math.random(1,100)
	if chance < 40 then
		return ranks[1]
	elseif chance < 80 then
		return ranks[2]
	else
		return ranks[3]
	end
end

function GenerateRankSoviet()
	local ranks = {"Jr. LT","LT","Sr. LT","Capt.","Maj."}
	local chance = math.random(1,100)
	if chance < 40 then
		return ranks[math.random(1,3)]
	elseif chance < 80 then
		return ranks[4]
	else
		return ranks[5]
	end
end

function GenerateRank()
	local playerSide = ScenEdit_PlayerSide()
	if playerSide == 'Soviet Union' then
		return GenerateRankSoviet()
	else
		return GenerateRankUSA()
	end
end

function RandomLetter()
	local alphabet = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
	return string.upper(alphabet[math.random(1,#alphabet)])
end

function GenerateSurvivorNameSoviet()
	local rank = GenerateRank()
	local initials = RandomLetter()..". "..RandomLetter()..". "
	local surnames = {    
		'Smirnov',
		'Ivanov',
		'Kuznetsov',
		'Popov',
		'Sokolov',
		'Lebedev',
		'Kozlov',
		'Novikov',
		'Morozov',
		'Petrov',
		'Volkov',
		'Solovyov',
		'Vasilyev',
		'Zaytsev',
		'Pavlov',
		'Semyonov',
		'Golubev',
		'Vinogradov',
		'Bogdanov',
		'Vorobyov',
	}
	return rank..' '..initials..surnames[math.random(1,#surnames)] 
end

function GenerateSurvivorNameUSA()
	local rank = GenerateRank()
	local initials = RandomLetter()..". "..RandomLetter()..". "
	local surnames = {    
		"Smith",
		"Johnson",
		"Williams",
		"Brown",
		"Jones",
		"Garcia",
		"Miller",
		"Davis",
		"Rodriguez",
		"Martinez",
		"Hernandez",
		"Lopez",
		"Gonzalez",
		"Wilson",
		"Anderson",
	}
	return rank..' '..initials..surnames[math.random(1,#surnames)] 
end

function GenerateSurvivorName()
	local playerSide = ScenEdit_PlayerSide()
	if playerSide == 'Soviet Union' then
		return GenerateSurvivorNameSoviet()
	else
		return GenerateSurvivorNameUSA()
	end
end

function PlaceSurvivor(latitude,longitude)
	local randomPosition = CircularRandomPosition(latitude,longitude,2)
	local survivorData = DetermineTypeOfSurvivor(randomPosition.latitude,randomPosition.longitude)
	local survivorName = GenerateSurvivorName()
	local survivor = ScenEdit_AddUnit({
		side='Downed Pilots',
		type=survivorData.type,
		dbid=survivorData.dbid,
		name=survivorName,
		latitude=randomPosition.latitude,
		longitude=randomPosition.longitude
	})
end

function RandomBailoutString()
	local damagePrefixes = {
		"I've lost control! ",
		"They got me! ",
		"Taking hits! ",
		"I'm hit! ",
		"Flight controls are gone! ",
		"Taking heavy fire! "
	}
	local bailoutSuffixes = {
		"Going in!",
		"Going down!",
		"Eject, eject, eject!!!",
		"I can't hold it together!",
		"Bailing out!"
	}
	local result = damagePrefixes[math.random(1,#damagePrefixes)]..bailoutSuffixes[math.random(1,#bailoutSuffixes)]
	return result
end

function BailoutMessage(name,latitude,longitude)
	local theMessage = RandomBailoutString()
	local theMessage = GenerateRadioMessageBody(theMessage,name)
	RadioMessage('VHF','134.75 MHz',theMessage,{latitude=latitude, longitude=longitude})
end

function PilotSurvives()
	local chanceOfBailout = 66
	local chance = math.random(1,100)
	if chance <= chanceOfBailout then
		return true
	else
		return false
	end
end

function GenerateSurvivors(latitude,longitude,name)
	math.randomseed(os.time())
	if PilotSurvives() then
		PlaceSurvivor(latitude,longitude)
		BailoutMessage(name,latitude,longitude)
	end	
end

----------Hostilities
function HostilitiesHaveCommenced(boolValue)
	if boolValue == nil then
		return ConvertStringToBoolean(ScenEdit_GetKeyValue('hostilities'))
	elseif boolValue == true then
		ScenEdit_SetKeyValue('hostilities','true')
		return true
	elseif boolValue == false then
		ScenEdit_SetKeyValue('hostilities','false')
		return false
	else
		return nil
	end
end

function ActivateMissionsByList(side, missionList)
	for k,v in ipairs (missionList) do
		ScenEdit_SetMission (side, v, {isactive=true})
	end
end

function SetSidesHostile()
	ScenEdit_SetSidePosture ('United States', 'Soviet Union', 'H')
	ScenEdit_SetSidePosture ('Soviet Union', 'United States', 'H')
end

function CommenceHostilities()
	if not HostilitiesHaveCommenced() then
		SetSidesHostile()
		local missionList, missionSide
		if ScenEdit_PlayerSide() == 'United States' then
			missionSide = 'Soviet Union'
			missionList = {
				'Backfire Strike',
			}
		else
			missionSide = 'United States'
			missionList = {
				'ASuW Strike'
			}
		end
		ActivateMissionsByList(missionSide, missionList)
	end
end

------Randomise proficiency
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

----------Request USAF support
function RequestUSAFSupport()
	local aircraftLoadouts = {
		{loadout=1404,readyTime=15},
		{loadout=12152,readyTime=5},
		{loadout=3,readyTime=0},
	}

	local numberOfAircraft = 8
	local aircraft = {}
	for i = 1,numberOfAircraft do

		local loadoutData
		if i <= 2 then
			loadoutData = aircraftLoadouts[1]
		elseif i <= 4 then
			loadoutData = aircraftLoadouts[2]
		else
			loadoutData = aircraftLoadouts[3]
		end

		local unit = ScenEdit_AddUnit({
			side='United States',
			name='43rd TFS #'..i,
			type='Aircraft',
			dbid=583,
			base='155d1b96-629f-4652-9fed-541489d1b8af',
			loadoutid=loadoutData.loadout,
		})
		ScenEdit_SetLoadout ({
			UnitName=unit.guid,
			LoadoutID=0,
			TimeToReady_Minutes=loadoutData.readyTime,
			IgnoreMagazines=true, -- OPTIONAL
			ExcludeOptionalWeapons=false -- OPTIONAL
		})
		table.insert(aircraft,unit)
	end

	RandomiseUnitTableProficiency(aircraft)

	TelexMessageToPlayerNATO(
		'cvbg-61', 
		'eack', 
		'i', 
		'eackerson ab', 
		'cvbg 61',
		'secret', 
		'1. acknowledge 43rd tfs detachment at eackerson ab is under your control <BR>'..
		'2. scramble initiated <BR>'..
		'3. 2 x F-15C on alert 5; 2 x F-15C on alert 15. Further 4 x F-15C available for follow-on ops.', 
		{latitude='52.7173868791964', longitude='174.120568818604'} --location
	)
	ScenEdit_PlaySound('scramble.mp3')
	ChangeScore('United States',-500,'Requested operational control of USAF forces.')
end

----------TWO SIDED SCENARIO SETUP
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

function ClearSideReferencePoints(sideName)
	local sideRPs=VP_GetSide({side=sideName}).rps
	for k,v in ipairs(sideRPs) do
		ScenEdit_DeleteReferencePoint({side=sideName,guid=v.guid})
	end
end

function SetupSideAsAI(sideName)
	ScenEdit_SetSidePosture('Civilian', sideName, 'F')
	ScenEdit_SetSidePosture('Nature', sideName, 'F')
	ScenEdit_SetDoctrine({side=sideName}, {
		weapon_control_status_air = 1,
		weapon_control_status_surface = 1,
		weapon_control_status_subsurface = 1,
		weapon_control_status_land = 1,
		})
end

function RandomiseSideUnitProficiency(sideName)
	local sideUnits = VP_GetSide({side=sideName}).units
	RandomiseUnitTableProficiency(sideUnits)
end

function DisplayGamePlayNotes()
	local gameplayNotes = '<h1>Gameplay Notes</h1> <p>This scenario has additional features, which are activated by <u>Special Actions</u>. To access the Special Action Menu you can either click on the Special Actions button on the toolbar, or use the Game > Special Actions menu command.</p><h2>Replay Special Messages</h2> <p>Replay the last ten (10) special messages recieved.</p> <h2>Perform Search and Rescue</h2> <p>Attempt to rescue a downed pilot or shipwreck survivors. To rescue survivors, select the survivor and a nearby friendly unit and execute the special action.</p> <h2>Request OPCON of 43rd TFS Det at Eareckson AB <BR><h3>US SIDE ONLY</h3></h2> <p>Request operational control of F-15Cs from the 43rd Tactical Fighter Squadron at Eareckson AB.</p> <p><em>This special action is not available until certain criteria are met in the scenario. You will be notified when it becomes available.</em></p>'
	ScenEdit_SpecialMessage('playerside',gameplayNotes)
end

if ThisIsFirstLoad() then
	math.randomseed(os.time())
	local playerSide = ScenEdit_PlayerSide()
	local enemySide = 'Soviet Union'
	if playerSide == 'Soviet Union' then enemySide = 'United States' end

	if inDevelopment then --ask to do stuff
		local userInput = string.upper(ScenEdit_MsgBox('Clear RPs for '..playerSide..'?',1))
		if userInput == 'OK' then 
			ClearSideReferencePoints(playerSide)
		end

		userInput = string.upper(ScenEdit_MsgBox('Setup '..enemySide..' as AI opponent?',1))
		if userInput == 'OK' then 
			SetupSideAsAI(enemySide)
		end

		userInput = string.upper(ScenEdit_MsgBox('Randomise unit proficiencies?',1))
		if userInput == 'OK' then 
			RandomiseSideUnitProficiency('United States') 
			RandomiseSideUnitProficiency('Soviet Union') 
		end

		userInput = string.upper(ScenEdit_MsgBox('Set firstLoad key value to false?',1))
		if userInput == 'OK' then 
			ThisIsFirstLoad(false) 
		end

		userInput = string.upper(ScenEdit_MsgBox('Display gameplay notes?',1))
		if userInput == 'OK' then 
			DisplayGamePlayNotes()
		end

	else --don't give the option and just do it
		ClearSideReferencePoints(playerSide)
		SetupSideAsAI(enemySide)
		RandomiseSideUnitProficiency('United States') 
		RandomiseSideUnitProficiency('Soviet Union') 
		ThisIsFirstLoad(false) 
		DisplayGamePlayNotes()
	end	
end