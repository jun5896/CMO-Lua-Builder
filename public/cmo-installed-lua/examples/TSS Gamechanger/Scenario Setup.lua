unit = ScenEdit_GetUnit({name='TG-42', guid='197f2ba4-4b6b-4b6a-8243-ece7f7639eb1'})
destination = {latitude='32.3797352130779', longitude='-64.811248440954'}
rejoin_point = World_GetPointFromBearing({latitude=unit.latitude,longitude=unit.longitude,distance=50,bearing=90})
scatter_leg = World_GetPointFromBearing({latitude=unit.latitude,longitude=unit.longitude,distance=math.random(20,50),bearing=math.random(30,150)}) --determine first leg of scatter
dist_rem = Tool_Range({latitude=rejoin_point.Latitude,longitude=rejoin_point.Longitude},{latitude=destination.latitude,longitude=destination.longitude})
legs = round(dist_rem/50)
scatter_course = {scatter_leg,rejoin_point} --create initial scatter
dest_brg = round(Tool_Bearing({latitude=unit.latitude,longitude=unit.longitude},{latitude=rejoin_point.Latitude,longitude=rejoin_point.Longitude}))

if legs >= 1 then
	for i = 1,legs do
		seq = #scatter_course
		leg = seq + 1
		length = math.random(20,30)
		::redo_variation::
		variation = math.random(-30,30)
		if variation > -10 and variation < 10 then goto redo_variation end
		heading = (dest_brg+variation)%359
		rev_heading = (dest_brg-(variation*2))%359
		leg1 = World_GetPointFromBearing({latitude=scatter_course[seq].Latitude,longitude=scatter_course[seq].Longitude,distance=length,bearing=heading})
		rev_heading = round(Tool_Bearing({latitude=leg1.Latitude,longitude=leg1.Longitude},{latitude=destination.latitude,longitude=destination.longitude}))
		leg2 = World_GetPointFromBearing({latitude=leg1.Latitude,longitude=leg1.Longitude,distance=length,bearing=rev_heading})
		scatter_course[leg] = leg1
		leg = leg + 1
		scatter_course[leg] = leg2
	end
	expected = legs + 2
end

