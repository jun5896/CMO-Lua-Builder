local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
		{dbid=1136, name='Rapier SAM section', type='Facility', points=200, descriptor='destroyed'}, --SAM Plt/2 (Rapier FSA Blindfire)
		{dbid=1153, name='Frigate', type='Ship', points=250, descriptor='sunk'}, --F 71 Alvand [Saam, Vosper Mk5]
		{dbid=1153, name='F-5E Tiger II', type='Aircraft', points=75, descriptor='shot down'}, --F-5E Tiger II
		{dbid=1308, name='F-4E Phantom II', type='Aircraft', points=100, descriptor='shot down'}, --F-4E Phantom II
		{dbid=149, name='Oil Refinery', type='Facility', points=1000, descriptor='destroyed'}, --Structure (Oil Refinery)
		{dbid=210, name='Fuel Transfer Pier', type='Facility', points=1000, descriptor='destroyed'}, --Structure (Naval Dock)
		{dbid=229, name='F-4D Phantom II', type='Aircraft', points=100, descriptor='shot down'}, --F-4D Phantom II
		{dbid=586, name='Radar (AN/TPS-43)', type='Facility', points=50, descriptor='destroyed'}, --Radar (AN/TPS-43)
		{dbid=658, name='I-Hawk battery', type='Facility', points=200, descriptor='destroyed'}, --SAM Bty (I-HAWK [Baseline])
		{dbid=76, name='750k Litre Oil Tank', type='Facility', points=850, descriptor='destroyed'}, --Diesel (750k Liter Tank)
		{dbid=901, name='SA-6q battalion', type='Facility', points=200, descriptor='destroyed'}, --SAM Bn (SA-6a Gainful [2K12E Kvadrat])
		{dbid=911, name='AAA platoon', type='Facility', points=50, descriptor='destroyed'}, --AAA Plt/3 (23mm ZU-23-2 x 2)
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Iran_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theUnit.name..', dbid '..theUnit.dbid)
		end
	else
		ChangeScore('Iraq',matchData.points,'An Iranian '..matchData.name.. ' was '..matchData.descriptor..'.')
	end
end