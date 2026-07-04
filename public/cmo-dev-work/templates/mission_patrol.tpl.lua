-- mission_patrol.tpl.lua
-- 컨텍스트: side, name, patrol_type, patrol_zone_rps = { rp1, rp2, ... }
do
    local __valid = { AAW=true, ASW=true, ASuW=true, SEAD=true,
                      ["Sea Control"]=true, Naval=true, Land=true }
    local __ptype = {{q(patrol_type or "ASW")}}
    if not __valid[__ptype] then
        print("WARNING: invalid patrol_type, falling back to ASW")
        __ptype = "ASW"
    end
    local __m = ScenEdit_AddMission({{q(side)}}, {{q(name)}}, "patrol", { type = __ptype })
    if __m then
        {% include "rp_lookup" with { rps = patrol_zone_rps, side = side, list_var = "__rps" } %}
        if #__rps > 0 then
            __m.patrolmission = {
                patrolzone = __rps,
                {% if oneThirdRule then %}oneThirdRule = {{literal(oneThirdRule)}},{% end %}
                {% if checkOPA then %}checkOPA = {{literal(checkOPA)}},{% end %}
                {% if active_em then %}activeem = {{literal(active_em)}},{% end %}
            }
        end
        print("SUCCESS: created patrol mission " .. {{q(name)}})
    else
        print("ERROR: failed to create patrol mission " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

