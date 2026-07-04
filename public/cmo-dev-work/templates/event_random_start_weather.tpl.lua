-- event_random_start_weather.tpl.lua
-- 시나리오 시작 시 한 번만 기상을 무작위로 설정
-- RegularTime(1초) + KeyValue guard 방식으로 안전하게 1회 실행 보장
-- (ScenLoaded 트리거가 일부 버전에서 불안정할 수 있어 안전한 패턴 사용)
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Random Starting Weather Setup")}},
        isactive     = true,
        isrepeatable = true,
        isshown      = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trigger")}}
        ScenEdit_SetTrigger({ mode = "add", type = "RegularTime", name = __tname, interval = 1 })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
-- 한 번만 실행되도록 KeyValue guard
local kv_key = 'random_weather_done'
if ScenEdit_GetKeyValue(kv_key) == 'true' then return end
ScenEdit_SetKeyValue(kv_key, 'true')

local t_min, t_max = {{temp_min or 15}}, {{temp_max or 25}}
local r_min, r_max = {{rain_min or 0}}, {{rain_max or 0}}
local c_min, c_max = {{cloud_min or 0.0}}, {{cloud_max or 0.3}}
local s_min, s_max = {{sea_min or 0}}, {{sea_max or 2}}

math.randomseed(os.time())
local newTemp = math.random(t_min, t_max)
local newRain = math.random(r_min, r_max)
local newCloud = c_min + (math.random() * (c_max - c_min))
local newSea = math.random(s_min, s_max)

ScenEdit_SetWeather(newTemp, newRain, newCloud, newSea)
ScenEdit_SpecialMessage('playerside', "Meteorological Dept: Initial weather conditions have been randomized.")
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
