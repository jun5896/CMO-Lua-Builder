-- mission_strike.tpl.lua
-- 컨텍스트: side, name, strike_type, targets = { unit_name, ... }, target_side?, targets_dbid?, flight_size?, escort?
do
    local __valid_types = { Land = true, Naval = true, Sub = true, ["Air Intercept"] = true }
    local __strike_type = {{q(strike_type or "Land")}}
    if not __valid_types[__strike_type] then
        print("WARNING: invalid strike_type, falling back to Land")
        __strike_type = "Land"
    end
    local __m = ScenEdit_AddMission({{q(side)}}, {{q(name)}}, "strike", {
        type = __strike_type,
    })
    if __m then
        {% if flight_size then %}__m.flightsize = {{flight_size}}{% end %}
        {% if oneway then %}__m.oneway = {{literal(oneway)}}{% end %}
        {% for _, target_name in ipairs(targets or {}) do %}
        do
            local __target_name = {{q(target_name)}}
            local __target_side = {{q(target_side or "")}}
            local __t = nil
            if __target_side ~= "" then
                __t = ScenEdit_GetUnit({ side = __target_side, name = __target_name })
            end
            if not __t then
                __t = ScenEdit_GetUnit({ name = __target_name })
            end
            if __t then
                ScenEdit_AssignUnitAsTarget({ __t.name or __target_name }, {{q(name)}})
                print("SUCCESS: assigned target " .. {{q(target_name)}})
            else
                print("WARNING: target unit not found: " .. {{q(target_name)}})
            end
        end
        {% end %}
        print("SUCCESS: created strike mission " .. {{q(name)}})
    else
        print("ERROR: failed to create strike mission " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

