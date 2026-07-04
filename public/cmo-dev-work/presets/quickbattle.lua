-- presets/quickbattle.lua
-- 동적 시나리오 생성을 시연하는 예제. (Task 9)
-- cmo.build("quickbattle") 호출 시점마다 랜덤한 유닛 편제와 위치를 가지는 설정이 반환됩니다.

math.randomseed(os.time() + math.random(1, 10000))

local function pick_random(list)
    return list[math.random(1, #list)]
end

-- DB3K_517 기준으로 검증되는 항공기/함선/시설 DBID 목록
local blue_aircraft_dbids = { 316, 211, 342, 253 } -- F-16, F-15, F/A-18, MiG-29
local red_ship_dbids = { 87, 593 } -- Slava-class cruisers
local red_facility_dbids = { 37, 543, 439 } -- S-300, S-400, Big Bird radar

local config = {
    header = {
        title = "Dynamic Quick Battle - " .. os.date("%Y%m%d_%H%M%S"),
        description = "This scenario was dynamically generated with random forces and locations.",
    },
    sides = {
        { side = "Blue", postures = { { other_side = "Red", posture = "H" } } },
        { side = "Red", postures = { { other_side = "Blue", posture = "H" } } },
    },
    units = {},
    missions = {},
}

-- 1. Blue 항공기 랜덤 배치 (unit_spawn_random 활용)
local num_blue = math.random(2, 4)
local interceptors = {}
for i = 1, num_blue do
    local uname = "Blue-Fighter-" .. i
    interceptors[#interceptors + 1] = uname
    config.units[#config.units + 1] = {
        is_random = true,
        side = "Blue",
        name = uname,
        type = "Aircraft",
        dbid = pick_random(blue_aircraft_dbids),
        terrain = "sea", -- 바다 위에 공중 스폰 (고도 지정)
        lat_min = 34.0, lat_max = 35.0,
        lon_min = 127.0, lon_max = 128.0,
        altitude = 15000 + math.random(-5000, 5000),
        speed = 400 + math.random(-50, 100)
    }
end

-- 2. Red 해상/지상 랜덤 배치
local num_red = math.random(2, 4)
for i = 1, num_red do
    local is_ship = (math.random() > 0.5)
    config.units[#config.units + 1] = {
        is_random = true,
        side = "Red",
        name = (is_ship and "Red-Ship-" or "Red-SAM-") .. i,
        type = is_ship and "Ship" or "Facility",
        dbid = is_ship and pick_random(red_ship_dbids) or pick_random(red_facility_dbids),
        terrain = is_ship and "sea" or "land",
        lat_min = 35.5, lat_max = 36.5,
        lon_min = 126.5, lon_max = 128.5,
    }
end

-- 3. 순찰 미션 할당
config.missions[#config.missions + 1] = {
    kind = "patrol",
    side = "Blue",
    name = "QB-CAP",
    patrol_type = "AAW",
    flight_size = 2,
    active_emcon = true
    -- zone 은 생략 (동적 생성에서는 zone 도 무작위 생성 가능)
}

return config
