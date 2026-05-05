-- event_complex.tpl.lua
-- 다중 트리거/조건/액션 이벤트.
-- 컨텍스트: name, description?, isactive?, isrepeatable?, isshown?,
--           triggers = { { type=..., name=..., opts={...} }, ... },
--           conditions = { ... 동일 ... },
--           actions = { ... 동일 ... }
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "")}},
        isactive     = {{literal(default(isactive, true))}},
        isrepeatable = {{literal(default(isrepeatable, false))}},
        isshown      = {{literal(default(isshown, true))}},
    })
    if __evt then
        {% for _, t in ipairs(triggers or {}) do %}
        do
            local __t = ScenEdit_SetTrigger({ mode = "add", type = {{q(t.type)}}, name = {{q(t.name)}},
                {% for k, v in pairs(t.opts or {}) do %}{{k}} = {{lua_table(v, "                ")}},{% end %}
            })
            if __t then ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = {{q(t.name)}} }) end
        end
        {% end %}
        {% for _, c in ipairs(conditions or {}) do %}
        do
            local __c = ScenEdit_SetCondition({ mode = "add", type = {{q(c.type)}}, name = {{q(c.name)}},
                {% for k, v in pairs(c.opts or {}) do %}{{k}} = {{lua_table(v, "                ")}},{% end %}
            })
            if __c then ScenEdit_SetEventCondition({{q(name)}}, { mode = "add", name = {{q(c.name)}} }) end
        end
        {% end %}
        {% for _, a in ipairs(actions or {}) do %}
        do
            {% if a.type == "LuaScript" and a.opts and a.opts.scripttext and __config and __config.multi_file then %}
                {% 
                   local sf_name = "events/" .. a.name .. ".lua"
                   table.insert(__config.__side_files, { name = sf_name, content = a.opts.scripttext })
                   a.opts.scripttext = "ScenEdit_RunScript('" .. run_script_path(__config, sf_name) .. "')"
                %}
            {% end %}
            local __a = ScenEdit_SetAction({ mode = "add", type = {{q(a.type)}}, name = {{q(a.name)}},
                {% for k, v in pairs(a.opts or {}) do %}{{k}} = {{lua_table(v, "                ")}},{% end %}
            })
            if __a then ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = {{q(a.name)}} }) end
        end
        {% end %}
        print("SUCCESS: event " .. {{q(name)}} .. " created with " ..
              tostring({{ len(triggers) }}) .. "T/" ..
              tostring({{ len(conditions) }}) .. "C/" ..
              tostring({{ len(actions) }}) .. "A")
    else
        print("ERROR: failed to create event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

