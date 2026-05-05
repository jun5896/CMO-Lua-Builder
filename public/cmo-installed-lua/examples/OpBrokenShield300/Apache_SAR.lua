local function GenerateListOfSurvivorUnits()
	local result = {}
	local survivorTable = GenerateListOfUnitsOnSide('Israel Downed Aircrew')
	local validDBIDs = {
		Ship = {2553},
		Facility = {2441, 3135}
	}
	
	for k,v in ipairs(survivorTable) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		local validUnits = validDBIDs[unit.type]
		if validUnits then
			for _, dbid in ipairs(validUnits) do
				if unit.dbid == dbid then
					table.insert(result, unit)
					break
				end
			end
		end
	end
	
	return result
end

local function UnitIsARescueAircraft(unitGUID)
	local rescueAircraft = {
		{type="Aircraft", dbid=1698, points=0, isUAV=false, numberOfCrew=0}, -- S-70A-9 Blackhawk [AH-60L Battle Hawk]
		{type="Aircraft", dbid=2405, points=0, isUAV=false, numberOfCrew=0}, -- AS.565SA Panther [Atalef]
		{type="Aircraft", dbid=4732, points=0, isUAV=false, numberOfCrew=0}, -- CH-53C Sea Stallion [Yasur 2025]
	}

	local unit, result = ScenEdit_GetUnit({guid=unitGUID}), false
	for k,v in ipairs (rescueAircraft) do
		if unit.dbid == v.dbid then result = true end
	end
	return result
end

local function UnitIsRescueCapable(unitGUID)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	local result = false
	if unit.type == 'Ship' or unit.type == 'Submarine' or unit.type == 'Facility' then
		result = true
	elseif unit.type == 'Aircraft' and UnitIsARescueAircraft(unit.guid) then
		result = true
	end
	return result
end

local function GenerateListOfRescueUnits()
	local result, playerSide = {}, ReturnPlayerSide() -- Ensure ReturnPlayerSide is defined
	local playerSideUnits = GenerateListOfUnitsOnSide(playerSide)
	for k,v in ipairs (playerSideUnits) do
		if UnitIsRescueCapable(v.guid) then table.insert(result,v) end
	end
	return result
end

local function GetListOfNearbyUnits(unitGUID)
	local result = {}
	local maximumRescueDistance = 1
	local rescueCandidates = GenerateListOfRescueUnits()
	for k,v in ipairs (rescueCandidates) do
		local distance = Tool_Range(unitGUID,v.guid)
		if distance < maximumRescueDistance then 
			local unitData = ScenEdit_GetUnit({guid=v.guid})
			table.insert(result,unitData)
		end
	end
	return result
end

local function AirUnitIsWithinRescueParams(unitGUID)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	local altitudeAboveSeaLevel, terrainElevation = unit.altitude, World_GetElevation({latitude=unit.latitude,longitude=unit.longitude})
	if terrainElevation < 0 then terrainElevation = 0 end
	local altitudeAboveGround = altitudeAboveSeaLevel - terrainElevation
	if altitudeAboveGround <= 75 and unit.speed <= 50 then
		print (unit.name..' is within rescue parameters ')
		return true
	else
		print (unit.name..' is NOT within rescue parameters ')
		return false
	end  
end

local function SubmarineIsWithinRescueParams(unitGUID)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	if unit.altitude >= -20 and unit.speed <= 6 then
		return true
	else
		return false
	end
end

local function UnitIsReadyToRescue(unitGUID)
	local unit, result = ScenEdit_GetUnit({guid=unitGUID}), false
	if UnitIsRescueCapable(unit.guid) then
		if unit.type == 'Ship' and unit.speed <= 10 then
			result = true
		elseif unit.type == 'Facility' then
			result = true
		elseif unit.type == 'Aircraft' and AirUnitIsWithinRescueParams(unit.guid) then
			result = true
		elseif unit.type == 'Submarine' and SubmarineIsWithinRescueParams(unit.guid) then
			result = true
		end
	end
	return result
end

local function DisplayRescueMessage(rescuedUnitName, rescuerName)
	local theMessage = '<BR> '..rescuedUnitName .. ' was rescued by '..rescuerName..' at '..DTG()
	ScenEdit_SpecialMessage('Israel',theMessage)
end

local function DisplayCaptureMessage(deadUnitName)
	local theMessage = '<BR> '..deadUnitName .. ' is no longer responding to radio communication. Presumed captured at '..DTG()
	ScenEdit_SpecialMessage('Israel',theMessage)
end

local function ReturnPenaltyForSurvivorDeath(unitDBID)
	local result = {points = -500, attrition = 1}
	if unitDBID == 2553 then
		result.points = 20*(-25)
		result.attrition = 20
	end
	return result 
end

local function ReturnRewardForSurvivorRescue(unitDBID)
	local result = {points = 500, attrition = -1}
	if unitDBID == 2553 then
		result.points = 20*(25)
		result.attrition = -20
	end
	return result 
end

local function SurvivorDies(deadUnitGUID)
	local deadUnit = ScenEdit_GetUnit({guid=deadUnitGUID}) 
	local ownerSide, penalty = string.gsub(deadUnit.side, ' Downed Aircrew',''), ReturnPenaltyForSurvivorDeath(deadUnit.dbid)
	ChangeScore(ownerSide,penalty.points,deadUnit.name..' was captured before being rescued.')
	DisplayCaptureMessage(deadUnit.name)
	ScenEdit_DeleteUnit({guid=deadUnit.guid})
end

local function DoRescue(rescuedUnitGUID, rescuerGUID)
	local rescuedUnit, rescuer = ScenEdit_GetUnit({guid=rescuedUnitGUID}), ScenEdit_GetUnit({guid=rescuerGUID})
	local reward = ReturnRewardForSurvivorRescue(rescuedUnit.dbid)
	DisplayRescueMessage(rescuedUnit.name, rescuer.name)
	ChangeScore(rescuer.side,reward.points,rescuedUnit.name..' was rescued.')
	ScenEdit_DeleteUnit({guid=rescuedUnitGUID})
end

local function DoRescueRoutine()
	local survivorList = GenerateListOfSurvivorUnits()
	for k,survivor in ipairs (survivorList) do
		local listOfNearbyUnits = GetListOfNearbyUnits(survivor.guid)
		for key, nearbyUnit in ipairs (listOfNearbyUnits) do
			if UnitIsReadyToRescue(nearbyUnit.guid) then
				DoRescue(survivor.guid, nearbyUnit.guid)
			end
		end
	end
end

local function CleanUpExpiredSurvivors()
	local survivorList = GenerateListOfSurvivorUnits()
	local timeNow = ScenEdit_CurrentTime()
	local elapsedTime = 1800 -- 30 minutes of game time (60 seconds * 30 minutes)

	for k,survivor in ipairs (survivorList) do
		local timeOfDeath = ReturnTimeOfDeath(survivor.guid)
		if timeOfDeath ~= nil and (timeNow - timeOfDeath) > thirtyMinutesInSeconds then
			SurvivorDies(survivor.guid)
		end
	end
end

function ReturnTimeOfDeath(guid)
	local unitKey = CreateGUIDKeyName(guid)
	local result = tonumber(ScenEdit_GetKeyValue(unitKey))
	return result
end

DoRescueRoutine()
CleanUpExpiredSurvivors()