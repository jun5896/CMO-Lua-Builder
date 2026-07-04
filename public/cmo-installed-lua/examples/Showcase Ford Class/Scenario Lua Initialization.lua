ScenEdit_RunScript('DeveloperMode.lua')

math.randomseed(os.time())
math.random()

-- =====================================
-- Set and Restore Scenario Variables --
-- =====================================

-- =========================
-- Set Variables on Scenario Load
-- =========================

function SetScenarioVariables()
	local variablesList = {
		-- Variables that need to be restored when scenario is reloaded
		{variable='Angola_CeasefireCounter', value=0, persist=true, key='Angola_CeasefireCounterKey'},
		{variable='Angola_CeasefireTime', value=math.random(24,36), persist=true, key='Angola_CeasefireTimeKey'},
		{variable='Russia_CeasefireCounter', value=0, persist=true, key='Russia_CeasefireCounterKey'},
		{variable='Russia_CeasefireTime', value=math.random(12,18), persist=true, key='Russia_CeasefireTimeKey'},

		-- Variables only needed upon scenario initialization
	}

	for _, v in ipairs(variablesList) do
		_G[v.variable] = v.value
		if v.persist then
			ScenEdit_SetKeyValue(v.key, tostring(v.value))
		end
	end
end

-- =========================
-- Restore Variables on Scenario Reload
-- =========================

function RestoreScenarioVariables()
	local variablesList = {
		{variable='Angola_CeasefireCounter', key='Angola_CeasefireCounterKey'},
		{variable='Angola_CeasefireTime', key='Angola_CeasefireTimeKey'},
		{variable='Russia_CeasefireCounter', key='Russia_CeasefireCounterKey'},
		{variable='Russia_CeasefireTime', key='Russia_CeasefireTimeKey'},
	}

	-- Restore the values from the key store
	for _, v in ipairs(variablesList) do
		local value = ScenEdit_GetKeyValue(v.key)

		-- Check if the value is numeric to convert it
		if tonumber(value) then
			_G[v.variable] = tonumber(value)
		else
			_G[v.variable] = value
		end
	end
end

-- ==========================
-- Scenario Initialization --
-- ==========================

function ThisIsFirstLoad(booleanValue)
	local result
	if booleanValue == nil then
		result = ScenEdit_GetKeyValue('firstLoad')
		if result == '' or result == nil then result = true end
		if result == 'false' then result = false end
	else
		if booleanValue == true then
			ScenEdit_ClearKeyValue('firstLoad')
			result = true
		elseif booleanValue == false then
			ScenEdit_SetKeyValue('firstLoad','false')
			result = false
		end
	end
	return result
end

if ThisIsFirstLoad() then
	math.randomseed(os.time())
	local PlayerSide = ScenEdit_PlayerSide()
	if inDevelopment then -- Ask to do stuff
		userInput = string.upper(ScenEdit_MsgBox('Set scenario variables?',1))
		if userInput == 'OK' then
			SetScenarioVariables()
		end

		userInput = string.upper(ScenEdit_MsgBox('Set firstLoad key value to false?',1))
		if userInput == 'OK' then
			ThisIsFirstLoad(false)
		end
	else -- Don't give the option and just do it
		SetScenarioVariables()
		ThisIsFirstLoad(false)
	end
else
	RestoreScenarioVariables()
end