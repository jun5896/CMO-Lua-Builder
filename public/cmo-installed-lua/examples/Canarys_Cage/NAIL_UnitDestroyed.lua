local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local unitListNAIL = {
		{type= 'Aircraft', dbid= 1208, description='Mirage F.1ED', points= 50}, --Mirage F.1ED -- Libya (Air Force), 1980
		{type= 'Aircraft', dbid= 1209, description='Mirage F.1CH', points= 50}, --Mirage F.1CH -- Morocco (Air Force), 1979
		{type= 'Aircraft', dbid= 1211, description='Mirage F.1CH-200', points= 50}, --Mirage F.1CH-200 -- Morocco (Air Force), 1981
		{type= 'Aircraft', dbid= 1232, description='E-2C Hawkeye Group II', points= 50}, --E-2C Hawkeye Group II -- Egypt (Air Force), 2003, 5x
		{type= 'Aircraft', dbid= 131, description='Su-22M-3K Fitter J', points= 50}, --Su-22M-3K Fitter J -- Libya (Air Force), 1982
		{type= 'Aircraft', dbid= 132, description='Su-24MK Fencer D', points= 50}, --Su-24MK Fencer D -- Libya (Air Force), 1990, 20x + 1x
		{type= 'Aircraft', dbid= 1323, description='Su-24MK Fencer D', points= 50}, --Su-24MK Fencer D -- Algeria (Air Force), 1997
		{type= 'Aircraft', dbid= 1506, description='F-4E Phantom II', points= 50}, --F-4E Phantom II -- Egypt (Air Force), 1981, 36x
		{type= 'Aircraft', dbid= 1658, description='MiG-29 Fulcrum C', points= 50}, --MiG-29 Fulcrum C -- Algeria (Air Force), 1999, 9-13
		{type= 'Aircraft', dbid= 2235, description='MiG-25P Foxbat A', points= 50}, --MiG-25P Foxbat A -- Libya (Air Force), 1986, 30x
		{type= 'Aircraft', dbid= 3150, description='AS.565MA Panther', points= 50}, --AS.565MA Panther -- Morocco (Navy), 2002, 3x, Floreal, Ex-SA.365M Dauphin 2
		{type= 'Aircraft', dbid= 454, description='F-16CG Blk 42 Falcon', points= 50}, --F-16CG Blk 42 Falcon [Peace Vector II Upgr] -- Egypt (Air Force), 2002, Blk 32 Upgr
		{type= 'Aircraft', dbid= 550, description='SH-2G(E) Seasprite', points= 50}, --SH-2G(E) Seasprite -- Egypt (Navy), 1998, 12x
		{type= 'Aircraft', dbid= 980, description='Sea King Mk47 [HAS.1]', points= 50}, --Sea King Mk47 [HAS.1] -- Egypt (Navy), 1977
		
		{type= 'Facility', dbid= 1036, description='Radar (AN/TPS-63)', points= 100}, --Radar (AN/TPS-63) -- Morocco (Air Force), 1984, 8x
		{type= 'Facility', dbid= 1292, description='AvGas (3000k Liter Underground Tank)', points= 100}, --AvGas (3000k Liter Underground Tank) -- Generic (Generic)
		{type= 'Facility', dbid= 1315, description='SAM Bn (SA-3b Goa [S-125M Pechora])', points= 100}, --SAM Bn (SA-3b Goa [S-125M Pechora]) -- Algeria (Air Force)
		{type= 'Facility', dbid= 1422, description='Runway-Grade Taxiway', points= 100}, --Runway-Grade Taxiway (3200m) -- Generic (Generic), 2601-3200m, 10k feet, Very Large Aircraft
		{type= 'Facility', dbid= 1423, description='Runway-Grade Taxiway', points= 100}, --Runway-Grade Taxiway (2600m) -- Generic (Generic), 2001-2600m, 8k feet, Very Large Aircraft
		{type= 'Facility', dbid= 1426, description='Ammo Shelter', points= 100}, --Ammo Shelter -- Generic (Generic)
		{type= 'Facility', dbid= 1496, description='Ammo Pad', points= 100}, --Ammo Pad -- Generic (Generic)
		{type= 'Facility', dbid= 1508, description='AvGas Tank Farm', points= 100}, --AvGas Tank Farm (40 x 40k Liter Tank) -- Generic (Generic)
		{type= 'Facility', dbid= 1509, description='AvGas Tank Farm', points= 100}, --AvGas Tank Farm (10 x 75k Liter Tank) -- Generic (Generic)
		{type= 'Facility', dbid= 190, description='A/C Tarmac Space', points= 100}, --A/C Tarmac Space (4x Medium Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 1955, description='Infantry Company', points= 100}, --Inf Coy -- Generic (Generic), APP 6 Placeholder
		{type= 'Facility', dbid= 217, description='Tarmac Space', points= 100}, --A/C Tarmac Space (2x Large Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 2236, description='MANPADS Team', points= 100}, --SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3) -- Morocco (Army)
		{type= 'Facility', dbid= 27, description='Hardened Aircraft Shelter', points= 125}, --A/C Hardened Aircraft Shelter (1x Large Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 281, description='Tarmac Space', points= 100}, --A/C Tarmac Space (2x Medium Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 2911, description='AAA Battery', points= 100}, --AAA Bty (57mm ZSU-57-2 x 4) -- Algeria (Army), 1976, 36x, Second-Hand
		{type= 'Facility', dbid= 3, description='Control Tower (Building)', points= 100}, --Building (Control Tower) -- Generic (Generic)
		{type= 'Facility', dbid= 301, description='SSM Platoon', points= 100}, --SSM Plt (SSC-3 Styx [4K51 Rubezh]) -- Algeria (Navy), 1988, 2x + Square Tie pr Bty, 4x Bty
		{type= 'Facility', dbid= 344, description='Tarmac Space', points= 100}, --A/C Tarmac Space (2x Very Large Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 35, description='Runway', points= 100}, --Runway (3200m) -- Generic (Generic), 2601-3200m, 10k feet, Very Large Aircraft
		{type= 'Facility', dbid= 353, description='Runway', points= 100}, --Runway Access Point (Very Large Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 4, description='Hardened Aircraft Shelter', points= 125}, --A/C Hardened Aircraft Shelter (1x Medium Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 41, description='Hangar', points= 100}, --A/C Hangar (2x Large Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 427, description='Passenger Terminal (Building)', points= 100}, --Building (Airport Terminal) -- Generic (Generic)
		{type= 'Facility', dbid= 68, description='Hangar', points= 100}, --A/C Hangar (2x Medium Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 86, description='Hangar', points= 100}, --A/C Hangar (2x Small Aircraft) -- Generic (Generic)
		{type= 'Facility', dbid= 93, description='SAM Bty (I-HAWK [P1])', points= 100}, --SAM Bty (I-HAWK [P1]) -- United States (Army), 1981, 4x Bty pr Bn, 18x Bn
		
		{type= 'Ship', dbid= 1094, description='Frigate', points= 200}, --F 946 Abu Qir [Descubierta] -- Egypt (Navy), 1996
		{type= 'Ship', dbid= 1097, description='Destroyer', points= 200}, --F 951 Najim Al Zafir [Jianghu Type 053H(E)] -- Egypt (Navy), 1999
		{type= 'Ship', dbid= 1100, description='Missile Boat', points= 200}, --416 Ziyad [Pr.1234E Nanuchka II] -- Libya (Navy), 1981
		{type= 'Ship', dbid= 1261, description='Landing Ship', points= 200}, --L 9030 Champlain [BATRAL Class] -- France (Navy), 1975-2003
		{type= 'Ship', dbid= 1410, description='Corvette', points= 200}, --901 Mourad Rais [Pr.1159 Koni] -- Algeria (Navy), 2000
		{type= 'Ship', dbid= 1993, description='Missile Boat', points= 200}, --670 Ramadan -- Egypt (Navy), 2005
		{type= 'Ship', dbid= 375, description='Landing Ship', points= 200}, --LST 1179 Newport -- United States (Navy), 1986-1994, 3x LCVP, 1x LCP
		{type= 'Ship', dbid= 462, description='Guided Missile Frigate', points= 200}, --F 911 Mubarak [Perry] -- Egypt (Navy), 1999
		
		{type= 'Submarine', dbid= 148, description='Kilo Class submarine', points= 200}, --012 Rais Hadj Mubarek [PL-877EKM Kilo] -- Algeria (Navy), 1988
		{type= 'Submarine', dbid= 245, description='Romeo Class submarine', points= 200}, --S 849 Romeo -- Egypt (Navy), 1995
		{type= 'Submarine', dbid= 256, description='Foxtrot Class submarine', points= 200}, --S 311 Al Badr [PL-641 Foxtrot] -- Libya (Navy), 1977
	}

	local matchData = nil

	for k,v in ipairs (unitListNAIL) do
		if theDestroyedUnit.type == v.type 
			and theDestroyedUnit.dbid == v.dbid then
				matchData = v
		end
	end

	if matchData == nil then
		BugMessage('NAIL_UnitDestroyed','Unable to match data for '..theDestroyedUnit.name..'; dbid '..theDestroyedUnit.dbid)
	else
		local descriptor
		if theDestroyedUnit.type == 'Submarine' or theDestroyedUnit.type == 'Ship' then
			descriptor = 'sunk.'
		else
			descriptor = 'destroyed.'
		end
		ChangeScore('Spain',matchData.points,'A NAIL '..matchData.description..' was '..descriptor)
	end

	local tenerifeUnits = {
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='03004fca-9af0-4acc-a459-faff6a549e0c'},
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='13423177-13fc-4c31-9a04-abd247891c2d'},
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='4363ae19-823a-4009-8ef3-b5380a866816'},
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='457f97e8-a7f8-440e-96f0-14a819a028ae'},
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='488cdb21-7cfb-4795-b0ab-2a92104d7806'},
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='72e5c574-7cf2-4ba5-a43a-8ca6b3f33568'},
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='88ebddff-2bc3-4782-98ed-81cff5d9683f'},
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='a169ee11-66fb-4b58-a2d9-47e22794e9e6'},
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='d3dff44c-9d75-4943-85e7-05ddbe3fb722'},
		{name='Inf Coy', guid='0588ed9f-3c52-45d9-828e-8434522f12e3'},
		{name='Inf Coy', guid='16ee1b78-a37d-41f0-bec4-ce8afcf29530'},
		{name='Inf Coy', guid='65c5a4f3-708b-4bf4-92ac-a58a8258364e'},
		{name='Inf Coy', guid='696ba777-3757-4a7f-b5bf-174ac0f39d33'},
		{name='Inf Coy', guid='7bde8fac-756e-4720-8c00-283017f66298'},
		{name='Inf Coy', guid='ae73eec5-4554-4acc-a959-3ac68dd23f89'},
		{name='Inf Coy', guid='fda15c7c-994c-45b8-abf6-eb0b60649da4'},
		{name='Radar (AN/TPS-63)', guid='ca5771a9-0ae5-4652-bbec-bbf12245d055'},
		{name='SAM Bn 2', guid='6c695f38-ccea-488f-b53c-d48f6e78b767'},
		{name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', guid='038eee06-0137-4641-9408-444f8c7247f3'},
		{name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', guid='0dc41e84-dcfe-4527-9a67-e5c61dd169fc'},
		{name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', guid='15583efd-edcf-4169-b7e6-3dec02abf62f'},
		{name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', guid='2198d9ce-147b-4931-a01d-870c278f28e0'},
		{name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', guid='ebe0f1a6-e876-4df5-966f-7eee989c8df4'},
		{name='SSM Plt 3', guid='db5e86c5-f37e-43d0-a57b-352f02d8cfe8'},
		{name='SSM Plts 1', guid='459fd228-28a8-49f7-91d0-c857bb1d4bd4'},
	}
		
	local granCanariaUnits = {
		{name='Radar (AN/TPS-63)', guid='3ff6a8f7-eb22-41cf-b3ac-0c96fcf0e030'} , 
		{name='SAM Bn (SA-3b Goa [S-125M Pechora])', guid='6d80d234-0ffc-4180-abdd-2903994dd27d'} , 
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='fbfaf1e7-17b1-43af-8f88-b0e5abcf0e2c'} , 
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='b5df7d92-e5ef-4615-a765-94d87b274872'} , 
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='f2a25547-e795-4b1f-934a-c155a84d2585'} , 
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='84c29392-a652-49ca-ab54-0e5a4e5cfbb3'} , 
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='da7b6776-bef1-4750-9a70-0aecc56248ac'} , 
		{name='AAA Bty (57mm ZSU-57-2 x 4)', guid='012b391f-bf0d-427c-85d3-2cd826d0371a'} , 
		{name='Inf Coy', guid='29db7d88-5767-414b-81a7-9617a518796f'} , 
		{name='Inf Coy', guid='03d32b01-6719-4bb1-9aa5-422b83e60203'} , 
		{name='Inf Coy', guid='99c06d18-570c-4040-bde0-b7d1ab9293bb'} , 
		{name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', guid='971d7786-5e96-463f-92aa-61a26e427ed4'} , 
		{name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', guid='a37c980f-4ea2-4fec-ab45-d41b2ccc1c94'} , 
		{name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', guid='3a9aa168-f097-45e1-9a3c-89273af3e0a5'} , 
		{name='SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)', guid='6c6cab46-e39e-4429-9042-a50cb928b93d'}
	}

	local tenerifeIsClear = ConvertStringToBoolean(ScenEdit_GetKeyValue('tenerifeIsClear'))
	local granCanariaIsClear = ConvertStringToBoolean(ScenEdit_GetKeyValue('granCanariaIsClear'))

	local function UnitDestructionThresholdMet(unitTable)
		local result, n, total = false, 0, #unitTable
		for k,v in ipairs (unitTable) do
			local unit = ScenEdit_GetUnit({guid=v.guid})
			if unit == nil then n = n + 1 end
		end
		local ratio = n / total
		if ratio > 0.75 then result = true end
		return result
	end

	if UnitDestructionThresholdMet(tenerifeUnits) and not tenerifeIsClear then 
		ChangeScore('Spain',1500,'NAIL forces on Tenerife reduced by 75%')
		ScenEdit_SetKeyValue('tenerifeIsClear','true')
	end

	if UnitDestructionThresholdMet(granCanariaUnits) and not granCanariaIsClear then 
		ChangeScore('Spain',1500,'NAIL forces on Gran Canaria reduced by 75%')
		ScenEdit_SetKeyValue('granCanariaIsClear','true')
	end
end