local theDamagedUnit = ScenEdit_UnitX()
local aggressor

if theDamagedUnit.type ~= "Weapon" then
    if theDamagedUnit.side == "China Fishing Fleet" or theDamagedUnit.side == "CCG" then
        aggressor = "Philippines"
    elseif theDamagedUnit.side == "Philippines" then
        aggressor = "China"
    end

    local playerSide = ScenEdit_PlayerSide()
    local vesselPositionString = ConvertDecimalPositionToDegrees(theDamagedUnit.latitude, theDamagedUnit.longitude)

    if playerSide == "United States" and aggressor == "China" then
        --radio message from affected PN vessel
        local theMessage =
            "Mayday Mayday Mayday<BR> This is Philippine warship " ..
            theDamagedUnit.name ..
                ". We are under attack by Chinese vessels in position " ..
                    vesselPositionString .. ". We request assistance from any vessels able to assist."
        theMessage = GenerateRadioMessageBody(theMessage, theDamagedUnit.name)
        RadioMessage(
            "121.50 MHz",
            "VHF",
            theMessage,
            {latitude = theDamagedUnit.latitude, longitude = theDamagedUnit.longitude}
        )

        --signal with updated orders
        theMessage =
            ACP126(
            "CTF70",
            "COMPACFLT",
            "z",
            "COMPACFLT PEARL HARBOR HI",
            "CTF 70",
            "secret",
            "1. COMPACFLT has recieved reports of chinese vessels firing on filipino naval units IVO Huangyan Island. <BR>2. this is a major escalation by the chinese and must be met with appropriate countermeasures. <BR>3. proceed with available assets directly to the vicinity of Huangyan Island and ensure the safety of filipino vessels in the area. <BR>4. You are authorised to open fire on Chinese military units that pose an immediate threat to filipino vessels or units under your command."
        )
        ScenEdit_SpecialMessage(playerSide, theMessage)
        RegisterMessage(theMessage)

    elseif playerSide == "United States" and aggressor == "Philippines" then
        --sigint intercept from China
        theMessage =
            ACP126(
            "CTF70",
            "COMPACFLT",
            "z",
            "COMPACFLT PEARL HARBOR HI",
            "CTF 70",
            "top secret",
            "1. COMPACFLT has recieved SIGINT indicating the plan intends to commence hostilities against filipino naval units IVO Huangyan Island. <BR>2. this is a major escalation by the chinese and must be met with appropriate countermeasures. <BR>3. proceed with available assets directly to the vicinity of Huangyan Island and ensure the safety of filipino vessels in the area. <BR>4. You are authorised to open fire on Chinese military units that pose an immediate threat to filipino vessels or units under your command."
        )
        ScenEdit_SpecialMessage(playerSide, theMessage)
        RegisterMessage(theMessage)

    elseif playerSide == "PLAN" and aggressor == "Philippines" then
        --radio message from CCG vessel
        local theMessage =
            "Mayday Mayday Mayday<BR> This is Chinese vessel " ..
            theDamagedUnit.name ..
                ". We are under attack by Philippine vessels in position " ..
                    vesselPositionString .. ". We request assistance from any vessels able to assist."
        theMessage = GenerateRadioMessageBody(theMessage, theDamagedUnit.name)
        RadioMessage(
            "121.50 MHz",
            "VHF",
            theMessage,
            {latitude = theDamagedUnit.latitude, longitude = theDamagedUnit.longitude}
        )

        --signal with updated orders
        theMessage =
            NonAlignedSignal(
            "commander tf 88",
            "South Fleet HQ Zhanjiang",
            "updated orders",
            "top secret",
            "immediate",
            "1. filipino aggression and provocations around Huangyan Island have escalated into open hostility. <BR>2. this blatant assault on chinese sovereignty cannot be tolerated. <BR>3. use all forces at your disposal to remove the filipino presence from the vicinity of Huangyan Island. <BR>4. you are cleared to neutralise any american forces that attempt to interfere with our defence of Huangyan Island."
        )
        ScenEdit_SpecialMessage(playerSide, theMessage)
        RegisterMessage(theMessage)

    elseif playerSide == "PLAN" and aggressor == "China" then
        --radio message from CCG vessel
        local theMessage =
            "Mayday Mayday Mayday<BR> This is Chinese vessel " ..
            theDamagedUnit.name ..
                ". We are under attack by Philippine vessels in position " ..
                    vesselPositionString .. ". We request assistance from any vessels able to assist."
        theMessage = GenerateRadioMessageBody(theMessage, "China Coast Guard 1002")
        RadioMessage(
            "121.50 MHz",
            "VHF",
            theMessage,
            {latitude = theDamagedUnit.latitude, longitude = theDamagedUnit.longitude}
        )

        --signal with updated orders
        theMessage =
            NonAlignedSignal(
            "commander tf 88",
            "South Fleet HQ Zhanjiang",
            "updated orders",
            "top secret",
            "immediate",
            "1. filipino aggression and provocations around Huangyan Island have escalated into open hostility. <BR>2. this blatant assault on chinese sovereignty cannot be tolerated. <BR>3. use all forces at your disposal to remove the filipino presence from the vicinity of Huangyan Island. <BR>4. you are cleared to neutralise any american forces that attempt to interfere with our defence of Huangyan Island."
        )
        ScenEdit_SpecialMessage(playerSide, theMessage)
        RegisterMessage(theMessage)
    end
    ScenEdit_SetSidePosture("PLAN", "United States", "H")
    ScenEdit_SetSidePosture("United States", "PLAN", "H")

    --CCF fleet disengages and flees
    ScenEdit_DeleteMission("China Fishing Fleet", "Fishing")
    local sideUnits = VP_GetSide({side = "China Fishing Fleet"}).units
    for k, v in ipairs(sideUnits) do
        local unit = ScenEdit_GetUnit({guid = v.guid})
        if unit.type == "Ship" then
            ScenEdit_SetUnit(
                {
                    guid = unit.guid,
                    course = {
                        [1] = {
                            latitude = "21.5663761778267",
                            longitude = "114.01621358279"
                        }
                    },
                    manualThrottle = "Full"
                }
            )
        end
    end

    --Initiate delayed missions 
    local function MissionTableEntryIsADuplicate(missionTable,missionGUID)
        for k,v in ipairs (missionTable) do
            if v.guid == missionGUID then
                return true
            end
        end
    end
    
    local function GetSideMissions(sideName)
        local sideUnits = VP_GetSide({side=sideName}).units
        local result = {}
        for k,v in ipairs (sideUnits) do
            local unit = ScenEdit_GetUnit({guid=v.guid})
            if unit.mission ~= nil then
                if not MissionTableEntryIsADuplicate(result,unit.mission.guid) then
                    table.insert(result,unit.mission)
                end
            end
        end
        return result
    end

    local function EnableDelayedMissions(sideName)
        local sideMissions = GetSideMissions(sideName)
        for k,v in ipairs (sideMissions) do
            ScenEdit_SetMission(sideName,v.name,{isactive=true})
        end
    end

    if playerSide == 'United States' then
        EnableDelayedMissions('PLAN')
    else
        EnableDelayedMissions('United States')
    end
end
