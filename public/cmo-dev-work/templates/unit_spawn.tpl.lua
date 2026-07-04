-- unit_spawn.tpl.lua
-- ScenEdit_AddUnit. 번들 샘플 컨벤션에 맞춰 lat/lon 키 사용.
-- 컨텍스트: side, name, type, dbid, lat, lon, alt?, heading?, speed?, loadout?
do
    local __unit = ScenEdit_AddUnit({
        side    = {{q(side)}},
        name    = {{q(name)}},
        type    = {{q(type or "Aircraft")}},
        dbid    = {{dbid}},
        lat     = {{lat or latitude or 0}},
        lon     = {{lon or longitude or 0}},
        {% if alt or altitude then %}altitude = {{alt or altitude}},{% end %}
        {% if heading then %}heading = {{heading}},{% end %}
        {% if speed then %}speed = {{speed}},{% end %}
        {% if loadout then %}loadoutid = {{loadout}},{% end %}
        {% if base then %}base = {{q(base)}},{% end %}
    })
    if __unit then
        print("SUCCESS: spawned " .. {{q(name)}} .. " (dbid " .. {{dbid}} .. ")")
    else
        print("ERROR: failed to spawn " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

