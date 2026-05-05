math.randomseed(os.time())

local False_DBIDs = {
	95,
	94,
	93
}

for i = 1,math.random(12,18),1 do
	::redo_falsepos::
	local lat_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local lon_var = math.random(1,(10^13)) --random number between 1 and 10^13

	local pos_lat = math.random(35,40) + (lat_var/(10^13)) --latitude; 
	local pos_lon = math.random(-76,-70) + (lon_var/(10^13)) --longitude; 

	local pos_elev = World_GetElevation({lat=pos_lat,lon=pos_lon})

	if pos_elev > -30 or pos_elev < -1500 then goto redo_falsepos end

	local x = math.random(1,3)
	ScenEdit_AddUnit({side='Nature',type='Submarine',dbid=False_DBIDs[x],name='False Contact '..i,lat=pos_lat,lon=pos_lon,altitude=pos_elev+5})
end

local Biol_DBIDs = {
	354, --Fish school
	355, --Orcas
	92, --Whale
}

local BiolQty = math.random(12,18)

for i = 1,BiolQty,1 do
	::redo_biolpos::
	local lat_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local lon_var = math.random(1,(10^13)) --random number between 1 and 10^13

	local pos_lat = math.random(35,40) + (lat_var/(10^13)) --latitude; 
	local pos_lon = math.random(-76,-70) + (lon_var/(10^13)) --longitude; 

	local pos_elev = World_GetElevation({lat=pos_lat,lon=pos_lon})

	if pos_elev > -25 then goto redo_biolpos end

	local x = math.random(1,3)
	local a = ScenEdit_AddUnit({side='Nature',type='Submarine',dbid=Biol_DBIDs[x],name='Biol Contact '..i,lat=pos_lat,lon=pos_lon})

	ScenEdit_AssignUnitToMission(a.name, 'Wander')
end


ports = {
	'New York',
	'Norfolk',
}
seas = {
	'North',
	'North East',
	'East',
	'South East',
}

seas_and_ports = {
	'New York',
	'Norfolk',
	'North',
	'North East',
	'East',
	'South East'
}

merchants = {
	{dbid=775, prefix='MV '}, --Commercial Container Vessel - Feeder [1600 TEU, 20000 DWT]
	{dbid=2027, prefix='MV '}, --Commercial Container Vessel - Feedermax [3000 TEU, 30000 DWT]
	{dbid=2029, prefix='MV '}, --Commercial Container Vessel - New Panamax [13500 TEU, 155000 DWT]
	{dbid=2028, prefix='MV '}, --Commercial Container Vessel - Panamax [4500 TEU, 65000 DWT]
	{dbid=2030, prefix='MV '}, --Commercial Container Vessel - Post Panamax [9500 TEU, 105000 DWT]
	{dbid=774, prefix='MV '}, --Commercial Container Vessel - Small Feeder [100 TEU, 5750 DWT]
	{dbid=2026, prefix='MV '}, --Commercial Container Vessel - Small Feeder [750 TEU, 9500 DWT]
	{dbid=2031, prefix='MV '}, --Commercial Container Vessel - Ultra Large [15000 TEU, 160000 DWT]
	{dbid=2775, prefix='MV '}, --Commercial Dry-Bulk Carrier [Capesize Size 150000 DWT]
	{dbid=2023, prefix='MV '}, --Commercial Dry-Bulk Carrier [Handymax Size 45000 DWT]
	{dbid=773, prefix='MV '}, --Commercial Dry-Bulk Carrier [Handysize 35000 DWT]
	{dbid=2774, prefix='MV '}, --Commercial Dry-Bulk Carrier [Panamax Size 75000 DWT]
	{dbid=1001, prefix='MV '}, --Commercial Dry-Bulk Carrier [Small Handysize, Helo Deck 25000 DWT]
	{dbid=1374, prefix='MV '}, --Commercial Dry-Bulk Carrier [Small Handysize 25000 DWT]
	{dbid=2773, prefix='MV '}, --Commercial Dry-Bulk Carrier [Supramax Size 55000 DWT]
	{dbid=2776, prefix='MV '}, --Commercial Dry-Bulk Carrier [Very Large Size 200000 DWT]
	{dbid=1006, prefix='HLV '}, --Commercial Heavy Lift Vessel -  [40000 DWT]
	{dbid=222, prefix='LNC/C '}, --Commercial LNG/LPG Tanker -  [18000 DWT]
	{dbid=1599, prefix='C/F '}, --Commercial RO/RO Vessel -  [11500 DWT]
	{dbid=2034, prefix='C/F '}, --Commercial RO/RO Vessel -  [18000 DWT]
	{dbid=1002, prefix='OSV '}, --Commercial Supply Vessel -  [2900 DWT]
	{dbid=1317, prefix='OSV '}, --Commercial Supply Vessel -  [6000 DWT]
	{dbid=144, prefix='MT '}, --Commercial Tanker - General Purpose [20000 DWT]
	{dbid=339, prefix='MT '}, --Commercial Tanker - Large Range 1 [75000 DWT]
	{dbid=275, prefix='MT '}, --Commercial Tanker - Large Range 2 [150000 DWT]
	{dbid=145, prefix='MT '}, --Commercial Tanker - Medium Range [40000 DWT]
	{dbid=2022, prefix='MT '}, --Commercial Tanker - Ultra Large Crude Carrier [420000 DWT]
	{dbid=259, prefix='MT '}, --Commercial Tanker - Very Large Crude Carrier [300000 DWT]
}

