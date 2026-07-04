-- event_ambient_traffic.tpl.lua
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Ambient Traffic Spawner")}},
        isactive     = true,
        isrepeatable = false,
        isshown      = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trigger")}}
        ScenEdit_SetTrigger({ mode = "add", type = "RegularTime", name = __tname, interval = {{interval or 600}} })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local dbids = {{dbid_list or "{2024, 2696, 1475, 775, 2775, 1002}"}}
local amount = {{amount or 5}}
local lat_min = {{lat_min or 0}}
local lat_max = {{lat_max or 0}}
local lon_min = {{lon_min or 0}}
local lon_max = {{lon_max or 0}}

for i = 1, amount do
    local random_dbid = dbids[math.random(1, #dbids)]
    local new_lat = lat_min + (math.random() * (lat_max - lat_min))
    local new_lon = lon_min + (math.random() * (lon_max - lon_min))
    
    local elevation = World_GetElevation({latitude=new_lat, longitude=new_lon})
    if elevation < 0 then
        local unit = ScenEdit_AddUnit({
            side = 'Civilian',
            type = 'Ship',
            name = 'Civilian Traffic ' .. math.random(1000, 9999),
            dbid = random_dbid,
            latitude = new_lat,
            longitude = new_lon
        })
        if unit then
            ScenEdit_SetUnit({guid=unit.guid, heading=math.random(0,359), speed=math.random(5, 15)})
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
