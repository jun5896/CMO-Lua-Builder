local theDestroyedUnit = ScenEdit_UnitX()
local targetDescription = theDestroyedUnit.name

local theMessage =
	ACP126(
	"all",
	"NORAD",
	"z",
	"Norad missile alert centre",
	"all stations",
	"secret",
	"1. reports received of nuclear detonation over " ..
		targetDescription ..
			"<BR> 2. all available intelligence suggests these reports are accurate<br> 3. operation lightning strike assessed as failure<br> 4. set defcon 1"
)

ScenEdit_SpecialMessage("playerside", theMessage)
RegisterMessage(theMessage)

ChangeScore(
	"United States",
	-10000,
	"Pakistani Separatists launched a successful nuclear strike on " .. targetDescription
)

ScenEdit_EndScenario()