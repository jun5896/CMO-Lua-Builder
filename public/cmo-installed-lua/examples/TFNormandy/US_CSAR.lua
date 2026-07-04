local function GetSurvivor()
	local unitList, survivorUnitDBID, result = VP_GetSide({side='United States'}).units, 2441, nil
	for k,v in ipairs (unitList) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.dbid == survivorUnitDBID then
			result = unit
		end
	end
	return result
end

local survivor = GetSurvivor()

if survivor == nil then
	BugMessage('US_CSAR','Unable to find a survivor!')
	ScenEdit_SetEvent('US_CSAR',{isactive=false})
else
	local rescueHeloDBIDs = {
		247,
		512,
		260
	}

	local function UnitIsARescueHelo(dbid)
		local result = false
		for k,v in ipairs (rescueHeloDBIDs) do
			if v == dbid then result = true end
		end
		return result
	end

	local function ReturnListOfRescueHelos()
		local unitList, result = VP_GetSide({side='United States'}).units, {}
		for k,v in ipairs (unitList) do
			local unit = ScenEdit_GetUnit({guid=v.guid})
			if UnitIsARescueHelo(unit.dbid) then
				table.insert( result, unit)
			end
		end
		return result
	end

	local function ReturnAltitudeAGL(guid)
		local result, unit = nil, ScenEdit_GetUnit({guid=guid})
		local terrainAltitude = World_GetElevation({
			latitude=unit.latitude,
			longitude=unit.longitude
		})
		result = unit.altitude - terrainAltitude
		return result
	end

	local function HeloIsReadyToRescue(guid)
		local result, unit = false, ScenEdit_GetUnit({guid=guid})
		local altitudeAGL = ReturnAltitudeAGL(unit.guid)
		local rangeFromSurvivor = Tool_Range(survivor.guid,unit.guid)
		if unit.speed < 50 and altitudeAGL < 750 and rangeFromSurvivor < 1 then
			result = true
		elseif rangeFromSurvivor < 1 then
			RadioMessageToPlayer('Eagle 6 this is '..unit.name.."; we've got the package in sight but will need to drop altitude and hover over them to effect a rescue.")
		end
		return result
	end

	local function PerformRescue(guid)
		local unit = ScenEdit_GetUnit({guid=guid})
		ScenEdit_DeleteUnit({guid=survivor.guid})
		ChangeScore(survivor.side,100,survivor.name..' was rescued.')
		RadioMessageToPlayer(
			'Eagle 6 this is '..unit.name..'; we have the package, out. </P>'..
			"<P> Eagle 6 this is Blast 4 Actual; we're returning to loiter. Good to see your boys are going home, out."
		)
		ScenEdit_AssignUnitToMission('Blast 1', 'Blast Loiter')
        ScenEdit_AssignUnitToMission('Blast 2', 'Blast Loiter')
		ScenEdit_SetEvent('US_CSAR',{isactive=false})
	end

	local rescueHeloList = ReturnListOfRescueHelos()

	if rescueHeloList ~= nil then
		for k,v in ipairs (rescueHeloList) do
			if HeloIsReadyToRescue(v.guid) then
				PerformRescue(v.guid)
				--Return F-15s to loiter
				for i = 1,4 do
					local strikeEagle = ScenEdit_GetUnit({side='USAF',name='Blast 4-'..i})
					if strikeEagle ~= nil then
						ScenEdit_AssignUnitToMission(x.name, 'Blast Loiter')
					end
				end
				break
			end
		end
	end
end