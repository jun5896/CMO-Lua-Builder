local theDestroyedUnit = ScenEdit_UnitX()
local targetList = {
	{dbid = 626, type = 'Facility', name = 'Rebel Inf Plt', points=50, descriptor='eliminated'},
	{dbid = 1496, type = 'Facility', name = 'Rebel Ammo Pad', points=50, descriptor='destroyed'},
	{dbid = 1749, type = 'Facility', name = 'Rebel Tents', points=25, descriptor='destroyed'},
	{dbid = 1522, type = 'Facility', name = 'Rebel AAA Sec', points=50, descriptor='eliminated'},
}

local matchData = {}

for k,v in ipairs (targetList) do
	if v.dbid == theDestroyedUnit.dbid then
		matchData = v
	end
end

if matchData == {} then
	BugMessage('Rebels_UnitDestroyed', 'No dbid match found for destroyed unit')
	if DebugModeIsOn() then
		ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
	end
else
	ChangeScore('Colombia',matchData.points,'A Colombian '..matchData.name.. ' was '..matchData.descriptor)
end

local rebelSide = VP_GetSide({side='Rebels'})
local remainingUnits = 0
for k,v in ipairs (rebelSide.units) do
    local unit = ScenEdit_GetUnit({guid=v.guid})
	if unit.dbid == 626 or --Inf Plt
		unit.dbid == 1522 then --AAA
			remainingUnits = remainingUnits + 1
	end
end

local debriefMessageHasPlayed = ConvertStringToBoolean(ScenEdit_GetKeyValue('GameOver'))

if remainingUnits == 0 and not debriefMessageHasPlayed then
	local minutesCurrent = TimeIs().minute
	local minutesToNextHour = 60-minutesCurrent
	local theMessage = ACP126('OBISPO','HQJOC','o','joint operations command bogota','obispo','top secret','All rebel combatants confirmed as eliminated. Recover raiding party to within Colombian airspace and prepare for debrief in approximately '..minutesToNextHour..' mins.')
	ScenEdit_SpecialMessage('playerside',theMessage)
	RegisterMessage(theMessage)
	ScenEdit_SetKeyValue('GameOver','true')
end