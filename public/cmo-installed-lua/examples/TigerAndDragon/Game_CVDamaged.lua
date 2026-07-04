local theDamagedUnit = ScenEdit_UnitX()

local pointsSide = 'India'
if theDamagedUnit.side == 'India' then pointsSide = 'China' end

ChangeScore(pointsSide,3500,theDamagedUnit.name..' was damaged.')
ChangeScore(theDamagedUnit.side,-3500,theDamagedUnit.name..' was damaged.')