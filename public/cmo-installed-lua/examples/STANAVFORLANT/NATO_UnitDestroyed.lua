local theDestroyedUnit = ScenEdit_UnitX()

if theDestroyedUnit.type ~= 'Weapon' then
  
    local targetList = {
        {type='Aircraft', dbid=1251, points=50, name='Lynx HAS.2', destroyedString='destroyed'},--Lynx HAS.2
        {type='Aircraft', dbid=1505, points=50, name='AH-1J Sea Cobra', destroyedString='destroyed'},--AH-1J Sea Cobra
        {type='Aircraft', dbid=1711, points=50, name='SH-2D Seasprite LAMPS I', destroyedString='destroyed'},--SH-2D Seasprite LAMPS I
        {type='Aircraft', dbid=1765, points=100, name='Shackleton AEW.2', destroyedString='destroyed'},--Shackleton AEW.2
        {type='Aircraft', dbid=1769, points=50, name='Lynx SH-14B [Mk27]', destroyedString='destroyed'},--Lynx SH-14B [Mk27]
        {type='Aircraft', dbid=2101, points=50, name='CH-53D Sea Stallion', destroyedString='destroyed'},--CH-53D Sea Stallion
        {type='Aircraft', dbid=2301, points=50, name='F-5A Freedom Fighter', destroyedString='destroyed'},--F-5A Freedom Fighter
        {type='Aircraft', dbid=246, points=50, name='F-104G Starfighter', destroyedString='destroyed'},--F-104G Starfighter
        {type='Aircraft', dbid=2475, points=100, name='P-3B Orion', destroyedString='destroyed'},--P-3B Orion
        {type='Aircraft', dbid=2819, points=50, name='F-104G Starfighter [CF-104C]', destroyedString='destroyed'},--F-104G Starfighter [CF-104C]
        {type='Aircraft', dbid=2945, points=50, name='UH-1N Huey', destroyedString='destroyed'},--UH-1N Huey
        {type='Aircraft', dbid=3003, points=100, name='Nimrod MR.1', destroyedString='destroyed'},--Nimrod MR.1
        {type='Aircraft', dbid=3008, points=100, name='P-3C Orion Update I', destroyedString='destroyed'},--P-3C Orion Update I
        {type='Aircraft', dbid=3053, points=50, name='Buccaneer S.2B', destroyedString='destroyed'},--Buccaneer S.2B
        {type='Aircraft', dbid=3253, points=50, name='TF-104G Starfighter', destroyedString='destroyed'},--TF-104G Starfighter
        {type='Aircraft', dbid=3258, points=50, name='TF-104G Starfighter [CF-104D]', destroyedString='destroyed'},--TF-104G Starfighter [CF-104D]
        {type='Aircraft', dbid=3283, points=50, name='F-5B Freedom Fighter', destroyedString='destroyed'},--F-5B Freedom Fighter
        {type='Aircraft', dbid=667, points=50, name='CH-46D Sea Knight', destroyedString='destroyed'},--CH-46D Sea Knight
        {type='Aircraft', dbid=683, points=50, name='CH-124A Heltas [Sea King]', destroyedString='destroyed'},--CH-124A Heltas [Sea King]

        {type='Ship', dbid=1004, points=250, name='F 300 Oslo [Dealey Mod]', destroyedString='sunk'},--F 300 Oslo [Dealey Mod]
        {type='Ship', dbid=127, points=250, name='F 169 Amazon [Type 21, Exocet]', destroyedString='sunk'},--F 169 Amazon [Type 21, Exocet]
        {type='Ship', dbid=1575, points=50, name='LCU 1646', destroyedString='sunk'},--LCU 1646
        {type='Ship', dbid=1576, points=50, name='LCP', destroyedString='sunk'},--LCP
        {type='Ship', dbid=735, points=250, name='DDH 205 St. Laurent', destroyedString='sunk'},--DDH 205 St. Laurent
        {type='Ship', dbid=742, points=250, name='FFG 1 Brooke', destroyedString='sunk'},--FFG 1 Brooke
        {type='Ship', dbid=767, points=250, name='DDG 37 Farragut', destroyedString='sunk'},--DDG 37 Farragut
        {type='Ship', dbid=793, points=750, name='LPD 4 Austin', destroyedString='sunk'},--LPD 4 Austin
        {type='Ship', dbid=806, points=1500, name='LPH 2 Iwo Jima', destroyedString='sunk'},--LPH 2 Iwo Jima
        {type='Ship', dbid=826, points=250, name='F 802 Van Speijk', destroyedString='sunk'},--F 802 Van Speijk
        {type='Ship', dbid=828, points=250, name='D 185 Lütjens [Charles F. Adams, Type Z103]', destroyedString='sunk'},--D 185 Lütjens [Charles F. Adams, Type Z103]
    }


	local matchData = {}

	for k,v in ipairs (targetList) do
		if v.dbid == theDestroyedUnit.dbid and v.type == theDestroyedUnit.type then
			matchData = v
		end
	end

	if matchData == {} then
		BugMessage('NATO_UnitDestroyed', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
        ChangeScore('NATO',matchData.points*-1,theDestroyedUnit.name..' was '..matchData.destroyedString..'.')

        local function UnitIsAnAmphib(dbid)
            local result = false
            if dbid == 793 or dbid == 806 then result = true end
            return result
        end

        if matchData.type == 'Ship' and UnitIsAnAmphib() then
            ChangeScore('NATO',-1500,'An amphibious unit was destroyed. Mission failed!')
        end
    end
end