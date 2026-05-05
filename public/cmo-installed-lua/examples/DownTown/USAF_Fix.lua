local aircraft = {
    {type = "Aircraft", dbid = 1258, points = 0, name = "F-4C Phantom II", newLoadout = 644},
    --F-4C Phantom II
    {type = "Aircraft", dbid = 134, points = 0, name = "F-105D Thunderchief", newLoadout = 9479},
    --F-105D Thunderchief
    {type = "Aircraft", dbid = 20, points = 0, name = "F-105G Thunderchief", newLoadout = 9943}
    --F-105G Thunderchief
}

function ReplaceLoadouts()
    local sideUnitList = VP_GetSide({side='USAF'}).units
    for k,v in ipairs (sideUnitList) do
        local unit = ScenEdit_GetUnit({guid=v.guid})
        if unit.type == 'Aircraft' then
            for each, aircraftType in ipairs (aircraft) do
                if unit.dbid == aircraftType.dbid then
                    ScenEdit_DeleteUnit({guid=v.guid})
                    local newUnit = ScenEdit_AddUnit({
                        side=unit.side,
                        name=unit.name,
                        type=unit.type,
                        dbid=unit.dbid,
                        altitude=unit.altitude,
                        heading=unit.heading,
                        speed=unit.speed,
                        loadoutid=aircraftType.newLoadout,
                        latitude=unit.latitude,
                        longitude=unit.longitude,
                    })                    
                end
            end
        end
    end
end