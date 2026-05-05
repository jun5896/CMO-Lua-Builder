inDevelopment = true

function ClearSideReferencePoints(sideName)
	local sideRPs=VP_GetSide({side=sideName}).rps
	for k,v in ipairs(sideRPs) do
		ScenEdit_DeleteReferencePoint({side=sideName,guid=v.guid})
	end
end

local playerSide = ScenEdit_PlayerSide()

if inDevelopment then
    local userInput = string.upper(ScenEdit_MsgBox('Clear RPs for '..playerSide..'?',1))
    if userInput == 'OK' then 
        ClearSideReferencePoints(playerSide)
    end
    userInput = string.upper(ScenEdit_MsgBox('Setup opposite side as AI opponent for '..playerSide..'?',1))
    if userInput == 'OK' then 
        if ScenEdit_PlayerSide() == 'United States' then
            SetupSideAsAI('PLAN')
        elseif ScenEdit_PlayerSide() == 'PLAN' then
            SetupSideAsAI('United States')
        end
    end
else
    ClearSideReferencePoints(playerSide)
    if ScenEdit_PlayerSide() == 'United States' then
        SetupSideAsAI('PLAN')
    elseif ScenEdit_PlayerSide() == 'PLAN' then
        SetupSideAsAI('United States')
    end
end

local function SetupSideAsAI(sideName)
	ScenEdit_SetSidePosture('Civilian', sideName, 'F')
	ScenEdit_SetSidePosture('Nature', sideName, 'F')
	ScenEdit_SetDoctrine({side=sideName}, {
		weapon_control_status_air = 1,
		weapon_control_status_surface = 1,
		weapon_control_status_subsurface = 1,
		weapon_control_status_land = 1,
		})
end


