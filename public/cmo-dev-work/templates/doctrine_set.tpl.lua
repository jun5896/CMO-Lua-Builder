-- doctrine_set.tpl.lua
-- ScenEdit_SetDoctrine. 컨텍스트: side, unit?, settings = { key=value, ... }
do
    {% if unit then %}
    local __u = ScenEdit_GetUnit({ name = {{q(unit)}}, side = {{q(side)}} })
    if __u then
        ScenEdit_SetDoctrine({ guid = __u.guid }, {
            {% for k, v in pairs(settings or {}) do %}{{k}} = {{literal(v)}},{% end %}
        })
        print("SUCCESS: doctrine set on " .. {{q(unit)}})
    else
        print("ERROR: unit not found: " .. {{q(unit)}})
    end
    {% else %}
    ScenEdit_SetDoctrine({ side = {{q(side)}} }, {
        {% for k, v in pairs(settings or {}) do %}{{k}} = {{literal(v)}},{% end %}
    })
    print("SUCCESS: doctrine set on side " .. {{q(side)}})
    {% end %}
end

