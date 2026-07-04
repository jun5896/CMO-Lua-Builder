local rebelBase = ScenEdit_GetReferencePoint({side='Rebels',name='Rebel Base'})
local intelReceived = ConvertStringToBoolean(ScenEdit_GetKeyValue('intelReceived'))

if rebelBase == nil then
	BugMessage('Game_IntelReceived','Unable to find Rebel Base reference point!')
elseif intelReceived then
	BugMessage('Game_IntelReceived','Intel provided too early!')
else
	local rebelSide = VP_GetSide({side='Rebels'})
	for k,v in ipairs (rebelSide.units) do
		if v.dbid == 1496 or --Ammo pad
			v.dbid == 1749 then --Tents
				local unit = ScenEdit_GetUnit({guid=v.guid})
				ScenEdit_SetUnit({guid=unit.guid,autodetectable=true})
		end
	end
	local specialForcesPosition = CircularRandomPosition(rebelBase.latitude,rebelBase.longitude, 5)
	ScenEdit_AddUnit({side='Colombia', name="'COBRAS' Sqn 7th SF Grp", type='Facility', dbid=614, latitude=specialForcesPosition.latitude, longitude=specialForcesPosition.longitude})
	local positionString = ConvertDecimalPositionToDegrees(rebelBase.latitude,rebelBase.longitude)
	
	local theMessage = ACP126('OBISPO','HQJOC','o','joint operations command bogota','obispo','top secret','venezuelan submarine confirmed responsible for attack on BL 161 cartagena de indias; venezuela formally declared war approximately 20 minutes ago. </p> we now have solid intelligence on the location of the rebel camp, and the president believes this will be our best chance to destroy it before large scale hostilities develop. <p>Updated orders as follows: <BR> 1. Immediately dispatch raiding forces to attack and destroy the rebel camp located in the vicinity of '..positionString..'. <BR> 2. Ensure no rebels survive the raid. 7th SF group personnel are at your disposal for spotting if required, however it is expected you will make use of helicopter deployed infantry from 2nd Division to scour the target area to identify stragglers.  <BR> 3. Ensure the safety of the raiding party by countering any threats posed by venezuelan aircraft.</p> ROE changes: <BR> Air - Tight <BR> surface - tight <br> subsurface - free.')
	ScenEdit_SpecialMessage('playerside',theMessage)
	RegisterMessage(theMessage)
	ScenEdit_SetKeyValue('intelReceived','true')
end