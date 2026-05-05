local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1037, points=50, name='aircraft', destroyedString='destroyed'},--RB-57F Canberra
        {type='Facility', dbid=100, points=0, name='city', destroyedString='destroyed... how did you manage that?!'},--Marker (City)
        {type='Facility', dbid=1150, points=50, name='AAA battery', destroyedString='destroyed'},--AAA Bty (M42A1 Duster x 4)
        {type='Facility', dbid=1423, points=50, name='AAA battery', destroyedString='destroyed'},--AAA Bty (57mm M1950 x 4)
        {type='Facility', dbid=41, points=500, name='diesel storage tank', destroyedString='destroyed'},--Diesel (400k Liter Tank)
        {type='Ship', dbid=1401, points=100, name='destroyer', destroyedString='destroyed'},--D 163 Khaibar
        {type='Ship', dbid=650, points=200, name='troop carrier', destroyedString='sunk'},--Commercial Dry-Bulk Carrier - Small Handysize [25,000t DWT]
        {type='Ship', dbid=971, points=100, name='destroyer', destroyedString='sunk'},--D 164 Shah Jahan
        {type='Ship', dbid=994, points=50, name='minehunter', destroyedString='sunk'},--M 160 Adjutant
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('Pakistan_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('India',matchData.points,'An enemy '..matchData.name..' was '..matchData.destroyedString..'.')
    end
end