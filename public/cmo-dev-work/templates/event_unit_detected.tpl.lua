-- event_unit_detected.tpl.lua
-- 컨텍스트: name, detector_side, target_filter = { TargetSide, TargetType, ... }
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, { isactive = true, isrepeatable = true })
    if __evt then
        local __tname = {{q(name .. "_trig")}}
        ScenEdit_SetTrigger({ mode = "add", type = "UnitDetected", name = __tname,
            DetectorSideID = {{q(detector_side or "")}},
            TargetFilter = {
                {% for k, v in pairs(target_filter or {}) do %}{{k}} = {{literal(v)}},{% end %}
            },
            MCL = {{mcl or 1}},
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })
        {% if lua_script then %}
        local __aname = {{q(name .. "_act")}}
        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = {{q(lua_script)}} })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        {% end %}
        print("SUCCESS: detected event " .. {{q(name)}})
    end
end

