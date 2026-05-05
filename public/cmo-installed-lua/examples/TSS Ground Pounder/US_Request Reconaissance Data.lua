local AshevilleCheck = ScenEdit_GetUnit({guid='3M12KI-0HNEQME91196B'})
if AshevilleCheck == nil then -- Mark submarine on station if it has been destroyed, allows mission to continue
	AshevilleOnStation(true)
end

local MiamiCheck = ScenEdit_GetUnit({guid='3M12KI-0HNEQME9119HT'})
if MiamiCheck == nil then -- Mark submarine on station if it has been destroyed, allows mission to continue
	MiamiOnStation(true)
end

if AshevilleOnStation() and MiamiOnStation() then
	local sideUnits = VP_GetSide({side='Iran'}).units

	for _, unit in ipairs(sideUnits) do
		local unitData = ScenEdit_GetUnit({guid=unit.guid})
	
		if unitData.type == 'Facility' and unitData:inArea({'RP-274', 'RP-275', 'RP-276', 'RP-277'}) then
			ScenEdit_SetUnit({guid=unit.guid, autodetectable=true})
		end
	end

	ScenEdit_SetSidePosture('USA 10th SFG', 'USN', 'F') 

	ScenEdit_MsgBox('Reconaissance data received.', 6)
	ScenEdit_SetSpecialAction({actionnameorid='Request Reconaissance Data', isactive=false})

	ScenEdit_SetEvent('US_AshLeavesLaunchZone', {isactive=false})
	ScenEdit_SetEvent('US_MiaLeavesLaunchZone', {isactive=false})
else
	ChangeScore('playerside', -50, 'At least one subamrine is not within its launch zone.')
	ScenEdit_MsgBox('Reconaissance data not received. At least one submarine is not within its launch zone.',6)
end