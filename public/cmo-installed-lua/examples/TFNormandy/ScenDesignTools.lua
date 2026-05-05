function PrintSideUnitScoringTemplate(sideName)
    local sideUnits = VP_GetSide({side=sideName}).units
    for k,v in ipairs (sideUnits) do
        local unit = ScenEdit_GetUnit({guid=v.guid})
        print (
            "{dbid="..unit.dbid..
            ", type="..unit.type..
            ", points=0"..
            ", destroyedString=nil"..
            "},--"..unit.classname)
    end
end