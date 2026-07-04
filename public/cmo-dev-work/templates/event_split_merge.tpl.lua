-- event_split_merge.tpl.lua
-- 부대 분산(Split) / 결집(Merge) 스크립트
-- CMO v1265+ 공식 API: ScenEdit_SplitUnit(), ScenEdit_MergeUnits()
-- Split: 단일 복합 시설 유닛을 각 컴포넌트 mount별 독립 유닛으로 자동 분해
-- Merge: 분해된 유닛들을 다시 원래 단일 유닛으로 병합
do
    local __evt = ScenEdit_SetEvent({{q(name)}}, {
        description  = {{q(description or "Split / Merge Unit Event")}},
        isactive     = true,
        isrepeatable = false,
        isshown      = true,
    })
    if __evt then
        local __tname = {{q(name .. "_trigger")}}
        ScenEdit_SetTrigger({ mode = "add", type = "RegularTime", name = __tname, interval = {{interval or 30}} })
        ScenEdit_SetEventTrigger({{q(name)}}, { mode = "add", name = __tname })

        local __aname = {{q(name .. "_action")}}
        local __script = [==[
local target_id = {{q(unit_id or unit_name or "")}}
local side = {{q(side or "RED")}}
local mode = {{q(mode or "split")}}

-- GUID 우선, Name 폴백
local unit = ScenEdit_GetUnit({guid=target_id})
if not unit then
    unit = ScenEdit_GetUnit({side=side, name=target_id})
end

if unit then
    if mode == "split" then
        -- 공식 API: 유닛을 컴포넌트 mount 단위로 자동 분해
        -- 반환값: 분해된 유닛 래퍼(wrapper)들의 테이블
        local split_units = ScenEdit_SplitUnit({guid=unit.guid})
        if split_units then
            local count = 0
            for _ in pairs(split_units) do count = count + 1 end
            ScenEdit_SpecialMessage(side, unit.name .. " 부대가 " .. count .. "개 컴포넌트로 분산 전개되었습니다.")
        end
    elseif mode == "merge" then
        -- 공식 API: 현재 선택된 유닛들을 첫 번째 유닛으로 병합
        -- 주의: 이 함수는 ScenEdit_SelectedUnits()와 연동되므로
        -- 스크립트에서 직접 호출 시에는 유닛 GUID를 넘겨야 할 수 있음
        local merged = ScenEdit_MergeUnits()
        if merged then
            ScenEdit_SpecialMessage(side, merged.name .. " 부대가 결집 완료되었습니다.")
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
