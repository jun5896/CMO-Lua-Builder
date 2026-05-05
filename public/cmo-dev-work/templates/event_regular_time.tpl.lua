-- event_regular_time.tpl.lua
-- BrassDrum 류의 Hourly/주기적 액션.
-- 컨텍스트: name, interval (초), lua_script
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, { isactive = true, isrepeatable = true })
    if __evt then
        local __tname = {{q(name .. "_trig")}}
        ScenEdit_SetTrigger({ mode = "add", type = "RegularTime", name = __tname,
            Interval = {{interval or 3600}},
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_act")}}
        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = {{q(lua_script or "")}} })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: regular_time event " .. {{q(name)}})
    end
end

