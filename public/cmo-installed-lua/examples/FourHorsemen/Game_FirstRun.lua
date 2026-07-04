math.randomseed(os.time())

local unitListHorton = {
    {name = "A 122 Olwen", guid = "d77448bb-34d3-4a4e-b730-0ab8567658ee"},
    {name = "C 551 Giuseppe Garibaldi", guid = "983017fd-5aa2-42cf-8589-1e704bbb97be"},
    {name = "CG 49 Vincennes", guid = "85cc7318-1f8f-4369-993e-947248655227"},
    {name = "D 550 Audace", guid = "099fd9a3-bf86-4004-849f-18dc58c2838a"},
    {name = "D 551 Ardito", guid = "12c942d7-cde5-40f3-ae1a-bcbc2c781271"},
    {name = "D 91 Nottingham", guid = "b35457fc-dce7-4dbf-af1e-991d4fded274"},
    {name = "D 95 Manchester", guid = "a2cdcbb2-6f14-4f85-a87f-2ec572c8bbaa"},
    {name = "DD 970 Caron", guid = "0484705e-bd73-4af4-9ce8-aca876b72b71"},
    {name = "DD 989 Deyo", guid = "36325763-5f95-4d15-a2f8-21dc72e16eed"},
    {name = "F 40 Sirius", guid = "b895e56e-188c-4673-a001-f3558181a244"},
    {name = "F 56 Argonaut", guid = "eae752cb-54df-413d-94e2-9a0ed0b7a88e"},
    {name = "F 573 Scirocco", guid = "55d48c0c-82ca-42af-b2e0-197238bd56b8"},
    {name = "F 576 Espero", guid = "c50a7cea-4b90-41c9-a8f8-ec41475a1517"},
    {name = "F 87 Chatham", guid = "cf59f3a3-5080-4727-ac58-e622106e62ff"},
    {name = "F 88 Broadsword", guid = "15a5ecc0-6951-48fd-9ec3-3a3a2bbb6cfc"},
    {name = "F 92 Boxer", guid = "ed476297-7310-446e-9e83-5d95df41f9ef"},
    {name = "F 93 Beaver", guid = "b7b5207e-7ff3-4d63-8d6a-bc553da4617d"},
    {name = "R 06 Illustrious", guid = "6739c9b6-144e-4b5d-988e-1cba5c2d9bb9"},
    {name = "SSN 647 Pogy", guid = "9d23bdfd-2d02-44ec-a5b8-ead5471da830"},
    {name = "SSN 663 Hammerhead", guid = "d5d9c37a-03f9-439d-8058-431ed648914d"},
    {name = "SSN 707 Portsmouth", guid = "47e392c3-de7a-40e1-bcc4-aca77c89837f"},
    {name = "SSN 714 Norfolk", guid = "3173f535-7696-4b45-bd95-c0197f8647fe"}
}

local submarines = {
    {name = "K-148 Krasnodar", guid = "7fb62741-c520-48d3-88d0-a89830583803"},
    {name = "K-278 Komsomolets", guid = "e2fba112-5bac-44f7-aaad-b50c2d1df19d"},
    {name = "K-360", guid = "833fc3ce-4a7b-4952-83a3-8be8c14d3d83"},
    {name = "K-463", guid = "591f6364-0189-47af-bad1-c03ff4ffcac7"},
}

local function GenerateTableOfEnemyUnitDistances(latitude,longitude)
    local result = {}
    for k,v in ipairs (unitListHorton) do
        local distance = Tool_Range({latitude=latitude,longitude=longitude},v.guid)
        table.insert(result,distance)
    end
    return result
end

local function PositionIsWithinXDistanceOfEnemy(latitude,longitude,xDistance)
    local distanceList, result = GenerateTableOfEnemyUnitDistances(latitude,longitude), false
    for k,v in ipairs (distanceList) do
        if v <= xDistance then
            result = true
        end
    end
    return result
end

for k,v in ipairs (submarines) do
    local errorCount = 0

    ::redoSubPosition::
    local position = RandomPosition(60, 64, -20, -7)
	local elevation = World_GetElevation(position)

	if elevation > -2000 or PositionIsWithinXDistanceOfEnemy(position.latitude,position.longitude,80) then
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoSubPosition
		else
			BugMessage("Game_Setup", "Unable to place "..v.name..' after 500 attempts!')
			break
		end
	end

	ScenEdit_SetUnit({guid=v.guid,latitude=position.latitude,longitude=position.longitude})
end