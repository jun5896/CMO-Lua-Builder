-- loadout_set.tpl.lua
-- ScenEdit_SetLoadout. 컨텍스트: unit, side?, dbid, time_to_ready?
do
    local __unit_id = {{q(unit)}}
    local __u = ScenEdit_GetUnit({ guid = __unit_id })
    if not __u and {{q(side or "")}} ~= "" then
        __u = ScenEdit_GetUnit({ side = {{q(side or "")}}, name = __unit_id })
    end
    if not __u then
        __u = ScenEdit_GetUnit({ name = __unit_id })
    end
    if __u then
        ScenEdit_SetLoadout({
            unitName = __u.guid,
            loadoutid = {{dbid}},
            {% if time_to_ready then %}TimeToReady_Minutes = {{time_to_ready}},{% end %}
        })
        print("SUCCESS: loadout " .. tostring({{dbid}}) .. " set on " .. {{q(unit)}})
    else
        print("ERROR: unit not found for loadout: " .. {{q(unit)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

