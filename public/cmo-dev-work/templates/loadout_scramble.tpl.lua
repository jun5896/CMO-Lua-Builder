-- loadout_scramble.tpl.lua
-- 비행장 긴급발진 콤보: 호스트로부터 새 유닛 생성 + 로드아웃 + Launch.
-- 컨텍스트: side, host, name, type, dbid, loadout_dbid, mission?
do
    local __unit = ScenEdit_AddUnit({
        side = {{q(side)}},
        name = {{q(name)}},
        type = {{q(type or "Aircraft")}},
        dbid = {{dbid}},
        loadoutid = {{loadout_dbid or 0}},
        base = {{q(host)}},
    })
    if __unit then
        {% if mission then %}
        ScenEdit_AssignUnitToMission(__unit.guid, {{q(mission)}})
        {% end %}
        if __unit.Launch then __unit:Launch() end
        print("SUCCESS: scrambled " .. {{q(name)}} .. " from " .. {{q(host)}})
    else
        print("ERROR: scramble failed for " .. {{q(name)}})
        {% include "errmsg_guard" with { __indent = "        " } %}
    end
end

