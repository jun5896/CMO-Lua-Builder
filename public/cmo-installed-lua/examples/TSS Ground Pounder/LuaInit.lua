UI_SetCameraView(24, 61, 500000)

function ConvertStringToBoolean(stringName)
	local stringName = string.upper(stringName)
	local result = false
	if stringName == 'TRUE' then
		result = true
	end
	return result
end

function shuffleTable( t )
	local rand = math.random 
	assert( t, "shuffleTable() expected a table, got nil" )
	local iterations = #t
	local j
	
	for i = iterations, 2, -1 do
		j = rand(i)
		t[i], t[j] = t[j], t[i]
	end
end

function ChangeScore(side,amt,reason)
	local side = tostring(side)
	local current_score = ScenEdit_GetScore(side)
	local current_score = current_score + amt
	local reason = tostring(reason)
	ScenEdit_SetScore(side,current_score,reason)
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function DTG(TimeVar)
	if TimeVar == nil then
	TimeVar = ScenEdit_CurrentTime()
	end
	msgtime = os.date("!%d%H%M" .. "Z" .. " " .. "%b %y", TimeVar)
	msgtime = string.upper(msgtime)
	return msgtime
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

function ACP126(rec_station,snd_station,precedence,from,to,classification,body)
	--rec_station --4 letter code (e.g. YDCX)
	--snd_station --4 letter code +/- NR 3 number (e.g. YBDN NR 270)
	--precedence --Flash (Z), Immediate (O), Priority (P), Routine (R), Flash Override (Y)
	dtg = DTG()
	--from --e.g. MET FLT OPS
	--to --e.g. SSN 21 SEAWOLF
	--classification --Unclass +/- SBU / FOUO / NOFORN (Restricted), Confidential, Secret, Top Secret
	--body
	_,gr = body:gsub("%S+","")
	sig_string = string.upper('<P><FONT face=Consolas>'..rec_station..' <BR>'..
	'DE '..snd_station..' <BR>'..
	precedence..' '..dtg..' <BR>'..
	'fm '..from..' <BR>'..
	'to '..to..' <BR>'..
	'wd gr'..gr..' <BR>'..
	'bt <BR>'..
	classification..' <BR>'..
	body..' <BR>'..
	'bt <BR>'..
	'nnnn </P>')
	return sig_string
end

function AshevilleOnStation(boolValue)
	if boolValue == nil then
		return ConvertStringToBoolean(ScenEdit_GetKeyValue('AshevilleOnStationKey'))
	elseif boolValue == true then
		ScenEdit_SetKeyValue('AshevilleOnStationKey', 'true')
		return true
	elseif boolValue == false then
		ScenEdit_SetKeyValue('AshevilleOnStationKey', 'false')
		return false
	else
		return nil
	end
end

function MiamiOnStation(boolValue)
	if boolValue == nil then
		return ConvertStringToBoolean(ScenEdit_GetKeyValue('MiamiOnStationKey'))
	elseif boolValue == true then
		ScenEdit_SetKeyValue('MiamiOnStationKey', 'true')
		return true
	elseif boolValue == false then
		ScenEdit_SetKeyValue('MiamiOnStationKey', 'false')
		return false
	else
		return nil
	end
end

function AshevilleDetected(boolValue)
	if boolValue == nil then
		return ConvertStringToBoolean(ScenEdit_GetKeyValue('AshevilleDetectedKey'))
	elseif boolValue == true then
		ScenEdit_SetKeyValue('AshevilleDetectedKey', 'true')
		return true
	elseif boolValue == false then
		ScenEdit_SetKeyValue('AshevilleDetectedKey', 'false')
		return false
	else
		return nil
	end
end

function MiamiDetected(boolValue)
	if boolValue == nil then
		return ConvertStringToBoolean(ScenEdit_GetKeyValue('MiamiDetectedKey'))
	elseif boolValue == true then
		ScenEdit_SetKeyValue('MiamiDetectedKey', 'true')
		return true
	elseif boolValue == false then
		ScenEdit_SetKeyValue('MiamiDetectedKey', 'false')
		return false
	else
		return nil
	end
end