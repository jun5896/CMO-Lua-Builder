-- event_radio_message.tpl.lua
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Military Radio Message")}},
        isactive     = true,
        isrepeatable = false,
        isshown      = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trigger")}}
        ScenEdit_SetTrigger({ mode = "add", type = "RegularTime", name = __tname, interval = {{interval or 60}} })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local function DTG()
    local time_var = ScenEdit_CurrentTime()
    return string.upper(os.date("!%d%H%M Z %b %y", time_var))
end

local msg_type = {{q(msg_type or "radio")}}
local body = {{q(body or "No message")}}
local side = {{q(side or "playerside")}}

if msg_type == 'telex' then
    local sig_string = string.upper('<P><FONT face=Consolas>' .. {{q(rec_station or "ALL")}} .. ' <BR>' ..
    'DE ' .. {{q(snd_station or "HQ")}} .. ' <BR>' ..
    {{q(precedence or "R")}} .. ' ' .. DTG() .. ' <BR>' ..
    'fm ' .. {{q(from or "COMMAND")}} .. ' <BR>' ..
    'to ' .. {{q(to or "ALL STATIONS")}} .. ' <BR>' ..
    'bt <BR>' ..
    {{q(classification or "UNCLASS")}} .. ' <BR>' ..
    body .. ' <BR>' ..
    'bt <BR>nnnn </P>')
    ScenEdit_SpecialMessage(side, sig_string)
else
    local msg = "<P>" .. DTG() .. ' <BR>' .. {{q(band or "VHF")}} .. ' <BR>' .. {{q(freq or "121.5 MHz")}} .. ' </P><P><I>"' .. body .. '"</I></P>'
    ScenEdit_SpecialMessage(side, msg)
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
