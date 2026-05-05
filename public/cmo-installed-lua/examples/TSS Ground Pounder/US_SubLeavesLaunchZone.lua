local unit = ScenEdit_UnitX()

if unit.guid == '3M12KI-0HNEQME91196B' then
	AshevilleOnStation(false)
	ScenEdit_SetEvent('US_AshArrivesAtLaunchZone', {isactive=true})
end

if unit.guid == '3M12KI-0HNEQME9119HT' then
	MiamiOnStation(false)'
	ScenEdit_SetEvent('US_MiaArrivesAtLaunchZone', {isactive=true})
end