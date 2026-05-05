-- event_teleport.tpl.lua
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Teleport Units")}},
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
local targets = {{lua_table(target_guids or {}, "")}}
local lat_min = {{lat_min or 0}}
local lat_max = {{lat_max or 0}}
local lon_min = {{lon_min or 0}}
local lon_max = {{lon_max or 0}}

for _, guid in ipairs(targets) do
    local unit = ScenEdit_GetUnit({guid=guid})
    if unit then
        local valid = false
        local attempts = 0
        local new_lat, new_lon
        
        while not valid and attempts < 100 do
            new_lat = lat_min + (math.random() * (lat_max - lat_min))
            new_lon = lon_min + (math.random() * (lon_max - lon_min))
            
            local elevation = World_GetElevation({latitude=new_lat, longitude=new_lon})
            local over_water = (elevation < 0)
            
            if {{literal(default(require_water, false))}} then
                if over_water then valid = true end
            elseif {{literal(default(require_land, false))}} then
                if not over_water then valid = true end
            else
                valid = true
            end
            attempts = attempts + 1
        end
        
        if valid then
            ScenEdit_SetUnit({guid=guid, latitude=new_lat, longitude=new_lon})
        end
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
