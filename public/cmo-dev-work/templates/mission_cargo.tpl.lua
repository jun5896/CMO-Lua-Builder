-- mission_cargo.tpl.lua
-- 컨텍스트: side, name, cargo_type ("air"|"sea"|...), pickup_rp, dropoff_rp,
--          cargo_items = { { type=..., dbid=..., guid=... }, ... }
do
    local __m = ScenEdit_AddMission({{q(side)}}, {{q(name)}}, "cargo", {
        type = {{q(cargo_type or "air")}}
    })
    if __m then
        __m.cargomission = {
            {% if pickup_rp then %}pickuppoint = {{q(pickup_rp)}},{% end %}
            {% if dropoff_rp then %}dropoffpoint = {{q(dropoff_rp)}},{% end %}
            {% if minimum_number then %}minimumnumber = {{minimum_number}},{% end %}
            {% if maximum_number then %}maximumnumber = {{maximum_number}},{% end %}
            {% if group_size then %}groupsize = {{group_size}},{% end %}
            {% if transit_altitude then %}transitaltitude = {{transit_altitude}},{% end %}
            {% if station_altitude then %}stationaltitude = {{station_altitude}},{% end %}
            {% if transit_depth then %}transitdepth = {{transit_depth}},{% end %}
            {% if station_depth then %}stationdepth = {{station_depth}},{% end %}
        }
        {% for _, c in ipairs(cargo_items or {}) do %}
        if __m.addAssignedCargo then
            __m:addAssignedCargo({{q(c.type or "mount")}}, {{c.dbid}}, {{q(c.guid or "")}})
        end
        {% end %}
        print("SUCCESS: created cargo mission " .. {{q(name)}})
    else
        print("ERROR: failed to create cargo mission " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

