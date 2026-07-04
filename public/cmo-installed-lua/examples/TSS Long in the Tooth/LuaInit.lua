math.randomseed(os.time())

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function shuffleTable(t)
	local rand = math.random 
	assert( t, "shuffleTable() expected a table, got nil" )
	local iterations = #t
	local j
	
	for i = iterations, 2, -1 do
		j = rand(i)
		t[i], t[j] = t[j], t[i]
	end
end

function DTG(TimeVar)
	if TimeVar == nil then 
	TimeVar = ScenEdit_CurrentTime()
	end
	msgtime = os.date("!%H%M" .. "UTC" .. " " .. "%d %b %y r.", TimeVar)
	msgtime = string.upper(msgtime)
	return msgtime
end


function ChangeScore(side,score,reason)
	init_score = ScenEdit_GetScore(side)
	new_score = init_score + score
	ScenEdit_SetScore(side,new_score,reason)
end

function Signal (recipient,sender,subject,precedence,body)
	local precedence = string.upper(precedence)
	local recipient = string.upper(recipient)
	local sender = string.upper(sender)
	local body = string.upper(body)
	local subject = string.upper(subject)
	local msg_time = DTG()

	local signal_string = '<P><FONT face=Consolas>'.. precedence.. '\\'..'\\ <BR>' .. 
	'FROM: '..sender..' <BR>' .. 
	'TO: '..recipient..' <BR>' ..
	'SUBJ: '..subject..' <BR>' .. 
	msg_time .. ' </FONT></P>' ..
	'<P><FONT face=Consolas>'..body.. ' </FONT></P>' ..
	'<P><FONT face=Consolas>'..'\\'..'\\'..precedence..'</FONT></P>'
	return signal_string
end

function InterceptCheck()
	side = VP_GetSide({side='United States'})
	transmitter = ScenEdit_GetUnit({guid='9bca913e-d0cf-4f0e-bdce-55c7fd26cff5'})
	detected = false
	for i = 1,#side.units do
		unit = ScenEdit_GetUnit({guid=side.units[i].guid})
		range = Tool_Range(unit.guid, transmitter.guid)
			if unit.type == 'Ship' and range < 10 then
				chance=math.random(1,100)
				threshold=round(range*10,0)
				if chance > threshold then
					detected = true
				end
				print (unit.type..' '..unit.name..' is '..range..'nm from transmitter. Threshold is '..threshold..', chance roll was '..chance)
			elseif unit.type == 'Submarine' and unit.altitude >-20 and range < 5 then
				chance=math.random(1,100)
				threshold=round((range*2)*2,0)
				if chance > threshold then
					detected = true
				end
				print (unit.type..' '..unit.name..' is '..range..'nm from transmitter. Threshold is '..threshold..', chance roll was '..chance)
			elseif unit.type == 'Aircraft' and range < 235.5 then --Must be within theoretical max range for 36kft
				chance=math.random(1,100)
				alt1=math.sqrt(unit.altitude)
				alt2=math.sqrt(1) --submarine antenna assumed to be 1m ASL
				horizon_m=(alt1+alt2)*4124
				horizon_nm=horizon_m/1852 --1852m to 1nm
				threshold=round((range/235.5)*100,0) --% of current range vs maximum at 235.5nm for a/c at 36Kft
				if range < horizon_nm and chance > threshold then
					detected = true
				end
				print (unit.type..' '..unit.name..' is '..range..'nm from transmitter, horizon is '..horizon_nm..'nm. Threshold is '..threshold..', chance roll was '..chance)
			end
	end
	return detected
end