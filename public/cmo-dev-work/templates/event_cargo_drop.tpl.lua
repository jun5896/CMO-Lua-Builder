-- event_cargo_drop.tpl.lua
-- 화물 하역 (Cargo Drop) 스크립트
-- 수송기/헬기가 지정 구역에 도달하면 ScenEdit_UnloadCargo()로 화물 하역
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Cargo Drop Event")}},
        isactive     = true,
        isrepeatable = false,
        isshown      = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trigger")}}
        ScenEdit_SetTrigger({
            mode = "add",
            type = "UnitEntersArea",
            name = __tname,
            targetfilter = { TargetSide = {{q(side)}}, TargetName = {{q(unit_id or unit_name or "")}} },
            area = {{drop_zone or "{}"}}
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local target_id = {{q(unit_id or unit_name or "")}}
local side = {{q(side or "playerside")}}

-- GUID 우선, Name 폴백
local unit = ScenEdit_GetUnit({guid=target_id})
if not unit then
    unit = ScenEdit_GetUnit({side=side, name=target_id})
end

if unit then
    -- ScenEdit_UnloadCargo expects the source unit name or GUID.
    ScenEdit_UnloadCargo(unit.guid)
    ScenEdit_SpecialMessage(side, unit.name .. " has successfully dropped its cargo in the designated zone.")
end
]==]

        {% if __config and __config.multi_file then %}
            {% 
               local sf_name = "events/" .. name .. "_action.lua"
               table.insert(__config.__side_files, { name = sf_name, content = __script })
               __script = "ScenEdit_RunScript('" .. run_script_path(__config, sf_name) .. "')"
            %}
        {% end %}

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: event " .. {{q(name)}})
    else
        print("ERROR: failed to create event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
