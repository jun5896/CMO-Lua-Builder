math.randomseed(os.time())

WeatherDrift()

local fishingVessels = {
	{dbid=20, prefix='N/A', category='Commercial',}, -- Civilian Dhow [15m] -- Civilian (Civilian)
	{dbid=357, prefix='N/A', category='Commercial',}, -- Civilian Dhow [22m] -- Civilian (Civilian)
}

local numberOFCivFishingVessels = math.random(48,96)

for i = 1,numberOFCivFishingVessels do
	local randomType = fishingVessels[math.random(1,#fishingVessels)].dbid
	local errorCount = 0
	::redoPositionFishingVessels::
	local position = RandomPosition(17,21,105,112)
	local elevation = World_GetElevation(position)
	if elevation > -25 then 
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionFishingVessels
		else
			BugMessage('Game_Setup','Unable to place fishing vessel #'..i..' after 500 attempts!')
			break
		end
	end
	
	local unit = ScenEdit_AddUnit({
		side='Civilian',
		type='Ship',
		dbid=randomType,
		name='Fishing Vessel',
		lat=position.latitude,
		lon=position.longitude
	})

	ScenEdit_AssignUnitToMission(unit.guid, 'Fishing')
end

local preplacedEnemySHORAD = {
    {type='Facility', dbid=193,guid='98c2991b-9b19-4f05-ab4b-7987bb97c26d',}, --AAA Bty (57mm ZSU-57-2 x 4)
    {type='Facility', dbid=193,guid='c3e4e23e-9243-4500-b5bc-7a3c600a7ae9',}, --AAA Bty (57mm ZSU-57-2 x 4)
    {type='Facility', dbid=193,guid='d65882aa-ed4c-475b-a395-1aca560255a5',}, --AAA Bty (57mm ZSU-57-2 x 4)
    {type='Facility', dbid=193,guid='e8ee04c4-9476-4274-aa78-e758d00fe397',}, --AAA Bty (57mm ZSU-57-2 x 4)

    {type='Facility', dbid=222,guid='a0d4a7ef-49dd-4e30-a2ef-0dc0d0636304',}, --AAA Bty (37mm Type 65 Twin x 4)
    {type='Facility', dbid=222,guid='a3216a7b-52ca-4365-8358-820ae135da7b',}, --AAA Bty (37mm Type 65 Twin x 4)
    {type='Facility', dbid=222,guid='b4e22988-0e25-4317-8b11-83da88389065',}, --AAA Bty (37mm Type 65 Twin x 4)
    {type='Facility', dbid=222,guid='fdd0ed02-bd06-42f4-a325-f7daf874133d',}, --AAA Bty (37mm Type 65 Twin x 4)

    {type='Facility', dbid=621,guid='0af49d49-6099-4350-95e6-8c401e5cd3c5',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='0b5edd8f-d890-4784-804e-377c6457483f',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='0c874013-75b6-4338-ab6b-d52e5e07eb67',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='0fbe9c86-4b1b-4e2d-9399-e601acd4e7bf',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='11ee7ea9-1a27-448f-991d-04e5933069c1',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='1354d670-b27d-4dd2-9ae6-66752a272217',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='2e295ea0-d9af-46f1-90a6-ee89ef1489ee',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='36b6e13c-9358-4a08-ae30-c8bdbffa6d3b',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='4c7b5bd5-8c7c-43d9-a4b6-cfa0ddba9eec',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='52719cc5-ac7c-4c3c-a7b0-408a757e2b36',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='56a2acfa-7cbd-40a9-9c42-81709354f004',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='5dccffdb-2bea-49b2-a282-41794da5addd',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='775a78f0-8596-45e1-a83a-45ee883acc04',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='81de177a-d06e-4f2d-9c91-87bf105134ce',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='8b83fd45-a7be-412b-b55f-5540b941670e',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='8ce50a06-1520-4faa-9e02-19a899f138db',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='9981f31d-7a70-48cc-a5d4-08b18ca1805d',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='b05d6597-0e13-4b79-84e9-7d13f5ba65db',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='ba907e14-2cbe-4c3c-b56e-048adba4970e',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='d9820470-7c50-4df0-be06-deb0e2be6763',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    {type='Facility', dbid=621,guid='ec6fc73f-a1a5-4508-b919-46ac897c13ab',}, --AAA Bty (ZPU-2 x 4 + Fire Can FC)

    {type='Facility', dbid=628,guid='14738659-562e-464b-ab00-5973cb6fd4fc',}, --AAA Bty (12.7mm DSHK x 4)
    {type='Facility', dbid=628,guid='512f541f-19d5-4253-b057-95f47225cc39',}, --AAA Bty (12.7mm DSHK x 4)
    {type='Facility', dbid=628,guid='b6048d91-321c-4d01-ae7d-15c16dbf6158',}, --AAA Bty (12.7mm DSHK x 4)
    {type='Facility', dbid=628,guid='cb81fff7-7608-4731-9a2d-971f712fd627',}, --AAA Bty (12.7mm DSHK x 4)
    {type='Facility', dbid=628,guid='d68a3528-eee6-4a1e-b17b-df11617bad02',}, --AAA Bty (12.7mm DSHK x 4)

    {type='Facility', dbid=633,guid='00e69297-160b-4709-b11d-39538714f041',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='2118d0e3-841d-479b-9a06-dee717548fcd',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='37f1118c-eb7f-4d49-9b58-b9adc1d3863c',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='515e06e1-fc93-4db8-94b5-b81d44cf12dd',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='79985c1e-c0dd-40fc-96f9-50a756eac9f8',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='8928a35a-abfa-4522-bc7c-06a0fc741b23',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='8d88acf9-d0eb-426d-844d-2a89dcd835de',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='8f2f36ed-38b7-4be6-9fa5-abbb72653798',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='a7b89a74-cf39-409f-9da2-c196efc1c070',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='ab85d2de-2fd2-48d1-879c-f6bd1a4a9fd0',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='c187f378-d560-452f-aba5-2dfb32255a80',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='d32ee5ea-8d2c-4f95-9021-bc1351e4f68c',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='d8d6c6c9-c1f5-41ae-bbc3-97dd66b82ec4',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='dcef0152-a8b6-4731-8be2-094fab72a211',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='df15fb6d-0287-48d4-8ae5-850f7422f436',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='e5b028f3-96b7-4c40-b24d-576eb80e2cd0',}, --SAM Sec (SA-7a Grail MANPADS x 4)
    {type='Facility', dbid=633,guid='eb0d41c7-c62b-4806-9e43-c2b25ce6b8eb',}, --SAM Sec (SA-7a Grail MANPADS x 4)

    {type='Facility', dbid=634,guid='089d6c1f-75ad-4493-91fc-a4fef421a1fe',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='091ed8e6-86e2-4b98-bee5-8062c9962b48',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='0a8efd2f-2b53-4584-acdd-59630ceb948e',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='0ac74258-208a-47dc-a97f-f1b981085f45',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='1686c087-df76-424b-a102-4959d85aa7d9',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='220ece5c-49bd-407c-8f5b-e533344eceab',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='255cae33-5c90-4a56-a393-4f045f3bafdf',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='403d2493-b262-4c17-a4e4-ad0216f17074',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='55ecb45c-d1bb-4d63-bc4e-84851ca30635',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='6acd550f-2cf6-4671-b495-25de29a81010',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='7375c3f3-5ebb-4614-8f6a-63e0d3820524',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='7b578023-345f-47e0-8b0b-d7ab77a2987d',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='8c0919af-0b8b-4a5a-89e5-22306c0cc3cb',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='929aeda5-df03-4e01-8010-1a78f7078e6c',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='92af238f-2636-42fe-a4d8-c43a6f909713',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='9c7cb60e-e465-4bdf-b249-c80d01f59448',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='9d39f8ad-4cde-426f-8b69-369fe8903fce',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='a5e252ef-10a9-445d-821a-136110703a20',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='ae1db783-70eb-49c5-ba27-56ae653d819a',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='bdb86b84-a27b-4bb6-9e96-8ff1dd248397',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='c83697dd-7991-4686-a10b-6cb011c7cd13',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='d176fb0f-b148-43c5-8da1-5f564469bad0',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='d9ab7699-3fd6-4c23-877c-a91851d04c85',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='e35b5144-69b1-4a3a-b31c-8ca776c6a0da',}, --AAA Bty (57mm M1950 x 4)
    {type='Facility', dbid=634,guid='fafd511a-bd00-498a-98ce-4581572fd10b',}, --AAA Bty (57mm M1950 x 4)
}

local preplacedEnemySAM = {
    {type='Facility', dbid=630,guid='0d16adb2-2116-4aed-a600-32fcb1764a77',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='27a1aced-867a-4531-9005-c91dea2a8fc0',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='41c957f5-9ae1-490f-9357-f65eb79758e8',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='64b36742-cb71-46c8-9fd4-03538fb4304c',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='686e5a96-b21c-4be0-b7f7-e7b6486d36d0',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='9e641486-bfdf-4141-8cdf-709ae4116b1d',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='aefe34b6-323e-48de-a973-f5fe58e2cc10',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='b2d9df66-b88c-4812-89be-d4b203917bad',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='bc301625-5c38-42cd-ba1f-b75f98e1b8c4',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='cbb19e7d-fa26-4998-b88c-22a51206387d',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='d5fe7ae1-2c63-4760-b92c-7846c794576e',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
    {type='Facility', dbid=630,guid='d9ef2a02-28c6-4791-b675-5959571b38b0',}, --SAM Bn (SA-2d Guideline [S-75 Dvina])
}

for k,v in ipairs(preplacedEnemySHORAD) do
    JitterPosition(v.guid,5)
end

local randomAAA = {
	193, --AAA Bty (57mm ZSU-57-2 x 4)
    222, --AAA Bty (37mm Type 65 Twin x 4)
    621, --AAA Bty (ZPU-2 x 4 + Fire Can FC)
    628, --AAA Bty (12.7mm DSHK x 4)
    633, --SAM Sec (SA-7a Grail MANPADS x 4)
    634, --AAA Bty (57mm M1950 x 4)
}

local numberOfRandomAAA = math.random(12,24)

for i = 1,numberOfRandomAAA do
	local randomType = randomAAA[math.random(1,#randomAAA)]
	local errorCount = 0
	::redoPositionAAA::
	local position = RandomPosition(20,21,105,107)
	if OverWater(position.latitude,position.longitude) then 
		errorCount = errorCount + 1
		if errorCount <= 500 then
			goto redoPositionAAA
		else
			BugMessage('Game_Setup','Unable to place random AAA  #'..i..' after 500 attempts!')
			break
		end
	end
	
	local unit = ScenEdit_AddUnit({
		side='North Vietnam',
		type='Facility',
		dbid=randomType,
		name='Random AAA #'..i,
		lat=position.latitude,
		lon=position.longitude
	})
end