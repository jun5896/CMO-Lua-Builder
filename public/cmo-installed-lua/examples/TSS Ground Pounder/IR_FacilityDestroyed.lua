local TheDestroyedUnit = ScenEdit_UnitX()

local SecondaryTargets = {
	{name='[Target] Operations Building', guid='3M12KI-0HNF12O1107OO'},
	{name='[Target] A/C Hangar (2x Large Aircraft)', guid='3M12KI-0HNERC1MAENJ5'},
	{name='[Target] Warehouse', guid='3M12KI-0HNF12O110721'},
	{name='[Target] AvGas (75k Liter Tank)', guid='3M12KI-0HNEQME9115JH'},
	{name='[Target] AvGas (75k Liter Tank)', guid='3M12KI-0HNEQME91144T'},
	{name='[Target] AvGas (75k Liter Tank)', guid='3M12KI-0HNEQME9113AS'},
	{name='[Target] AvGas (75k Liter Tank)', guid='3M12KI-0HNEQME91144O'},
	{name='[Target] AvGas (75k Liter Tank)', guid='3M12KI-0HNEQME9112QI'},
	{name='[Target] AvGas (75k Liter Tank)', guid='3M12KI-0HNEQME91156I'}
}

local isSecondaryTarget = false

for _, unit in ipairs(SecondaryTargets) do
	if TheDestroyedUnit.guid == unit.guid then
		isSecondaryTarget = true
		ChangeScore('USN', 10, unit.name.. 'secondary objective destroyed.')
		break
	end
end

if not isSecondaryTarget then
	ChangeScore('USN', 5, TheDestroyedUnit.name .. ' destroyed.')
end