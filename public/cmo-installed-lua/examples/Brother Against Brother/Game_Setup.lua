math.randomseed(os.time())

--Set weather
WeatherDrift()

if DebugModeIsOn() then
	WeatherReport('WEATHER INITIALISED')
end

--Generate Rebel Base
local randomNum = math.random(1,3)
local selectedSeed = ScenEdit_GetReferencePoint({
	side='Rebels',
	name='Seed '..randomNum})

local rebelBaseLocation = CircularRandomPosition(selectedSeed.latitude,selectedSeed.longitude,20)


local rebelBase = ScenEdit_AddReferencePoint({side='Rebels',
	name='Rebel Base',
	latitude=rebelBaseLocation.latitude,
	longitude=rebelBaseLocation.longitude})
	
local rebelForces = {
	{dbid = 626, type = 'Facility', namePrefix = 'Rebel Inf Plt ', minNumber = 4, maxNumber = 4},
	{dbid = 1496, type = 'Facility', namePrefix = 'Rebel Ammo Pad ', minNumber = 2, maxNumber = 3},
	{dbid = 1749, type = 'Facility', namePrefix = 'Rebel Tents ', minNumber = 3, maxNumber = 5},
	{dbid = 1522, type = 'Facility', namePrefix = 'Rebel AAA Sec ', minNumber = 3, maxNumber = 3},
}
local totalRebelUnits = 0
for k,v in ipairs (rebelForces) do
	local randomAmount = math.random(v.minNumber,v.maxNumber)
	for i = 1,randomAmount do
		local randomPosition = CircularRandomPosition(rebelBase.latitude, rebelBase.longitude, 0.5)
		local unit = ScenEdit_AddUnit({
			side='Rebels',
			type=v.type,
			dbid=v.dbid,
			name=v.namePrefix..' '..i,
			latitude=randomPosition.latitude,
			longitude=randomPosition.longitude,
			autodetectable=false
		})
		totalRebelUnits = totalRebelUnits + 1
	end
end

ScenEdit_SetKeyValue('totalRebelUnits',tostring(totalRebelUnits))

if DebugModeIsOn() then
	ScenEdit_SpecialMessage('playerside',
	'Rebel Base created; '..totalRebelUnits..' rebel units added')
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
	local position = RandomPosition(9,15,-78,-70)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -10 or pos_elev < -500 then goto redoPositionFalse end
	local randomType = math.random(1,3)
	ScenEdit_AddUnit({side='Nature',type='Submarine',dbid=False_DBIDs[randomType],name='False Contact '..i,lat=position.latitude,lon=position.longitude})
end

--Randomly place biologicals; 60% fish, 20% Orca, 20% Whale
local Biol_DBIDs = {
	354, --Fish
	354, --Orcas
	92 --Whale
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
	local position = RandomPosition(9,15,-78,-70)
	local pos_elev = World_GetElevation(position)
	if pos_elev > -25 then goto redoPositionBiologics end
	
	local unit = ScenEdit_AddUnit({side='Nature',type='Submarine',dbid=randomType,name='Biol Contact '..i,lat=position.latitude,lon=position.longitude})
	ScenEdit_AssignUnitToMission(unit.name, 'Wander')
end

------------------------------------------------------------Civilian Shipping

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
	
	randomPos = RandomPosition(9,15,-78,-70)

	if OverWater(randomPos.latitude,randomPos.longitude) then
		unit = AddRandomShipping(randomPos.latitude,randomPos.longitude,shipType)
		ScenEdit_AssignUnitToMission(unit.name,'Civilian Shipping')
	elseif redoCounter < 500 then
		redoCounter = redoCounter + 1
		goto redoRandomPosition
	else
		print ('Unable to find a suitable position after 500 attempts.')
	end
end