math.randomseed(os.time())

WeatherDrift()

local playerSide = ScenEdit_PlayerSide()
if playerSide == "USN" then
	local sparedUnits = {
		{name = "Riyahd Air Base", guid = "783847a6-63c7-4c26-9fe3-7932446a33d6"},
		{name = "Disco #01", guid = "eedc7868-5f68-4dd7-ada4-2c81eca72121"},
		{name = "Disco #02", guid = "e3a4f722-d1f0-4c12-a6ac-5ced40a2ce75"},
		{name = "Disco #03", guid = "afa872c1-9b56-486a-863e-a9fb15bf1557"}
	}
	local unitsToDelete = VP_GetSide({side = "USAF"}).units
	for k, v in ipairs(unitsToDelete) do
		local unit = ScenEdit_GetUnit({guid = v.guid})
		local match = false
		for key, spared in ipairs(sparedUnits) do
			if v.guid == spared.guid then
				match = true
			end
		end
		if match == false and unit.type == "Aircraft" then
			ScenEdit_DeleteUnit({guid = v.guid})
		end
	end
elseif playerSide == "USAF" then
	local unitsToDelete = VP_GetSide({side = "USN"}).units
	for k, v in ipairs(unitsToDelete) do
		local unit = ScenEdit_GetUnit({guid = v.guid})
		if unit.type == "Aircraft" then
			ScenEdit_DeleteUnit({guid = v.guid})
		end
	end
end

RandomiseSideUnitProficiency("playerside")
RandomiseSideUnitProficiency("Iraq")

