side = VP_GetSide({name='Civilian'})
for k,v in pairs(side.units) do
    unit = ScenEdit_GetUnit({guid=v.guid})
        if unit.course[1] == nil then
            ScenEdit_DeleteUnit({guid=unit.guid})
        end
end