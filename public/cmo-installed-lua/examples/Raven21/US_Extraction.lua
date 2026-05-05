local theUnit = ScenEdit_UnitX()

if theUnit.dbid == 667 then
    if theUnit.speed < 60 and theUnit.altitude < 75 then
        local function ReturnSEALTeamData()
            local unitList, sealTeamDBID = VP_GetSide({side = "United States"}).units, 276
            for k, v in ipairs(unitList) do
                local unit = ScenEdit_GetUnit({guid = v.guid})
                if unit.dbid == sealTeam and unit.type == "Facility" then
                    return unit
                end
            end
        end

        local sealTeam = ReturnSEALTeamData()

        local rangeToHelo
        if sealTeam ~= nil then
            rangeToHelo = Tool_Range(theUnit.guid, sealTeam.guid)
        else
            rangeToHelo = 9999
        end

        if rangeToHelo <= 5 then
            ScenEdit_DeleteUnit({guid = sealTeam})
            local theMessage =
                GenerateRadioMessageBody(
                "We've got the SEALs and the WIAs and KIAs onboard. We're RTB, out.",
                theUnit.name
            )
            RadioMessage(
                "VHF",
                "132.25MHz ENCRYPTED",
                theMessage,
                {latitude = theUnit.latitude, longitude = theUnit.longitude}
            )
            ChangeScore("United States", 100, "The crew of Raven 21 was extracted via helo along with SEAL Team 1.")
        else
            local theMessage =
                GenerateRadioMessageBody("We've got the WIA and KIAs onboard. We're RTB, out.", theUnit.name)
            RadioMessage(
                "VHF",
                "132.25MHz ENCRYPTED",
                theMessage,
                {latitude = theUnit.latitude, longitude = theUnit.longitude}
            )
            ChangeScore("United States", 50, "The crew of Raven 21 was extracted via helo.")
        end

        TelexMessageToPlayer(
            'ntbi',
            'COMIDEASTFOR',
            'z',
            'Commander Middle east force',
            'commanding officer cv 34 oriskany',
            'top secret',
            '1. bravo zulu on retrieval of the crew of raven 21.<BR> 2. if not already enacted, immediately ensure destruction of raven 21 wreckage.'
        )

        ScenEdit_SetUnit({guid = theUnit.guid, rtb = true})
        ScenEdit_SetEvent("US_Extraction", {isactive = false})

    else

        local theMessage =
            GenerateRadioMessageBody(
            "We're over the LZ. We'll need to slow down and descend to a safe altitude before retrieving the package, out.",
            theUnit.name
        )
        RadioMessage(
            "VHF",
            "132.25MHz ENCRYPTED",
            theMessage,
            {latitude = theUnit.latitude, longitude = theUnit.longitude}
        )
    end
end