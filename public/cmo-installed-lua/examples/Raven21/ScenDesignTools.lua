function PrintSideUnitScoringTemplate(sideName)
    local sideUnits = VP_GetSide({side=sideName}).units
    for k,v in ipairs (sideUnits) do
        local unit = ScenEdit_GetUnit({guid=v.guid})
        print (
            "{type='"..unit.type..
            "', dbid="..unit.dbid..
			", points=0"..
			", name='"..unit.classname..
            "', destroyedString=nil"..
            "},--"..unit.classname)
    end
end

function RenameReferencePoints(x,y,prefix)
	local counter = 0
	for i = x,y do
		counter = counter + 1
	    ScenEdit_SetReferencePoint({side='playerside',
	    	name='RP-'..i,
	    	newname=prefix..' '..counter,
	    	highlighted=true})
	end
end

function MarkTerritorialWaters(x,y,prefix,angle)
	local RPList = {}
	for i = y,x,-1 do
		local refPoint = ScenEdit_GetReferencePoint({
			side='playerside',
			name='RP-'..i
		})
		table.insert(RPList,refPoint)
	end

	for k,v in ipairs(RPList) do
		local newRPPos = World_GetPointFromBearing({
            latitude=v.latitude,
            longitude=v.longitude,
            distance=12,
            bearing=angle
        })
        local newRP = ScenEdit_AddReferencePoint({
            side='playerside',
            latitude=newRPPos.latitude,
            longitude=newRPPos.longitude,
            highlighted=true
        })
    end
end

function CreateCircleOfReferencePointsAroundUnit(unitGUID,numpoints,radius,prefix)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	local rpTable = {}
	local circle = World_GetCircleFromPoint({latitude=unit.latitude,
		longitude=unit.longitude,
		radius=radius,
		numpoints=numpoints})
	for k,v in ipairs (circle) do
		local rp = ScenEdit_AddReferencePoint({side='playerside',
			latitude=v.latitude,
			longitude=v.longitude,
			name=prefix..' '..k,
			highlighted=true})
		table.insert(rpTable,rp.guid)
	end
	return rpTable
end

function CreateCircleOfReferencePointsAroundRP(rpGUID,rpSide,numpoints,radius,prefix)
	local unit = ScenEdit_GetReferencePoint({side=rpSide,guid=rpGUID})
	local rpTable = {}
	local circle = World_GetCircleFromPoint({latitude=unit.latitude,
		longitude=unit.longitude,
		radius=radius,
		numpoints=numpoints})
	for k,v in ipairs (circle) do
		local rp = ScenEdit_AddReferencePoint({side=unit.side,
			latitude=v.latitude,
			longitude=v.longitude,
			name=prefix..' '..k,
			highlighted=true})
		table.insert(rpTable,rp.guid)
	end
	return rpTable
end

function ClearSideReferencePoints(sideName)
	local sideRPs=VP_GetSide({side=sideName}).rps
	for k,v in ipairs(sideRPs) do
		ScenEdit_DeleteReferencePoint({side=sideName,guid=v.guid})
	end
end

function ReturnGroupMembers(groupGUID)
    local group = ScenEdit_GetUnit({guid=groupGUID})
    local result = {}
    local unitList = VP_GetSide({side=group.side}).units
    for k,v in ipairs (unitList) do
        local unit = ScenEdit_GetUnit({guid=v.guid})
        if unit.group ~= nil then
            if unit.group.guid == group.guid then
                table.insert(result, unit)
            end
        end
    end
    return result
end

function ReturnGroupLead(groupTable)
	local result = nil
	for k,v in ipairs (groupTable) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.group ~= nil and unit.formation ~= nil then
			if unit.formation.bearing == 0 and unit.formation.distance == 0 then
				result = unit
			end
		end
	end
	return result
end

function EvenNumber(num)
	local result = false
	if num % 2 == 0 then result = true end
	return result
end


function SetFormationChevron(groupGUID,orientation,spacingNm)
	local group = ScenEdit_GetUnit({guid=groupGUID})
	local groupTable = ReturnGroupMembers(groupGUID)
	local groupLead = ReturnGroupLead(groupTable)
	local distanceCounter1, distanceCounter2, orientation1, orientation2 = 0, 0, (orientation - 45)%360, (orientation + 45)%360
	for k,v in ipairs (groupTable) do
		if v.guid ~= groupLead.guid and v.type ~= 'Group' then
			if EvenNumber(k) then
				distanceCounter1 = distanceCounter1 + 1
				ScenEdit_SetUnit({guid=v.guid,formation={
					bearing=orientation1,
					distance = spacingNm * distanceCounter1}})
			else
				distanceCounter1 = distanceCounter2 + 1
				ScenEdit_SetUnit({guid=v.guid,formation={
					bearing=orientation2,
					distance = spacingNm * distanceCounter2}})
			end
		end
	end
end

function SetPositionChevron(groupGUID,orientation,spacingNm)
	local group = ScenEdit_GetUnit({guid=groupGUID})
	local groupTable = ReturnGroupMembers(groupGUID)
	local groupLead = ReturnGroupLead(groupTable)
	local distanceCounter1, distanceCounter2, orientation1, orientation2 = 0, 0, (orientation - 135)%360, (orientation + 135)%360
	for k,v in ipairs (groupTable) do
		if v.guid ~= groupLead.guid and v.type ~= 'Group' then
			if EvenNumber(k) then
				distanceCounter1 = distanceCounter1 + 1
				print ('Side 1, Counter '..distanceCounter1)
				local position = World_GetPointFromBearing({latitude=groupLead.latitude,longitude=groupLead.longitude,bearing=orientation1,distance=spacingNm * distanceCounter1})
				ScenEdit_SetUnit({guid=v.guid,latitude=position.latitude,longitude=position.longitude})
			else
				distanceCounter2 = distanceCounter2 + 1
				print ('Side 2, Counter '..distanceCounter2)
				local position = World_GetPointFromBearing({latitude=groupLead.latitude,longitude=groupLead.longitude,bearing=orientation2,distance=spacingNm * distanceCounter2})
				ScenEdit_SetUnit({guid=v.guid,latitude=position.latitude,longitude=position.longitude})
			end
        else
        	ScenEdit_SetUnit({guid=v.guid, position=groupLead.latitude, longitude=groupLead.longitude})
		end
	end
end

function SetFormationChevron(groupGUID,orientation,spacingNm)
	local group = ScenEdit_GetUnit({guid=groupGUID})
	local groupTable = ReturnGroupMembers(groupGUID)
	local groupLead = ReturnGroupLead(groupTable)
	local distanceCounter1, distanceCounter2, orientation1, orientation2 = 0, 0, (orientation - 45)%360, (orientation + 45)%360
	for k,v in ipairs (groupTable) do
		if v.guid ~= groupLead.guid and v.type ~= 'Group' then
			if EvenNumber(k) then
				distanceCounter1 = distanceCounter1 + 1
				ScenEdit_SetUnit({guid=v.guid,formation={
					bearing=orientation1,
					distance = spacingNm * distanceCounter1}})
			else
				distanceCounter1 = distanceCounter2 + 1
				ScenEdit_SetUnit({guid=v.guid,formation={
					bearing=orientation2,
					distance = spacingNm * distanceCounter2}})
			end
		end
	end
end