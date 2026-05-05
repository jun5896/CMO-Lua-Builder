-- inst_import.tpl.lua
-- ScenEdit_ImportInst. 컨텍스트: side, filename
do
    local __side = {{q(side)}}
    local __filename = {{q(filename)}}
    
    local ok, err = pcall(ScenEdit_ImportInst, __side, __filename)
    if ok then
        print("SUCCESS: Imported INST " .. __filename .. " to " .. __side)
    else
        print("ERROR: Failed to import INST " .. __filename)
        print("Reason: " .. tostring(err))
    end
end
