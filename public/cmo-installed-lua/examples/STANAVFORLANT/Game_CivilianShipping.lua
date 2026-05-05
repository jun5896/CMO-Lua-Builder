local shipList = {
	{
		name = "Passenger",
		{dbid=285, prefix='MS', category='Passenger',}, -- Commercial Cruise Liner [45,000t GT] -- Commercial (Commercial)
		{dbid=509, prefix='MS', category='Passenger',}, -- Commercial Ferry [1,900t DWT] -- Commercial (Commercial)
	},
	{
		name = "Pleasure",
		{dbid=1866, prefix='MY', category='Pleasure',}, -- Civilian Motor Yacht [13m] -- Civilian (Civilian)
		{dbid=603, prefix='MY', category='Pleasure',}, -- Civilian Motor Yacht [38m] -- Civilian (Civilian), 125 feet
		{dbid=664, prefix='SY', category='Pleasure',}, -- Civilian Sailboat [23m] -- Civilian (Civilian)
		{dbid=665, prefix='SY', category='Pleasure',}, -- Civilian Sailboat [38m] -- Civilian (Civilian)
	},
	{
		{dbid=1868, prefix='MV', category='Commercial',}, -- Commercial Container Vessel - Feeder [1,600 TEU, 20,000t DWT] -- Commercial (Commercial)
		{dbid=1867, prefix='MV', category='Commercial',}, -- Commercial Container Vessel - Feedermax [3,000 TEU, 30,000t DWT] -- Commercial (Commercial)
		{dbid=1869, prefix='MV', category='Commercial',}, -- Commercial Container Vessel - Panamax [4,500 TEU, 65,000t DWT] -- Commercial (Commercial)
		{dbid=1870, prefix='MV', category='Commercial',}, -- Commercial Container Vessel - Small Feeder [100 TEU, 5,750t DWT] -- Commercial (Commercial)
		{dbid=1871, prefix='MV', category='Commercial',}, -- Commercial Container Vessel - Small Feeder [750 TEU, 9,500t DWT] -- Commercial (Commercial)
		{dbid=2366, prefix='MV', category='Commercial',}, -- Commercial Dry-Bulk Carrier - Capesize Size [150,000t DWT] -- Commercial (Commercial)
		{dbid=273, prefix='MV', category='Commercial',}, -- Commercial Dry-Bulk Carrier - Handymax Size [45,000t DWT] -- Commercial (Commercial)
		{dbid=663, prefix='MV', category='Commercial',}, -- Commercial Dry-Bulk Carrier - Handysize [35,000t DWT] -- Commercial (Commercial)
		{dbid=2365, prefix='MV', category='Commercial',}, -- Commercial Dry-Bulk Carrier - Panamax Size [75,000t DWT] -- Commercial (Commercial)
		{dbid=650, prefix='MV', category='Commercial',}, -- Commercial Dry-Bulk Carrier - Small Handysize [25,000t DWT] -- Commercial (Commercial)
		{dbid=2364, prefix='MV', category='Commercial',}, -- Commercial Dry-Bulk Carrier - Supramax Size [55,000t DWT] -- Commercial (Commercial)
		{dbid=2117, prefix='FT', category='Commercial',}, -- Commercial Factory Trawler [2,500t DWT] -- Commercial (Commercial)
		{dbid=1865, prefix='FV', category='Commercial',}, -- Commercial Fishing Boat [23m] -- Commercial (Commercial)
		{dbid=508, prefix='FV', category='Commercial',}, -- Commercial Fishing Boat [35m] -- Commercial (Commercial)
		{dbid=2118, prefix='FT', category='Commercial',}, -- Commercial Large Trawler [1,250t DWT] -- Commercial (Commercial)
		{dbid=256, prefix='LNC/C', category='Commercial',}, -- Commercial LNG/LPG Tanker [18,000t DWT] -- Commercial (Commercial)
		{dbid=660, prefix='CF', category='Commercial',}, -- Commercial RO/RO Vessel [11,500t DWT] -- Commercial (Commercial)
		{dbid=252, prefix='CF', category='Commercial',}, -- Commercial RO/RO Vessel [18,000t DWT] -- Commercial (Commercial)
		{dbid=655, prefix='OSV', category='Commercial',}, -- Commercial Supply Vessel [2,900t DWT] -- Commercial (Commercial)
		{dbid=287, prefix='OSV', category='Commercial',}, -- Commercial Supply Vessel [6,000t DWT] -- Commercial (Commercial)
		{dbid=651, prefix='MT', category='Commercial',}, -- Commercial Tanker - General Purpose [20,000t DWT] -- Commercial (Commercial)
		{dbid=580, prefix='MT', category='Commercial',}, -- Commercial Tanker - Large Range 1 [75,000t DWT] -- Commercial (Commercial)
		{dbid=258, prefix='MT', category='Commercial',}, -- Commercial Tanker - Large Range 2 [150,000t DWT] -- Commercial (Commercial)
		{dbid=259, prefix='MT', category='Commercial',}, -- Commercial Tanker - Medium Range [40,000t DWT] -- Commercial (Commercial)
		{dbid=2119, prefix='FT', category='Commercial',}, -- Commercial Trawler [800t DWT] -- Commercial (Commercial)

	},
}

