local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1610, points=50, name='Sea Vixen FAW Mk1', destroyedString='shot down'},--Sea Vixen FAW Mk1
        {type='Aircraft', dbid=1612, points=50, name='Scimitar F.Mk1', destroyedString='shot down'},--Scimitar F.Mk1
        {type='Aircraft', dbid=1613, points=100, name='Gannet AEW.3', destroyedString='shot down'},--Gannet AEW.3
        {type='Aircraft', dbid=208, points=50, name='Gannet COD', destroyedString='shot down'},--Gannet COD
        {type='Aircraft', dbid=215, points=50, name='Hunter FR.10', destroyedString='shot down'},--Hunter FR.10
        {type='Aircraft', dbid=247, points=100, name='Shackleton MR.2', destroyedString='shot down'},--Shackleton MR.2
        {type='Aircraft', dbid=267, points=100, name='Canberra PR.7', destroyedString='shot down'},--Canberra PR.7
        {type='Aircraft', dbid=417, points=100, name='Canberra B(I).6', destroyedString='shot down'},--Canberra B(I).6
        {type='Aircraft', dbid=599, points=50, name='Whirlwind HAS.7', destroyedString='shot down'},--Whirlwind HAS.7
        {type='Aircraft', dbid=734, points=50, name='Javelin FAW.9', destroyedString='shot down'},--Javelin FAW.9
        {type='Aircraft', dbid=75, points=50, name='Hunter FGA.9', destroyedString='shot down'},--Hunter FGA.9

        {type='Facility', dbid=120, points=25, name='Building (Control Tower)', destroyedString='destroyed'},--Building (Control Tower)
        {type='Facility', dbid=1221, points=25, name='Armored Plt (Centurion Mk 5/2 MBT)', destroyedString='destroyed'},--Armored Plt (Centurion Mk 5/2 MBT)
        {type='Facility', dbid=130, points=0, name='A/C Tarmac Space (4x Large Aircraft)', destroyedString='destroyed'},--A/C Tarmac Space (4x Large Aircraft)
        {type='Facility', dbid=1472, points=25, name='AAA Bty (40mm/70 Bofors x 4, FCE7 Yellow Fever FCR)', destroyedString='destroyed'},--AAA Bty (40mm/70 Bofors x 4, FCE7 Yellow Fever FCR)
        {type='Facility', dbid=1537, points=25, name='Armored Recon Plt  (FV 701C Ferret Mk.1/2)', destroyedString='destroyed'},--Armored Recon Plt  (FV 701C Ferret Mk.1/2)
        {type='Facility', dbid=221, points=50, name='Ammo Bunker (Surface)', destroyedString='destroyed'},--Ammo Bunker (Surface)
        {type='Facility', dbid=224, points=25, name='Pill Box (12.7mm)', destroyedString='destroyed'},--Pill Box (12.7mm)
        {type='Facility', dbid=235, points=25, name='A/C Hangar (4x Large Aircraft)', destroyedString='destroyed'},--A/C Hangar (4x Large Aircraft)
        {type='Facility', dbid=288, points=25, name='Arty Bty/3 (105mm/37 L118 Towed Light Gun x 2)', destroyedString='destroyed'},--Arty Bty/3 (105mm/37 L118 Towed Light Gun x 2)
        {type='Facility', dbid=325, points=25, name='Inf Coy', destroyedString='destroyed'},--Inf Coy
        {type='Facility', dbid=393, points=25, name='SAM Sqn (Thunderbird 1)', destroyedString='destroyed'},--SAM Sqn (Thunderbird 1)
        {type='Facility', dbid=43, points=25, name='AvGas (400k Liter Tank)', destroyedString='destroyed'},--AvGas (400k Liter Tank)
        {type='Facility', dbid=6, points=25, name='Pill Box (81mm Mortars)', destroyedString='destroyed'},--Pill Box (81mm Mortars)
        {type='Facility', dbid=90, points=50, name='Radar (AR-1)', destroyedString='destroyed'},--Radar (AR-1)

        {type='Ship', dbid=1208, points=250, name='F 32 Salisbury [Type 61]', destroyedString='sunk'},--F 32 Salisbury [Type 61]
        {type='Ship', dbid=1212, points=5000, name='R 06 Centaur', destroyedString='sunk'},--R 06 Centaur
        {type='Ship', dbid=1229, points=5000, name='R 08 Bulwark [Centaur]', destroyedString='sunk'},--R 08 Bulwark [Centaur]
        {type='Ship', dbid=146, points=5000, name='R 38 Victorious [Illustrious Class]', destroyedString='sunk'},--R 38 Victorious [Illustrious Class]
        {type='Ship', dbid=1499, points=250, name='D 01 C Class Destroyer', destroyedString='sunk'},--D 01 C Class Destroyer
        {type='Ship', dbid=1570, points=50, name='LCVP', destroyedString='sunk'},--LCVP
        {type='Ship', dbid=25, points=250, name='F 390 Loch', destroyedString='sunk'},--F 390 Loch
        {type='Ship', dbid=268, points=250, name='F 269 Meon', destroyedString='sunk'},--F 269 Meon
        {type='Ship', dbid=32, points=500, name='A 84 Reliant', destroyedString='sunk'},--A 84 Reliant
        {type='Ship', dbid=35, points=500, name='A 83 Appleleaf', destroyedString='sunk'},--A 83 Appleleaf
        {type='Ship', dbid=361, points=500, name='L 3001 LST(3)', destroyedString='sunk'},--L 3001 LST(3)
        {type='Ship', dbid=363, points=500, name='L 4062 LCT(8)', destroyedString='sunk'},--L 4062 LCT(8)
        {type='Ship', dbid=387, points=250, name='D 22 Battle Class (Late)', destroyedString='sunk'},--D 22 Battle Class (Late)
        {type='Ship', dbid=458, points=500, name='A 207 Wave', destroyedString='sunk'},--A 207 Wave
    }

	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('UK_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('United Kingdom',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')
    end
end