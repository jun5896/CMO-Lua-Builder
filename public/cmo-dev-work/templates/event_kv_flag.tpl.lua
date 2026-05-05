-- event_kv_flag.tpl.lua
-- KeyValue 상태 플래그 기반 1회성 이벤트 템플릿.
-- 컨텍스트: name, trigger = { type, name, opts }, kv_key, lua_script
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "")}},
        isactive     = true,
        isrepeatable = true, -- 내부 플래그로 중복 실행을 막으므로 true 권장
        isshown      = {{literal(default(isshown, true))}},
    })
    if __evt then
        ScenEdit_SetTrigger({ mode = "add", type = {{q(trigger.type)}}, name = {{q(trigger.name)}},
            {% for k, v in pairs(trigger.opts or {}) do %}{{k}} = {{lua_table(v, "            ")}},{% end %}
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = {{q(trigger.name)}} })

        local __aname = {{q(name .. "_action")}}
        local __script = string.format([==[
local _key = %q
if ScenEdit_GetKeyValue(_key) == "1" then return end

-- User Script
%s

-- Set flag
ScenEdit_SetKeyValue(_key, "1")
]==], {{q(kv_key)}}, {{q(lua_script or "-- no user script provided")}})

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: kv_flag event " .. {{q(name)}})
    else
        print("ERROR: failed to create kv_flag event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
