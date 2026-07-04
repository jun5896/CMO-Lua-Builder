-- event_unit_x.tpl.lua
-- ScenEdit_UnitX() 를 동적으로 활용하는 이벤트 템플릿.
-- 트리거 종류: UnitDestroyed, TargetDamaged, UnitEntersArea 등
-- 컨텍스트: name, trigger_type, trigger_opts = {}, lua_script
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "")}},
        isactive     = true,
        isrepeatable = {{literal(default(isrepeatable, true))}},
        isshown      = {{literal(default(isshown, true))}},
    })
    if __evt then
        local __tname = {{q(name .. "_trig")}}
        ScenEdit_SetTrigger({ mode = "add", type = {{q(trigger_type)}}, name = __tname,
            {% for k, v in pairs(trigger_opts or {}) do %}{{k}} = {{lua_table(v, "            ")}},{% end %}
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = string.format([==[
local u = ScenEdit_UnitX()
if not u then
    ScenEdit_SpecialMessage("Console", "[cmo-lua-dev] Warning: ScenEdit_UnitX() returned nil in %q")
    return
end

-- User Script (has access to 'u')
%s
]==], {{q(name)}}, {{q(lua_script or "-- no user script provided")}})

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: unit_x event " .. {{q(name)}})
    else
        print("ERROR: failed to create unit_x event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