local iraqMobileAirDefenceUnits = {
	{name = "AAA Bty (37mm M1939 x 6)", guid = "83cdbae5-ef84-4e57-a0fe-58e4c7629e41"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "001efb0e-6389-4b7c-ac36-27d31f651517"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "24afb0d3-e91b-40df-889f-55a184fc0c22"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "25af07da-d1d3-4b65-b9a4-b05cc8bc9348"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "2662d83d-4a5e-4bf1-8cfa-6bc6c38744ac"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "2e85e2aa-c296-4de0-b4af-f2f6c3b8960a"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "3a96bd4f-9c0a-48c1-8528-95d6d78b0611"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "5bcffd0b-5bfc-4203-ba76-5a4ef7dbd0df"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "677ca9a2-681e-49db-970c-9560b60d6c81"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "6ee6e4e7-aca7-4b6f-9e87-12343fbba57f"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "7e3ccb4a-13b0-4846-8087-0810a8bf4dcf"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "a92a1f5c-36ba-40e2-94f3-4eb799ff390d"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "c9d011f4-d538-4961-8718-d8940a535015"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "da76853e-51c8-4cbf-81c4-01fa95b53759"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "e5889eee-2838-4da3-a212-391152ac4652"},
	{name = "AAA Bty (57mm S-60 x 6, RPK-1M1 FCR)", guid = "e9a5a115-a437-4b81-9fc9-5d11b936debd"},
	{name = "AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)", guid = "169ff1f4-f2a6-4aac-889c-ed248833334a"},
	{name = "AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)", guid = "406e71bc-badb-4197-a1f2-05aa0aa15221"},
	{name = "AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)", guid = "5ae4a093-2708-45ca-a702-7ebd606ce13d"},
	{name = "AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)", guid = "c9a55bd7-ea6d-4f18-aed6-e3880079fcb5"},
	{name = "AAA Plt/2 (23mm ZSU-23-4 Shilka x 2)", guid = "d7859294-4315-48be-ac8d-2935d57f67ed"},

	{name = "SAM Bty (SA-3b Goa [S-125M Pechora])", guid = "25e5d729-1246-4b8c-99df-55dc9a9d079d"},
	{name = "SAM Bty (SA-3b Goa [S-125M Pechora])", guid = "509d83b4-ba84-470a-b5b1-1059fb1d9554"},
	{name = "SAM Bty (SA-3b Goa [S-125M Pechora])", guid = "88b4ed73-72df-4468-8584-325ea59fde1c"},
	{name = "SAM Bty (SA-3b Goa [S-125M Pechora])", guid = "a78df9ad-1b83-40da-b446-b464fda853a8"},
	{name = "SAM Bty (SA-3b Goa [S-125M Pechora])", guid = "b4441e4d-2767-4a23-9801-7f0b82a19d32"},
	{name = "SAM Bty (SA-3b Goa [S-125M Pechora])", guid = "eaacf954-a011-4241-81cf-3e81e566080b"},
	{name = "SAM Bty (SA-3b Goa [S-125M Pechora])", guid = "fba54955-a2da-4433-a75d-4176009c2c9d"},
	{name = "SAM Bty (SA-3b Goa [S-125M Pechora])", guid = "fdd95bb8-bd81-49b8-9b63-e3df59ad5032"},
	{name = "SAM Bty (SA-3b Goa [S-125M Pechora])", guid = "ff20930b-de7f-43ff-b406-afdd8a2226f3"},
	{name = "SAM Bty (SA-6a Gainful [2K12E Kvadrat])", guid = "8fc9537e-4f8b-488c-a598-41566c3a7425"},
	{name = "SAM Bty (SA-6a Gainful [2K12E Kvadrat])", guid = "b7c49e6e-b161-45c3-b120-ae8fae1bbcc2"},
	{name = "SAM Bty (SA-6a Gainful [2K12E Kvadrat])", guid = "c420d362-5107-449d-90a6-2cf72ae1fc43"},
	{name = "SAM Bty (SA-6a Gainful [2K12E Kvadrat])", guid = "e5d275db-ca9c-48f1-8d9e-aa22566150a3"},
	{name = "SAM Bty/2 (Roland 2 [Shelter])", guid = "3557341d-ebc6-46c3-a546-ef61ef78b94a"},
	{name = "SAM Bty/2 (SA-8b Gecko Mod-0 [9K33M2 Romb])", guid = "170986a9-af9f-4d21-8918-a9ac2ec18c15"},
	{name = "SAM Bty/2 (SA-8b Gecko Mod-0 [9K33M2 Romb])", guid = "da36c489-edc1-4536-b90f-7faec8da1e6c"},
	{name = "SAM Plt (SA-13 Gopher [9K35 Strela-10])", guid = "abe03671-deca-4f4c-a239-20d0d5600b5a"},
	{name = "SAM Plt (SA-9b Gaskin [9K31 Strela-1])", guid = "2feec5f3-2b2f-4ab8-bfe7-17c03c0f642b"},
	{name = "SAM Sec (SA-14 Gremlin [9K34 Strela-3] MANPADS x 3)", guid = "2bd91b43-dced-416f-9dc9-c32125d19342"},
	{name = "SAM Sec (SA-14 Gremlin [9K34 Strela-3] MANPADS x 3)", guid = "ae5d3228-ab3e-469b-96d1-8341daafbf3e"},
	{name = "SAM Sec (SA-14 Gremlin [9K34 Strela-3] MANPADS x 3)", guid = "ef90355f-81d6-49dd-9517-a82e1a6f8cc4"},
	{name = "SAM Sec (SA-14 Gremlin [9K34 Strela-3] MANPADS x 3)", guid = "f1f589f9-09f3-47d3-9aa9-1271047ecd17"},
	{name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)", guid = "0ff95264-dca0-4f71-bcb0-2d8bb2d036fe"},
	{name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)", guid = "37a12dce-5666-4fb7-8e19-1fdad6f71f17"},
	{name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)", guid = "5b199bba-df31-4434-a0c8-e0c98cf0fd4f"},
	{name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)", guid = "668f671c-cde9-45ee-be63-834a70bc1748"},
	{name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)", guid = "6da88061-1def-41e6-87fb-728adab147ab"},
	{name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)", guid = "8a9934d9-5e70-465c-92b1-6a9d9c4fe3ef"},
	{name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)", guid = "b397b6ed-4683-4295-bb5b-cd7a6eaf7bf0"},
	{name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)", guid = "b81544f9-a945-4c55-95e9-e7114ca5133e"},
	{name = "SAM Sec (SA-7b Grail [9K32M Strela-2M] MANPADS x 3)", guid = "edb93473-07f8-4b2d-9795-2d87fc470a4d"},
}

for k, v in ipairs(iraqMobileAirDefenceUnits) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local newPos = CircularRandomPosition(unit.latitude, unit.longitude, 10)
	ScenEdit_SetUnit({guid = unit.guid, latitude = newPos.latitude, longitude = newPos.longitude})
end

local iraqUnits = VP_GetSide({side='Iraq'}).units
for k,v in ipairs(iraqUnits) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	if unit.type == 'Aircraft' then
		RandomiseReadyTime(unit.guid)
	end
end