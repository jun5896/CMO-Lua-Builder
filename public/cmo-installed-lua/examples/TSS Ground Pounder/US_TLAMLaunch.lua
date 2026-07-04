math.randomseed(os.time())

local tlam = ScenEdit_UnitX()

local range_asheville
if asheville == nil then 
	range_asheville = 9999 
else
	range_asheville = Tool_Range('3M12KI-0HNEQME91196B', tlam.guid)
end

local range_miami
if miami == nil then 
	range_miami = 9999 
else
	range_miami = Tool_Range('3M12KI-0HNEQME9119HT', tlam.guid)
end

local closestSubmarine
local submarineDetected = false
if range_asheville < range_miami then
	closestSubmarine = {name='SSN 758 Asheville', guid='3M12KI-0HNEQME91196B'}
	submarineDetected = AshevilleDetected()
else
	closestSubmarine = {name='SSN 755 Miami', guid='3M12KI-0HNEQME9119HT'}
	submarineDetected = MiamiDetected()
end

if submarineDetected == false then
	local IranUnitList = VP_GetSide({side='Iran'}).units
	local CivilianUnitList = VP_GetSide({side='Civilian'}).units

	for _,unit in ipairs(IranUnitList) do
		local unitInfo = ScenEdit_GetUnit({guid=unit.guid})
		local range = Tool_Range(unit.guid, closestSubmarine.guid) 
		if unitInfo.type == 'Ship' or unitInfo.type == 'Submarine' then
			if range < 25 then 
				IranDetectsSubmarine = true
			end
		elseif unitInfo.type == 'Aircraft' then 
			local alt1 = math.sqrt(unitInfo.altitude)
			local alt2 = math.sqrt(90) 
			local horizon_m = (alt1 + alt2) * 4124 
			local horizon_nm = horizon_m / 1852 
			if range < horizon_nm then
				IranDetectsSubmarine = true
			end
		end
	end

	for _,unit in ipairs(CivilianUnitList) do 
		local unitInfo = ScenEdit_GetUnit({guid=unit.guid})
		local range = Tool_Range(unitInfo.guid, tlam.guid) 
		if unitInfo.type == 'Ship' or unitInfo.type == 'Submarine' then 
			if range < 25 and math.random(1,100) <= 20 then 
				IranDetectsSubmarine = true
			end
		elseif unitInfo.type == 'Aircraft' then 
			local alt1 = math.sqrt(unitInfo.altitude)
			local alt2 = math.sqrt(90) 
			local horizon_m = (alt1 + alt2) * 4124 
			local horizon_nm = horizon_m / 1852 
			if range < horizon_nm and math.random(1,100) <= 20 then
				IranDetectsSubmarine = true
			end
		end
	end
end

if IranDetectsSubmarine == true then
	ScenEdit_SetSidePosture('Iran', 'USN', 'H')
	ScenEdit_SetEMCON('Side', 'Iran', 'Sonar=Active')
	ScenEdit_SetDoctrine({side="Iran"}, {weapon_control_status_subsurface=0})
	ScenEdit_SetUnit({guid=closestSubmarine.guid, autodetectable=true})
	if closestSubmarine.guid == '3M12KI-0HNEQME91196B' then
		AshevilleDetected(true)
	else
		MiamiDetected(true)
	end

	ScenEdit_SetEvent('US_SubsDetected', {isactive=true})
end