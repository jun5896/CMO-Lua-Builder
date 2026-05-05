-- event_logistics.tpl.lua
-- 보급/탄약 제어 (Logistics Control) 스크립트
-- 공식 API: ScenEdit_ClearAllMagazines() (v1143.1+), ScenEdit_DistributeWeaponAtAirbase()
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Logistics Control Event")}},
        isactive     = true,
        isrepeatable = true,
        isshown      = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trigger")}}
        ScenEdit_SetTrigger({ mode = "add", type = "RegularTime", name = __tname, interval = {{interval or 3600}} })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local target_id = {{q(base_id or base_name or "")}}
local side = {{q(side or "playerside")}}
local mode = {{q(logistics_mode or "clear")}}
local weapon_dbid = {{weapon_dbid or 0}}
local quantity = {{quantity or 0}}

-- GUID 우선, Name 폴백
local base = ScenEdit_GetUnit({guid=target_id})
if not base then
    base = ScenEdit_GetUnit({side=side, name=target_id})
end

if base then
    if mode == "clear" then
        -- 공식 API: 특정 유닛의 모든 탄약고를 비움
        ScenEdit_ClearAllMagazines({guid=base.guid})
        ScenEdit_SpecialMessage(side, "All magazines at " .. base.name .. " have been emptied.")
    elseif mode == "distribute" and weapon_dbid > 0 then
        -- 공식 API: 특정 공항에 무장을 분배
        ScenEdit_DistributeWeaponAtAirbase(base.guid, weapon_dbid, quantity)
        ScenEdit_SpecialMessage(side, "A supply of weapons (DBID " .. weapon_dbid .. " x" .. quantity .. ") has arrived at " .. base.name .. ".")
    end
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
