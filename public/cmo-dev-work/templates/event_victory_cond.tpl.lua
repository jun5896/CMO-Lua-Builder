-- event_victory_cond.tpl.lua
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Victory Condition Check")}},
        isactive     = true,
        isrepeatable = false,
        isshown      = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trigger")}}
        ScenEdit_SetTrigger({ mode = "add", type = "RegularTime", name = __tname, interval = {{interval or 15}} })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local function evaluate_victory()
    {{check_logic or "return true"}}
end

if evaluate_victory() then
    local new_score = ScenEdit_GetScore({{q(side or "playerside")}}) + {{points or 100}}
    ScenEdit_SetScore({{q(side or "playerside")}}, new_score, 'Victory Condition Met')
    ScenEdit_SpecialMessage({{q(side or "playerside")}}, '<P><b>VICTORY CONDITION MET</b><br/>{{message or "Objective Achieved!"}}</P>')
    
    if {{literal(default(end_scenario, false))}} then
        ScenEdit_EndScenario()
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
