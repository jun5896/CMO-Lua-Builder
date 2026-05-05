math.randomseed(os.time())

function shuffleTable(tableName)
	local n = #tableName
	for i = n, 2, -1 do
		local j = math.random(i)
		tableName[i], tableName[j] = tableName[j], tableName[i]
	end
end

function RoundNumber(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function ConvertDecimalToCoord(latitude, longitude)
	-- Convert latitude and longitude to numbers if they are strings
	latitude = tonumber(latitude)
	longitude = tonumber(longitude)

	-- Determine if latitude is North or South
	local latDirection = "N"
	if latitude < 0 then
		latDirection = "S"
		latitude = math.abs(latitude)
	end
	
	-- Determine if longitude is East or West
	local lonDirection = "E"
	if longitude < 0 then
		lonDirection = "W"
		longitude = math.abs(longitude)
	end
	
	-- Separate degrees, minutes, and seconds for latitude
	local latDegrees = math.floor(latitude)
	local latMinutesFull = (latitude - latDegrees) * 60
	local latMinutes = math.floor(latMinutesFull)
	local latSeconds = math.floor((latMinutesFull - latMinutes) * 60) -- Rounded to no decimals
	
	-- Separate degrees, minutes, and seconds for longitude
	local lonDegrees = math.floor(longitude)
	local lonMinutesFull = (longitude - lonDegrees) * 60
	local lonMinutes = math.floor(lonMinutesFull)
	local lonSeconds = math.floor((lonMinutesFull - lonMinutes) * 60) -- Rounded to no decimals
	
	-- Format the result as degrees, minutes, and rounded seconds with direction
	local formattedLatitude = string.format("%d° %d' %d\" %s", latDegrees, latMinutes, latSeconds, latDirection)
	local formattedLongitude = string.format("%d° %d' %d\" %s", lonDegrees, lonMinutes, lonSeconds, lonDirection)
	
	return formattedLatitude, formattedLongitude
end

function RandomPosition(latitudeMin,latitudeMax,longitudeMin,longitudeMax)
	local lat_var = math.random(1,(10^13)) -- random number between 1 and 10^13
	local lon_var = math.random(1,(10^13)) -- random number between 1 and 10^13
	local pos_lat = math.random(latitudeMin,latitudeMax) + (lat_var/(10^13)) -- latitude; 
	local pos_lon = math.random(longitudeMin,longitudeMax) + (lon_var/(10^13)) -- longitude; 
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

function OverWater(latitude, longitude)
	local pointElevation = World_GetElevation({
		latitude = latitude,
		longitude = longitude})
	if pointElevation < 0 then
		return true
	else
		return false
	end
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
	dtg = DTG()
	--from --e.g. MET FLT OPS
	--to --e.g. SSN 21 SEAWOLF
	--classification --Unclass +/- SBU / FOUO / NOFORN (Restricted), Confidential, Secret, Top Secret
	--body
	_,gr = body:gsub("%S+","")
	sig_string = string.upper('<P><FONT face=Consolas>'..rec_station..' <BR>'..
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

function ACP126(snd_station, rec_station, precedence, classification, time, body)
	-- Precedence -- Flash (Z), Immediate (O), Priority (P), Routine (R), Flash Override (Y)
	-- From -- e.g. MET FLT OPS
	-- To -- e.g. SSN 21 SEAWOLF
	-- Classification -- Unclas +/- SBU / FOUO / NOFORN (Restricted), Confidential, Secret, Top Secret
	-- Body
	local msg_time
	if time == nil then
		msg_time = DTG()
	else
		msg_time = time
	end

	local signal_string = string.upper(
		'<P><FONT face=Courier New>' ..
		'SENDING STATION: '..snd_station..' <BR>' .. 
		'RECEIVING STATION: '..rec_station..' <BR>' ..
		'PRIORITY: '..precedence.. ' <BR>' ..
		'CLASSIFICATION: '..classification..' <BR>' ..
		'DTG: '..msg_time.. ' <BR>' ..
		'<P>'..body..'</P>'
	)

	return signal_string
end

function TelexMessageToPlayer(snd_station, rec_station, precedence, classification, time, body, location)
	local theMessage = ACP126(snd_station, rec_station, precedence, classification, time, body)
	if location ~= nil then
		ScenEdit_SpecialMessage('playerside', theMessage, {latitude=location.latitude, longitude=location.longitude})
	else
		ScenEdit_SpecialMessage('playerside', theMessage)
	end
	ScenEdit_PlaySound('telex.mp3')
end