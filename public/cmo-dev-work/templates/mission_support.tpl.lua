-- mission_support.tpl.lua
-- 컨텍스트: side, name, support_type, support_area_rps = { rp, ... }
do
    local __m = ScenEdit_AddMission({{q(side)}}, {{q(name)}}, "support", {
        type = {{q(support_type or "air")}}
    })
    if __m then
        {% include "rp_lookup" with { rps = support_area_rps, side = side, list_var = "__rps" } %}
        if #__rps > 0 then
            __m.supportmission = {
                supportzone = __rps,
                {% if one_third_rule ~= nil then %}onethirdrule = {{literal(one_third_rule)}},{% end %}
                {% if transit_altitude then %}transitaltitude = {{transit_altitude}},{% end %}
                {% if station_altitude then %}stationaltitude = {{station_altitude}},{% end %}
                {% if loop_type then %}looptype = {{q(loop_type)}},{% end %}
                {% if loop_length then %}looplength = {{loop_length}},{% end %}
                {% if loop_width then %}loopwidth = {{loop_width}},{% end %}
            }
        end
        print("SUCCESS: created support mission " .. {{q(name)}})
    else
        print("ERROR: failed to create support mission " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

