ScenEdit_RunScript('DeveloperMode.lua')

math.randomseed(os.time())

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
		result = true
	elseif booleanValue == false then
		result = false
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

function SearchAndRescueIsInEffect(boolValue)
	if boolValue == nil then
		return ConvertStringToBoolean(ScenEdit_GetKeyValue('SAR_In_Effect'))
	elseif boolValue == true then
		ScenEdit_SetKeyValue('SAR_In_Effect','true')
		return true
	elseif boolValue == false then
		ScenEdit_SetKeyValue('SAR_In_Effect','false')
		return false
	else
		return nil
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

-- Israel Side Setup

function IsraelSideSetup()
	ScenEdit_SetEvent('Leading to hostility', {isactive=true})
	ScenEdit_SetEvent('Leading to hostility2', {isactive=false})
	ScenEdit_SetEvent('Syrian Air Defense HQ is out of action2', {isactive=true})
	ScenEdit_SetSidePosture('Israel', 'Syria', 'U')
	ScenEdit_SetSidePosture('Israel', 'Syria.', 'U')
	ScenEdit_SetSidePosture('Israel', 'Iranian Infrastructure', 'U')

	ScenEdit_SetUnit({side='Syria', unitname='Buk-M1 (Damascus West) #2', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Buk-M2E (Damascus East) #1', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Buk-M2E (Damascus North) #2', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Buk-M2E (Damascus North) #3', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Buk-M2E (T4) #5', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Mobile Sector Control - IADS South Syria', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #10', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #11', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #2', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #3', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #7', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #8', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus East) #12', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus East) #13', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus West) #22', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus West) #23', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (T4) #25', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (T4) #26', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (T4) #27', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Radar 64N6 #1', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Radar 9S36 #1', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Radar 9S36 #3', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn 2K12E Kvadrat #3', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn 2K12E Kvadrat (Damascus West) #7', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-125M (Damascus West) #3', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-125M (Damascus West) #4', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-300PMU-2 (Damascus East) #1', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-300PMU-2 (Damascus North) #2', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-300PMU-2 (T4) #3', autodetectable=false})
	ScenEdit_SetUnit({side='Syria', unitname='Syrian Air Defense HQ', autodetectable=false})

	local listOfRPNames = {'RP-3055', 'RP-3056', 'RP-3057', 'RP-3057', 'RP-3058', 'RP-3022', 'RP-3023', 'RP-3024', 'RP-3025', 'RP-3027', 'RP-3028', 'RP-3029', 'RP-3030', 'RP-3033', 'RP-3034', 'RP-3035', 'RP-3036', 'RP-3038', 'RP-3039', 'RP-3040', 'RP-3041', 'RP-3042', 'RP-3043', 'RP-3044', 'RP-3045'}
	for k,v in ipairs (listOfRPNames) do
		ScenEdit_DeleteReferencePoint({name=v, side='Israel'})
	end

	ScenEdit_DeleteMission('Israel', 'Hatzor AB')
	ScenEdit_DeleteMission('Israel', 'Hazerim AB')
	ScenEdit_DeleteMission('Israel', 'Nevatim AB')
	ScenEdit_DeleteMission('Israel', 'Ovda AB')
	ScenEdit_DeleteMission('Israel', 'Palmachim AB')
	ScenEdit_DeleteMission('Israel', 'Ramat David AB')
	ScenEdit_DeleteMission('Israel', 'Ramon AB')
	ScenEdit_DeleteMission('Israel', 'Tel Aviv-Dov Hoz AB')
	ScenEdit_DeleteMission('Israel', 'Tel Nof AB')

	local message = ScenEdit_SpecialMessage('Israel','<P><IMG src="https://i.imgur.com/hOs8HsQ.jpg" align=middle></P><P>Commander, welcome to the Control room! Grab some coffee as it appears this will be one of those really long days. The briefing already got you up to speed with the current situation and there is nothing new to report at the moment. We have a&nbsp;satellite that will make a pass over Syria in about 50 minutes, you can use the time till then&nbsp;to check on the currently available IAF assets and to get familiar with the weapon types available in the magazines.</P><P> You should also check out the available Special Actions!<P>', {lat=32.0715413805,lon=34.7861001889})

	RegisterMessage(message)
end

-- Syria Side Setup

function SyriaSideSetup()
	ScenEdit_SetTime({Date='02:13:2020', Time='18:00:00'})
	ScenEdit_SetEvent('.SyriaAttackstarted', {isactive=true})
	ScenEdit_SetEvent('.SyriaIADSonly', {isactive=true})
	ScenEdit_SetEvent('Fateh-110s', {isactive=true})
	ScenEdit_SetEvent('Leading to hostility', {isactive=false})
	ScenEdit_SetEvent('Leading to hostility2', {isactive=false})
	ScenEdit_SetEvent('Satellite comes in range', {isactive=false})
	ScenEdit_SetEvent('SF team not extracted in time', {isactive=false})
	ScenEdit_SetEvent('Side event 1.1', {isactive=false})
	ScenEdit_SetEvent('Side event 1.2', {isactive=false})
	ScenEdit_SetEvent('Side event 2.1', {isactive=false})
	ScenEdit_SetEvent('Side event 2.2 Failsafe', {isactive=false})
	ScenEdit_SetEvent('Side event 2.2', {isactive=false})
	ScenEdit_SetEvent('Side event 2.2', {isactive=false})
	ScenEdit_SetEvent('Side event 2.2 Failsafe', {isactive=false})
	ScenEdit_SetEvent('Side event 3', {isactive=false})
	ScenEdit_SetEvent('Side event 4', {isactive=false})
	ScenEdit_SetEvent('Side event 5', {isactive=false})
	ScenEdit_SetEvent('Syrian Air Defense HQ is out of action', {isactive=true})
	ScenEdit_SetEvent('Time sensitive target 1', {isactive=false})
	ScenEdit_SetEvent('Time sensitive target 1 Activate Failsafe', {isactive=false})
	ScenEdit_SetEvent('Time sensitive target 2', {isactive=false})
	ScenEdit_SetSidePosture('Israel', 'Syria', 'H')
	ScenEdit_SetSidePosture('Israel', 'Syria.', 'H')
	ScenEdit_SetSidePosture('Israel', 'Iranian Infrastructure', 'H')

	mySide = VP_GetSide({Name='Israel'}) 
	myZone = mySide:getnonavzone('Jordan2') 
	myZone.isactive = false
	mySide = VP_GetSide({Name='Israel'}) 
	myZone = mySide:getnonavzone('Syrian Airspace') 
	myZone.isactive = false

	ScenEdit_SetUnit({side='Syria', unitname='Buk-M1 (Damascus West) #2', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Buk-M2E (Damascus East) #1', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Buk-M2E (Damascus North) #2', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Buk-M2E (Damascus North) #3', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Buk-M2E (T4) #5', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Mobile Sector Control - IADS South Syria', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #10', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #11', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #2', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #3', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #7', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #8', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus East) #12', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus East) #13', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus West) #22', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus West) #23', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (T4) #25', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (T4) #26', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (T4) #27', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Radar 64N6 #1', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Radar 9S36 #1', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Radar 9S36 #3', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn 2K12E Kvadrat #3', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn 2K12E Kvadrat (Damascus West) #7', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-125M (Damascus West) #3', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-125M (Damascus West) #4', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-300PMU-2 (Damascus East) #1', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-300PMU-2 (Damascus North) #2', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='SAM Bn S-300PMU-2 (T4) #3', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Syrian Air Defense HQ', autodetectable=true})

	ScenEdit_AssignUnitAsTarget({'Buk-M1 (Damascus West) #2'}, 'M270 Strike')
	ScenEdit_AssignUnitAsTarget({'Buk-M2E (Damascus East) #1'}, 'Strike Package Echo 05')
	ScenEdit_AssignUnitAsTarget({'Buk-M2E (Damascus North) #2'}, 'LYNX Strike')
	ScenEdit_AssignUnitAsTarget({'Buk-M2E (Damascus North) #3'}, 'LYNX Strike')
	ScenEdit_AssignUnitAsTarget({'Buk-M2E (T4) #5'}, 'Strike Package Tango 02')
	ScenEdit_AssignUnitAsTarget({'Mobile Sector Control - IADS South Syria'}, 'Strike Package Foxtrot 03')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E #11'}, 'Strike Package Foxtrot 02')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E #3'}, 'Strike Package Foxtrot 03')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E #7'}, 'Strike Package Foxtrot 03')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E #8'}, 'Strike Package Foxtrot 01')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E (Damascus East) #12'}, 'Strike Package Echo 05')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E (Damascus East) #13'}, 'Strike Package Echo 05')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E (Damascus West) #22'}, 'M270 Strike')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E (Damascus West) #23'}, 'M270 Strike')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E (T4) #25'}, 'Strike Package Tango 02')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E (T4) #26'}, 'Strike Package Tango 02')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E (T4) #27'}, 'Strike Package Tango 02')
	ScenEdit_AssignUnitAsTarget({'Radar 64N6 #1'}, 'Strike Package Echo 05')
	ScenEdit_AssignUnitAsTarget({'Radar 9S36 #1'}, 'Strike Package Tango 02')
	ScenEdit_AssignUnitAsTarget({'Radar 9S36 #3'}, 'Strike Package Echo 05')
	ScenEdit_AssignUnitAsTarget({'SAM Bn 2K12E Kvadrat #3'}, 'Strike Package Foxtrot 03')
	ScenEdit_AssignUnitAsTarget({'SAM Bn 2K12E Kvadrat (Damascus West) #7'}, 'M270 Strike')
	ScenEdit_AssignUnitAsTarget({'SAM Bn S-125M (Damascus West) #3'}, 'M270 Strike')
	ScenEdit_AssignUnitAsTarget({'SAM Bn S-300PMU-2 (Damascus East) #1'}, 'Strike Package Echo 01')
	ScenEdit_AssignUnitAsTarget({'SAM Bn S-300PMU-2 (Damascus East) #1'}, 'Strike Package Echo 03')
	ScenEdit_AssignUnitAsTarget({'SAM Bn S-300PMU-2 (Damascus East) #1'}, 'Strike Package Echo 05')
	ScenEdit_AssignUnitAsTarget({'SAM Bn S-300PMU-2 (Damascus North) #2'}, 'LYNX Strike')
	ScenEdit_AssignUnitAsTarget({'SAM Bn S-300PMU-2 (Damascus North) #2'}, 'Strike Package November 02')
	ScenEdit_AssignUnitAsTarget({'SAM Bn S-300PMU-2 (T4) #3'}, 'Strike Package Tango 01')
	ScenEdit_AssignUnitAsTarget({'SAM Bn S-300PMU-2 (T4) #3'}, 'Strike Package Tango 03')
	ScenEdit_AssignUnitAsTarget({'Syrian Air Defense HQ'}, 'Strike Package November 04')

	ScenEdit_AddUnit({type='facility', name='MLRS Bty (Lynx) 2', dbid=3176, side='Israel', Latitude='33.1533333', Longitude='35.58111111111111', autodetectable=false})
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E #11'}, 'Strike Package Foxtrot 02')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E (Damascus North) #15'}, 'LYNX Strike')
	ScenEdit_AssignUnitAsTarget({'Pantsir-S1E (Damascus North) #17'}, 'LYNX Strike')
	ScenEdit_AssignUnitToMission('MLRS Bty (Lynx) 2', 'LYNX Strike')
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E #11', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus North) #15', autodetectable=true})
	ScenEdit_SetUnit({side='Syria', unitname='Pantsir-S1E (Damascus North) #17', autodetectable=true})

	ScenEdit_SetLoadout({unitname='69sq #246', LoadoutID=25991, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='69sq #250', LoadoutID=25991, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='69sq #252', LoadoutID=25987, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='69sq #255', LoadoutID=25987, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='69sq #259', LoadoutID=25987, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='69sq #261', LoadoutID=25987, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='69sq #263', LoadoutID=26016, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='69sq #267', LoadoutID=26016, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='105sq #630', LoadoutID=11823, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='105sq #638', LoadoutID=11823, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='105sq #648', LoadoutID=11823, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='105sq #651', LoadoutID=11823, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='105sq #678', LoadoutID=11823, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='105sq #682', LoadoutID=11823, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='105sq #684', LoadoutID=11823, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='105sq #687', LoadoutID=11823, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='106sq #525', LoadoutID=18190, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='106sq #530', LoadoutID=18190, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='106sq #541', LoadoutID=18190, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='106sq #560', LoadoutID=18190, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='106sq #832', LoadoutID=18190, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='106sq #840', LoadoutID=18190, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='107sq #823', LoadoutID=26045, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='107sq #826', LoadoutID=26045, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='107sq #827', LoadoutID=24973, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='107sq #833', LoadoutID=24973, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='117sq #304', LoadoutID=24971, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='117sq #305', LoadoutID=24971, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='117sq #353', LoadoutID=24971, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='117sq #356', LoadoutID=24971, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #403', LoadoutID=26044, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #425', LoadoutID=26044, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #437', LoadoutID=26044, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #447', LoadoutID=26044, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #477', LoadoutID=26040, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #486', LoadoutID=26040, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #491', LoadoutID=26040, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #493', LoadoutID=26040, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #494', LoadoutID=26045, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='119sq #497', LoadoutID=26045, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='120sq #264', LoadoutID=8280, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='120sq #272', LoadoutID=8280, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='140sq #913', LoadoutID=1843, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='140sq #916', LoadoutID=1843, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='140sq #917', LoadoutID=18068, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='140sq #918', LoadoutID=18068, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='201sq #857', LoadoutID=26046, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='201sq #860', LoadoutID=26046, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='201sq #871', LoadoutID=26050, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='201sq #872', LoadoutID=26050, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='253sq #462', LoadoutID=24973, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='253sq #466', LoadoutID=24973, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='253sq #468', LoadoutID=24973, TimeToReady_Minutes=0, IgnoreMagazines=true})
	ScenEdit_SetLoadout({unitname='253sq #470', LoadoutID=24973, TimeToReady_Minutes=0, IgnoreMagazines=true})

	local message = ScenEdit_SpecialMessage('Syria','<P><IMG alt=https://i.imgur.com/R9wVVU8.jpg src="https://i.imgur.com/R9wVVU8.jpg"></P><P>Commander,</P><P>we do not have reports of increased IAF activity so far, but that can change any minute now. Most of our SAM batteries finished relocating to new and supposedly unknown as of yet&nbsp;to the enemy positions about&nbsp;10-12 hours ago. We belive that conducting major relocations now will be counterproductive as Israel is looking for them and moving targets are easier to get picked with their radars on GMTI mode (Ground Moving Target Indication). Worst of all - they can get caught off guard while moving!</P><P>The Air Force is also preparing some fighters right now that will be transfered under our command, but they strongly believe that getting them in the air in any other situation then intercept of confirmed hostile fighters would be a waste or worse - pure suicide.</P>')

	RegisterMessage(message)
end

-- Player Side Setup

function PlayerSideSetup()
	local PlayerSide = ScenEdit_PlayerSide()
	if ScenEdit_PlayerSide() == 'Israel' then
		IsraelSideSetup()
	else
		SyriaSideSetup()
	end
end

-- Scenario Setup

function ThisIsFirstLoad(booleanValue)
	local result
	if booleanValue == nil then
		result = ScenEdit_GetKeyValue('firstLoad')
		if result == '' or result == nil then result = true end
		if result == false then result = false end
	else
		if booleanValue == true then
			ScenEdit_ClearKeyValue('firstLoad')
			result = true
		elseif booleanValue == false then
			ScenEdit_SetKeyValue('firstLoad',false)
			result = false
		end
	end
	return result
end

if ThisIsFirstLoad() then
	local PlayerSide = ScenEdit_PlayerSide()
	if inDevelopment then -- Ask to do stuff
		userInput = string.upper(ScenEdit_MsgBox('Execute scenario setup?',1))
		if userInput == 'OK' then
			PlayerSideSetup()
		end

		userInput = string.upper(ScenEdit_MsgBox('Set firstLoad key value to false?',1))
		if userInput == 'OK' then
			ThisIsFirstLoad(false)
		end
	else -- Don't give the option and just do it
		PlayerSideSetup()
		ThisIsFirstLoad(false)
	end
end