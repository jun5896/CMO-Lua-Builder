local shipList = {
	{
		name = "Passenger",
		{dbid=384, prefix='MS ', category ='Passenger'}, --Commercial Cruise Liner [135000 GT]
		{dbid=2024, prefix='MS ', category ='Passenger'}, --Commercial Cruise Liner [45000 GT]
	},
	{
		name = "Pleasure",
		{dbid=2696, prefix='MV ', category ='Pleasure'}, --Civilian Go Fast [13m]
		{dbid=1474, prefix='MY ', category ='Pleasure'}, --Civilian Motor Yacht [13m]
		{dbid=1475, prefix='MY ', category ='Pleasure'}, --Civilian Motor Yacht [38m]
		{dbid=2398, prefix='SY ', category ='Pleasure'}, --Civilian Sailboat [20m - high speed]
		{dbid=1378, prefix='SY ', category ='Pleasure'}, --Civilian Sailboat {23m]
		{dbid=1379, prefix='SY ', category ='Pleasure'}, --Civilian Sailboat [38m]
		{dbid=1789, prefix='MV ', category ='Pleasure'}, --Civilian Small Boat [7m]
	},
	{
		name = "Commercial",
		{dbid=775, prefix='MV ', category ='Commercial'}, --Commercial Container Vessel - Feeder [1600 TEU, 20000 DWT]
		{dbid=2027, prefix='MV ', category ='Commercial'}, --Commercial Container Vessel - Feedermax [3000 TEU, 30000 DWT]
		{dbid=2029, prefix='MV ', category ='Commercial'}, --Commercial Container Vessel - New Panamax [13500 TEU, 155000 DWT]
		{dbid=2028, prefix='MV ', category ='Commercial'}, --Commercial Container Vessel - Panamax [4500 TEU, 65000 DWT]
		{dbid=2030, prefix='MV ', category ='Commercial'}, --Commercial Container Vessel - Post Panamax [9500 TEU, 105000 DWT]
		{dbid=774, prefix='MV ', category ='Commercial'}, --Commercial Container Vessel - Small Feeder [100 TEU, 5750 DWT]
		{dbid=2026, prefix='MV ', category ='Commercial'}, --Commercial Container Vessel - Small Feeder [750 TEU, 9500 DWT]
		{dbid=2031, prefix='MV ', category ='Commercial'}, --Commercial Container Vessel - Ultra Large [15000 TEU, 160000 DWT]
		{dbid=2775, prefix='MV ', category ='Commercial'}, --Commercial Dry-Bulk Carrier [Capesize Size 150000 DWT]
		{dbid=2023, prefix='MV ', category ='Commercial'}, --Commercial Dry-Bulk Carrier [Handymax Size 45000 DWT]
		{dbid=773, prefix='MV ', category ='Commercial'}, --Commercial Dry-Bulk Carrier [Handysize 35000 DWT]
		{dbid=2774, prefix='MV ', category ='Commercial'}, --Commercial Dry-Bulk Carrier [Panamax Size 75000 DWT]
		{dbid=1001, prefix='MV ', category ='Commercial'}, --Commercial Dry-Bulk Carrier [Small Handysize, Helo Deck 25000 DWT]
		{dbid=1374, prefix='MV ', category ='Commercial'}, --Commercial Dry-Bulk Carrier [Small Handysize 25000 DWT]
		{dbid=2773, prefix='MV ', category ='Commercial'}, --Commercial Dry-Bulk Carrier [Supramax Size 55000 DWT]
		{dbid=2776, prefix='MV ', category ='Commercial'}, --Commercial Dry-Bulk Carrier [Very Large Size 200000 DWT]
		{dbid=1006, prefix='HLV ', category ='Commercial'}, --Commercial Heavy Lift Vessel -  [40000 DWT]
		{dbid=222, prefix='LNC/C ', category ='Commercial'}, --Commercial LNG/LPG Tanker -  [18000 DWT]
		{dbid=1599, prefix='C/F ', category ='Commercial'}, --Commercial RO/RO Vessel -  [11500 DWT]
		{dbid=2034, prefix='C/F ', category ='Commercial'}, --Commercial RO/RO Vessel -  [18000 DWT]
		{dbid=1002, prefix='OSV ', category ='Commercial'}, --Commercial Supply Vessel -  [2900 DWT]
		{dbid=1317, prefix='OSV ', category ='Commercial'}, --Commercial Supply Vessel -  [6000 DWT]
		{dbid=144, prefix='MT ', category ='Commercial'}, --Commercial Tanker - General Purpose [20000 DWT]
		{dbid=339, prefix='MT ', category ='Commercial'}, --Commercial Tanker - Large Range 1 [75000 DWT]
		{dbid=275, prefix='MT ', category ='Commercial'}, --Commercial Tanker - Large Range 2 [150000 DWT]
		{dbid=145, prefix='MT ', category ='Commercial'}, --Commercial Tanker - Medium Range [40000 DWT]
		{dbid=2022, prefix='MT ', category ='Commercial'}, --Commercial Tanker - Ultra Large Crude Carrier [420000 DWT]
		{dbid=259, prefix='MT ', category ='Commercial'}, --Commercial Tanker - Very Large Crude Carrier [300000 DWT]
		{dbid=16, prefix='FV ', category ='Commercial'}, --Commercial Fishing Boat [23m]
		{dbid=328, prefix='FV ', category ='Commercial'}, --Commercial Fishing Boat [35m[
		{dbid=2358, prefix='FT ', category ='Commercial'}, --Commercial Factory Trawler [2,500t DWT]
		{dbid=2359, prefix='FT ', category ='Commercial'}, --Commercial Large Trawler [1,250 DWT]
		{dbid=2357, prefix='FT ', category ='Commercial'}, --Commercial Trawler [800t DWT]
	},
}

local shipNames = {
	{
		name = "Commercial",
		'Ad Lib',
		'Aquitania',
		'Blue Moon',
		'Cape Falcon',
		'Cape Stork',
		'Cotswold',
		'Da Vinci',
		'Falcon',
		'Fortune Symphony',
		'Grasshopper',
		'Happy Days',
		'Honey',
		'Kite Bay',
		'La Familia',
		'Newcastle Max',
		'Nordic Visby',
		'Octopus',
		'Power Ranger',
		'Rebel',
		'Ten Jin Maru',
		"Dagon's Feast",
		"Hawk's Vengeance",
		"Herman's Folly",
		"Kraken's Kiss",
		"Maiden's Bane",
		"St. Kevin's Ire",
		"Witch's Kiss",
		'Addiction',
		'Aja',
		'Akashia',
		'Aksham Tarkee',
		'Alaska',
		'Alexis',
		'Alibi',
		'Alisa',
		'Ambrosia',
		'Andromeda',
		'Antaeus',
		'Baraka',
		'BD Sooky La La',
		'Beluga',
		'Benthic Explorer',
		'Beowolf',
		'Beverly Hills',
		'Bhangra Knights',
		'Black Hawk',
		'Black Pearl',
		'Black Swan',
		'Black Wind',
		'Borealis',
		'Brandenburg',
		'Brave Joffrey',
		'Bravelove One',
		'Braverus',
		'Britannic',
		'Buccleuch',
		'Butterface',
		'Caledonia II',
		'Calypso',
		'Cape Bay',
		'Cape Cross',
		'Cape Flamingo',
		'Cape Heron',
		'Cape Osprey',
		'Cape Owl',
		'Carmen',
		'Carpe Diem',
		'Castro del Gato',
		'Chachki',
		'Charlie',
		'Charlotte',
		'Charon',
		'Cheshire',
		'Claridon',
		'Cleopatra',
		'Colossus',
		'Crescent Star',
		'Dagat Ahas',
		'Dagger',
		'Dax',
		'Dax',
		'Deep Quest',
		'Delta',
		'Derrick',
		'Dida',
		'Disco Freddy',
		'Divinus',
		'Duhallow',
		'Dulcibella',
		'Eastern Spirit',
		'Ecstasea',
		'Edinburgh Trader',
		'Element',
		'Elisabeth Dane',
		'Empress',
		'Ergenstrasse',
		'Esgred',
		'Essess',
		'Eureka',
		'Falcon Bay',
		'Farrah',
		'Fenris',
		'Fierce',
		'Fingerdancer',
		'Flying Dutchman',
		'Flying Wasp',
		'Forlorn Hope',
		'Fortunate Son',
		'Fortune Bay',
		'Freedom',
		'Fury',
		'Galileo',
		'Genoa Maru',
		'Geofon',
		'Geraldine Manx',
		'Geronimo',
		'Ghost',
		'Gia Gunn',
		'Giants Causeway',
		'Glencairn',
		'Gloria N',
		'Golden Eagle',
		'Golden Rose',
		'Golden Storm',
		'Goliath',
		'Good Hope Max',
		'Great Kraken',
		'Grey Ghost',
		'Hahnchen Maru',
		'Hai Peng',
		'Hardhand',
		'Henrietta ',
		'Here Comes the Sun',
		'Hung Lo',
		'Huntress',
		'Illusion',
		'Imagine',
		'Immer Essen',
		'Imperius',
		'India',
		'Inspiration',
		'Invader',
		'Iron Baron',
		'Iron King',
		'Iron Lady',
		'Iron Victory',
		'Iron Wind',
		'Iron Wing',
		'Ivy Winters',
		'J Sotomayor',
		'Jackdaw',
		'Jade',
		'James Prior',
		'Jasmine',
		'Jazz',
		'Joslyn',
		'Jujubee',
		'Kasha',
		'Katya',
		'Kennedy Davenport',
		'Kenya',
		'Kestrel',
		'Kimora',
		'Kite',
		'Kolga',
		'Lady Joanna',
		'Lady Lyanna',
		'Lady Olenna',
		'Laganja',
		'Laila',
		'Lake',
		'Lamentation',
		'Lashauwn',
		'Latrice Royale',
		'Latvijas Vilks',
		'Lazuli',
		'Lena B',
		'Leviathan',
		'Liberty',
		'Lineysha',
		'Lioness',
		'Lionstar',
		'Liparus',
		'Lord Dagon',
		'Lord Quellon',
		'Lord Renly',
		'Lord Tywin',
		'Lord Vickon',
		'Love Nest',
		'Luna Lucura',
		'Madame',
		'Maeaq Turkia',
		'Magnolia',
		'Manila Luzon',
		'Mansfield',
		'Mantle',
		'Marie Elena',
		'Mary Deare',
		'Match Point',
		'Mayan Queen IV',
		'Mecsca',
		'Miden Max',
		'Milan',
		'Milfio',
		'Minnow Johnson',
		'Missing Link',
		'Monsoon',
		'Morgan',
		'Morning Star ',
		'Morrigan',
		'Mykonos Bay',
		'Nathan Ross',
		'Nautilus',
		'Naysha Lopez',
		'Nekulturny',
		'Nicoline Bulker',
		'Nightflyer',
		'Ning-Po',
		'Nordic London',
		'Nordic Riga',
		'Nordic Stockholm',
		'Ocean Plunderer',
		'Ocean Prefect',
		'Ocean Prelate',
		'Odyssey',
		'Olympius',
		'Ongina',
		'Orca',
		'Paradise Bay',
		'Patna',
		'Pavel Morozov',
		'Pearl',
		'Pequod',
		'Phoenix',
		'Poseidon',
		'Precious Gem',
		'Premiership',
		'Princess Irene',
		'Princess Marcella',
		'Proteus',
		'Queen K',
		'Queen Margaery',
		'Raja',
		'Raven',
		'Reaper',
		'Reapers Wind',
		'Red Dragon',
		'Red Jester',
		'Red October',
		'Red Tide',
		'Red Witch',
		'Rights-of-Man',
		'Rob Roy',
		'Robert Turner',
		'Ronez',
		'Royale',
		'Rusalka',
		'Sadlers Wells',
		'Sahara',
		'Salazar',
		'Santana',
		'Saracen',
		'Sea Cliff',
		'Sea Song',
		'Sea Star',
		'Sea Witch',
		'Seaswift',
		'Seaview',
		'Selstam Eule',
		'Seven Skulls',
		'Shangela',
		'Shannel',
		'Silverfin',
		'Southern Queen',
		'Sparrowhawk',
		'Spartacus',
		'St Helen',
		'St. Georges',
		'Starfish',
		'Sweet Cersei',
		'Tanager',
		'Tatianna',
		'Tempest',
		'Trinity',
		'Turtle',
		'Tyra',
		'Ulysses',
		'Valentina',
		'Velour',
		'Venture',
		'Venus',
		'Viktorius',
		'Vivacious',
		'Vivienne',
		'Wanderer',
		'Warhammer',
		'Willam',
		'Windbreaker',
		'Yara Sofia',
		'Zahara',
		'Zelbess',
	},
	
	{
		name = "Pleasure",
		'Acid',
		'Adore',
		'Alexis Mateo',
		'Alyssa Edwards',
		'April',
		'Arsenal Gear',
		'Bianca del Rio',
		'Big in Japan',
		'Blac Chyna',
		'Bob',
		'Candy',
		'Chad',
		'Chi Chi',
		'Chiku Shan',
		'Coco Montrese',
		'Cold Feet',
		'Courtney',
		'Crème de la Crème',
		'Cynthia Lee Fontaine',
		'Detox',
		'Diamonds are Forever',
		'Disco Freddy',
		'Disco Volante',
		'Double Down',
		'Fakya',
		'Fame',
		'Foamdrinker',
		'Ginger',
		'Happy Wanderer',
		'High Power III',
		'Honey Mahogany',
		'Incognito',
		'Inferno',
		'Jenny',
		'Jiggly',
		'Kim Chi',
		'Legitimate Businessman',
		'Mariah',
		'Max',
		'Milk',
		'Mimi',
		'Mystique',
		'Naomi',
		'Never Enough',
		'Nina Flowers',
		'Outer Haven',
		'Paige',
		'Palanquin Ship',
		'Pandora',
		'Penny',
		'Peppermint',
		'Porkchop',
		'Pure Bliss',
		'Rachel',
		'Rebecca Glasscock',
		'Retox',
		'Reverse Kangaroo',
		'Rip Tickle',
		'Salty Hippo',
		'Salty Wench',
		'Sasha',
		'Seattle Sook',
		'Senor Holdsagrudge',
		'Serena',
		'Shark',
		'Sharon',
		'Shea',
		'Silence',
		'Sonique',
		'Stacy',
		'Swiftin',
		'Tammie B',
		'The Princess',
		'Thorgy',
		'Thunderer',
		'Trinity Taylor',
		'Trixie',
		'Two Dogs',
		'Unnamed ship shaped like a rubber duck',
		'Warrior Wench',
		'Washington Wah-Wah',
		'White Widow',
		'Wild',
		'Woe',
		'Yamam',
		"Nina Bo'nina Brown",
	},
		
	{
		name = "Passenger",
		'Adultery Carnival',
		'Astronomical Bar-Tab',
		'Captive Ordeal',
		'Delhi Belly',
		'Dysentery Explorer',
		'Endless Buffet',
		'Endless Conga',
		'Eternal Sunburn',
		'Final Destination',
		'Gastro Adventure',
		'Inescapable Experience',
		'No Refunds',
		'Ocean Torment',
		'Octogenerian Explorer',
		'Rainbow Festival',
		'Sea Spirit',
		'Stahpiwannagetoff',
		'Starfish Aroma',
		'The Nauseator',
		'Titanic II',
		'Wonkatania',
	},
}

local rpList_1 = {
	{name = 'Shipping Route A1', radius = 50},
	{name = 'Shipping Route A2', radius = 50},
	{name = 'Shipping Route A3', radius = 50},
	{name = 'Shipping Route A4', radius = 50},
	{name = 'Shipping Route A5', radius = 50},
	{name = 'Shipping Route A6', radius = 30},
	{name = 'Shipping Route A7', radius = 50},
}

local rpList_2 = {
	{name = 'Shipping Route B1', radius = 50},
	{name = 'Shipping Route B2', radius = 50},
	{name = 'Shipping Route B3', radius = 50},
	{name = 'Shipping Route B4', radius = 50},
	{name = 'Shipping Route B5', radius = 50},
	{name = 'Shipping Route B6', radius = 30},
	{name = 'Shipping Route B7', radius = 50},
}

local rpList_3 = {
	{name = 'Shipping Route C1', radius = 50},
	{name = 'Shipping Route C2', radius = 50},
	{name = 'Shipping Route C3', radius = 50},
	{name = 'Shipping Route C4', radius = 50},
	{name = 'Shipping Route C5', radius = 50},
	{name = 'Shipping Route C6', radius = 50},
}

local function AddRandomShipping(latitude, longitude, ship_type)

	for k,v in ipairs (shipList) do
		if v.name == ship_type then shipSubList = v end
	end
		
	for k,v in ipairs (shipNames) do
		if v.name == ship_type then 
			randomName = math.random(1,#v)
			shipName = v[randomName]
			table.remove(v,randomName)
		end
	end
	
	local shipEntry = shipSubList[math.random(1,#shipSubList)]
	
	local addedShip = ScenEdit_AddUnit({side='Civilian', 
		name = shipEntry.prefix..shipName, 
		type = 'Ship',
		dbid = shipEntry.dbid,
		side = 'Civilian',
		latitude = latitude,
		longitude = longitude})
	return addedShip
	
end

local shippingAmount = math.random(70,100)

for i = 1, shippingAmount do

	if i <= shippingAmount * 0.8 then
		shipType = 'Commercial'
	elseif i <= shippingAmount * 0.95 then
		shipType = 'Pleasure'
	else
		shipType = 'Passenger'
	end
	
	local rpList
	
	local chance = math.random(1,3)
	if chance == 1 then
		rpList = rpList_1
	elseif chance == 2 then
		rpList = rpList_2
	elseif chance == 3 then
		rpList = rpList_3
	end
	
	local randomRPNumber = math.random(1,#rpList)
	local randomRP = rpList[randomRPNumber]

	local referencePoint = ScenEdit_GetReferencePoint({side='Civilian',name=randomRP.name})
	
	local redoCounter = 0
	::redoRandomPosition::
	
	local shipCourse = {}
	
	local chance = math.random(1,2)
	local startWP, waypoint
	
	if randomRPNumber == 1 or (chance == 1 and randomRPNumber <= #rpList - 1) then
		startWP = randomRPNumber + 1
		for i = startWP, #rpList do
			waypoint = ScenEdit_GetReferencePoint({
				side='Civilian',
				name=rpList[i].name})
			
			waypointRandomPos = CircularRandomPosition(waypoint.latitude, waypoint.longitude, 20)
			if OverWater(waypointRandomPos.latitude, waypointRandomPos.longitude) then
				table.insert(shipCourse,waypointRandomPos)
			end
		end
	else
		startWP = randomRPNumber - 1
		for i = startWP, 1, -1 do
			waypoint = ScenEdit_GetReferencePoint({
				side='Civilian',
				name=rpList[i].name})
			
			waypointRandomPos = CircularRandomPosition(waypoint.latitude, waypoint.longitude, 20)
			if OverWater(waypointRandomPos.latitude, waypointRandomPos.longitude) then
				table.insert(shipCourse,waypointRandomPos)
			end
		end
	end
	
	local randomPos = CircularRandomPosition(referencePoint.latitude,referencePoint.longitude,randomRP.radius)

	if OverWater(randomPos.latitude,randomPos.longitude) then
		unit = AddRandomShipping(randomPos.latitude,randomPos.longitude,shipType)
		ScenEdit_SetUnit({guid=unit.guid,course=shipCourse})
	elseif redoCounter < 500 then
		redoCounter = redoCounter + 1
		goto redoRandomPosition
	else
		print ('Unable to find a suitable position after 500 attempts.')
	end
end