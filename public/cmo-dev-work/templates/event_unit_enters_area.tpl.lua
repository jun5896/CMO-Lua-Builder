-- event_unit_enters_area.tpl.lua
-- 컨텍스트: name, side, area_rps = { rp, ... }, target_filter, lua_script?
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, { isactive = true, isrepeatable = {{literal(default(isrepeatable, true))}} })
    if __evt then
        local __tname = {{q(name .. "_trig")}}
        local __area = {
            {% for _, rp in ipairs(area_rps or {}) do %}{{q(rp)}},{% end %}
        }
        ScenEdit_SetTrigger({ mode = "add", type = "UnitEntersArea", name = __tname,
            TargetFilter = {
                {% for k, v in pairs(target_filter or {}) do %}{{k}} = {{literal(v)}},{% end %}
            },
            Area = __area,
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })
        {% if lua_script then %}
        local __aname = {{q(name .. "_act")}}
        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = {{q(lua_script)}} })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        {% end %}
        print("SUCCESS: enters_area event " .. {{q(name)}})
    end
end