scatter_course[#scatter_course+1]=destination
ScenEdit_SetUnit({guid=unit.guid,course=scatter_course})

-- Add False Contacts

local False_DBIDs = {
	95,
	94,
	93
}

for i = 1,math.random(12,18),1 do
	::redo_falsepos::
	local randomPosition = RandomPosition(30, 40, -75, -60)
	if not OverWater(randomPosition.latitude, randomPosition.longitude) then goto redo_falsepos end

	local x = math.random(1,3)
	local falseContact = ScenEdit_AddUnit({
		side='Nature',
		type='Submarine',
		dbid=False_DBIDs[x],
		name='False Contact '..i,
		latitude=randomPosition.latitude,
		longitude=randomPosition.longitude,
	})
end

-- Add Biologics

local Biol_DBIDs = {
	220,
	220,
	92
}

local BiolQty = math.random(8,12)

for i = 1,BiolQty,1 do
	::redo_biolpos::
	local randomPosition = RandomPosition(30, 40, -75, -60)
	if not OverWater(randomPosition.latitude, randomPosition.longitude) then goto redo_biolpos end

	local x = math.random(1,3)
	local biologic = ScenEdit_AddUnit({
		side='Nature',
		type='Submarine',
		dbid=Biol_DBIDs[x],
		name='Biol Contact '..i,
		latitude=randomPosition.latitude,
		longitude=randomPosition.longitude})

	ScenEdit_AssignUnitToMission(biologic.name, 'Whale')
end

-- Add Shipping

ports = {'New York', 'Norfolk', 'Bermuda'}
seas = {'North', 'South', 'East'}
seas_and_ports = {'New York', 'Norfolk', "Bermuda", 'North', 'South', 'East'}

local names = {
	RecNames = {
		'Ad Lib',
		'Addiction',
		'Alibi',
		'Ambrosia',
		'Baraka',
		'Blue Moon',
		'Bravelove One',
		'Calypso',
		'Carpe Diem',
		'Cleopatra',
		'Da Vinci',
		'Diamonds are Forever',
		'Double Down',
		'Ecstasea',
		'Element',
		'Falcon',
		'Fortunate Son',
		'Freedom',
		'Golden Eagle',
		'Here Comes the Sun',
		'Happy Days',
		'High Power III',
		'Illusion',
		'Imagine',
		'Huntress',
		'Honey',
		'Incognito',
		'Invader',
		'Jazz',
		'Katya',
		'La Familia',
		'Liberty',
		'Match Point',
		'Mayan Queen IV',
		'Missing Link',
		'Octopus',
		'Never Enough',
		'Odyssey',
		'Pure Bliss',
		'Queen K',
		'Ranger',
		'Rebel'
	},

	CommNames = {
		'Aquitania',
		'Braverus',
		'Buccleuch',
		'Cape Cross',
		'Cape Bay',
		'Cape Falcon',
		'Cape Flamingo',
		'Cape Heron',
		'Cape Osprey',
		'Cape Owl',
		'Cape Stork',
		'Viktorius',
		'Castro del Gato',
		'Cheshire',
		'Colossus',
		'Cotswold',
		'Divinus',
		'Duhallow',
		'Falcon Bay',
		'Fortune Bay',
		'Fortune Symphony',
		'Galileo',
		'Geraldine Manx',
		'Giants Causeway',
		'Good Hope Max',
		'Grasshopper',
		'Iron Baron',
		'Imperius',
		'Iron King',
		'James Prior',
		'Kite Bay',
		'Lena B',
		'Mecsca',
		'Miden Max',
		'Mykonos Bay',
		'Newcastle Max',
		'Nicoline Bulker',
		'Nordic London',
		'Nordic Riga',
		'Nordic Stockholm',
		'Nordic Visby',
		'Ocean Prefect',
		'Ocean Prelate',
		'Olympius',
		'Paradise Bay',
		'Power Ranger',
		'Premiership',
		'Ronez',
		'Sadlers Wells',
		'Spartacus',
		'Ten Jin Maru',
		'St Helen'
	},

	PassNames = {
		'Allure Of The Seas',
		'Carnival Fascination',
		'Carnival Triumph',
		'Discovery Sun',
		'Explorer',
		'Freedom of the Seas',
		'Island Sky',
		'Ocean Atlantic',
		'Sea Spirit',
		'Superstar Aquarius'
	}
}

local types = {
	RecTypes={
		{dbid=603,prefix='MY '},--motor yacht 38m
		{dbid=664,prefix='SV '}, --civilian sailboat 23m
		{dbid=665,prefix='SY '} --civilian sailboat 38m
	},

	CommTypes={
		{dbid=1867,prefix='MV '}, --feedermax 30,000
		{dbid=287,prefix='MV '}, --supply vessel 6,000
		{dbid=1318,prefix='MTS '}, --ocean going tug
		{dbid=256,prefix='LPG/C '}, --LNG/LPG tanker
		{dbid=2117,prefix='FT '}, --factory trawler
		{dbid=273,prefix='MV '},--dry bulk 45,000
		{dbid=650,prefix='MV '},--dry bulk 25,000
		{dbid=651,prefix='MT '}, --tanker
		{dbid=580,prefix='AOG '}, --tanker LR
		{dbid=2118,prefix='FV '},--large trawler
		{dbid=508,prefix='FV '} --fishing boat 35m
	},

	PassTypes={
		{dbid=285,prefix='MS '},--cruise liner
		{dbid=285,prefix='MS '},--cruise liner
		{dbid=285,prefix='MS '},--cruise liner (included x 3 for 75% population)
		{dbid=509,prefix='MS '},  --ferry (might not make a week at cruise
		{dbid=603,prefix='MSY '} --motor yacht 38m
	},
}

for i = 1, math.random(36,48) do
	unit_type = math.random(1,10)

	if unit_type <= 6 then
		unit_type = types.CommTypes
		unit_name = names.CommNames
	elseif unit_type <= 9 then
		unit_type = types.RecTypes
		unit_name = names.RecNames
	elseif unit_type == 10 then
		unit_type = types.PassTypes
		unit_name = names.PassNames
	end

	chance = math.random(1,5)
	civ_type = unit_type[math.random(1,#unit_type)]
	origin = {}
	destination = {}
	destination1 = {}
	destination2 = {}

	if chance <= 3 then --random pos
		::redo_pos_1::
		local origin = CircularRandomPosition(math.random(30, 40), math.random(-75, -60), math.random(1, 100))
		if not OverWater(origin.latitude, origin.longitude) then goto redo_pos_1 end

		dest1 = ScenEdit_GetReferencePoint({side='Civilian', name=seas_and_ports[math.random(1,#seas_and_ports)]})
		destination1.latitude = dest1.latitude
		destination1.longitude = dest1.longitude

		dest2 = ScenEdit_GetReferencePoint({side='Civilian', name=seas_and_ports[math.random(1,#seas_and_ports)]})
		destination2.latitude = dest2.latitude
		destination2.longitude = dest2.longitude
		if destination1 == destination2 then goto redo_pos_1 end

		local ship = ScenEdit_AddUnit({
			side='Civilian',
			type='Ship',
			dbid=civ_type.dbid,
			name=civ_type.prefix..unit_name[math.random(1,#unit_name)],
			latitude=origin.latitude,
			longitude=origin.longitude,
			course={destination1, destination2, origin}
		})
	elseif chance == 4 then --at sea
		::redo_pos_2::
		a_origin = ScenEdit_GetReferencePoint({side='Civilian', name=seas[math.random(1,#seas)]})
		local origin = CircularRandomPosition(a_origin.latitude, a_origin.longitude, math.random(10,1000)/10)
		if not OverWater(origin.latitude, origin.longitude) then goto redo_pos_2 end

		a_destination = ScenEdit_GetReferencePoint({side='Civilian',name=ports[math.random(1,#ports)]})
		destination.latitude=a_destination.latitude
		destination.longitude=a_destination.longitude

		local ship = ScenEdit_AddUnit({
			side='Civilian',
			type='Ship',
			dbid=civ_type.dbid,
			name=civ_type.prefix..unit_name[math.random(1,#unit_name)],
			latitude=origin.latitude,
			longitude=origin.longitude,
			course={destination, origin}
		})
	elseif chance == 5 then --in port
		::redo_pos_3::
		a_origin = ScenEdit_GetReferencePoint({side='Civilian', name=ports[math.random(1,#ports)]})
		local origin = CircularRandomPosition(a_origin.latitude, a_origin.longitude, math.random(10,1000)/10)
		if not OverWater(origin.latitude, origin.longitude) then goto redo_pos_3 end

		a_destination = ScenEdit_GetReferencePoint({side='Civilian', name=seas[math.random(1,#seas)]})
		destination.latitude=a_destination.latitude
		destination.longitude=a_destination.longitude
		local ship = ScenEdit_AddUnit({
			side='Civilian',
			type='Ship',
			dbid=civ_type.dbid,
			name=civ_type.prefix..unit_name[math.random(1,#unit_name)],
			latitude=origin.latitude,
			longitude=origin.longitude,
			course={destination, origin}
		})
	end
end