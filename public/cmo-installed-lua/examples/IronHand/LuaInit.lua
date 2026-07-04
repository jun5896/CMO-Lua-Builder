scenarioScriptFilePath = '/IronHand/'

math.randomseed(os.time())
math.random()

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
	local weatherBaseline = { undercloud = 0.3, seastate = 2, rainfall = 0, temp = 15 }
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

function GenerateRadioMessageBody(theMessage,callsign)
	local result
	if callsign == nil then callsign = 'unk stn' end
    result = '<P>'..string.upper(callsign)..'<BR> <I>"'..theMessage..'"</I></P> '
	return result
end

function RadioMessage(band,frequency,theMessage,location)
	assert(theMessage,'RadioMessage(): No message passed!')
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

function TelexMessageToPlayer(recipient,sender,subject,classification,precedence,body,location)
	local theMessage = Signal(recipient,sender,subject,classification,precedence,body)
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

function WeatherReportRUS(outlook)
	if outlook == nil then outlook = 'next forecast at '..DTGSoviet(ScenEdit_CurrentTime()+21600) end

	local weather, DTG = ScenEdit_GetWeather(), DTGSoviet()
	local tempC, tempF, cloud, rain, sea = weather.temp, ConvertTempCtoF(weather.temp), GenerateCloudDescriptor(weather.undercloud), GenerateRainDescriptor(weather.rainfall), weather.seastate

	TelexMessageToPlayer(
		'ALL', --recipient
		--function TelexMessageToPlayer(recipient, sender, subject, classification, precedence, body, location)
		'CENTRAL METEOROLOGICAL DIRECTORATE', --sender
		'WX REPORT - Nagorno-Karabakh', --subject
        'UNCLASSIFIED', --classification
		'ROUTINE', --precedence
		'AVERAGE TEMP '.. tempC ..'°C / '..tempF..'°F <BR> SEA STATE '.. sea ..' <BR>'..rain..' PRECIPITATION <BR>'..cloud..' <BR>'..outlook,
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

------------------SAR
function ReturnSurvivor(selectedUnits)
	local survivorSide = 'Downed Pilots'
	local rescuerSide = 'Russia'
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
	local rescuerSide = 'Russia'
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
		4568, --Mi-8AMTSh Hip H
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
			ChangeScore('Russia',50,selectedUnits.survivor.name..' was rescued.')
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

function GenerateRank()
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

function RandomLetter()
	local alphabet = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
	return string.upper(alphabet[math.random(1,#alphabet)])
end

function GenerateSurvivorName()
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
		"We're hit! ",
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

---------IADS component
function GetListOfAAAUnits()
	local sideUnits, result = VP_GetSide({side='Azerbaijan'}).units, {}
	local affectedDBIDs = {
		--249,--SAM Bty (SA-4 Ganef [2K11 Krug])
		--386, --SAM Bn (SA-20b Gargoyle [S-300PMU-2])
		1613,--Radar (Back Net [P-80])
		1628,--Radar (Tin Shield B [5N59S/36D6])
		188, --Radar (Bar Lock A [P-37])
		253,--SAM Bn (SA-3c Goa [S-125M1 Neva-M])
		265, --Radar (Spoon Rest D [P-18])
		269, --SAM Bn (SA-2f Guideline [S-75M Volkhov])
		333, --Radar (Tall King A [P-14])
		587, --SAM Grp (SA-5c Gammon [S-200M Vega M], 2x Bn)
		80, --AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)
		426, --SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)
		420, --SAM Sec (SA-18 Grouse [9K38 Igla] MANPADS x 3)
		250, --SAM Plt (SA-19 Grisom [9K22 Tunguska])
		1560, --SAM Sec (SA-24 Grouse [9K338 Igla-S] MANPADS x 3)
	}
	for each, entry in ipairs (sideUnits) do
		local unit = ScenEdit_GetUnit({guid=entry.guid})
		for k,v in ipairs(affectedDBIDs) do
			if unit.dbid == v then
				table.insert(result,unit)
				break
			end
		end
	end
	return result
end

function DisruptAZComms()
	local unitsToBeDisrupted = GetListOfAAAUnits()
	for k,v in ipairs (unitsToBeDisrupted) do
		local chanceOfDisruption = 45
		local chance = math.random(1,100)
		if chance < chanceOfDisruption then
			ScenEdit_SetUnit({guid=v.guid,outofcomms=true})
		end
	end
	ScenEdit_SetDoctrine({side="Azerbaijan"}, {weapon_control_status_air=1})
	ScenEdit_SetEMCON('Side', "Azerbaijan", 'Radar=Active')
	TelexMessageToPlayer(
		"IRON HAND",
		'Main Intelligence Directorate',
		'SIGINT UPDATE',
		'Sovershenno sekretno',
		'Vozdukh',
		'1. AZERBAIJAN AIR DEFENSE RADIO TRAFFIC ABRUPTLY CEASED MID TRANSMISSION <BR>2. SIMILAR DISRUPTION NOTED TO DATA TRAFFIC <BR>3. ASSESS THAT AZERBAIJAN AIR DEFENSE CONTROL COMMUNICATIONS ARE CURRENTLY INOPERABLE <BR>4. ANTICIPATE REDUCED COORDINATION OF AZERBAIJAN AIR DEFENSE ACTIVITIES UNTIL COMMUNICATIONS REESTABLISHED',
		nil
	)
end

---------FARP setup
function GetSelectedUnitForFARP()
	local selectedUnits = ScenEdit_SelectedUnits()
	if selectedUnits.units ~= nil then
		if #selectedUnits.units == 1 then
			local unit = ScenEdit_GetUnit({guid=selectedUnits.units[1].guid})
			if unit.type == 'Aircraft' and unit.dbid == 2376 then
				return unit
			else
				ScenEdit_MsgBox('The selected unit is not suitable for this special action.\n\n Try selecting a single Mi-26 helicopter.',0)
			end
		else
			ScenEdit_MsgBox('Too many units are selected.\n\n Try selecting a single Mi-26 helicopter.',0)
		end
	else
		ScenEdit_MsgBox('No friendly units are selected.\n\n Try selecting a single Mi-26 helicopter under your control.',0)
	end
	return nil
end

function FARPConditionsAreMet()
	local helicopter = GetSelectedUnitForFARP()
	if OverWater(helicopter.latitude,helicopter.longitude) then
		ScenEdit_MsgBox(helicopter.name..' is currently over water.\n\n Move over land and try again.',0)
		return false
	elseif helicopter.speed > 50 or ReturnUnitAltitudeAGL(helicopter.guid) > 75 then
		ScenEdit_MsgBox(helicopter.name..' is flying too high or too fast to set up a refueling point.\n\nAircraft establishing fueling points must be flying at less than 245ft/75m AGL and slower than 50 knots.',0)
		return false
	else
		return true
	end
end

function FARPMessage(name,latitude,longitude)
	local theMessage = 'Forward refueling point established.'
	local theMessage = GenerateRadioMessageBody(theMessage,name)
	RadioMessage('VHF','134.75 MHz',theMessage,{latitude=latitude, longitude=longitude})
end

function AddFARP()
	local helicopter = GetSelectedUnitForFARP()
	if FARPConditionsAreMet() then
		ScenEdit_AddUnit({
			side=helicopter.side,
			name=helicopter.name..' FARP',
			type='Facility',
			dbid=248,
			latitude=helicopter.latitude,
			longitude=helicopter.longitude,
		})
		FARPMessage(helicopter.name,helicopter.latitude,helicopter.longitude)
		ScenEdit_DeleteUnit({guid=helicopter.guid})
	end
end

function SetupForwardRefuelingPoint()
	local helicopter = GetSelectedUnitForFARP()
	if helicopter ~= nil then
		AddFARP()
		
	end
end