--gets a list of all survivor-type units
local function GetListOfSurvivors()
	local sideUnits = VP_GetSide({side='Survivors'}).units
	local survivorTable = {}
	local liferaftDBID = 2553
	local strandedPersonDBID = 2441
	for k,v in ipairs (sideUnits) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.dbid == liferaftDBID or unit.dbid == strandedPersonDBID then
            table.insert(survivorTable,unit)
		end
	end
	return survivorTable
end
--checks to see if any other units are close enough for rescue

local function GetListOfNearbyUnits(unitGUID)
	local listOfNearbyUnits = {}
	local maximumRescueDistance = 1
	local sideUnits = VP_GetSide({side='Colombia'}).units
	for k,v in ipairs (sideUnits) do
		local distance = Tool_Range(unitGUID,v.guid)
		if distance < maximumRescueDistance then 
			local unitData = ScenEdit_GetUnit({guid=v.guid})
			table.insert(listOfNearbyUnits,unitData)
		end
	end
    print (listOfNearbyUnits)
	return listOfNearbyUnits
end


local function AirUnitIsWithinRescueParams(unitGUID)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	if unit.altitude <= 75 and unit.speed <= 50 then
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

local rescueCapableUnits = {
	{name='AS.555SN', dbid=405, type='Aircraft'},

	{name='UH-60L Blackhawk', dbid=4251, type='Aircraft'},
	{name='AH-60A Arpia III', dbid=4252, type='Aircraft'},
	{name='Mi-17V5 Hip H', dbid=3879, type='Aircraft'},
	{name='Bell 412EP', dbid=4094, type='Aircraft'},
	
	{name='FM 53 Antioquia', dbid=1924, type='Ship'},
	{name='SO 28 Pijao', dbid=242, type='Submarine'},
}

local function UnitIsRescueCapable(unitGUID)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	local rescueCapable = false
	for k,v in ipairs (rescueCapableUnits) do 
		if unit.dbid == v.dbid then
			rescueCapable = true
		end
	end
    print (unit.name..' is rescue capable: '..tostring(rescueCapable))
    return rescueCapable
end


local function UnitIsReadyToRescue(unitGUID)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	if unit.type == 'Facility' then
		return true
	end
	if UnitIsRescueCapable(unit.guid) then
		if unit.type == 'Ship' and unit.speed <= 10 then
			return true
		elseif unit.type == 'Aircraft' and AirUnitIsWithinRescueParams(unit.guid) then
			return true
		elseif unit.type == 'Submarine' and SubmarineIsWithinRescueParams(unit.guid) then
			return true
		end
	else
		return false
	end
end

local function AppendRescueSummary(rescuedUnitName, rescuerName)
	local theMessage = '<BR> '..rescuedUnitName .. ' was rescued by '..rescuerName..' at '..DTG()
	local theSummary = ScenEdit_GetKeyValue('rescueSummary')
	if theSummary == nil then theSummary = '' end
	theUpdatedSummary = theSummary..theMessage
	ScenEdit_SetKeyValue('rescueSummary',theUpdatedSummary)
end

local function DoRescue(rescuedUnitGUID, rescuerGUID)
	local rescuedUnit = ScenEdit_GetUnit({guid=rescuedUnitGUID})
	local rescuer = ScenEdit_GetUnit({guid=rescuerGUID})
	AppendRescueSummary(rescuedUnit.name, rescuer.name)
	ChangeScore('Colombia',25,rescuedUnit.name..' was rescued.')
	ScenEdit_DeleteUnit({guid=rescuedUnitGUID})
end

local survivorList = GetListOfSurvivors()

if surivorList == {} or surivorList == nil then
	ScenEdit_SetEvent('Game_SAR',{isactive=false})
else
	for k,survivor in ipairs (survivorList) do
		local listOfNearbyUnits = GetListOfNearbyUnits(survivor.guid)
		for key, nearbyUnit in ipairs (listOfNearbyUnits) do
			if UnitIsReadyToRescue(nearbyUnit.guid) then
				DoRescue(survivor.guid, nearbyUnit.guid)
				table.remove(survivorList,k)
			end
		end
	end
end