scenarioScriptFilePath = '/FighterWeaponsSchool/'

function RunScript(fileName)
	local scriptFilePath = scenarioScriptFilePath..fileName..'.lua'
	print ('Attempting to execute '..scriptFilePath)
	if ScenEdit_RunScript(scriptFilePath) then
		print ('Success!')
	end
end

function LuaReset()
	print ('Resetting...')
	ScenEdit_ClearKeyValue("")
	print ('KeyValues cleared.')
	RunScript('LuaInit')
end

function ConvertStringToBoolean(stringName)
	local stringName = string.upper(stringName)
	local result = false
	if stringName == 'TRUE' then
		result = true
	end
	return result
end

function IsBetaVersion(booleanValue)
	if booleanValue == true then
		ScenEdit_SetKeyValue('betaVersion','true')
		return true
	elseif booleanValue == false then
		ScenEdit_SetKeyValue('betaVersion','false')
		return false
	else
		local betaStatus = ScenEdit_GetKeyValue('betaVersion')
		local result = ConvertStringToBoolean(betaStatus)
		return result
	end
end

IsBetaVersion(true) --------------------------------------------------REMOVE BEFORE RELEASE
scenarioZuluOffset = -4 ----------CHANGE PER SCENARIO

function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function CircularRandomPosition(x_latitude, x_longitude, max_radius)
	local randomisationCircle = World_GetCircleFromPoint({
		latitude=x_latitude,
		longitude=x_longitude,
		radius=math.random(0.1,max_radius),
		numpoints = 72})
	local randomisedPoint = randomisationCircle[math.random(1,#randomisationCircle)]
    return randomisedPoint
end

function ChangeScore(side,amt,reason)
	local newScore = ScenEdit_GetScore(side) + amt
	ScenEdit_SetScore(side,newScore,reason)
	print (side..' score changed to '..newScore)
	return newScore
end

function BugMessage(eventName,description)
	if IsBetaVersion() then
		ScenEdit_MsgBox('An issue occured with '..eventName..';\n'..description..'\n\nThis will not affect system stability but may affect scenario balance. \n\nPlease report this in the Beta Testing Forum. \n\nThanks!', 0)
	else
		ScenEdit_MsgBox('An issue occured with '..eventName..';\n'..description..'\n\nThis will not affect system stability but may affect scenario balance. \n\nPlease report this in the Tech Support subforum on the Matrix Games forum, including a screenshot of this message. \n\nhttp://www.matrixgames.com/forums/tt.asp?forumid=1279', 0)
	end
end

function RandomiseUnitTableProficiency(unitTable)
	for k,v in ipairs (unitTable) do
		local unit = ScenEdit_GetUnit({guid=v.guid})
		if unit.type ~= 'Group' then
			local chance = math.random(1,100)
			if chance <=50 then proficiency = 2
			elseif chance <=70 then proficiency = 3
			elseif chance <=90 then proficiency = 1
			elseif chance <=95 then proficiency = 4
			elseif chance <=100 then proficiency = 0
			end
			ScenEdit_SetUnit({guid=v.guid,proficiency=proficiency})
		end
	end
end

function RandomiseSideUnitProficiency(sideName)
	local sideUnits = VP_GetSide({side=sideName}).units
	RandomiseUnitTableProficiency(sideUnits)
end