local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
	local targetList = {
        {type='Facility', dbid=114, points=50, name='building (Radio/TV Station)', destroyedString='destroyed.'},--Building (Radio/TV Station)
        {type='Facility', dbid=1417, points=50, name='AAA bty (57mm M1950 x 4)', destroyedString='destroyed.'},--AAA Bty (57mm M1950 x 4)
        {type='Facility', dbid=1452, points=50, name='armored plt (M4A3E8 Sherman MBT)', destroyedString='destroyed.'},--Armored Plt (M4A3E8 Sherman MBT)
        {type='Facility', dbid=196, points=50, name='bunker (Comm Center)', destroyedString='destroyed.'},--Bunker (Comm Center)
        {type='Facility', dbid=208, points=50, name='building', destroyedString='destroyed.'},--Building (Tall Building)
        {type='Facility', dbid=312, points=500, name='target structure (Industrial Plant)', destroyedString='destroyed.'},--Structure (Industrial Plant)
        {type='Facility', dbid=316, points=500, name='target structure (Railway Yard)', destroyedString='destroyed.'},--Structure (Railway Yard)
        {type='Facility', dbid=389, points=50, name='building (Barracks)', destroyedString='destroyed.'},--Building (Barracks)
        {type='Facility', dbid=483, points=200, name='target radar (Generic Surface Search Radar)', destroyedString='destroyed.'},--Radar (Generic Surface Search Radar)
        {type='Facility', dbid=61, points=200, name='target radar (Spoon Rest A [P-12])', destroyedString='destroyed.'},--Radar (Spoon Rest A [P-12])
        {type='Facility', dbid=7, points=0, name='map marker (Town)', destroyedString='destroyed.'},--Marker (Town)
        
        {type='Ship', dbid=1274, points=400, name='frigate', destroyedString='sunk.'},--F 140 Talwar
        {type='Ship', dbid=1277, points=300, name='frigate', destroyedString='sunk.'},--F 110 Cauvery
        {type='Ship', dbid=1280, points=800, name='cruiser', destroyedString='sunk.'},--INS Delhi
        {type='Ship', dbid=962, points=400, name='destroyer', destroyedString='sunk.'},--D 141 Ranjit
        {type='Ship', dbid=966, points=300, name='frigate', destroyedString='sunk.'},--F 46 Kistna
        {type='Ship', dbid=974, points=400, name='frigate', destroyedString='sunk.'},--F 143 Trishul
        {type='Ship', dbid=980, points=50, name='minesweeper', destroyedString='sunk.'},--M 2707 Arlingham
        {type='Ship', dbid=981, points=50, name='minesweeper', destroyedString='sunk.'},--M 1191 Conniston Class (Sweeper)
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('India_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        local newScore = ChangeScore('Pakistan',matchData.points,'An Indian '..matchData.name..' was '..matchData.destroyedString)
        if newScore >= 2000 then
            ChangeScore('Pakistan',0,'Massive damage was inflicted on enemy forces. Well done!')
            ScenEdit_EndScenario()
        end
	end
end