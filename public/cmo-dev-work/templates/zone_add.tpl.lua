-- zone_add.tpl.lua
-- ScenEdit_AddNoNavZone or ScenEdit_AddExclusionZone.
-- 컨텍스트: side, name, kind ("nonav" 기본 / "exclusion"), area = { rp1, rp2, ... }
do
    local __area = {
        {% for _, rp_name in ipairs(area or {}) do %}
        {{q(rp_name)}},
        {% end %}
    }
    {% if (kind or "nonav") == "exclusion" then %}
    local __ok = ScenEdit_AddExclusionZone({{q(side)}}, {{q(name)}}, {
        area = __area,
        {% if affects then %}affects = {{literal(affects)}},{% end %}
    })
    {% else %}
    local __ok = ScenEdit_AddNoNavZone({{q(side)}}, {{q(name)}}, {
        area = __area,
        {% if isactive ~= nil then %}isactive = {{literal(isactive)}},{% end %}
    })
    {% end %}
    if __ok then
        print("SUCCESS: added zone " .. {{q(name)}})
    else
        print("ERROR: failed to add zone " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

