function ConvertStringToBoolean(stringName)
	local stringName = string.upper(stringName)
	local result = false
	if stringName == 'TRUE' then
		result = true
	end
	return result
end

function ConvertBooleanToString(booleanValue)
	local result
	if booleanValue == true then
		result = 'true'
	elseif booleanValue == false then
		result = 'false'
	end
	return result
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

function MergeTable(table1, table2)
	for k,v in ipairs(table2) do
		table.insert(table1, v)
	end
	return table1
end

function DTG(TimeVar)
	if TimeVar == nil then
		TimeVar = ScenEdit_CurrentTime()
	end
	local msgtime = os.date("!%H%M %d %b %y", TimeVar)
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

function ReturnPlayerSide()
	local result = VP_GetSide({side='playerside'}).name
	return result
end

function GenerateListOfUnitsOnSide(sideName)
	local result = VP_GetSide({side=sideName}).units
	return result
end

function SearchAndRescueIsInEffect(booleanValue)
	local result
	if booleanValue ~= nil then
		ScenEdit_SetKeyValue('SAR_In_Effect',ConvertBooleanToString(booleanValue))
		result = booleanValue
	else
		result = ConvertStringToBoolean(ScenEdit_GetKeyValue('SAR_In_Effect'))
	end
	return result
end

function CreateGUIDKeyName(guid)
	return 'x_'..guid
end

function RetrieveGUIDFromKey(key)
	local stringLength = string.len(key)
	local result = string.sub(key,3,stringLength)
	return result
end

function CalculateSurvivalTime(guid)
	local unit = ScenEdit_GetUnit({guid=guid})
	local survivalTime = 1800
	if unit.type == 'Ship' then --survives for up to 210min
		survivalTime = math.random(3600,12600)
	elseif unit.type == 'Facility' then --survives for up to 210min
		survivalTime = math.random(3600,12600)
	else
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside',
				unit.name..' is an unrecognised unit type ("'..unit.type..'") for survival time calcs.<BR> It will live for 12 hours.')
		end
	end
	return survivalTime
end

function SetTimeOfDeath(guid)
	local survivalTime = CalculateSurvivalTime(guid)
	local timeOfDeath = tostring(ScenEdit_CurrentTime() + survivalTime)
	local unitKey = CreateGUIDKeyName(guid)
	ScenEdit_SetKeyValue(unitKey,timeOfDeath)
	return timeOfDeath
end

function ReturnTimeOfDeath(guid)
	local unitKey = CreateGUIDKeyName(guid)
	local result = tonumber(ScenEdit_GetKeyValue(unitKey))
	return result
end

function UnitIsAirborneAircraft(unitGUID)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	local result = false
	if unit.type == 'Aircraft' and unit.condition_v == 'Airborne' then 
		result = true
	end
	return result
end

function UnitIsShipOrShallowSub(unitGUID)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	local result = false
	if unit.type == 'Ship' or (unit.type == 'Submarine' and unit.altitude > -150) then
		result = true
	end
	return result
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