-- weather_random.tpl.lua
-- math.random + ScenEdit_SetWeather. 컨텍스트: seed?, temp_min/max, rain_chance, sea_state_min/max
do
    {% if seed then %}math.randomseed({{seed}}){% else %}math.randomseed(os.time()){% end %}
    local __t = math.random({{temp_min or -10}}, {{temp_max or 40}})
    local __rain = (math.random() < {{rain_chance or 0.3}}) and math.random(1, 5) or 0
    local __sea = math.random({{sea_state_min or 0}}, {{sea_state_max or 9}})
    ScenEdit_SetWeather(__t, __rain, __sea, math.random(0, 8))
    print(string.format("Weather: temp=%d rain=%d sea=%d", __t, __rain, __sea))
end

