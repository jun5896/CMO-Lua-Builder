-- doctrine_emcon.tpl.lua
-- ScenEdit_SetEMCON. 컨텍스트: side, unit?, value (예: "Inherit", "Radar=Active;Sonar=Passive")
do
    local __scope, __id
    {% if unit then %}
    local __u = ScenEdit_GetUnit({ name = {{q(unit)}}, side = {{q(side)}} })
    if __u then __scope = "Unit"; __id = __u.guid end
    {% else %}
    local __s = VP_GetSide({ side = {{q(side)}} })
    if __s then __scope = "Side"; __id = __s.guid end
    {% end %}
    if __scope then
        ScenEdit_SetEMCON(__scope, __id, {{q(value or "Inherit")}})
        print("SUCCESS: EMCON " .. __scope .. " = " .. {{q(value or "Inherit")}})
    else
        print("ERROR: EMCON target not found")
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

