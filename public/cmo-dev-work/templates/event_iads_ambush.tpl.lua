-- event_iads_ambush.tpl.lua
-- IADS Ambush event.
-- Monitors one or more SAM/radar units and switches their radar EMCON
-- between Passive and Active when selected contact types enter engage range.
-- Context:
--   unit_ids     = { "SAM name or GUID", "Radar name or GUID" }
--   target_types = { "Aircraft", "Missile" }
-- Backward compatible aliases:
--   unit_id, unit_name, target_type
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "IADS Ambush Event")}},
        isactive     = true,
        isrepeatable = true,
        isshown      = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trigger")}}
        ScenEdit_SetTrigger({ mode = "add", type = "RegularTime", name = __tname, interval = {{interval or 5}} })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local unit_ids = {{lua_table(unit_ids or unit_names or units or {}, "")}}
local legacy_unit_id = {{q(unit_id or unit_name or "")}}
local target_types = {{lua_table(target_types or {}, "")}}
local legacy_target_type = {{q(target_type or "")}}
local engage_range = {{engage_range or 40}}
local side = {{q(side or "RED")}}

local function normalize_list(value, fallback)
    if type(value) ~= "table" then
        if value == nil or value == "" then
            return fallback or {}
        end
        return { value }
    end

    local list = {}
    for _, item in ipairs(value) do
        if item ~= nil and tostring(item) ~= "" then
            list[#list + 1] = tostring(item)
        end
    end
    if #list == 0 and fallback then return fallback end
    return list
end

unit_ids = normalize_list(unit_ids, legacy_unit_id ~= "" and { legacy_unit_id } or {})
target_types = normalize_list(target_types, legacy_target_type ~= "" and { legacy_target_type } or { "Aircraft" })

local type_filter = {}
for _, contact_type in ipairs(target_types) do
    type_filter[tostring(contact_type)] = true
    type_filter[string.lower(tostring(contact_type))] = true
end

local function resolve_unit(unit_id)
    local unit = ScenEdit_GetUnit({guid = unit_id})
    if not unit then
        unit = ScenEdit_GetUnit({side = side, name = unit_id})
    end
    if not unit then
        unit = ScenEdit_GetUnit({name = unit_id})
    end
    return unit
end

local function add_contact(contacts, seen, contact)
    if type(contact) ~= "table" then return end
    local key = contact.guid or contact.actualunitid or contact.actualUnitID or tostring(contact)
    if key and not seen[key] then
        seen[key] = true
        contacts[#contacts + 1] = contact
    end
end

local function contact_matches_type(contact)
    local contact_type = tostring(contact.type or contact.Type or contact.contacttype or contact.ContactType or "")
    if contact_type == "" then
        -- Some ScenEdit_GetContacts() wrappers do not expose type consistently.
        -- Keep the contact rather than silently missing a valid threat.
        return true
    end
    return type_filter[contact_type] or type_filter[string.lower(contact_type)] or false
end

local function collect_contacts()
    local contacts = {}
    local seen = {}
    if type(VP_GetSide) == "function" then
        local ok_side, side_wrapper = pcall(VP_GetSide, {side = side})
        if ok_side and side_wrapper and type(side_wrapper.contactsBy) == "function" then
            for _, contact_type in ipairs(target_types) do
                local ok_contacts, result = pcall(function()
                    return side_wrapper:contactsBy(contact_type)
                end)
                if ok_contacts and type(result) == "table" then
                    for _, contact in pairs(result) do
                        add_contact(contacts, seen, contact)
                    end
                end
            end
        end
    end
    if next(contacts) == nil and type(ScenEdit_GetContacts) == "function" then
        local ok_contacts, result = pcall(ScenEdit_GetContacts, side)
        if ok_contacts and type(result) == "table" then
            for _, contact in pairs(result) do
                if contact_matches_type(contact) then
                    add_contact(contacts, seen, contact)
                end
            end
        end
    end
    return contacts
end

local contacts = collect_contacts()

for _, unit_id in ipairs(unit_ids) do
    local unit = resolve_unit(unit_id)
    if unit then
        local kv_key = 'iads_emcon_' .. unit.guid
        local current_state = ScenEdit_GetKeyValue(kv_key)
        if current_state == '' then current_state = 'passive' end

        local target_in_range = false
        if contacts then
            for _, contact in pairs(contacts) do
                local contact_guid = contact.actualunitid or contact.actualUnitID or contact.guid
                local dist = contact_guid and Tool_Range(unit.guid, contact_guid)
                if dist and dist <= engage_range then
                    target_in_range = true
                    break
                end
            end
        end

        if target_in_range and current_state == 'passive' then
            ScenEdit_SetEMCON('Unit', unit.guid, 'Radar=Active')
            ScenEdit_SetKeyValue(kv_key, 'active')
        elseif not target_in_range and current_state == 'active' then
            ScenEdit_SetEMCON('Unit', unit.guid, 'Radar=Passive')
            ScenEdit_SetKeyValue(kv_key, 'passive')
        end
    else
        print("WARNING: IADS unit not found: " .. tostring(unit_id))
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
