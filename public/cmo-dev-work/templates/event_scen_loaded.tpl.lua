-- event_scen_loaded.tpl.lua
-- 시나리오 시작/로드 시 1회 실행. BrassDrum LuaInit 패턴 부트스트랩에 적합.
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, { isactive = true, isrepeatable = false })
    if __evt then
        local __tname = {{q(name .. "_trig")}}
        ScenEdit_SetTrigger({ mode = "add", type = "ScenLoaded", name = __tname })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_act")}}
        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = {{q(lua_script or "")}} })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: scen_loaded event " .. {{q(name)}})
    end
end

