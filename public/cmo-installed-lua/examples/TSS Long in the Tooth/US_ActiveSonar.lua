math.randomseed(os.time())
side = VP_GetSide({side='United States'})
for k,v in ipairs(side.units) do
	unit = ScenEdit_GetUnit({guid=v.guid})
	if unit then
		if unit.type == 'Ship' then
			chance = math.random(1,100)
			if chance >= 85 then
				ScenEdit_SetEMCON('Unit',unit.guid,'Sonar=Active')
			else
				ScenEdit_SetEMCON('Unit',unit.guid,'Sonar=Passive')
			end
		end
	end
end