merchant_names = {
	'Market',
	'Revolver',
	'Three Faces',
	'Exchange',
	'Diva',
	'Sabe',
	'Peel',
	'Laird',
	'Greyhound',
	'Chasers',
	'Acid',
	'Adore',
	'Aja',
	'Akashia',
	'Aksham Tarkee',
	'Alaska',
	'Alexis Mateo',
	'Alexis',
	'Alisa',
	'Alyssa Edwards',
	'Andromeda',
	'Annie',
	'Antaeus',
	'April',
	'Arsenal Gear',
	'Beluga',
	'Benthic Explorer',
	'Beowolf',
	'Beverley Hills',
	'Bhagwan Dryden',
	'Bianca del Rio',
	'Blac Chyna',
	'Black Hawk',
	'Black Pearl',
	'Black Swan',
	'Black Wind',
	'Bob',
	'Borealis',
	'Brandenburg',
	'Brave Joffrey',
	'Britannic',
	'Caledonia II',
	'Candy',
	'Carmen',
	'Chachki',
	'Chad',
	'Charlie',
	'Charlotte',
	'Charon',
	'Chi Chi',
	'Chiku Shan',
	'Claridon',
	'Coco Montrese',
	'Cold Feet',
	'Courtney',
	'Crème de la Crème',
	'Crescent Star',
	'Cynthia Lee Fontaine',
	'Cynthia Lee Fontaine',
	'Dagat Ahas',
	'Dagger',
	"Dagon's Feast",
	'Dax',
	'Deep Quest',
	'Delta',
	'Derrick',
	'Detox',
	'Dida',
	'Disco Volante',
	'Dulcibella',
	'Eastern Spirit',
	'Edinburgh Trader',
	'Elisabeth Dane',
	'Elizabeth Dane',
	'Empress',
	'Ergenstrasse',
	'Esgred',
	'Essess',
	'Eureka',
	'Fame',
	'Farrah',
	'Fenris',
	'Fierce',
	'Fingerdancer',
	'Flying Dutchman',
	'Flying Wasp',
	'Foamdrinker',
	'Forlorn Hope',
	'Fury',
	'Genoa Maru',
	'Geofon',
	'Geronimo',
	'Ghost',
	'Gia Gunn',
	'Ginger',
	'Glencairn',
	'Gloria N',
	'Golden Rose',
	'Golden Storm',
	'Goliath',
	'Great Kraken',
	'Grey Ghost',
	'Hahnchen Maru',
	'Hai Peng',
	'Happy Wanderer',
	'Hardhand',
	'Henrietta ',
	"Herman's Folly",
	'Honey Mahogany',
	'Hung Lo',
	'Immer Essen',
	'India',
	'Inferno',
	'Inspiration',
	'Iron Lady',
	'Iron Victory',
	'Iron Wind',
	'Iron Wing',
	'Ivy Winters',
	'J Sotomayor',
	'Jackdaw',
	'Jade',
	'Jasmine',
	'Jenny',
	'Jiggly',
	'Joslyn',
	'Jujubee',
	'Kasha',
	'Katya',
	'Kennedy Davenport',
	'Kenya',
	'Kestrel',
	'Kim Chi',
	'Kimora',
	'Kite',
	'Kolga',
	"Kraken's Kiss",
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
	'Leviathan',
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
	"Maiden's Bane",
	'Manila Luzon',
	'Mansfield',
	'Mantle',
	'Maria Doria',
	'Maria Narcissa',
	'Mariah',
	'Marie Elena',
	'Mary Deare',
	'Max',
	'Milan',
	'Milfio',
	'Milk',
	'Mimi',
	'Minnow Johnson',
	'Monsoon',
	'Morgan',
	'Morning Star ',
	'Morrigan',
	'Mystique',
	'Naomi',
	'Nathan Ross',
	'Nautilus',
	'Naysha Lopez',
	'Nekulturny',
	'Nightflyer',
	'Nina Brown',
	'Nina Flowers',
	'Ning-Po',
	'Ongina',
	'Orca',
	'Outer Haven',
	'Paige',
	'Palanquin Ship',
	'Pandora',
	'Patna',
	'Pearl',
	'Pearl',
	'Penny',
	'Peppermint',
	'Pequod',
	'Phoenix',
	'Porkchop',
	'Poseidon',
	'Precious Gem',
	'Princess Irene',
	'Princess Marcella',
	'Proteus',
	'Queen Margaery',
	'Rachel',
	'Raja',
	'Raven',
	'Reaper',
	'Reapers Wind',
	'Rebecca Glasscock',
	'Red Dragon',
	'Red Jester',
	'Red October',
	'Red Tide',
	'Red Witch',
	'Rights-of-Man',
	'Rob Roy',
	'Robert Turner',
	'Royale',
	'Rupaul',
	'Rusalka',
	'Sahara',
	'Salazar',
	'Salty Hippo',
	'Salty Wench',
	'Santana',
	'Saracen',
	'Sasha',
	'Sea Cliff',
	'Sea Song',
	'Sea Star',
	'Sea Witch',
	'Seaswift',
	'Seaview',
	'Selstam Eule',
	'Serena',
	'Seven Skulls',
	'Shangela',
	'Shannel',
	'Shikaka',
	'Sharon',
	'Shea',
	'Silence',
	'Silverfin',
	'Sonique',
	'Southern Queen',
	'Sparrowhawk',
	'St. Georges',
	'Stacy',
	'Starfish',
	'Sweet Cersei',
	'Swiftin',
	'Tammie B',
	'Tanager',
	'Tatianna',
	'Tempest',
	'The Princess',
	'Thorgy',
	'Thunderer',
	'Titanic II',
	'Tough',
	'Trinity Taylor',
	'Trinity',
	'Trixie',
	'Turtle',
	'Two Dogs',
	'Tyra',
	'Ulysses',
	'Valentina',
	'Velour',
	'Venture',
	'Venus',
	'Vivacious',
	'Vivienne',
	'Wanderer',
	'Warhammer',
	'Warrior Wench',
	'White Widow',
	'Wild',
	'Willam',
	'Windbreaker',
	'Woe',
	'Wonkatania ',
	'Yara Sofia',
	'Zahara',
	'Zelbess',
}

