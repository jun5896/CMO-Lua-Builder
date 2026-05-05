local function unitIsAmphibiousVessel(guid)
	local unit = ScenEdit_GetUnit({guid=guid})
	local result = false
	if unit.type == 'Ship' and 
		(unit.dbid == 375 or --LST 1179 Newport -- United States (Navy), 1986-1994, 3x LCVP, 1x LCP
			unit.dbid == 831 or --L 51 Galicia [Enforcer] -- Spain (Navy), 1998
			unit.dbid == 2084 or --LCM-6 -- Italy (Navy)
			unit.dbid == 2147 or --LCM-1E -- Spain (Navy), 2002, 2x + 12x
			unit.dbid == 2148) then --LCM-8 -- Spain (Navy)
				result = true
	end
	return result		
end

local theUnit = ScenEdit_UnitX()

if unitIsAmphibiousVessel(theUnit.guid) then
	ScenEdit_SetKeyValue('granCanariaLandingIsComplete','true')
	ChangeScore('Spain',1500,'Amphibious forces have arrived at Gran Canaria')
	local theMessage = ACP126('xcga','HQBRIMAR','z','HQ brigade de infanteria de marina','comandante grupo alfa','secreto','Amphibious forces have arrived at Gran Canaria.')
	ScenEdit_SpecialMessage('playerside',theMessage)
	ScenEdit_SetEvent('Spain_GranCanariaLanding',{isactive=false})
end