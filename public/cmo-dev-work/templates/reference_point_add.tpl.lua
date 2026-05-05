-- reference_point_add.tpl.lua
-- ScenEdit_AddReferencePoint. side, name, latitude, longitude 필요.
do
    local __rp = ScenEdit_AddReferencePoint({
        side      = {{q(side)}},
        name      = {{q(name)}},
        lat       = {{lat or latitude}},
        lon       = {{lon or longitude}},
        {% if highlighted then %}highlighted = {{literal(highlighted)}},{% end %}
        {% if locked then %}locked = {{literal(locked)}},{% end %}
        {% if relative_to then %}relativeto = {{q(relative_to)}},{% end %}
        {% if bearing_type then %}bearingtype = {{q(bearing_type)}},{% end %}
        {% if bearing then %}bearing = {{bearing}},{% end %}
        {% if distance then %}distance = {{distance}},{% end %}
    })
    if __rp then
        print("SUCCESS: added RP " .. {{q(name)}})
    else
        print("ERROR: failed to add RP " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

