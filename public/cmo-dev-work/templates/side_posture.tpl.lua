-- side_posture.tpl.lua
-- ScenEdit_SetSidePosture. 컨텍스트: side, postures = { { other_side, posture }, ... }
{% for _, p in ipairs(postures or {}) do %}
do
    local __ok = ScenEdit_SetSidePosture({{q(side)}}, {{q(p.other_side)}}, {{q(p.posture)}})
    if __ok then
        print("SUCCESS: " .. {{q(side)}} .. " -> " .. {{q(p.other_side)}} .. " = " .. {{q(p.posture)}})
    else
        print("ERROR: posture set failed for " .. {{q(p.other_side)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
{% end %}
