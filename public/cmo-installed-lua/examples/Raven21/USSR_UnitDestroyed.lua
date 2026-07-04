local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type == 'Weapon' then
	if not SovietsHaveFiredWeapons() then
		SovietsHaveFiredWeapons(true)
	end
else
	local targetList = {
        {type='Aircraft', dbid=1267, points=-100, name='fighter aircraft', destroyedString='shot down'},--Su-17M Fitter C
        {type='Aircraft', dbid=1296, points=-100, name='fighter aircraft', destroyedString='shot down'},--MiG-23M Flogger B
        {type='Aircraft', dbid=133, points=-200, name='support aircraft', destroyedString='shot down'},--Tu-95RT Bear D
        {type='Aircraft', dbid=1479, points=-75, name='helicopter', destroyedString='shot down'},--Mi-24D Hind D
        {type='Aircraft', dbid=1487, points=-75, name='helicopter', destroyedString='shot down'},--Mi-8MT Hip H
        {type='Aircraft', dbid=55, points=-75, name='helicopter', destroyedString='shot down'},--Ka-25BSh Hormone A
        {type='Ship', dbid=1345, points=-250, name='warship', destroyedString='sunk'},--BRK Kildin [Pr.56U]
        {type='Ship', dbid=505, points=-250, name='intelligence vessel', destroyedString='sunk'},--SSV Mayak [Pr.502, ASW Mod]
        {type='Ship', dbid=694, points=-250, name='warship', destroyedString='sunk'},--BPK Kashin Mod [Pr.61M]
        {type='Ship', dbid=695, points=-250, name='warship', destroyedString='sunk'},--RKR Kresta I [Pr.1134 Berkut]
        {type='Ship', dbid=700, points=-250, name='warship', destroyedString='sunk'},--SKR Krivak II [Pr.1135M Burevestnik-M]
        {type='Ship', dbid=715, points=-250, name='amphibious ship', destroyedString='sunk'},--BDK Ropucha I [Pr.775]
        {type='Ship', dbid=716, points=-250, name='amphibious ship', destroyedString='sunk'},--BDK Alligator [Pr.1171 Tapir]
        {type='Ship', dbid=730, points=-250, name='auxilliary vessel', destroyedString='sunk'},--VT Dubna [Kerch]
        {type='Submarine', dbid=279, points=-250, name='submarine', destroyedString='sunk'},--PL-641B Tango [Som]
	}

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('USSR_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		if SovietsHaveFiredWeapons() then
			ChangeScore('United States',matchData.points*-1,'A Soviet '..matchData.name.. ' was '..matchData.destroyedString..'.')
		else
			ChangeScore('United States',matchData.points,'A Soviet '..matchData.name.. ' was '..matchData.destroyedString..', breaching RoE.')
			local sovietScore = ChangeScore('Soviet Union',matchData.points*-1,'A Soviet '..matchData.name.. ' was '..matchData.destroyedString..'.')
			if sovietScore >= 500 then
				TelexMessageToPlayer(
					'ntbi',
					'COMIDEASTFOR',
					'z',
					'Commander Middle east force',
					'commanding officer cv 34 oriskany',
					'top secret',
					'1. your wanton disregard for rules of engagement with soviet forces has compromised the mission.<BR> 2. you are relieved of command effective immediately. <br> 3. expect to face a court martial on your return to port.'
				)
				ChangeScore('United States',-500,'You were relieved of command.')
				ScenEdit_EndScenario()
			else
				TelexMessageToPlayer(
					'ntbi',
					'COMIDEASTFOR',
					'z',
					'Commander Middle east force',
					'commanding officer cv 34 oriskany',
					'top secret',
					'1. immediately cease fire.<BR> 2. positively identify any further contacts before engaging. <br> 3. you are not, repeat not, authorized to fire on soviet forces unless fired upon.'
				)
			end
		end
	end
end