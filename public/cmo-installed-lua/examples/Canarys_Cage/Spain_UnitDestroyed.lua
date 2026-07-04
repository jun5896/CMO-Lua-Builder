local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
	
		{type= 'Aircraft', name= 'F/A-18A Hornet', dbid= 564, points= 75, descriptor='destroyed'}, --F/A-18A Hornet [EF-18A+, C.15A] -- Spain (Air Force), 2002; Example Notes
		{type= 'Aircraft', name= 'SH-3W Sea King AEW', dbid= 668, points= 100, descriptor='destroyed'}, --SH-3W Sea King AEW [HS.9] -- Spain (Navy), 1989-2015, 3x
		{type= 'Aircraft', name= 'SH-3H Sea King', dbid= 674, points= 50, descriptor='destroyed'}, --SH-3H Sea King [HS.9] -- Spain (Navy), 1996-2002
		{type= 'Aircraft', name= 'AV-8B Harrier II+', dbid= 836, points= 75, descriptor='destroyed'}, --AV-8B Harrier II+ [EAV-8B Night Attack, VA.1B Matador II] -- Spain (Navy), 2002
		{type= 'Aircraft', name= 'P-3B Orion', dbid= 1585, points= 100, descriptor='destroyed'}, --P-3B Orion -- Spain (Navy), 2003
		{type= 'Aircraft', name= 'Falcon 20C-ECM', dbid= 1836, points= 200, descriptor='destroyed'}, --Falcon 20C-ECM [TM.11] -- Spain (Air Force), 1980
		{type= 'Aircraft', name= 'AB.212 ASW', dbid= 1963, points= 50, descriptor='destroyed'}, --AB.212 ASW [HA.18] -- Spain (Navy), 1976, Agusta-Bell, Designated Z.18 prior to 1978
		{type= 'Aircraft', name= 'S-70B-1 Seahawk', dbid= 2004, points= 50, descriptor='destroyed'}, --S-70B-1 Seahawk [HS.23] -- Spain (Navy), 2003
		{type= 'Aircraft', name= 'AB.212 Colibri EW', dbid= 2014, points= 50, descriptor='destroyed'}, --AB.212 Colibri EW -- Spain (Navy), 1989, Agusta-Bell, 4x
		{type= 'Aircraft', name= 'KC-130H Hercules', dbid= 3118, points= 200, descriptor='destroyed'}, --KC-130H Hercules [TK.10] -- Spain (Air Force), 1976, 5x
		{type= 'Aircraft', name= 'Boeing 707-351C', dbid= 3154, points= 250, descriptor='destroyed'}, --Boeing 707-351C Santiago [TM.17, ELINT Mod] -- Spain (Air Force), 1998, 1x

		{name= 'L42 Pizarro', type= 'Ship', dbid= 375, points= 1000, descriptor='sunk'}, --LST 1179 Newport -- United States (Navy), 1986-1994, 3x LCVP, 1x LCP
		{name= 'R 11 Principe de Asturias', type= 'Ship', dbid= 476, points= 2000, descriptor='sunk'}, --R 11 Principe de Asturias -- Spain (Navy), 2002-2012
		{name= 'F 102 Almirante Borbon', type= 'Ship', dbid= 768, points= 500, descriptor='sunk'}, --F 101 Alvaro De Bazán -- Spain (Navy), 2003
		{name= 'L 51 Galicia ', type= 'Ship', dbid= 831, points= 1000, descriptor='sunk'}, --L 51 Galicia [Enforcer] -- Spain (Navy), 1998
		{name= 'F 32 Diana', type= 'Ship', dbid= 836, points= 500, descriptor='sunk'}, --F 31 Descubierta -- Spain (Navy), 2000-2009
		{name= 'F 84 Reina Sofia', type= 'Ship', dbid= 1400, points= 500, descriptor='sunk'}, --F 81 Santa Maria [Perry] -- Spain (Navy), 2003
		{name= 'F 74 Asturias', type= 'Ship', dbid= 1401, points= 500, descriptor='sunk'}, --F 71 Baleares -- Spain (Navy), 1992-2009
		{name= 'LCM-6 #741', type= 'Ship', dbid= 2084, points= 200, descriptor='sunk'}, --LCM-6 -- Italy (Navy)
		{name= 'LCM-1E #729', type= 'Ship', dbid= 2147, points= 200, descriptor='sunk'}, --LCM-1E -- Spain (Navy), 2002, 2x + 12x
		{name= 'LCM-8 #726', type= 'Ship', dbid= 2148, points= 200, descriptor='sunk'}, --LCM-8 -- Spain (Navy), 1976-2008
		
		{type= 'Submarine', name= 'S 63 Marsopa', dbid= 264, points= 500, descriptor='sunk'}, --S 61 Delfin [Daphne, S-60] -- Spain (Navy), 1995-2006
		{type= 'Submarine', name= 'S 74 Tramontana', dbid= 495, points= 500, descriptor='sunk'}, --S 71 Galerna [Agosta, S-70] -- Spain (Navy), 2006
		
		{type= 'Facility', name= 'SAM Plt/2 (NASAMS II)', dbid= 653, points=250, descriptor='destroyed'}, --SAM Plt/2 (NASAMS II) -- Spain (Air Force), 2005, 2x + 1x MSP-500 pr Plt, 2x pr Bty
		{type= 'Facility', name= 'Sensor (MSP-500 [NASAMS])', dbid= 1273, points=250, descriptor='destroyed'}, --Sensor (MSP-500 [NASAMS II]) -- Spain (Air Force), 2005
		{type= 'Facility', name= 'EVA 11', dbid= 1872, points=500, descriptor='destroyed'}, --Radar (S-763 Lanza 3D) -- Spain (Air Force), 2000, 11x

    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('Spain_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
		if theDestroyedUnit.type == 'Aircraft' then
			ChangeScore('Spain',matchData.points*-1,'A Spanish '..matchData.name.. ' was '..matchData.descriptor)
		else
			ChangeScore('Spain',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.descriptor)
		end
    end
	
	if theDestroyedUnit.dbid == 476 then
		local theMessage = ACP126('xcga','JEMAD','z','Jefe del Estado Mayor de la Defensa','comandante grupo alfa','ultra secreto','1. Acknowledge R 11 Principe de Asturias lost. <BR>2. You are relieved of command effective immediately. <BR>3. Return to Madrid at once for debriefing.')
		ScenEdit_SpecialMessage('playerside',theMessage)
		ChangeScore('Spain',-10000,theDestroyedUnit.name.. ' was lost; the mission is doomed.')
		ScenEdit_EndScenario()
	end
end
