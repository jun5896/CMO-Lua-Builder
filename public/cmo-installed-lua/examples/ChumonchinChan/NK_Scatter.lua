local junks = {
    {name = "Transport Junk", guid = "526a4040-2105-48ea-8f0f-40b4c3ff663c"},
    {name = "Transport Junk", guid = "d715d9c6-ddfe-4519-8193-3a16520d3105"},
    {name = "Transport Junk", guid = "b359918f-365c-40a9-ab3b-14841fa825ed"},
    {name = "Transport Junk", guid = "d8d51eab-fea9-4001-9f63-346932a2079a"},
    {name = "Transport Junk", guid = "ba7df1aa-e870-4981-80c6-106e48c28209"},
    {name = "Transport Junk", guid = "cdaf229a-c058-4f23-8591-f7895b9f134b"},
    {name = "Transport Junk", guid = "c7e09713-7bba-4891-829f-fb780808d82d"},
    {name = "Transport Junk", guid = "125f4527-0425-4a32-9dbe-d2ea58e4d192"},
    {name = "Transport Junk", guid = "2d27e88d-f032-4296-8eb2-7f2408df1721"},
    {name = "Transport Junk", guid = "9576be1b-6fae-472f-a1c4-fa75591cc535"}
}

math.randomseed(os.time())
for k, v in ipairs(junks) do
    local unit = ScenEdit_GetUnit({guid = v.guid})
    local newWaypoint =
        World_GetPointFromBearing(
        {
            latitude = unit.latitude,
            longitude = unit.longitude,
            bearing = math.random(0, 125),
            distance = 100
        }
    )
    ScenEdit_SetUnit({
        guid = v.guid, 
        course = {newWaypoint}, 
        manualThrottle = "Full"
    })
end
local unit = ScenEdit_GetUnit({guid='88dcba64-6a6f-4ba2-bde3-065931ebdfc8'})
local theMessage = GenerateRadioMessageBody("Enemy cargo vessels spotted. They're attempting to scatter. Tally ho!",'C 44 HMS Jamaica')
RadioMessage('HF','27.5MHz',theMessage,{latitude=unit.latitude, longitude=unit.longitude})