-- event_dbid_score.tpl.lua
-- Unit type + DBID 기반 스코어보드 이벤트 템플릿.
-- 컨텍스트: name, target_side, side, scores = { Aircraft = { [dbid] = score }, Facility = { ... } }
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Scoreboard event")}},
        isactive     = true,
        isrepeatable = true,
        isshown      = {{literal(default(isshown, true))}},
    })
    if __evt then
        local __tname = {{q(name .. "_trig")}}
        ScenEdit_SetTrigger({ mode = "add", type = "UnitDestroyed", name = __tname,
            TargetFilter = {
                TargetSide = {{q(target_side or "Any")}},
            },
        })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __scores_tbl = {{lua_table(scores or {}, "")}}
        local __script = string.format([==[
local u = ScenEdit_UnitX()
if not u then return end

local scores = %s
local unit_type = tostring(u.type or "")
local typed_scores = scores[unit_type] or scores[unit_type:lower()]
local pts = typed_scores and typed_scores[u.dbid]
if pts then
    local current_score = ScenEdit_GetScore(%q) or 0
    ScenEdit_SetScore(%q, current_score + pts, %q)
    ScenEdit_SpecialMessage(%q, string.format("Target Destroyed: %%s (%%s DBID: %%d) - Score +%%d", u.name, unit_type, u.dbid, pts))
end
]==], __scores_tbl, {{q(side or "Blue")}}, {{q(side or "Blue")}}, {{q(name)}}, {{q(side or "Blue")}})

        ScenEdit_SetAction({ mode = "add", type = "LuaScript", name = __aname, scripttext = __script })
        ScenEdit_SetEventAction({{q(name)}}, { mode = "add", name = __aname })
        print("SUCCESS: dbid_score event " .. {{q(name)}})
    else
        print("ERROR: failed to create dbid_score event " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end
