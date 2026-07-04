local theUnit = ScenEdit_UnitX()

local landingCraft = {
    {name = "LCU 1646", guid = "c11f49f6-481f-4210-922d-423a131bc393"},
    {name = "LCU 1646", guid = "4650c2a3-b0de-4476-80b2-322ef5c88fc8"}
}

local unitsToBeDeployed = {
    {name = "3 Pl B Coy 13th MAU", dbid = 1696, latitude = 10.744568674954, longitude = 46.667298395996},
    {name = "2 Pl B Coy 13th MAU", dbid = 1696, latitude = 10.742423015626, longitude = 46.666803324096},
    {name = "1 Pl B Coy 13th MAU", dbid = 1696, latitude = 10.741329199375, longitude = 46.66492503554},
    {name = "Armoured Pl 13th MAU", dbid = 1346, latitude = 10.743438271456, longitude = 46.667085521867}
}

local beachMarker = {name = "White Beach", guid = "cdb63397-7fbe-46e0-8076-6b09d4067317"}

local function DeployUnits()
    for k, v in ipairs(unitsToBeDeployed) do
        ScenEdit_AddUnit(
            {
                side = "United States",
                name = v.name,
                type = "Facility",
                dbid = v.dbid,
                latitude = v.latitude,
                longitude = v.longitude
            }
        )
    end
end

local function LandingCraftIsAlive(guid)
    local unit, result = ScenEdit_GetUnit({guid = guid}), false
    if unit ~= nil then
        result = true
    end
    return result
end

local function BothLandingCraftAreAlive()
    local numberAlive, result = 0, false
    for k, v in ipairs(landingCraft) do
        if LandingCraftIsAlive(v.guid) then
            numberAlive = numberAlive + 1
        end
    end
    print(numberAlive)
    if numberAlive == 2 then
        result = true
    end
    return result
end

local function UnitIsOneOfTheDesignatedLCUs(guid)
    local result = false
    if guid == landingCraft[1].guid or guid == landingCraft[2].guid then
        result = true
    end
    return result
end

if UnitIsOneOfTheDesignatedLCUs(theUnit.guid) then
    if BothLandingCraftAreAlive then
        local seperationRange = Tool_Range(landingCraft[1].guid, landingCraft[2].guid)
        if seperationRange <= 5 then
            DeployUnits()
            ChangeScore("United States", 300, "Marines landed at White Beach.")
            local theMessage =
                GenerateRadioMessageBody(
                "We've landed our embarked units. Out.",
                theUnit.name
            )
            RadioMessage(
                "VHF",
                "131.25 MHz ENCRYPTED",
                theMessage,
                {latitude = theUnit.latitude, longitude = theUnit.longitude}
            )

            ScenEdit_DeleteUnit({guid = beachMarker.guid})
            ScenEdit_SetEvent("US_MarinesArriveByLCU", {isactive = false})
        else
            local theMessage =
                GenerateRadioMessageBody(
                "We're at the beach but we need to wait for the other LCU to arrive before we commence the landing. Out.",
                theUnit.name
            )
            RadioMessage(
                "VHF",
                "131.25 MHz ENCRYPTED",
                theMessage,
                {latitude = theUnit.latitude, longitude = theUnit.longitude}
            )
        end
    else
        DeployUnits()
        ChangeScore("United States", 150, "Marines landed at White Beach after losing an LCU.")
        local theMessage =
                GenerateRadioMessageBody(
            "We've landed our embarked units. Out.",
            theUnit.name
        )
        RadioMessage(
            "VHF",
            "131.25 MHz ENCRYPTED",
            theMessage,
            {latitude = theUnit.latitude, longitude = theUnit.longitude}
        )
        ScenEdit_DeleteUnit({guid = beachMarker.guid})
        ScenEdit_SetEvent("US_MarinesArriveByLCU", {isactive = false})
    end
end
