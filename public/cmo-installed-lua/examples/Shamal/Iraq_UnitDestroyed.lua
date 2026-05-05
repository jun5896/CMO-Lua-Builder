local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= "Weapon" then
    local targetList = {
        {type = "Aircraft", dbid = 1203, points=0, name = "Mirage F.1EQ-6", destroyedString = nil},
        --Mirage F.1EQ-6
        {type = "Aircraft", dbid = 1347, points=0, name = "MiG-29 Fulcrum A", destroyedString = nil},
        --MiG-29 Fulcrum A
        {type = "Aircraft", dbid = 2233, points=0, name = "MiG-25P Foxbat A", destroyedString = nil},
        --MiG-25P Foxbat A
        {type = "Aircraft", dbid = 2238, points=0, name = "MiG-23ML Flogger G", destroyedString = nil},
        --MiG-23ML Flogger G
        {type = "Aircraft", dbid = 2760, points=0, name = "MiG-21bis Fishbed L", destroyedString = nil},
        --MiG-21bis Fishbed L
        {type = "Aircraft", dbid = 2761, points=0, name = "MiG-21MF Fishbed J", destroyedString = nil},
        --MiG-21MF Fishbed J
        {type = "Aircraft", dbid = 361, points=0, name = "F-7B Fishbed [MiG-21 Copy]", destroyedString = nil},
        --F-7B Fishbed [MiG-21 Copy]
        {
            type = "Facility",
            dbid = 103,
            points = 0,
            name = "A/C Tarmac Space (4x Very Large Aircraft)",
            destroyedString = nil
        },
        --A/C Tarmac Space (4x Very Large Aircraft)
        {type = "Facility", dbid = 1421, points = 0, name = "Runway-Grade Taxiway (4000m)", destroyedString = nil},
        --Runway-Grade Taxiway (4000m)
        {type = "Facility", dbid = 1422, points = 0, name = "Runway-Grade Taxiway (3200m)", destroyedString = nil},
        --Runway-Grade Taxiway (3200m)
        {type = "Facility", dbid = 1423, points = 0, name = "Runway-Grade Taxiway (2600m)", destroyedString = nil},
        --Runway-Grade Taxiway (2600m)
        {
            type = "Facility",
            dbid = 1592,
            points = 0,
            name = "Single-Unit Airfield (1x 3201-4000m Runway)",
            destroyedString = nil
        },
        --Single-Unit Airfield (1x 3201-4000m Runway)
        {
            type = "Facility",
            dbid = 1695,
            points = 0,
            name = "SAM Bty/2 (SA-8b Gecko Mod-0 [9K33M2 Romb])",
            destroyedString = nil
        },
        --SAM Bty/2 (SA-8b Gecko Mod-0 [9K33M2 Romb])
        {
            type = "Facility",
            dbid = 1707,
            points = 0,
            name = "SAM Bty (SA-2f Guideline [S-75M Volkhov])",
            destroyedString = nil
        },
        --SAM Bty (SA-2f Guideline [S-75M Volkhov])
        {
            type = "Facility",
            dbid = 1712,
            points = 0,
            name = "Single-Unit Airfield (1x 2001-2600m Runway)",
            destroyedString = nil
        },
        --Single-Unit Airfield (1x 2001-2600m Runway)
        {
            type = "Facility",
            dbid = 1786,
            points = 0,
            name = "SAM Bty (SA-3b Goa [S-125M Pechora])",
            destroyedString = nil
        },
        --SAM Bty (SA-3b Goa [S-125M Pechora])
        {type = "Facility", dbid = 1830, points = 0, name = "Radar (Spoon Rest D [P-18])", destroyedString = nil},
        --Radar (Spoon Rest D [P-18])
        {
            type = "Facility",
            dbid = 1831,
            points = 0,
            name = "SAM Bty (SA-6a Gainful [2K12E Kvadrat])",
            destroyedString = nil
        },
        --SAM Bty (SA-6a Gainful [2K12E Kvadrat])
        {
            type = "Facility",
            dbid = 1833,
            points = 0,
            name = "AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)",
            destroyedString = nil
        },
        --AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)
        {
            type = "Facility",
            dbid = 1835,
            points = 0,
            name = "SAM Plt (SA-9b Gaskin [9K31 Strela-1])",
            destroyedString = nil
        },
        --SAM Plt (SA-9b Gaskin [9K31 Strela-1])
        {
            type = "Facility",
            dbid = 1837,
            points = 0,
            name = "SAM Plt (SA-13 Gopher [9K35 Strela-10])",
            destroyedString = nil
        },
        --SAM Plt (SA-13 Gopher [9K35 Strela-10])
        {
            type = "Facility",
            dbid = 1838,
            points = 0,
            name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)",
            destroyedString = nil
        },
        --AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)
        {type = "Facility", dbid = 184, points = 0, name = "A/C Revetment (1x Large Aircraft)", destroyedString = nil},
        --A/C Revetment (1x Large Aircraft)
        {
            type = "Facility",
            dbid = 186,
            points = 0,
            name = "A/C Tarmac Space (4x Large Aircraft)",
            destroyedString = nil
        },
        --A/C Tarmac Space (4x Large Aircraft)
        {
            type = "Facility",
            dbid = 1877,
            points = 0,
            name = "Single-Unit Airfield (1x 2600-3200m, Runway)",
            destroyedString = nil
        },
        --Single-Unit Airfield (1x 2600-3200m, Runway)
        {
            type = "Facility",
            dbid = 1879,
            points = 0,
            name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)",
            destroyedString = nil
        },
        --SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)
        {type = "Facility", dbid = 1881, points = 0, name = "Radar (Bar Lock A [P-37])", destroyedString = nil},
        --Radar (Bar Lock A [P-37])
        {
            type = "Facility",
            dbid = 1883,
            points = 0,
            name = "SAM Sec (SA-14 Gremlin [9K34 Strela-3] MANPADS x 3)",
            destroyedString = nil
        },
        --SAM Sec (SA-14 Gremlin [9K34 Strela-3] MANPADS x 3)
        {type = "Facility", dbid = 1886, points = 0, name = "AAA Bty (37mm M1939 x 6)", destroyedString = nil},
        --AAA Bty (37mm M1939 x 6)
        {type = "Facility", dbid = 1890, points = 0, name = "Radar (Tall King A [P-14])", destroyedString = nil},
        --Radar (Tall King A [P-14])
        {
            type = "Facility",
            dbid = 217,
            points = 0,
            name = "A/C Tarmac Space (2x Large Aircraft)",
            destroyedString = nil
        },
        --A/C Tarmac Space (2x Large Aircraft)
        {
            type = "Facility",
            dbid = 27,
            points = 0,
            name = "A/C Hardened Aircraft Shelter (1x Large Aircraft)",
            destroyedString = nil
        },
        --A/C Hardened Aircraft Shelter (1x Large Aircraft)
        {
            type = "Facility",
            dbid = 306,
            points = 0,
            name = "Runway Access Point (Large Aircraft)",
            destroyedString = nil
        },
        --Runway Access Point (Large Aircraft)
        {
            type = "Facility",
            dbid = 307,
            points = 0,
            name = "Runway Access Point (Medium Aircraft)",
            destroyedString = nil
        },
        --Runway Access Point (Medium Aircraft)
        {type = "Facility", dbid = 320, points = 0, name = "Ammo Revetment", destroyedString = nil},
        --Ammo Revetment
        {type = "Facility", dbid = 322, points = 0, name = "Ammo Bunker (Surface)", destroyedString = nil},
        --Ammo Bunker (Surface)
        {type = "Facility", dbid = 325, points = 0, name = "Ammo Bunker (Underground)", destroyedString = nil},
        --Ammo Bunker (Underground)
        {
            type = "Facility",
            dbid = 344,
            points = 0,
            name = "A/C Tarmac Space (2x Very Large Aircraft)",
            destroyedString = nil
        },
        --A/C Tarmac Space (2x Very Large Aircraft)
        {type = "Facility", dbid = 35, points = 0, name = "Runway (3200m)", destroyedString = nil},
        --Runway (3200m)
        {
            type = "Facility",
            dbid = 353,
            points = 0,
            name = "Runway Access Point (Very Large Aircraft)",
            destroyedString = nil
        },
        --Runway Access Point (Very Large Aircraft)
        {type = "Facility", dbid = 36, points = 0, name = "AvGas Bunker (150k Liter Tank)", destroyedString = nil},
        --AvGas Bunker (150k Liter Tank)
        {
            type = "Facility",
            dbid = 4,
            points = 0,
            name = "A/C Hardened Aircraft Shelter (1x Medium Aircraft)",
            destroyedString = nil
        },
        --A/C Hardened Aircraft Shelter (1x Medium Aircraft)
        {
            type = "Facility",
            dbid = 430,
            points = 0,
            name = "Single-Unit Airfield (2x 3201-4000m Runways)",
            destroyedString = nil
        },
        --Single-Unit Airfield (2x 3201-4000m Runways)
        {type = "Facility", dbid = 452, points = 0, name = "Building (Medium)", destroyedString = nil},
        --Building (Medium)
        {type = "Facility", dbid = 512, points = 0, name = "SAM Bty/2 (Roland 2 [Shelter])", destroyedString = nil},
        --SAM Bty/2 (Roland 2 [Shelter])
        {type = "Facility", dbid = 55, points = 0, name = "Runway (2600m)", destroyedString = nil},
        --Runway (2600m)
        {type = "Facility", dbid = 757, points = 0, name = "Runway (4000m)", destroyedString = nil},
        --Runway (4000m)
        {type = "Facility", dbid = 84, points = 0, name = "AvGas (150k Liter Tank)", destroyedString = nil},
        --AvGas (150k Liter Tank)
        {type = "Facility", dbid = 9, points = 0, name = "A/C Hangar (4x Large Aircraft)", destroyedString = nil},
        --A/C Hangar (4x Large Aircraft)
        {type = "Facility", dbid = 940, points = 0, name = "AvGas Bunker (750k Liter Tank)", destroyedString = nil},
        --AvGas Bunker (750k Liter Tank)
        {type = "Facility", dbid = 944, points = 0, name = "AvGas (150k Liter Underground Tank)", destroyedString = nil}
        --AvGas (150k Liter Underground Tank)
    }

    local specificTargets = {
        {name = "[Target] C-7 Medium Building)", guid = "496e17d4-a7ef-4020-9ea9-7dc0d54d57c4"},
        {name = "[Target] C-7 Medium Building)", guid = "66b1e699-4059-4cf9-bf37-12a78b6eb95d"},
        {name = "[Target] C-7 Medium Building)", guid = "cabbd68f-d008-48f9-bc87-f8dcfe3b1bcb"},
        {name = "[Target] C-7 Medium Building)", guid = "55198431-4132-448e-b404-7b328cadf2aa"},
        {name = "[Target] C-7 Medium Building)", guid = "de0b577e-7f83-44a0-99e4-13b15c756b11"},
        {name = "[Target] C-7 Medium Building)", guid = "1d757821-d57a-433a-8085-4c7f67778672"},
        {name = "[Target] C-7 Medium Building)", guid = "cf42397e-781b-41f9-92ab-853bdaf69e88"},
        {name = "[Target] C-7 Medium Building)", guid = "a35b8b8a-7941-45c0-9e90-01939b5f7b15"},
        {name = "[Target] C-7 Medium Building)", guid = "ed8352a4-43f6-4f48-9cd6-9bb4aedb895b"},
        {name = "[Target] C-7 Medium Building)", guid = "57c208ab-ea60-46b6-ae01-69eacfcd7aca"},
        {name = "[Target] C-7 Medium Building)", guid = "b468232e-30ac-4d7a-b5a1-ffd40ec756df"},
        {name = "[Target] C-7 Medium Building)", guid = "e892f806-9448-483b-aacd-59106015d68f"},
        {name = "[Target] C-7 Medium Building)", guid = "06411691-e8f7-4baa-a276-7d7931e667a0"},
        {name = "[Target] C-7 Medium Building)", guid = "f11236ac-4ea0-46c6-89f1-7aa607ecad49"},
        {name = "[Target] C-7 Medium Building)", guid = "3474aa3f-5a0e-4b76-96fb-193814ac1fdd"},
        {name = "[Target] C-7 Medium Building)", guid = "3da9a5fb-4ec8-4669-8d51-2973583f6c1a"},
        {name = "[Target] C-7 Medium Building)", guid = "7dab5975-1e9c-4cc5-8ced-9b057bcf067b"},
        {name = "[Target] C-7 Medium Building)", guid = "4cecfebf-c4fa-42a1-93fd-2f1085259713"},
        {name = "[Target] C-7 Medium Building)", guid = "b1966105-f070-4949-be91-b4bd6a32d729"},
        {name = "[Target] C-7 Medium Building)", guid = "d68def85-5eec-45a9-8665-3d314964ba4e"},
        {name = "[Target] C-7 Medium Building)", guid = "5eaf1a37-3e8f-4f21-a115-623524ef570a"},
        {name = "[Target] C-7 Medium Building)", guid = "9fdff308-5620-400f-a186-6dc9d0a5012e"},
        {name = "[Target] C-7 Medium Building)", guid = "05e7bcf0-e758-4815-b163-8c606b52fac8"},
        {name = "[Target] Runway (3885 x 45 m, 11/29)", guid = "6f27cd00-7a27-4e23-b24a-d38ee18f6ab3"},
        {name = "[Target] Runway (3765 x 30 m, 11/29)", guid = "f0e77e5d-9dcd-4a6c-acff-56d9dd57bc43"},
        {
            name = "[Target] A/C Tab-Vee Hardened Aircraft Shelter (1x Large Aircraft)",
            guid = "5eac5293-de7e-4496-94d1-3cdca99ea148"
        },
        {
            name = "[Target] A/C Tab-Vee Hardened Aircraft Shelter (1x Large Aircraft)",
            guid = "2aeaa1b7-f5ba-4d61-a7b8-ad49b6a82b5c"
        },
        {
            name = "[Target] A/C Quick Turn Hardened Aircraft Shelter (1x Medium Aircraft)",
            guid = "2ffb087a-51c0-412a-897f-bba3d78b00d7"
        },
        {
            name = "[Target] A/C Quick Turn Hardened Aircraft Shelter (1x Medium Aircraft)",
            guid = "7f2e9bd0-8699-4355-b0b0-00aedbca2285"
        },
        {
            name = "[Target] A/C Quick Turn Hardened Aircraft Shelter (1x Medium Aircraft)",
            guid = "6f7a81d6-190b-485b-b84c-98da24f93ef1"
        },
        {
            name = "[Target] A/C Quick Turn Hardened Aircraft Shelter (1x Medium Aircraft)",
            guid = "e7aa907a-4f0c-4e37-bdce-4520313455bd"
        },
        {name = "[Target] Ammo Revetement", guid = "b36f6672-8064-4227-8027-1228da54cfe5"},
        {name = "[Target] Ammo Revetement", guid = "b11adc06-b0c6-43e4-8c89-3544064c70b6"},
        {name = "[Target] Ammo Revetement", guid = "9da269c0-291f-4cd5-b9d1-0334e929e9a7"},
        {name = "[Target] Ammo Revetement", guid = "061c1b63-3b67-4661-b5fd-8ade02913110"},
        {name = "[Target] Ammo Revetement", guid = "890b3b84-8e79-4566-9776-d245149fc670"},
        {name = "[Target] Ammo Revetement", guid = "41f3691e-0849-4689-893d-94830b7cf5b1"},
        {name = "[Target] Ammo Revetement", guid = "5a31fe2d-e50c-41c7-83b5-edcad847e7c4"},
        {name = "[Target] Ammo Revetement", guid = "431b48f8-9ff1-4d3e-98e6-73b6ac55cef4"},
        {name = "[Target] Ammo Revetement", guid = "334cf160-c2ae-4ad1-9999-15e401c5e0dc"},
        {name = "[Target] Ammo Revetement", guid = "e9099ef3-744e-4582-a32b-9fa455bb2ea4"},
        {name = "[Target] Ammo Revetement", guid = "03dab234-e2c8-40cb-a74f-9341713a4c8f"},
        {name = "[Target] Ammo Revetement", guid = "76d678cb-67a5-4ec9-a507-b5f91157f74e"},
        {name = "[Target] Ammo Revetement", guid = "465824cf-f485-417f-8b79-7acaecbe4a08"},
        {name = "[Target] Ammo Revetement", guid = "af4e6f20-471b-4119-9228-0195c83ac907"},
        {name = "[Target] Ammo Revetement", guid = "0465bd47-5d2b-4d1b-ae0d-4393ef7eaaac"},
        {name = "[Target] Ammo Revetement", guid = "d6db266c-2897-4819-a410-ee2e5f87f835"},
        {name = "[Target] Ammo Bunker (Surface)", guid = "e4082423-ffe0-4d9c-a0ef-eb302f066537"}
    }

    local matchData = {}

    for k, v in ipairs(targetList) do
        if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
            matchData = v
        end
    end

    local unitIsSpecificTarget = false

    for k, v in ipairs(specificTargets) do
        if v.guid == theDestroyedUnit.guid then
            unitIsSpecificTarget = true
        end
    end

    local humanSide = ScenEdit_PlayerSide()

    if matchData == {} then
        BugMessage("Iraq_UnitDestroyed", "No dbid match found for destroyed unit")
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage(
                "playerside",
                "Could not find match for destroyed unit " ..
                    theDestroyedUnit.name .. ", dbid " .. theDestroyedUnit.dbid
            )
        end
    else
        if unitIsSpecificTarget then
            ChangeScore(
                humanSide,
                100,
                "A designated Iraqi target " ..
                    string.lower(theDestroyedUnit.type) .. " was destroyed."
            )
        else
            ChangeScore(
                humanSide,
                matchData.points,
                "An Iraqi " .. matchData.name .. " was destroyed."
            )
        end
    end
end
