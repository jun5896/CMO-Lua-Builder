local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {

        {type='Facility', dbid=120, points=-100, name='building', destroyedString='destroyed, breaching RoE.'},--Building (Control Tower)
        {type='Facility', dbid=151, points=-100, name='military building', destroyedString='destroyed, breaching RoE.'},--Ammo Bunker (Underground)
        {type='Facility', dbid=170, points=-50, name='radar', destroyedString='destroyed, breaching RoE.'},--Radar (Bar Lock A [P-37])
        {type='Facility', dbid=207, points=-100, name='building', destroyedString='destroyed, breaching RoE.'},--A/C Revetment (1x Very Large Aircraft)
        {type='Facility', dbid=256, points=-100, name='building', destroyedString='destroyed, breaching RoE.'},--A/C Revetment (1x Large Aircraft)
        {type='Facility', dbid=389, points=-100, name='military building', destroyedString='destroyed, breaching RoE.'},--Building (Barracks)
        {type='Facility', dbid=432, points=-100, name='building', destroyedString='destroyed, breaching RoE.'},--A/C Hangar (2x Large Aircraft)
        {type='Facility', dbid=45, points=-100, name='building', destroyedString='destroyed, breaching RoE.'},--AvGas (150k Liter Tank)

        {type='Aircraft', dbid=2438, points=10, name='aircraft', destroyedString='shot down.'},--MiG-21F-13 Fishbed C
        {type='Aircraft', dbid=2991, points=10, name='aircraft', destroyedString='shot down.'},--MiG-17PF Fresco D
        {type='Facility', dbid=1533, points=50, name='SAM site', destroyedString='destroyed.'},--SAM Bn (SA-2b Guideline [S-75 Dvina])
        {type='Facility', dbid=1536, points=10, name='armoured recon platoon', destroyedString='destroyed.'},--Armored Recon Plt  (FV 701C Ferret Mk.1/2)
        {type='Facility', dbid=1540, points=10, name='mechanised infantry platoon', destroyedString='destroyed.'},--Mech Inf Plt (BTR-152 APC)
        {type='Facility', dbid=1542, points=25, name='armoured platoon', destroyedString='destroyed.'},--Armored Plt (T-34/85 MBT)
        {type='Facility', dbid=1549, points=50, name='AAA battery', destroyedString='destroyed.'},--AAA Bty (23mm ZSU-23-4 Shilka x 2)
        {type='Facility', dbid=260, points=5, name='truck convoy', destroyedString='destroyed.'},--Vehicles (Truck x 4)
        {type='Ship', dbid=1706, points=25, name='ship', destroyedString='sunk.'},--RKA Osa II
        {type='Ship', dbid=1710, points=25, name='ship', destroyedString='sunk.'},--Project 206ER Mol
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Somalia_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		ChangeScore('United States',matchData.points,'A Somali '..matchData.name.. ' was '..matchData.destroyedString..'.')
	end
end