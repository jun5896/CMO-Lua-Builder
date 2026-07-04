local unitList = VP_GetSide({side='Civilian'}).units
local numberOfCivilianUnits = #unitList
local numberOfUnitsDeleted = 0
for k,v in ipairs (unitList) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	if (unit.course[1] == nil or unit.speed == 0) and 
		unit.type == 'Ship' then
        ScenEdit_DeleteUnit({guid=v.guid})
		numberOfUnitsDeleted = numberOfUnitsDeleted + 1
	end
end

if DebugModeIsOn() then
	ScenEdit_SpecialMessage('playerside','Civ_Cleanup fired. <BR>Initial civilian Units: '..numberOfCivilianUnits..' <BR>Civilian units cleaned up: '..numberOfUnitsDeleted)
end