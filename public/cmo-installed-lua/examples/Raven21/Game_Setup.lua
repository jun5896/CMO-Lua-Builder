math.randomseed(os.time())

local opforSubs = {
	{name='B 474', guid='a53cf9c5-525c-45d8-baf8-89d20cb84670'},
}

for k,v in ipairs (opforSubs) do
	local unit = ScenEdit_GetUnit({guid=v.guid})
	local randomPos = CircularRandomPosition(unit.latitude, unit.longitude, 20)
	if OverWater(randomPos.latitude,randomPos.longitude) then
		ScenEdit_SetUnit({guid=unit.guid,latitude=randomPos.latitude,longitude=randomPos.longitude})
	end
end

--Set weather
WeatherDrift()

if DebugModeIsOn() then
	WeatherReport('WEATHER INITIALISED')
end

local function RandomPosition(latitudeMin,latitudeMax,longitudeMin,longitudeMax)
	local lat_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local lon_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local pos_lat = math.random(latitudeMin,latitudeMax) + (lat_var/(10^13)) --latitude; 
	local pos_lon = math.random(longitudeMin,longitudeMax) + (lon_var/(10^13)) --longitude; 
	return {latitude=pos_lat,longitude=pos_lon}
end

--Randomly place false contacts
local False_DBIDs = {
	95, --Large
	94, --Medium
	93 --Small
}

local falseQty =  math.random(24,32)

for i = 1,falseQty do
	::redoPositionFalse::
	local position = RandomPosition(10,13,43,49)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -10 or pos_elev < -500 then goto redoPositionFalse end
	local randomType = math.random(1,3)
	ScenEdit_AddUnit({side='Nature',type='Submarine',dbid=False_DBIDs[randomType],name='False Contact '..i,lat=position.latitude,lon=position.longitude})
end

--Randomly place biologicals; 60% fish, 20% Orca, 20% Whale
local Biol_DBIDs = {
	220,
	220,
	92
}

local biolQty = math.random(24,32)

for i = 1,biolQty do
	if i <= biolQty * 0.6 then
		randomType = Biol_DBIDs[1]
	elseif i <= biolQty * 0.8 then
		randomType = Biol_DBIDs[2]
	else
		randomType = Biol_DBIDs[3]
	end
	::redoPositionBiologics::
	local position = RandomPosition(10,13,43,49)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -25 then goto redoPositionBiologics end
	
	local unit = ScenEdit_AddUnit({side='Nature',type='Submarine',dbid=randomType,name='Biol Contact '..i,lat=position.latitude,lon=position.longitude})
	ScenEdit_AssignUnitToMission(unit.name, 'Wander')
end

------------------------------------------------------------Civilian Shipping

local shipList = {
	{
		name = "Passenger",
		{dbid=285,prefix='MS ', category ='Passenger'},--cruise liner
		{dbid=285,prefix='MS ', category ='Passenger'},--cruise liner
		{dbid=285,prefix='MS ', category ='Passenger'},--cruise liner (included x 3 for 75% population)
		{dbid=509,prefix='MS ', category ='Passenger'},  --ferry (might not make a week at cruise
		{dbid=603,prefix='MSY ', category ='Passenger'} --motor yacht 38m

	},
	{
		name = "Pleasure",
		{dbid=603,prefix='MY ', category ='Pleasure'},--motor yacht 38m
		{dbid=664,prefix='SV ', category ='Pleasure'}, --civilian sailboat 23m
		{dbid=665,prefix='SY ', category ='Pleasure'} --civilian sailboat 38m
	},
	{
		name = "Commercial",
		{dbid=1867,prefix='MV ', category ='Commercial'}, --feedermax 30,000
		{dbid=287,prefix='MV ', category ='Commercial'}, --supply vessel 6,000
		{dbid=1318,prefix='MTS ', category ='Commercial'}, --ocean going tug
		{dbid=256,prefix='LPG/C ', category ='Commercial'}, --LNG/LPG tanker
		{dbid=2117,prefix='FT ', category ='Commercial'}, --factory trawler
		{dbid=273,prefix='MV ', category ='Commercial'},--dry bulk 45,000
		{dbid=650,prefix='MV ', category ='Commercial'},--dry bulk 25,000
		{dbid=651,prefix='MT ', category ='Commercial'}, --tanker
		{dbid=580,prefix='AOG ', category ='Commercial'}, --tanker LR
		{dbid=2118,prefix='FV ', category ='Commercial'},--large trawler
		{dbid=508,prefix='FV ', category ='Commercial'} --fishing boat 35m
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
		'Retox',
		'Diamonds are Forever',
		'Disco Volante',
		'Disco Freddy',
		'Double Down',
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
		"Nina Bo'nina Brown",
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
		'Rip Tickle',
		'Salty Hippo',
		'Salty Wench',
		'Sasha',
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
		'White Widow',
		'Wild',
		'Woe',
	},
		
	{
		name = "Passenger",
		"Starfish Aroma",
		'Allure Of The Seas',
		'Carnival Fascination',
		'Carnival Triumph',
		'Discovery Sun',
		'Endless Conga',
		'Final Destination',
		'Freedom of the Seas',
		'Gastro Adventure',
		'Inescapable Experience',
		'Maria Doria',
		'Maria Narcissa',
		'No Refunds',
		'Ocean Atlantic',
		'Rainbow Festival',
		'Sea Spirit',
		'Stahpiwannagetoff',
		'The Nauseator',
		'Titanic II',
		'Wonkatania',
	},
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

local shippingAmount = math.random(20,40)

for i = 1, shippingAmount do

	if i <= shippingAmount * 0.8 then
		shipType = 'Commercial'
	elseif i <= shippingAmount * 0.95 then
		shipType = 'Pleasure'
	else
		shipType = 'Passenger'
	end
	
	
	redoCounter = 0
	::redoRandomPosition::
	
	randomPos = RandomPosition(10,13,43,49)

	if OverWater(randomPos.latitude,randomPos.longitude) then
		unit = AddRandomShipping(randomPos.latitude,randomPos.longitude,shipType)
		ScenEdit_AssignUnitToMission(unit.name,'Civilian Shipping')
	elseif redoCounter < 500 then
		redoCounter = redoCounter + 1
		goto redoRandomPosition
	else
		BugMessage('Game_Setup','Unable to find a suitable position after 500 attempts.')
	end
end