-- event_simple.tpl.lua
-- 단일 트리거 + LuaScript 액션 이벤트.
-- 컨텍스트: name, trigger = { type, name, opts }, lua_script (string)
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "")}},
        isactive     = true,
        isrepeatable = {{literal(default(isrepeatable, false))}},
        isshown      = {{literal(default(isshown, true))}},
    })
    if __evt then
        ScenEdit_SetTrigger({ mode = "add", type = {{q(trigger.type)}}, name = {{q(trigger.name)}},
            {% for k, v in pairs(trigger.opts or {}) do %}{{k}} = {{lua_table(v, "            ")}},{% end %}
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = {{q(trigger.name)}} })

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = {{q(name .. "_action")}},
            scripttext = {{q(lua_script)}}
        })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = {{q(name .. "_action")}} })
        print("SUCCESS: simple event " .. {{q(name)}})
    else
        print("ERROR: failed to create event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

