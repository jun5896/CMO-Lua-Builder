-- presets/cap_patrol.lua
return {
    header = { title = "CAP Patrol", description = "Defensive AAW patrol" },
    reference_points = {
        { side = "Blue", name = "CAP-NW", lat = 36.0, lon = 127.5 },
        { side = "Blue", name = "CAP-NE", lat = 36.0, lon = 128.5 },
        { side = "Blue", name = "CAP-SE", lat = 35.5, lon = 128.5 },
        { side = "Blue", name = "CAP-SW", lat = 35.5, lon = 127.5 },
    },
    units = {
        { side = "Blue", name = "CAP-1", type = "Aircraft", dbid = 211, lat = 35.75, lon = 128.0, alt = 9000, speed = 480 },
    },
    missions = {
        {
            kind = "patrol", side = "Blue", name = "CAP-1-Patrol",
            patrol_type = "AAW",
            patrol_zone_rps = { "CAP-NW", "CAP-NE", "CAP-SE", "CAP-SW" },
            oneThirdRule = true,
        },
    },
}
