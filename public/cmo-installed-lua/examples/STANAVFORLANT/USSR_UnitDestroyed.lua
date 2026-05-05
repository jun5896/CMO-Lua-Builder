local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=148, points=50, name='Tu-16P Badger J', destroyedString='shot down'},--Tu-16P Badger J
        {type='Aircraft', dbid=185, points=50, name='Tu-16K-10-26P Badger C Mod', destroyedString='shot down'},--Tu-16K-10-26P Badger C Mod
        {type='Aircraft', dbid=186, points=50, name='Tu-16K-26PM Badger G Mod', destroyedString='shot down'},--Tu-16K-26PM Badger G Mod
        {type='Aircraft', dbid=55, points=25, name='Ka-25BSh Hormone A', destroyedString='shot down'},--Ka-25BSh Hormone A
        {type='Aircraft', dbid=677, points=50, name='Tu-16R Badger E', destroyedString='shot down'},--Tu-16R Badger E
        {type='Aircraft', dbid=684, points=50, name='Tu-16RM-1/2 Badger D', destroyedString='shot down'},--Tu-16RM-1/2 Badger D

        {type='Ship', dbid=1258, points=250, name='RKR Kynda [Pr.58]', destroyedString='sunk'},--RKR Kynda [Pr.58]
        {type='Ship', dbid=1261, points=250, name='BPK Kanin [Pr.57A Gnevny]', destroyedString='sunk'},--BPK Kanin [Pr.57A Gnevny]
        {type='Ship', dbid=694, points=500, name='BPK Kashin Mod [Pr.61M]', destroyedString='sunk'},--BPK Kashin Mod [Pr.61M]
        {type='Ship', dbid=733, points=3000, name='VTR Boris Chilikin [Pr.1559V]', destroyedString='sunk'},--VTR Boris Chilikin [Pr.1559V]

        {type='Submarine', dbid=243, points=150, name='diesel submarine', destroyedString='sunk'},--PL-641 Foxtrot
        {type='Submarine', dbid=250, points=200, name='nuclear submarine', destroyedString='sunk'},--PLA-627A November [Kit]
        {type='Submarine', dbid=251, points=150, name='diesel submarine', destroyedString='sunk'},--PL-633 Romeo
        {type='Submarine', dbid=279, points=150, name='diesel submarine', destroyedString='sunk'},--PL-641B Tango [Som]
    }


	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('USSR_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('NATO',matchData.points,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
    end
end