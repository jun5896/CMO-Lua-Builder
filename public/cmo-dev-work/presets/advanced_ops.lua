return {
    header = {
        title = "Advanced Operations Demo",
        description = "Demonstrates the 10 new advanced templates including IADS, CSAR, Weather, Traffic, and Radio Messages."
    },
    multi_file = false,
    
    sides = {
        { name = "playerside", posture = { RED = "Hostile", Civilian = "Neutral", ["Downed Pilots"] = "Friendly" } },
        { name = "RED", posture = { playerside = "Hostile" } },
        { name = "Civilian", posture = { playerside = "Neutral", RED = "Neutral" } },
        { name = "Downed Pilots", posture = { playerside = "Friendly" } }
    },
    
    reference_points = {
        { side = "playerside", name = "RP-1", latitude = 35.0, longitude = 129.0 },
        { side = "playerside", name = "RP-2", latitude = 35.1, longitude = 129.0 },
        { side = "playerside", name = "RP-3", latitude = 35.1, longitude = 129.1 },
        { side = "playerside", name = "RP-4", latitude = 35.0, longitude = 129.1 },
    },
    
    units = {
        -- CSAR Test Target
        { side = "playerside", name = "Viper 1", type = "Aircraft", dbid = 316, latitude = 34.5, longitude = 129.5 },
        -- Logistics Base
        { side = "playerside", name = "Blue Airbase", type = "Facility", dbid = 430, latitude = 37.09, longitude = 127.03 },
        -- IADS SAM Target
        { side = "RED", name = "SA-21 Battery", type = "Facility", dbid = 543, latitude = 39.0, longitude = 125.0 }
    },

    events = {
        -- 1. IADS Ambush
        {
            name = "Red IADS Ambush",
            kind = "iads_ambush",
            side = "RED",
            unit_name = "SA-21 Battery",
            engage_range = 80,
            interval = 5
        },
        -- 2. Cargo Drop
        {
            name = "Special Forces Drop",
            kind = "cargo_drop",
            side = "playerside",
            unit_name = "Viper 1",
            drop_zone = "{'RP-1', 'RP-2', 'RP-3', 'RP-4'}"
        },
        -- 3. Victory Condition
        {
            name = "Check Victory",
            kind = "victory_cond",
            side = "playerside",
            points = 500,
            check_logic = "return (ScenEdit_GetScore('playerside') >= 1000)",
            message = "Score reached 1000! You win!",
            end_scenario = true,
            interval = 30
        },
        -- 4. Teleport
        {
            name = "Teleport SAM",
            kind = "teleport",
            target_guids = {}, -- Would be dynamic in a real scenario
            lat_min = 38.0, lat_max = 39.0,
            lon_min = 124.0, lon_max = 126.0,
            require_land = true,
            interval = 600
        },
        -- 5. CSAR
        {
            name = "CSAR Auto-Spawner",
            kind = "csar",
            target_side = "playerside",
            rescue_side = "playerside"
        },
        -- 6. Logistics
        {
            name = "Osan AB Resupply",
            kind = "logistics",
            side = "playerside",
            base_name = "Blue Airbase",
            logistics_mode = "distribute",
            weapon_dbid = 897,
            quantity = 50,
            interval = 3600
        },
        -- 7. Split/Merge
        {
            name = "Deploy SAM",
            kind = "split_merge",
            side = "RED",
            unit_name = "SA-21 Battery",
            mode = "split",
            interval = 1200
        },
        -- 8. Dynamic Weather
        {
            name = "Weather Drift",
            kind = "dynamic_weather",
            interval = 1800
        },
        -- 9. Ambient Traffic
        {
            name = "Spawn Traffic",
            kind = "ambient_traffic",
            amount = 10,
            lat_min = 34.0, lat_max = 35.0,
            lon_min = 128.0, lon_max = 130.0,
            interval = 7200
        },
        -- 10. Radio Message
        {
            name = "HQ Radio Broadcast",
            kind = "radio_message",
            msg_type = "telex",
            side = "playerside",
            body = "INTELLIGENCE INDICATES RED IADS IS ACTIVE. PROCEED WITH EXTREME CAUTION.",
            rec_station = "VIPER",
            snd_station = "AWACS",
            precedence = "O",
            classification = "SECRET",
            interval = 600
        }
    }
}
