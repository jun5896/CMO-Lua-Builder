ScenEdit_RunScript('DeveloperMode.lua')

math.randomseed(os.time())
math.random()

-- =================
-- Scenario Setup --
-- =================

function SetupSubmarine(submarineTable, submarineSide, submarineName, escortBoolean, escortName)
	local Index = math.random(1, #submarineTable)
	local subInfo = submarineTable[Index]

	ScenEdit_SetUnit({
		side=submarineSide, 
		name=submarineName, 
		heading=subInfo.heading, 
		latitude=subInfo.latitude, 
		longitude=subInfo.longitude
	})

	if ScenEdit_GetSideIsHuman(submarineSide) then
		ScenEdit_AssignUnitToMission(submarineName, nil)
	else
		ScenEdit_AssignUnitToMission(submarineName, subInfo.mission)
	end

	if escortBoolean == true then
		ScenEdit_SetUnit({
			side=submarineSide, 
			name=escortName, 
			heading=subInfo.escortHeading, 
			latitude=subInfo.escortLatitude, 
			longitude=subInfo.escortLongitude
		})

		if ScenEdit_GetSideIsHuman(submarineSide) then
			ScenEdit_AssignUnitToMission(escortName, nil)
		else
			ScenEdit_AssignUnitToMission(escortName, subInfo.escortMission)
		end
	end
end

-- ===================
-- Submarine Tables --
-- ===================

local BelgorodTable = {
	{
		heading=280,
		latitude='81.5692423898793',
		longitude='147.53660786426',
		mission='Emplacement zone A',
		escortHeading=280,
		escortLatitude='82.1950511118441',
		escortLongitude='151.036814599659',
		escortMission='Emplacement zone A Escort'
	},
	{
		heading=90,
		latitude='87.0533581265612',
		longitude='128.623523919292',
		mission='Emplacement zone D',
		escortHeading=90,
		escortLatitude='86.8974989211257',
		escortLongitude='130.028913292364',
		escortMission='Emplacement zone D Escort'
	}
}

local OrenburgTable = {
	{
		heading=320,
		latitude='73.486949766786',
		longitude='-157.50548750592',
		mission='Activation Site A',
		escortHeading=320,
		escortLatitude='73.8600069097283',
		escortLongitude='-157.12900409373',
		escortMission='Activation Site A Escort'
	},
	{
		heading=120,
		latitude='79.1926405489423',
		longitude='-161.787673473522',
		mission='Activation Site D',
		escortHeading=120,
		escortLatitude='79.3896761594767',
		escortLongitude='-163.085513047321',
		escortMission='Activation Site D Escort'
	}
}

local PodmoskovyeTable = {
	{
		heading=295,
		latitude='82.0091051286464',
		longitude='41.8414099225931',
		mission='Preparation Area A',
		escortHeading=295,
		escortLatitude='82.1911767503469',
		escortLongitude='45.7109064436504',
		escortMission='Preparation Area A Escort'
	},
	{
		heading=110,
		latitude='81.5510639547088',
		longitude='4.41393068779108',
		mission='Preparation Area B',
		escortHeading=110,
		escortLatitude='81.6864133034119',
		escortLongitude='5.4233912136135',
		escortMission='Preparation Area B Escort'
	}
}

local SeverodvinskTable = {
	{heading=80, latitude='76.8430704348267', longitude='-164.438871643617', mission='Severodvinsk PZ 1'},
	{heading=180, latitude='75.7843456884983', longitude='-159.876996175025', mission='Severodvinsk PZ 1'},
	{heading=280, latitude='79.4222522291065', longitude='-155.354545614843', mission='Severodvinsk PZ 1'},
	{heading=340, latitude='79.7520689095129', longitude='-156.750438031029', mission='Severodvinsk PZ 1'},
	{heading=80, latitude='85.1959932688683', longitude='143.466645862677', mission='Severodvinsk PZ 2'},
	{heading=180, latitude='81.0675481077294', longitude='148.599413608794', mission='Severodvinsk PZ 2'},
	{heading=270, latitude='87.240380637693', longitude='163.206009647482', mission='Severodvinsk PZ 2'},
	{heading=340, latitude='83.6042030637614', longitude='158.652148869159', mission='Severodvinsk PZ 2'},
	{heading=80, latitude='82.7662800511707', longitude='25.3245077273535', mission='Severodvinsk PZ 3'},
	{heading=180, latitude='81.1498449852294', longitude='14.0972757965503', mission='Severodvinsk PZ 3'},
	{heading=340, latitude='80.7550554222952', longitude='36.9572536323749', mission='Severodvinsk PZ 3'},
	{heading=270, latitude='82.6390776804117', longitude='69.2625894955382', mission='Severodvinsk PZ 3'},
}

local DallasTable = {
	{heading=300, latitude='75.4822416893364', longitude='-132.135608948241', mission='Cyber 1'},
	{heading=350, latitude='66.9706602658021', longitude='-167.026554488041', mission='Cyber 1'},
	{heading=300, latitude='83.3273979105667', longitude='-141.113065607081', mission='Cyber 2'},
	{heading=350, latitude='88.3577500512558', longitude='-43.0487621776154', mission='Cyber 2'},
	{heading=60, latitude='87.0756477569022', longitude='-5.08884105817846', mission='Cyber 3'},
	{heading=60, latitude='83.6078851091719', longitude='3.55467094340892', mission='Cyber 3'},
	{heading=60, latitude='77.197551369023', longitude='2.32421685163199', mission='Cyber 4'},
	{heading=60, latitude='74.8548544275417', longitude='28.7916972907539', mission='Cyber 4'},
}

local IllinoisTable = {
	{heading=50, latitude='78.3415088433432', longitude='-6.75905192352875', mission='PZ Greenland'},
	{heading=350, latitude='79.1868858341127', longitude='35.79397101522', mission='PZ Greenland'},
	{heading=300, latitude='82.7195395821267', longitude='57.1444887612139', mission='PZ Greenland'},
	{heading=100, latitude='83.1333796957441', longitude='-5.9694730325986', mission='PZ Greenland'},
}

local JimmyCarterTable = {
	{heading=0, latitude='67.1432291248884', longitude='-169.555580029793', mission='ATGU'},
	{heading=280, latitude='76.3147331247301', longitude='-127.693717603524', mission='ATGU'},
	{heading=300, latitude='84.9542942176137', longitude='-64.0866770560132', mission='ATGU'},
	{heading=30, latitude='83.4280315891238', longitude='59.1519979196596', mission='ATGU'},
	{heading=200, latitude='81.767884693935', longitude='-164.143595857171', mission='ATGU'},
	{heading=330, latitude='62.886867876806', longitude='-167.659692953428', mission='ATGU'},
}

local MississippiTable = {
	{heading=30, latitude='71.9098665322458', longitude='-169.098255236773', mission='PZ Alaska'},
	{heading=350, latitude='73.3032122460547', longitude='-145.418449733717', mission='PZ Alaska'},
	{heading=20, latitude='62.1729221120153', longitude='-168.262564436386', mission='PZ Alaska'},
	{heading=200, latitude='84.5032877193674', longitude='-153.505380265727', mission='PZ Alaska'},
}

local OhioTable = {
	{heading=0, latitude='64.9895121619844', longitude='-168.937832188155', mission='Cluster Lance - CH1'},
	{heading=280, latitude='84.4880900702697', longitude='-114.928506179473', mission='Cluster Lance - SV1'},
	{heading=300, latitude='86.9702037593431', longitude='-162.632642174002', mission='Cluster Lance - LP1'},
	{heading=30, latitude='56.9920221149834', longitude='-174.868595650648', mission='Cluster Lance - ES1'},
}

local SeawolfTable = {
	{heading=330, latitude='83.8929625034283', longitude='-134.745313689003', mission='PZ Ridge'},
	{heading=350, latitude='81.349995096772', longitude='173.810829530962', mission='PZ Ridge'},
	{heading=20, latitude='85.0374692276509', longitude='-4.69270536246881', mission='PZ Ridge'},
	{heading=320, latitude='76.7425608560806', longitude='-142.65662015308', mission='PZ Ridge'},
}

-- =========================
-- Scenario Initialization
-- =========================

function ThisIsFirstLoad(booleanValue)
	local result
	if booleanValue == nil then
		result = ScenEdit_GetKeyValue('firstLoad')
		if result == '' or result == nil then result = true end
		if result == 'false' then result = false end
	else
		if booleanValue == true then
			ScenEdit_ClearKeyValue('firstLoad')
			result = true
		elseif booleanValue == false then
			ScenEdit_SetKeyValue('firstLoad','false')
			result = false
		end
	end
	return result
end

if ThisIsFirstLoad() then
	local PlayerSide = ScenEdit_PlayerSide()
	if inDevelopment then -- Ask to do stuff
		userInput = string.upper(ScenEdit_MsgBox('Randomly position submarines?',1))
		if userInput == 'OK' then
			SetupSubmarine(BelgorodTable, 'Russia', 'K-139 RFS Belgorod', true, 'K-157 RFS Vepr')
			SetupSubmarine(OrenburgTable, 'Russia', 'BS-136 RFS Orenburg', true, 'K-295 RFS Samara')
			SetupSubmarine(PodmoskovyeTable, 'Russia', 'BS-64 RFS Podmoskovye', true, 'K-371 RFS Pantera')
			SetupSubmarine(SeverodvinskTable, 'Russia', 'K-329 RFS Severodvinsk', false, nil)
			SetupSubmarine(DallasTable, 'US', 'SSN 700 USS Dallas', false, nil)
			SetupSubmarine(IllinoisTable, 'US', 'SSN 786 USS Illinois', false, nil)
			SetupSubmarine(JimmyCarterTable, 'US', 'SSN 23 USS Jimmy Carter', false, nil)
			SetupSubmarine(MississippiTable, 'US', 'SSN 782 USS Mississippi', false, nil)
			SetupSubmarine(OhioTable, 'US', 'SSGN 726 USS Ohio', false, nil)
			SetupSubmarine(SeawolfTable, 'US', 'SSN 21 USS Seawolf', false, nil)
		end

		userInput = string.upper(ScenEdit_MsgBox('Set firstLoad key value to false?',1))
		if userInput == 'OK' then
			ThisIsFirstLoad(false)
		end
	else -- Don't give the option and just do it
		SetupSubmarine(BelgorodTable, 'Russia', 'K-139 RFS Belgorod', true, 'K-157 RFS Vepr')
		SetupSubmarine(OrenburgTable, 'Russia', 'BS-136 RFS Orenburg', true, 'K-295 RFS Samara')
		SetupSubmarine(PodmoskovyeTable, 'Russia', 'BS-64 RFS Podmoskovye', true, 'K-371 RFS Pantera')
		SetupSubmarine(SeverodvinskTable, 'Russia', 'K-329 RFS Severodvinsk', false, nil)
		SetupSubmarine(DallasTable, 'US', 'SSN 700 USS Dallas', false, nil)
		SetupSubmarine(IllinoisTable, 'US', 'SSN 786 USS Illinois', false, nil)
		SetupSubmarine(JimmyCarterTable, 'US', 'SSN 23 USS Jimmy Carter', false, nil)
		SetupSubmarine(MississippiTable, 'US', 'SSN 782 USS Mississippi', false, nil)
		SetupSubmarine(OhioTable, 'US', 'SSGN 726 USS Ohio', false, nil)
		SetupSubmarine(SeawolfTable, 'US', 'SSN 21 USS Seawolf', false, nil)
		ThisIsFirstLoad(false)
	end
end