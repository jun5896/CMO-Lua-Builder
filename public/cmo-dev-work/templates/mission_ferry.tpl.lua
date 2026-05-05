-- mission_ferry.tpl.lua
-- 컨텍스트: side, name, ferry_type, embarkation_rp, destination_rp, one_way?
do
    local __m = ScenEdit_AddMission({{q(side)}}, {{q(name)}}, "ferry", {
        type = {{q(ferry_type or "air")}}
    })
    if __m then
        __m.ferrymission = {
            {% if embarkation_rp then %}embarkationpoint = {{q(embarkation_rp)}},{% end %}
            {% if destination_rp then %}destinationpoint = {{q(destination_rp)}},{% end %}
            {% if one_way ~= nil then %}oneway = {{literal(one_way)}},{% end %}
            {% if minimum_number then %}minimumnumber = {{minimum_number}},{% end %}
            {% if maximum_number then %}maximumnumber = {{maximum_number}},{% end %}
            {% if group_size then %}groupsize = {{group_size}},{% end %}
            {% if transit_altitude then %}transitaltitude = {{transit_altitude}},{% end %}
            {% if station_altitude then %}stationaltitude = {{station_altitude}},{% end %}
            {% if transit_depth then %}transitdepth = {{transit_depth}},{% end %}
            {% if station_depth then %}stationdepth = {{station_depth}},{% end %}
        }
        print("SUCCESS: created ferry mission " .. {{q(name)}})
    else
        print("ERROR: failed to create ferry mission " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

