local theUnit = ScenEdit_UnitX()

if theUnit.dbid == 17 and (theUnit.loadoutdbid == 5280 or theUnit.loadoutdbid == 5281) then
    if theUnit.speed < 60 and theUnit.altitude < 75 then
        local sealTeam =
            ScenEdit_AddUnit(
            {
                side = "United States",
                name = "SEAL Team 1 Tarawa Det",
                dbid = 276,
                type = "Facility",
                latitude = "10.745350905277",
                longitude = "46.6696512418712"
            }
        )

        ScenEdit_DeleteUnit({name = "LZ Black", guid = "0e8e5edf-e655-4778-b27f-702f525f8e21"})

        local theMessage =
            GenerateRadioMessageBody("Package delivered. We're RTB, out.", theUnit.name)

        RadioMessage(
            "VHF",
            "132.25MHz ENCRYPTED",
            theMessage,
            {latitude = theUnit.latitude, longitude = theUnit.longitude}
        )

        ScenEdit_SetUnit({guid = theUnit.guid, rtb = true})

        local theMessage =
            GenerateRadioMessageBody(
            "We'll need about 15 minutes to recon the beach. We'll check in once we're done, out.",
            sealTeam.name
        )
        RadioMessage(
            "VHF",
            "132.25MHz ENCRYPTED",
            theMessage,
            {latitude = sealTeam.latitude, longitude = sealTeam.longitude}
        )

        ChangeScore("United States", 50, "SEALs inserted via helo.")

        ScenEdit_SetEvent("US_SEALsArriveByHelo", {isactive = false})
    else
        local theMessage =
            GenerateRadioMessageBody(
            "We're over the LZ. We'll need to slow down and descend to a safe altitude before deploying the package, out.",
            theUnit.name
        )
        RadioMessage(
            "VHF",
            "132.25MHz ENCRYPTED",
            theMessage,
            {latitude = theUnit.latitude, longitude = theUnit.longitude}
        )
    end
elseif theUnit.dbid == 17 then
    local theMessage =
        GenerateRadioMessageBody(
        "We're over LZ Black but we don't have the right loadout.</P> <P>Please advise, out.",
        theUnit.name
    )

    RadioMessage("VHF", "132.25MHz ENCRYPTED", theMessage, {latitude = theUnit.latitude, longitude = theUnit.longitude})
end
