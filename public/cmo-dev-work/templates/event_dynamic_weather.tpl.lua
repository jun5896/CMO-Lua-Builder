-- event_dynamic_weather.tpl.lua
-- 동적 기상 변화 (Drift) 스크립트
-- 기준점(Baseline)으로부터 지정된 변동폭 이내에서 기상이 점진적으로 요동
-- 공식 API: ScenEdit_SetWeather(temperature, rainfall, undercloud, seastate)
-- 파라미터 범위: temp(자유), rainfall(0-50), undercloud(0.0-1.0), seastate(0-9)
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Dynamic Weather Event")}},
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
local base_temp = {{base_temp or 15}}
local base_rain = {{base_rain or 0}}
local base_cloud = {{base_cloud or 0.1}}
local base_sea = {{base_sea or 2}}

local var_temp = {{var_temp or 2}}
local var_rain = {{var_rain or 0}}
local var_cloud = {{var_cloud or 0.1}}
local var_sea = {{var_sea or 1}}

-- 정수 난수 (온도, 해상상태)
local temp_drift = math.random(-var_temp, var_temp)
local sea_drift = math.random(-var_sea, var_sea)

-- 소수 난수 (구름, 비) — Lua math.random(a,b)은 정수만 반환하므로 math.random()으로 0~1 소수 생성 후 스케일링
local cloud_drift = (math.random() * var_cloud * 2) - var_cloud
local rain_drift = 0
if var_rain > 0 then
    rain_drift = math.random(-var_rain, var_rain)
end

local newTemp = base_temp + temp_drift
local newRain = base_rain + rain_drift
local newCloud = base_cloud + cloud_drift
local newSea = base_sea + sea_drift

-- 엔진 허용 범위 내로 경계값 클램핑
if newRain < 0 then newRain = 0 elseif newRain > 50 then newRain = 50 end
if newCloud < 0.0 then newCloud = 0.0 elseif newCloud > 1.0 then newCloud = 1.0 end
if newSea < 0 then newSea = 0 elseif newSea > 9 then newSea = 9 end

ScenEdit_SetWeather(newTemp, newRain, newCloud, newSea)
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
