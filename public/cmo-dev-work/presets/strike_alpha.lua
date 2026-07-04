-- presets/strike_alpha.lua
-- 데모 시나리오: NATO 측 F-35 두 기로 적 SAM 사이트 타격.
return {
    header = {
        title = "Strike Alpha",
        description = "NATO Air-to-Ground demo",
    },
    sides = {
        { side = "Blue", postures = {
            { other_side = "Red", posture = "H" },
        }},
    },
    units = {
        { side = "Blue", name = "Striker-1", type = "Aircraft", dbid = 3326, lat = 35.0, lon = 128.0, alt = 8000, heading = 270, speed = 450 },
        { side = "Blue", name = "Striker-2", type = "Aircraft", dbid = 3326, lat = 35.05, lon = 128.05, alt = 8000, heading = 270, speed = 450 },
        { side = "Red", name = "SAM-Site-1", type = "Facility", dbid = 123, lat = 35.4, lon = 127.6 },
    },
    missions = {
        {
            kind = "strike", side = "Blue", name = "Strike-Alpha",
            strike_type = "Land",
            target_side = "Red",
            targets = { "SAM-Site-1" },
            flight_size = 2,
        },
    },
    events = {
        {
            kind = "kv_flag",
            name = "Test_KV_Flag",
            trigger = { type = "RegularTime", name = "trig_time_1", opts = { Interval = 15 } },
            kv_key = "IsFirstWarningSent",
            lua_script = 'ScenEdit_SpecialMessage("Blue", "This is your first and only warning.")'
        },
        {
            kind = "unit_x",
            name = "Test_Unit_X_Enters",
            trigger_type = "UnitEntersArea",
            trigger_opts = { TargetFilter = { TargetSide = "Blue" }, Area = { "RP-1", "RP-2", "RP-3", "RP-4" } },
            lua_script = 'ScenEdit_SpecialMessage("Blue", string.format("Unit %s entered the zone!", u.name))'
        },
        {
            kind = "dbid_score",
            name = "Test_DBID_Score",
            target_side = "Red",
            side = "Blue",
            scores = {
                Facility = {
                    [123] = 100,
                },
            }
        },
        {
            kind = "escalation",
            name = "Test_Escalation_Hostile",
            trigger = { type = "UnitDestroyed", name = "trig_esc", opts = { TargetFilter = { TargetSide = "Blue" } } },
            postures = {
                { side = "Blue", other_side = "Red", posture = "H" },
                { side = "Red", other_side = "Blue", posture = "H" }
            },
            doctrines = {
                { side = "Blue", settings = { weapon_state_planned = "5111" } }
            },
            message = { side = "Blue", text = "DEFCON 3: We have taken casualties. ROE changed to Weapons Free!" }
        },
        {
            kind = "contact_emcon",
            name = "Test_Contact_EMCON",
            trigger = { name = "trig_time_15s", opts = { Interval = 15 } },
            side = "Blue",
            target_posture = "H",
            emcon = { type = "Side", id = "Blue", value = "Radar=Active" },
            message = { text = "Hostile contact detected! EMCON set to Active." }
        },
        {
            kind = "missions_toggle",
            name = "Test_Missions_Toggle",
            trigger = { type = "UnitDetected", name = "trig_detected", opts = { TargetFilter = { TargetSide = "Red" } } },
            side = "Blue",
            activate_missions = { "Strike-Alpha" },
            deactivate_missions = { "Patrol-Beta" },
            message = { text = "Enemy detected. Activating Strike-Alpha and deactivating Patrol-Beta." }
        },
        {
            kind = "scramble",
            name = "Test_Scramble",
            trigger = { type = "ScenLoaded", name = "trig_scen_loaded" },
            side = "Blue",
            units = { "Striker-1", "Striker-2" },
            loadout_dbid = 33136,
            mission = "Strike-Alpha",
            message = { side = "Blue", text = "Emergency Scramble! Striker-1 and Striker-2 launching immediately." }
        }
    },
    weather = {
        { temp_min = 10, temp_max = 20, rain_chance = 0.3, sea_state_min = 1, sea_state_max = 3 }
    },
    inst_imports = {
        { side = "Red", filename = "Bunker_Complex.inst" }
    }
}
