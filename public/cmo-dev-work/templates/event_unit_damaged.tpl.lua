-- event_unit_damaged.tpl.lua
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, { isactive = true, isrepeatable = {{literal(default(isrepeatable, true))}} })
    if __evt then
        local __tname = {{q(name .. "_trig")}}
        ScenEdit_SetTrigger({ mode = "add", type = "UnitDamaged", name = __tname,
            TargetFilter = {
                TargetSide = {{q(side or "")}},
                TargetType = {{target_type_id or 0}},
                SpecificUnitClass = {{target_dbid or 0}},
            },
            DamagePercent = {{damage_percent or 50}},
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })
        {% if lua_script then %}
        local __aname = {{q(name .. "_act")}}
        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = {{q(lua_script)}} })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        {% end %}
        print("SUCCESS: damaged event " .. {{q(name)}})
    end
end

