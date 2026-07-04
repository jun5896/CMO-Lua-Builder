local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Facility', dbid=100, points=100, name='Marker (City)', destroyedString='destroyed'},--Marker (City)
        {type='Facility', dbid=1093, points=100, name='shore battery', destroyedString='destroyed'},--Arty Bty (130mm/52 M-46 M1954 Towed Howitzer x 6)
        {type='Facility', dbid=1122, points=100, name='shore battery', destroyedString='destroyed'},--Arty Bty (85mm D-44 Howitzer x 6)
        {type='Facility', dbid=1143, points=100, name='shore battery', destroyedString='destroyed'},--Arty Bty (122mm M1938 Howitzer x 6)
        {type='Facility', dbid=120, points=100, name='control tower', destroyedString='destroyed'},--Building (Control Tower)
        {type='Facility', dbid=221, points=100, name='ammo bunker', destroyedString='destroyed'},--Ammo Bunker (Surface)
        {type='Facility', dbid=233, points=100, name='truck depot', destroyedString='destroyed'},--Vehicle (Truck Depot, 40x Vehicles)
        {type='Facility', dbid=247, points=100, name='aircraft revetment', destroyedString='destroyed'},--A/C Revetment (1x Medium Aircraft)
        {type='Facility', dbid=255, points=100, name='radar (Cross Slot)', destroyedString='destroyed'},--Radar (Cross Slot)
        {type='Facility', dbid=264, points=100, name='aircraft revetment', destroyedString='destroyed'},--A/C Camouflaged Revetment (1x Medium Aircraft)
        {type='Facility', dbid=309, points=100, name='runway', destroyedString='destroyed'},--Runway (2600m)
        {type='Facility', dbid=388, points=100, name='airport terminal', destroyedString='destroyed'},--Building (Airport Terminal)
        {type='Facility', dbid=406, points=100, name='ammo dump', destroyedString='destroyed'},--Ammo Shelter
        {type='Facility', dbid=415, points=100, name='underground fuel tank', destroyedString='destroyed'},--AvGas (150k Liter Underground Tank)
        {type='Facility', dbid=433, points=100, name='hangar', destroyedString='destroyed'},--A/C Hangar (2x Medium Aircraft)
        {type='Facility', dbid=440, points=100, name='hangar', destroyedString='destroyed'},--A/C Tarmac Space (2x Large Aircraft)
        {type='Facility', dbid=451, points=100, name='runway access point', destroyedString='destroyed'},--Runway Access Point (Very Large Aircraft)
        {type='Facility', dbid=483, points=100, name='radar (Surface Search Radar)', destroyedString='destroyed'},--Radar (Generic Surface Search Radar)
        {type='Facility', dbid=630, points=100, name='SAM battalion (SA-2d Guideline)', destroyedString='destroyed'},--SAM Bn (SA-2d Guideline [S-75 Dvina])
        {type='Facility', dbid=72, points=100, name='radar (Knife Rest B [P-10])', destroyedString='destroyed'},--Radar (Knife Rest B [P-10])
        {type='Facility', dbid=92, points=100, name='fuel tank farm', destroyedString='destroyed'},--AvGas Tank Farm (40 x 40k Liter Tank)

        {type='Ship', dbid=1110, points=100, name='patrol boat', destroyedString='sunk'},--MPK Shanghai
        {type='Ship', dbid=1616, points=100, name='patrol boat', destroyedString='sunk'},--TK P-6 [Pr.183]
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('NVA_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('United States',matchData.points,'A North Vietnamese '..matchData.name..' was '..matchData.destroyedString..'.')
    end
end