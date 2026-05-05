-- mission_mine.tpl.lua
-- 컨텍스트: side, name, mine_type, minefield_area_rps = { rp, ... }
do
    local __m = ScenEdit_AddMission({{q(side)}}, {{q(name)}}, "mine", {
        type = {{q(mine_type or "naval")}}
    })
    if __m then
        {% include "rp_lookup" with { rps = minefield_area_rps, side = side, list_var = "__rps" } %}
        if #__rps > 0 then
            __m.minemission = {
                minefieldarea = __rps,
                {% if density then %}density = {{q(density)}},{% end %}
                {% if number_of_mines then %}numberofmines = {{number_of_mines}},{% end %}
                {% if randomize ~= nil then %}randomize = {{literal(randomize)}},{% end %}
            }
        end
        print("SUCCESS: created mine mission " .. {{q(name)}})
    else
        print("ERROR: failed to create mine mission " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

