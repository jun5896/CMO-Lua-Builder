-- event_csar.tpl.lua
-- CSAR (Combat Search And Rescue) 자동 생성 스크립트
-- NorthPacific 시나리오 구현을 참고하여 고도화:
-- - 66% 확률로 조종사 생존 판정
-- - 바다: 구명보트(DBID 2553) / 육지: 조종사(DBID 2441) 분기
-- - 랜덤 계급+이름 생성, 격추 좌표 주변 반경 2nm 이내 랜덤 오프셋
-- - MAYDAY 구조 무전 발송
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "CSAR Auto-Spawner Event")}},
        isactive     = true,
        isrepeatable = true,
        isshown      = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trigger")}}
        ScenEdit_SetTrigger({
            mode = "add",
            type = "UnitDestroyed",
            name = __tname,
            targetfilter = { TargetSide = {{q(target_side)}} }
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local rescue_side = {{q(rescue_side or "")}}
local destroyed_unit = ScenEdit_UnitX()

-- 조종사 생존 확률 (66%)
local function PilotSurvives()
    return math.random(1, 100) <= 66
end

-- 랜덤 성명 생성
local function GenerateSurvivorName()
    local ranks = {"2LT", "1LT", "CAPT", "MAJ", "LCDR", "LT"}
    local alphabet = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'}
    local surnames = {
        "Smith", "Johnson", "Williams", "Brown", "Jones",
        "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
        "Ivanov", "Petrov", "Kozlov", "Volkov", "Morozov"
    }
    local rank = ranks[math.random(1, #ranks)]
    local init = alphabet[math.random(1, #alphabet)] .. ". " .. alphabet[math.random(1, #alphabet)] .. "."
    local surname = surnames[math.random(1, #surnames)]
    return rank .. " " .. init .. " " .. surname
end

-- 긴급 무전 문구 랜덤 생성
local function RandomBailoutString()
    local prefixes = {"I've lost control! ", "They got me! ", "Taking hits! ", "I'm hit! ", "Flight controls are gone! "}
    local suffixes = {"Going in!", "Going down!", "Eject, eject, eject!!!", "Bailing out!"}
    return prefixes[math.random(1, #prefixes)] .. suffixes[math.random(1, #suffixes)]
end

if destroyed_unit and destroyed_unit.type == "Aircraft" then
    math.randomseed(os.time())
    if PilotSurvives() then
        local lat, lon = destroyed_unit.latitude, destroyed_unit.longitude
        
        -- 격추 좌표 주변 반경 2nm 이내 랜덤 오프셋
        local circle = World_GetCircleFromPoint({latitude=lat, longitude=lon, radius=math.random(1, 2), numpoints=36})
        local offset = circle[math.random(1, #circle)]
        local spawn_lat, spawn_lon = offset.latitude, offset.longitude
        
        -- 바다/육지 판별
        local elevation = World_GetElevation({latitude=spawn_lat, longitude=spawn_lon})
        local survivor_type = 'Facility'
        local survivor_dbid = 2441 -- Stranded Person (육지)
        if elevation < 0 then
            survivor_type = 'Ship'
            survivor_dbid = 2553  -- Life Raft (바다)
        end
        
        local survivorName = GenerateSurvivorName()
        local survivor = ScenEdit_AddUnit({
            side = 'Downed Pilots',
            type = survivor_type,
            dbid = survivor_dbid,
            name = survivorName,
            latitude = spawn_lat,
            longitude = spawn_lon
        })
        
        if survivor then
            local msg = RandomBailoutString()
            local radio_msg = '<P>' .. survivorName .. ': "' .. msg .. '"</P>'
            ScenEdit_SpecialMessage(rescue_side, radio_msg, {latitude=spawn_lat, longitude=spawn_lon})
        end
    end
end
]==]

        {% if __config and __config.multi_file then %}
            {% 
               local sf_name = "events/" .. name .. "_action.lua"
               table.insert(__config.__side_files, { name = sf_name, content = __script })
               __script = "ScenEdit_RunScript('" .. run_script_path(__config, sf_name) .. "')"
            %}
        {% end %}

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: event " .. {{q(name)}})
    else
        print("ERROR: failed to create event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
