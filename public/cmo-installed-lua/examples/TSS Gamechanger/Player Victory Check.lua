local capitalShips = {
	{name='BB-61 Iowa', guid='fa13486f-04d4-4679-8b41-cb1af37a8107'},
	{name='CAG-1 Boston', guid='f8416b68-9c99-4d56-9c05-91f8b2ddd32a'},
}

local shipsRemaining = 0
for k,v in ipairs (capitalShips) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	if unit ~= nil then
		shipsRemaining = shipsRemaining + 1
	end
end

if shipsRemaining == 0 then
	local submarineNameString = 'USS NAUTILUS (SSN 571)'

	local submarine = ScenEdit_GetUnit({guid='6d63f3a5-a7d7-41a2-8712-1324494f74c0'}) -- SSN 571 Nautilus
	if submarine == nil then
		submarineNameString = 'USS RAZORBACK (SS-398)'
	end

	TelexMessageToPlayer(
		'FLT OPS', -- Sending Station
		submarineNameString, -- Receiving Station
		'ROUTINE', -- Flash (Z), Immediate (O), Priority (P), Routine (R), Flash Override (Y)
		'UNCLASS', -- Unclass +/- SBU / FOUO / NOFORN (Restricted), Confidential, Secret, Top Secret
		nil, -- Time
		'Congratulations, you have sunk both the USS Iowa (BB-61) and USS Boston (CAG-1). Exercise is complete, return to base.', -- Body of the message
		nil -- Location of the message (optional)
	)

	ScenEdit_EndScenario()
end