local shipNames = {
	{
		name = "Commercial",
		'Ad Lib',
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
		'Aquaria',
		'Aquitania',
		'Architect',
		'Ariel',
		'Asia',
		'Baraka',
		'Beluga',
		'Benthic Explorer',
		'Beowolf',
		'Beverly Hills',
		'Bhangra Knights',
		'Black Hawk',
		'Black Pearl',
		'Black Swan',
		'Black Wind',
		'Blair',
		'Blue Moon',
		'Bobka',
		'Borealis',
		'Brandenburg',
		'Brave Joffrey',
		'Bravelove One',
		'Braverus',
		'Britannic',
		'Brooke Lynn',
		'Buccleuch',
		'Butterface',
		'Cain',
		'Caledonia II',
		'Calypso',
		'Cape Bay',
		'Cape Cross',
		'Cape Falcon',
		'Cape Flamingo',
		'Cape Heron',
		'Cape Osprey',
		'Cape Owl',
		'Cape Stork',
		'Carmen',
		'Carpe Diem',
		'Castro del Gato',
		'Chachki',
		'Charlie',
		'Charlotte',
		'Charon',
		'Cheshire',
		'Chicken Hawk',
		'Claridon',
		'Cleopatra',
		'Colossus',
		'Cosmo',
		'Cotswold',
		'Cracker',
		'Crescent Star',
		'Da Vinci',
		'Dagat Ahas',
		'Dagger',
		'Davenport',
		'Dax',
		'Deep Quest',
		'Delta',
		'Derrick',
		'Diamond',
		'Dida',
		'Disco Stu',
		'Divinus',
		'Duhallow',
		'Dulcibella',
		'Dusty Ray',
		'Eastern Spirit',
		'Ecstasea',
		'Edinburgh Trader',
		'Elaine',
		'Element',
		'Elisabeth Dane',
		'Empress',
		'Envy',
		'Ergenstrasse',
		'Esgred',
		'Essess',
		'Eureka',
		'Falcon Bay',
		'Falcon',
		'Farrah',
		'Fenris',
		'Fierce',
		'Fingerdancer',
		'Flying Dutchman',
		'Flying Wasp',
		'Forlorn Hope',
		'Fortunate Son',
		'Fortune Bay',
		'Fortune Symphony',
		'Freedom',
		'Fury',
		'Galileo',
		'Ganache',
		'Genoa Maru',
		'Geofon',
		'George',
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
		'Grasshopper',
		'Great Kraken',
		'Grey Ghost',
		'Hahnchen Maru',
		'Hai Peng',
		'Happy Days',
		'Hardhand',
		'Heart',
		'Henrietta ',
		'Here Comes the Sun',
		'Honey',
		'Hung Lo',
		'Huntress',
		'Hytes',
		'Illusion',
		'Imagine',
		'Iman',
		'Immer Essen',
		'Imperius',
		'India',
		'Initial D',
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
		'Jerry',
		'Joslyn',
		'Jujubee',
		'Kahanna',
		'Kalorie',
		'Kameron',
		'Kasha',
		'Katya',
		'Kennedy Davenport',
		'Kenya',
		'Kestrel',
		'Kimora',
		'Kite Bay',
		'Kite',
		'Kolga',
		'Kramer',
		'La Familia',
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
		'Mayhem',
		'Mecsca',
		'Mercedes',
		'Miden Max',
		'Milan',
		'Milfio',
		'Miller',
		'Minnow Johnson',
		'Missing Link',
		'Monet X',
		'Monique',
		'Monsoon',
		'Montrese',
		'Morgan',
		'Morning Star ',
		'Morrigan',
		'Mykonos Bay',
		'Nathan Ross',
		'Nautilus',
		'Naysha Lopez',
		'Nekulturny',
		'Newcastle Max',
		'Nicoline Bulker',
		'Nightflyer',
		'Nina',
		'Ning-Po',
		'Nordic London',
		'Nordic Riga',
		'Nordic Stockholm',
		'Nordic Visby',
		'Nutmeg',
		'Ocean Plunderer',
		'Ocean Prefect',
		'Ocean Prelate',
		'Octopus',
		'Oddly',
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
		'Plastique',
		'Poseidon',
		'Power Ranger',
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
		'Rebel',
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
		'Scarlet',
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
		'Shuga',
		'Silky',
		'Silverfin',
		'Soju',
		'Southern Queen',
		'Sparrowhawk',
		'Spartacus',
		'St Helen',
		'St. Clair',
		'St. Georges',
		'Starfish',
		'Sweet Cersei',
		'Tanager',
		'Tatianna',
		'Tempest',
		'Ten Jin Maru',
		'Tiara',
		'Trinity',
		'Turtle',
		'Twinh Khass',
		'Tyra',
		'Ulysses',
		'Valentina',
		'Van Delay',
		'Vanessa Mateo',
		'Vanjie',
		'Velour',
		'Venture',
		'Venus',
		'Versace',
		'Viktor Kotik',
		'Viktorius',
		'Vivacious',
		'Vivienne',
		'Vixen',
		'Wanderer',
		'Warhammer',
		'West',
		'Willam',
		'Windbreaker',
		'Yara Sofia',
		'Yuhua Hamasaki',
		'Yvie',
		'Zahara',
		'Zelbess',
		"A'Keria",
		"Dagon's Feast",
		"Hawk's Vengeance",
		"Herman's Folly",
		"Kraken's Kiss",
		"Maiden's Bane",
		"O'Hara",
		"Ra'Jah",
		"St. Kevin's Ire",
		"Witch's Kiss",
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
		'Fame',
		'Festivus',
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
		'Pedant',
		'Penny',
		'Peppermint',
		'Porkchop',
		'Pure Bliss',
		'Rachel',
		'Rebecca Glasscock',
		'Retox',
		'Reverse Kangaroo',
		'Ride to Virginia',
		'Rip Tickle',
		'Salty Hippo',
		'Salty Wench',
		'Sasha',
		'Seattle Sook',
		'Senor Holdsagrudge',
		'Serena',
		'Serenity Now',
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
		'White Widow',
		'Wild',
		'Woe',
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
	{name = 'Shipping Route A6', radius = 50},
	{name = 'Shipping Route A7', radius = 50},
}

local rpList_2 = {
	{name = 'Shipping Route B1', radius = 50},
	{name = 'Shipping Route B2', radius = 50},
	{name = 'Shipping Route B3', radius = 50},
	{name = 'Shipping Route B4', radius = 50},
	{name = 'Shipping Route B5', radius = 50},
}

local rpList_3 = {
	{name = 'Shipping Route C1', radius = 50},
	{name = 'Shipping Route C2', radius = 50},
	{name = 'Shipping Route C3', radius = 50},
	{name = 'Shipping Route C4', radius = 50},
	{name = 'Shipping Route C5', radius = 50},
}

local function AddRandomShipping(latitude, longitude, ship_type)
	local shipSubList = {}

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