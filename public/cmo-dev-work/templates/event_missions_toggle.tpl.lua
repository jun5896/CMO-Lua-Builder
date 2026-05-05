-- event_missions_toggle.tpl.lua
-- 특정 트리거 발생 시 미션 목록을 일괄 활성화/비활성화.
-- 컨텍스트: name, trigger = { type, name, opts }, side, activate_missions = {}, deactivate_missions = {}
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Mission toggle event")}},
        isactive     = true,
        isrepeatable = {{literal(default(isrepeatable, false))}},
        isshown      = {{literal(default(isshown, true))}},
    })
    if __evt then
        ScenEdit_SetTrigger({ mode = "add", type = {{q(trigger.type)}}, name = {{q(trigger.name)}},
            {% for k, v in pairs(trigger.opts or {}) do %}{{k}} = {{lua_table(v, "            ")}},{% end %}
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = {{q(trigger.name)}} })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local side = {{q(side or "Blue")}}

-- Activate missions
{% for _, m in ipairs(activate_missions or {}) do %}
ScenEdit_SetMission(side, {{q(m)}}, { isactive = true })
{% end %}

-- Deactivate missions
{% for _, m in ipairs(deactivate_missions or {}) do %}
ScenEdit_SetMission(side, {{q(m)}}, { isactive = false })
{% end %}

{% if message then %}
ScenEdit_SpecialMessage(side, {{q(message.text)}})
{% end %}
]==]

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: missions_toggle event " .. {{q(name)}})
    else
        print("ERROR: failed to create missions_toggle event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
