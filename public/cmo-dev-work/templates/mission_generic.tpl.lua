-- mission_generic.tpl.lua
-- 알 수 없는 미션 종류 폴백.
do
    local __kind = {{q(kind or mission_type or "patrol")}}
    local __sub = {{q(mission_subtype or "land")}}
    local __m = ScenEdit_AddMission({{q(side)}}, {{q(name)}}, __kind, { type = __sub })
    if __m then
        print("SUCCESS: created " .. __kind .. " mission " .. {{q(name)}})
    else
        print("ERROR: failed to create " .. __kind .. " mission " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

