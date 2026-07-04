-- event_scramble.tpl.lua
-- 특정 트리거 발생 시 대기 중인 유닛들의 로드아웃을 즉시(TimeToReady_Minutes=0) 변경하여 지정 미션에 투입하는 긴급 스크램블 이벤트.
-- 컨텍스트: name, trigger = { type, name, opts }, side?, units = {}, loadout_dbid, mission, time_to_ready?
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Emergency scramble event")}},
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
local units = {{lua_table(units or {}, "")}}
local loadout_dbid = {{loadout_dbid or 0}}
local mission = {{q(mission or "")}}
local side = {{q(side or "")}}
local time_to_ready = {{time_to_ready or 0}}

for _, unit_id in ipairs(units) do
    local u = ScenEdit_GetUnit({guid = unit_id})
    if not u and side ~= "" then
        u = ScenEdit_GetUnit({side = side, name = unit_id})
    end
    if not u then
        u = ScenEdit_GetUnit({name = unit_id})
    end
    if u then
        ScenEdit_SetLoadout({
            unitName = u.guid,
            loadoutid = loadout_dbid,
            TimeToReady_Minutes = time_to_ready
        })
        if mission ~= "" then
            ScenEdit_AssignUnitToMission(u.guid, mission)
        end
    else
        print("WARNING: scramble unit not found: " .. tostring(unit_id))
    end
end

{% if message then %}
ScenEdit_SpecialMessage({{q(message.side or "Blue")}}, {{q(message.text)}})
{% end %}
]==]

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: scramble event " .. {{q(name)}})
    else
        print("ERROR: failed to create scramble event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
