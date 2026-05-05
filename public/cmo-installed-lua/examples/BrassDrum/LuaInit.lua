scenarioScriptFilePath = '/BrassDrum/'

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
scenarioZuluOffset = 4 ----------CHANGE PER SCENARIO

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

----------SCENARIO SPECIFIC
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
	if callsign == nil then callsign = 'unknown station' end
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
	RadioSoundEffect()
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

function TelexMessageToPlayer(rec_station, snd_station, precedence, from, to, classification, body, location)
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

function WeatherReport(outlook)
	if outlook == nil then outlook = 'next forecast at '..DTG(ScenEdit_CurrentTime()+21600) end

	local weather, DTG = ScenEdit_GetWeather(), DTG()
	local tempC, tempF, cloud, rain, sea = weather.temp, ConvertTempCtoF(weather.temp), GenerateCloudDescriptor(weather.undercloud), GenerateRainDescriptor(weather.rainfall), weather.seastate
		
	TelexMessageToPlayer(
		'ALL',
		'METOc',
		'r',
		'Naval Meteorology and Oceanography Command',
		'ALL STATIONS',
		'unclass',
		'WX REPORT '..DTG..' - strait of hormuz <BR>AVERAGE TEMP '..tempC..'°C / '..tempF..'°F <BR> SEA STATE '..sea..' <BR>'..rain..' PRECIPITATION <BR>'..cloud..' <BR>'..outlook,
		nil
	)
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
		1986, --CH-53E Super Stallion
		2006, --MH-60R Seahawk
		2793, --MH-53E Sea Dragon
		2794, --MH-60S Knighthawk
		2844, --UH-1Y Venom [Huey]
		297, --MV-22B Osprey
		4356, --MH-60R Seahawk
		4681, --MH-60S Knighthawk
		571, --MH-60S Knighthawk
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

function GenerateRank()
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

