math.randomseed(os.time())

local airGroups = {
	{name='Flight 18', guid='adc517c9-da68-4a94-a37c-e21f31c90169'} , 
	{name='Flight 19', guid='938ce65f-094f-44f5-bb86-ee41f4022ae3'} , 
	{name='Flight 20', guid='d04eb74d-2332-4093-9029-fa731170cfe0'} , 
	{name='Flight 21', guid='41fb1c47-efc0-4628-9ee9-8dc39d9e1dfc'}
}

local centrePoint = ScenEdit_GetReferencePoint({side='OPFOR',name='Centrepoint'})

for k,v in ipairs (airGroups) do 
	local newPos = CircularRandomPosition(centrePoint.latitude,centrePoint.longitude,75)
	ScenEdit_SetUnit({
		guid=v.guid,
		latitude=newPos.latitude,
		longitude=newPos.longitude
	})
end

local airDefences = {
	{name='AAA Bty (37mm T65 Twin x 4)', guid='5216f419-a72b-4b1b-8a21-68b22975cb25', range=0.5} , 
	{name='SAM Plt (SA-9b Gaskin [9K31 Strela-1])', guid='c2b5adf4-c3ea-4ba1-9ada-455bfc8a4c5e', range = 0.5} , 
	{name='AAA Bty (57mm M1950 x 4 + Fire Can FC)', guid='6c6aaba2-1003-4d19-a36d-e8176b725e4d', range = 4} , 
	{name='SAM  (SA-3b Goa)', guid='6ced4e83-bbbc-4fd1-9078-9f18f686809a', range= 10}
}

for k,v in ipairs (airDefences) do 
	local newPos = CircularRandomPosition(centrePoint.latitude,centrePoint.longitude,v.range/2)
	ScenEdit_SetUnit({
		guid=v.guid,
		latitude=newPos.latitude,
		longitude=newPos.longitude
	})
end

RandomiseSideUnitProficiency('OPFOR')