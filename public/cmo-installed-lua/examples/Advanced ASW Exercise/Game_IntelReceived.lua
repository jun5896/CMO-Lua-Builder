local sideUnits = VP_GetSide({side="OPFOR"}).units
local submarineList = {}
for k,v in ipairs (sideUnits) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
    local unitType = string.upper(unit.type)
	if unitType == 'SUBMARINE' then
		table.insert(submarineList,unit)
	end
end

local randomSubmarine = submarineList[math.random(1,#submarineList)]

local civilianUnits = VP_GetSide({side="Civilian"}).units
local civilianShipList = {}
for k,v in ipairs (civilianUnits) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
    local unitType = string.upper(unit.type)
	if unitType == 'SHIP' then
		table.insert(civilianShipList,unit)
	end
end

local civilianShipWithinVisualRange = false
local theCivilianShip, rangeToSubmarine = nil, nil

for k,v in ipairs (civilianShipList) do
	rangeToSubmarine = Tool_Range(v.guid,randomSubmarine.guid)
	if rangeToSubmarine <= 7 then
		theCivilianShip = ScenEdit_GetUnit({guid=v.guid})
		civilianShipWithinVisualRange = true
		break
	end
end

if civilianShipWithinVisualRange == true then
	local reportedPosition = CircularRandomPosition(
		theCivilianShip.latitude, 
		theCivilianShip.longitude, 
		rangeToSubmarine/2)
		
	local positionString = ConvertDecimalPositionToDegrees(
		reportedPosition.latitude,reportedPosition.longitude)
		
	local theMessage = ACP126('FOST','FLEET','i','CINCFLEET NORTHWOOD','FOST TASK GROUP COMMANDER',
			'secret','possible submarine periscope sighting reported by civilian vessel '..theCivilianShip.name..' at '..positionString..' <BR> recommend immediate investigation and prosecution')
			
	local referencePointName = 'POSSUB '..DTG()
	
	local theReferencePoint = ScenEdit_AddReferencePoint({
		side='FOST Units', 
		latitude=reportedPosition.latitude, 
		longitude=reportedPosition.longitude, 
		name=referencePointName, 
		highlighted=true})
		
	ScenEdit_SpecialMessage('playerside',theMessage)
	RegisterMessage(theMessage)
	ScenEdit_SetKeyValue('intelReceived','true')
	
else
	local redoCounter = 0
	::redoPosition::
	local triangulatedPosition = CircularRandomPosition(randomSubmarine.latitude,randomSubmarine.longitude,10)
	if OverWater(triangulatedPosition.latitude,triangulatedPosition.longitude) then
		
		local triangulatedArea = World_GetCircleFromPoint({
			latitude=triangulatedPosition.latitude,
			longitude=triangulatedPosition.longitude,
			radius=math.random(10,15),
			numpoints = 12})
			
		local rpPrefix = 'PROBSUB '..DTG()
		for k,v in ipairs (triangulatedArea) do
			local theRP = ScenEdit_AddReferencePoint({
				latitude=v.latitude,
				longitude=v.longitude,
				name=rpPrefix..' #'..k,
				side='FOST Units',
				highlighted=true
			})
		end
		
		local positionString = ConvertDecimalPositionToDegrees(
		triangulatedPosition.latitude,triangulatedPosition.longitude)
		
		local theMessage = ACP126('FOST','FLEET','i','CINCFLEET NORTHWOOD','FOST TASK GROUP COMMANDER',
			'top secret','sigint intercept via ODD BIRD indicates probable submarine in vicinity of '..positionString..' <BR> recommend immediate investigation and prosecution')
		
		ScenEdit_SpecialMessage('playerside',theMessage)
		RegisterMessage(theMessage)
		ScenEdit_SetKeyValue('intelReceived','true')
		
	else
		redoCounter = redoCounter + 1
		if redoCounter > 100 then
			BugMessage('Game_IntelReceived','Unable to find a suitable triangulated position after 100 attempts!')
		else
			goto redoPosition
		end
	end
end