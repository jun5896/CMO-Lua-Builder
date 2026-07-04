local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=2735, points=100, name='UH-1B Huey', destroyedString='shot down'},--UH-1B Huey
        {type='Aircraft', dbid=3007, points=100, name='OV-10A Bronco', destroyedString='shot down'},--OV-10A Bronco
        {type='Aircraft', dbid=586, points=100, name='P-2F (P2V-6F) Neptune', destroyedString='shot down'},--P-2F (P2V-6F) Neptune

        {type='Ship', dbid=1188, points=250, name='WPG 39 Owasco', destroyedString='sunk'},--WPG 39 Owasco
        {type='Ship', dbid=1321, points=50, name='Civilian Junk [35m, Armed]', destroyedString='sunk'},--Civilian Junk [35m, Armed]
        {type='Ship', dbid=1604, points=150, name='US Mk2 Swift', destroyedString='sunk'},--US Mk2 Swift
        {type='Ship', dbid=327, points=250, name='WPB 82301 Point Caution [Point Class]', destroyedString='sunk'},--WPB 82301 Point Caution [Point Class]
        {type='Ship', dbid=643, points=200, name='MSO 442 Aggressive', destroyedString='sunk'},--MSO 442 Aggressive
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('MACV_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('MACV',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
    end
end