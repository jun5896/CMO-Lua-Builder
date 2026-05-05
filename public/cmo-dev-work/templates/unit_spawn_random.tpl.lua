-- unit_spawn_random.tpl.lua
-- 런타임에 수심/육지 체크를 수행하여 유효한 위치에 무작위로 유닛을 배치하는 템플릿.
-- 컨텍스트: side, name, type, dbid, loadoutid, terrain (sea/land), lat_min, lat_max, lon_min, lon_max, max_attempts
do
    local __aname = {{q(name)}}
    local __ok = false
    local max_attempts = {{max_attempts or 500}}
    local terrain = {{q(terrain or "sea")}}

    for i = 1, max_attempts do
        local lat = math.random() * ({{lat_max}} - {{lat_min}}) + {{lat_min}}
        local lon = math.random() * ({{lon_max}} - {{lon_min}}) + {{lon_min}}
        
        local valid = true
        local elev = World_GetElevation({ latitude = lat, longitude = lon })
        if elev then
            if terrain == "sea" and elev > -10 then valid = false end
            if terrain == "land" and elev < 0 then valid = false end
        end

        if valid then
            local __u = ScenEdit_AddUnit({
                side = {{q(side)}}, name = __aname, type = {{q(type)}}, dbid = {{dbid}},
                latitude = lat, longitude = lon,
                {% if loadoutid then %}loadoutid = {{loadoutid}},{% end %}
                {% if altitude then %}altitude = {{altitude}},{% end %}
                {% if heading then %}heading = {{heading}},{% end %}
                {% if speed then %}speed = {{speed}},{% end %}
            })
            if __u then
                print("SUCCESS: random spawn " .. __aname .. " at " .. lat .. ", " .. lon)
                __ok = true
                break
            end
        end
    end

    if not __ok then
        print("ERROR: failed to find valid random spawn for " .. __aname .. " after " .. max_attempts .. " attempts.")
    end
end
