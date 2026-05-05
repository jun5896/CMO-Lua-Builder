-- event_contact_emcon.tpl.lua
-- side:contactsBy() 우선, ScenEdit_GetContacts() 폴백으로 contact 조건 만족 시 EMCON 변경.
-- 컨텍스트: name, trigger = { name, opts }, side, target_type?, target_posture?, emcon = { type, id, value }, message = { text }
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Contact check and EMCON update")}},
        isactive     = true,
        isrepeatable = {{literal(default(isrepeatable, false))}},
        isshown      = {{literal(default(isshown, true))}},
    })
    if __evt then
        ScenEdit_SetTrigger({ mode = "add", type = "RegularTime", name = {{q(trigger.name)}},
            {% for k, v in pairs(trigger.opts or { Interval = 15 }) do %}{{k}} = {{lua_table(v, "            ")}},{% end %}
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = {{q(trigger.name)}} })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local side_name = {{q(side or "Blue")}}
local target_type = {{q(target_type or "")}}
local target_posture = {{q(target_posture or "H")}}

local function collect_contacts()
    local contacts = {}
    if type(VP_GetSide) == "function" then
        local ok_side, side_wrapper = pcall(VP_GetSide, {side = side_name})
        if ok_side and side_wrapper and type(side_wrapper.contactsBy) == "function" and target_type ~= "" then
            local ok_contacts, result = pcall(function() return side_wrapper:contactsBy(target_type) end)
            if ok_contacts and type(result) == "table" then
                contacts = result
            end
        end
    end
    if next(contacts) == nil and type(ScenEdit_GetContacts) == "function" then
        local ok_contacts, result = pcall(ScenEdit_GetContacts, side_name)
        if ok_contacts and type(result) == "table" then
            contacts = result
        end
    end
    return contacts
end

local contacts = collect_contacts()
local found = false
if contacts then
    for _, c in pairs(contacts) do
        local posture = tostring(c.posture or c.Posture or "")
        if target_posture == "" or posture == target_posture then
            found = true
            break
        end
    end
end

if found then
    ScenEdit_SetEMCON({{q((emcon and emcon.type) or "Side")}}, {{q((emcon and emcon.id) or side or "Blue")}}, {{q((emcon and emcon.value) or "Inherit")}})
    {% if message then %}
    ScenEdit_SpecialMessage({{q(side or "Blue")}}, {{q(message.text)}})
    {% end %}
end
]==]

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: contact_emcon event " .. {{q(name)}})
    else
        print("ERROR: failed to create contact_emcon event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
