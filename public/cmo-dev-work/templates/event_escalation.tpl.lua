-- event_escalation.tpl.lua
-- ROE 및 긴장도 에스컬레이션 템플릿. 트리거 시 Posture 와 Doctrine 을 일괄 변경.
-- 컨텍스트: name, trigger = { type, name, opts }, postures = {}, doctrines = {}, message = { side, text }
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Escalation event")}},
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
-- Posture changes
{% for _, p in ipairs(postures or {}) do %}
ScenEdit_SetSidePosture({{q(p.side)}}, {{q(p.other_side)}}, {{q(p.posture)}})
{% end %}

-- Doctrine changes
{% for _, d in ipairs(doctrines or {}) do %}
ScenEdit_SetDoctrine({ side = {{q(d.side)}} }, {{lua_table(d.settings, "")}})
{% end %}

{% if message then %}
ScenEdit_SpecialMessage({{q(message.side)}}, {{q(message.text)}})
{% end %}
]==]

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: escalation event " .. {{q(name)}})
    else
        print("ERROR: failed to create escalation event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
