-- event_unit_destroyed.tpl.lua
-- ChumonchinChan/NK_UnitDestroyed.lua 패턴 기반.
-- 컨텍스트: name, target_dbid, target_type, points, side, on_destroyed_message
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        isactive = true, isrepeatable = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trig")}}
        ScenEdit_SetTrigger({ mode = "add", type = "UnitDestroyed", name = __tname,
            TargetFilter = {
                TargetSide = {{q(side or "")}},
                TargetType = {{target_type_id or 4}},
                TargetSubType = {{target_subtype or 0}},
                SpecificUnitClass = {{target_dbid or 0}},
            },
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_act")}}
        local __script = string.format([==[
local pts = ScenEdit_GetScore(%q) or 0
ScenEdit_SetScore(%q, pts + %d, %q)
ScenEdit_SpecialMessage(%q, %q)
]==], {{q(side or "")}}, {{q(side or "")}}, {{points or 0}}, {{q(name)}},
            {{q(side or "")}}, {{q(on_destroyed_message or "Target destroyed.")}})
        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: unit_destroyed event " .. {{q(name)}})
    end
end