function RandomLetter()
	local alphabet = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
	return string.upper(alphabet[math.random(1,#alphabet)])
end

function GenerateSurvivorName()
	local rank = GenerateRank()
	local initials = RandomLetter()..". "..RandomLetter()..". "
	local surnames = {    
		"Adams",
		"Alexander",
		"Allen",
		"Anderson",
		"Bailey",
		"Baker",
		"Barnes",
		"Bell",
		"Bennett",
		"Brooks",
		"Brown",
		"Bryant",
		"Butler",
		"Campbell",
		"Carter",
		"Clark",
		"Coleman",
		"Collins",
		"Cook",
		"Cooper",
		"Cox",
		"Davis",
		"Diaz",
		"Edwards",
		"Evans",
		"Flores",
		"Foster",
		"Garcia",
		"Gonzales",
		"Gonzalez",
		"Gray",
		"Green",
		"Griffin",
		"Hall",
		"Harris",
		"Hayes",
		"Henderson",
		"Hernandez",
		"Hill",
		"Howard",
		"Hughes",
		"Jackson",
		"James",
		"Jenkins",
		"Johnson",
		"Jones",
		"Kelly",
		"King",
		"Lee",
		"Lewis",
		"Long",
		"Lopez",
		"Martin",
		"Martinez",
		"Miller",
		"Mitchell",
		"Moore",
		"Morgan",
		"Morris",
		"Murphy",
		"Nelson",
		"Parker",
		"Patterson",
		"Perez",
		"Perry",
		"Peterson",
		"Phillips",
		"Powell",
		"Price",
		"Ramirez",
		"Reed",
		"Richardson",
		"Rivera",
		"Roberts",
		"Robinson",
		"Rodriguez",
		"Rogers",
		"Ross",
		"Russell",
		"Sanchez",
		"Sanders",
		"Scott",
		"Simmons",
		"Smith",
		"Stewart",
		"Taylor",
		"Thomas",
		"Thompson",
		"Torres",
		"Turner",
		"Walker",
		"Ward",
		"Washington",
		"Watson",
		"White",
		"Williams",
		"Wilson",
		"Wood",
		"Wright",
		"Young",
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
	ScenEdit_SetSidePosture ('United States', 'Iran', 'H')
	ScenEdit_SetSidePosture ('Iran', 'United States', 'H')
end

function CommenceHostilities()
	if not HostilitiesHaveCommenced() then
		SetSidesHostile()
		local missionList = {
			'Bandar Abbas Fishbed Intercept',
			'Bandar Lengeh Intercept',
			'Char Bahar Intercept',
			'Jask Intercept',
			'Maritime Strike A',
			'Maritime Strike B'
		}
		local missionSide = 'Iran'
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

-------IADS/Naval comms disruption
function GetListOfIADSUnits()
	local sideUnits, result = VP_GetSide({side='Iran'}).units, {}
	local affectedDBIDs = {
		{type='Facility', dbid=1254, points=0, name='SAM Plt (SA-13 Gopher [9K35 Strela-10])', destroyedString='destroyed'},--SAM Plt (SA-13 Gopher [9K35 Strela-10])
        {type='Facility', dbid=547, points=0, name='SAM Plt (SA-11 Gadfly [9K37 Buk-M1])', destroyedString='destroyed'},--SAM Plt (SA-11 Gadfly [9K37 Buk-M1])
        {type='Facility', dbid=1815, points=0, name='AAA Bty (100mm KS-19 Auto [Sair] x 4, GFCR)', destroyedString='destroyed'},--AAA Bty (100mm KS-19 Auto [Sair] x 4, GFCR)
        {type='Facility', dbid=1878, points=0, name='AAA Bty (14.5mm/79 ZPU-4 Quad x 4)', destroyedString='destroyed'},--AAA Bty (14.5mm/79 ZPU-4 Quad x 4)
        {type='Facility', dbid=260, points=0, name='SAM Bn (SA-10a Grumble [S-300PT-1])', destroyedString='destroyed'},--SAM Bn (SA-10a Grumble [S-300PT-1])
        {type='Facility', dbid=399, points=0, name='SAM Bn (SA-20a Gargoyle [S-300PM-1])', destroyedString='destroyed'},--SAM Bn (SA-20a Gargoyle [S-300PM-1])
        {type='Facility', dbid=418, points=0, name='SAM Sec (SA-16 Gimlet [9K310 Igla-1] MANPADS x 3)', destroyedString='destroyed'},--SAM Sec (SA-16 Gimlet [9K310 Igla-1] MANPADS x 3)
        {type='Facility', dbid=419, points=0, name='Radar (Tin Shield A [5N59])', destroyedString='destroyed'},--Radar (Tin Shield A [5N59])
        {type='Facility', dbid=556, points=0, name='SAM Plt (RBS 70 Mk1 MANPADS x 3)', destroyedString='destroyed'},--SAM Plt (RBS 70 Mk1 MANPADS x 3)
        {type='Facility', dbid=901, points=0, name='SAM Bn (SA-6a Gainful [2K12E Kvadrat])', destroyedString='destroyed'},--SAM Bn (SA-6a Gainful [2K12E Kvadrat])
        {type='Facility', dbid=902, points=0, name='SAM Bn (HQ-2b)', destroyedString='destroyed'},--SAM Bn (HQ-2b)
        {type='Facility', dbid=906, points=0, name='SAM Plt (HN-5A MANPADS x 4)', destroyedString='destroyed'},--SAM Plt (HN-5A MANPADS x 4)
        {type='Facility', dbid=909, points=0, name='AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)', destroyedString='destroyed'},--AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)
        {type='Facility', dbid=910, points=0, name='AAA Sec (35mm Twin Oerlikon x 2, Skyguard FCR)', destroyedString='destroyed'},--AAA Sec (35mm Twin Oerlikon x 2, Skyguard FCR)
        {type='Facility', dbid=911, points=0, name='AAA Plt/3 (23mm ZU-23-2 x 2)', destroyedString='destroyed'},--AAA Plt/3 (23mm ZU-23-2 x 2)
        {type='Facility', dbid=912, points=0, name='AAA Sec (35mm Twin Oerlikon x 2)', destroyedString='destroyed'},--AAA Sec (35mm Twin Oerlikon x 2)
	}
	for each, entry in ipairs (sideUnits) do
		local unit = ScenEdit_GetUnit({guid=entry.guid})
		for k,v in ipairs(affectedDBIDs) do
			if unit.dbid == v.dbid and unit.type == v.type then
				table.insert(result,unit)
				break
			end
		end
	end
	return result
end

function DisruptIranIADSComms()
	local unitsToBeDisrupted = GetListOfIADSUnits()
	for k,v in ipairs (unitsToBeDisrupted) do
		local chanceOfDisruption = 40
		local chance = math.random(1,100)
		if chance < chanceOfDisruption then
			ScenEdit_SetUnit({guid=v.guid,outofcomms=true})
		end
	end
	ScenEdit_SetDoctrine({side="Iran"}, {weapon_control_status_air=1})
	ScenEdit_SetEMCON('Side', "Iran", 'Radar=Active')
	TelexMessageToPlayer(
		"CSG77",
		'CENTCOM',
		'i',
		'US central command',
		'carrier strike group 77',
		'top secret',
		'1. iranian AIR DEFENSE RADIO TRAFFIC ABRUPTLY CEASED MID TRANSMISSION <BR>2. SIMILAR DISRUPTION NOTED TO DATA TRAFFIC <BR>3. ASSESS THAT iranian AIR DEFENSE CONTROL COMMUNICATIONS ARE CURRENTLY INOPERABLE <BR>4. ANTICIPATE REDUCED COORDINATION OF iranian AIR DEFENSE ACTIVITIES UNTIL COMMUNICATIONS REESTABLISHED',
		nil
	)
end

function GetListOfNavalUnits()
	local sideUnits, result = VP_GetSide({side='Iran'}).units, {}
	local affectedDBIDs = {
		{type='Facility', dbid=1813, points=0, name='SSM Bn (C-704 [Nasr])', destroyedString='destroyed'},--SSM Bn (C-704 [Nasr])
		{type='Facility', dbid=904, points=0, name='SSM Bn (C-802)', destroyedString='destroyed'},--SSM Bn (C-802)
		{type='Ship', dbid=1198, points=0, name='P 313-1 Fath [Thondor Type 021 Houdong]', destroyedString='sunk'},--P 313-1 Fath [Thondor Type 021 Houdong]
		{type='Ship', dbid=2002, points=0, name='Type 022 Houbei', destroyedString='sunk'},--Type 022 Houbei
		{type='Ship', dbid=330, points=0, name='Toragh [Boghammar Mod]', destroyedString='sunk'},--Toragh [Boghammar Mod]
		{type='Submarine', dbid=313, points=500, name='901 Tareq [PL-877EKM Kilo]', destroyedString='sunk'},--901 Tareq [PL-877EKM Kilo]
		{type='Submarine', dbid=508, points=500, name='PL-636.3 Kilo [Varshavyanka]', destroyedString='sunk'},--PL-636.3 Kilo [Varshavyanka]
	}
	for each, entry in ipairs (sideUnits) do
		local unit = ScenEdit_GetUnit({guid=entry.guid})
		for k,v in ipairs(affectedDBIDs) do
			if unit.dbid == v.dbid and unit.type == v.type then
				table.insert(result,unit)
				break
			end
		end
	end
	return result
end

function DisruptIranNavalComms()
	local unitsToBeDisrupted = GetListOfNavalUnits()
	for k,v in ipairs (unitsToBeDisrupted) do
		local chanceOfDisruption = 40
		local chance = math.random(1,100)
		if chance < chanceOfDisruption then
			ScenEdit_SetUnit({guid=v.guid,outofcomms=true})
		end
	end
	ScenEdit_SetDoctrine({side="Iran"}, {weapon_control_status_surface=1,weapon_control_status_subsurface=1})
	--ScenEdit_SetEMCON('Side', "Iran", 'Radar=Active')
	TelexMessageToPlayer(
		"CSG77",
		'CENTCOM',
		'i',
		'US central command',
		'carrier strike group 77',
		'top secret',
		'1. iranian NAVAL COORDINATION RADIO TRAFFIC ABRUPTLY CEASED MID TRANSMISSION <BR>2. SIMILAR DISRUPTION NOTED TO DATA TRAFFIC <BR>3. ASSESS THAT iranian NAVAL COORDINATION COMMUNICATIONS ARE CURRENTLY INOPERABLE <BR>4. ANTICIPATE REDUCED COORDINATION OF iranian NAVAL ACTIVITIES UNTIL COMMUNICATIONS REESTABLISHED',
		nil
	)
end

function IADSMessageHasPlayed(boolValue)
	if boolValue == nil then
		return ConvertStringToBoolean(ScenEdit_GetKeyValue('IADSMessage'))
	elseif boolValue == true then
		ScenEdit_SetKeyValue('IADSMessage','true')
		return true
	elseif boolValue == false then
		ScenEdit_SetKeyValue('IADSMessage','false')
		return false
	else
		return nil
	end
end

function NavalHQMessageHasPlayed(boolValue)
	if boolValue == nil then
		return ConvertStringToBoolean(ScenEdit_GetKeyValue('navalHQMessage'))
	elseif boolValue == true then
		ScenEdit_SetKeyValue('navalHQMessage','true')
		return true
	elseif boolValue == false then
		ScenEdit_SetKeyValue('navalHQMessage','false')
		return false
	else
		return nil
	end
end