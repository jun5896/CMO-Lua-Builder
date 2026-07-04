-- presets/multi_file_pack.lua
-- 다중 파일(Multi-file) 시나리오 출력 시연 예제. (Task 10)
-- config.multi_file = true 로 설정하면,
-- 빌더가 output/multi_file_pack/init.lua 와 output/multi_file_pack/events/*.lua 로 나누어 저장합니다.

return {
    header = {
        title = "Multi-file Event Pack Example",
        description = "Demonstrates extracting LuaScript actions into side files.",
    },
    multi_file = true,
    sides = {
        { side = "Blue" }
    },
    events = {
        {
            kind = "complex",
            name = "Test_Event_MultiFile",
            isactive = true,
            triggers = {
                { type = "RegularTime", name = "trig_10s", opts = { Interval = 10 } }
            },
            actions = {
                {
                    type = "LuaScript",
                    name = "action_hello_world",
                    opts = {
                        scripttext = [==[
-- 이 스크립트는 외부 events/action_hello_world.lua 파일로 분리되어 저장됩니다.
local msg = "Hello from external script!"
print(msg)
ScenEdit_SpecialMessage("Blue", msg)
]==]
                    }
                }
            }
        }
    }
}
