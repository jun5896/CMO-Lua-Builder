local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
    local targetList = {
		{type='Aircraft', isDrone=true, dbid=1006, points=50, name='MQ-8B Fire Scout UAV', destroyedString='destroyed'},--MQ-8B Fire Scout UAV
		{type='Aircraft', isDrone=false, dbid=1510, points=500, name='KC-130J Hercules', destroyedString='destroyed'},--KC-130J Hercules
		{type='Aircraft', isDrone=false, dbid=1692, points=500, name='KC-135R Stratotanker', destroyedString='destroyed'},--KC-135R Stratotanker
		{type='Aircraft', isDrone=false, dbid=1986, points=100, name='CH-53E Super Stallion', destroyedString='destroyed'},--CH-53E Super Stallion
		{type='Aircraft', isDrone=false, dbid=2006, points=100, name='MH-60R Seahawk', destroyedString='destroyed'},--MH-60R Seahawk
		{type='Aircraft', isDrone=false, dbid=2705, points=500, name='P-8A Poseidon', destroyedString='destroyed'},--P-8A Poseidon
		{type='Aircraft', isDrone=false, dbid=2793, points=250, name='MH-53E Sea Dragon', destroyedString='destroyed'},--MH-53E Sea Dragon
		{type='Aircraft', isDrone=false, dbid=2794, points=100, name='MH-60S Knighthawk', destroyedString='destroyed'},--MH-60S Knighthawk
		{type='Aircraft', isDrone=false, dbid=2843, points=100, name='AH-1Z Viper [Super Cobra]', destroyedString='destroyed'},--AH-1Z Viper [Super Cobra]
		{type='Aircraft', isDrone=false, dbid=2844, points=100, name='UH-1Y Venom [Huey]', destroyedString='destroyed'},--UH-1Y Venom [Huey]
		{type='Aircraft', isDrone=true, dbid=2846, points=100, name='MQ-4C Triton UAV [Global Hawk Mod]', destroyedString='destroyed'},--MQ-4C Triton UAV [Global Hawk Mod]
		{type='Aircraft', isDrone=false, dbid=2891, points=200, name='C-2A(R) Greyhound', destroyedString='destroyed'},--C-2A(R) Greyhound
		{type='Aircraft', isDrone=false, dbid=297, points=200, name='MV-22B Osprey', destroyedString='destroyed'},--MV-22B Osprey
		{type='Aircraft', isDrone=false, dbid=343, points=350, name='EA-18G Growler', destroyedString='destroyed'},--EA-18G Growler
		{type='Aircraft', isDrone=false, dbid=4356, points=100, name='MH-60R Seahawk', destroyedString='destroyed'},--MH-60R Seahawk
		{type='Aircraft', isDrone=false, dbid=4681, points=100, name='MH-60S Knighthawk', destroyedString='destroyed'},--MH-60S Knighthawk
		{type='Aircraft', isDrone=false, dbid=534, points=750, name='F-35B Lightning II', destroyedString='destroyed'},--F-35B Lightning II
		{type='Aircraft', isDrone=false, dbid=555, points=200, name='F/A-18C Hornet', destroyedString='destroyed'},--F/A-18C Hornet
		{type='Aircraft', isDrone=false, dbid=571, points=100, name='MH-60S Knighthawk', destroyedString='destroyed'},--MH-60S Knighthawk
		{type='Aircraft', isDrone=false, dbid=694, points=500, name='E-2C Hawkeye 2000', destroyedString='destroyed'},--E-2C Hawkeye 2000
		{type='Aircraft', isDrone=false, dbid=753, points=250, name='F/A-18E Super Hornet', destroyedString='destroyed'},--F/A-18E Super Hornet
		{type='Aircraft', isDrone=false, dbid=965, points=250, name='F/A-18F Super Hornet', destroyedString='destroyed'},--F/A-18F Super Hornet

		{type='Facility', dbid=1592, points=0, name='Single-Unit Airfield (1x 3201-4000m Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 3201-4000m Runway)
		{type='Facility', dbid=1877, points=0, name='Single-Unit Airfield (1x 2600-3200m, Runway)', destroyedString='destroyed'},--Single-Unit Airfield (1x 2600-3200m, Runway)

		{type='Ship', dbid=1114, points=10000, name='LPD 17 San Antonio', destroyedString='sunk'},--LPD 17 San Antonio
		{type='Ship', dbid=2118, points=10000, name='LSD 41 Whidbey Island', destroyedString='sunk'},--LSD 41 Whidbey Island
		{type='Ship', dbid=2339, points=7500, name='CG 56 San Jacinto [Ticonderoga Baseline 3, VLS]', destroyedString='sunk'},--CG 56 San Jacinto [Ticonderoga Baseline 3, VLS]
		{type='Ship', dbid=2343, points=5000, name='DDG 51 Arleigh Burke [Arleigh Burke Flight I]', destroyedString='sunk'},--DDG 51 Arleigh Burke [Arleigh Burke Flight I]
		{type='Ship', dbid=2344, points=5000, name='DDG 72 Mahan [Arleigh Burke Flight II]', destroyedString='sunk'},--DDG 72 Mahan [Arleigh Burke Flight II]
		{type='Ship', dbid=2348, points=5000, name='DDG 91 Pinckney [Arleigh Burke Flight IIA]', destroyedString='sunk'},--DDG 91 Pinckney [Arleigh Burke Flight IIA]
		{type='Ship', dbid=2349, points=5000, name='DDG 96 Bainbridge [Arleigh Burke Flight IIA]', destroyedString='sunk'},--DDG 96 Bainbridge [Arleigh Burke Flight IIA]
		{type='Ship', dbid=2362, points=50000, name='LHA 6 America [Flight 0, Assault-Optimized Makin Island]', destroyedString='sunk'},--LHA 6 America [Flight 0, Assault-Optimized Makin Island]
		{type='Ship', dbid=2593, points=75000, name='CVN 77 George Bush [Nimitz Class]', destroyedString='sunk'},--CVN 77 George Bush [Nimitz Class]
		{type='Ship', dbid=2594, points=3000, name='LCS 1 Freedom', destroyedString='sunk'},--LCS 1 Freedom
		{type='Ship', dbid=2595, points=3000, name='LCS 2 Independence', destroyedString='sunk'},--LCS 2 Independence
		{type='Ship', dbid=765, points=10000, name='DDG 1000 Zumwalt', destroyedString='sunk'},--DDG 1000 Zumwalt
		{type='Ship', dbid=897, points=10000, name='AOE 6 Supply', destroyedString='sunk'},--AOE 6 Supply

		{type='Submarine', dbid=74, points=5000, name='SSN 774 Virginia [Flight I]', destroyedString='sunk'},--SSN 774 Virginia [Flight I]
    }

    local matchData = {}

    for k,v in ipairs (targetList) do
        if v.dbid == theDestroyedUnit.dbid 
			and v.type == theDestroyedUnit.type then
				matchData = v
        end
    end

    if matchData == {} then
        BugMessage('United States_UnitDestroyed', 'No dbid match found for destroyed unit')
        if DebugModeIsOn() then
            ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
        end
    else
		ChangeScore('United States',matchData.points*-1,theDestroyedUnit.name.. ' was '..matchData.destroyedString..'.')
		
		if not matchData.isDrone and theDestroyedUnit.type == 'Aircraft' then
			GenerateSurvivors(theDestroyedUnit.latitude,theDestroyedUnit.longitude,theDestroyedUnit.name)
		end
    end
end