shuffleTable(merchant_names)

num_merchants = math.random(12,24)

for i = 1,num_merchants do
	chance = math.random(1,4)
	merch_type = merchants[math.random(1,#merchants)]
	origin = {}
	destination = {}
	if chance <= 2 then --random pos
		::redo_pos_1::
		lat_var = math.random(1,(10^13)) --random number between 1 and 10^13
		lon_var = math.random(1,(10^13)) --random number between 1 and 10^13
		
		origin.latitude = math.random(35,40) + (lat_var/(10^13)) --latitude; 
		origin.longitude = math.random(-76,-70) + (lon_var/(10^13)) --longitude; 
		
		pos_elev = World_GetElevation({lat=origin.latitude,lon=origin.longitude})
			if pos_elev > -5 then goto redo_pos_1 end
		dest1 = ScenEdit_GetReferencePoint({side='Civilian',name=seas_and_ports[math.random(1,#seas_and_ports)]})
		destination.latitude = dest1.latitude
		destination.longitude = dest1.longitude
		ship = ScenEdit_AddUnit({side='Civilian',type='Ship',dbid=merch_type.dbid,name=merch_type.prefix..merchant_names[i],latitude=origin.latitude,longitude=origin.longitude,course={destination}})
	elseif chance == 2 then --at sea
		::redo_pos_2::
		a_origin = ScenEdit_GetReferencePoint({side='Civilian',name=seas[math.random(1,#seas)]})
		circle = World_GetCircleFromPoint({latitude=a_origin.latitude,longitude=a_origin.longitude,radius=math.random(10,100)})
		a_origin = circle[math.random(1,#circle)]
		origin.latitude=a_origin.Latitude
		origin.longitude=a_origin.Longitude
		pos_elev = World_GetElevation({lat=origin.latitude,lon=origin.longitude})
			if pos_elev > -5 then goto redo_pos_2 end
		a_destination = ScenEdit_GetReferencePoint({side='Civilian',name=ports[math.random(1,#ports)]})
		destination.latitude=a_destination.latitude
		destination.longitude=a_destination.longitude
		ship = ScenEdit_AddUnit({side='Civilian',type='Ship',dbid=merch_type.dbid,name=merch_type.prefix..merchant_names[i],latitude=origin.latitude,longitude=origin.longitude,course={destination}})
	elseif chance == 3 then --in port
		::redo_pos_3::
		a_origin = ScenEdit_GetReferencePoint({side='Civilian',name=ports[math.random(1,#ports)]})
					circle = World_GetCircleFromPoint({latitude=a_origin.latitude,longitude=a_origin.longitude,radius=math.random(5,50)})
		a_origin = circle[math.random(1,#circle)]
		origin.latitude=a_origin.Latitude
		origin.longitude=a_origin.Longitude
		pos_elev = World_GetElevation({lat=origin.latitude,lon=origin.longitude})
			if pos_elev > -5 then goto redo_pos_3 end
		a_destination = ScenEdit_GetReferencePoint({side='Civilian',name=seas[math.random(1,#seas)]})
		destination.latitude=a_destination.latitude
		destination.longitude=a_destination.longitude
		ship = ScenEdit_AddUnit({side='Civilian',type='Ship',dbid=merch_type.dbid,name=merch_type.prefix..merchant_names[i],latitude=origin.latitude,longitude=origin.longitude,course={destination}})
	end
end

ScenEdit_SpecialMessage('playerside',"<P><B>Gameplay Notes</B></P> <P>This scenario models submarine communications; namely Ultra High Frequency (UHF) radio.</P> <P><B>Ultra high frequency</B> allows to you to communicate directly with offboard intelligence assets via satellite relay. UHF signals do not penetrate water, so your submarine will need to be at periscope depth (-20m/-66ft) or shallower in order to perform this special action. To do so, open the Special Action menu and select <I>'Request Intelligence Update'</I>. This will provide an update on the approximate location, heading, speed and type of enemy ships.</P> <P>Because your submarine is emitting radio signals, every time you request an update there is a chance that the enemy will detect your transmissions. This is calculated using radio line of sight (with the UHF antenna assumed to be at a height of 3ft/1m above the surface), so a surface ship will only be able to detect transmissions at a maximum of approx 20nm, while an aircraft at 36,000ft can detect transmissions beyond 250nm. The chance of detection is directly related to your distance from the enemy unit.</P> <P>In addition, you will only be able to request updates once every two hours, as any good sub captain won't risk transmitting unless they absolutely have to!</P>")